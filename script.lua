Hands.hiding = 1

local colors = { "Red", "White", "Orange", "Pink", "Yellow", "Purple", "Green", "Blue" }
local myCombatDeck = 1
local blueDeck = 1
local dice = 1

local mapAmounts = { 5, 7, 9, 11, 11, 11, 11, 11, 9, 7, 5 }
local tileTypeSpawnAmounts = { 0, 0, 0, 0, 0 }
local numberSpawned = 0

local isRagnarokOn = false
local ragnarokTurn = 0
local ragnarokTurnNum = 0
local everyNturnShrink = 3
local RagnarokDefStartTurn = 5

local turnNum = 0

function updateVikingCount(player)
    playerVikings = player.getVar('myNumberOfVikings')
    possiblePog = player.editButton({
        index = 0, label = player.getVar('myNumberOfVikings')
    })
    --local playerParams = 
    --if player.getVar('myNumberOfVikings') >= 12 then
        --båt
        --MAGNUS-SENPEI NOTICE ME! KYAAA!
        --playerParams.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/players/' .. string.lower(player.getVar('color')) .. '.png'
    --else if player.getVar('myNumberOfVikings') >= 8 then
        --geit
        --MAGNUS-SENPEI NOTICE ME! KYAAA!
        --playerParams.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/players/' .. string.lower(player.getVar('color')) .. '.png'
    --else if player.getVar('myNumberOfVikings') >= 5 then
        --berserker
        --MAGNUS-SENPEI NOTICE ME! KYAAA!
        --playerParams.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/players/' .. string.lower(player.getVar('color')) .. '.png'
    --else if player.getVar('myNumberOfVikings') >= 5 then
        --normal
        --MAGNUS-SENPEI NOTICE ME! KYAAA!
        --playerParams.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/players/' .. string.lower(player.getVar('color')) .. '.png'
    --end
    --player.setCustomObject(playerParams)
    --player.reload()
end

function subtractAViking(object, player_color)
    object.setVar('myNumberOfVikings', object.getVar('myNumberOfVikings') - 1)
    updateVikingCount(object)
end

function addAViking(object, player_color)
    object.setVar('myNumberOfVikings', object.getVar('myNumberOfVikings') + 1)
    updateVikingCount(object)
end

function forfeitTile(player)
    for _, playerPawn in ipairs(getObjectsWithTag('playerPawn')) do
        if playerPawn.getVar('color') ~= nil then
            if playerPawn.getVar('color') == player.color then
                playerPawn.setVar('myCurrentTile', nil)
            end
        end
    end
end

function StartRagnarok()
    --not working
    if isRagnarokOn == false then
        printAll('starting Ragnarok!')
        isRagnarokOn = true
    end
end

function StartRagnarok2()
    if isRagnarokOn == false then
        printAll('starting Ragnarok!')
        isRagnarokOn = true
        for _, player in ipairs(getObjectsWithTag('playerPawn')) do
            local testPoggersDoNotStealOriginalOC = player.getVar('myNumberOfVikings') / 2
            if testPoggersDoNotStealOriginalOC == math.floor(testPoggersDoNotStealOriginalOC) then
                player.setVar('myNumberOfVikings', testPoggersDoNotStealOriginalOC)
            else
                player.setVar('myNumberOfVikings', math.floor(testPoggersDoNotStealOriginalOC)+1)
            end
            updateVikingCount(player)
        end
    end
end

