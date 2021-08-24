local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)

local ToggleEquipAsset = require(Modules.AvatarExperience.AvatarEditor.Actions.ToggleEquipAsset)
local EquipOutfit = require(Modules.AvatarExperience.AvatarEditor.Actions.EquipOutfit)
local ReceivedAvatarData = require(Modules.AvatarExperience.AvatarEditor.Actions.ReceivedAvatarData)
local Constants = require(Modules.AvatarExperience.Common.Constants)

local MAX_HATS = 3

local function checkIfWearingAsset(assets, assetId)
	for _, equippedAssetId in pairs(assets) do
		if equippedAssetId == assetId then
			return true
		end
	end

	return false
end

local function fullOutfitReset(oldState, assets)
	local newState = {}
	local assetTypeIds = {}

	for assetTypeId, _ in pairs(oldState) do
		assetTypeIds[assetTypeId] = true
	end

	for assetTypeId, _ in pairs(assets) do
		assetTypeIds[assetTypeId] = true
	end

	for assetTypeId, _ in pairs(assetTypeIds) do
		local assetsByType = assets[assetTypeId]
		newState[assetTypeId] = assetsByType and assetsByType or {}
	end

	return newState
end

local function replaceOutfitParts(oldState, assets)
	return Cryo.Dictionary.join(oldState, assets)
end

return Rodux.createReducer(nil, {
	[ReceivedAvatarData.name] = function(state, action)
		local assets = action.avatarData['assets']
		if assets == nil then
			return state
		end
		state = {}
		for _, asset in ipairs(assets) do
			local assetTypeId = tostring(asset.assetType.id)
			local entry = state[assetTypeId]
			local assetId = tostring(asset.id)

			if entry ~= nil then
				table.insert(entry, assetId)
			else
				state[assetTypeId] = {assetId}
			end
		end
		return state
	end,
	[ToggleEquipAsset.name] = function(state, action)
		state = state or {}

		if action.assetType == Constants.AssetTypes.Emote then
			return state
		end

		if state[action.assetType] and checkIfWearingAsset(state[action.assetType], action.assetId) then
			local assets = state[action.assetType] or {}
			return Cryo.Dictionary.join(state, {[action.assetType] = Cryo.List.removeValue(assets, action.assetId)})
		end

		if action.assetType == Constants.AssetTypes.Hat then
			local hats = state[Constants.AssetTypes.Hat] or {}
			if #hats >= MAX_HATS then
				return state
			end

			return Cryo.Dictionary.join(state, {[Constants.AssetTypes.Hat] = {action.assetId, hats[1], hats[2]}})
		end
		-- Key: Asset Type, Value: Array of Asset IDs
		return Cryo.Dictionary.join(state, {[action.assetType] = {action.assetId}})
	end,
	[EquipOutfit.name] = function(state, action)
		state = state or {}

		if action.fullReset then
			return fullOutfitReset(state, action.assets)
		else
			return replaceOutfitParts(state, action.assets)
		end
	end
})