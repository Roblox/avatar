local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ArgCheck = require(Modules.Common.ArgCheck)

local Action = require(Modules.Common.Action)

return Action(script.Name, function(categoryIndex, subcategoryIndex, status)
	ArgCheck.isType(categoryIndex, "number", "SetCatalogSortDataStatus expects categoryIndex")
	ArgCheck.isType(subcategoryIndex, "number", "SetCatalogSortDataStatus expects subcategoryIndex")
	ArgCheck.isType(status, "string", "SetCatalogSortDataStatus expects status")

	return {
        categoryIndex = categoryIndex,
        subcategoryIndex = subcategoryIndex,
		status = status,
	}
end)