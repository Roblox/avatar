local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local RevokeAsset = require(Modules.AvatarExperience.AvatarEditor.Actions.RevokeAsset)
local ToggleEquipAsset = require(Modules.AvatarExperience.AvatarEditor.Thunks.ToggleEquipAsset)
local AvatarEditorUtils = require(Modules.AvatarExperience.AvatarEditor.Utils)

return function(assetTypeId, assetId)
	return function(store)
		local equippedAssets = store:getState().AvatarExperience.AvatarEditor.Character.EquippedAssets
		assetTypeId = tostring(assetTypeId)
		assetId = tostring(assetId)

		if AvatarEditorUtils.isAssetEquipped(assetId, assetTypeId, equippedAssets) then
			store:dispatch(ToggleEquipAsset(assetTypeId, assetId))
		end
		store:dispatch(RevokeAsset(assetTypeId, assetId))
	end
end