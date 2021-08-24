local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(assetId, isOwned)
	return {
		assetId = assetId,
		isOwned = isOwned,
	}
end)
