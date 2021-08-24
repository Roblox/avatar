local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local EquipOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.EquipOutfit)
local SetAvatarType = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarType)
local SetAvatarScales = require(Modules.AvatarExperience.AvatarEditor.Actions.SetAvatarScales)
local SetBodyColors = require(Modules.AvatarExperience.AvatarEditor.Actions.SetBodyColors)
local ClearSelectedItem = require(Modules.AvatarExperience.Common.Actions.ClearSelectedItem)
local CloseAllItemDetails = require(Modules.AvatarExperience.Catalog.Thunks.CloseAllItemDetails)
local AvatarEditorUtils = require(Modules.AvatarExperience.AvatarEditor.Utils)

local FFlagAvatarEditorKeepYourColor = true

local bodyPartAssetTypeIds = {
	Torso = "27",
	RightArm = "28",
	LeftArm = "29",
	LeftLeg = "30",
	RightLeg = "31",
}

-- A fully qualified outfit is one that has both arms, both legs, and a torso.
local function isFullyQualifiedOutfit(assets)
	for _, assetTypeId in pairs(bodyPartAssetTypeIds) do
		if not assets[assetTypeId] then
			return false
		end
	end

	return true
end

return function(outfit)
	return function(store)
		local fullReset = outfit.isEditable or isFullyQualifiedOutfit(outfit.assets)

		-- Do a full reset on a user costume, or a preset fully qualified one. Otherwise swap the existing parts.
		store:dispatch(EquipOutfit(outfit.assets, fullReset))

		if true then
			local selectedItem = store:getState().AvatarExperience.AvatarScene.TryOn.SelectedItem.itemId
			if selectedItem then
				store:dispatch(ClearSelectedItem())
				store:dispatch(CloseAllItemDetails(store:getState().Navigation.history))
			end
		end

		if fullReset then
			-- Preset costumes should not replace body colors.
			if not FFlagAvatarEditorKeepYourColor or
				(FFlagAvatarEditorKeepYourColor and not AvatarEditorUtils.isPresetCostume(outfit)) then
				store:dispatch(SetBodyColors(outfit.bodyColors))
			end
			store:dispatch(SetAvatarScales(outfit.scales))
			store:dispatch(SetAvatarType(outfit.avatarType))
		end
	end
end