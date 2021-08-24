local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)
local SetAvailableToSellAssetsFromFetchSellData =
	require(Modules.AvatarExperience.Catalog.Actions.SetAvailableToSellAssetsFromFetchSellData)
local AddAvailableToSellAsset = require(Modules.AvatarExperience.Catalog.Actions.AddAvailableToSellAsset)
local RemoveAvailableToSellAsset = require(Modules.AvatarExperience.Catalog.Actions.RemoveAvailableToSellAsset)
local Cryo = require(Modules.Packages.Cryo)

-- dictionary of assetIds containing a list of userAssetIds
return Rodux.createReducer({}, {
	--[[
		action.assetId: string
		action.userAssetIdList: table
	]]
	[SetAvailableToSellAssetsFromFetchSellData.name] = function(state, action)
		local assetId = action.assetId
		local userAssetIdList = action.userAssetIdList

		return Cryo.Dictionary.join(state, {
			[assetId] = userAssetIdList,
		})
	end,

	--[[
		action.assetId: string
		action.userAssetId: string
	]]
	[AddAvailableToSellAsset.name] = function(state, action)
		local assetId = action.assetId
		local userAssetId = action.userAssetId
		local newList = { userAssetId }

		local currentInfo = state[assetId]
		if currentInfo then
			newList = Cryo.List.join(currentInfo, newList)
		end

		return Cryo.Dictionary.join(state, {
			[assetId] = newList,
		})
	end,

	--[[
		action.assetId: string
		action.userAssetId: string
	]]
	[RemoveAvailableToSellAsset.name] = function(state, action)
		local assetId = action.assetId

		local currentInfo = state[assetId]
		if not currentInfo then
			return state
		end

		local newList = Cryo.List.removeValue(currentInfo, action.userAssetId)

		return Cryo.Dictionary.join(state, {
			[assetId] = newList,
		})
	end,
})