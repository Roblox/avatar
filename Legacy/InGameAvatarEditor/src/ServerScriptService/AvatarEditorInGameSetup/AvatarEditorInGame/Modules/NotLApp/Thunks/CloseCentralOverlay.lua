local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local SetCentralOverlay = require(Modules.NotLApp.Actions.SetCentralOverlay)

return function()
	return function(store)
		store:dispatch(SetCentralOverlay())
	end
end