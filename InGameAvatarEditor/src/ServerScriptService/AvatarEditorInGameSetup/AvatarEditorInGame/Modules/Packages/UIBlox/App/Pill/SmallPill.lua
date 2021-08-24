local Pill = script.Parent
local App = Pill.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)
local Cryo = require(Packages.Cryo)
local t = require(Packages.t)

local Images = require(App.ImageSet.Images)
local CursorKind = require(App.SelectionImage.CursorKind)
local withSelectionCursorProvider = require(App.SelectionImage.withSelectionCursorProvider)
local ImageSetComponent = require(UIBlox.Core.ImageSet.ImageSetComponent)
local ControlState = require(UIBlox.Core.Control.Enum.ControlState)
local GenericButton = require(UIBlox.Core.Button.GenericButton)
local GenericTextLabel = require(UIBlox.Core.Text.GenericTextLabel.GenericTextLabel)
local GetTextSize = require(UIBlox.Core.Text.GetTextSize)

local withStyle = require(UIBlox.Core.Style.withStyle)
local getContentStyle = require(Pill.getContentStyle)

local HEIGHT = 28
local PADDING = 12

local BUTTON_STATE_COLOR = {
	[ControlState.Default] = "SecondaryDefault",
	[ControlState.Hover] = "SecondaryOnHover",
}

local SELECTED_BUTTON_STATE_COLOR = {
	[ControlState.Default] = "BackgroundOnHover",
}

local CONTENT_STATE_COLOR = {
	[ControlState.Default] = "TextMuted",
	[ControlState.Hover] = "TextEmphasis",
}

local SELECTED_CONTENT_STATE_COLOR = {
	[ControlState.Default] = "TextEmphasis",
}

local SmallPill = Roact.PureComponent:extend("SmallPill")

SmallPill.validateProps = t.strictInterface({
	-- Position in an ordered layout
	layoutOrder = t.optional(t.number),
	-- Text shown in the Pill
	text = t.optional(t.string),
	-- Flag that indicates that the Pill is selected (background is filled)
	isSelected = t.optional(t.boolean),
	-- Flag that indicates that the Pill is still loading
	isLoading = t.optional(t.boolean),
	-- Flag that indicates that the Pill is disabled
	isDisabled = t.optional(t.boolean),
	-- BackgroundColor (used for the loading animation)
	backgroundColor = t.optional(t.Color3),
	-- Callback function when the Pill is clicked
	onActivated = t.callback,

	-- optional parameters for RoactGamepad
	NextSelectionLeft = t.optional(t.table),
	NextSelectionRight = t.optional(t.table),
	NextSelectionUp = t.optional(t.table),
	NextSelectionDown = t.optional(t.table),
	controlRef = t.optional(t.table),
})

SmallPill.defaultProps = {
	layoutOrder = 1,
	text = "",
	isSelected = false,
	isLoading = false,
	isDisabled = false,
}

function SmallPill:init()
	self.state = {
		controlState = ControlState.Initialize
	}

	self.onStateChanged = function(oldState, newState)
		self:setState({
			controlState = newState,
		})
	end
end

function SmallPill:render()
	local isSelected = self.props.isSelected
	local image = isSelected and Images["component_assets/circle_29"] or Images["component_assets/circle_29_stroke_1"]
	local text = self.props.text

	local buttonColors = isSelected and SELECTED_BUTTON_STATE_COLOR or BUTTON_STATE_COLOR
	local contentColors = isSelected and SELECTED_CONTENT_STATE_COLOR or CONTENT_STATE_COLOR
	local sliceCenter = Rect.new(14, 14, 15, 15)

	return withStyle(function(style)
		return withSelectionCursorProvider(function(getSelectionCursor)
			local theme = style.Theme
			local fontStyle = style.Font.CaptionHeader
			local textSize = fontStyle.RelativeSize * style.Font.BaseSize
			local textWidth = GetTextSize(text, textSize, fontStyle.Font, Vector2.new()).X
			local size = UDim2.new(0, textWidth + PADDING * 2, 0, HEIGHT)

			local currentState = self.state.controlState
			local textStyle = getContentStyle(contentColors, currentState, style)

			return Roact.createElement("Frame", {
				Size = size,
				BackgroundTransparency = 1,
				LayoutOrder = self.props.layoutOrder,
			}, {
				Button = Roact.createElement(GenericButton, {
					Size = size,
					SliceCenter = sliceCenter,
					SelectionImageObject = getSelectionCursor(CursorKind.SmallPill),
					isLoading = self.props.isLoading,
					isDisabled = self.props.isDisabled,
					text = self.props.text,
					onActivated = self.props.onActivated,
					buttonImage = image,
					buttonStateColorMap = buttonColors,
					contentStateColorMap = contentColors,
					onStateChanged = self.onStateChanged,
					NextSelectionLeft = self.props.NextSelectionLeft,
					NextSelectionRight = self.props.NextSelectionRight,
					NextSelectionUp = self.props.NextSelectionUp,
					NextSelectionDown = self.props.NextSelectionDown,
					[Roact.Ref] = self.props.controlRef,
				}, {
					UIListLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, PADDING),
					}),
					Text = Roact.createElement(GenericTextLabel, {
						BackgroundTransparency = 1,
						Text = self.props.text,
						fontStyle = fontStyle,
						colorStyle = textStyle,
						LayoutOrder = 2,
					})
				}),
				Mask = self.props.isLoading and Roact.createElement(ImageSetComponent.Label, {
					BackgroundTransparency = 1,
					Image = Images["component_assets/circle_29_mask"],
					ImageColor3 = self.props.backgroundColor or theme.BackgroundDefault.Color,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = sliceCenter,
					Size = size,
					ZIndex = 3,
				}),
			})
		end)
	end)
end

return Roact.forwardRef(function (props, ref)
	return Roact.createElement(SmallPill, Cryo.Dictionary.join(
		props,
		{controlRef = ref}
	))
end)
