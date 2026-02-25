local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local SetAvatarScales = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarScales)
local TwoAxisSlider = require(Modules.AvatarExperience.AvatarEditor.Components.TwoAxisSlider)

local withStyle = UIBlox.Style.withStyle

local BACKGROUND_DIMENSIONS = Vector2.new(224, 195)

local DEFAULT_PROPORTION_VALUE = 0.5
local DISABLED_TRANSPARENCY = 0.5

local BODY_TYPE_IMAGE_PATH = "rbxasset://textures/AvatarEditorImages/Sliders/body-type-slider-background.png"

local BodyTypeSlider = Roact.PureComponent:extend("BodyTypeSlider")

function BodyTypeSlider:init()
	self.ref = self.props[Roact.Ref] or Roact.createRef()

	-- Maps relative position on triangle to correct scale values
	self.mapPositionToScales = function(position)
		local bodyTypeScaleRules = self.props.bodyTypeScaleRules
		local bodyTypeRange = bodyTypeScaleRules.max - bodyTypeScaleRules.min
		local bodyTypePercent = 1.0 - position.Y
		local bodyType = math.clamp(bodyTypePercent * bodyTypeRange + bodyTypeScaleRules.min,
			bodyTypeScaleRules.min, bodyTypeScaleRules.max)

		local proportionScaleRules = self.props.proportionScaleRules
		local proportionRange = proportionScaleRules.max - proportionScaleRules.min
		-- Handle edge case for bodyType == 0.0 to avoid divide by zero error
		local proportionPercent = 1.0 - (bodyType == 0.0 and DEFAULT_PROPORTION_VALUE
			or (position.X - 0.5 * position.Y) / bodyType)
		local proportion = math.clamp(proportionPercent * proportionRange + proportionScaleRules.min,
			proportionScaleRules.min, proportionScaleRules.max)

		return proportion, bodyType
	end

	-- Maps scale values to correct relative position on triangle
	self.mapScalesToPosition = function(proportion, bodyType)
		local bodyTypeScaleRules = self.props.bodyTypeScaleRules
		local bodyTypeRange = bodyTypeScaleRules.max - bodyTypeScaleRules.min
		local bodyTypePercent = (bodyType - bodyTypeScaleRules.min) / bodyTypeRange

		local proportionScaleRules = self.props.proportionScaleRules
		local proportionRange = proportionScaleRules.max - proportionScaleRules.min
		local proportionPercent = (proportion - proportionScaleRules.min) / proportionRange

		return Vector2.new((1.0 - proportionPercent) * bodyTypePercent + 0.5 * (1.0 - bodyTypePercent),
			1.0 - bodyTypePercent)
	end

	self.setScales = function(proportion, bodyType)
		self.props.setScales({
			proportion = proportion,
			bodyType = bodyType,
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

function BodyTypeSlider:render()
	local proportion = self.props.proportion
	local bodyType = self.props.bodyType
	local proportionScaleRules = self.props.proportionScaleRules
	local bodyTypeScaleRules = self.props.bodyTypeScaleRules
	local layoutOrder = self.props.LayoutOrder
	local lockNavigationCallback = self.props.lockNavigationCallback
	local unlockNavigationCallback = self.props.unlockNavigationCallback

	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		local aspectRatio = BACKGROUND_DIMENSIONS.X / BACKGROUND_DIMENSIONS.Y
		local sliderWidth = BACKGROUND_DIMENSIONS.X
		local sliderHeight = sliderWidth / aspectRatio

		local isDisabled = self.props.isDisabled

		return Roact.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Image = BODY_TYPE_IMAGE_PATH,
			LayoutOrder = layoutOrder,
			Size = UDim2.new(0, BACKGROUND_DIMENSIONS.X, 0, sliderHeight),
			BackgroundTransparency = 1,
			ImageColor3 = theme.BackgroundUIDefault.Color,
			ImageTransparency = isDisabled and DISABLED_TRANSPARENCY or theme.BackgroundUIDefault.Transparency,

			[Roact.Ref] = self.ref,
		}, {
			TwoAxisSlider = Roact.createElement(TwoAxisSlider, {
				mapPositionToScales = self.mapPositionToScales,
				mapScalesToPosition = self.mapScalesToPosition,
				setScales = self.setScales,
				xScaleRules = proportionScaleRules,
				yScaleRules = bodyTypeScaleRules,
				xScale = proportion,
				yScale = bodyType,

				getBackgroundAbsolutePosition = self.getBackgroundAbsolutePosition,
				getBackgroundAbsoluteSize = self.getBackgroundAbsoluteSize,

				invertDPadX = true,
				isDisabled = isDisabled,

				onDragStart = lockNavigationCallback,
				onDragEnd = unlockNavigationCallback,
			}),
		})
	end)
end

local function mapStateToProps(state, props)
	local avatarScales = state.AvatarExperience.AvatarEditor.Character.AvatarScales
	local avatarSettings = state.AvatarExperience.AvatarEditor.AvatarSettings
	local scalesRules = avatarSettings[AvatarEditorConstants.AvatarSettings.scalesRules]

	return {
		avatarType = state.AvatarExperience.AvatarEditor.Character.AvatarType,
		bodyType = avatarScales.bodyType,
		proportion = avatarScales.proportion,
		bodyTypeScaleRules = scalesRules.bodyType,
		proportionScaleRules = scalesRules.proportion,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setScales = function(scales)
			dispatch(SetAvatarScales(scales))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(BodyTypeSlider)
