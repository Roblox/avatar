
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ApplyNavigateBackUp = require(Modules.LuaApp.Actions.ApplyNavigateBackUp)

return function(bypassNavigationLock)

	return function(store)
		store:dispatch(ApplyNavigateBackUp(bypassNavigationLock))
	end
end
