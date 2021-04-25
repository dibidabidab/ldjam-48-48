
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

    function createTag(name, i)
        local tag = createEntity()
        setName(tag, "tag"..i)
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

end
