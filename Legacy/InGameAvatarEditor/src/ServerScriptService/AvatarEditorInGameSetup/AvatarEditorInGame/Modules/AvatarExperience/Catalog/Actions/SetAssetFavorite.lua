local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Common.ArgCheck)

return Action(script.Name, function(assetId, isFavorited)
	ArgCheck.isType(assetId, "string", "SetAssetFavorite expects assetId")
	ArgCheck.isType(isFavorited, "boolean", "SetAssetFavorite expects isFavorited")

	return {
		assetId = assetId,
		isFavorited = isFavorited,
	}
end)