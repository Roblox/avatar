local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local Images = UIBlox.App.ImageSet.Images
local ImageSetLabel = UIBlox.Core.ImageSet.Label
local withStyle = UIBlox.Style.withStyle

local FFlagUIGradientEnabled = true

local PADDING = 10
local ICON_SIZE = 48
local INITIAL_OVERLAY_TRANSPARENCY = 0.25

local PageButton = Roact.PureComponent:extend("PageButton")

PageButton.defaultProps = {
	transparencyModifier = 0,
}

function PageButton:render()
	local size = self.props.Size

	local backgroundImage = self.props.backgroundImage
	local icon = self.props.icon
	local text = self.props.text
	local transparencyModifier = self.props.transparencyModifier

	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme
		local font = stylePalette.Font
		local textHeight = font.BaseSize * font.Header1.RelativeSize

		local overlayFrameTransparency = theme.Overlay.Transparency + (1 - theme.Overlay.Transparency) * transparencyModifier
		if FFlagUIGradientEnabled then
			overlayFrameTransparency = transparencyModifier
		end

		return Roact.createElement("ImageButton", {
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = size,

			[Roact.Event.Activated] = self.props.onActivated,
		}, {
			BackgroundImage = Roact.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = backgroundImage,
				ImageTransparency = transparencyModifier,
				Position = UDim2.new(0.5, 0, 0.5),
				Size = UDim2.new(1, 0, 1, 0),
				ScaleType = Enum.ScaleType.Crop,
				ZIndex = 1,
			}),

			Thumbnail = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 2,
			}, self.props[Roact.Children]),

			Overlay = Roact.createElement("Frame", {
				BackgroundTransparency = overlayFrameTransparency,
				BackgroundColor3 = theme.Overlay.Color,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 1, 1, 1),
				ZIndex = 3,
			}, {
				Gradient = FFlagUIGradientEnabled and Roact.createElement("UIGradient", {
					Rotation = 90,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
						ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1.0),
						NumberSequenceKeypoint.new(0.666, INITIAL_OVERLAY_TRANSPARENCY),
						NumberSequenceKeypoint.new(1, INITIAL_OVERLAY_TRANSPARENCY)
					}),
				})
			}),

			Foreground = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, 0, 2 / 3, 0),
				ZIndex = 4,
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, PADDING),
				}),

				Icon = Roact.createElement(ImageSetLabel, {
					BackgroundTransparency = 1,
					Image = Images[icon],
					ImageTransparency = transparencyModifier,
					LayoutOrder = 1,
					Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
				}),

				Text = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, textHeight),
					Font = font.Header1.Font,
					Text = text,
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = textHeight,
					TextTransparency = transparencyModifier,
				}),
			}),
		})
	end)
end

return PageButton