local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local SetCurrentToastMessage = require(Modules.NotLApp.Actions.SetCurrentToastMessage)
local RemoveCurrentToastMessage = require(Modules.NotLApp.Actions.RemoveCurrentToastMessage)

return function(state, action)
	state = state or {}

	if action.type == SetCurrentToastMessage.name then
		return action.toastMessage
	elseif action.type == RemoveCurrentToastMessage.name then
		return {}
	end

	return state
end