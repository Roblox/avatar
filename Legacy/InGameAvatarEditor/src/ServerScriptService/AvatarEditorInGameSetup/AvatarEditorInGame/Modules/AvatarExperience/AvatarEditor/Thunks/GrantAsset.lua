local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local GrantAsset = require(Modules.AvatarExperience.AvatarEditor.Actions.GrantAsset)
local FetchItemData = require(Modules.AvatarExperience.Catalog.Thunks.FetchItemData)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

return function(assetTypeId, assetId)
	return function(store)
		store:dispatch(GrantAsset(assetTypeId, assetId))
		store:dispatch(FetchItemData(assetId, CatalogConstants.ItemType.Asset))
	end
end
