local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(bundleId, isOwned)
	return {
		bundleId = bundleId,
		isOwned = isOwned,
	}
end)
