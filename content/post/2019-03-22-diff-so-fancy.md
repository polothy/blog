---
title: "diff-so-fancy"
date: 2019-03-22T20:42:16-07:00
tags: ["awesome-cli", "git"]
---

Oh, so _fancy_!

<!--more-->

The project [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy) is a tool
to make `git diff` more readable. Err... more _fancy_!

Install and usage is pretty easy.  Just `brew install diff-so-fancy` to install
and then you can configure `git` to use it.  If you want to go all in, use the
official method:

```shell
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
```

For me, I just enabled it for `git diff` and `git show` by adding the following
to my `.gitconfig` file:

```gitconfig
[pager]
	diff = diff-so-fancy | less --tabs=4 -RFX
	show = diff-so-fancy | less --tabs=4 -RFX
```

Also in the install, they recommend adding some colors to the `git diff` output.
I already had a lot set, so mine ended up looking like this:

```gitconfig
[color]
  pager = true
  ui = auto
  status = auto
  diff = auto
  branch = auto
  showBranch = auto
  interactive = auto
  grep = auto
[color "status"]
  header = black bold
  branch = cyan
  nobranch = red
  unmerged = red
  untracked = magenta
  added = green
  changed = yellow bold
[color "diff"]
  meta = magenta
  frag = black bold
  func = blue
  old = red strike
  new = green
  commit = cyan
  whitespace = red
  context = normal dim
[color "branch"]
  current = cyan
  local = blue
  remote = magenta
  upstream = magenta
  plain = normal
[color "decorate"]
  branch = green bold
  remoteBranch = magenta bold
  tag = magenta bold
  stash = cyan
  HEAD = cyan bold
[color "interactive"]
  prompt = red
  header = red bold
  error = red
  help = black bold
[color "grep"]
  context = normal
  match = green
  filename = blue
  function = blue
  selected = normal
  separator = cyan bold
  linenumber = yellow
[color "diff-highlight"]
  oldNormal = red
  oldHighlight = red 52
  newNormal = green
  newHighlight = green 22
```

And that's it! Now you are _fancy_!  One thing I worried about when I was setting
this up is if `diff-so-fancy` would break things when I tried to save a diff to
a file for a patch or somehow break other tools, like `tig`.  But, no need to
fear, the install method ensures `diff-so-fancy` only kicks in when you need to
use the pager.  So, when you are piping output to another command or sending it
to a file, `git` already knows not to use the pager and thus, `diff-so-fancy` is
not invoked.

Here is a demo with some silly edits:

![diff-so-fancy demo](/img/diff-so-fancy-demo.png)

What I particularly like about the above output is the highlighting of the
changed words.

Lastly, I recommend checking out their [pro
tips](https://github.com/so-fancy/diff-so-fancy/blob/master/pro-tips.md) for
some extra _fancy_. I'm currently trying out the "Moving around in the diff"
tip.
