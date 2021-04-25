
function create(btn)

    setName(btn, "music button")


    local icon = createChild(btn)
    setComponents(icon, {
        UIElement {
            renderOffset = ivec2(-6, 1)
        },
        AsepriteView {
            sprite = "sprites/ui/music_icon",
            frame = _G.musicEnabled and 0 or 1
        }
    })

    function enableOrDisableMusic()
        if _G.musicEnabled then
            setComponents(btn, {
                SoundSpeaker {
                    looping = true,
                    volume = .4,
                    sound = "awful_song"
                }
            })
        else
            component.SoundSpeaker.remove(btn)
        end
    end

    applyTemplate(btn, "Button", {
        text = "",
        action = function()
            _G.musicEnabled = not _G.musicEnabled
            component.AsepriteView.getFor(icon).frame = _G.musicEnabled and 0 or 1
            enableOrDisableMusic()
        end
    })
    local uiElement = component.UIElement.getFor(btn)
    uiElement.renderOffset = ivec2(10, 22)
    uiElement.absolutePositioning = true
    uiElement.absoluteVerticalAlign = 2
    component.UIContainer.getFor(btn).fixedWidth = 23
    component.UIContainer.getFor(btn).fixedHeight = 25
    component.UIContainer.getFor(btn).autoWidth = false


    enableOrDisableMusic()
end
