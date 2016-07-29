
if not fm.gui then error("Hey silly. don't include this directly!") end
fm.gui.actions = {} -- The actual even handlers
fm.gui.radio = {} -- The container for radio elements.

function fm.gui.registerAllHandlers()
    Gui.on_click("FactorioMaps_mainButton", fm.gui.actions.MainButton)
    Gui.on_click("FactorioMaps_advancedButton", fm.gui.actions.advancedButton)
    Gui.on_click("FactorioMaps_maxSize", fm.gui.actions.maxSize)
    Gui.on_click("FactorioMaps_baseSize", fm.gui.actions.baseSize)
    Gui.on_click("FactorioMaps_generate", fm.gui.actions.generate)
    Gui.on_click("FactorioMaps_viewReturn", fm.gui.actions.viewReturn)
    Gui.on_click("FactorioMaps_topLeftView", fm.gui.actions.topLeftView)
    Gui.on_click("FactorioMaps_topLeftPlayer", fm.gui.actions.topLeftPlayer)
    Gui.on_click("FactorioMaps_bottomRightView", fm.gui.actions.bottomRightView)
    Gui.on_click("FactorioMaps_bottomRightPlayer", fm.gui.actions.bottomRightPlayer)

    Gui.on_checked_state_changed("FactorioMaps_dayOnly", fm.gui.actions.dayOnly)
    Gui.on_checked_state_changed("FactorioMaps_altInfo", fm.gui.actions.altInfo)
    Gui.on_checked_state_changed("FactorioMaps_customSize", fm.gui.actions.customSize)
    Gui.on_checked_state_changed("FactorioMaps_radio_mapQuality_", fm.gui.actions.mapQualityRadio)
    Gui.on_checked_state_changed("FactorioMaps_radio_extension_", fm.gui.actions.extensionRadio)

    Gui.on_text_changed("FactorioMaps_folderName", fm.gui.actions.folderName)
    Gui.on_text_changed("FactorioMaps_topLeftX", fm.gui.actions.topLeftX)
    Gui.on_text_changed("FactorioMaps_topLeftY", fm.gui.actions.topLeftY)
    Gui.on_text_changed("FactorioMaps_bottomRightX", fm.gui.actions.bottomRightX)
    Gui.on_text_changed("FactorioMaps_bottomRightY", fm.gui.actions.bottomRightY)
end

function fm.gui.updateCoords()
    for index, player in pairs(game.players) do
        if player.valid and player.connected then
            local rightPane = fm.gui.getRightPane(player.index)
            if (rightPane and rightPane.label_currentPlayerCoords) then
                local x = math.floor(player.position.x)
                local y = math.floor(player.position.y)
                rightPane.label_currentPlayerCoords.caption = {"label-current-player-coords", player.surface.name, x, y}
            end
        end
    end
end


--------------------------------
-- MAIN WINDOW BUTTON
--------------------------------
function fm.gui.actions.MainButton(event)
    if (fm.gui.getMainWindow(event.player_index)) then
        fm.gui.hideMainWindow(event.player_index)
    else
        fm.gui.showMainWindow(event.player_index)
    end
end

