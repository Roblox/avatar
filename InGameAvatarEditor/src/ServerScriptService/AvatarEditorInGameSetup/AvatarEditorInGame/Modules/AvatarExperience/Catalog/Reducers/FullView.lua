local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)

local Toggle3DFullView = require(Modules.AvatarExperience.Catalog.Actions.Toggle3DFullView)

return Rodux.createReducer(false, {
	[Toggle3DFullView.name] = function(state, action)
		return not state
	end,
})