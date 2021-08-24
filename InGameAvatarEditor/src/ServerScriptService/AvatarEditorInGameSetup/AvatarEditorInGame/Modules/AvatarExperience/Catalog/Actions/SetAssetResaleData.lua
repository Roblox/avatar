local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Packages.ArgCheck)

return Action(script.Name, function(assetId, assetResaleData)
	ArgCheck.isType(assetId, "string", "assetId")
	ArgCheck.isType(assetResaleData, "table", "assetResaleData")
	return {
		assetId = assetId,
		assetResaleData = assetResaleData,
	}
end)