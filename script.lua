local allPossibleTableTopColors = { "White", "Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Pink", "Grey",
    "Black" }
local colors = { "Red", "White", "Orange", "Pink", "Yellow", "Purple", "Green", "Blue" }
local myCombatDeck = 1
local resourceDeck = 1
local dice = 1

local deckRotation = { 0, 45 - 90, 0 }
local combatDiscard = nil
local resourceDiscard = nil
local combatDiscardPosition = { 11, 5, 17 }
local resourceDiscardPostion = { -17, 5, -11 }
local combatCardNames = { 'Kill 2 vikings', 'Switch to scissors', 'The Golden Card!', 'Switch to rock',
    'Switch to paper', 'dummy' }
local combatCardNumbers = {}
local resourceCardNames = { 'Steal a combatCard', 'Fleinsopp', 'Heavy rain', 'Steal a Viking', 'Gjallarhorn',
    'Natural disaster', 'Super Shoe' }
local resourceCardNumbers = {}

local mapAmounts = { 5, 7, 9, 11, 11, 11, 11, 11, 9, 7, 5 }
local tileTypeSpawnAmounts = { 0, 0, 0, 0, 0 }
local numberSpawned = 0

local isRagnarokOn = false
local ragnarokTurn = 0
local ragnarokTurnNum = 0
local everyNturnShrink = 3
local RagnarokDefStartTurn = 5
local turnNum = 0

local gameStarted = false
local heavyRainColor = nil
local heavyRainTurn = 0
local heavyRainPlayedBeforeMovement = nil
local stealACardAction = false
local stealACardPlayerColor = nil
local playersInCombat = false
local playerColorsPicked = { '0', '0', '0', '0', '0', '0', '0', '0', '0', '0' }
local playerColorsInCombat = {}


--variables below can't be local cuz i'm using global.getVar to access them
fleinSoppOn = false
heavyRainOn = false
superShoeOn = false

function onMyColorPickerUpdate(player, option, id)
    for index = 1, 8, 1 do
        if player.color == allPossibleTableTopColors[index] then
            playerColorsPicked[index] = option
            print(player.color .. 'picked ' .. playerColorsPicked[index])
        end
    end
end

function onRockPaperScissorCommit(player, value)
    --print(value)
    if value == 'Rock' then

    elseif value == 'Paper' then

    elseif value == 'Scissor' then

    end
end

function onCombatStart(params)
    playerColorsInCombat = params
    local player1Color = params[1]
    local player2Color = params[2]
    if player1Color ~= nil and player2Color ~= nil then
        if playersInCombat == false then
            printToAll('Battle Begun')
            local valueToSend = '"' .. player1Color .. "|" .. player2Color .. '"'
            print(valueToSend)
            UI.setAttribute("rockPaperScissorUI", "visibility", valueToSend)
            UI.show("rockPaperScissorUI")
        end
        playersInCombat = true
    end
end

function noCombat()
    UI.setAttribute("rockPaperScissorUI", "visibility", "Black")
    --print('no combat')
    playersInCombat = false
end

function onObjectPickUp(player_color, object)
    if stealACardAction == true and stealACardPlayerColor ~= nil then
        if player_color == stealACardPlayerColor then
            if object.hasTag('combatCard') == true or object.hasTag('lastCombatCardPlayed') == true then
                if object.getVar('iAm') ~= nil then
                    object.removeTag('lastCombatCardPlayed')
                    stealACardAction = false
                    stealACardPlayerColor = nil
                    printToColor('You stole ' .. combatCardNames[object.getVar('iAm') + 1], player_color)
                    printToAll(combatCardNames[object.getVar('iAm') + 1] .. ' is no longer in play')
                end
            end
        end
    end
    if object.hasTag('combatCard') == true then
        for i = 0, #combatCardNames, 1 do
            if object.hasTag('cc' .. i) == true then
                object.setVar('iAm', i)
                object.removeTag('cc' .. i)
            end
        end
    elseif object.hasTag('resourceCard') == true then
        for i = 0, #resourceCardNames, 1 do
            if object.hasTag('rc' .. i) == true then
                object.setVar('iAm', i)
                object.removeTag('rc' .. i)
            end
        end
    end
end

function combatCardFunc(thisTable)
    obj = thisTable[1]
    thisColor = thisTable[2]
    if obj.hasTag('lastCombatCardPlayed') == false then
        printToAll(thisColor .. " played " .. combatCardNames[obj.getVar('iAm') + 1])
    end

    if #getObjectsWithTag('lastCombatCardPlayed') == 0 then
        obj.addTag('lastCombatCardPlayed')
    else
        for _, object in ipairs(getObjectsWithTag('lastCombatCardPlayed')) do
            if object ~= obj then
                object.removeTag('lastCombatCardPlayed')
                object.setLock(true)
            end
        end
        obj.addTag('lastCombatCardPlayed')
    end
end

function subtractAViking(object, player_color)
    local vikings = object.getVar('myNumberOfVikings')
    local position = object.getPosition()
    local index = object.getVar('myIndex')
    local color = object.getVar('playerColor')
    object.destruct()
    spawnInAPlayer(position.x, position.y, position.z, color, index, vikings - 1)
