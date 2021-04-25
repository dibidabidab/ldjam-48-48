
_G.hudScreen = currentEngine

onEvent("BeforeDelete", function()
    loadOrCreateLevel(nil)
    if _G.hudScreen == currentEngine then
        _G.hudScreen = nil
    end
end)

if _G.levelToLoad == nil then
    error("_G.levelToLoad is nil")
end

_G.retryLevel = function()
    closeActiveScreen()
    openScreen("scripts/ui_screens/LevelScreen")
end

local levelRestarter = createEntity()
listenToKey(levelRestarter, gameSettings.keyInput.retryLevel, "retry_key")
onEntityEvent(levelRestarter, "retry_key_pressed", retryLevel)

applyTemplate(createEntity(), "GameBoardHud")

loadOrCreateLevel(_G.levelToLoad)
