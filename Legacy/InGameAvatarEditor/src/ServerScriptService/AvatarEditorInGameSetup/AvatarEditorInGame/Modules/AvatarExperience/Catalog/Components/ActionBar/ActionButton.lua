local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local withStyle = UIBlox.Style.withStyle

local FitChildren = require(Modules.NotLApp.FitChildren)
local FitTextLabel = require(Modules.NotLApp.FitTextLabel)
local ImageSetButton = UIBlox.Core.ImageSet.Button
local ImageSetLabel = UIBlox.Core.ImageSet.Label
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local ShimmerAnimation = require(Modules.NotLApp.ShimmerAnimation)

local Images = UIBlox.App.ImageSet.Images

local BACKGROUND_IMAGE_9_SLICE = Images["component_assets/circle_17"]

local ActionButton = Roact.PureComponent:extend("ActionButton")

function ActionButton:init()
	self.state = {
		isButtonPressed = false,
	}

	self.onInputBegan = function()
		self:setState({
			isButtonPressed = true
		})
	end

	self.onInputEnded = function()
		self:setState({
			isButtonPressed = false
		})
	end
end

function ActionButton:renderWithStyle(stylePalette)
	local size = self.props.Size
	local position = self.props.Position
	local layoutOrder = self.props.LayoutOrder
	local font = self.props.Font
	local buttonProps = self.props.buttonProps
	local isButtonPressed = self.state.isButtonPressed

	local theme = stylePalette.Theme

	local buttonTransparency = 0
	if buttonProps.buttonIsDisabled then
		buttonTransparency = CatalogConstants.ActionBar.DisabledButtonTransparency
	elseif isButtonPressed then
		buttonTransparency = theme.Overlay.Transparency
	end

	local childElement
	if buttonProps.buttonIsLoading then
		childElement = Roact.createElement(ShimmerAnimation, {
			Size = UDim2.new(1, 0, 2, 0),
			Position = UDim2.new(0, 0, 0, 0),
			shimmerSpeed = 1.5,
		})
	else
		childElement = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, buttonProps.buttonIconPadding),
			}),
			Icon = buttonProps.buttonIcon and Roact.createElement(ImageSetLabel, {
				Size = UDim2.new(0, buttonProps.buttonIconSize, 0, buttonProps.buttonIconSize),
				BackgroundTransparency = 1,
				Image = buttonProps.buttonIcon,
				ImageTransparency = buttonTransparency,
				ImageColor3 = theme.ContextualPrimaryContent.Color,
				LayoutOrder = 1,
			}),
			Text = Roact.createElement(FitTextLabel, {
				Size = UDim2.new(0, 0, 0, font.BaseSize * font.Header1.RelativeSize),
				BackgroundTransparency = 1,
				Text = buttonProps.buttonText or "",
				Font = font.Header1.Font,
				TextSize = font.BaseSize * font.Header1.RelativeSize,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextWrapped = false,
				TextColor3 = theme.ContextualPrimaryContent.Color,
				TextTransparency = buttonTransparency,
				LayoutOrder = 2,
				fitAxis = FitChildren.FitAxis.Width,
			})
		})
	end

	return Roact.createElement(ImageSetButton, {
		Size = size,
		Position = position,
		LayoutOrder = layoutOrder,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Image = BACKGROUND_IMAGE_9_SLICE,
		ImageColor3 = buttonProps.buttonColor,
		ImageTransparency = buttonTransparency,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(8, 8, 9, 9),
		ClipsDescendants = true,
		[Roact.Event.InputBegan] = self.onInputBegan,
		[Roact.Event.InputEnded] = self.onInputEnded,
		[Roact.Event.Activated] = function()
			if not buttonProps.buttonIsLoading then
				buttonProps.onActivated()
			end
		 end,
	}, {
		ButtonInfo = childElement,
	})
end

function ActionButton:render()
    return withStyle(function(stylePalette)
        return self:renderWithStyle(stylePalette)
    end)
end

return ActionButton
