local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local SetAvatarScales = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarScales)
local TwoAxisSlider = require(Modules.AvatarExperience.AvatarEditor.Components.TwoAxisSlider)

local withStyle = UIBlox.Style.withStyle
local ImageSetLabel = UIBlox.Core.ImageSet.Label
local Images = UIBlox.App.ImageSet.Images

local DISABLED_TRANSPARENCY = 0.5
local BACKGROUND_DIMENSIONS = Vector2.new(224, 224)

local SQUARE_RADAR_IMAGE = Images["component_assets/circle_17"]


local BodySizeSlider = Roact.PureComponent:extend("BodySizeSlider")

function BodySizeSlider:init()
	self.ref = self.props[Roact.Ref] or Roact.createRef()

	-- Maps relative position on square to correct scale values
	self.mapPositionToScales = function(position)
		local widthRules = self.props.widthRules
		local widthRange = widthRules.max - widthRules.min
		local widthPercent = position.X
		local width = math.clamp(widthPercent * widthRange + widthRules.min,
			widthRules.min, widthRules.max)

		local heightRules = self.props.heightRules
		local heightRange = heightRules.max - heightRules.min
		local heightPercent = 1.0 - position.Y
		local height = math.clamp(heightPercent * heightRange + heightRules.min,
			heightRules.min, heightRules.max)

		return width, height
	end

	-- Maps scale values to correct relative position on the square radar
	self.mapScalesToPosition = function(width, height)
		local widthRules = self.props.widthRules
		local widthRange = widthRules.max - widthRules.min
		local widthPercent = (width - widthRules.min) / widthRange

		local heightRules = self.props.heightRules
		local heightRange = heightRules.max - heightRules.min
		local heightPercent = (height - heightRules.min) / heightRange

		return Vector2.new(widthPercent, 1.0 - heightPercent)
	end

	self.setScales = function(width, height)
		self.props.setScales({
			width = width,
			height = height,
		})
	end

	self.getBackgroundAbsolutePosition = function()
		local guiObject = self.ref:getValue()
		if guiObject then
			return guiObject.AbsolutePosition
		end
		return nil
	end
	self.getBackgroundAbsoluteSize = function()
		local guiObject = self.ref:getValue()
		if guiObject then
			return guiObject.AbsoluteSize
		end
		return nil
	end
end

function BodySizeSlider:render()
	local width = self.props.width
	local height = self.props.height
	local widthRules = self.props.widthRules
	local heightRules = self.props.heightRules
	local layoutOrder = self.props.LayoutOrder
	local lockNavigationCallback = self.props.lockNavigationCallback
	local unlockNavigationCallback = self.props.unlockNavigationCallback
	local isDisabled = self.props.isDisabled

	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		return Roact.createElement(ImageSetLabel, {
			Image = SQUARE_RADAR_IMAGE,
			Size = UDim2.new(0, BACKGROUND_DIMENSIONS.X, 0, BACKGROUND_DIMENSIONS.Y),
			BackgroundTransparency = 1,
			ImageColor3 = theme.BackgroundUIDefault.Color,
			ImageTransparency = isDisabled and DISABLED_TRANSPARENCY or theme.BackgroundUIDefault.Transparency,
			LayoutOrder = layoutOrder,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(9, 9, 9, 9),
			ZIndex = 2,

			[Roact.Ref] = self.ref,
		}, {
			TwoAxisSlider = Roact.createElement(TwoAxisSlider, {
				mapPositionToScales = self.mapPositionToScales,
				mapScalesToPosition = self.mapScalesToPosition,
				setScales = self.setScales,
				xScaleRules = widthRules,
				yScaleRules = heightRules,
				xScale = width,
				yScale = height,

				getBackgroundAbsolutePosition = self.getBackgroundAbsolutePosition,
				getBackgroundAbsoluteSize = self.getBackgroundAbsoluteSize,

				isDisabled = isDisabled,

				onDragStart = lockNavigationCallback,
				onDragEnd = unlockNavigationCallback,
			})
		})
	end)
end

local function mapStateToProps(state, props)
	local avatarScales = state.AvatarExperience.AvatarEditor.Character.AvatarScales
	local scalesRules =
		state.AvatarExperience.AvatarEditor.AvatarSettings[AvatarEditorConstants.AvatarSettings.scalesRules]

	return {
		height = avatarScales.height,
		width = avatarScales.width,
		heightRules = scalesRules.height,
		widthRules = scalesRules.width,
		avatarType = state.AvatarExperience.AvatarEditor.Character.AvatarType,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setScales = function(scales)
			dispatch(SetAvatarScales(scales))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(BodySizeSlider)
