local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Packages.ArgCheck)

return Action(script.Name, function(assetId, priceInRobux)
	ArgCheck.isType(assetId, "string", "assetId")
	ArgCheck.isType(priceInRobux, "number", "priceInRobux")

	return {
		assetId = assetId,
        priceInRobux = priceInRobux,
	}
end)