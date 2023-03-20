local colors = { "White", "Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Pink" }
local myGameObjects = {}
local playerPawns = {}
local playerList = {}
--availableTileTypes = {'plains', 'forest','mountain', 'swamp'}
local myCombatDeck = 1

local blueDeck = 1
local mapAmounts = { 5, 7, 9, 11, 11, 11, 11, 11, 9, 7, 5 }
local tileTypeSpawnAmounts = { 0, 0, 0, 0, 0 }
local numberSpawned = 0
--line 9

--based of https://gist.github.com/Uradamus/10323382

function randomizeMap(times)
    for l = 0, times, 1 do
        local localMap = getObjectsWithTag('tile')
        for i = #localMap, 2, -1 do
            local j = math.random(i)
            local obj1 = localMap[i]
            local obj2 = localMap[j]
            if obj1.getVar("spawn") ~= true then
                obj1.setPosition(obj2.getPosition())
                obj2.setPosition(obj1.getPosition())
            end
        end
    end
end

function spawnGame()
    --spawning in the map
    for i = 1, 11, 1 do
        local spawnPoints = false
        if i == 1 or i == 4 or i == 8 or i == 11 then
            spawnPoints = true
        end
        mapHelperFunction(1 - mapAmounts[i] / 2, 0 + mapAmounts[i] / 2, i - 5.5, spawnPoints)
    end

    randomizeMap(4)

    --spawning in player pawns
    playerList = Player.getPlayers()
    local index = 0
    for _, player in ipairs(Player.getPlayers()) do
        index = index + 1

        spawnInAPlayer(
            player.getHandTransform().position.x,
            player.getHandTransform().position.y,
            player.getHandTransform().position.z,
            index
        )
    end
    --spawn decks
    myCombatDeck = spawnObject({
        type = 'Deck',
        position = { 10, 3, 0 },
    })
    myCombatDeck.use_hands = true
    myGameObjects[#myGameObjects + 1] = myCombatDeck

    blueDeck = spawnObject({
        type = 'Deck',
        position = { -10, 3, 0 },
    })
    blueDeck.use_hands = true
    myGameObjects[#myGameObjects + 1] = blueDeck
end

function destroyAllObjects()
    for _, object in ipairs(myGameObjects) do
        destroyObject(object)
    end
    for _, player in ipairs(Player.getPlayers()) do
        for _, object in ipairs(player.getHandObjects()) do
            destroyObject(object)
        end
    end
    myGameObjects = {}
    playerPawns = {}
    numberSpawned = 0
end

function mapHelperFunction(startIndex, endIndex, yPos, playerSpawn)
    for xPos = startIndex, endIndex, 1 do
        local x = xPos * Grid.sizeX
        local y = yPos * Grid.sizeY
        if playerSpawn == true then
            if xPos == startIndex or xPos == endIndex then
                type = 'playerSpawnTile'
            else
                type = randomType()
            end
        else
            type = randomType()
        end
        spawnATile(x, 1, y, type)
    end
end

function randomType()
    local returnVar = 'forest'
    if numberSpawned < 11 + 44 then
        returnVar = 'plains'
    elseif numberSpawned < 11 + 44 + 22 then
        returnVar = 'mountain'
    else
        returnVar = 'swamp'
    end
    numberSpawned = numberSpawned + 1
    return returnVar
end

function spawnInAPlayer(x, y, z, index)
    local tile = spawnObject({
        type = 'Figurine_Custom',
        position = { x, y, z },
        --scale = {0.9,0.9,1}
    })
    local params = {
        image = 'https://screenshots.wildwolf.dev/Gjallarhorn/players/' ..
            string.lower(colors[#playerPawns + 1]) .. '.png'
    }
    print('https://screenshots.wildwolf.dev/Gjallarhorn/players/' ..
        string.lower(colors[#playerPawns + 1]) .. '.png')
    tile.setCustomObject(params)

    tile.setLuaScript([[
        numberOfVikings=3
        addThisTurn=0
        giveCombatCard=false
        giveBlueCard=false
    ]] .. 'myPlayerIndex=' .. tostring(index) .. ' ' .. [[
        function onCollisionEnter(info)
            if info.collision_object.getVar('numberOfVikingsOnThisTile') then
                addThisTurn=info.collision_object.getVar('numberOfVikingsOnThisTile')
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

function spawnATile(x, y, z, type)
    if type then
        local tile = spawnObject({
            type = 'Custom_Tile',
            position = { x, y, z },
        })
        local params = { image = '', image_bottom = '' }
        local tileType = 0

        tile.grid_projection = true
        tile.setName(type)
        tile.setVar("numberOfVikingsOnThisTile", 0)
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
            tileType = 1
        elseif type == 'plains' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/grass.png'
            tile.setVar("numberOfVikings", 1)
            tileType = 2
        elseif type == 'mountain' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/mountain.png'
            tile.setVar("giveCombatCard", true)
            tileType = 3
        elseif type == 'swamp' then
            params.image = 'https://screenshots.wildwolf.dev/Gjallarhorn/tiles/swamp.png'
            tile.setVar("giveResourceCard", true)
            tileType = 4
        end
        tile.addTag('tile')
        tile.setCustomObject(params)
        myGameObjects[#myGameObjects + 1] = tile
        tileTypeSpawnAmounts[tileType] = tileTypeSpawnAmounts[tileType] + 1
    end
end

function onPlayerTurn(previous_player, player)
    if player.color == getSeatedPlayers()[#getSeatedPlayers()] and #playerPawns ~= 0 then
        print('new turn starting')
        for _, player1a in pairs(playerPawns) do
            player1a.setVar('numberOfVikings', player1a.getVar('numberOfVikings') + player1a.getVar('addThisTurn'))
            possiblePog = player1a.editButton({
                index = 0, label = player1a.getVar('numberOfVikings')
            })
            if player1a.getVar('giveCombatCard') == true then
                myCombatDeck.deal(1, playerList[player1a.getVar('myPlayerIndex')].color)
            end
            if player1a.getVar('giveBlueCard') == true then
                blueDeck.deal(1, playerList[player1a.getVar('myPlayerIndex')].color)
            end
        end
    end
end
