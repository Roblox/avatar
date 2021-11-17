--[[
	This prompt shows up when your character is R15 and has layered clothing equipped, and you try to switch to R6.
	It warns that R6 does not support layered clothing and therefore all layered clothing items will be removed.
	Action buttons:
		- Cancel (character stays as R15)
		- Confirm (character becomes R6, all layered clothing items are removed)
]]

local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules


local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local t = require(Modules.Packages.t)
local withLocalization = require(Modules.Packages.Localization.withLocalization)
local UIBlox = require(Modules.Packages.UIBlox)

local CloseCentralOverlay = require(Modules.NotLApp.Thunks.CloseCentralOverlay)
local SetAvatarType = require(Modules.AvatarExperience.AvatarEditor.Thunks.SetAvatarType)
local RemoveLayeredClothing = require(Modules.AvatarExperience.AvatarEditor.Actions.RemoveLayeredClothing)

local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)

local InteractiveAlert = UIBlox.App.Dialog.Alert.InteractiveAlert
local ButtonType = UIBlox.App.Button.Enum.ButtonType

local LayeredClothingR6SwitchPrompt = Roact.PureComponent:extend("LayeredClothingR6SwitchPrompt")

LayeredClothingR6SwitchPrompt.validateProps = t.strictInterface({
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
	removeLayeredClothing = t.callback,
})


function LayeredClothingR6SwitchPrompt:init()
	self.switchToR6 = function()
		self.props.removeLayeredClothing()
		self.props.setAvatarType(AvatarExperienceConstants.AvatarType.R6)
		self.closePrompt()
	end

	self.closePrompt = function()
		self.props.closePrompt()
	end
end

function LayeredClothingR6SwitchPrompt:renderLocalized(localized)
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
						onActivated = self.switchToR6,
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

function LayeredClothingR6SwitchPrompt:render()
	return withLocalization({
		titleText = "Common.AlertsAndOptions.Title.Warning",
		bodyText = "Feature.Avatar.Label.LayeredClothingSwitchR6Warning",
		confirmButtonText = "CommonUI.Controls.Action.Confirm",
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
		removeLayeredClothing = function()
			dispatch(RemoveLayeredClothing())
		end,
	}
end

LayeredClothingR6SwitchPrompt = RoactRodux.connect(mapStateToProps, mapDispatchToProps)(LayeredClothingR6SwitchPrompt)

return LayeredClothingR6SwitchPrompt
