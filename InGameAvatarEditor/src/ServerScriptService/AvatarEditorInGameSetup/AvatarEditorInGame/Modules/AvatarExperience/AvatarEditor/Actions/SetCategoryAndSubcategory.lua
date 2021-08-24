local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Packages.ArgCheck)

return Action("Avatar-"..script.Name, function(category, subcategory)
	ArgCheck.isTypeOrNil(category, "number", "SetCategoryAndSubCategory expects category")
	ArgCheck.isTypeOrNil(subcategory, "number", "SetCategoryAndSubCategory expects subcategory")

	return {
		category = category,
		subcategory = subcategory,
	}
end)