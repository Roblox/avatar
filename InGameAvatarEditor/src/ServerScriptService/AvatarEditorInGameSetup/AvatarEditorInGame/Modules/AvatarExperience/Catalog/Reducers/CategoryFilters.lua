local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Rodux = require(Modules.Packages.Rodux)

local SelectCategoryFilters = require(Modules.AvatarExperience.Catalog.Actions.SelectCategoryFilters)

local default = {}

return Rodux.createReducer(default, {
	[SelectCategoryFilters.name] = function(state, action)
		return action.filtersSelection
	end,
})