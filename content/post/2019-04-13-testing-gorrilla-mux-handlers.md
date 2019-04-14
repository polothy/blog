---
title: "Testing gorilla/mux handlers"
date: 2019-04-13T15:11:52-07:00
tags: ["go"]
---

Currently working on a prototype microservice and to get started quickly I
decided to use [gorilla/mux](https://github.com/gorilla/mux) as my router
because of its low barrier of entry and plenty of resources out there on it.
One thing that has bothered me before when I have used `mux` was how to go about
testing the HTTP handlers. Discovered a nice way to do it.

<!--more-->

_tl;dr_ Checkout this
[gist](https://gist.github.com/polothy/dc4fa7796ca12f876e9173a50a25804b).

There are many ways to go about this, but here are some requirements that helped
to shape the design:

1. I wanted to pass in any dependencies directly to the handler. I like the
  simplicity of this and it avoids things like global structs or a single
  massive struct that contains any possible dependency you might use across your
  handlers.
2. I wanted to test the routing to the handler as well. While you can test the
   handler in isolation, I like the idea of knowing that the route config works
   as expected.

In order to satisfy the above, we need to wire up a `mux` router with our route
and handler in each test. Two problems can arise while testing this way:

1. The route definition can become duplicated in the test, which might lead to
   the route becoming stale. You are also not actually testing your real route.
2. Avoiding duplication can also lead to another problem: the router with all
   the routes is usually built all at once. This can become a problem at testing
   time if you have a wide variety of dependencies across all of your handlers.
   You would have to build out those dependencies in each test in order to just
   route to a single handler.

To avoid duplication of the route and to avoid building the router with all the
routes and handlers, I came up with this really simple solution:

```go
package main

import (
	"net/http"

	"github.com/gorilla/mux"
)

// Handler is responsible for defining a HTTP request route and corresponding handler.
type Handler struct {
	// Receives a route to modify, like adding path, methods, etc.
	Route func(r *mux.Route)

	// HTTP Handler
	Func  http.HandlerFunc
}

// AddRoute adds the handler's route the to the router.
func (h Handler) AddRoute(r *mux.Router) {
	h.Route(r.NewRoute().HandlerFunc(h.Func))
}
```

The above defines a `Handler` struct with two fields:

* `Handler.Route`: this is used to define the route for the handler.
* `Handler.Func`: this is used to define the actual HTTP handler.

In addition, the `Handler` struct has the `AddRoute` method to attach the
handler's route to the router.

Here is how you define a new handler:

```go
package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func Greeter(prefix string) Handler {
	return Handler{
		Route: func(r *mux.Route) {
			r.Path("/greet/{name}").Methods("GET")
		},
		Func: func(w http.ResponseWriter, r *http.Request) {
			name, ok := mux.Vars(r)["name"]
			if !ok || name == "" {
				name = "Champ"
			}
			_, err := w.Write([]byte(prefix + " " + name + "!"))
			if err != nil {
				log.Printf("Failed to write to response: %s\n", err)
			}
		},
	}
}
```

The above defines a `Greeter` function that returns the `Handler` struct.  It
accepts a single dependency, which is just a string.  With a little imagination
though, the dependency could be something more complicated, like database
connection, application service, etc. Then it fills out the `Handler` by
providing the `Route` and `Func` logic.

Here is how it looks to actually use `Greeter`:

```go
package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {
	r := mux.NewRouter()

	complexDependency := "Hello" // ;)
	Greeter(complexDependency).AddRoute(r)

	log.Fatal(http.ListenAndServe(":8000", r))
}
```

Simple enough. Just create the router, build `Greeter` and add its route to the
router. Lastly, start the server.

And finally, this is how it looks to test `Greeter`:

```go
package main

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gorilla/mux"
)

func TestGreeter(t *testing.T) {
	w := httptest.NewRecorder()
	r := mux.NewRouter()
	Greeter("Hello").AddRoute(r)
	r.ServeHTTP(w, httptest.NewRequest("GET", "/greet/Hodor", nil))

	if w.Code != http.StatusOK {
		t.Error("Did not get expected HTTP status code, got", w.Code)
	}
	if w.Body.String() != "Hello Hodor!" {
		t.Error("Did not get expected greeting, got", w.Body.String())
	}
}
```

Also very straight forward, nearly identical to the actual usage. The above test
verifies the `Greeter` handler's route and the HTTP handler _in isolation_ from
any other handler.

## Conclusion

Overall, I think this is a nice approach as it bundles the route and the handler
in a single, reusable package. It is also very IDE friendly as the IDE will
auto-fill the `Handler` fields with the appropriate function definitions. In
addition, it is very copy/paste friendly because the only identifier that _must_
be renamed is the function name (EG: `Greeter`).
