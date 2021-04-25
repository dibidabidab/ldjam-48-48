
function create(dot)

    setComponents(dot, {
        Transform(),
        RenderModel {
            modelName = "BadDotBlock"
        },
        ShadowReceiver()
    })

end
