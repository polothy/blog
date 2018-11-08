---
title: "Knative"
date: 2018-11-07T20:59:04-08:00
tags: ["istio", "kubernetes", "knative"]
---

[Knative](https://cloud.google.com/knative/) (pronounced kay-nay-tiv):

> Kubernetes-based platform to build, deploy, and manage modern serverless workloads.

<!--more-->

Randomly stumbled upon Knative when I saw Jenkins X project was using it to enable Serverless Jenkins Builds.  Upon first glace, I thought neat, then closed my browser tab.  Then, I randomly stumbled upon it again (yes, the whole internet is clickbait for me!) and this time, I studied the docs some more and I became _very_ interested.  Apparently Knative is the serverless add-on for Google's managed Kubernetes (GKE).

The project is split up across several GitHub projects, [docs](https://github.com/knative/docs), [serving](https://github.com/knative/serving), [build](https://github.com/knative/build), [eventing](https://github.com/knative/eventing), [build-pipeline](https://github.com/knative/build-pipeline), etc.

The _very_ attractive features are that you can define your source git repository and have your project's container built and deployed within Kubernetes on `git push`.  In addition, you get very nice features like blue/green deployments and autoscaling, down to zero (AKA serverless).  Knative can deliver some of these features because it is built on top of Istio, which I'm a big fan of and makes the Knative project even more interesting to me.

As if that wasn't enough, another great feature of Knative is that it uses custom [CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/) in order to allow you to define your project's requirements in YAML that then gets processed by Kubernetes.  And because of this, we can apply GitOps (perhaps with [Flux](https://github.com/weaveworks/flux)) to our application's _build and deployment_ process.  This is great because if someone spills their coffee on the cluster, then we just re-sync our YAML and our project is building and deploying once again, nothing is lost.

After watching the demo and reading some docs, I saw some gaps:

* There isn't a way to create a private service (AKA a mesh only service).  Looks like there is [an issue](https://github.com/knative/serving/issues/2127) though for 0.3 release.
* Building your container is great, but you really need a pipeline with tests.  I found [build-pipeline](https://github.com/knative/build-pipeline) and it looks really nice.  Allows you to define a build pipeline with tasks and can even fan in/out.  Only problem, it does not have any releases yet.
* Wonder how multi-cluster would work? If you have to deploy globally and into multiple clusters.  Maybe each would just build and deploy the service.

The project is very young, only at version 0.2 at the time of writing, but appears to have some good momentum based on the GitHub Insights.  Considering this project is driving new features for GKE and there are several other companies partnered with Google to build Knative, it seems like a great project to start tracking and playing around with.