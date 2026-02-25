local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)

local AvatarExperience = Modules.AvatarExperience
local AvatarEditor = AvatarExperience.AvatarEditor

local SetPageLoaded = require(AvatarEditor.Actions.SetPageLoaded)

local DEFAULT_STATE = false
return Rodux.createReducer(DEFAULT_STATE, {

	[SetPageLoaded.name] = function(state, action)
		return action.value
	end,
})