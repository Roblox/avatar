local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local SetCategoryAndSubcategory = require(Modules.AvatarExperience.Catalog.Actions.SetCategoryAndSubcategory)

local default = {
    category = 1,
    subcategory = 0,
}

return Rodux.createReducer(default, {
	[SetCategoryAndSubcategory.name] = function(state, action)
        return Cryo.Dictionary.join(state, {
            category = action.category or state.category,
            subcategory = action.subcategory or 0,
        })
	end,
})