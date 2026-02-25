local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)

local SetCurrentCharacter = require(Modules.AvatarExperience.Common.Actions.SetCurrentCharacter)

local defaultState = nil

return Rodux.createReducer(defaultState, {
	[SetCurrentCharacter.name] = function(state, action)
		return action.currentCharacter
	end,
})