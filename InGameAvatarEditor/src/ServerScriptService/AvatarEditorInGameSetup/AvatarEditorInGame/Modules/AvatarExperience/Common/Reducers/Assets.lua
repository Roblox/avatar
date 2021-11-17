local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local ArgCheck = require(Modules.Common.ArgCheck)
local Cryo = require(Modules.Packages.Cryo)

local AssetInfo = require(Modules.AvatarExperience.Common.Models.AssetInfo)
local SetRecommendedAssetsAction = require(Modules.AvatarExperience.Catalog.Actions.SetRecommendedAssetsAction)
local SetAssetInfoFromInventoryFetch =
	require(Modules.AvatarExperience.AvatarEditor.Actions.SetAssetInfoFromInventoryFetch)
local SetAssetInfoFromOutfitDetails =
	require(Modules.AvatarExperience.AvatarEditor.Actions.SetAssetInfoFromOutfitDetails)
local SetAssetInfoFromCatalogItemAction =
	require(Modules.AvatarExperience.Catalog.Actions.SetAssetInfoFromCatalogItemAction)
local SetAssetInfoFromBundleItemAction =
	require(Modules.AvatarExperience.Catalog.Actions.SetAssetInfoFromBundleItemAction)
local SetAssetInfoFromSortResults = require(Modules.AvatarExperience.Catalog.Actions.SetAssetInfoFromSortResults)
local SetAssetInfoFromAvatarEditorRecommendedItems =
	require(Modules.AvatarExperience.AvatarEditor.Actions.SetAssetInfoFromAvatarEditorRecommendedItems)
local AppendAssetResellersList = require(Modules.AvatarExperience.Catalog.Actions.AppendAssetResellersList)
local SetAssetResellersList = require(Modules.AvatarExperience.Catalog.Actions.SetAssetResellersList)
local SetAssetLowestPrice = require(Modules.AvatarExperience.Catalog.Actions.SetAssetLowestPrice)
local SetAssetResaleData = require(Modules.AvatarExperience.Catalog.Actions.SetAssetResaleData)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local SetAssetOwned = require(Modules.AvatarExperience.Common.Actions.SetAssetOwned)

