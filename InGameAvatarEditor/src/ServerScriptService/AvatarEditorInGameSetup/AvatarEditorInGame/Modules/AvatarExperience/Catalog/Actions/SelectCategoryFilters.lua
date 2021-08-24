local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Common.ArgCheck)

return Action(script.Name, function(filtersSelection)
	ArgCheck.isType(filtersSelection, "table", "SelectCategoryFilters expects filtersSelection")

	return {
		filtersSelection = filtersSelection,
	}
end)