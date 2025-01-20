local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local SearchesInCatalog = require(Modules.AvatarExperience.Catalog.Reducers.SearchesInCatalog)

return function(state, action)
	state = state or {}

	return {
		SearchesInCatalog = SearchesInCatalog(state.SearchesInCatalog, action),
	}
end