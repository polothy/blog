---
title: "Open in Emacs"
date: 2018-11-13T19:27:56-08:00
tags: ["emacs", "spacemacs"]
---

How to open a file/directory or pipe output to Emacs GUI from the terminal.

<!--more-->

I like playing around with editors and my most recent discovery is Emacs with the [Spacemacs](http://spacemacs.org) distribution.  The very first editor that I fell in love with was TextMate and one of the first things I expect every editor to have is a way to open content up from the terminal.  I like to open up files/directories and to pipe content into the editor, EG:

```bash
$ mate hodor.txt
$ echo "hi" | mate
```

When I first looked at Atom, it could open files, but could not handle piping output.  VS Code could open files and eventually supported piping output, but it ended up behaving oddly.  After doing a `echo "Hi" | code -` it would hang in the terminal, supposedly waiting for more output to pipe.  So, you would have to close the file or `Ctr-c` to get the prompt back.  Vi(m) works well, after all, it was born in the terminal.  Thinking the same would be for Emacs, but sadly it is more complicated.

Before diving in, a little information about my setup.  Emacs was installed with `brew cask install emacs`.  I was using `emacs-plus` tap, but I like the simplicity of the cask.  I mention this because after switching to the cask, I had to refactor my bash script below.  In addition, you need to enable the Emacs server in your Spacemacs configuration.  Modify these settings under `dotspacemacs/init`:

```emacs-lisp
;; Start an Emacs server if one is not already running.
dotspacemacs-enable-server 't
;; Where to save server socket file.
dotspacemacs-server-socket-dir '"~/.emacs.d/server"
```

OK, continuing on.  What makes it more complicated than other editors is that you have the Emacs GUI and the Emacs server.  After lots of Googling, tinkering and more hours than I care to mention :smile:, this is what I came up with:

```bash
#!/bin/bash

# Usage: ec file.txt
# OR:    echo "hi" | ec

#set -ex

PARAMS=(-a '' -nq -s ~/.emacs.d/server/server)

# Determine if Emacs is running already or not.
if [ ! -e ~/.emacs.d/server/server ]; then
    PARAMS+=(-c)
fi

if [ -z "$1" ]; then
    TMP="$(mktemp /tmp/stdin-XXX)"
    cat >$TMP
    emacsclient "${PARAMS[@]}" $TMP &> /dev/null
    rm $TMP
else
    emacsclient "${PARAMS[@]}" "$1" &> /dev/null
fi
```

**UPDATE:** I modified the above script to no longer verify if the passed argument is a file or directory that exists.  Reason being, if you want to make a new file, you can with the new code, EG: `ec newfile.txt`. 

This goes into a file named `ec` (or whatever you want) which should be in your `$PATH`.  What this does is first detects if the Emacs server is running by looking for the server socket file (we defined the location of that above). If the server is running, then Emacs is already open, so I omit the `-c` parameter to open in the current frame. Otherwise, I use `-c` to open a new frame.

The second thing the script does is detect if there is no argument.  If that's the case, then it sends the piped output to the temporary file, opens the file in Emacs GUI and then removes the file.  Otherwise, if there is an argument, open that via Emacs GUI.

Is it perfect? Probably not.  Detection of piping output into the script could be improved _a lot_.  I'm betting that the detection of Emacs server running could also be improved. For example, I could imagine a scenario where the server is still running, but I have closed all the frames. But, I'm not shooting for absolute perfection, I can now handle my to main use cases:

```bash
$ ec hodor.txt
$ echo "hi" | ec
```
