local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Common.Roact)
local Text = require(Modules.Common.Text)

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local ImageSetLabel = UIBlox.Core.ImageSet.Label

local NUMBER_FONT_SIZE = 42
local NUMBER_PADDING_TOP = -7
local NUMBER_PADDING_BOTTOM = -7
local LABEL_FONT_SIZE = 18
local ICON_SIZE = 44
local ICON_TEXT_PADDING = 10
local LEFT_PADDING = 10
local RIGHT_PADDING = 10
local TOTAL_HEIGHT = math.max(ICON_SIZE,
	NUMBER_FONT_SIZE + LABEL_FONT_SIZE + NUMBER_PADDING_TOP + NUMBER_PADDING_BOTTOM)
local NON_TEXT_WIDTH = ICON_SIZE + ICON_TEXT_PADDING + LEFT_PADDING + RIGHT_PADDING

local PrimaryStatWidget = Roact.PureComponent:extend("PrimaryStatWidget")

PrimaryStatWidget.defaultProps = {
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.new(0, 0, 0, 0),
}

function PrimaryStatWidget.GetMinimumWidth(number, label, font)
	local numberTextWidth = Text.GetTextWidth(number, font, NUMBER_FONT_SIZE)
	local labelTextWidth = Text.GetTextWidth(label, font, LABEL_FONT_SIZE)
	local textWidth = math.max(numberTextWidth, labelTextWidth)
	local totalWidth = textWidth + NON_TEXT_WIDTH

	return totalWidth
end

function PrimaryStatWidget.GetMinimumWidthRethemed(number, label, style)
	local numberTextWidth = Text.GetTextWidth(number,
		style.Font.Title.Font, style.Font.BaseSize * style.Font.Title.RelativeSize)
	local labelTextWidth = Text.GetTextWidth(label,
		style.Font.CaptionHeader.Font, style.Font.BaseSize * style.Font.CaptionHeader.RelativeSize)
	local textWidth = math.max(numberTextWidth, labelTextWidth)
	local totalWidth = textWidth + NON_TEXT_WIDTH

	return totalWidth
end

function PrimaryStatWidget:render()
	local icon = self.props.icon
	local number = self.props.number
	local label = self.props.label
	local font = self.props.font
	local color = self.props.color
	local width = self.props.width
	local layoutOrder = self.props.LayoutOrder
	local anchorPoint = self.props.AnchorPoint
	local position = self.props.Position
	local withNewThemeProvider = self.props.withNewThemeProvider

	local textWidth = width - NON_TEXT_WIDTH

	return withStyle(function(style)
		return Roact.createElement("Frame", {
			AnchorPoint = anchorPoint,
			Position = position,
			Size = UDim2.new(0, width, 0, TOTAL_HEIGHT),
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, ICON_TEXT_PADDING),
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, LEFT_PADDING),
				PaddingRight = UDim.new(0, RIGHT_PADDING),
			}),
			Icon = withNewThemeProvider and Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
				Image = icon,
				ImageColor3 = style.Theme.IconEmphasis.Color,
				ImageTransparency = style.Theme.IconEmphasis.Transparency,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}) or Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE),
				Image = icon,
				ImageColor3 = color,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}),
			TextSection = Roact.createElement("Frame", {
				Size = UDim2.new(0, textWidth, 1, 0),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			}, {
				Number = withNewThemeProvider and Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, NUMBER_FONT_SIZE),
					Position = UDim2.new(0, 0, 0, NUMBER_PADDING_TOP),
					Text = number,
					Font = style.Font.Title.Font,
					TextSize = style.Font.BaseSize * style.Font.Title.RelativeSize,
					TextColor3 = style.Theme.TextEmphasis.Color,
					TextTransparency = style.Theme.TextEmphasis.Transparency,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					BackgroundTransparency = 1,
				}) or Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, NUMBER_FONT_SIZE),
					Position = UDim2.new(0, 0, 0, NUMBER_PADDING_TOP),
					Text = number,
					Font = font,
					TextSize = NUMBER_FONT_SIZE,
					TextColor3 = color,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					BackgroundTransparency = 1,
				}),
				Label = withNewThemeProvider and Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, LABEL_FONT_SIZE),
					Position = UDim2.new(0, 0, 0, NUMBER_FONT_SIZE + NUMBER_PADDING_TOP + NUMBER_PADDING_BOTTOM),
					Text = label,
					Font = style.Font.CaptionHeader.Font,
					TextSize =  style.Font.BaseSize * style.Font.CaptionHeader.RelativeSize,
					TextColor3 = style.Theme.TextEmphasis.Color,
					TextTransparency = style.Theme.TextEmphasis.Transparency,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					BackgroundTransparency = 1,
				}) or Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, LABEL_FONT_SIZE),
					Position = UDim2.new(0, 0, 0, NUMBER_FONT_SIZE + NUMBER_PADDING_TOP + NUMBER_PADDING_BOTTOM),
					Text = label,
					Font = font,
					TextSize = LABEL_FONT_SIZE,
					TextColor3 = color,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextScaled = true,
					BackgroundTransparency = 1,
				}),
			}),
		})
	end)
end

return PrimaryStatWidget