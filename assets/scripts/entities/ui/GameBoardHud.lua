
function create(hud, args)

    setName(hud, "hud")

    setComponents(hud, {
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

    local room = nil
    _G.setRoom = function(r)
        room = r
    end

    function createTag(name, i)
        local tag = createEntity()
        setComponents(tag, {
            UIElement {
                absolutePositioning = true,
                renderOffset = ivec2(-100)
            },
            AsepriteView {
                sprite = "sprites/ui/next_hold",
                frame = i
            }
        })
        setUpdateFunction(tag, .2, function()

            if room[name] == nil then
                return
            end
            local screenPos = room.project(room.component.Transform.getFor(room[name]).position)
            if screenPos then
                screenPos = screenPos / ivec2(gameSettings.graphics.uiPixelScaling)
                screenPos.y = -screenPos.y
                component.UIElement.getFor(tag).renderOffset = screenPos
            end

        end, false) -- false: start directly.
    end

    createTag("nextBlock", 0)
    createTag("holdBlock", 1)

    local retryButton = createChild(hud, "retryButton")
    applyTemplate(retryButton, "Button", {
        text = "Retry",
        action = _G.retryLevel
    })
    component.UIElement.getFor(retryButton).startOnNewLine = true
    component.UIElement.getFor(retryButton).renderOffset.x = -69

    local pauseButton = createChild(hud, "pauseButton")
    local paused = false
    function togglePause()
        if not paused then
            room.setPaused(true)
            paused = true

            local howToPlay = createEntity()
            applyTemplate(howToPlay, "HowToPlay", { goBack = togglePause, okText = "Continue" })

        elseif not room.gameOver then
            room.setPaused(false)
            paused = false
        end
    end
    applyTemplate(pauseButton, "Button", {
        text = "Help ",
        action = function()
            if not paused then
                togglePause()
            end
        end
    })
    component.UIElement.getFor(pauseButton).startOnNewLine = true
    component.UIElement.getFor(pauseButton).renderOffset.x = -69

    local stopButton = createChild(hud, "stopButton")
    applyTemplate(stopButton, "Button", {
        text = "Stop ",
        action = _G.goToMainMenu
    })
    component.UIElement.getFor(stopButton).startOnNewLine = true
    component.UIElement.getFor(stopButton).renderOffset.x = -69

    setComponents(createChild(hud), {
        UIElement {
            renderOffset = ivec2(-69, 0),
            startOnNewLine = true
        },
        TextView {
            text = "\n\n\nScore:",
            fontSprite = "sprites/ui/default_font",
            mapColorFrom = 2,
            mapColorTo = colors.theme0
        }
    })
    local scoreText = createChild(hud, "scoreText")
    setComponents(scoreText, {
        UIElement {
            renderOffset = ivec2(-69, 0),
            startOnNewLine = true
        },
        TextView {
            text = "0",
            fontSprite = "sprites/ui/default_font",
            mapColorFrom = 2,
            mapColorTo = colors.text
        }
    })
    setComponents(createChild(hud), {
        UIElement {
            renderOffset = ivec2(-69, 0),
            startOnNewLine = true
        },
        TextView {
            text = "\nDepth:",
            fontSprite = "sprites/ui/default_font",
            mapColorFrom = 2,
            mapColorTo = colors.theme0
        }
    })
    local depthText = createChild(hud, "depthText")
    setComponents(depthText, {
        UIElement {
            renderOffset = ivec2(-69, 0),
            startOnNewLine = true
        },
        TextView {
            text = "",
            fontSprite = "sprites/ui/default_font",
            mapColorFrom = 2,
            mapColorTo = colors.text
        }
    })

    _G.updateHudScore = function(score, depth)
        component.TextView.getFor(scoreText).text = ""..score
        component.TextView.getFor(depthText).text = ""..depth
    end

    local boardWidth = _G.boardWidth

    local marksContainer = createChild(hud, "marksContainer")
    setComponents(marksContainer, {
        UIElement {
            absolutePositioning = true,
            absoluteHorizontalAlign = 1,
            renderOffset = ivec2(0, 13)
        },
        UIContainer {
            fixedWidth = boardWidth * 16
        }
    })
    local marks = {}
    for x = 1, boardWidth do
        marks[x - 1] = {}
    end
    for y = 1, 2 do
        for x = 1, boardWidth do
            local mark = createChild(marksContainer)
            marks[x - 1][y - 1] = mark
            setComponents(mark, {
                UIElement {
                    lineSpacing = 0
                },
                AsepriteView {
                    sprite = "sprites/ui/death_mark",
                    loop = false
                }
            })
        end
    end
    _G.mark = function(x, y)
        local mark = marks[x][y]
        setTimeout(mark, x * .02, function()

            playAsepriteTag(component.AsepriteView.getFor(mark), "mark", true)
        end)
    end

    _G.showGameOverPopup = function(score)
        local popup = createEntity()
        setName(popup, "gameover popup")
        setComponents(popup, {
            UIElement {
                absolutePositioning = true,
                absoluteHorizontalAlign = 1,
                absoluteVerticalAlign = 1,
                renderOffset = ivec2(-128, 0)
            },
            UIContainer {
                nineSliceSprite = "sprites/ui/howtoplay_9slice",

                fixedWidth = 120,
                fixedHeight = 120
            }
        })
        applyTemplate(createChild(popup), "Text", {
            text = "GAME OVER!\n",
            waving = true,
            wavingFrequency = .2,
            wavingSpeed = 20,
            wavingAmplitude = 2,
            lineSpacing = 10
        })
        applyTemplate(createChild(popup), "Button", {
            text = "Main menu",
            action = _G.goToMainMenu
        })
    end

    _G.countDown = function()
        -- bla bla TODO
    end

    applyTemplate(createEntity(), "AwfulMusic")
end
