
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ApplyNavigateToRoute = require(Modules.NotLApp.Actions.ApplyNavigateToRoute)

return function(route, bypassNavigationLock)

	return function(store)
		store:dispatch(ApplyNavigateToRoute(route, bypassNavigationLock))
	end
end
