local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Common.ArgCheck)

return Action(script.Name, function(assets)
	ArgCheck.isType(assets, "table", "SetAssetInfoFromOutfitDetails action expects assets to be a table")

	return {
		assets = assets,
	}
end)