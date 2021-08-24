local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local AnimatedItem = require(Modules.NotLApp.Generic.AnimatedItem)
local ImageSetLabel = UIBlox.Core.ImageSet.Label
local withStyle = UIBlox.Style.withStyle
local Images = UIBlox.App.ImageSet.Images

local TRIANGLE_IMAGE = Images["component_assets/triangleUp_16"]

local NavHighlight = Roact.PureComponent:extend("NavHighlight")

local ANIMATION_SPRING_SETTINGS = {
	dampingRatio = 1,
	frequency = 3.5,
}

local PADDING = 15

local ARROW_SIZE = Vector2.new(20, 8)

function NavHighlight:render()
    local selectedCategory = self.props.selectedCategory
    local categoryButton = self.props.categoryButtonRefs[selectedCategory]
    local useArrowHighlight = self.props.useArrowHighlight

    if not categoryButton then
        return
    end

    local width = 0
    local position = 0
    if categoryButton.current then
        width = categoryButton.current.AbsoluteSize.X - PADDING
        position = categoryButton.current.AbsolutePosition.X + PADDING / 2

        local scrollingFrameRef = self.props.scrollingFrameRef
        if scrollingFrameRef.current then
            position = position +
                scrollingFrameRef.current.CanvasPosition.X - scrollingFrameRef.current.AbsolutePosition.X
        end
    end

    return withStyle(function(stylePalette)
        local theme = stylePalette.Theme

        return Roact.createElement(AnimatedItem.AnimatedFrame, {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundTransparency = 1,
            animatedProps = {
                [AnimatedItem.AnimatedProp.Size.Offset.X] = width,
                [AnimatedItem.AnimatedProp.Position.Offset.X] = position,
            },
            springOptions = ANIMATION_SPRING_SETTINGS,
        }, {
            Highlight = not useArrowHighlight and Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 3),
                BorderSizePixel = 0,
                BackgroundColor3 = theme.IconEmphasis.Color,
                BackgroundTransparency = theme.IconEmphasis.Transparency,
            }),

            ArrowHighlight = useArrowHighlight and Roact.createElement(ImageSetLabel, {
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 1, 0),
                Size = UDim2.new(0, ARROW_SIZE.X, 0, ARROW_SIZE.Y),
                Image = TRIANGLE_IMAGE,
                ImageColor3 = theme.BackgroundContrast.Color,
                ImageTransparency = theme.BackgroundContrast.Transparency,
            }),
        })
    end)
end

return NavHighlight
