
_G.hudScreen = currentEngine
_G.titleScreen = false

onEvent("BeforeDelete", function()
    loadOrCreateLevel(nil)
    if _G.hudScreen == currentEngine then
        _G.hudScreen = nil
    end
end)

_G.retryLevel = function()
    closeActiveScreen()
    openScreen("scripts/ui_screens/LevelScreen")
end

local levelRestarter = createEntity()
listenToKey(levelRestarter, gameSettings.keyInput.retryLevel, "retry_key")
onEntityEvent(levelRestarter, "retry_key_pressed", retryLevel)

applyTemplate(createEntity(), "GameBoardHud")

loadOrCreateLevel("assets/levels/default_level.lvl")
