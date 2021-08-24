local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)
local SetCurrentlySellingAssetsFromFetchSellData =
	require(Modules.AvatarExperience.Catalog.Actions.SetCurrentlySellingAssetsFromFetchSellData)
local AddCurrentlySellingAsset = require(Modules.AvatarExperience.Catalog.Actions.AddCurrentlySellingAsset)
local RemoveCurrentlySellingAsset = require(Modules.AvatarExperience.Catalog.Actions.RemoveCurrentlySellingAsset)
local Cryo = require(Modules.Packages.Cryo)

return Rodux.createReducer({}, {
	--[[
		action.assetId: string
		action.userAssetIdList: table
	]]
	[SetCurrentlySellingAssetsFromFetchSellData.name] = function(state, action)
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
	[AddCurrentlySellingAsset.name] = function(state, action)
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
	[RemoveCurrentlySellingAsset.name] = function(state, action)
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