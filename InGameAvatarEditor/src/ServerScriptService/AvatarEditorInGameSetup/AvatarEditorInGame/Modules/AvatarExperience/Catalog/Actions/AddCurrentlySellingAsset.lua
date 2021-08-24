local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Packages.ArgCheck)

return Action(script.Name, function(assetId, userAssetId)
	ArgCheck.isType(assetId, "string", "assetId")
	ArgCheck.isType(userAssetId, "string", "userAssetId")

	return {
		assetId = assetId,
		userAssetId = userAssetId,
	}
end)