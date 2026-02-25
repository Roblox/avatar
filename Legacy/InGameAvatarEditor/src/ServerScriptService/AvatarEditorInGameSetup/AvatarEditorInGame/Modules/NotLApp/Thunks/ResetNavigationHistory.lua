local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ApplyResetNavigationHistory = require(Modules.NotLApp.Actions.ApplyResetNavigationHistory)

return function(route, history)
	return function(store)
		store:dispatch(ApplyResetNavigationHistory(route, history))
	end
end
