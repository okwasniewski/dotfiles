-- RecursiveBinder is a spoon that allows you to bind keys recursively.

local currentBrowser = "Arc"
local currentTerminal = "Ghostty"

hs.loadSpoon("RecursiveBinder")

spoon.RecursiveBinder.escapeKey = { {}, "escape" } -- Press escape to abort

local singleKey = spoon.RecursiveBinder.singleKey

local keyMap = {
  [singleKey("b", "browser")] = function()
    hs.application.launchOrFocus(currentBrowser)
  end,
  [singleKey("t", "terminal")] = function()
    hs.application.launchOrFocus(currentTerminal)
  end,
  [singleKey("o", "obsidian")] = function()
    hs.application.launchOrFocus("Obsidian")
  end,
  [singleKey("c", "calendar")] = function()
    hs.application.launchOrFocus("Calendar")
  end,
  [singleKey("s", "slack")] = function()
    hs.application.launchOrFocus("Slack")
  end,
  [singleKey("d", "discord")] = function()
    hs.application.launchOrFocus("Discord")
  end,
  [singleKey("m", "spotify")] = function()
    hs.application.launchOrFocus("Spotify")
  end,
  [singleKey("r", "reload")] = function()
    hs.reload()
  end,
  [singleKey("w", "window+")] = {
    [singleKey("m", "minimize")] = function()
      hs.window.focusedWindow():minimize()
    end,
    [singleKey("return", "maximize")] = function()
      hs.window.focusedWindow():maximize(0)
    end,
    [singleKey("h", "left")] = function()
      hs.window.focusedWindow():moveToUnit(hs.layout.left50)
    end,
    [singleKey("l", "right")] = function()
      hs.window.focusedWindow():moveToUnit(hs.layout.right50)
    end,
    [singleKey("q", "quit")] = function()
      hs.window.focusedWindow():close()
    end,
  },
}

hs.hotkey.bind({ "control", "shift" }, "s", spoon.RecursiveBinder.recursiveBind(keyMap))
