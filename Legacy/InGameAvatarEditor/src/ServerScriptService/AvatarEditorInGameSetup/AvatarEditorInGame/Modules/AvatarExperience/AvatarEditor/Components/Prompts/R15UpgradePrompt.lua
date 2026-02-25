--[[
	This prompt shows up when your character is R6 and you try to do something that only works
	for R15 avatars.
	It warns that R6 does not support (XYZ) and prompts you to switch your character to R15.
	Action buttons:
		- Cancel (character stays as R6)
		- Switch (character becomes R15, the thing you were trying to do happens)
]]

local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local t = require(Modules.Packages.t)
local withLocalization = require(Modules.Packages.Localization.withLocalization)
local UIBlox = require(Modules.Packages.UIBlox)

local CloseCentralOverlay = require(Modules.NotLApp.Thunks.CloseCentralOverlay)
local SetAvatarType = require(Modules.AvatarExperience.AvatarEditor.Thunks.SetAvatarType)
local ToggleEquipAsset = require(Modules.AvatarExperience.AvatarEditor.Thunks.ToggleEquipAsset)

local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)

local InteractiveAlert = UIBlox.App.Dialog.Alert.InteractiveAlert
local ButtonType = UIBlox.App.Button.Enum.ButtonType

local R15UpgradePrompt = Roact.PureComponent:extend("R15UpgradePrompt")

R15UpgradePrompt.validateProps = t.strictInterface({
	bodyText = t.string,
	onSwitchSelected = t.optional(t.callback),

	-- Forced from CentralOverlay
	containerWidth = t.number,
	defaultChildRef = t.optional(t.table),
	onOverlayClosed = t.optional(t.callback),
	focusController = t.optional(t.table),

	-- fromMapStateToProps
	screenSize = t.Vector2,

	-- mapDispatchToProps
	closePrompt = t.callback,
	setAvatarType = t.callback,
	toggleEquipAsset = t.callback,
})


function R15UpgradePrompt:init()
	self.switchToR15 = function()
		self.props.setAvatarType(AvatarExperienceConstants.AvatarType.R15)
		if self.props.onSwitchSelected then
			self.props.onSwitchSelected()
		end
		self.closePrompt()
	end

	self.closePrompt = function()
		self.props.closePrompt()
	end
end

function R15UpgradePrompt:renderLocalized(localized)
	return Roact.createElement(InteractiveAlert, {
		title = localized.titleText,
		bodyText = localized.bodyText,
		buttonStackInfo = {
			buttons = {
				{
					props = {
						onActivated = self.closePrompt,
						text = localized.cancelButtonText,
					},
				},
				{
					buttonType = ButtonType.PrimarySystem,
					props = {
						onActivated = self.switchToR15,
						text = localized.confirmButtonText,
					},
				},
			},
		},
		position = UDim2.fromScale(0.5, 0.5),
		screenSize = self.props.screenSize,
		defaultChildRef = self.props.defaultChildRef,
	})
end

function R15UpgradePrompt:render()
	return withLocalization({
		titleText = "Feature.Avatar.Label.SwitchToR15",
		bodyText = self.props.bodyText,
		confirmButtonText = "Feature.Avatar.Action.Switch",
		cancelButtonText = "Feature.Avatar.Action.Cancel",
	})(function(localized)
		return self:renderLocalized(localized)
	end)
end

local function mapStateToProps(state, _props)
	return {
		screenSize = state.ScreenSize,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		closePrompt = function()
			dispatch(CloseCentralOverlay())
		end,
		setAvatarType = function(newAvatarType)
			dispatch(SetAvatarType(newAvatarType))
		end,
		toggleEquipAsset = function(assetType, assetId, navigation)
			dispatch(ToggleEquipAsset(assetType, assetId, navigation))
		end,
	}
end

R15UpgradePrompt = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(R15UpgradePrompt)

return R15UpgradePrompt
