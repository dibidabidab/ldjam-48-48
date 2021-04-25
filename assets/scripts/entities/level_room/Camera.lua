
defaultArgs({
    setAsMain = false,
    name = ""
})

function create(cam, args)

    setComponents(cam, {
        Transform (),
        CameraPerspective {
            fieldOfView = 75,
            nearClipPlane = .1,
            farClipPlane = 1000
        }
    })
    component.Transform.getFor(cam).rotation.y = 80
    local rot = quat:new()
    component.Transform.animate(cam, "rotation", rot, 4., "pow2Out")

    if args.name ~= "" then
        setName(cam, args.name)
    end
    if args.setAsMain then
        setMainCamera(cam)
    end

    local sun = createChild(cam, "sun")
    setComponents(sun, {
        Transform(),
        ParentOffset {
            position = vec3(-7, 0, -5)
        },
        DirectionalLight {
            ambient = vec3(1),
            diffuse = vec3(10),
            specular = vec3(10)
        },
        ShadowRenderer {
            frustrumSize = vec2(12, 20)
        }
    })
    component.ParentOffset.getFor(sun).rotation.x = 80
    component.ParentOffset.getFor(sun).rotation.y = -40

    local lowerLight = createChild(cam, "lowerLight")
    setComponents(lowerLight, {
        Transform(),
        ParentOffset {
            position = vec3(-2, -10, -14)
        },
        PointLight {
            ambient = vec3(0),
            diffuse = vec3(1, 10, 1),
            specular = vec3(1, 10, 1)
        }
    })

end
