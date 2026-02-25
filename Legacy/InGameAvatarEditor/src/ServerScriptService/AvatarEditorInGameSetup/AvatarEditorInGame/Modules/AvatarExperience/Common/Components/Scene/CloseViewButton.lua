local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local ImageSetButton = UIBlox.Core.ImageSet.Button
local withStyle = UIBlox.Style.withStyle

local Images = UIBlox.App.ImageSet.Images

local CloseViewButton = Roact.PureComponent:extend("CloseViewButton")

local IMAGE = Images["icons/actions/previewShrink"]
local IMAGE_SIZE = Vector2.new(36, 36)
local IMAGE_PADDING = Vector2.new(12, 12)

function CloseViewButton:render()
    return withStyle(function(stylePalette)
        local theme = stylePalette.Theme

        return Roact.createElement(ImageSetButton, {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -IMAGE_PADDING.X, 1, -IMAGE_PADDING.Y),
            Size = UDim2.new(0, IMAGE_SIZE.X, 0, IMAGE_SIZE.Y),
            Image = IMAGE,
            ImageColor3 = theme.IconEmphasis.Color,
            ImageTransparency = theme.IconEmphasis.Transparency,

            [Roact.Event.Activated] = self.props.onActivated,
        })
    end)
end

return CloseViewButton
