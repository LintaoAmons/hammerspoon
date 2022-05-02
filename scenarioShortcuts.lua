local hyperKey = {'shift', 'alt', 'ctrl', 'cmd'}

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
        hs.timer.doAfter(0.2, function()
            hs.eventtap.keyStroke({}, key)
        end)
    end)
end

function tmuxSwitchWindow(windowNumber)
  return remap(hyperKey, windowNumber, function()
        hs.eventtap.keyStroke({'ctrl'}, 'b', 1000)
        hs.timer.doAfter(0.2, function()
            hs.eventtap.keyStroke({}, windowNumber)
        end)
    end)
end

function terminalCommand(key, cmd)
    return remap({'cmd', 'ctrl'}, key, function()
        hs.eventtap.keyStrokes(cmd)
        hs.timer.doAfter(0.2, function()
            hs.eventtap.keyStroke({}, 'return', 1000)
        end)
    end)

end

local allScenarios = {
    firefox = "firefox",
    terminal = "terminal",
    joplin = "joplin"
}

local scenarioShortcuts = {
    [allScenarios.firefox] = {
        nextTab = remap({'cmd', 'ctrl'}, 'l', keyStroke({'ctrl'}, 'tab')),
        prevTab = remap({'cmd', 'ctrl'}, 'h', keyStroke({'ctrl', 'shift'}, 'tab'))
    },
    [allScenarios.terminal] = {
        -- tmux
        paneRight = tmuxSwitchPane('l'),
        paneLeft = tmuxSwitchPane('h'),
        paneUp = tmuxSwitchPane('k'),
        paneDown = tmuxSwitchPane('j'),
        switchToWindow1 = tmuxSwitchWindow("1"),
        switchToWindow2 = tmuxSwitchWindow("2"),
        switchToWindow3 = tmuxSwitchWindow("3"),
        switchToWindow4 = tmuxSwitchWindow("4"),

        -- tui
        lazygit = terminalCommand('u', 'lazygit'),
        termscp = terminalCommand('i', 'termscp'),
        lfcd = terminalCommand('o', 'lfcd'),
        k9s = terminalCommand('9', 'k9s')
    },
    [allScenarios.joplin] = {}
}

local function enableScenarioShortcuts(scenario)
    for _, value in pairs(scenarioShortcuts[scenario]) do
        value:enable()
    end
end

local function disableScenarioShortcuts(scenario)
    for _, value in pairs(scenarioShortcuts[scenario]) do
        value:disable()
    end
end

local function isInTable(table, value)
    for k, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

local function enableScenarios(scenarios)
    scenarios = scenarios or {}
    for _, value in pairs(allScenarios) do
        if isInTable(scenarios, value) then
            enableScenarioShortcuts(value)
        else
            disableScenarioShortcuts(value)
        end
    end
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
            enableScenarios({allScenarios.terminal})
        end
        if (appName == "IntelliJ IDEA") then
            showFocusAlert("IDEA")
            enableScenarios()
        end
        if (appName == "Firefox") then
            showFocusAlert("FIREFOX")
            enableScenarios({allScenarios.firefox})
        end
        if (appName == "Joplin") then
            showFocusAlert("JOPLIN")
            enableScenarios({allScenarios.joplin})
        end
    end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()