end

function addAViking(object, player_color)
    local vikings = object.getVar('myNumberOfVikings')
    local position = object.getPosition()
    local index = object.getVar('myIndex')
    local color = object.getVar('playerColor')
    object.destruct()
    spawnInAPlayer(position.x, position.y, position.z, color, index, vikings + 1)
end

function resourceCardFunc(thisTable)
    obj = thisTable[1]
    thisColor = thisTable[2]

    if obj.hasTag('lastResourceCardPlayed') == false then
        printToAll(thisColor .. " played " .. resourceCardNames[obj.getVar('iAm') + 1])
        if obj.getVar('iAm') == 0 then --done
            stealACardAction = true
            stealACardPlayerColor = thisColor
            for _, card in ipairs(getObjectsWithTag('lastCombatCardPlayed')) do
                card.setLock(false)
            end
            printToColor("Take a card from a players hand or take", thisColor)
            printToColor("the combat card thats just been played (is in the discard pile)", thisColor)
        elseif obj.getVar('iAm') == 1 then --done
            fleinSoppOn = true
        elseif obj.getVar('iAm') == 2 then --not really done
            heavyRainOn = true
            heavyRainColor = Turns.turn_color
            heavyRainTurn = turnNum
            thisPlayerPawn = getPlayerPawn(Turns.turn_color)
            if thisPlayerPawn.getVar('myCurrentTile') == thisPlayerPawn.getVar('myTileThisTurn') or thisPlayerPawn.getVar('firstTurn') == true then
                heavyRainPlayedBeforeMovement = true
            else
                heavyRainPlayedBeforeMovement = false
            end
        elseif obj.getVar('iAm') == 3 then --done
            printToColor("PSSST! over here!, those buttons next to the player pieces", thisColor)
            printToColor("they don't have any restrictions, +1 to yourself, -1 to somebody else", thisColor)
        elseif obj.getVar('iAm') == 4 then --done
            StartRagnarok2()
        elseif obj.getVar('iAm') == 5 then --kinda done
            printToColor('would you be so kind as to press -- on the relevant player pieces, thx buddy you da best',
                thisColor)
        elseif obj.getVar('iAm') == 6 then --done
            superShoeOn = true
        end
    end
    if #getObjectsWithTag('lastResourceCardPlayed') == 0 then
        obj.addTag('lastResourceCardPlayed')
    else
        for _, object in ipairs(getObjectsWithTag('lastResourceCardPlayed')) do
            if object ~= obj then
                object.removeTag('lastResourceCardPlayed')
                object.setLock(true)
            end
        end
        obj.addTag('lastResourceCardPlayed')
    end
end

function onObjectDrop(player_color, object)
    if object.hasTag('playThisCombatCard') == true then
        object.setLuaScript([[
            isDone = false
            function onCollisionEnter(info)
                colObj = info.collision_object
                if colObj.hasTag('gameObject') == false then
                    isDone = true
                    self.setRotation(]] .. tableToString(deckRotation) .. [[)

                    self.setPosition(]] .. tableToString(combatDiscardPosition) .. [[)

                    self.setLock(true)
                    params = {
                        self,
                        ]] .. "'" .. player_color .. "'" .. [[
                    }
                    Global.call("combatCardFunc", params)
                end
            end
        ]])
        object.addTag('removeThisScript')
    elseif object.hasTag('playThisResourceCard') == true then
        object.setLuaScript([[
            isDone = false
            function onCollisionEnter(info)
                colObj = info.collision_object
                if colObj.hasTag('gameObject') == false then
                    isDone = true
                    self.setRotation(]] .. tableToString(deckRotation) .. [[)

                    self.setPosition(]] .. tableToString(resourceDiscardPostion) .. [[)

                    self.setLock(true)
                    params = {
                        self,
                        ]] .. "'" .. player_color .. "'" .. [[
                    }
                    Global.call("resourceCardFunc", params)
                end
            end
        ]])
        object.addTag('removeThisScript')
    end
end

function onPlayerAction(player, action, targets)
    if Turns.turn_color ~= player.color then
        for _, target in ipairs(targets) do
            if target.hasTag('diec') == true then
                printToColor('It is ' .. Turns.turn_color .. "'s turn", player.color)
                return false
            end
        end
    end
    if targets[1].hasTag('playerPawn') then
        if player.color ~= targets[1].getVar('playerColor') then
            printToColor('This Chieftan belongs to ' .. targets[1].getVar('playerColor'), player.color)
            return false
        end
    end
end

function onObjectEnterZone(zone, object)
    if zone == combatDiscard and object.hasTag('combatCard') == true then
        object.addTag('playThisCombatCard')
    end
    if zone == resourceDiscard and object.hasTag('resourceCard') == true then
        object.addTag('playThisResourceCard')
    end
end

function onObjectLeaveZone(zone, object)
    if object.hasTag('playThisCombatCard') == true or object.hasTag('playThisResourceCard') == true then
        object.removeTag('playThisCombatCard')
        object.removeTag('playThisResourceCard')
    end
end

