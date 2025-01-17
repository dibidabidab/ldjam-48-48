
loadModels("assets/models/blocks.ubj", false)
shapes = include("scripts/entities/level_room/_block_shapes")

defaultArgs({
    width = _G.boardWidth or 9,
    timeTillNewRow = 14,
    fallTime = 1.,
    deathMarksPerCol = 2    -- todo hud has 2 hardcoded
})

function mod(a, b)
    local c = a % b
    if c < 0 then
        return c + b
    else
        return c
    end
end

function soundEffect(path)
    setComponents(createEntity(), {
        DespawnAfter {
            time = 2.
        },
        SoundSpeaker {
            sound = path
        }
    })
end

function holdKey(listener, keyName, action)
    listenToKey(listener, gameSettings.keyInput[keyName], keyName)
    local pressed = 0
    local released = false
    onEntityEvent(listener, keyName.."_pressed", function()
        pressed = pressed + 1
        released = false
        local pressTime = pressed

        action()

        local e = createEntity()
        setTimeout(e, .15, function()
            setUpdateFunction(e, .08, function()
                if not released and pressed == pressTime then
                    action()
                else
                    component.DespawnAfter.getFor(e).time = 0.
                end
            end)
        end)
    end)
    onEntityEvent(listener, keyName.."_released", function()
        released = true
    end)
end

