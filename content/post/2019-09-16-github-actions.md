---
title: "GitHub Actions"
date: 2019-09-16T12:39:31-07:00
tags: ["github"]
---

Got accepted in the beta program for [GitHub
Actions](https://github.com/features/actions). So, naturally, let's create an
action to publish this blog!

<!--more-->

Prior to using Actions, I used a `Makefile` to publish the blog. It was simple,
short and easy. So, why bother with using Actions? For fun and profit of course!
Also, publishing is now just one step: `git push origin/master`. Winning!

Often I find that being lazy has led to major productivity boots in my life
because I _absolutely hate to repeat tasks_. I learned early on in my career to
automate early and often to help avoid burnout. Why do something manually (ugh!)
when I could automate it (yes!)?

For scripting the building and publishing of my blog, I used
[benmatselby/hugo-deploy-gh-pages](https://github.com/benmatselby/hugo-deploy-gh-pages)
as a starting point. If you follow the link, you will notice that the repository
is a GitHub Action that you can use directly. I didn't use the action because I
wanted to modify the way it publishes the site and I didn't want to pass it my
GitHub token.

To use GitHub Actions, just add a [workflow
file](https://help.github.com/en/articles/configuring-a-workflow) to the
repository. For me, it was `.github/workflows/hugo.yml` with the following
contents:

```yaml
name: Publish Blog with Hugo
on:
  push:
    branches:
    - master
jobs:

  build:
    name: Build
    runs-on: ubuntu-latest
    steps:

    - name: Checkout master
      uses: actions/checkout@v1
      with:
        submodules: true

    - name: Build and publish blog
      env:
        HUGO_VERSION: 0.58.2
        TOKEN: ${{ secrets.TOKEN }}
      run: |
        scripts/action.sh
```

The above basically translates to: on push to master, spin up an Ubuntu box,
checkout _this_ repository with submodules and lastly run my script defined in
_this_ repository with specific environment variables. Remember, this is `beta`
so things will likely change. Syntax documentation can be found
[here](https://help.github.com/en/articles/workflow-syntax-for-github-actions).

The only thing left to do before pushing to `master` is to setup the secret. In
your GitHub account, go to Profile Settings | Developer Settings | Personal
access tokens | Generate new token. Give the token `public_repo` access. Copy
the token after it is created. Go to the repository with the action, Settings |
Secrets. Add a new secret, name it `TOKEN` and paste in the generated token from
earlier. Now trigger the action with a good old `git push origin/master`.

That's it! Visit the repository's Actions tab to watch the workflow execute. So
far, I'm liking the syntax. The steps with the `uses:` are a particularly
interesting extension model. This actually grabs the action from a repository.
For example, `actions/checkout@v1` can be found
[here](https://github.com/actions/checkout) and it has various settings you can
pass to the action.

This is all new to me, but not entirely sure how comfortable I would be using
non-standard actions due to security and stability concerns. More research is
required, but I certainly _love_ the idea of using this model for my own
actions. I'd like to see what it is like to wrap my current deployment script
into an action repository.

## Conclusion

Very easy to get started with GitHub actions. I actually got it working while
waiting for a flight at the airport. Looking forward to writing my own actions
and exploring the rest of the features available to GitHub Actions.
