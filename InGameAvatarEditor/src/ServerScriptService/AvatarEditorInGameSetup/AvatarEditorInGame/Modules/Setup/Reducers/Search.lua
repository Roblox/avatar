local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local SearchesInCatalog = require(Modules.AvatarExperience.Catalog.Reducers.SearchesInCatalog)
-- local SearchesInLibrary = require(Modules.LuaApp.Reducers.SearchesInLibrary)

return function(state, action)
	state = state or {}

	return {
		SearchesInCatalog = SearchesInCatalog(state.SearchesInCatalog, action),
	}
end