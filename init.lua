-- 
require('windows')

hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()
hs.alert.show("Hammerspoon config reloaded")

-- hs.hotkey.bind(hyperKey, 'a', winwin:moveAndResize("halfleft"))
-- half of screen
-- {frame.x, frame.y, window.w, window.h}
-- First two elements: we decide the position of frame
-- Last two elements: we decide the size of frame

function showFocusAlert(content) 
    hs.alert.show(content, hs.alert.defaultStyle, hs.screen.mainScreen(), 0.5)
end

local function pressFn(mods, key)
	if key == nil then
		key = mods
		mods = {}
	end

	return function() hs.eventtap.keyStroke(mods, key, 1000) end
end

local function remap(mods, key, pressFn)
	return hs.hotkey.bind(mods, key, pressFn, nil, pressFn)
end

local scenarioShortcuts = {
  nextTab = nil,
  prevTab = nil
}

function applicationWatcher(appName, eventType, appObject)
  -- local function clear()
  --   for key, value in pairs(scenarioShortcuts) do
  --     if 
  --   end
  -- end

    if (eventType == hs.application.watcher.activated) then
        -- 初始化senarioShortcuts
        if (appName == "Finder") then
            -- Bring all Finder windows forward when one gets activated
            appObject:selectMenuItem({"Window", "Bring All to Front"})
        end
        if (appName == "iTerm2") then
          showFocusAlert("TERMINAL")
        end
        if (appName == "IntelliJ IDEA") then
          showFocusAlert("IDEA")
        end
        if (appName == "Firefox") then
          showFocusAlert("FIREFOX")
           scenarioShortcuts.nextTab = remap({'cmd', 'ctrl'}, 'l', pressFn({'ctrl'}, 'tab'))
           scenarioShortcuts.prevTab = remap({'cmd', 'ctrl'}, 'h', pressFn({'ctrl', 'shift'}, 'tab'))
        end
        if (appName == "Joplin") then
          showFocusAlert("JOPLIN")
        end
    end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