function forfeitTile(player)
    for _, playerPawn in ipairs(getObjectsWithTag('playerPawn')) do
        if playerPawn.getVar('playerColor') ~= nil then
            if playerPawn.getVar('playerColor') == player.color then
                playerPawn.setVar('myCurrentTile', nil)
            end
        end
    end
end

function StartRagnarok()
    if isRagnarokOn == false then
        printToAll('starting Ragnarok!')
        isRagnarokOn = true
    end
end

function StartRagnarok2()
    if isRagnarokOn == false then
        printToAll('starting Ragnarok!')
        isRagnarokOn = true
        for _, player in ipairs(getObjectsWithTag('playerPawn')) do
            local vikings = math.ceil(player.getVar('myNumberOfVikings') / 2)
            local position = player.getPosition()
            local color = player.getVar('playerColor')
            local index = player.getVar('myIndex')
            player.destruct()
            spawnInAPlayer(position.x, position.y, position.z, color, index, vikings)
        end
    end
end

function setPlayerImage(player, color, vikings)
    local v = vikings - 3
    local params = {
        image = 'https://screenshots.wildwolf.dev/Gjallarhorn/players/'
    }
    if v >= 9 then
        params.image = params.image .. 'boat/'
    elseif v >= 6 then
        params.image = params.image .. 'goat/'
    elseif v >= 3 then
        params.image = params.image .. 'war/'
    else
        params.image = params.image .. 'norm/'
    end
    params.image = params.image .. string.lower(color) .. '.png'
    player.setCustomObject(params)
end

function ragnarokFunc(i)
    for _, object in ipairs(getObjectsWithTag('ragnarok' .. i)) do
        destroyObject(object)
    end
end

-- https://stackoverflow.com/questions/5977654/how-do-i-use-the-bitwise-operator-xor-in-lua

local function BitXOR(a, b) --Bitwise xor
    local p, c = 1, 0
    while a > 0 and b > 0 do
        local ra, rb = a % 2, b % 2
        if ra ~= rb then c = c + p end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end
    if a < b then a = b end
    while a > 0 do
        local ra = a % 2
        if ra > 0 then c = c + p end
        a, p = (a - ra) / 2, p * 2
    end
    return c
end

local function BitOR(a, b) --Bitwise or
    local p, c = 1, 0
    while a + b > 0 do
        local ra, rb = a % 2, b % 2
        if ra + rb > 0 then c = c + p end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end
    return c
end

local function BitNOT(n) --Bitwise not
    local p, c = 1, 0
    while n > 0 do
        local r = n % 2
        if r < 1 then c = c + p end
        n, p = (n - r) / 2, p * 2
    end
    return c
end

local function BitAND(a, b) --Bitwise and
    local p, c = 1, 0
    while a > 0 and b > 0 do
        local ra, rb = a % 2, b % 2
        if ra + rb > 1 then c = c + p end
        a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
    end
    return c
end

--based of https://gist.github.com/Uradamus/10323382

function randomizeMap(times)
    for l = 0, times, 1 do
        local localMap = getObjectsWithTag('tile')
        for i = #localMap, 2, -1 do
            local j = math.random(i)
            local obj1 = localMap[i]
            local obj2 = localMap[j]
            if obj1.getVar("spawn") ~= true and obj2.getVar("spawn") ~= true then
                obj1.setPosition(obj2.getPosition())
                obj2.setPosition(obj1.getPosition())
            end
        end
    end
end