function ragnarokFunc(i)
    for _, object in ipairs(getObjectsWithTag('ragnarok'..i)) do
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
    --spawning in the map
    for i = 1, 11, 1 do
        spawnPoints = false
        if i == 1 or i == 4 or i == 8 or i == 11 then
            spawnPoints = true
        end
        mapHelperFunction(1-mapAmounts[i] / 2, 0+mapAmounts[i] / 2,i - 5.5, spawnPoints,i)
    end

    dice = spawnObject({
        type = 'Die_6',
        position = { 0, 10, 2 },
    })
    dice.addTag('dice')
    dice.addTag('gameObject')
    
    --spawning in player pawns
    local spawnPlayerIndex = 1
    for _, player in ipairs(Player.getPlayers()) do
        spawnInAPlayer(
            player.getHandTransform().position.x,
            player.getHandTransform().position.y,
            player.getHandTransform().position.z,
            player.color,
            spawnPlayerIndex
        )
        spawnPlayerIndex = spawnPlayerIndex + 1
    end
    
    --spawn decks
    deckScale = 1.75
    myCombatDeck = spawnObject({
        type = 'DeckCustom',
        position = { 16, 5, 12 },
        scale = { deckScale, deckScale, deckScale}
    })
    combatDeckParams ={
        face = 'C:/temp Tabletop Files/CombatCardCollection.png', back = 'C:/temp Tabletop Files/card backside_Combat.png',
        width = 3,
        height = 3,
        number = 6
    }
    myCombatDeck.use_hands = true
    myCombatDeck.hide_when_face_down = true
    myCombatDeck.use_snap_points = false
    myCombatDeck.setCustomObject(combatDeckParams)
    myCombatDeck.setRotation({0,45-90,0})
    myCombatDeck.setName('Combat Cards')
    myCombatDeck.addTag('gameObject')
    myCombatDeck.flip()

    blueDeck = spawnObject({
        type = 'DeckCustom',
        position = { -12, 5, -16 },
        scale = { deckScale, deckScale, deckScale}
    })
    blueDeckParams ={
        face = 'C:/temp Tabletop Files/ResourceCardCollection2.png', back = 'C:/temp Tabletop Files/card backside_Resources.png',
        width = 3,
        height = 3,
        number = 7,
    }
    blueDeck.use_hands = true
    blueDeck.hide_when_face_down = true
    blueDeck.use_snap_points = false
    blueDeck.setCustomObject(blueDeckParams)
    blueDeck.setRotation({0,45-90,0})
    blueDeck.setName('Resource Cards')
    blueDeck.addTag('gameObject')
    blueDeck.flip()
end

function destroyAllObjects()
    for _, object in ipairs(getObjectsWithTag('gameObject')) do
        destroyObject(object)
    end
    tileTypeSpawnAmounts = { 0, 0, 0, 0, 0 }
    numberSpawned = 0
    for _, player in ipairs(Player.getPlayers()) do
        for _, obj in ipairs(player.getHandObjects(1)) do
            destroyObject(obj)
        end
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
        if xPos == startIndex or xPos == endIndex or index == 12-1 or index == 1 then
            spawnATile(x,tileHeight,y,type, xPos + 4.5, index, 'ragnarok' .. 1)
        else
            if xPos+1 == startIndex or xPos-1 == startIndex or xPos+1 == endIndex or xPos-1 == endIndex or index == 11-1 or index == 1+1 then
                spawnATile(x,tileHeight,y,type, xPos + 4.5, index,'ragnarok' .. 2)
            else
                if xPos+2 == startIndex or xPos-2 == startIndex or xPos+2 == endIndex or xPos-2 == endIndex or index == 11-2 or index == 1+2 then
                    spawnATile(x,tileHeight,y,type, xPos + 4.5, index,'ragnarok' .. 3)
                else
                    if xPos+3 == startIndex or xPos-3 == startIndex or xPos+3 == endIndex or xPos-3 == endIndex or index == 11-3 or index == 1+3 then
                        spawnATile(x,tileHeight,y,type, xPos + 4.5, index,'ragnarok' .. 4)
                    else
                        spawnATile(x,tileHeight,y,type, xPos + 4.5, index, '')
                    end
                end
            end
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

