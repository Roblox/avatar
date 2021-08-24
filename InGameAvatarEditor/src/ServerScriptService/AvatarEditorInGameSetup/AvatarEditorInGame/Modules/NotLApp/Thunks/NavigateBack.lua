
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ApplyNavigateBack = require(Modules.NotLApp.Actions.ApplyNavigateBack)


return function(bypassNavigationLock)

	return function(store)
		store:dispatch(ApplyNavigateBack(bypassNavigationLock))
	end
end
