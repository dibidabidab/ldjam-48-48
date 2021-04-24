

function create(dot)

    setComponents(dot, {
        Transform(),
        RenderModel {
            modelName = (math.random() > .5) and "DotBlock" or "DotBlock.001"
        },
        ShadowCaster(),
        ShadowReceiver()
    })

end
