
function create(dot)

    setComponents(dot, {
        Transform(),
        RenderModel {
            modelName = "BadDotBlock"
        },
        ShadowCaster(),
        ShadowReceiver()
    })

end
