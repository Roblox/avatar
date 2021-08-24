local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Common.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local Constants = require(Modules.NotLApp.Constants)
local FitChildren = require(Modules.NotLApp.FitChildren)

local FitTextLabel = require(Modules.NotLApp.FitTextLabel)
local LocalizedFitTextLabel = require(Modules.NotLApp.LocalizedFitTextLabel)
local ImageSetLabel = UIBlox.Core.ImageSet.Label

local FitImageTextFrame = Roact.PureComponent:extend("FitImageTextFrame")

local defaultImageProps = {
	ImageColor3 = Constants.Color.GRAY2,
	ImageTransparency = 0,
}

local defaultTextProps = {
	Font = Enum.Font.SourceSans,
	TextColor3 = Constants.Color.GRAY2,
	TextTransparency = 0,
	useLocalizedText = false,
}

FitImageTextFrame.defaultProps = {
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 0, 1, 0),
	LayoutOrder = 1,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	padding = 0,
	imageProps = defaultImageProps,
	textProps = defaultTextProps,
}

function FitImageTextFrame:render()
	local position = self.props.Position
	local size = self.props.Size
	local layoutOrder = self.props.LayoutOrder
	local verticalAlignment = self.props.VerticalAlignment
	local padding = self.props.padding
	local imageProps = self.props.imageProps
	local textProps = self.props.textProps

	return Roact.createElement(FitChildren.FitFrame, {
		Position = position,
		Size = size,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = layoutOrder,

		fitAxis = FitChildren.FitAxis.Width,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = verticalAlignment,
			Padding = UDim.new(0, padding),
		}),
		Image = Roact.createElement(ImageSetLabel, {
			LayoutOrder = 1,
			Size = imageProps.Size,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = imageProps.Image,
			ImageColor3 = imageProps.ImageColor3,
			ImageTransparency = imageProps.ImageTransparency,
		}),
		Text = Roact.createElement(textProps.useLocalizedText and LocalizedFitTextLabel or FitTextLabel, {
			LayoutOrder = 2,
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = textProps.Font,
			Text = textProps.Text,
			TextSize = textProps.TextSize,
			TextColor3 = textProps.TextColor3,
			TextTransparency = textProps.TextTransparency,

			fitAxis = FitChildren.FitAxis.Width,
		}),
	})
end

return FitImageTextFrame