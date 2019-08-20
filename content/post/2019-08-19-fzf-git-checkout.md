---
title: "Fuzzy git checkout"
date: 2019-08-19T20:01:43-07:00
tags: ["fzf", "git"]
---

Using `fzf` for `git checkout`.

<!--more-->

First things first, let's see the goods!

![Demo of git checkout with fzf](/img/fzf-git-checkout-demo.png)

The above image has a list of git branches to checkout on the left hand side.
The list of branches can be fuzzy filtered. On the right hand side, it shows a
`git log` of the selected branch that you can scroll it with the mouse or
`Shift-up`/`Shift-down`.

Why do this? For fun and profit! For me, `git checkout`, even with nice tab
completion, can get a bit cumbersome. Especially for work related branches that
often have ticket IDs in them.

How? Some simple functions can do it (tested in `zsh`). Here is the first:

```bash
fzf-git-branch() {
    git rev-parse HEAD > /dev/null 2>&1 || return

    git branch --color=always --all --sort=-committerdate |
        grep -v HEAD |
        fzf --height 50% --ansi --no-multi --preview-window right:65% \
            --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
        sed "s/.* //"
}
```

Let's break it down! The first line just checks if we are in a git repository,
if no, bail. The second line is a series of commands piped together. It might
look like a mess at first, but here it is broken down:

1. First list all the branches and sort them so most recent is at the bottom of
   the `fzf` menu. Most likely going to checkout a branch that has been recently edited.

```bash
git branch --color=always --all --sort=-committerdate
```
2. Then filter out any branches branches with `HEAD` in it. Usually this is
   something like `remotes/origin/HEAD -> origin/master` which isn't helpful for
   what we are doing.
```bash
grep -v HEAD
```
3. Then send all the branches to `fzf`. Use `man fzf` to see what the parameters
mean, but it's mostly all for customizing the display. The preview is just running `git log` on the
currently selected branch with some formatting and limiting to 50 commits.
```bash
fzf --height 50% --ansi --no-multi --preview-window right:65% \
            --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})'
```
4. Lastly, the selected branch from `fzf` is filtered through `sed` to remove
   the asterisk and leading whitespace.
```bash
sed "s/.* //"
```

Once you figure out how it all works, you can start to customize it to suite
your own needs. Maybe you want a different preview, change sorting, no remote
branches, etc.

This function by itself isn't _that_ great. All it does is print the branch. For
example, you can do something like:

```shell
git checkout -b testing $(fzf-git-branch)
```

Which works, but it's a little wonky. Let's say you don't select a branch
(forgot to fetch), hitting `Esc` will cancel the selection, but the git command
will still run. We can do better.

```bash
fzf-git-checkout() {
    git rev-parse HEAD > /dev/null 2>&1 || return

    local branch

    branch=$(fzf-git-branch)
    if [[ "$branch" = "" ]]; then
        echo "No branch selected."
        return
    fi

    # If branch name starts with 'remotes/' then it is a remote branch. By
    # using --track and a remote branch name, it is the same as:
    # git checkout -b branchName --track origin/branchName
    if [[ "$branch" = 'remotes/'* ]]; then
        git checkout --track $branch
    else
        git checkout $branch;
    fi
}

```

This is a simple wrapper function to our previous one. It lets you select a
branch and then runs `git checkout` for you. If you selected a remote branch,
it'll use the
[\-\-track](https://git-scm.com/docs/git-checkout#Documentation/git-checkout.txt---track)
option. I like the `--track` option because it errors out if the branch already
exists locally. If that's the case, then I would likely want to instead checkout
the local branch and update it from the remote.

Of course, typing these long function names is a terrible idea, use aliases:

```bash
alias gb='fzf-git-branch'
alias gco='fzf-git-checkout'
```

That's it! Fun way to checkout branches. I got inspiration for this from the
[fzf wiki](https://github.com/junegunn/fzf/wiki/Examples#git) and this
[gist](https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236) from
the `fzf` author.


