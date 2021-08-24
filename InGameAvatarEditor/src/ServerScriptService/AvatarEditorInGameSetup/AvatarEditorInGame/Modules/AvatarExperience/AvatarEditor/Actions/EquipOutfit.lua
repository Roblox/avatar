local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(assets, fullReset)
	return {
		assets = assets,
		fullReset = fullReset,
	}
end)