function spawnGame()
    destroyAllObjects()
    gameStarted = true
    --spawning in the map
    for i = 1, 11, 1 do
        spawnPoints = false
        if i == 1 or i == 4 or i == 8 or i == 11 then
            spawnPoints = true
        end
        mapHelperFunction(1 - mapAmounts[i] / 2, 0 + mapAmounts[i] / 2, i - 5.5, spawnPoints, i)
    end
    --have to remove the line about locking tiles in their spawn function if you want this part to work btw
    -- randomizeTileZone = spawnObject({
    --     type = 'randomizeTrigger',
    --     scale = {30, 10, 30}
    -- })
    -- --randomizeTileZone.addTag('gameObject')
    -- randomizeTileZone.addTag('notSpawnTile')
    -- randomizeTileZone.randomize()
    -- for _, tile in ipairs(getObjectsWithTag('tile')) do
    --     tile.setLock(true)
    -- end


    dice = spawnObject({
        type = 'Die_6',
        position = { 0, 10, 2 },
    })
    dice.addTag('myDice')
    dice.addTag('gameObject')
    dice.setLuaScript([[
        heavyRainNum = nil
        newNum = false
        timesDiceThrownThisTurn = 0

        function helperFunc(num)
            if heavyRainNum ~= nil then
                if heavyRainNum > num then
                    heavyRainNum = num
                end
            else
                heavyRainNum = num
            end
        end

        function onCollisionEnter(info)
            if info.collision_object.hasTag('tile') then
                newNum = true
            end
            if Global.GetVar('heavyRainOn') == true then
                Wait.condition(
                function() -- Executed after our condition is met
                    if self.isDestroyed() then
                        printToAll("Die was destroyed before it came to rest.")
                    elseif newNum == true then
                        timesDiceThrownThisTurn = timesDiceThrownThisTurn + 1
                        if timesDiceThrownThisTurn % 2 == 0 then
                            if heavyRainNum > self.getRotationValue() then
                                heavyRainNum = self.getRotationValue()
                            end
                        else
                            heavyRainNum = self.getRotationValue()
                        end
                        newNum = false
                    end
                end,
                function() -- Condition function
                    return self.isDestroyed() or self.resting
                end,
                10
                )
            end
        end


    ]])

    -- randomizeMap(4)

    --spawning in player pawns
    local spawnPlayerIndex = 1
    for _, player in ipairs(Player.getPlayers()) do
        spawnInAPlayer(
            player.getHandTransform().position.x,
            player.getHandTransform().position.y,
            player.getHandTransform().position.z,
            player.color,
            spawnPlayerIndex,
            3
        )
        spawnPlayerIndex = spawnPlayerIndex + 1
    end
    --spawn decks
    deckScale = { 1.75, 1.75, 1.75 }
    myCombatDeck = spawnObject({
        type = 'Deck',
        position = { 16, 5, 12 },
        scale = deckScale
    })
    combatDeckParams = {
        face = 'https://screenshots.wildwolf.dev/Gjallarhorn/card/combat.png',
        back = 'https://screenshots.wildwolf.dev/Gjallarhorn/card/cback.png',
        width = 3,
        height = 3,
        number = 6,
        back_is_hidden = true,
    }
    myCombatDeck.use_hands = true
    myCombatDeck.hide_when_face_down = true
    myCombatDeck.use_snap_points = false
    myCombatDeck.setCustomObject(combatDeckParams)
    myCombatDeck.setRotation(deckRotation)
    myCombatDeck.setName('Combat Cards')
    myCombatDeck.addTag('gameObject')

    for _, obj in ipairs(myCombatDeck.getObjects()) do
        local combatCard = myCombatDeck.takeObject({
            GUID = obj.guid
        })
        combatCard.addTag('combatCard')
        combatCard.addTag('gameObject')
        combatCard.addTag('cc' .. obj.index)
        myCombatDeck.putObject(combatCard)
    end
    myCombatDeck.flip()
    combatDiscard = spawnObject({
        type = 'ScriptingTrigger',
        position = combatDiscardPosition,
        scale = { 5, 5, 8 }
    })
    combatDiscard.setRotation(deckRotation)
    combatDiscard.addTag('gameObject')
    combatDiscard.addTag('combatCard')

    resourceDeck = spawnObject({
        type = 'DeckCustom',
        position = { -12, 5, -16 },
        scale = deckScale
    })
    resourceDeckParams = {
        face = 'https://screenshots.wildwolf.dev/Gjallarhorn/card/resource.png',
        back = 'https://screenshots.wildwolf.dev/Gjallarhorn/card/rback.png',
        width = 3,
        height = 3,
        number = 7,
        back_is_hidden = true,
    }
    resourceDeck.use_hands = true
    resourceDeck.hide_when_face_down = true
    resourceDeck.use_snap_points = false
    resourceDeck.setCustomObject(resourceDeckParams)
    resourceDeck.setRotation(deckRotation)
    resourceDeck.setName('Resource Cards')
    resourceDeck.addTag('gameObject')

    for _, obj in ipairs(resourceDeck.getObjects()) do
        local resourceCard = resourceDeck.takeObject({
            GUID = obj.guid
        })
        resourceCard.addTag('resourceCard')
        resourceCard.addTag('gameObject')
        resourceCard.addTag('rc' .. obj.index)
        resourceDeck.putObject(resourceCard)
    end
    resourceDeck.flip()

    resourceDiscard = spawnObject({
        type = 'ScriptingTrigger',
        position = resourceDiscardPostion,
        scale = { 5, 5, 8 }
    })
    resourceDiscard.setRotation(deckRotation)
    resourceDiscard.addTag('gameObject')
    resourceDiscard.addTag('resourceCard')
end

function destroyAllObjects()
    for _, object in ipairs(getObjectsWithTag('gameObject')) do
        destroyObject(object)
    end
    tileTypeSpawnAmounts = { 0, 0, 0, 0, 0 }
    numberSpawned = 0
    for _, player in ipairs(Player.getPlayers()) do
        for _, obj in ipairs(player.getHandObjects(1)) do
            if obj.isDestroyed() == false then
                obj.destruct()
            end
        end
    end
    if randomizeTileZone ~= nil then
        destroyObject(randomizeTileZone)
    end
end

