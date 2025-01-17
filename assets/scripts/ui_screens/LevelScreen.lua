
_G.hudScreen = currentEngine
_G.titleScreen = false

onEvent("BeforeDelete", function()
    loadOrCreateLevel(nil)
    if _G.hudScreen == currentEngine then
        _G.hudScreen = nil
    end
end)

_G.retryLevel = function()
    if screenTransitionStarted then
        return
    end

    startScreenTransition("textures/screen_transition1", "shaders/screen_transition/cutoff_texture")
    onEvent("ScreenTransitionStartFinished", function()

        closeActiveScreen()
        openScreen("scripts/ui_screens/LevelScreen")
    end)
end
_G.goToMainMenu = function()
    if screenTransitionStarted then
        return
    end

    startScreenTransition("textures/screen_transition0", "shaders/screen_transition/cutoff_texture")
    onEvent("ScreenTransitionStartFinished", function()

        closeActiveScreen()
        openScreen("scripts/ui_screens/StartupScreen")
    end)
end

local levelRestarter = createEntity()
listenToKey(levelRestarter, gameSettings.keyInput.retryLevel, "retry_key")
onEntityEvent(levelRestarter, "retry_key_pressed", retryLevel)

endScreenTransition("textures/screen_transition1", "shaders/screen_transition/cutoff_texture")
applyTemplate(createEntity(), "GameBoardHud")

loadOrCreateLevel("assets/levels/default_level.lvl")
