local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local SearchesInCatalogStatus = require(Modules.AvatarExperience.Catalog.Reducers.SearchesInCatalogStatus)

return function(state, action)
	state = state or {}

	return {
		SearchesInCatalogStatus = SearchesInCatalogStatus(state.SearchesInCatalogStatus, action),
	}
end