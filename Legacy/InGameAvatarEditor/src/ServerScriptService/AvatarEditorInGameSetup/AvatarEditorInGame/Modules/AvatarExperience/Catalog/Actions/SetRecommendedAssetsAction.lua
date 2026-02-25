local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)

return Action(script.Name, function(assetId, recommendedItems, assetTypeId)
	return {
		assetId = assetId,
		recommendedItems = recommendedItems,
		assetTypeId = assetTypeId,
	}
end)