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

-- TODO 变成接受两个变量（from, to），变量的类型是 {keycode，mods}
function tmuxCmdCtrlToPrefix(fromKey, mods, toKey)
  if mods == nil then
    mods = {}
  end

  if toKey == nil then
    toKey = fromKey
  end

  return remap({'cmd', 'ctrl'}, fromKey, function()
      hs.eventtap.keyStroke({'ctrl'}, 'b', 1000)
      hs.timer.doAfter(0.2, function()
          hs.eventtap.keyStroke(mods, toKey)
      end)
  end)
end

function tmuxHyperToPrefix(key)
  return remap(hyperKey, key, function()
        hs.eventtap.keyStroke({'ctrl'}, 'b', 1000)
        hs.timer.doAfter(0.2, function()
            hs.eventtap.keyStroke({}, key)
        end)
    end)
end

function tmuxSwitchWindow(windowNumber)
  return tmuxHyperToPrefix(windowNumber)
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
        -- tmux::session
        previousSession = tmuxCmdCtrlToPrefix('[', {'shift'}, '9'),
        nextSession = tmuxCmdCtrlToPrefix(']', {'shift'}, '0'),
        renameSession = tmuxCmdCtrlToPrefix('m', {'shift'}, '4'),
        -- tmux::pane
        paneRight = tmuxCmdCtrlToPrefix('l'),
        paneLeft = tmuxCmdCtrlToPrefix('h'),
        paneUp = tmuxCmdCtrlToPrefix('k'),
        paneDown = tmuxCmdCtrlToPrefix('j'),
        switchToNextPane=tmuxCmdCtrlToPrefix('o'),

        switchToWindow1 = tmuxHyperToPrefix("1"),
        switchToWindow2 = tmuxHyperToPrefix("2"),
        switchToWindow3 = tmuxHyperToPrefix("3"),
        switchToWindow4 = tmuxHyperToPrefix("4"),
        closePane = tmuxHyperToPrefix("x"),
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
