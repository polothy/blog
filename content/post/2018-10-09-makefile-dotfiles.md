---
title: "Makefile for your dotfiles"
date: 2018-10-09T19:45:24-07:00
---

The secret is out, I really like a good `Makefile`!  I like to use them almost
everywhere, even in my `dotfiles`.

<!--more-->

I was originally inspired by this [dotfiles](https://github.com/driesvints/dotfiles)
project.  Using `Brewfile` and `mackup` to do most of the heavy lifting.

Then I ran into some problems:

* `Brewfile` is sort of an all or nothing type system.  It's really only handy
  if you are on a fresh, blank computer.  That doesn't actually happen for me
  that often.
* For some reason, I was always a little paranoid about `mackup` usage.  I always
  would lookup source code for how it worked.  Plus for my particular setup, I ended
  up with some rather odd symlinking that would confuse the heck out of me if I had
  forgotten how it worked.

While `Brewfile` and `mackup` are great tools, they were not adding a lot of value
for _me_ and I realized that what they were doing was really simple and I could
migrate to a simple `Makefile` (read: simple to me!).

## Replacing mackup

Replacing `makup` was easy for me because I was only using it for dot files that
were _only_ located in my `$HOME` directory.

```markdown

```