function create(board, args)

    hudScreen.setRoom(currentEngine)

    local grid = {}
    local minY = 999999999
    local maxY = 4

    local score = 0
    local timeMultiplier = 1.

    print("Creating game board..")
    setName(board, "board")

    local cam = createChild(board, "camera")
    applyTemplate(cam, "Camera", { setAsMain = true })
    component.Transform.getFor(cam).position = vec3(args.width / 2, 2, 16)

    local maxYMarkers = { createChild(board, "maxYMarkerLeft"), createChild(board, "maxYMarkerRight") }
    for i = 1, 2 do
        setComponents(maxYMarkers[i], {
            Transform {
                position = (i == 1) and vec3(0) or vec3(args.width, 0, 0)
            },
            RenderModel {
                modelName = "MaxYMarker"
            }
        })
    end
    component.Transform.getFor(maxYMarkers[2]).rotation.z = 180

    function placeDot(x, y, bad)
        minY = math.min(y, minY)

        local dot = createChild(board, "dot"..x..","..y)
        applyTemplate(dot, bad and "BadDotBlock" or "DotBlock")
        grid[x][y] = dot

        component.Transform.getFor(dot).position = vec3(x, y, 0)
    end
    function removeDot(x, y, punish)
        local dot = grid[x][y]
        if dot == nil then
            return false
        else
            if punish then
                component.Transform.animate(dot, "scale", vec3(.85), .5, "pow2Out")
                component.Transform.animate(dot, "position", vec3(x, y + 4, 0), .5, "pow2Out", function()
                    setTimeout(board, .4, function()
                        component.Transform.animate(dot, "position", vec3(-2, y + 4, 0), .5, "pow2Out", function()
                            setTimeout(board, .1, function()
                                destroyEntity(dot)
                            end)
                        end)
                    end)
                end)
                score = score - 1
            else
                score = score + 1
                destroyEntity(dot)
            end

            grid[x][y] = nil
            return true
        end
    end

    for x = 0, args.width - 1 do
        grid[x] = {}
        for y = -8, maxY - 1 do
            placeDot(x, y)
        end
    end

    local holdingType = nil
    local placedAfterHold = true

    local nextFallingBlockType = shapes.getRandomShape()
    local fallingBlocksMade = 0
    function newFallingBlock()

        local block = createChild(board, "fallingblock"..fallingBlocksMade)
        applyTemplate(block, "FallingBlock", { type = nextFallingBlockType })
        fallingBlocksMade = fallingBlocksMade + 1

        local obj = {
            entity = block,
            type = nextFallingBlockType,
            shape = shapes.shapes[nextFallingBlockType],
            x = math.floor(args.width / 2),
            y = maxY + 5,
            modelOffset = ivec2(0),
            timesRotated = 0
        }
        local size = shapes.getSize(obj.shape)
        obj.x = obj.x - math.floor(size.x / 2)
        print("Size of falling block:", size)
        component.Transform.getFor(block).position = vec3(obj.x, obj.y, 0)

        nextFallingBlockType = shapes.getRandomShape()
        updateNextAndHolding()
        return obj
    end

    function updateNextAndHolding()
        local nextB = getChild(cam, "nextBlock")
        local holdB = getChild(cam, "holdBlock")
        currentEngine.nextBlock = nil
        currentEngine.holdBlock = nil
        if nextB ~= nil then
            destroyEntity(nextB)
        end
        if holdB ~= nil then
            destroyEntity(holdB)
        end
        nextB = createChild(cam, "nextBlock")
        currentEngine.nextBlock = nextB
        applyTemplate(nextB, "FallingBlock", { type = nextFallingBlockType })
        setComponents(nextB, {
            Transform {
                position = vec3(-100, 0, 0) -- prevent one frame display
            },
            ParentOffset {
                position = vec3(6, -6, -14)
            }
        })
        if holdingType ~= nil then
            holdB = createChild(cam, "holdBlock")
            currentEngine.holdBlock = holdB
            applyTemplate(holdB, "FallingBlock", { type = holdingType })
            setComponents(holdB, {
                Transform {
                    position = vec3(-100, 0, 0) -- prevent one frame display
                },
                ParentOffset {
                    position = vec3(-10, -6, -14)
                }
            })
        end
    end

    local fallingBlock = nil

    function moveFallingBlock(x, y)
        fallingBlock.x = fallingBlock.x + x
        fallingBlock.y = fallingBlock.y + y

        local z = 1.2

        local size = shapes.getSize(fallingBlock.shape)
        if fallingBlock.y + size.y > maxY + 1 then
            z = 1.8
        end

        component.Transform.animate(fallingBlock.entity, "position",
                vec3(fallingBlock.x + fallingBlock.modelOffset.x, fallingBlock.y + fallingBlock.modelOffset.y, z), .05)
    end
    function rotateFallingBlock(right)

        if right then
            fallingBlock.shape = shapes.rotate_CCW_90(fallingBlock.shape)
            fallingBlock.timesRotated = fallingBlock.timesRotated + 1
        else
            fallingBlock.shape = shapes.rotate_CW_90(fallingBlock.shape)
            fallingBlock.timesRotated = fallingBlock.timesRotated - 1
        end
        fallingBlock.timesRotated = mod(fallingBlock.timesRotated, 4)
        local newRotation = quat:new()
        newRotation.z = fallingBlock.timesRotated * -90
        component.Transform.animate(fallingBlock.entity, "rotation", newRotation, .05)

        local newSize = shapes.getSize(fallingBlock.shape)

        if fallingBlock.timesRotated == 0 then
            fallingBlock.modelOffset = ivec2(0, 0)
        elseif fallingBlock.timesRotated == 1 then
            fallingBlock.modelOffset = ivec2(0, newSize.y)
        elseif fallingBlock.timesRotated == 2 then
            fallingBlock.modelOffset = ivec2(newSize.x, newSize.y)
        elseif fallingBlock.timesRotated == 3 then
            fallingBlock.modelOffset = ivec2(newSize.x, 0)
        end
        moveFallingBlock(0, 0)

        print("Size of falling block:", newSize)
        print("Times rotated:", fallingBlock.timesRotated)
    end

    function isOrientationValid(doCorrections)

        local valid = false

        while not valid do
            valid = true

            local size = shapes.getSize(fallingBlock.shape)

            if fallingBlock.x < 0 then
                if doCorrections then
                    moveFallingBlock(1, 0)
                end
                valid = false
            end
            if fallingBlock.x + size.x > args.width then
                if doCorrections then
                    moveFallingBlock(-1, 0)
                end
                valid = false
            end
            if fallingBlock.y < minY then
                if doCorrections then
                    moveFallingBlock(0, 1)
                end
                valid = false
            end
            if not doCorrections then
                return valid
            end
        end
        return valid
    end

    function finishFallingBlock()
        local size = shapes.getSize(fallingBlock.shape)

        if fallingBlock.y + size.y > maxY + 1 then
            return false
        end

        local e = fallingBlock.entity
        local modelPos = component.Transform.getFor(e).position
        component.PointLight.remove(e)
        component.ShadowCaster.remove(e)
        component.Transform.animate(e, "position", vec3(modelPos.x, modelPos.y, -10 + math.random() * .1), .05, "pow2Out", function()
            setTimeout(board, 30, function()
                destroyEntity(e)
            end)
        end)

        for x = 1, size.x do
            for y = 1, size.y do

                if fallingBlock.shape[y][x] == 1 then

                    local gridPos = ivec2(fallingBlock.x + x - 1, fallingBlock.y + y - 1)

                    if not removeDot(gridPos.x, gridPos.y) then
                        print("OVERLAP! place dot")
                        placeDot(gridPos.x, gridPos.y, true)
                    end
                end
            end
        end

        fallingBlock = nil

        setSkySpeed(3. * timeMultiplier)
        component.CameraPerspective.animate(cam, "fieldOfView", 75.6, .05, "pow2", function()
            component.CameraPerspective.animate(cam, "fieldOfView", 75, .2, "pow2", function()
                setSkySpeed(timeMultiplier)

            end)    -- todo: maybe bug in c++
        end)

        soundEffect("sounds/place")
        placedAfterHold = true
        fallingBlock = newFallingBlock()
        hudScreen.updateHudScore(score, minY)

        timeMultiplier = 1. + (math.max(0, math.min(score, 300)) / 300) * 3.
        print("Time multiplier:", timeMultiplier)

        return true
    end
    hudScreen.updateHudScore(score, minY)

    function moveDownAndPossiblyFinish()
        moveFallingBlock(0, -1)
        if not isOrientationValid(false) then
            isOrientationValid(true)
            finishFallingBlock()
        end
    end

    function updateMaxYMarker()
        print("MaxY =", maxY)
        for i = 1, 2 do
            local pos = component.Transform.getFor(maxYMarkers[i]).position
            component.Transform.animate(maxYMarkers[i], "position", vec3(pos.x, maxY + 1, pos.z), .1, "pow2")
        end
    end

    local deathMarks = {}
    for x = 0, args.width - 1 do
        deathMarks[x] = {}
    end

    local introduceNewRow = nil
    introduceNewRow = function()

        local timeTillNewRow = args.timeTillNewRow / timeMultiplier

        setTimeout(board, timeTillNewRow - 1.5, function()
            for x = 0, args.width - 1 do
                local dot = grid[x][maxY]
                if dot then
                    component.RenderModel.animate(dot, "visibilityMask", 13, 2, "pow2In")
                end
            end
        end)

        setTimeout(board, timeTillNewRow, function()
            minY = minY - 1
            local bad = false
            local nrMarked = 0
            for x = 0, args.width - 1 do
                placeDot(x, minY)

                local crossedAtX = false
                if removeDot(x, maxY, true) then
                    bad = true
                    crossedAtX = true
                    print("Dot crossed maxY line!", x)
                end
                local marked = false
                for markY = 0, args.deathMarksPerCol - 1 do
                    if not marked and crossedAtX and not deathMarks[x][markY] then
                        deathMarks[x][markY] = true
                        hudScreen.mark(x, markY)
                        marked = true
                    end
                    if deathMarks[x][markY] then
                        nrMarked = nrMarked + 1
                    end
                end
            end
            if bad then
                soundEffect("sounds/crossed")
            end
            if nrMarked == args.width * args.deathMarksPerCol then
                print("GAME OVER!")
                setPaused(true)
                currentEngine.gameOver = true
                hudScreen.showGameOverPopup(score)
            else
                introduceNewRow()
                maxY = maxY - 1
                updateMaxYMarker()
                hudScreen.updateHudScore(score, minY)
            end
        end)
        local camPos = component.Transform.getFor(cam).position
        component.Transform.animate(cam, "position", vec3(camPos.x, minY + 9, camPos.z), timeTillNewRow)
    end
    updateMaxYMarker()

    function startGame()

        fallingBlock = newFallingBlock()

        setUpdateFunction(board, args.fallTime, function()
            moveDownAndPossiblyFinish()
        end)

        function delayUpdate()
            component.LuaScripted.getFor(board).updateAccumulator = 0.
        end

        holdKey(board, "moveRight", function()
            moveFallingBlock(1, 0)
            isOrientationValid(true)
            delayUpdate()
        end)
        holdKey(board, "moveLeft", function()
            moveFallingBlock(-1, 0)
            isOrientationValid(true)
            delayUpdate()
        end)
        holdKey(board, "softDrop", function()
            moveFallingBlock(0, -1)
            isOrientationValid(true)
            delayUpdate()
        end)

        listenToKey(board, gameSettings.keyInput.rotateRight, "rotate_right")
        onEntityEvent(board, "rotate_right_pressed", function()
            rotateFallingBlock(true)
            isOrientationValid(true)
            soundEffect("sounds/rotate")
            delayUpdate()
        end)
        listenToKey(board, gameSettings.keyInput.rotateLeft, "rotate_left")
        onEntityEvent(board, "rotate_left_pressed", function()
            rotateFallingBlock(false)
            isOrientationValid(true)
            soundEffect("sounds/rotate")
            delayUpdate()
        end)
        listenToKey(board, gameSettings.keyInput.place, "place")
        onEntityEvent(board, "place_pressed", function()
            finishFallingBlock()
        end)
        listenToKey(board, gameSettings.keyInput.hold, "hold")
        onEntityEvent(board, "hold_pressed", function()

            if not placedAfterHold then
                print("cannot hold, place first")
                return
            end
            placedAfterHold = false

            if holdingType ~= nill then
                nextFallingBlockType = holdingType
            end
            holdingType = fallingBlock.type
            print("holding:", holdingType)
            destroyEntity(fallingBlock.entity)
            fallingBlock = newFallingBlock()
        end)
        introduceNewRow()
    end

    setTimeout(board, 3., function()
        startGame()
    end)
    hudScreen.countDown()
end