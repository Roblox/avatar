local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local RoactRodux = require(Modules.Packages.RoactRodux)
local RoactServices = require(Modules.Common.RoactServices)

local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local SetAvatarScales = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarScales)

local Slider = UIBlox.App.Slider.SystemSlider

local HeadSlider = Roact.PureComponent:extend("HeadSlider")

function HeadSlider:init()
	self.moveListen = nil
	self.endListen = nil

	self.scaleRef = Roact.createRef()
end

function HeadSlider:render()
	local avatarType = self.props.avatarType
	local head = self.props.head
	local headScaleRules = self.props.headScaleRules
	local LayoutOrder = self.props.LayoutOrder

	return Roact.createElement(Slider, {
		layoutOrder = LayoutOrder,
		min = headScaleRules.min,
		max = headScaleRules.max,
		stepInterval = headScaleRules.increment,
		value = head,
		onValueChanged = function(newValue)
			self.props.setScales({
				head = newValue,
			})
		end,
		onDragStart = self.props.lockNavigationCallback,
		onDragEnd = self.props.unlockNavigationCallback,
		isDisabled = avatarType == AvatarEditorConstants.AvatarType.R6,

		NextSelectionUp = self.props.NextSelectionUp,
		NextSelectionDown = self.props.NextSelectionDown,
		[Roact.Ref] = self.props[Roact.Ref],
	})
end

local function mapStateToProps(state, props)
	return {
		avatarType = state.AvatarExperience.AvatarEditor.Character.AvatarType,
		head = state.AvatarExperience.AvatarEditor.Character.AvatarScales.head,
		headScaleRules =
			state.AvatarExperience.AvatarEditor.AvatarSettings[AvatarEditorConstants.AvatarSettings.scalesRules].head,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		setScales = function(scales)
			dispatch(SetAvatarScales(scales))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(HeadSlider)
