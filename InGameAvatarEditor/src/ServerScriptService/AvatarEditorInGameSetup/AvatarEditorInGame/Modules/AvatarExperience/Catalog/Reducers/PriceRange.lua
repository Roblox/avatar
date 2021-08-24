local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)

local SetPriceRange = require(Modules.AvatarExperience.Catalog.Actions.SetPriceRange)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local default = {
	minPrice = CatalogConstants.MinPriceFilter,
	maxPrice = CatalogConstants.MaxPriceFilter,
}

return Rodux.createReducer(default, {
	[SetPriceRange.name] = function(state, action)
		return action.priceRange
	end,
})