local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ArgCheck = require(Modules.Common.ArgCheck)
local SetCategoryAndSubcategory = require(Modules.AvatarExperience.Catalog.Actions.SetCategoryAndSubcategory)

return function(category, subcategory)
	return function(store)
		ArgCheck.isTypeOrNil(category, "number", "SetCategoryAndSubcategory thunk expects category")
		ArgCheck.isTypeOrNil(subcategory, "number", "SetCategoryAndSubcategory thunk expects subcategory")

		store:dispatch(SetCategoryAndSubcategory(category, subcategory))
	end
end
