local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Immutable = require(Modules.Common.Immutable)

local SetSearchParameters = require(Modules.NotLApp.Actions.SetSearchParameters)

return function(state, action)
	state = state or {}

	if action.type == SetSearchParameters.name then
		state = Immutable.Set(state, action.searchUuid, action.parameters)
	end

	return state
end