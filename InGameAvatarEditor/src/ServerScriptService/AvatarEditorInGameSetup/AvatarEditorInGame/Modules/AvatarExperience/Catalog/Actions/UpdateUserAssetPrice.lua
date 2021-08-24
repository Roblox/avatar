local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Packages.ArgCheck)

return Action(script.Name, function(userAssetId, priceInRobux)
	ArgCheck.isType(userAssetId, "string", "userAssetId")
	ArgCheck.isTypeOrNil(priceInRobux, "number", "priceInRobux")

	return {
		userAssetId = userAssetId,
		priceInRobux = priceInRobux,
	}
end)