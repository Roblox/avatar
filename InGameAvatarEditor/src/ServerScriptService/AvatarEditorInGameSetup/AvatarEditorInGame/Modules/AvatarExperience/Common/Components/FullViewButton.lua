local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local ImageSetButton = UIBlox.Core.ImageSet.Button
local ImageSetLabel = UIBlox.Core.ImageSet.Label
local SpringAnimatedItem = UIBlox.Utility.SpringAnimatedItem
local withStyle = UIBlox.Style.withStyle
local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)

local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)

local Images = UIBlox.App.ImageSet.Images

local FullViewButton = Roact.PureComponent:extend("FullViewButton")

local MINIMIZE_IMAGE = Images["icons/actions/previewShrink"]
local MINIMIZE_IMAGE_SIZE = Vector2.new(36, 36)

local NAV_HEIGHT = 40
local DROP_SHADOW_SIZE = 14
local EXPAND_IMAGE_PADDING = Vector2.new(20, 20)
local EXPAND_IMAGE_SIZE = Vector2.new(24, 24)
local EXPAND_IMAGE = Images["icons/actions/previewExpand"]

local ANIMATION_SPRING_SETTINGS_UI_EXPAND = {
	dampingRatio = 0.60,
	frequency = 4.25,
}

local ANIMATION_SPRING_SETTINGS_UI_COLLAPSE = {
	dampingRatio = 1,
	frequency = 3.5,
}

local function mapValuesToProps(values)
	return {
		Size = UDim2.new(1, 0, 0, values.height),
	}
end

function FullViewButton:calculateButtonHeight()
	local hasSubcategories = self.props.hasSubcategories
	local isPortrait = self.props.isPortrait
	local isUIFullView = self.props.isUIFullView
	local sceneHeight = self.props.sceneHeight

	local height = sceneHeight

	if isUIFullView and isPortrait then
		height = height + NAV_HEIGHT + EXPAND_IMAGE_SIZE.Y + EXPAND_IMAGE_PADDING.Y + DROP_SHADOW_SIZE
		if hasSubcategories then
			height = height + NAV_HEIGHT
		end
	elseif not isPortrait then
		local extraSpace = EXPAND_IMAGE_SIZE.Y + EXPAND_IMAGE_PADDING.Y + DROP_SHADOW_SIZE
		height = height - extraSpace
	end

	return height
end

function FullViewButton:renderExpandButton(theme)
	return Roact.createElement(ImageSetLabel, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, MINIMIZE_IMAGE_SIZE.X, 0, MINIMIZE_IMAGE_SIZE.Y),
		Image = MINIMIZE_IMAGE,
		ImageColor3 = theme.IconEmphasis.Color,
		ImageTransparency = theme.IconEmphasis.Transparency,
	})
end

function FullViewButton:renderCollapseButton(theme)
	return Roact.createElement(ImageSetLabel, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Image = EXPAND_IMAGE,
		ImageColor3 = theme.IconEmphasis.Color,
		ImageTransparency = theme.IconEmphasis.Transparency,
		Size = UDim2.new(0, -EXPAND_IMAGE_SIZE.X, 0, -EXPAND_IMAGE_SIZE.Y),
		BackgroundTransparency = 1,
	})
end

function FullViewButton:render()
	local topBarHeight = self.props.topBarHeight
	local isUIFullView = self.props.isUIFullView
	local isFullView = self.props.isFullView
	local isPortrait = self.props.isPortrait
	local onActivated = self.props.changeViewFunction
	local height = self:calculateButtonHeight()

	local fullViewImageButton, settings, imageTransparency, imageTransparencyShadow

	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		if not isUIFullView then
			settings = ANIMATION_SPRING_SETTINGS_UI_COLLAPSE
			fullViewImageButton = self:renderExpandButton(theme)
			imageTransparencyShadow = 1
			imageTransparency = 1
		else
			settings = ANIMATION_SPRING_SETTINGS_UI_EXPAND
			fullViewImageButton = self:renderCollapseButton(theme)
			imageTransparencyShadow = theme.DropShadow.Transparency
			imageTransparency = 0
		end

		return Roact.createElement(SpringAnimatedItem.AnimatedFrame, {
			regularProps = {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, 0, 0, topBarHeight),
				Size = UDim2.new(1, 0, 1, 0),
				Visible = (onActivated ~= nil) and (isPortrait or isFullView),
			},

			animatedValues = {
				height = height,
			},

			mapValuesToProps = mapValuesToProps,
			springOptions = settings,
		}, {
			FullViewIcon = Roact.createElement(ImageSetLabel, {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, 0, 1, 0),
				Size = UDim2.new(0, EXPAND_IMAGE_SIZE.X + EXPAND_IMAGE_PADDING.X + DROP_SHADOW_SIZE, 0,
					EXPAND_IMAGE_SIZE.Y + EXPAND_IMAGE_PADDING.Y + DROP_SHADOW_SIZE),
				BackgroundTransparency = 1,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(16, 16, 18, 18),
				Image = Images["component_assets/dropshadow_24_6"],
				ImageColor3 = theme.DropShadow.Color,
				ImageTransparency = imageTransparencyShadow,
				ZIndex = 2,
			}, {
				BackgroundImage = Roact.createElement(ImageSetButton, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, EXPAND_IMAGE_SIZE.X + EXPAND_IMAGE_PADDING.X,
						0, EXPAND_IMAGE_SIZE.Y + EXPAND_IMAGE_PADDING.Y),
					BackgroundTransparency = 1,
					Image = Images["component_assets/circle_17"],
					ImageColor3 = theme.BackgroundContrast.Color,
					ImageTransparency = imageTransparency,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(8, 8, 9, 9),
					[Roact.Event.Activated] = onActivated,
				}, {
					FullViewImageButton = fullViewImageButton,
				})
			})
		})
	end)
end

local function mapStateToProps(state, props)
	local deviceOrientation = state.DeviceOrientation
	local isPortrait = deviceOrientation == DeviceOrientationMode.Portrait
	local hasSubcategories = false
	local page = AvatarExperienceUtils.getPageFromState(state)
	if page and page.Subcategories then
		hasSubcategories = true
	end

	return {
		topBarHeight = 36,
		screenSize = state.ScreenSize,
		globalGuiInset = state.GlobalGuiInset,
		isPortrait = isPortrait,
		hasSubcategories = hasSubcategories,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, nil)(FullViewButton)
