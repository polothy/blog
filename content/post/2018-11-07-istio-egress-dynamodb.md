---
title: "Istio Egress to AWS Dynamodb"
date: 2018-11-07T14:26:17-08:00
tags: ["istio", "aws", "dynamodb", "egress"]
---

Took a while to figure out how to properly configure Istio egress to allow a service to talk to DynamoDB.  I didn't find many up-to-date resources out there on the topic, so decided to share what worked for me.

<!--more-->

**Word of caution:** Istio is a young project and changing very rapidly.  This post is based on this networking API version: `networking.istio.io/v1alpha3`

This post assumes that you are already running a service in Kubernetes and [Istio](https://istio.io).  The service now needs to talk to DynamoDB.  The DynamoDB table should exist and your Kubernetes cluster nodes should have proper IAM role(s) to talk to your DynamoDB table.  By default, Istio prevents any connections outside of the mesh unless it is explicitly allowed.  The recommended way to do this is with a `ServiceEntry`, but you can do it by IP range too.

Before starting anything, I really recommend running through the [Egress Task](https://istio.io/docs/tasks/traffic-management/egress/).  It's fast, helps to familiarize yourself with the features and helps to verify that you can indeed get it working.

The **primary thing** that tripped me up when I was trying this for the first time was what that you cannot use a wildcard in your hosts for exposing HTTPS services via a `ServiceEntry`.  EG: you cannot make a single `ServiceEntry` with the host `*.amazonaws.com` to give access to most all of the AWS services.  This is mentioned in [the Istio docs here](https://istio.io/docs/examples/advanced-egress/egress-tls-origination/).  You can use a wildcard in your HTTP hosts.

## AWS session in the service

To connect to DynamoDB, our AWS session looks like this (written in Go):

```go
sess, err := session.NewSession(&aws.Config{
    Region:                        aws.String(endpoints.UsEast1RegionID),
    CredentialsChainVerboseErrors: aws.Bool(true),
    LogLevel:                      aws.LogLevel(aws.LogDebugWithHTTPBody),
})

if err != nil {
    return errors.New(fmt.Sprintf("Failed to create AWS session with error %s", err.Error()))
}

// Continue with your code to interact with DynamoDB
```

So, nothing fancy here, but let's point out a couple of things:

* Not specifying credentials, which means the SDK will basically fall back to IAM roles.  This is what we will be using.
* Besides region, the other parameters are _very_ helpful for debugging outbound connections.  Just look at the logs on your pod for failed requests.

At this point, go ahead and deploy your service and see the logs after you try to interact with DynamoDB.  Should see some errors about which requests were tried and their errors.  It's good to note the hosts here.

In order to allow the service to interact with DynamoDB we need to expose the metadata server, IAM Service and DynamoDB.

## Egress to metadata server

Since we are using IAM to authenticate, the AWS SDK will send a request to `169.254.169.254` which is the [metadata server](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html).  Envoy will block this, we unblock it with some good old YAML:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: aws-metadata-service-entry
spec:
  hosts:
  - 169.254.169.254
  ports:
  - number: 80
    name: http
    protocol: HTTP
  resolution: DNS
  location: MESH_EXTERNAL
```

## Egress to IAM service

Again, since we are using IAM for authentication, the AWS SDK will also send a request to `sts.amazonaws.com` which is the IAM Service.  Let's allow this request too.  Note, this time it is HTTPS so we also need a `VirtualService`:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: aws-sts-service-entry
spec:
  hosts:
  - sts.amazonaws.com
  ports:
  - number: 443
    name: https
    protocol: HTTPS
  resolution: DNS
  location: MESH_EXTERNAL
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: aws-sts-virtual-service
spec:
  hosts:
  - sts.amazonaws.com
  tls:
  - match:
    - port: 443
      sni_hosts:
      - sts.amazonaws.com
    route:
    - destination:
        host: sts.amazonaws.com
        port:
          number: 443
      weight: 100
```

## Egress to DynamoDB

Finally, what we actually want to do, interact with DynamoDB.  Allow this request with the following (modify AWS region as necessary):

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: dynamodb-service-entry
spec:
  hosts:
  - dynamodb.us-east-1.amazonaws.com
  ports:
  - number: 443
    name: https
    protocol: HTTPS
  resolution: DNS
  location: MESH_EXTERNAL
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: aws-dynamodb-virtual-service
spec:
  hosts:
  - dynamodb.us-east-1.amazonaws.com
  tls:
  - match:
    - port: 443
      sni_hosts:
      - dynamodb.us-east-1.amazonaws.com
    route:
    - destination:
        host: dynamodb.us-east-1.amazonaws.com
        port:
          number: 443
      weight: 100
```

## Conclusion

After those definitions are deployed to your cluster, your service should now be allowed to talk to the necessary servers in order to authenticate using IAM and to interact with DynamoDB.

Just want to reiterate: no wildcard in your HTTPS hosts for egress.  Istio is still a young project, so this might change down the road.