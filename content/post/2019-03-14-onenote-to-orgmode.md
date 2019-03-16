---
title: "OneNote to Org mode"
date: 2019-03-14T19:29:23-07:00
tags: ["emacs", "spacemacs", "orgmode"]
---

I decided to make a very nerdy decision: use Org mode instead of OneNote.

<!--more-->

Don't get me wrong, OneNote is actually a pretty nice application. I would never
have used it, but at work I already needed to have Office installed and OneNote
came with it. It all started one day when I had about _100 browser tabs_ open
and I was using them like a to do list. I thought, notes, I need to take notes!
OneNote was there and really helped me with keeping a reading list, a to do list
and anything random that I came across or thought about.

Then I started taking a liking to Emacs with the
[Spacemacs](http://spacemacs.org) distribution. While exploring the Emacs
community, I found that a lot of users picked up Emacs _just to use_ [Org
mode](https://orgmode.org). When you know nothing about Org mode and you first
take a look, it seems very overwhelming. There are **a lot** of features and
this leads to a lot of syntax and keyboard bindings to learn. But what got me
was that it did it all in plain text, which means my notes are my own and I'll
have them forever. Not to mention that Org mode can export to several different
formats, so it has a built in escape hatch. My point being, OneNote might not be
around in 10 years, but I should be able to open a plain text file any day.

## Getting started

Like I said before, even though Org mode saves to plain text, it can do a lot.
So when you are trying to learn it, you can go off the deep end really quickly
by trying to learn _everything_ Org mode can do. I made that mistake, and what I
should have done was just jump in and play with it. Here are some of the basics
to get started for taking notes and to dos:

* For a to do list, just use the headings. Sub-headings are your to do items. A
  heading is just a new line with an asterisk, a sub-heading with two asterisks,
  and so on.
* To turn a heading into a `TODO`, just hit `Shift-<left/right>`. Same command
  to switch it to `DONE`. You can customize these states if you want.
* The `M-<left/right/up/down>` can indent/outdent heading or moving them
  up/down.
* If you are at the end of a line, then `M-Return M-Return` (yes twice) will
  insert a new heading of the same level on the next line (this might be
  Spacemacs specific).
* You can collapse any heading with content under it by hitting `Tab` key. Hit
  `Tab` again to show it. It also expands sub-trees.
* To insert a link while in insert mode, `M-Return i l`.

Think that's it for my Org mode 101. That's about 90% of what I do and it pretty
much gets me feature parity with OneNote. After that, you can slowly explore the
wonders of Org mode as you actually need them.

## Demo

Here's a mini demo of Org mode.  This is what is in the `demo.org` file:

```org
* General
** TODO Buy supplies
** DONE Mine obsidian
CLOSED: [2019-03-14 Thu 20:06]
** Plot to take the throne
Just some take some me time to think about taking over Westeros.
* House
** Winterize
It's coming some day.
* Garden
** Feed Fang
** Deal with white walkers
```

The above might look a little unappealing. Sort of hard to read, nothing is
indented, looks verbose to type, etc. But there's a couple of things that Org
mode does that is unlike other formats, like Markdown:

* Think of the above as source code. This isn't what you see while editing.
* The above also isn't exactly what you type in. There are simple commands to
  help generate it (like in the above section on the basics).
* Org mode actually handles a lot of the formatting for you.

So, with the above in mind, here is how it is rendered in Emacs:

![Org mode demo rendering](/img/orgmode-demo.png)

Looks pretty nice eh? Just wanted to point out, see how the other major headings
are collapsed? This makes very large Org files easy to manage and easy to focus
on one section at a time.

## What about notes on the go?

One thing OneNote has going for it is that it has a mobile app for editing your
notes on the go. Nothing _native_ exists for Org mode, but there are options.
The good looking option is [Beorg](https://beorgapp.com). I haven't started
using yet because I'm not a huge note taker on my phone anyways, but good to
know that I have the option.

## Org mode for blogs

You might be wondering:

> Are you writing your blog in Org mode?

Answer: no. I tried it with my last post and while writing I found an Org to
HTML rendering error on something simple. The project that Hugo uses to render
Org files is pretty stagnant, so attempting to send a pull request there might
not be worth my time. Plus, first requirement of my blog is to be easy! Markdown
is better supported with Hugo and that's what I'm going to stick with for now.

I know it is entirely possible to write a blog with Org mode, I have seen others
do it. I'm just using Hugo right now and want to stick with what works best with
it.

## Conclusion

It's been fun learning Org mode, it's very _geeky_ and I like that. Plus, now I
have one less application I need to login with my every changing work password
with 2FA just to jot down a thought.
