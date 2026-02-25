local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

--[[
	Gets the Asset or Bundle info based on the given itemId and itemType.
	Expects state to be AvatarExperience.Common.
]]
return function(state, itemId, itemType)
	if itemType == CatalogConstants.ItemType.Asset then
		local asset = state.Assets[itemId]
		return asset
	elseif itemType == CatalogConstants.ItemType.Bundle then
		local bundle = state.Bundles[itemId]
		return bundle
	end
end