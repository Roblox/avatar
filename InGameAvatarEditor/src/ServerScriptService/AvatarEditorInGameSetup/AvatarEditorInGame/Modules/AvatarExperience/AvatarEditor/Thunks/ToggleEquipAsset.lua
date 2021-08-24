local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local ToggleEquipAsset = require(Modules.AvatarExperience.AvatarEditor.Actions.ToggleEquipAsset)
local ClearSelectedItem = require(Modules.AvatarExperience.Common.Actions.ClearSelectedItem)
local CloseAllItemDetails = require(Modules.AvatarExperience.Catalog.Thunks.CloseAllItemDetails)
local Constants = require(Modules.AvatarExperience.Common.Constants)
local SetCurrentToastMessage = require(Modules.NotLApp.Actions.SetCurrentToastMessage)
local ToastType = require(Modules.NotLApp.Enum.ToastType)

local MAX_HATS = 3

local EQUIP_4TH_HAT_TOAST = {
	toastMessage = "Feature.Avatar.Message.HatLimitTooltip",
	isLocalized = false,
	toastType = ToastType.InformationMessage,
}

return function(assetTypeId, assetId)
	return function(store)
		local equippedAssets = store:getState().AvatarExperience.AvatarEditor.Character.EquippedAssets
		if not equippedAssets then
			return
		end

		local selectedItem = store:getState().AvatarExperience.AvatarScene.TryOn.SelectedItem
		if true then
			selectedItem = store:getState().AvatarExperience.AvatarScene.TryOn.SelectedItem.itemId
		end

		if selectedItem then
			store:dispatch(ClearSelectedItem())
			store:dispatch(CloseAllItemDetails(store:getState().Navigation.history))
		end

		local equippedHats = equippedAssets[Constants.AssetTypes.Hat]
		if assetTypeId == Constants.AssetTypes.Hat and equippedHats and #equippedHats >= MAX_HATS then
			local equippedHats = equippedAssets and equippedAssets[Constants.AssetTypes.Hat] or {}
			local unequipping = false
			for _, equippedAssetId in ipairs(equippedHats) do
				if assetId == equippedAssetId then
					unequipping = true
				end
			end
			if not unequipping then
				store:dispatch(SetCurrentToastMessage(EQUIP_4TH_HAT_TOAST))
			end
		end
		store:dispatch(ToggleEquipAsset(assetTypeId, assetId))
	end
end