return function(state, action)
	state = state or {}

	if action.type == SetAssetInfoFromCatalogItemAction.name then
        ArgCheck.isType(action.assetId, "string", "assetId must be a string.")
        ArgCheck.isType(action.assetData, "table", "assetData must be a table.")

		local assetId = tostring(action.assetId)
		local assetDataInfo = AssetInfo.fromGetCatalogItemData(action.assetData)

		local existingInfo = state[assetId]
		if existingInfo then
			local newData = Cryo.Dictionary.join(existingInfo, assetDataInfo)
			return Cryo.Dictionary.join(state, { [assetId] = newData })
		else
			return Cryo.Dictionary.join(state, { [assetId] = assetDataInfo })
		end

	elseif action.type == SetAssetInfoFromBundleItemAction.name then
		ArgCheck.isType(action.assets, "table", "assets data must be a table.")

		local changedAssets = {}
		for _, assetData in pairs(action.assets) do
			local assetId = tostring(assetData.id)
			local assetDataInfo = AssetInfo.fromBundleItemData(assetData)

			local existingInfo = state[assetId]
			if existingInfo then
				changedAssets[assetId] = Cryo.Dictionary.join(existingInfo, assetDataInfo)
			else
				changedAssets[assetId] = assetDataInfo
			end
		end

		return Cryo.Dictionary.join(state, changedAssets)

	elseif action.type == SetAssetInfoFromSortResults.name then
		ArgCheck.isType(action.sortResults, "table", "sortResults must be a table.")

		local changedAssets = {}
		for _, assetData in pairs(action.sortResults) do
			local assetId = tostring(assetData.id)
			local assetDataInfo = AssetInfo.fromSortResults(assetData)

			local existingInfo = state[assetId]
			if existingInfo then
				changedAssets[assetId] = Cryo.Dictionary.join(existingInfo, assetDataInfo)
			else
				changedAssets[assetId] = assetDataInfo
			end
		end

		return Cryo.Dictionary.join(state, changedAssets)

	elseif action.type == SetRecommendedAssetsAction.name then
		ArgCheck.isType(action.recommendedItems, "table", "recommendedItems must be a table.")

		local assetId = tostring(action.assetId)
		local changedAssets = {}
		local recommendedAssets = {}

		for _, recommendedItem in pairs(action.recommendedItems) do
			local recommendedAssetId = tostring(recommendedItem.item.assetId)
			local recommendedAssetInfo = AssetInfo.fromGetRecommendedItemsData(recommendedItem, action.assetTypeId)

			local currentRecommendedInfo = state[recommendedAssetId]
			if not currentRecommendedInfo then
				changedAssets[recommendedAssetId] = recommendedAssetInfo
			elseif not currentRecommendedInfo.receivedFromRecommendedData and not currentRecommendedInfo.receivedCatalogData then
				changedAssets[recommendedAssetId] = Cryo.Dictionary.join(currentRecommendedInfo, recommendedAssetInfo)
			end

			recommendedAssets[#recommendedAssets + 1] = {
				id = recommendedAssetId,
				type = CatalogConstants.ItemType.Asset,
			}
		end

		local assetRecommendedItemsInfo = AssetInfo.fromGetRecommendedItems(recommendedAssets)

		-- Update the asset's recommended id list
		local existingInfo = state[assetId]
		if existingInfo then
			changedAssets[assetId] = Cryo.Dictionary.join(existingInfo, assetRecommendedItemsInfo)
		else
			changedAssets[assetId] = assetRecommendedItemsInfo
		end

		return Cryo.Dictionary.join(state, changedAssets)

	elseif action.type == SetAssetResaleData.name then
		ArgCheck.isType(action.assetResaleData, "table", "assetResaleData must be a table.")

		local assetId = tostring(action.assetId)
		local assetResaleInfo = AssetInfo.fromResaleData(action.assetResaleData)

		local existingInfo = state[assetId]
		if existingInfo then
			return Cryo.Dictionary.join(state, {
				[assetId] = Cryo.Dictionary.join(existingInfo, assetResaleInfo),
			})
		else
			return Cryo.Dictionary.join(state, {
				[assetId] = assetResaleInfo,
			})
		end

	elseif action.type == SetAssetInfoFromInventoryFetch.name then
		ArgCheck.isType(action.assets, "table", "assets must be a table.")
		ArgCheck.isTypeOrNil(action.assetTypeId, "string", "assetTypeId must be a string.")

		local changedAssets = {}
		local assetTypeId = action.assetTypeId

		for _, assetData in pairs(action.assets) do
			local assetId = tostring(assetData.assetId)
			local inventoryAssetInfo = AssetInfo.fromInventoryFetch(assetData, assetTypeId)

			local existingInfo = state[assetId]
			if existingInfo then
				changedAssets[assetId] = Cryo.Dictionary.join(existingInfo, inventoryAssetInfo)
			else
				changedAssets[assetId] = inventoryAssetInfo
			end
		end

		return Cryo.Dictionary.join(state, changedAssets)

	elseif action.type == SetAssetInfoFromOutfitDetails.name then
		ArgCheck.isType(action.assets, "table", "assets must be a table.")

		local changedAssets = {}
		for _, assetData in pairs(action.assets) do
			local assetId = tostring(assetData.id)
			local assetDataInfo = AssetInfo.fromOutfitDetails(assetData)

			local existingInfo = state[assetId]
			if existingInfo then
				changedAssets[assetId] = Cryo.Dictionary.join(existingInfo, assetDataInfo)
			else
				changedAssets[assetId] = assetDataInfo
			end
		end

		return Cryo.Dictionary.join(state, changedAssets)

	elseif action.type == SetAssetResellersList.name then
		ArgCheck.isType(action.assetId, "string", "assetId must be a sting.")
		ArgCheck.isType(action.userAssetIds, "table", "userAssetIds must be a table.")

		local assetId = tostring(action.assetId)
		local resellerAssetInfo = AssetInfo.fromGetResellers(action.userAssetIds)

		local existingInfo = state[assetId]
		if existingInfo then
			return Cryo.Dictionary.join(state, {
				[assetId] = Cryo.Dictionary.join(existingInfo, resellerAssetInfo),
			})
		else
			return Cryo.Dictionary.join(state, {
				[assetId] = resellerAssetInfo,
			})
		end

	elseif action.type == AppendAssetResellersList.name then
		ArgCheck.isType(action.assetId, "string", "assetId must be a sting.")
		ArgCheck.isType(action.userAssetIds, "table", "userAssetIds must be a table.")

		local assetId = tostring(action.assetId)

		local existingInfo = state[assetId]
		if existingInfo then
			local existingResellersList = existingInfo.resellerUserAssetIds

			local resellerUserAssetIds
			if existingResellersList then
				resellerUserAssetIds = Cryo.List.join(existingResellersList, action.userAssetIds)
			else
				resellerUserAssetIds = action.userAssetIds
			end

			local resellerAssetInfo = AssetInfo.fromGetResellers(resellerUserAssetIds)
			return Cryo.Dictionary.join(state, {
				[assetId] = Cryo.Dictionary.join(existingInfo, resellerAssetInfo),
			})
		else
			local resellerAssetInfo = AssetInfo.fromGetResellers(action.userAssetIds)
			return Cryo.Dictionary.join(state, {
				[assetId] = resellerAssetInfo,
			})
		end

	elseif action.type == SetAssetLowestPrice.name then
		ArgCheck.isType(action.assetId, "string", "assetId must be a sting.")
		ArgCheck.isType(action.priceInRobux, "number", "price must be a number.")

        local assetId = action.assetId
		local lowestPrice = action.priceInRobux
		local lowestPriceAssetInfo = AssetInfo.fromLowestPrice(lowestPrice)

		local existingInfo = state[assetId]
		if existingInfo then
			return Cryo.Dictionary.join(state, {
				[assetId] = Cryo.Dictionary.join(existingInfo, lowestPriceAssetInfo),
			})
		else
			return Cryo.Dictionary.join(state, {
				[assetId] = lowestPriceAssetInfo,
			})
		end

	elseif action.type == SetAssetInfoFromAvatarEditorRecommendedItems.name then
		ArgCheck.isType(action.assets, "table", "assets must be a table.")
		ArgCheck.isType(action.assetTypeId, "string", "assetTypeId must be a string.")

		local assetTypeId = action.assetTypeId

		local changedAssets = {}
		for _, recommendedItem in pairs(action.assets) do
			local recommendedAssetId = tostring(recommendedItem.item.assetId)
			local recommendedAssetInfo = AssetInfo.fromGetRecommendedItemsData(recommendedItem, assetTypeId)

			local currentRecommendedInfo = state[recommendedAssetId]
			if not currentRecommendedInfo then
				changedAssets[recommendedAssetId] = recommendedAssetInfo
			elseif not currentRecommendedInfo.receivedFromRecommendedData and not currentRecommendedInfo.receivedCatalogData then
				changedAssets[recommendedAssetId] = Cryo.Dictionary.join(currentRecommendedInfo, recommendedAssetInfo)
			end
		end

		return Cryo.Dictionary.join(state, changedAssets)

    elseif action.type == SetAssetOwned.name then
        ArgCheck.isType(action.assetId, "string", "assetId must be a string.")
        ArgCheck.isType(action.isOwned, "boolean", "isOwned must be a bool.")

		local assetId = tostring(action.assetId)
		local assetDataInfo = AssetInfo.fromIsOwned(action.isOwned)

		local existingInfo = state[assetId]
		if existingInfo then
			local newData = Cryo.Dictionary.join(existingInfo, assetDataInfo)
			return Cryo.Dictionary.join(state, { [assetId] = newData })
		else
			return Cryo.Dictionary.join(state, { [assetId] = assetDataInfo })
		end
	end


	return state
end
