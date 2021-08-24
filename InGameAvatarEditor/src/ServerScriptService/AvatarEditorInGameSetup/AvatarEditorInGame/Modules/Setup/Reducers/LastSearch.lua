local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local SetSearchParameters = require(Modules.NotLApp.Actions.SetSearchParameters)

return function(state, action)
	state = state or {}

	if action.type == SetSearchParameters.name then
		state = action.searchUuid
	end

	return state
end