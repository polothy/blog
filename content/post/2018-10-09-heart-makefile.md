---
title: "<3 Makefile"
date: 2018-10-09T19:45:24-07:00
---

The secret is out, I really like a good `Makefile`!

<!--more-->

Ever since college, I had only ever heard of how terrible `Makefiles` are, so
I have always avoided them.  The Symfony project thought at one point that
they would shift to using `make`.  When that happened, I thought that
I better learn how to use it.  After researching and trying it out, 
I really started to like `make`.  There's a learning curve, but great payoff.

I noticed some key things about my projects that were converted to using a
`Makefile`:

1. Reduction in documentation.  A lot of "How do I...?" get answered by
   running `make target`.
2. Random Bash scripts were deleted and migrated to the `Makefile`, often
   improving.  I'm not a Bash Wizard, so this is a good thing.
3. Standardizes project tasks for everyone.

Now with `make`, I am automating _all the things_ and writing less documentation.
Win win for me.  Another great thing about `make` is that it is usually already
installed. This means that most people do not have to install something in order
use your automation tool of choice (EG: it's as convient as Bash scripts).

Some other things I like about `make`:

* Error handling.  If a command fails, it bails.
* Being able to conditionally control the printing of the command being
  executed via prefixing `@`.
* Targets and their dependencies.  Makes it really easy to organize and
  ensure everything happens in the correct order.

Symfony ended up not using `make`, but I was already hooked.