--------------------------------
-- RADIO BUTTON SIMULATOR!
--------------------------------
function fm.gui.radio.selector(event)
    local function split(inputstr, seperator)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        local i=1
        for str in string.gmatch(inputstr, "([^" .. seperator .. "]+)") do
                t[i] = str
                i = i + 1
        end
        return t
    end
    local tmp = split(event.element.name, "_")
    local radio = tmp[#tmp-1]
    local number = tonumber(tmp[#tmp])

    for index, element in pairs(global._radios[radio]) do
        if (element.valid) then
            if (index == number) then
                element.state = true
            else
                element.state = false
            end
        else
            global._radios[radio][index] = nil
        end
    end
    return number
end

function fm.gui.radio.mapQualitySelect(thisOne)
    for index, element in pairs(global._radios.mapQuality) do
        if (index == thisOne) then
            fm.gui.radio.selector({element = element})
        end
    end
end

function fm.gui.radio.extensionSelect(thisOne)
    for index, element in pairs(global._radios.extension) do
        if (index == thisOne) then
            fm.gui.radio.selector({element = element})
        end
    end
end

--------------------------------
-- MAIN WINDOW LEFT PANE
--------------------------------
function fm.gui.actions.dayOnly(event)
    fm.cfg.set("dayOnly", event.state)
end

function fm.gui.actions.altInfo(event)
    fm.cfg.set("altInfo", event.state)
end

function fm.gui.actions.advancedButton(event)
    if (fm.gui.getRightPane(event.player_index)) then
        fm.gui.hideRightPane(event.player_index)
    else
        fm.gui.showRightPane(event.player_index)
    end
end

function fm.gui.actions.folderName(event)
    if string.is_empty(event.text) then
        return
    end

    fm.cfg.set("folderName", event.text)
end

function fm.gui.actions.maxSize(event)
    local player = game.players[event.player_index]
    local minX, minY, maxX, maxY = helpers.maxSize(event.player_index)

    if(minX ~= nil and minY ~= nil and maxX ~= nil and maxY ~= nil) then
        fm.cfg.set("topLeftX", minX)
        fm.cfg.set("topLeftY", minY)
        fm.cfg.set("bottomRightX", maxX)
        fm.cfg.set("bottomRightY", maxY)
        local rightPane = fm.gui.getRightPane(player.index)
        if rightPane then
            rightPane.topFlow.FactorioMaps_topLeftX.text = minX
            rightPane.topFlow.FactorioMaps_topLeftY.text = minY
            rightPane.topFlow.FactorioMaps_bottomRightX.text = maxX
            rightPane.topFlow.FactorioMaps_bottomRightY.text = maxY
        end
    else
        player.print("Something went very very wrong...")
    end
end

function fm.gui.actions.baseSize(event)
    local player = game.players[event.player_index]
    local minX, minY, maxX, maxY = helpers.cropToBase(event.player_index)

    if(minX ~= nil and minY ~= nil and maxX ~= nil and maxY ~= nil) then
        fm.cfg.set("topLeftX", minX)
        fm.cfg.set("topLeftY", minY)
        fm.cfg.set("bottomRightX", maxX)
        fm.cfg.set("bottomRightY", maxY)
        local rightPane = fm.gui.getRightPane(player.index)
        if rightPane then
            rightPane.topFlow.FactorioMaps_topLeftX.text = minX
            rightPane.topFlow.FactorioMaps_topLeftY.text = minY
            rightPane.topFlow.FactorioMaps_bottomRightX.text = maxX
            rightPane.topFlow.FactorioMaps_bottomRightY.text = maxY
        end
    else
        player.print("Either you haven't built anything yet, or there is something very wrong )")
    end
end

function fm.gui.actions.generate(event)
    local player = game.players[event.player_index]
    local data = {}

--    fm.generateMap(player, data)
end

--------------------------------
-- MAIN WINDOW RIGHT PANE (ADVANCED SETTINGS)
--------------------------------
function fm.gui.actions.customSize(event)
    fm.cfg.set("customSize", event.state)
end

function fm.gui.actions.topLeftX(event)
    if string.is_empty(event.text) then
        return
    end

    fm.cfg.set("topLeftX", event.text)
end

function fm.gui.actions.topLeftY(event)
    if string.is_empty(event.text) then
        return
    end

    fm.cfg.set("topLeftY", event.text)
end

function fm.gui.actions.bottomRightX(event)
    if string.is_empty(event.text) then
        return
    end

    fm.cfg.set("bottomRightX", event.text)
end

function fm.gui.actions.bottomRightY(event)
    if string.is_empty(event.text) then
        return
    end

    fm.cfg.set("bottomRightY", event.text)
end

function fm.gui.actions.mapQualityRadio(event)
    local num = fm.gui.radio.selector(event)
    fm.cfg.set("mapQuality", num)
end

function fm.gui.actions.extensionRadio(event)
    local num = fm.gui.radio.selector(event)
    fm.cfg.set("extension", num)
end

function fm.gui.actions.viewReturn(event)
    fm.viewer(event, {x=fm.cfg.get("topLeftX"), y=fm.cfg.get("topLeftY")}, true)
end

function fm.gui.actions.topLeftView(event)
    fm.viewer(event, {x=fm.cfg.get("topLeftX"), y=fm.cfg.get("topLeftY")})
end

function fm.gui.actions.topLeftPlayer(event)
    Game.print_all("Using topLeftPlayer clicked")
    local player = game.players[event.player_index]
    local x = math.floor(player.position.x)
    local y = math.floor(player.position.y)
    fm.cfg.set("topLeftX", x)
    fm.cfg.set("topLeftY", y)

    local rightPane = fm.gui.getRightPane(player.index)
    if rightPane then
        rightPane.topFlow.FactorioMaps_topLeftX.text = x
        rightPane.topFlow.FactorioMaps_topLeftY.text = y
    end
end

function fm.gui.actions.bottomRightView(event)
    fm.viewer(event, {x=fm.cfg.get("bottomRightX"), y=fm.cfg.get("bottomRightY")})
end

function fm.gui.actions.bottomRightPlayer(event)
    Game.print_all("Using bottomRightPlayer clicked")
    local player = game.players[event.player_index]
    local x = math.floor(player.position.x)
    local y = math.floor(player.position.y)
    fm.cfg.set("bottomRightX", x)
    fm.cfg.set("bottomRightY", y)

    local rightPane = fm.gui.getRightPane(player.index)
    if rightPane then
        rightPane.topFlow.FactorioMaps_bottomRightX.text = x
        rightPane.topFlow.FactorioMaps_bottomRightY.text = y
    end
end

--Go ahead and register them now. There is no harm in it.
fm.gui.registerAllHandlers()