
defaultArgs({
    type = "T"
})

function create(block, args)

    print("Creating falling block:", args.type)

    setComponents(block, {
        Transform(),
        RenderModel {
            modelName = args.type.."Block"
        }
    })

end

