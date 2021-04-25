
defaultArgs({
    random = math.random
})

function create(dot, args)

    setComponents(dot, {
        Transform(),
        RenderModel {
            modelName = (args.random() > .5) and "DotBlock" or "DotBlock.001"
        },
        ShadowCaster(),
        ShadowReceiver()
    })

end
