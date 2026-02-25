local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local SetCentralOverlay = require(Modules.NotLApp.Actions.SetCentralOverlay)

return function(state, action)
	state = state or {
		OverlayType = nil,
		Arguments = {},
	}

	if action.type == SetCentralOverlay.name then
		state = {
			OverlayType = action.overlayType,
			Arguments = action.arguments and action.arguments or {},
		}
	end

	return state
end