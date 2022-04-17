function showFocusAlert(content)
    hs.alert.show(content, hs.alert.defaultStyle, hs.screen.mainScreen(), 0.5)
end

local function keyStroke(mods, key)
    if key == nil then
        key = mods
        mods = {}
    end

    return function()
        hs.eventtap.keyStroke(mods, key, 1000)
    end
end

local function remap(mods, key, pressFn)
    return hs.hotkey.bind(mods, key, pressFn, nil, pressFn)
end

function tmuxSwitchPane(key)
    return remap({'cmd', 'ctrl'}, key, function()
        hs.eventtap.keyStroke({'ctrl'}, 'b', 1000)
        hs.timer.doAfter(0.1, function() 
          hs.eventtap.keyStroke({}, key)
        end)
    end)
end

function terminalCommand(key, cmd)
    return remap({'cmd', 'ctrl'}, key, function()
        hs.eventtap.keyStrokes(cmd)
        hs.timer.doAfter(0.1, function()
            hs.eventtap.keyStroke({}, 'return', 1000)
        end)
    end)

end

-- lazygit demo

local scenarioShortcuts = {
    firefox = {
        nextTab = remap({'cmd', 'ctrl'}, 'l', keyStroke({'ctrl'}, 'tab')),
        prevTab = remap({'cmd', 'ctrl'}, 'h', keyStroke({'ctrl', 'shift'}, 'tab'))
    },
    tmux = {
        paneRight = tmuxSwitchPane('l'),
        paneLeft = tmuxSwitchPane('h'),
        paneUp = tmuxSwitchPane('k'),
        paneDown = tmuxSwitchPane('j')
    },
    terminal = {
        lazygit = terminalCommand('u', 'lazygit'),
        termscp = terminalCommand('i', 'termscp'),
        lfcd = terminalCommand('o', 'lfcd'),
        k9s = terminalCommand('9', 'k9s')
    }
}

-- TODO enable a list and disable others

local function enableScenarioShortcuts(scenario)
    for _, value in pairs(scenarioShortcuts[scenario]) do
        value:enable()
    end
end

local function disableScenarioShortcuts(scenario)
    for _, value in pairs(scenarioShortcuts[scenario]) do
        value:disable()
    end
    print(serializeTable(scenarioShortcuts))
end

function applicationWatcher(appName, eventType, appObject)

    if (eventType == hs.application.watcher.activated) then
        -- 初始化senarioShortcuts
        if (appName == "Finder") then
            -- Bring all Finder windows forward when one gets activated
            appObject:selectMenuItem({"Window", "Bring All to Front"})
        end
        if (appName == "iTerm2") then
            showFocusAlert("TERMINAL")
            enableScenarioShortcuts('tmux')
            enableScenarioShortcuts('terminal')
            disableScenarioShortcuts('firefox')
        end
        if (appName == "IntelliJ IDEA") then
            showFocusAlert("IDEA")
            disableScenarioShortcuts('tmux')
            disableScenarioShortcuts('terminal')
            disableScenarioShortcuts('firefox')
        end
        if (appName == "Firefox") then
            showFocusAlert("FIREFOX")
            enableScenarioShortcuts('firefox')
            disableScenarioShortcuts('tmux')
            disableScenarioShortcuts('terminal')
        end
        if (appName == "Joplin") then
            showFocusAlert("JOPLIN")
            enableScenarioShortcuts('joplin')
            disableScenarioShortcuts('tmux')
            disableScenarioShortcuts('terminal')
        end
    end
    print('current' .. serializeTable(scenarioShortcuts))

end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then
        tmp = tmp .. name .. " = "
    end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp = tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end
