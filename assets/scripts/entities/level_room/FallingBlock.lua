
defaultArgs({
    type = "T"
})

function create(block, args)

    local color = {
        J = vec3(.1, .3, 1.2),
        L = vec3(1.2, .4, .0),
        T = vec3(.7, 0, .9),
        O = vec3(1., .8, .0),
        I = vec3(0, 1, 1),
        Z = vec3(1.1, 0, 0),
        S = vec3(0, 1, 0)
    }
    color = color[args.type] or vec3()

    setComponents(block, {
        Transform(),
        RenderModel {
            modelName = args.type.."Block"
        },
        ShadowCaster(),
        PointLight {
            diffuse = color * vec3(20),
            specular = color * vec3(20),
            ambient = color * vec3(3)
        }
    })

end

