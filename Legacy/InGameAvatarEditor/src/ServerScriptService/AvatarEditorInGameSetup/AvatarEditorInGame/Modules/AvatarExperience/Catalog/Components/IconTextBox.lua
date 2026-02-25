local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local ImageSetLabel = UIBlox.Core.ImageSet.Label

local BUTTON_STROKE_IMAGE = "rbxasset://textures/ui/LuaDiscussions/buttonStroke.png"
local BACKGROUND_9S_CENTER = Rect.new(7, 8, 7, 8)

local IconTextBox = Roact.PureComponent:extend("IconTextBox")

IconTextBox.defaultProps = {
	LayoutOrder = 0,
	imagePadding = 6,
}

function IconTextBox:render()

	return UIBlox.Style.withStyle(function(style)
        local font = style.Font
		local theme = style.Theme

		local image = self.props.Image
		local imagePadding = self.props.imagePadding
		local layoutOrder = self.props.LayoutOrder
		local placeholderText = self.props.PlaceholderText
		local textSize = font.BaseSize * font.Body.RelativeSize
		local iconTotalWidth = textSize + imagePadding * 2

        return Roact.createElement("ImageLabel", {
			ImageRectSize = Vector2.new(0, 0),
            BackgroundTransparency = 1,
            Image = BUTTON_STROKE_IMAGE,
            ImageColor3 = theme.UIDefault.Color,
            ImageRectOffset = Vector2.new(0, 0),
            LayoutOrder = layoutOrder,
            ScaleType = Enum.ScaleType.Slice,
            Size = UDim2.new(1, 0, 0, 30),
            SliceCenter = BACKGROUND_9S_CENTER,
        }, {
			IconImage = Roact.createElement(ImageSetLabel, {
				AnchorPoint = Vector2.new(0, 0.5),
				LayoutOrder = 1,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, imagePadding, 0.5, 0),
				Size = UDim2.new(0, textSize, 0, textSize),
				Image = image,
				ImageColor3 = theme.TextDefault.Color,
				ImageTransparency = theme.TextDefault.Transparency,
			}),
            Textbox = Roact.createElement("TextBox", {
                BackgroundTransparency = 1,
                ClearTextOnFocus = false,
                Font = font.Header2.Font,
                FontSize = font.BaseSize * font.CaptionBody.RelativeSize,
                PlaceholderText = placeholderText,
                PlaceholderColor3 = theme.PlaceHolder.Color,
                Position = UDim2.new(0, iconTotalWidth, 0, 0),
				Size = UDim2.new(1, -iconTotalWidth, 1, 0),
				TextInputType = self.props.TextInputType,
				Text = "",
                TextColor3 = theme.TextDefault.Color,
                TextSize = textSize,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                --OverlayNativeInput = true,
				[Roact.Change.Text] = self.props[Roact.Change.Text],
            })
        })
	end)
end

return IconTextBox
