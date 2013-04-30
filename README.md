# Zephyros

> As Odysseus climbed onto the shore, he opened up his MBP and began to write an email to a mailing list about how terrible his adventure had been, and how he'd almost been drowned by the sea, and how beautiful yet deadly was the sound of the Sirens.
>
> But, noticing how his windows were all in disarray, overlapping one another and terribly sized, he opened Zephyros. Using a little black-CoffeeScript-magic, he tweaked his configs. Then he swiftly began arranging his windows using only his keyboard.
>
> The subjects of the local kingdom, noticing the elegant gracefulness with which he resized and repositioned his Mac windows, set out to make him their king. Even the mighty king of that land, two hundred years old yet stronger than any other, had decided to abdicate his throne for the sake of Odysseus. For he had learned of this foreigner's magnificent configs.
>
> But before the people could approach him, he sensed in himself their plan, so he set out for his home country to reclaim his dear wife Penelope. Yet even so, not without first pushing his config changes to his github repo for all to benefit from. And, being of such noble blood, he even contributed some of his ideas and configs to the Zephyros wiki for all to benefit from.
> - The Odyssey

## About Zephyros

*The OS X window manager for hackers*

* Current version: **2.4**
* Requires: OS X 10.7 and up
* Download: [latest .zip file](https://raw.github.com/sdegutis/zephyros/master/Builds/Zephyros-LATEST.app.tar.gz), unzip, right-click app, choose "Open"

Table of contents:

* [Overview](#overview)
    * [Basics](#basics)
    * [Modular Configs](#modular-configs)
    * [Auto-Reload Configs](#auto-reload-configs)
    * [Using Other Languages](#using-other-languages)
* [Config Example](#config-example)
    * [More Config Tricks/Examples](#more-config-tricksexamples)
* [API](#api)
    * [Top Level](#top-level)
    * [Type "API"](#type-api)
    * [Type "Settings"](#type-settings)
    * [Type "Window"](#type-window)
    * [Type "Screen"](#type-screen)
    * [Type "App"](#type-app)
    * [Other Type](#other-types)
    * [Events](#events)
* [Mailing List](#mailing-list)
* [Change log](#change-log)
* [Todo](#todo)
* [License](#license)

## Overview

#### Basics

At it's core, Zephyros is just a program that runs quietly in your menu bar, and loads a config file in your home directory.

You can write your config file using either:

- JavaScript as `~/.zephyros.js`
- [CoffeeScript 1.6.2](http://coffeescript.org/) as `~/.zephyros.coffee`
- any language which compiles down to JavaScript (see [Using Other Languages](#using-other-languages) below)

In your config file, `bind()` some global hot keys to your own JavaScript functions which do window-managery type things.

Here are some things you can do with Zephyros's simple API ([actual API docs are below](#api)):

- find the focused window
- determine window sizes and positions
- move and resize windows
- change focus to a given window
- listen to global events (window created, app launched/killed, etc)
- transfer focus to the closest window in a given direction
- run shell scripts
- open apps, links, or files
- get free pizza (okay not really)
- and more!

Is the API missing something you need? File an issue and let me know!

For your convenience, [underscore.js](http://underscorejs.org/) 1.4.4 is loaded beforehand.

#### Modular Configs

Feel free to put some `.coffee` or `.js` files in `~/.zephyros/` and `require()` them from your main config file.

If you want to put your config files all in one dir, you can use `~/.zephyros/config.*` as your config file instead of `~/.zephyros.*`. This has the advantage of your config files auto-reloading properly for new languages, plus you can then put the whole directory under version control more easily.

#### Auto-Reload Configs

When you enable this feature via the menu, Zephyros will reload your config file any time `~/.zephyros.coffee`, `~/.zephyros.js`, or anything within `~/.zephyros/` changes.

#### Using Other Languages

Besides JS and CoffeeScript, you can extend Zephyros to load other languages as well, so long as they compile down to JavaScript. There's a pretty big list you can choose from at [altjs.org](http://altjs.org/) and in [this guy's list](https://github.com/jashkenas/coffee-script/wiki/List-of-languages-that-compile-to-JS).

To use another language:

* Create `~/.zephyros/langs.json` which is a hash in the format `{ 'rb' : '/path/to/ruby-to-js/compiler' }`
* Now you can `require('~/.zephyros/myfile.rb');` from your main config.
* Plus you can use `~/.zephyros.rb` as your primary config.

#### Config Caveats

- If both config files exist, the most recently modified one will be chosen. You can override this by using `touch`.
- If reloading your config file fails, your key bindings will be un-bound as a precaution, presuming that your config file is in an unpredictable state. They will be re-bound again next time your config file is successfully loaded. Same with events you're registered to.

## Config Example

Put the following in `~/.zephyros.coffee`

```coffeescript
# useful for testing
bind "R", ["cmd", "alt", "ctrl"], -> reloadConfig()

# maximize window
bind "M", ["cmd", "alt", "ctrl"], ->
  win = api.focusedWindow()
  win.setFrame win.screen().frameWithoutDockOrMenu()

# push to top half of screen
bind "K", ["cmd", "alt", "ctrl"], ->
  win = api.focusedWindow()
  frame = win.screen().frameWithoutDockOrMenu()
  frame.size.height /= 2
  win.setFrame frame

# push to bottom half of screen
bind "J", ["cmd", "alt", "ctrl"], ->
  win = api.focusedWindow()
  frame = win.screen().frameWithoutDockOrMenu()
  frame.origin.y += frame.size.height / 2
  frame.size.height /= 2
  win.setFrame frame
```

#### More Config Tricks/Examples

The [wiki home page](https://github.com/sdegutis/zephyros/wiki) has a list of configs from users, and configs that replicate other apps (like SizeUp and Divvy).

## API

### Top Level

```coffeescript
property (API) api

- (void) log(String str)                   # shows up in the log window
- (void) alert(String str[, Float delay])  # shows in a fancy alert; optional delay is seconds

- (void) bind(String key,              # case-insensitive single-character string; see link below
              Array<String> modifiers, # may contain any number of: "cmd", "ctrl", "alt", "shift"
              Function fn)             # javascript fn that takes no args; return val is ignored

- (void) listen(String eventName, Function callback) # see Events section below

- (void) reloadConfig()

- (void) require(String path) # looks at extension to know which language to use
                              # if relative path, looks in `~/.zephyros/`

- (Hash) shell(String path, Array<String> args[, String stdin]) # returns {"stdout": string,
                                                                #          "stderr": string,
                                                                #          "status": int}

- (void) open(String thing) # can be path or URL

- (void) doAfter(Float sec, Function fn)
```

The function `bind()` uses [this list](https://github.com/sdegutis/zephyros/blob/master/Zephyros/SDKeyBindingTranslator.m#L148) of key strings.

### Type: `API`

```coffeescript
- (Settings) settings()

- (Array<Window>) allWindows()
- (Array<Window>) visibleWindows()
- (Window) focusedWindow()

- (Screen) mainScreen()
- (Array<Screen>) allScreens()

- (Array<App>) runningApps()

- (String) clipboardContents()
- (String) selectedText()
```

### Type: `Settings`

```coffeescript
property (Float) alertDisappearDelay # in seconds.
property (Boolean) alertAnimates     # when opening.

- (NSBox) alertBox()
- (NSTextField) alertTextField()
```

### Type: `Window`

```coffeescript
- (Grid) getGrid()
- (void) setGrid(Grid g[, Screen optionalScreen])
# grids are just JS objects with keys {x,y,w,h} as numbers, 0-based index

class-property (number) Window.gridWidth # default: 4
class-property (number) Window.gridMarginX # default: 5
class-property (number) Window.gridMarginY # default: 5
# these margins are for giving window-shadows some breathing room

- (CGPoint) topLeft()
- (CGSize) size()
- (CGRect) frame()

- (void) setTopLeft(CGPoint thePoint)
- (void) setSize(CGSize theSize)
- (void) setFrame(CGRect frame)
- (void) maximize()

- (Screen) screen()
- (Array<Window>) otherWindowsOnSameScreen()
- (Array<Window>) otherWindowsOnAllScreens()

- (String) title()
- (Boolean) isWindowMinimized()

- (Boolean) isNormalWindow() # you probably want to avoid resizing/moving ones that aren't

- (App) app()

- (Boolean) focusWindow()
- (void) focusWindowLeft()
- (void) focusWindowRight()
- (void) focusWindowUp()
- (void) focusWindowDown()
```

### Type: `Screen`

```coffeescript
- (CGRect) frameIncludingDockAndMenu()
- (CGRect) frameWithoutDockOrMenu()

- (Screen) nextScreen()
- (Screen) previousScreen()
```

### Type: `App`

```coffeescript
- (Array<Window>) allWindows()
- (Array<Window>) visibleWindows()

- (String) title()
- (Boolean) isHidden()

- (void) kill()
- (void) kill9()
```

### Other Types

The rest of the types here are classes from ObjC, bridged to JS. Here's a few for reference:

```coffeescript
# CGRect
property (CGPoint) origin # top-left
property (CGSize) size

# CGSize
property (Float) width
property (Float) height

# CGPoint
property (Float) x
property (Float) y
```

The rest you'll have to look up for yourself.

### Events

```coffeescript
'window_created', callback args: (win)
'window_minimized', callback args: (win)
'window_unminimized', callback args: (win)
'window_moved', callback args: (win)
'window_resized', callback args: (win)
'app_launched', callback args: (app)
'app_died', callback args: (app)
'app_hidden', callback args: (app)
'app_shown', callback args: (app)
```

## Mailing List

There's a Google Groups [mailing list](https://groups.google.com/forum/?fromgroups=#!forum/windows-app) for discussion about config ideas, techniques, or anything related to Zephyros


## Change log

- 2.4
  - Adds grid functions to window
- 2.3.6
  - The app has been renamed!
      - **But** this means auto-updating won't work.
      - Download it from the link at the top of this page.
      - Sorry. This *should* be the only time you'll ever need to do this.
  - Added `show` and `hide` to App class.
  - Added `minimize` and `unMinimize` to Window class.
  - Modified shell API method: `shell(command, args, options)`. Options is a hash with the following optional keys:
      - "input": a string with the command input
      - "pwd": a string with the working directory
      - "donotwait": a boolean, when `true` will launch the command in background and will discard the output
- 2.3.5
  - Windows.app needs to be renamed. [Cast your vote](https://groups.google.com/forum/?fromgroups=#!topic/windows-app/-Y5omxtblT0) for a new name!
  - Besides that, there's nothing new in this version.
- 2.3.4
  - Fixed `open()`
  - Fixed `selectedText()` to work in many more places, including web views (thanks [Julián Romero](https://github.com/djromero)!)
- 2.3.3
  - Fixed critical bug whereby configs wouldn't load at all if you didn't have the langs.json file (thanks [Rajarshi Nigam](https://github.com/rajington)!)
  - Added `win.otherWindowsOnAllScreens()`
  - The functions `win.focusWindow[Direction]()` now take into account all screens
- 2.3.2
  - Added `doAfter(sec, fn)`
  - Correctly handles choosing from more than 2 options of primary configs
  - Also looks for primary config files via `~/.zephyros/config.*`
      - This fixes the auto-reload non-cs/js config files bug
  - `require()` can now take a relative path (assumes `~/.zephyros/` prefix)
- 2.3.1
  - Fixed lots of functions in API to return actual JS types
  - Fixed event callbacks to give you actual JS types
  - Renamed `app.windows()` to `app.allWindows()`
  - Added `app.visibleWindows()`
  - Added `win.isNormalWindow()`
- 2.3
  - Added ability to use [AltJS](http://altjs.org/) etc. languages
  - Added `App` type, moved `isAppHidden` into it, gave it some fun methods
  - Added events
- 2.2.2
  - Navigate REPL history with C-n/C-p (or up/down)
  - Added 'pwd' argument to `shell()`
  - Fixed some bugs in the API (notably `api.visibleWindows` et al. can be enumerated)
  - Made the API almost entirely JS, so it'll work just as you expect
      - Only non-JS types are `Settings`, `CGRect`, `CGSize`, `CGPoint`
- 2.2.1
  - REPL can now take CoffeeScript or JS
  - Re-styled logs in Log Window
- 2.2
  - Renamed `print()` to `log()`
  - Converted all public-facing API to pure JS objects
  - Moved `selectedText()` to `api` object
  - Revamped Log Window, now includes REPL
- 2.1.2
  - First version anyone should care about

## Todo

### Want to help?

* Are you some kind of designer? Want to help? Great! We need these 3 things:
    1. better CSS styling in [the Log Window](Zephyros/logwindow.html)
    2. a better app icon (current one is literally a ripoff of [AppGrid's](https://dxezhqhj7t42i.cloudfront.net/image/1e0daca8-3855-4135-a2a1-8569d28e8648))
    3. a better menu bar icon (current one is literally a ripoff of [AppGrid's](http://giantrobotsoftware.com/appgrid/screenshot1-thumb.png))
* Are you a JS programmer? There's lots of low-hanging fruit!
    * Better error handling when passing wrong stuff into API functions
    * Convert more stuff in `api.coffee` to JS types before giving them to people (ugh so tedious though)
* Are you an ObjC programmer? There's lots of low-hanging fruit!
    * Get rid of the `NSPasteboard` category and the use of `objc_[g,s]etAssociatedObject`
    * Check for syntax errors (in raw JS) before evaluating code, and show them in the log window if there are any
    * Show evaluated (raw JS) code when there are runtime errors
    * Give a better error message if your config file *actually turns out to be a directory* (sigh)
    * Add `mouseMoved` event, but coalesce notifications to a reasonable amount (default every 0.5 sec, make it configurable)
    * Add `api.windowUnderMouse()`
    * Add `api.screenUnderMouse()`

## License

It's been said that a project's license reveals what its authors were afraid of. For example, if they're afraid of having their name dragged through the mud, they'll choose BSD over MIT, and if they're afraid people will use their work in some proprietary project without contributing back to the community, they'll choose GPL over either. Therefore, this software is licensed under the [MIT license](Licenses/LICENSE) with the additional clause that by using this software you agree not to put spiders or any other bugs under my pillow or blanket.
