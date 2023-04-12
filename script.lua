local colors = { "Red", "White", "Orange", "Pink", "Yellow", "Purple", "Green", "Blue" }
local myGameObjects = {}
local playerPawns = {}
--availableTileTypes = {'plains', 'forest','mountain', 'swamp'}
local myCombatDeck = 1

local blueDeck = 1
local mapAmounts = { 5, 7, 9, 11, 11, 11, 11, 11, 9, 7, 5 }
local tileTypeSpawnAmounts = { 0, 0, 0, 0, 0 }
local numberSpawned = 0

local isRagnarokOn = false
local ragnarokTurn = 0
local ragnarokTurnNum = 0
local everyNturnShrink = 3

--line 9

function StartRagnarok()
    --not working
    print('starting Ragnarok!')
    isRagnarokOn = true
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
    --spawning in the map
    for i = 1, 11, 1 do
        spawnPoints = false
        if i == 1 or i == 4 or i == 8 or i == 11 then
            spawnPoints = true
        end
        mapHelperFunction(1-mapAmounts[i] / 2, 0+mapAmounts[i] / 2,i - 5.5, spawnPoints,i)
    end

    -- randomizeMap(4)

    --spawning in player pawns
    for _, player in ipairs(Player.getPlayers()) do
        spawnInAPlayer(
            player.getHandTransform().position.x,
            player.getHandTransform().position.y,
            player.getHandTransform().position.z,
            player.color
        )
    end
    --spawn decks
    myCombatDeck = spawnObject({
        type = 'Deck',
        position = { 10, 10, 0 },
    })
    myCombatDeck.use_hands = true
    myGameObjects[#myGameObjects + 1] = myCombatDeck

    blueDeck = spawnObject({
        type = 'Deck',
        position = { -10, 10, 0 },
    })
    blueDeck.use_hands = true
    myGameObjects[#myGameObjects + 1] = blueDeck
end

function destroyAllObjects()
    for _, object in ipairs(myGameObjects) do
        destroyObject(object)
    end
    myGameObjects = {}
    playerPawns = {}
    tileTypeSpawnAmounts = { 0, 0, 0, 0, 0 }
    numberSpawned = 0
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
        if xPos == startIndex or xPos == endIndex or index == 12-1 or index == 1 then
            spawnATile(x,5,y,type,'ragnarok' .. 1)
        else
            if xPos+1 == startIndex or xPos-1 == startIndex or xPos+1 == endIndex or xPos-1 == endIndex or index == 11-1 or index == 1+1 then
                spawnATile(x,5,y,type,'ragnarok' .. 2)
            else
                if xPos+2 == startIndex or xPos-2 == startIndex or xPos+2 == endIndex or xPos-2 == endIndex or index == 11-2 or index == 1+2 then
                    spawnATile(x,5,y,type,'ragnarok' .. 3)
                else
                    if xPos+3 == startIndex or xPos-3 == startIndex or xPos+3 == endIndex or xPos-3 == endIndex or index == 11-3 or index == 1+3 then
                        spawnATile(x,5,y,type,'ragnarok' .. 4)
                    else
                        spawnATile(x,5,y,type, '')
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

function spawnInAPlayer(x, y, z, color)
    local tile = spawnObject({
        type = 'Figurine_Custom',
        position = { x, y, z },
        --scale = {0.9,0.9,1}
    })
    local params = {
        image = 'https://screenshots.wildwolf.dev/Gjallarhorn/players/' ..
            string.lower(color) .. '.png'
    }
    tile.setCustomObject(params)

    tile.setLuaScript([[
        myNumberOfVikings=3
        addThisTurn=0
        giveCombatCard=false
        giveBlueCard=false
    ]] .. 'color=' .. color .. ' ' .. [[
        function onCollisionEnter(info)
            if info.collision_object.getVar('numberOfVikings') then
                addThisTurn=info.collision_object.getVar('numberOfVikings')
                giveCombatCard = info.collision_object.getVar('giveCombatCard')
                giveBlueCard = info.collision_object.getVar('giveBlueCard')
            end
        end

        function onPickUp(player_color)
            for _, tile in ipairs(getObjectsWithTag('tile')) do
                tile.highlightOn('White')
            end
        end

        function onDrop( player_color)
            for _, tile in ipairs(getObjectsWithTag('tile')) do
                tile.highlightOff('White')
            end
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

    tile.createButton(textButtonParams)
    playerPawns[#playerPawns + 1] = tile
    myGameObjects[#myGameObjects + 1] = tile
end

function spawnATile(x, y, z, type, additionalTags)
    if type then
        local tile = spawnObject({
            type = 'Custom_Tile',
            position = { x, y, z },
            scale = { Grid.sizeX / 2, Grid.sizeX / 2, Grid.sizeX / 2 }
        })
        local params = { image = '', image_bottom = '' }
        local tileType = 0

        tile.grid_projection = true
        tile.setName(type)
        tile.setVar("numberOfVikings", 0)
        tile.setVar("giveCombatCard", false)
        tile.setVar("giveResourceCard", false)
        tile.setVar("spawn", false)
        if type == 'playerSpawnTile' then
            tileType = 5
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/' ..
                string.lower(colors[tileTypeSpawnAmounts[tileType] + 1]) .. '_tile.png'
            tile.setVar("spawn", true)
        elseif type == 'forest' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/forest.png'
            tile.setVar("numberOfVikings", 2)
            tileType = 3
        elseif type == 'plains' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/grass.png'
            tile.setVar("numberOfVikings", 1)
            tileType = 1
        elseif type == 'mountain' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/mountain.png'
            tile.setVar("giveCombatCard", true)
            tileType = 2
        elseif type == 'swamp' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/swamp.png'
            tile.setVar("giveResourceCard", true)
            tileType = 4
        end
        tile.addTag('tile')
        tile.addTag(additionalTags)
        tile.setCustomObject(params)
        myGameObjects[#myGameObjects + 1] = tile
        tileTypeSpawnAmounts[tileType] = tileTypeSpawnAmounts[tileType] + 1
    end
end

function onPlayerTurn(previous_player, cur_player)
    if cur_player.color == getSeatedPlayers()[#getSeatedPlayers()] and #playerPawns ~= 0 then
        print('new turn starting')
        if isRagnarokOn == true then
            ragnarokTurn = ragnarokTurn + 1
            if (ragnarokTurn + 2) % everyNturnShrink == 0 and ragnarokTurn < 11 then
                ragnarokTurnNum = ragnarokTurnNum + 1
                print('ragnarok turn ' .. ragnarokTurnNum)
                ragnarokFunc((ragnarokTurn + 2) / 3)
            end
        end

        for _, player in pairs(playerPawns) do
            player.setVar('myNumberOfVikings', player.getVar('myNumberOfVikings') + player.getVar('addThisTurn'))
            possiblePog = player.editButton({
                index = 0, label = player.getVar('myNumberOfVikings')
            })
            if player.getVar('giveCombatCard') == true then
                myCombatDeck.deal(1, player.getVar('color'))
            end
            if player.getVar('giveBlueCard') == true then
                blueDeck.deal(1, player.getVar('color'))
            end
        end
    end
end
