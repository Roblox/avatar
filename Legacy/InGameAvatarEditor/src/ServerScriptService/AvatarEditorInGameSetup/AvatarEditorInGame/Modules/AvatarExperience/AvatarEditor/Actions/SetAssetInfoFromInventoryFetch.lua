local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Common.ArgCheck)

return Action(script.Name, function(assets, assetTypeId)
	ArgCheck.isType(assets, "table", "SetAssetInfoFromInventoryFetch action expects assets to be a table")
	ArgCheck.isTypeOrNil(assetTypeId, "string", "SetAssetInfoFromInventoryFetch action expects assetTypeId to be a string")

	return {
		assets = assets,
		assetTypeId = assetTypeId,
	}
end)
