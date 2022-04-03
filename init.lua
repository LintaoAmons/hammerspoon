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

function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        if (appName == "Finder") then
            -- Bring all Finder windows forward when one gets activated
            appObject:selectMenuItem({"Window", "Bring All to Front"})
        end
    end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()
