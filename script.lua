--myPawn.highlightOn('White')
myGameObjects = {}
playerPawns = {}
playerList = {}
--availableTileTypes = {'plains', 'forest','mountain', 'swamp'}
myCombatDeck = 1

blueDeck = 1
mapAmounts = {5,7,9,11,11,11,11,11,9,7,5}
tileTypeSpawnAmounts = {0,0,0,0,0}
numberSpawned = 0
--line 9

--based of https://gist.github.com/Uradamus/10323382

function randomizeMap()
    localMap = getObjectsWithTag('tile')
    for i = #localMap, 2, -1 do
        local j = math.random(i)
        obj1 = localMap[i]
        obj1Pos = obj1.getPosition()
        obj2 = localMap[j]
        obj2Pos = obj2.getPosition()
        obj1.setPosition(obj2Pos)
        obj2.setPosition(obj1Pos)

    end
end


function spawnGame()

    --initial attempt at randomizing tiles
    --[[myRandomizeZone = spawnObject({
        type = 'ScriptingTrigger',
        position = {0.5, 0, 1},
        scale = {22,5,22},
    })
    myRandomizeZone.addTag('tile')
 
    myRandomizeZone.LayoutZone.setOptions({
        randomize=true,
        trigger_for_face_up=true,
        trigger_for_non_cards=true,
        --vertical_spread=2.1,
        horizontal_spread=2.1,
        vertical_group_padding=0.01
    })]]--


    --spawning in the map
    for i = 1, 11, 1 do
        spawnPoints = false
        if i == 1 or i == 4 or i == 8 or i == 11 then
            spawnPoints = true
        end
        mapHelperFunction(1-mapAmounts[i] / 2, 0+mapAmounts[i] / 2,i - 5.5, spawnPoints)
    end

    randomizeMap()
    randomizeMap()
    randomizeMap()
    randomizeMap()
    
    --print(myRandomizeZone)
    myGameObjects[#myGameObjects+1] = myRandomizeZone
    
    --spawning in player pawns
    playerList = Player.getPlayers()
    index = 0
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
        position = {10, 3, 0},
    })
    myCombatDeck.use_hands = true
    myGameObjects[#myGameObjects+1] = myCombatDeck
    
    blueDeck = spawnObject({
            type = 'Deck',
            position = {-10, 3, 0},
    })
    blueDeck.use_hands = true
    myGameObjects[#myGameObjects+1] = blueDeck
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
    for xPos=startIndex,endIndex,1 do
        x = xPos*Grid.sizeX
        y = yPos*Grid.sizeY
        if playerSpawn == true then
            if xPos == startIndex or xPos == endIndex then
                type = 'playerSpawnTile'
            else
                type = randomType()
            end
        else
            type = randomType()
        end
        spawnATile(x,1,y,type)
    end
end

function randomType()
    returnVar = 'forest'
    if numberSpawned < 11 then
    elseif numberSpawned < 11+44 then
        returnVar = 'plains'
    elseif numberSpawned < 11+44+22 then
        returnVar = 'mountain'
    else
        returnVar = 'swamp'
    end
    numberSpawned = numberSpawned+1
    return returnVar
end


function spawnInAPlayer(x, y, z, index)
    myPawn = spawnObject({
        type = 'Custom_Model',
        position = {x, y, z},
        --scale = {0.9,0.9,1}
    })
    params = {
        mesh = 'C:/temp Tabletop Files/Coffee Cup.obj',
    }

    myPawn.setCustomObject(params)


    myPawn.setLuaScript([[
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

    textButtonParams = {
        click_function = 'notAfunc',
        function_owner = self,
        label          = '3',
        position       = {0, 3, 0},
        rotation       = {90, 180, 0},
        width          = 800,
        height         = 400,
        font_size      = 340,
        color          = {0.5, 0.5, 0.5},
        font_color     = {1, 1, 1},
        tooltip        = 'number of vikings',
    }

    myPawn.createButton(textButtonParams)
    playerPawns[#playerPawns+1] = myPawn
    myGameObjects[#myGameObjects+1] = myPawn
end

function spawnATile(x, y, z, type)


    if type then

        myPawn = spawnObject({
            type = 'Custom_Tile',
            position = {x, y, z},
        })

        myPawn.grid_projection = true
        myPawn.setName(type)
        
        if type == 'playerSpawnTile' then

            params = {image = 'C:/temp Tabletop Files/playerSpawnTile.png'}
            myPawn.setLuaScript([[
                numberOfVikingsOnThisTile=0
                giveCombatCard=false
                giveBlueCard=false
            ]])
            myPawn.addTag('tile')
            tileTypeSpawnAmounts[5] = tileTypeSpawnAmounts[5]+1
        elseif type == 'forest' then

            params = {image = 'C:/temp Tabletop Files/forest.png'}
            myPawn.setLuaScript([[
                numberOfVikingsOnThisTile=2
                giveCombatCard=false
                giveBlueCard=false
            ]])
            myPawn.addTag('tile')
            tileTypeSpawnAmounts[1] = tileTypeSpawnAmounts[1]+1





        elseif type == 'plains' then

            params = {image = 'C:/temp Tabletop Files/plains.png'}
            myPawn.setLuaScript([[
                numberOfVikingsOnThisTile=1
                giveCombatCard=false
                giveBlueCard=false
            ]])
            myPawn.addTag('tile')
            tileTypeSpawnAmounts[2] = tileTypeSpawnAmounts[2]+1

        elseif type == 'mountain' then

            params = {image = 'C:/temp Tabletop Files/mountain.png'}
            myPawn.setLuaScript([[
                numberOfVikingsOnThisTile=0
                giveCombatCard=true
                giveBlueCard=false
            ]])
            myPawn.addTag('tile')
            tileTypeSpawnAmounts[3] = tileTypeSpawnAmounts[3]+1

        elseif type == 'swamp' then

            params = {image = 'C:/temp Tabletop Files/swamp.png'}
            myPawn.setLuaScript([[
                numberOfVikingsOnThisTile=0
                giveCombatCard=false
                giveBlueCard=true
            ]])
            myPawn.addTag('tile')
            tileTypeSpawnAmounts[4] = tileTypeSpawnAmounts[4]+1
        end
        myPawn.setCustomObject(params)
        myGameObjects[#myGameObjects+1] = myPawn
    end
end

function onPlayerTurn(previous_player, player)
    if player.color == getSeatedPlayers()[#getSeatedPlayers()] and #playerPawns != 0 then
        print('new turn starting')
        for _, player1a in pairs(playerPawns) do
            player1a.setVar('numberOfVikings', player1a.getVar('numberOfVikings')+player1a.getVar('addThisTurn'))
            possiblePog = player1a.editButton({
                index=0, label=player1a.getVar('numberOfVikings')
            })
            if player1a.getVar('giveCombatCard') == true then
                myCombatDeck.deal(1,playerList[player1a.getVar('myPlayerIndex')].color)
            end
            if player1a.getVar('giveBlueCard') == true then
                blueDeck.deal(1,playerList[player1a.getVar('myPlayerIndex')].color)
            end
        end
    end
end