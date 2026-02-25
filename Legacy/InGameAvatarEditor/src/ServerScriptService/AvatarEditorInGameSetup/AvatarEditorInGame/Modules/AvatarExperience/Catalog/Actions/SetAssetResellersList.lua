local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Packages.ArgCheck)

return Action(script.Name, function(assetId, userAssetIds)
	ArgCheck.isType(assetId, "string", "assetId")
	ArgCheck.isType(userAssetIds, "table", "userAssetIds")

	return {
		assetId = assetId,
        userAssetIds = userAssetIds,
	}
end)