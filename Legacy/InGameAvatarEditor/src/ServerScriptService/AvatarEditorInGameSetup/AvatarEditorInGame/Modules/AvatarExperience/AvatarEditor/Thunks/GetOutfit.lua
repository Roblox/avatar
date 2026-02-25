local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Players = game:GetService("Players")

local Promise = require(Modules.Packages.Promise)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local SetOutfitInfo = require(Modules.AvatarExperience.AvatarEditor.Actions.SetOutfitInfo)
local OutfitInfo = require(Modules.AvatarExperience.AvatarEditor.Models.OutfitInfo)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local SetAssetInfoFromOutfitDetails =
	require(Modules.AvatarExperience.AvatarEditor.Actions.SetAssetInfoFromOutfitDetails)

local buildCostumeInfoFromHumanoidDescription = require(Modules.Util.buildCostumeInfoFromHumanoidDescription)

local function keyMapper(outfitId)
	return AvatarExperienceConstants.OutfitInfoKey .. tostring(outfitId)
end

local function checkAssetExists(state, assetId)
	local existingInfo = state.AvatarExperience.Common.Assets[assetId]

	if existingInfo and existingInfo.receivedFromOutfitDetails then
		return true
	end

	return false
end

return function(outfitId, isEditable)

	return PerformFetch.Single(keyMapper(outfitId), function(store)
		local state = store:getState()
		if state.AvatarExperience.AvatarEditor.Outfits[outfitId] then
			return Promise.resolve()
		end
		return Promise.new(function(resolve, reject)
			coroutine.wrap(function()
				local humanoidDescription = Players:GetHumanoidDescriptionFromOutfitId(outfitId)

				local data = buildCostumeInfoFromHumanoidDescription(humanoidDescription)

				local assets = data.assets
				local outfitName = data.name
				local outfitAssets = data.assets
				local outfitBodyColors = data.bodyColors
				local outfitScales = data.scales
				local outfitAvatarType = data.playerAvatarType or "R15"

				local outfit = OutfitInfo.fromWebApi(outfitId, outfitName, assets, outfitBodyColors, outfitScales,
					outfitAvatarType, isEditable)
				store:dispatch(SetOutfitInfo(outfit))

				resolve()
			end)()
		end)
	end)
end
