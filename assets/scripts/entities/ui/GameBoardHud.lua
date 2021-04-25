
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
    applyTemplate(pauseButton, "Button", {
        text = "Pause",
        action = nil
    })
    component.UIElement.getFor(pauseButton).startOnNewLine = true
    component.UIElement.getFor(pauseButton).renderOffset.x = -69


    local scoreText = createChild(hud, "scoreText")

    setComponents(scoreText, {
        UIElement(),
        TextView {
            text = "Score:",
            fontSprite = "sprites/ui/default_font"
        }
    })

    _G.updateHudScore = function(score)
        component.TextView.getFor(scoreText).text = "Score: "..score
    end

    local boardWidth = 9

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
    for y = 1, 2 do
        for x = 1, boardWidth do
            local mark = createChild(marksContainer)
            setComponents(mark, {
                UIElement {
                    lineSpacing = 0
                },
                AsepriteView {
                    sprite = "sprites/ui/death_mark",
                    loop = false
                }
            })
            setTimeout(mark, math.random() * 4, function()

                playAsepriteTag(component.AsepriteView.getFor(mark), "mark", true)
            end)
        end
    end
end
