
defaultArgs({
    goBack = nil,
    okText = "  OK  "
})

function create(con, args)

    setName(con, "HowToPlayContainer")

    setComponents(con, {
        UIElement {
            absolutePositioning = true,
            absoluteHorizontalAlign = 1
        },
        UIContainer {
            nineSliceSprite = "sprites/ui/howtoplay_9slice",

            fixedWidth = 280,
            fillRemainingParentHeight = true
        }
    })
    applyTemplate(createChild(con), "Text", {
        text = "How to play:\n"
    })
    applyTemplate(createChild(con), "Text", {
        text = "Clear the blocks from the lines before\nthey disappear at the top!\nWhen all 'death' marks are checked, the\ngame will be over!\n\n",
        color = colors.text
    })
    function showKey(codeName, name)
        applyTemplate(createChild(con), "Text", {
            text = "["..gameSettings.keyInput[codeName]:getName().."] ",
        })
        applyTemplate(createChild(con), "Text", {
            text = name,
            color = colors.text
        })
    end
    showKey("moveRight", "Right ")
    showKey("moveLeft", "Left\n")
    showKey("softDrop", "Down\n")
    showKey("rotateRight", "Rotate right\n")
    showKey("rotateLeft", "Rotate left\n")
    showKey("place", "Place\n")
    showKey("hold", "Hold stone\n")

    local okClicked = false
    applyTemplate(createChild(con), "Button", {
        text = args.okText,
        action = function()
            okClicked = true
            component.UIElement.animate(con, "renderOffset", ivec2(-1000, 0), .5, "pow2Out") -- TODO: segfault when destroying con and button. Seems like button events keep triggering
            if okClicked and args.goBack then
                args.goBack()
            end
        end
    })

end