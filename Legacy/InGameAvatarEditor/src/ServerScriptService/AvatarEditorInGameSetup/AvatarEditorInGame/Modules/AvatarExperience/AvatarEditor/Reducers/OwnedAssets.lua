local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local SetOwnedAssets = require(Modules.AvatarExperience.AvatarEditor.Actions.SetOwnedAssets)
local GrantAsset = require(Modules.AvatarExperience.AvatarEditor.Actions.GrantAsset)
local RevokeAsset = require(Modules.AvatarExperience.AvatarEditor.Actions.RevokeAsset)
local GrantOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.GrantOutfit)
local RevokeOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.RevokeOutfit)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)

--[[
	Add more owned asset ids to the players list. Keep order by checking for duplicates and only
	appending new ones to the list.
]]

return Rodux.createReducer({}, {
	[SetOwnedAssets.name] = function(state, action)
        local checkForDups = {}
		local currentAssets = state[action.assetTypeId] and state[action.assetTypeId] or {}

		for _, assetId in pairs(currentAssets) do
			checkForDups[assetId] = assetId
		end

		for _, assetId in pairs(action.assets) do
			if not checkForDups[assetId] then
				currentAssets[#currentAssets + 1] = assetId
			end
		end

        return Cryo.Dictionary.join(state, {[action.assetTypeId] = currentAssets})
	end,

    [GrantAsset.name] = function(state, action)
		local assetTypeId = tostring(action.assetTypeId)
		local newAssetId = tostring(action.assetId)
		local currentAssets = state[assetTypeId] and state[assetTypeId] or {}

        local updatedAssets = { newAssetId }

		for i, assetId in ipairs(currentAssets) do
			-- Do nothing if this asset is already owned.
			if assetId == newAssetId then
				return state
			else
				updatedAssets[i + 1] = assetId
			end
		end

        return Cryo.Dictionary.join(state, {[assetTypeId] = updatedAssets})
	end,

    [RevokeAsset.name] = function(state, action)
		local assetTypeId = tostring(action.assetTypeId)
		local assetToRevokeId = tostring(action.assetId)
		local currentAssets = state[assetTypeId] and state[assetTypeId] or {}

		local updatedAssets = Cryo.List.removeValue(currentAssets, assetToRevokeId)

        return Cryo.Dictionary.join(state, {[assetTypeId] = updatedAssets})
	end,

    [GrantOutfit.name] = function(state, action)
		local actionOutfitId = tostring(action.outfitId)
		local currentOutfits = state[AvatarEditorConstants.CharacterKey] or {}

        local updatedOutfits = { actionOutfitId }

		for i, outfitId in ipairs(currentOutfits) do
			-- Do nothing if this costume is already owned.
			if outfitId == actionOutfitId then
				return state
			else
				updatedOutfits[i + 1] = outfitId
			end
		end

        return Cryo.Dictionary.join(state, {[AvatarEditorConstants.CharacterKey] = updatedOutfits})
	end,

	[RevokeOutfit.name] = function(state, action)
		local outfitId = tostring(action.outfitId)
		local currentOutfits = state[AvatarEditorConstants.CharacterKey] or {}
		local costumeList = Cryo.List.removeValue(currentOutfits, outfitId)

		return Cryo.Dictionary.join(state, {[AvatarEditorConstants.CharacterKey] = costumeList})
	end
})