function spawnInAPlayer(x, y, z, color, index)
    local player = spawnObject({
        type = 'Figurine_Custom',
        position = { x, y, z },
    })
    local params = {
        image = 'https://screenshots.wildwolf.dev/Gjallarhorn/players/' ..
            string.lower(color) .. '.png'
    }
    player.setCustomObject(params)
    player.setLuaScript([[
        myNumberOfVikings = 3
        addThisTurn = 0
        giveCombatCard = false
        giveResourceCard = false
        myCurrentTile = 0
        myTileThisTurn = 0
        isInCombat = false
        myIndex = ]] .. index .. [[

        ]]
        .. 'color = ' .."'" ..color .. "'" .. [[

            function onCollisionEnter(info)
                if info.collision_object.getVar('numberOfVikings') then
                    Global.UI.hide("CombatUI")
                    addThisTurn = info.collision_object.getVar('numberOfVikings')
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
                    Global.UI.Show("CombatUI")
                else
                    addThisTurn = 0
                    giveCombatCard = false
                    giveResourceCard = false
                    if myCurrentTile ~= nil and myCurrentTile ~= 0 then
                        if myCurrentTile.hasTag('shouldFlipThisTurn') then
                            myCurrentTile.removeTag('shouldFlipThisTurn')
                        end
                    end
                    Global.UI.hide("CombatUI")
                    myCurrentTile = 0
                end
            end
            function MovementCheck(tile, playerNum, num)
                if #getObjectsWithTag('dice') > 0 then
                    num = getObjectsWithTag('dice')[1].getRotationValue()
                    --printAll(getObjectsWithTag('dice')[1].getRotationValue())
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
                    tile.highlightOff('White')
            
                    if spawnTileInHere == true then
                        -- local num2 = num - lowestSpawnTileCost
                        -- if num2 > 0 then 
                        --     for _, localSpawnTile in ipairs(getObjectsWithTag('playerSpawnTile')) do
                        --         localSpawnTile.addTag('highlightCheck')
                        --         localSpawnTile.setVar('highlighColor', "Green")
                
                        --         local spawnLocalTilesINeedToCheck = { localSpawnTile }
                        --         localSpawnTile.setVar(movCostTag, 0)
                        --         while(#spawnLocalTilesINeedToCheck > 0 and absIndexMovementCheck < 150)
                        --         do
                                    
                        --             local localTileMovement = spawnLocalTilesINeedToCheck[#spawnLocalTilesINeedToCheck]
                        --             local x = localTileMovement.getVar('customX')
                        --             local y = localTileMovement.getVar('customY')
                        --             local currentMovCost = localTileMovement.getVar(movCostTag)+1
                
                        --             if math.abs(x - localSpawnTile.getVar('customX')) <= num2 and math.abs(y - localSpawnTile.getVar('customY')) <= num2 and localTileMovement.hasTag('checked') == false then
                        --                 for _, localTile2 in ipairs(checkHelper(localTileMovement)) do
                        --                     if math.abs(localTile2.getVar('customX') - localSpawnTile.getVar('customX')) <= num2 and math.abs(localTile2.getVar('customY') - localSpawnTile.getVar('customY')) <= num2 and localTile2.hasTag('checked') == false then
                        --                         if localTile2.hasTag(movCostTag) == true and localTile2.getVar('movementCost') < num2 then
                        --                             if currentMovCost + localTile2.getVar('movementCost') < localTile2.getVar(movCostTag) then
                        --                                 localTile2.setVar(movCostTag, currentMovCost + localTile2.getVar('movementCost'))
                        --                                 for _, localTile3 in ipairs(checkHelper(localTile2)) do
                        --                                     table.insert(spawnLocalTilesINeedToCheck, 1, localTile3)
                        --                                 end
                        --                             end
                        --                         else
                        --                             localTile2.addTag(movCostTag)
                        --                             localTile2.setVar(movCostTag, currentMovCost + localTile2.getVar('movementCost'))
                        --                             table.insert(spawnLocalTilesINeedToCheck, 1, localTile2)
                        --                         end
                        --                     end
                        --                 end
                        --             end
                            
                        --             localTileMovement.addTag('checked')
                        --             table.remove(spawnLocalTilesINeedToCheck)
                        --             absIndexMovementCheck = absIndexMovementCheck + 1
                        --         end
                
                
                

                        --         for _, spawnLocalTile2 in ipairs(spawnLocalTilesINeedToCheck) do
                        --             spawnLocalTile2.addTag('highlightCheck')
                        --             spawnLocalTile2.setVar('highlighColor', "Red")
                        --             localSpawnTile.highlightOn('Green')
                        --         end
                        --     end
                        -- else
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
    local textButtonParams = {
        click_function = 'notAfunc',
        function_owner = self,
        label          = '3',
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
        rotation       = { 90, 0, 0 },
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
        rotation       = { 90, 0, 0 },
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
        rotation       = { -90, 0, 0 },
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

function spawnATile(x, y, z, type, customX, customY, additionalTags)
    if type then
        local tile = spawnObject({
            type = 'Custom_Tile',
            position = { x, y, z },
            scale = { Grid.sizeX / 2 * 99 / 100, Grid.sizeX / 2, Grid.sizeX / 2 * 99 / 100 }
        })
        local params = { image = '', image_bottom = '' }
        local tileType = 0

        tile.grid_projection = true
        tile.setName(type)
        tile.setVar("numberOfVikings", 0)
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
            --MAGNUS-SENPEI NOTICE ME! KYAAA!
            params.image_bottom = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/mountain.png'

            tile.setVar("numberOfVikings", 2)
            tile.addTag('canFlip')
            tileType = 3
        elseif type == 'plains' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/grass.png'
            --MAGNUS-SENPEI NOTICE ME! KYAAA!
            params.image_bottom = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/mountain.png'
            
            tile.setVar("numberOfVikings", 1)
            tile.addTag('canFlip')
            tileType = 1
        elseif type == 'mountain' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/mountain.png'
            --MAGNUS-SENPEI NOTICE ME! KYAAA!
            params.image_bottom = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/swamp.png'
            
            tile.setVar("giveCombatCard", true)
            tile.setVar("movementCost", 2)
            tile.addTag('canFlip')
            tileType = 2
        elseif type == 'swamp' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/swamp.png'
            --MAGNUS-SENPEI NOTICE ME! KYAAA!
            params.image_bottom = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/mountain.png'
            
            tile.setVar("giveResourceCard", true)
            tile.setVar("movementCost", 3)
            tile.addTag('canFlip')
            tileType = 4
        end
        tile.setLock(true)
        tile.addTag('tile')
        tile.addTag(additionalTags)
        tile.setCustomObject(params)
        tile.addTag('gameObject')
        tileTypeSpawnAmounts[tileType] = tileTypeSpawnAmounts[tileType] + 1
    end
end

function onPlayerTurn(previous_player, cur_player)
    if cur_player.color == getSeatedPlayers()[#getSeatedPlayers()] and #getObjectsWithTag('playerPawn') ~= 0 then
        turnNum = turnNum + 1
        printAll('starting round ' .. turnNum)
        if turnNum > RagnarokDefStartTurn then
            isRagnarokOn = true
        end
        if isRagnarokOn == true then
            ragnarokTurn = ragnarokTurn + 1
            if (ragnarokTurn) % everyNturnShrink == 0 and ragnarokTurn < 11 then
                ragnarokTurnNum = ragnarokTurnNum + 1
                printAll('ragnarok round ' .. ragnarokTurnNum)
                ragnarokFunc(ragnarokTurnNum)
                for _, playerPawn in pairs(getObjectsWithTag('playerPawn')) do
                    if playerPawn.getVar('myCurrentTile') ~= nil and playerPawn.getVar('myCurrentTile') ~= 0 then
                        playerTile = playerPawn.getVar('myCurrentTile')
                        if playerTile.hasTag('ragnarok'.. ragnarokTurnNum + 1) == true then
                            playerPawn.highlightOn('Red')
                        end
                    end
                end
            end
        end

        for _, player in pairs(getObjectsWithTag('playerPawn')) do
            player.setVar('myNumberOfVikings', player.getVar('myNumberOfVikings') + player.getVar('addThisTurn'))
            player.setVar('myTileThisTurn', player.getVar('myCurrentTile'))
            updateVikingCount(player)
            if player.getVar('giveCombatCard') == true then
                myCombatDeck.deal(1, player.getVar('color'))
            end
            if player.getVar('giveResourceCard') == true then
                blueDeck.deal(1, player.getVar('color'))
            end
        end
        for _, tile in pairs(getObjectsWithTag('shouldFlipThisTurn')) do
            tile.setLock(false)
            tile.flip()
            tile.setLock(true)
            tile.removeTag("canFlip")
            tile.removeTag('shouldFlipThisTurn')
            tile.setName(tile.getName() .. ' (Stepped on)')
            tile.setVar("numberOfVikings", 0)
            tile.setVar('movementCost', 1)
            tile.setVar("giveCombatCard", false)
            tile.setVar("giveResourceCard", false)
        end
    end
end
function notAfunc()

end