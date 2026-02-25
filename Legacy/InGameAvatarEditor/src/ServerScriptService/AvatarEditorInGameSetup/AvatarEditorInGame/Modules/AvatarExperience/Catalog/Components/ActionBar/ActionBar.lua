--[[
	Creates a Roact Component which includes a generic button and a generic "more" button
	within a frame with a gradient

	Props:
		buttonProps: (table) Includes information needed for ActionButton
		bottomPadding: (number) Adds padding between the ActionButton and ActionBar frame from the bottom
		leftPadding : (number) Adds padding between the ActionButton and ActionBar frame from the left
		rightPadding : (number) Adds padding between the ActionButton and ActionBar frame from the right
		ZIndex: (number) Used to set the zindex of the entire component
		showMoreButton: (boolean) Whether or not you want to include the generic "more" button in the frame
	buttonProps:
		buttonText = (string) What text should appear on the ActionButton,
		buttonIcon = (string) What Icon should appear on the ActionButton,
		buttonIconPadding = (number) padding between text and icon,
		buttonIconSize = (number) size of the icon,
		buttonIsDisabled = (boolean) whether or not the ActionButton is disabled,
		buttonIsLoading = (boolean) whether or not the ActionButton is loading,
		buttonColor = (Color3) color of the ActionButton,
		onActivated = (callback) function that is called when the ActionButton is pressed,
]]

local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local t = require(Modules.Packages.t)

local withStyle = UIBlox.Style.withStyle
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local ActionButton = require(Modules.AvatarExperience.Catalog.Components.ActionBar.ActionButton)
local ItemDetailMoreButton = require(Modules.AvatarExperience.Catalog.Components.ActionBar.ItemDetailMoreButton)

local ACTION_BAR_HEIGHT = CatalogConstants.ActionBar.ActionBarHeight
local GRADIENT_HEIGHT = CatalogConstants.ActionBar.ActionBarGradientHeight

local MORE_BUTTON_WIDTH = ACTION_BAR_HEIGHT
local MORE_BUTTON_ACTION_BUTTON_GAP = 10

local GRADIENT_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/gradient_0_100.png"

local ActionBar = Roact.PureComponent:extend("ActionBar")

local PropTypes = t.strictInterface({
	buttonProps =  t.table,
	bottomPadding = t.number,
	leftPadding = t.number,
	rightPadding = t.number,
	ZIndex = t.number,
	showMoreButton = t.boolean,
	onMoreButtonActivated = t.optional(t.callback),
	onMoreButtonUnmount = t.optional(t.callback),
})

function ActionBar:renderWithStyle(stylePalette)
	assert(PropTypes(self.props))
	local zIndex = self.props.ZIndex
	local leftPadding = self.props.leftPadding
	local rightPadding = self.props.rightPadding
	local bottomPadding = self.props.bottomPadding
	local showMoreButton = self.props.showMoreButton
	local onMoreButtonActivated = self.props.onMoreButtonActivated
	local onMoreButtonUnmount = self.props.onMoreButtonUnmount
	local buttonProps = self.props.buttonProps

	local moreButtonWidth = showMoreButton and MORE_BUTTON_WIDTH or 0
	local moreButtonActionButtonGap = showMoreButton and MORE_BUTTON_ACTION_BUTTON_GAP or 0

	local actionBarHeightWithPadding = ACTION_BAR_HEIGHT + bottomPadding
	local totalHeight = actionBarHeightWithPadding + GRADIENT_HEIGHT

	local theme = stylePalette.Theme
	local font = stylePalette.Font

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, totalHeight),
		BackgroundTransparency = 1,
		ZIndex = zIndex,
	}, {
		ActionBar = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, actionBarHeightWithPadding),
			Position = UDim2.new(0, 0, 1, -actionBarHeightWithPadding),
			BackgroundColor3 = theme.BackgroundDefault.Color,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, moreButtonActionButtonGap),
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, leftPadding),
				PaddingRight = UDim.new(0, rightPadding),
				PaddingBottom = UDim.new(0, bottomPadding),
			}),
			MoreButton = showMoreButton and Roact.createElement(ItemDetailMoreButton, {
				LayoutOrder = 1,
				leftPadding = leftPadding,
				rightPadding = leftPadding,
				onActivated = onMoreButtonActivated,
				onUnmount = onMoreButtonUnmount,
			}),
			ActionButton = Roact.createElement(ActionButton, {
				Size = UDim2.new(1, - moreButtonWidth - moreButtonActionButtonGap, 1, 0),
				LayoutOrder = 2,
				Font = font,
				buttonProps = buttonProps,
			}),
		}),
		Gradient = Roact.createElement("ImageLabel", {
			Size = UDim2.new(1, 0, 0, GRADIENT_HEIGHT),
			Position = UDim2.new(0, 0, 1, -actionBarHeightWithPadding),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Image = GRADIENT_IMAGE,
			ImageColor3 = theme.BackgroundDefault.Color,
		})
	})
end

function ActionBar:render()
    return withStyle(function(stylePalette)
        return self:renderWithStyle(stylePalette)
    end)
end

return ActionBar
