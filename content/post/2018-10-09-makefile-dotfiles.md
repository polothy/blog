---
title: "Makefile for your dotfiles"
date: 2018-10-09T21:15:27-07:00
tags: ["makefile", "dotfiles", "homebrew"]
---

Using a `Makefile` for your `dotfiles` can help simplify your dot file life!

<!--more-->

I was originally inspired by this [dotfiles](https://github.com/driesvints/dotfiles)
project.  Using `Brewfile` and `mackup` to do most of the heavy lifting.  I
really liked it, but then I ran into some problems:

* `Brewfile` is sort of an all or nothing type system.  It's really only handy
  if you are on a fresh, blank computer.  That doesn't actually happen for me
  that often.  For example, if I upgrade macOS, I need to re-install my ports and
  and `Brewfile` is not practical for this because it includes things like `casks`
  and such.
* For some reason, I was always a little paranoid about `mackup` usage.  Mostly
  it was due to how infrequently I actually used it, so I would forget how it works
  and what commands I should use.  Plus for _my particular setup_, I ended
  up with some rather odd symlinking that would confuse the heck out of me if I had
  forgotten how it worked.

While `Brewfile` and `mackup` are great tools, they were not adding a lot of value
for _me_ and I realized that what they were doing was really simple and I could
migrate to a simple `Makefile`.

## Replacing mackup

Replacing `makup` was easy for me because I was only using it for dot files that
were _only_ located in my `$HOME` directory.  So, the goal is to create a symbolic
link between the files in my `dotfiles` to my `$HOME` directory.

Before reading the `Makefile` below, know this:

* The `Makefile` is located in `dotfiles/Makefile`, so commands run are relative to it.
* The dot files to link to `$HOME` directory are all located in `dotfiles/home` directory.
* [Read this](https://www.gnu.org/software/make/manual/make.html#Prerequisite-Types)
  regarding the pipe in the target dependencies.

```makefile
HOMEFILES := $(shell ls -A home)
DOTFILES := $(addprefix $(HOME)/,$(HOMEFILES))

.PHONEY: link unlink

link: | $(DOTFILES)

# This will link all of our dot files into our home directory.  The
# magic happening in the first arg to ln is just grabbing the file name
# and appending the path to dotfiles/home
$(DOTFILES):
	@ln -sv "$(PWD)/home/$(notdir $@)" $@

# Interactively delete symbolic links.
unlink:
	@echo "Unlinking dotfiles"
	@for f in $(DOTFILES); do if [ -h $$f ]; then rm -i $$f; fi ; done
```

_What's happening?_

* First, create the `HOMEFILES` variable which is a list of our files in the
  `dotfiles/home` directory.  A list in `make` is just space separated list,
  EG: `foo bar baz` is a list of three items.
* `DOTFILES` variable is used to create a list of files that we want to create in
  our `$HOME` directory.  This is done by prepending `$HOME/` to each
  item in the `HOMEFILES` list.  So, if you have `dotfiles/home/.zsh` you
  will get `$HOME/.zsh`.
* The `link` target is there to trigger the creation of any _missing_ dot files
  from your `$HOME` directory.  If you didn't have this target, then you would
  have to do `make $HOME/.zsh` for each file, no fun.
* `$(DOTFILES)` target defines the actual creation of the dot file in your
  `$HOME` directory.  What is nice is that this will not overwrite any
  existing files in your `$HOME` because that's how `make` works.  It wont
  run the target if the file already exists.  And of course, what it does
  is make a link, EG: `ln -sv dotfiles/home/.zsh $HOME/.zsh`
* The `unlink` target iterates over your dot files in your `$HOME` directory
  and _interactively_ deletes your dot files _only if_ that file is a symbolic link.

So, perhaps I got a little verbose in my explanation, but it ends up creating
a pretty simple `Makefile` and the result is very safe.  You can re-run `make link`
as you add new files to `dotfiles/home`.  You can run `make unlink` anytime and
it asks you for confirmation before unlinking anything.  And on top of that,
it's all non-destructive: if you have a _real_ file in your `$HOME` directory,
it will not overwritten or deleted.

## Replacing Brewfile

Replacing `Brewfile` is a little more involved, but ends up working quite well.

```makefile
BREW := /usr/local/bin/brew
PACKAGE = brew list --versions $(1) > /dev/null || brew install $(1)$(2)
CASK = brew cask list $(1) > /dev/null 2>&1 || brew cask install $(1)

.PHONEY: link install brew taps packages casks mas list unlink clean uninstall_brew uninstall_packages

install: | taps packages casks mas link clean

brew: | $(BREW)
	brew update

$(BREW):
	@ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

taps: | brew
	brew tap homebrew/cask
	# and many more...

packages: | brew
	$(call PACKAGE,go)
	# and many more...

casks: | brew
	$(call CASK,alfred)
	# and many more...

mas:
	mas install 587512244 # Kaleidoscope
	# and many more...

# Use to update install lists.
list:
	brew tap
	@echo "\n"
	brew leaves --full-name
	@echo "\n"
	brew cask list --full-name
	@echo "\n"
	mas list

clean:
	brew cleanup
	brew cask cleanup

# Use with caution, can really mess with Cask (thinks nothing is installed).
uninstall_brew:
	@ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"

uninstall_packages:
	brew remove --force --ignore-dependencies $(shell brew list)
```

Still with me? Great! _What is happening?_

* `BREW` variable just defines where `brew` binary is located.
* `PACKAGE` is a function to install a Homebrew package only when
  it is not already installed.
* `CASK` is a function to install a Homebrew Cask application only when
  it is not already installed.  _If I recall correctly_, "already installed
  detection" only works if you used `brew cask` to install the application.
* `install` target triggers everything to install.  You would run this on a fresh
  computer and customize it to your liking.
* `brew` target updates Homebrew.
* `$(BREW)` target installs Homebrew.
* `taps` target defines your Homebrew taps.
* `packages` target conditionally installs each Homebrew package.
* `cask` target conditionally installs each Homebrew Cask application.
* `mas` target installs applications from the App Store.  The
  `mas` binary can be installed via Homebrew.
* `list` is a handy target to list everything you have installed so you can
   update your `Makefile` with anything new.
* `clean` target is used to free up disk space.
* `uninstall_brew` target nukes Homebrew, _use with caution_.
* `uninstall_packages` target uninstalls all of your Homebrew packages.

So, this may look a bit complicated/intimidating, but for me it
helped to simplify things and make some of these install lists more
re-usable.  For example, when upgrading to a new macOS, you should
re-install your Homebrew packages:

```bash
$ make uninstall_packages && make packages
```

Done!  Use multiple computers? Missing applications?

```bash
$ make cask
```

Done!

## Conclusion

`dotfile` :heart: `Makefile`