local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Packages.ArgCheck)

return Action(script.Name, function(assetId, userAssetIdList)
	ArgCheck.isType(assetId, "string", "assetId")
	ArgCheck.isType(userAssetIdList, "table", "userAssetIdList")

	return {
		assetId = assetId,
		userAssetIdList = userAssetIdList,
	}
end)