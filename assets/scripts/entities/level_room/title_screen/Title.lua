
shapes = include("scripts/entities/level_room/_block_shapes")

function create(title)

    loadModels("assets/models/title.ubj", false)
    setName(title, "title")

    setComponents(title, {
        Transform(),
        RenderModel {
            modelName = "TitleDeep"
        },
        PointLight {
            diffuse = vec3(4, 4, 30),
            specular = vec3(4, 4, 30)
        }
    })

    local trisMap = {
        {1,1,1, 0, 1,1,1, 0, 2, 0, 1,1,1},
        {0,1,0, 0, 1,0,1, 0, 0, 0, 1,0,0},
        {0,1,0, 0, 1,1,0, 0, 1, 0, 1,1,1},
        {0,1,0, 0, 1,0,1, 0, 1, 0, 0,0,1},
        {0,1,0, 0, 1,0,1, 0, 1, 0, 1,1,1},
    }

    for y = 1, #trisMap do
        local row = trisMap[y]
        for x = 1, #row do

            if row[x] ~= 0 then

                local dot = createChild(title)
                applyTemplate(dot, row[x] == 1 and "DotBlock" or "BadDotBlock", {
                    random = function()
                        return 1.
                    end
                })

                component.Transform.getFor(dot).position = vec3(x, 30, y)
                component.Transform.getFor(dot).rotation.x = -90
                setTimeout(dot, (x + y) * .1 + .4, function()
                    local pos = component.Transform.getFor(dot).position
                    component.Transform.animate(dot, "position", vec3(pos.x, -3, pos.z), .4, "pow2Out")
                end)
            end
        end
    end

    setMainCamera(getByName("cam"))

    setUpdateFunction(title, 10., function()

        local block = createChild(title)
        applyTemplate(block, "FallingBlock", { type = shapes.getRandomShape() })
        component.Transform.getFor(block).position = vec3(-40, 6, 23)
        component.Transform.getFor(block).rotation.x = -56
        component.Transform.getFor(block).rotation.z = -43
        component.Transform.getFor(block).scale = vec3(15)
        component.PointLight.remove(block) -- shader def lagspike

        component.Transform.animate(block, "position", vec3(40, 6, 28), 10, function()
            component.DespawnAfter(block).time = 0.
        end)

    end)
    component.LuaScripted.getFor(title).updateAccumulator = 4

end
