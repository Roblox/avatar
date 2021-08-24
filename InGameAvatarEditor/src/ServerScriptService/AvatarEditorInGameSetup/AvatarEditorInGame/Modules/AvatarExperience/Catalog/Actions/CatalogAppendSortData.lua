local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ArgCheck = require(Modules.Common.ArgCheck)

local Action = require(Modules.Common.Action)

return Action(script.Name, function(categoryIndex, subcategoryIndex, sortResults)
	ArgCheck.isType(categoryIndex, "number", "CatalogAppendSortData expects categoryIndex")
	ArgCheck.isType(subcategoryIndex, "number", "CatalogAppendSortData expects subcategoryIndex")
	ArgCheck.isType(sortResults, "table", "CatalogAppendSortData expects sortResults")

	return {
        categoryIndex = categoryIndex,
        subcategoryIndex = subcategoryIndex,
        sortResults = sortResults,
	}
end)