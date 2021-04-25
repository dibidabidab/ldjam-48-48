
function create(player)

    setName(player, "player")

    if not _G.titleScreen then
        applyTemplate(createEntity(), "GameBoard")
    else
        applyTemplate(createEntity(), "Title")
    end

end