function mapHelperFunction(startIndex, endIndex, yPos, playerSpawn, index)
    for xPos = startIndex, endIndex, 1 do
        local x = xPos * Grid.sizeX - Grid.sizeX / 2
        local y = yPos * Grid.sizeY - Grid.sizeY / 2
        if playerSpawn == true then
            if xPos == startIndex or xPos == endIndex then
                type = 'playerSpawnTile'
            else
                type = randomType()
            end
        else
            type = randomType()
        end
        tileHeight = 5.35
        if xPos == startIndex or xPos == endIndex or index == 12 - 1 or index == 1 then
            spawnATile(x, tileHeight, y, type, xPos + 4.5, index, 'ragnarok' .. 1)
        elseif xPos + 1 == startIndex or xPos - 1 == startIndex or xPos + 1 == endIndex or xPos - 1 == endIndex or index == 11 - 1 or index == 1 + 1 then
            spawnATile(x, tileHeight, y, type, xPos + 4.5, index, 'ragnarok' .. 2)
        elseif xPos + 2 == startIndex or xPos - 2 == startIndex or xPos + 2 == endIndex or xPos - 2 == endIndex or index == 11 - 2 or index == 1 + 2 then
            spawnATile(x, tileHeight, y, type, xPos + 4.5, index, 'ragnarok' .. 3)
        elseif xPos + 3 == startIndex or xPos - 3 == startIndex or xPos + 3 == endIndex or xPos - 3 == endIndex or index == 11 - 3 or index == 1 + 3 then
            spawnATile(x, tileHeight, y, type, xPos + 4.5, index, 'ragnarok' .. 4)
        else
            spawnATile(x, tileHeight, y, type, xPos + 4.5, index, '')
        end
    end
end

function randomType()
    local returnVar = ''
    local rand = (BitXOR((math.random(89) * math.random(89)), (math.random(89) * math.random(89))) * BitNOT(BitXOR((math.random(89) * math.random(89)), (math.random(89) * math.random(89))))) %
        89
    while (returnVar == '')
    do
        if tileTypeSpawnAmounts[1] < 44 and (rand + tileTypeSpawnAmounts[1] < 44 or rand < 44) then
            returnVar = 'plains'
        elseif tileTypeSpawnAmounts[3] < 11 and (rand + tileTypeSpawnAmounts[3] < 11 or rand + tileTypeSpawnAmounts[1] > 43 and rand < 44 + 11) then
            returnVar = 'forest'
        elseif tileTypeSpawnAmounts[2] < 22 and (rand + tileTypeSpawnAmounts[2] < 22 or rand + tileTypeSpawnAmounts[1] + tileTypeSpawnAmounts[3] > 43 + 11 and rand < 44 + 22 + 11) then
            returnVar = 'mountain'
        elseif tileTypeSpawnAmounts[4] < 12 and (rand + tileTypeSpawnAmounts[4] < 12 or rand + tileTypeSpawnAmounts[1] + tileTypeSpawnAmounts[2] + tileTypeSpawnAmounts[3] > 43 + 22 + 11) then
            returnVar = 'swamp'
        end
        if tileTypeSpawnAmounts[1] == 44 then
            rand = rand - 44
        end
        if tileTypeSpawnAmounts[2] == 22 then
            rand = rand - 22
        end
        if tileTypeSpawnAmounts[3] == 11 then
            rand = rand - 11
        end
        if tileTypeSpawnAmounts[4] == 12 then
            rand = rand - 12
        end
    end
    numberSpawned = numberSpawned + 1
    return returnVar
end

