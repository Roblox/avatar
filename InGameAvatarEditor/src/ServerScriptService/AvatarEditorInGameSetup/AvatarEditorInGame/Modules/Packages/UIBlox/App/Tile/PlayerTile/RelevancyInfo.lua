local App = script:FindFirstAncestor("App")
local UIBlox = App.Parent
local Core = UIBlox.Core
local Packages = UIBlox.Parent

local t = require(Packages.t)
local Roact = require(Packages.Roact)

local ControlState = require(Core.Control.Enum.ControlState)
local GenericTextLabel = require(Core.Text.GenericTextLabel.GenericTextLabel)
local withStyle = require(Core.Style.withStyle)
local getContentStyle = require(Core.Button.getContentStyle)
local getIconSize = require(App.ImageSet.getIconSize)
local ImageSetComponent = require(UIBlox.Core.ImageSet.ImageSetComponent)
local IconSize = require(App.ImageSet.Enum.IconSize)

local RelevancyInfo = Roact.PureComponent:extend("RelevancyInfo")

local SECONDARY_CONTENT_STATE_COLOR = {
	[ControlState.Default] = "IconDefault",
	[ControlState.Hover] = "IconOnHover",
}

local EMPHASIS_CONTENT_STATE_COLOR = {
	[ControlState.Default] = "TextEmphasis",
}

local RELEVANCY_ICON_SIZE = getIconSize(IconSize.Small)
local RELEVANCY_TEXT_HEIGHT = 28

RelevancyInfo.validateProps = t.strictInterface({
	text = t.optional(t.string),
	icon = t.optional(t.union(t.string, t.table)),
	onActivated = t.optional(t.callback),
	tileSize = t.optional(t.UDim2),
})

RelevancyInfo.defaultProps = {
	text = "",
	icon = nil,
	tileSize = UDim2.fromOffset(150, 150),
}

local activatedStyle = function(onActivated, emphasisContentStyle, secondaryContentStyle)
	return onActivated and emphasisContentStyle or secondaryContentStyle
end

function RelevancyInfo:render()
	local currentState = self.state.controlState
	local text = self.props.text
	local icon = self.props.icon
	local onActivated = self.props.onActivated
	local tileSize = self.props.tileSize


	return withStyle(function(style)
		local emphasisContentStyle = getContentStyle(EMPHASIS_CONTENT_STATE_COLOR, currentState, style)
		local secondaryContentStyle = getContentStyle(SECONDARY_CONTENT_STATE_COLOR, currentState, style)
		local fontStyle = style.Font.CaptionHeader
		return Roact.createElement("ImageButton", {
			Size = UDim2.new(1, 0, 0, RELEVANCY_TEXT_HEIGHT),
			BackgroundTransparency = 1,
			Active = onActivated and true or false,
			[Roact.Event.Activated] = onActivated
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5),
			}),
			Icon = icon and Roact.createElement(ImageSetComponent.Label, {
				Size = UDim2.new(0, RELEVANCY_ICON_SIZE, 0, RELEVANCY_ICON_SIZE),
				BackgroundTransparency = 1,
				Image = icon,
				ImageColor3 = activatedStyle(onActivated, emphasisContentStyle, secondaryContentStyle).Color,
				ImageTransparency = activatedStyle(onActivated, emphasisContentStyle, secondaryContentStyle).Transparency,
				LayoutOrder = 1,
			}),
			Text = text and Roact.createElement(GenericTextLabel, {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 1),
				Size = UDim2.new(1, 0, 1, 0),
				Text = text,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				fontStyle = fontStyle,
				colorStyle = onActivated and emphasisContentStyle or secondaryContentStyle,
				LayoutOrder = 2,
				TextTruncate = Enum.TextTruncate.AtEnd,
			},{
				UISizeConstraint = Roact.createElement("UISizeConstraint", {
					MaxSize = Vector2.new(tileSize.X.Offset - RELEVANCY_ICON_SIZE, math.huge),
				}),
			}),
		})
	end)
end

return RelevancyInfo
