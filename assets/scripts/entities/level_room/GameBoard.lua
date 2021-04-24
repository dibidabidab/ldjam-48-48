
shapes = include("scripts/entities/level_room/_block_shapes")

defaultArgs({
    width = 10
})

function mod(a, b)
    local c = a % b
    if c < 0 then
        return c + b
    else
        return c
    end
end

function create(board, args)

    local grid = {}
    local minY = 999999999

    print("Creating game board..")
    setName(board, "board")

    for x = 0, args.width do
        grid[x] = {}
        for y = -10, 0 do
            minY = math.min(y, minY)

            local dot = createChild(board, "dot"..x..","..y)
            applyTemplate(dot, "DotBlock")
            grid[x][y] = dot

            component.Transform.getFor(dot).position = vec3(x, y, 0)
        end
    end

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
            y = 5,
            modelOffset = ivec2(0),
            timesRotated = 0
        }
        print("Size of falling block:", shapes.getSize(obj.shape))
        component.Transform.getFor(block).position = vec3(obj.x, obj.y, 0)

        nextFallingBlockType = shapes.getRandomShape()
        return obj
    end

    local fallingBlock = newFallingBlock()

    function moveFallingBlock(x, y)
        fallingBlock.x = fallingBlock.x + x
        fallingBlock.y = fallingBlock.y + y
        component.Transform.animate(fallingBlock.entity, "position",
                vec3(fallingBlock.x + fallingBlock.modelOffset.x, fallingBlock.y + fallingBlock.modelOffset.y, 0), .05)
    end
    function rotateFallingBlock(right)

        if right then
            fallingBlock.shape = shapes.rotate_CW_90(fallingBlock.shape)
            fallingBlock.timesRotated = fallingBlock.timesRotated + 1
        else
            fallingBlock.shape = shapes.rotate_CCW_90(fallingBlock.shape)
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
            if fallingBlock.x + size.x > args.width + 1 then
                if doCorrections then
                    moveFallingBlock(-1, 0)
                end
                valid = false
            end
            if valid then

                local noContactWithAir = true
                for x = 1, size.x do
                    for y = 1, size.y do

                        if fallingBlock.shape[y][x] == 1 then

                            local gridPos = ivec2(fallingBlock.x + x - 1, fallingBlock.y + y - 1)

                            local dotAbove = grid[gridPos.x][gridPos.y + 1]

                            if dotAbove == nil then
                                noContactWithAir = false
                            end
                        end
                    end
                end
                if noContactWithAir then
                    valid = false
                    if doCorrections then
                        moveFallingBlock(0, 1)
                    end
                end
            end
            if not doCorrections then
                return valid
            end
        end
        return valid
    end

    setUpdateFunction(board, .5, function()

        moveFallingBlock(0, -1)
        if not isOrientationValid(false) then
            isOrientationValid(true)
            fallingBlock = newFallingBlock()
        end
    end)



    listenToKey(board, gameSettings.keyInput.moveRight, "move_right")
    onEntityEvent(board, "move_right_pressed", function()
        moveFallingBlock(1, 0)
        isOrientationValid(true)
    end)
    listenToKey(board, gameSettings.keyInput.moveLeft, "move_left")
    onEntityEvent(board, "move_left_pressed", function()
        moveFallingBlock(-1, 0)
        isOrientationValid(true)
    end)
    listenToKey(board, gameSettings.keyInput.softDrop, "soft_drop")
    onEntityEvent(board, "soft_drop_pressed", function()
        moveFallingBlock(0, -1)
        isOrientationValid(true)
    end)
    listenToKey(board, gameSettings.keyInput.rotateRight, "rotate_right")
    onEntityEvent(board, "rotate_right_pressed", function()
        rotateFallingBlock(true)
        isOrientationValid(true)
    end)
    listenToKey(board, gameSettings.keyInput.rotateLeft, "rotate_left")
    onEntityEvent(board, "rotate_left_pressed", function()
        rotateFallingBlock(false)
        isOrientationValid(true)
    end)
end
