local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)
local CategoryFilters = require(Modules.AvatarExperience.Catalog.Reducers.CategoryFilters)
local PriceRange = require(Modules.AvatarExperience.Catalog.Reducers.PriceRange)

return Rodux.combineReducers({
    CategoryFilters = CategoryFilters,
    PriceRange = PriceRange,
})