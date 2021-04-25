
_G.titleScreen = true

_G.joinedSession = false

startupArgs = getGameStartupArgs()
if not _G.joinedSession then

    saveGamePath = startupArgs["--single-player"] or "saves/default_save.dibdab"
    startSinglePlayerSession(saveGamePath)

    username = startupArgs["--username"] or "poopoo"
    joinSession(username, function(declineReason)

        tryCloseGame()
        error("couldn't join session: "..declineReason)
    end)
    _G.joinedSession = true
end

onEvent("BeforeDelete", function()
    print("startup screen done..")
end)

function startLevel()
    if screenTransitionStarted then
        return
    end

    startScreenTransition("textures/screen_transition1", "shaders/screen_transition/cutoff_texture")
    onEvent("ScreenTransitionStartFinished", function()

        closeActiveScreen()
        openScreen("scripts/ui_screens/LevelScreen")
    end)
end

setComponents(createEntity(), {
    UIElement {
        absolutePositioning = true
    },
    UIContainer {
        nineSliceSprite = "sprites/ui/hud_border",
        fillRemainingParentHeight = true,
        fillRemainingParentWidth = true,

        zIndexOffset = -10
    }
})

local bottomTextCont = createEntity()
setName(bottomTextCont, "bottomText")
setComponents(bottomTextCont, {
    UIElement {
        absolutePositioning = true,
        absoluteHorizontalAlign = 1,
        absoluteVerticalAlign = 2,
        renderOffset = ivec2(0, 80)
    },
    UIContainer {
        fixedWidth = 200,
        fixedHeight = 40
    }
})


applyTemplate(createChild(bottomTextCont), "Text", {
    text = " Ludum Dare 48 entry by ",
    color = colors.text
})
applyTemplate(createChild(bottomTextCont), "Text", {
    text = "hilkojj\n\n",
    color = colors.theme0
})

function difficultyBtn(name, boardWidth)
    local btn = createChild(bottomTextCont)
    applyTemplate(btn, "Button", {
        text = name,
        action = function()
            _G.boardWidth = boardWidth
            startLevel()
        end
    })
    component.UIElement.getFor(btn).margin = ivec2(10, 0)
end
difficultyBtn("Easy", 6)
difficultyBtn("Medium", 9)
difficultyBtn("Hell", 12)

applyTemplate(createChild(bottomTextCont), "Text", {
    text = "\n\n      Version 1.0 (C) 2021",
    color = colors.text
})

endScreenTransition("textures/screen_transition0", "shaders/screen_transition/cutoff_texture")
loadOrCreateLevel("assets/levels/title_screen.lvl")

