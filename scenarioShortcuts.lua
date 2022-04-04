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
  firefox = {
    nextTab = remap({'cmd', 'ctrl'}, 'l', pressFn({'ctrl'}, 'tab')),
    prevTab = remap({'cmd', 'ctrl'}, 'h', pressFn({'ctrl', 'shift'}, 'tab'))
  },
  test = {
    testMap = remap({'cmd', 'ctrl'}, 'l', pressFn({'ctrl'}, 'l'))
  }
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
            enableScenarioShortcuts('test')
            disableScenarioShortcuts('firefox')
        end
        if (appName == "IntelliJ IDEA") then
            showFocusAlert("IDEA")
        end
        if (appName == "Firefox") then
            showFocusAlert("FIREFOX")
            enableScenarioShortcuts('firefox')
            disableScenarioShortcuts('test')
        end
        if (appName == "Joplin") then
            showFocusAlert("JOPLIN")
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

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
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
