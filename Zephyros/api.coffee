mapToJS = (list, fn) -> _.map __jsc__.toJS(list), fn
objToJS = (obj) -> __jsc__.toJS obj

class Screen
  @fromNS: (proxy) -> new Screen proxy
  constructor: (@proxy) ->
  frameIncludingDockAndMenu: -> @proxy.frameIncludingDockAndMenu()
  frameWithoutDockOrMenu: -> @proxy.frameWithoutDockOrMenu()
  nextScreen: -> Screen.fromNS @proxy.nextScreen()
  previousScreen: -> Screen.fromNS @proxy.previousScreen()

class App
  @fromNS: (proxy) -> new App proxy
  constructor: (@proxy) ->
  isHidden: -> @proxy.isHidden()
  show: -> @proxy.show()
  hide: -> @proxy.hide()
  allWindows: -> mapToJS @proxy.allWindows(), Window.fromNS
  visibleWindows: -> mapToJS @proxy.visibleWindows(), Window.fromNS
  title: -> @proxy.title()
  kill: -> @proxy.kill()
  kill9: -> @proxy.kill9()

class Window
  @fromNS: (proxy) -> new Window proxy
  constructor: (@proxy) ->
  topLeft: -> @proxy.topLeft()
  size: -> @proxy.size()
  frame: -> @proxy.frame()
  setTopLeft: (x) -> @proxy.setTopLeft(x)
  setSize: (x) -> @proxy.setSize(x)
  setFrame: (x) -> @proxy.setFrame(x)
  maximize: -> @proxy.maximize()
  minimize: -> @proxy.minimize()
  unMinimize: -> @proxy.unMinimize()
  app: -> App.fromNS @proxy.app()
  isNormalWindow: -> @proxy.isNormalWindow()
  screen: -> Screen.fromNS @proxy.screen()
  otherWindowsOnSameScreen: -> mapToJS @proxy.otherWindowsOnSameScreen(), Screen.fromNS
  otherWindowsOnAllScreens: -> mapToJS @proxy.otherWindowsOnAllScreens(), Screen.fromNS
  title: -> objToJS @proxy.title()
  isWindowMinimized: -> @proxy.isWindowMinimized()
  focusWindow: -> @proxy.focusWindow()
  focusWindowLeft: -> @proxy.focusWindowLeft()
  focusWindowRight: -> @proxy.focusWindowRight()
  focusWindowUp: -> @proxy.focusWindowUp()
  focusWindowDown: -> @proxy.focusWindowDown()
  getGrid: ->
    winFrame = @frame()
    screenRect = @screen().frameWithoutDockOrMenu()
    thirdScrenWidth = screenRect.size.width / Window.gridWidth
    halfScreenHeight = screenRect.size.height / 2.0
    {
      x: Math.round((winFrame.origin.x - NSMinX(screenRect)) / thirdScrenWidth),
      y: Math.round((winFrame.origin.y - NSMinY(screenRect)) / halfScreenHeight),
      w: Math.max(Math.round(winFrame.size.width / thirdScrenWidth), 1),
      h: Math.max(Math.round(winFrame.size.height / halfScreenHeight), 1)
    }
  setGrid: (grid, screen) ->
    screen ?= @screen()
    screenRect = screen.frameWithoutDockOrMenu()
    thirdScrenWidth = screenRect.size.width / Window.gridWidth
    halfScreenHeight = screenRect.size.height / 2.0
    newFrame = CGRectMake((grid.x * thirdScrenWidth) + NSMinX(screenRect),
                          (grid.y * halfScreenHeight) + NSMinY(screenRect),
                          grid.w * thirdScrenWidth,
                          grid.h * halfScreenHeight)
    newFrame = NSInsetRect(newFrame, Window.gridMarginX, Window.gridMarginY)
    newFrame = NSIntegralRect(newFrame)
    @setFrame newFrame

Window.gridWidth ?= 3
Window.gridMarginX ?= 5
Window.gridMarginY ?= 5

api =
  settings: -> SDAPI.settings()
  runningApps: -> mapToJS SDAppProxy.runningApps(), App.fromNS
  allWindows: -> mapToJS SDWindowProxy.allWindows(), Window.fromNS
  visibleWindows: -> mapToJS SDWindowProxy.visibleWindows(), Window.fromNS
  focusedWindow: -> Window.fromNS SDWindowProxy.focusedWindow()
  mainScreen: -> SDScreenProxy.mainScreen()
  allScreens: -> mapToJS SDScreenProxy.allScreens(), Screen.fromNS
  selectedText: -> objToJS DJRPasteboardProxy.selectedText()
  clipboardContents: ->
    body = NSPasteboard.generalPasteboard().stringForType(NSPasteboardTypeString)
    if body
      body.toString()
    else
      null

shell = (path, args, options) -> SDAPI.shell_args_options_ path, args, options
open = (thing) -> SDAPI.shell_args_options_ "/usr/bin/open", [thing], {}
bind = (key, modifiers, fn) -> SDKeyBinder.sharedKeyBinder().bind_modifiers_fn_ key, modifiers, fn
log = (str) -> SDLogWindowController.sharedLogWindowController().show_type_ str, "SDLogMessageTypeUser"
require = (file) -> SDConfigLoader.sharedConfigLoader().require(file)
alert = (str, delay) -> SDAlertWindowController.sharedAlertWindowController().show_delay_ str, delay
reloadConfig = -> SDConfigLoader.sharedConfigLoader().reloadConfig()
doAfter = (sec, fn) -> SDAPI.doFn_after_ fn, sec

listen = (event, fn) ->
  trampolineFn = (thing) ->
    switch thing.className().toString()
      when 'SDWindowProxy'
        fn Window.fromNS(thing)
      when 'SDAppProxy'
        fn App.fromNS(thing)
  SDEventListener.sharedEventListener().listenForEvent_fn_(event, trampolineFn)
