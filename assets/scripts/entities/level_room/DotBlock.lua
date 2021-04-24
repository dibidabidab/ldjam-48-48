
loadModels("assets/models/tetris_blocks.ubj", false)

function create(dot)

    setComponents(dot, {
        Transform(),
        RenderModel {
            modelName = "DotBlock"
        }
    })

end
