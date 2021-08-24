local App = script:FindFirstAncestor("App")
local UIBlox = App.Parent
local Core = UIBlox.Core
local Packages = UIBlox.Parent

local t = require(Packages.t)
local Roact = require(Packages.Roact)
local Cryo = require(Packages.Cryo)
local Dictionary = Cryo.Dictionary
local List = Cryo.List

local Images = require(App.ImageSet.Images)
local validateImageSetData = require(Core.ImageSet.Validator.validateImageSetData)
local ControlState = require(Core.Control.Enum.ControlState)
local withStyle = require(Core.Style.withStyle)
local getContentStyle = require(Core.Button.getContentStyle)
local PlayerTileButton = require(App.Tile.PlayerTile.PlayerTileButton)
local RelevancyInfo = require(App.Tile.PlayerTile.RelevancyInfo)
local SpringAnimatedItem = require(UIBlox.Utility.SpringAnimatedItem)

local Tile = require(App.Tile.BaseTile.Tile)

local PlayerTile = Roact.PureComponent:extend("PlayerTile")

local imageType = t.union(t.string, validateImageSetData)
PlayerTile.validateProps = t.strictInterface({
	title = t.string,

	subtitle = t.string,

	thumbnail = t.optional(t.union(t.string, t.table)),

	buttons = t.optional(t.array(t.strictInterface({
		icon = t.optional(imageType),
		onActivated = t.optional(t.callback),
		isSecondary = t.optional(t.boolean),
		isDisabled = t.optional(t.boolean),
	}))),

	relevancyInfo = t.optional(t.strictInterface({
		text = t.optional(t.string),
		icon = t.optional(imageType),
		onActivated = t.optional(t.callback),
	})),

	tileSize = t.optional(t.UDim2),

	onActivated = t.optional(t.callback),
	[Roact.Ref] = t.optional(t.table),
})

PlayerTile.defaultProps = {
	buttons = {},
	relevancyInfo = {
		text = "",
		icon = nil,
		onActivated = function() end,
	},
	tileSize = UDim2.new(0, 150, 0, 150),
	onActivated = function() end,
	title = "",
	subtitle = ""
}

local ANIMATION_SPRING_SETTINGS = {
	dampingRatio = 1,
	frequency = 4,
}

local CONTENT_STATE_COLOR = {
	[ControlState.Default] = "SystemPrimaryContent",
}


local VIGNETTE = Images["component_assets/vignette_246"]
local OUTER_BUTTON_PADDING = 10
local BUTTON_HEIGHT = 36

local function footer(props)
	return withStyle(function(style)
		return Roact.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
		}, {
			RelevancyInfo = Roact.createElement(RelevancyInfo, {
				text = props.relevancyInfo.text,
				icon = props.relevancyInfo.icon,
				onActivated = props.relevancyInfo.onActivated,
				tileSize = props.tileSize,
			}),
		})
	end)
end

local function thumbnailOverlayComponents(props)
	return withStyle(function(style)
		local primaryContentStyle = getContentStyle(CONTENT_STATE_COLOR, props.controlState, style)
		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
		}, {
			ButtonBackgroundGradient = not Cryo.isEmpty(props.buttons) and Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, BUTTON_HEIGHT + OUTER_BUTTON_PADDING*2),
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 0, 1, 0),
				LayoutOrder = 1,
			}, {
				UIGradient = Roact.createElement("UIGradient", {
					Rotation = 90,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, style.Theme.BackgroundUIContrast.Color),
						ColorSequenceKeypoint.new(1, style.Theme.BackgroundUIContrast.Color),
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, style.Theme.BackgroundUIContrast.Transparency),
					}),
				}),
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				})
			}),
			HoverTransparency = Roact.createElement(SpringAnimatedItem.AnimatedImageLabel, {
				springOptions = ANIMATION_SPRING_SETTINGS,
				animatedValues = {
					imageTransparency = props.mouseEntered and 0.6 or 1,
				},
				mapValuesToProps = function(values)
					return {
						ImageTransparency = values.imageTransparency,
					}
				end,
				regularProps = {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Image = VIGNETTE.Image,
					ImageRectSize = VIGNETTE.ImageRectSize,
					ImageRectOffset = VIGNETTE.ImageRectOffset,
					ImageColor3 = primaryContentStyle.Color,
					ImageTransparency = 0,
					LayoutOrder = 2,
					[Roact.Event.MouseEnter] = props.hoverMouseEnter,
					[Roact.Event.MouseLeave] = props.hoverMouseLeave,
				},
			}, {
				corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
			}),
			ButtonContainer = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 2,
			}, {
				PlayerTileButtons = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.new(1, 0, 1, 0),
					Size = UDim2.new(0, props.tileSize.X.Offset - (OUTER_BUTTON_PADDING * 2), 0, BUTTON_HEIGHT),
					AnchorPoint = Vector2.new(1, 1),
					LayoutOrder = 3,
					ZIndex = 2,
				}, List.join(List.map(props.buttons, function(button)
					return Roact.createElement(PlayerTileButton, {
						buttonHeight = BUTTON_HEIGHT,
						tileSize = props.tileSize,
						icon = button.icon,
						isSecondary = button.isSecondary,
						isDisabled = button.isDisabled,
						onActivated = button.onActivated,
						mouseEnter = props.hoverMouseEnter,
						mouseLeave = props.hoverMouseLeave,
					})
				end), {
					Roact.createElement("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 10),
						FillDirection = Enum.FillDirection.Horizontal,
					})
				})),
				UIPadding = Roact.createElement("UIPadding", {
					PaddingBottom = UDim.new(0, OUTER_BUTTON_PADDING),
					PaddingRight = UDim.new(0, OUTER_BUTTON_PADDING),
				}),
			}),
		})
	end)
end


function PlayerTile:init()
	self.firstButtonIcon = Roact.createRef()
	self.secondButtonIcon = Roact.createRef()
	self.mouseEntered = false
	self.state = {
		controlState = ControlState.Initialize,
		mouseEntered = false
	}

	self.onStateChanged = function(oldState, newState)
		self:setState({
			controlState = newState,
		})
		if self.props.onStateChanged then
			self.props.onStateChanged(oldState, newState)
		end
	end

	self.hoverMouseEnter = function()
		self:setState({
			mouseEntered = true,
		})
	end

	self.hoverMouseLeave = function()
		self:setState({
			mouseEntered = false,
		})
	end
end

function PlayerTile:render()
	local tileSize = self.props.tileSize
	local title = self.props.title
	local onActivated = self.props.onActivated
	local thumbnail = self.props.thumbnail

	return withStyle(function(style)
		return Roact.createElement("Frame", {
			Size = tileSize,
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			[Roact.Ref] = self.props[Roact.Ref],
		}, {
			Tile = Roact.createElement(Tile, {
				footer = footer(Dictionary.join(self.props, {
					controlState = self.state.controlState,
				})),
				hasRoundedCorners = true,
				innerPadding = OUTER_BUTTON_PADDING,
				name = title,
				subtitle = self.props.subtitle,
				titleTextLineCount = 1,
				onActivated = onActivated,
				thumbnail = thumbnail,
				backgroundImage = Images[style.Theme.PlayerBackgroundDefault.Image],
				thumbnailOverlayComponents = thumbnailOverlayComponents(Dictionary.join(self.props, {
					hoverMouseEnter = self.hoverMouseEnter,
					hoverMouseLeave = self.hoverMouseLeave,
					mouseEntered = self.state.mouseEntered,
				})),
			})
		})
	end)
end

return PlayerTile