function spawnInAPlayer(x, y, z, color, index, vikings)
    local player = spawnObject({
        type = 'Figurine_Custom',
        position = { x, y, z },
    })
    setPlayerImage(player, color, vikings)

    player.setLuaScript([[
myNumberOfVikings = ]] .. vikings .. [[

addThisTurn = 0
giveCombatCard = false
giveResourceCard = false
myCurrentTile = 0
myTileThisTurn = 0
isInCombat = false
firstTurn = true
myIndex = ]] .. index .. [[

function onCollisionEnter(info)
    if info.collision_object.getVar('tileNumberOfVikings') then
        Global.call('noCombat')
        addThisTurn = info.collision_object.getVar('tileNumberOfVikings')
        giveCombatCard = info.collision_object.getVar('giveCombatCard')
        giveResourceCard = info.collision_object.getVar('giveResourceCard')
        if myCurrentTile ~= 0 and myCurrentTile.hasTag('shouldFlipThisTurn') then
            myCurrentTile.removeTag('shouldFlipThisTurn')
        end
        myCurrentTile = info.collision_object

        if myCurrentTile.hasTag('canFlip') == true then
            myCurrentTile.addTag('shouldFlipThisTurn')
        end
    elseif info.collision_object.hasTag('playerPawn') == true then
        params = {
            playerColor,
            info.collision_object.getVar('playerColor')
        }
        Global.call('onCombatStart', params)
    else
        addThisTurn = 0
        giveCombatCard = false
        giveResourceCard = false
        if myCurrentTile ~= nil and myCurrentTile ~= 0 then
            if myCurrentTile.hasTag('shouldFlipThisTurn') then
                myCurrentTile.removeTag('shouldFlipThisTurn')
            end
        end
        Global.call('noCombat')
        myCurrentTile = 0
    end
end
function MovementCheck(tile, playerNum, num)
    if #getObjectsWithTag('myDice') > 0 then
        num = getObjectsWithTag('myDice')[1].getRotationValue()
        --printToAll(getObjectsWithTag('myDice')[1].getRotationValue())
    end
    if #getObjectsWithTag('myDice') > 0 then
        heavyRainNum = getObjectsWithTag('myDice')[1].getVar('heavyRainNum')
        if heavyRainNum ~= nil then
            num = heavyRainNum
        end
    else
        printToAll('something wrong with dice')
    end

    if Global.getVar('fleinSoppOn') == true then
        num = num * 2
    end

    local surroundingTilesMovement = { tile }
    local movCostTag = 'player' .. playerNum .. 'LowestMovCost'
    local spawnTileInHere = tile.hasTag('playerSpawnTile')
    local lowestSpawnTileCost = 200
    if spawnTileInHere == true then
        lowestSpawnTileCost = 0
    end
    tile.setVar(movCostTag, 0)

    if num > 0 then
        if Global.GetVar('superShoeOn') == true then
            for _, localTile in ipairs(getObjectsWithTag('tile')) do
                local x = localTile.getVar('customX')
                local y = localTile.getVar('customY')
                local diffX = math.abs(x - tile.getVar('customX'))
                local diffY = math.abs(y - tile.getVar('customY'))
                local diff = diffX + diffY
                if diff <= num then
                    localTile.addTag('highlightCheck')
                    localTile.setVar('highlighColor', "Red")
                    if localTile.hasTag('playerSpawnTile') then
                        spawnTileInHere = true
                    end
                end
            end
        else
            local absIndexMovementCheck = 0
            while(#surroundingTilesMovement > 0 and absIndexMovementCheck < 200)
            do

                local localTileMovement = surroundingTilesMovement[#surroundingTilesMovement]
                local x = localTileMovement.getVar('customX')
                local y = localTileMovement.getVar('customY')
                local currentMovCost = localTileMovement.getVar(movCostTag)

                if localTileMovement.hasTag('playerSpawnTile') == true  and localTileMovement.hasTag(movCostTag) == true and localTileMovement.getVar(movCostTag) < lowestSpawnTileCost and localTileMovement.getVar(movCostTag) <= num then
                    lowestSpawnTileCost = currentMovCost
                    spawnTileInHere = true
                end

                if math.abs(x - tile.getVar('customX')) <= num and math.abs(y - tile.getVar('customY')) <= num and localTileMovement.hasTag('checked') == false then
                    for _, localTile2 in ipairs(checkHelper(localTileMovement)) do
                        if math.abs(localTile2.getVar('customX') - tile.getVar('customX')) <= num and math.abs(localTile2.getVar('customY') - tile.getVar('customY')) <= num and localTile2.hasTag('checked') == false then
                            if localTile2.hasTag(movCostTag) == true then
                                if localTileMovement.getVar(movCostTag) + localTile2.getVar('movementCost') < localTile2.getVar(movCostTag) then
                                    localTile2.setVar(movCostTag, localTileMovement.getVar(movCostTag) + localTile2.getVar('movementCost'))
                                    for _, localTile3 in ipairs(checkHelper(localTile2)) do
                                        table.insert(surroundingTilesMovement, 1, localTile3)
                                    end
                                end
                            else
                                localTile2.addTag(movCostTag)
                                localTile2.setVar(movCostTag, localTileMovement.getVar(movCostTag) + localTile2.getVar('movementCost'))
                                table.insert(surroundingTilesMovement, 1, localTile2)
                            end
                        end
                    end
                end

                localTileMovement.addTag('checked')
                table.remove(surroundingTilesMovement)
                absIndexMovementCheck = absIndexMovementCheck + 1
            end
        end
        tile.highlightOff('White')

        if spawnTileInHere == true then
            for _, localTile4 in ipairs(getObjectsWithTag('playerSpawnTile')) do
                localTile4.addTag('highlightCheck')
                localTile4.setVar('highlighColor', 'Green')
            end
        end
        for _, localTile4 in ipairs(getObjectsWithTag('checked')) do
            localTile4.removeTag('checked')
        end
        for _, localTile5 in ipairs(getObjectsWithTag(movCostTag)) do
            if localTile5.getVar(movCostTag) <= num then
                if localTile5.hasTag('highlightCheck') == false then
                    localTile5.addTag('highlightCheck')
                    localTile5.setVar('highlighColor', "Red")
                end
            end
            localTile5.removeTag(movCostTag)
            localTile5.setVar(movCostTag, 1000)
        end
        for _, localTile6 in ipairs(getObjectsWithTag('highlightCheck')) do
            localTile6.highlightOn(localTile6.getVar('highlighColor'))
            localTile6.removeTag('highlightCheck')
        end
    end
end
function checkHelper(tile)
    local surroundingTilesCheckHelper = {}
    local orgXCheckHelper = tile.getVar('customX')
    local orgYCheckHelper = tile.getVar('customY')
    for _, checkHelperLocalTile in ipairs(getObjectsWithTag('tile')) do
        local xCheckHelper = checkHelperLocalTile.getVar('customX')
        local yCheckHelper = checkHelperLocalTile.getVar('customY')
        if math.abs(xCheckHelper - orgXCheckHelper) < 1 or math.abs(yCheckHelper - orgYCheckHelper) < 1 then
            if math.abs(xCheckHelper - orgXCheckHelper) < 2 and math.abs(yCheckHelper - orgYCheckHelper) < 2 then
                if checkHelperLocalTile ~= tile then
                    surroundingTilesCheckHelper[#surroundingTilesCheckHelper + 1] = checkHelperLocalTile
                end
            end
        end
    end
    return surroundingTilesCheckHelper
end
function onPickUp(player_color)
    if myTileThisTurn ~= 0 and myTileThisTurn ~= nil then
        MovementCheck(myTileThisTurn, 1, 3)
    elseif myCurrentTile ~= 0 and myTileThisTurn ~= nil then
        MovementCheck(myCurrentTile, 1, 3)
    end
end
function onDrop(player_color)
    for _, tile in ipairs(getObjectsWithTag('tile')) do
        tile.highlightOff('White')
    end
    for _, tile in ipairs(getObjectsWithTag('player' .. myIndex .. 'LowestMovCost')) do
        tile.removeTag('player' .. myIndex .. 'LowestMovCost')
    end
    self.highlightOff('Red')
end
    ]])

    player.setVar('playerColor', color)

    local textButtonParams = {
        click_function = 'printVikings',
        function_owner = self,
        label          = vikings,
        position       = { 0, 3, 0 },
        rotation       = { 90, 180, 0 },
        width          = 800,
        height         = 400,
        font_size      = 340,
        color          = { 0.5, 0.5, 0.5 },
        font_color     = { 1, 1, 1 },
        tooltip        = 'number of vikings',
    }
    local textButtonParams2 = {
        click_function = 'subtractAViking',
        function_owner = self,
        label          = '--',
        position       = { -2.5, 1, 0 },
        rotation       = { -90, 0, 0 },
        width          = 800,
        height         = 400,
        font_size      = 340,
        color          = { 0.5, 0.5, 0.5 },
        font_color     = { 1, 1, 1 },
        tooltip        = 'Subtract A Viking',
    }
    local textButtonParams3 = {
        click_function = 'addAViking',
        function_owner = self,
        label          = '++',
        position       = { -2.5, 2, 0 },
        rotation       = { 90, 0, 180 },
        width          = 800,
        height         = 400,
        font_size      = 340,
        color          = { 0.5, 0.5, 0.5 },
        font_color     = { 1, 1, 1 },
        tooltip        = 'Add A Viking',
    }
    local textButtonParams4 = {
        click_function = 'subtractAViking',
        function_owner = self,
        label          = '--',
        position       = { -2.5, 1, 0 },
        rotation       = { 90, 0, 180 },
        width          = 800,
        height         = 400,
        font_size      = 340,
        color          = { 0.5, 0.5, 0.5 },
        font_color     = { 1, 1, 1 },
        tooltip        = 'Subtract A Viking',
    }
    local textButtonParams5 = {
        click_function = 'addAViking',
        function_owner = self,
        label          = '++',
        position       = { -2.5, 2, 0 },
        rotation       = { -90, 0, 0 },
        width          = 800,
        height         = 400,
        font_size      = 340,
        color          = { 0.5, 0.5, 0.5 },
        font_color     = { 1, 1, 1 },
        tooltip        = 'Add A Viking',
    }

    player.createButton(textButtonParams)
    player.createButton(textButtonParams2)
    player.createButton(textButtonParams3)
    player.createButton(textButtonParams4)
    player.createButton(textButtonParams5)
    player.addTag('gameObject')
    player.addTag('playerPawn')
end

function printVikings(obj, color, alt_click)
    printToColor('player has ' .. obj.getVar('myNumberOfVikings') .. ' vikings', color)
end

function spawnATile(x, y, z, type, customX, customY, additionalTags)
    if type then
        local tile = spawnObject({
            type = 'Custom_Tile',
            position = { x, y, z },
            scale = { Grid.sizeX / 2 - 0.005, Grid.sizeX / 2 - 0.005, Grid.sizeX / 2 - 0.005 }
        })
        local params = { image = '', image_bottom = '' }
        local tileType = 0

        tile.grid_projection = true
        tile.setName(type)
        tile.setVar("tileNumberOfVikings", 0)
        tile.setVar("movementCost", 1)

        tile.setVar("customX", customX)
        tile.setVar("customY", customY)
        tile.setVar("giveCombatCard", false)
        tile.setVar("giveResourceCard", false)
        tile.setVar("spawn", false)
        tile.drag_selectable = false
        tile.gizmo_selectable = false
        if type == 'playerSpawnTile' then
            tileType = 5
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/' ..
                string.lower(colors[tileTypeSpawnAmounts[tileType] + 1]) .. '_tile.png'
            tile.setVar("spawn", true)
            tile.addTag('playerSpawnTile')
        elseif type == 'forest' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/forest.png'
            params.image_bottom = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/forest_used.png'

            tile.setVar("tileNumberOfVikings", 2)
            tile.addTag('canFlip')
            tileType = 3
        elseif type == 'plains' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/grass.png'
            params.image_bottom = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/grass_used.png'

            tile.setVar("tileNumberOfVikings", 1)
            tile.addTag('canFlip')
            tileType = 1
        elseif type == 'mountain' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/mountain.png'
            params.image_bottom = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/mountain_used.png'

            tile.setVar("giveCombatCard", true)
            tile.setVar("movementCost", 2)
            tile.addTag('canFlip')
            tileType = 2
        elseif type == 'swamp' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/swamp.png'
            params.image_bottom = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/swamp_used.png'

            tile.setVar("giveResourceCard", true)
            tile.setVar("movementCost", 3)
            tile.addTag('canFlip')
            tileType = 4
        end
        tile.addTag('tile')
        tile.addTag(additionalTags)
        tile.setCustomObject(params)
        tile.addTag('gameObject')
        tile.setLock(true)
        tileTypeSpawnAmounts[tileType] = tileTypeSpawnAmounts[tileType] + 1
    end
end

function onPlayerTurn(previous_player, cur_player)
    if cur_player.color == getSeatedPlayers()[#getSeatedPlayers()] and #getObjectsWithTag('playerPawn') ~= 0 then
        turnNum = turnNum + 1
        printToAll('starting round ' .. turnNum)
        if turnNum > RagnarokDefStartTurn then
            isRagnarokOn = true
        end
        if isRagnarokOn == true then
            ragnarokTurn = ragnarokTurn + 1
            if (ragnarokTurn) % everyNturnShrink == 0 and ragnarokTurnNum < 5 then
                ragnarokTurnNum = ragnarokTurnNum + 1
                printToAll('ragnarok round ' .. ragnarokTurnNum)
                ragnarokFunc(ragnarokTurnNum)
                for _, playerPawn in pairs(getObjectsWithTag('playerPawn')) do
                    if playerPawn.getVar('myCurrentTile') ~= nil and playerPawn.getVar('myCurrentTile') ~= 0 then
                        playerTile = playerPawn.getVar('myCurrentTile')
                        if playerTile.hasTag('ragnarok' .. ragnarokTurnNum + 1) == true then
                            playerPawn.highlightOn('Red')
                        end
                    end
                end
            end
            if ragnarokTurnNum == 0 then
                for _, playerPawn in pairs(getObjectsWithTag('playerPawn')) do
                    if playerPawn.getVar('myCurrentTile') ~= nil and playerPawn.getVar('myCurrentTile') ~= 0 then
                        playerTile = playerPawn.getVar('myCurrentTile')
                        if playerTile.hasTag('ragnarok' .. ragnarokTurnNum + 1) == true then
                            playerPawn.highlightOn('Red')
                        end
                    end
                end
            end
        end

        for _, player in pairs(getObjectsWithTag('playerPawn')) do
            local vikings = player.getVar('myNumberOfVikings') + player.getVar('addThisTurn')
            local position = player.getPosition()
            local color = player.getVar('playerColor')
            local index = player.getVar('myIndex')
            if player.getVar('giveCombatCard') == true then
                myCombatDeck.deal(1, player.getVar('playerColor'))
            end
            if player.getVar('giveResourceCard') == true then
                resourceDeck.deal(1, player.getVar('playerColor'))
            end
            player.destruct()
            spawnInAPlayer(position.x, position.y, position.z, color, index, vikings)
        end
        for _, tile in pairs(getObjectsWithTag('shouldFlipThisTurn')) do
            local position = tile.getPosition()
            tile.setLock(false)
            tile.flip()
            tile.setLock(true)
            tile.setPosition(position)
            tile.removeTag("canFlip")
            tile.removeTag('shouldFlipThisTurn')
            tile.setName(tile.getName() .. ' (Stepped on)')
            tile.setVar("tileNumberOfVikings", 0)
            tile.setVar('movementCost', 1)
            tile.setVar("giveCombatCard", false)
            tile.setVar("giveResourceCard", false)
        end
    end
    if gameStarted == true then
        for _, tile in pairs(getObjectsWithTag('removeThisScript')) do
            if tile.getVar('isDone') == true then
                tile.setLuaScript([[]])
                tile.removeTag('removeThisScript')
            end
        end
        dice.setVar('heavyRainNum', nil)
        dice.setVar('timesDiceThrownThisTurn', 0)
        fleinSoppOn = false
        printToAll('It is ' .. previous_player.color .. "'s turn.")
        if heavyRainOn == true then
            if heavyRainPlayedBeforeMovement == true then
                if previous_player.color == heavyRainColor then
                    heavyRainOn = false
                    printToAll('Heavy rain is over')
                end
            else
                if cur_player.color == heavyRainColor then
                    if heavyRainTurn < turnNum then
                        heavyRainOn = false
                        printToAll('Heavy rain is over')
                    end
                end
            end
        end
    end
    superShoeOn = false
    for _, object in pairs(getObjectsWithTag('lastResourceCardPlayed')) do
        object.removeTag('lastResourceCardPlayed')
    end
    for _, object in pairs(getObjectsWithTag('lastCombatCardPlayed')) do
        object.removeTag('lastCombatCardPlayed')
    end
end

function tableToString(myTable)
    local returnString = '{'
    for _, stringToBe in ipairs(myTable) do
        returnString = returnString .. stringToBe .. ", "
    end
    returnString = returnString .. '}'
    return returnString
end

function getPlayerPawn(color)
    for _, playerPawn in ipairs(getObjectsWithTag('playerPawn')) do
        if playerPawn.getVar('playerColor') == color then
            return playerPawn
        end
    end
end
