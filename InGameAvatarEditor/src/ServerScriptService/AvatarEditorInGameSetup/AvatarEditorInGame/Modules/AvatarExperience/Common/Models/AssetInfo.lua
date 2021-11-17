--[[
	Model for an Asset (e.g. Hat).
	{
		receivedCatalogData = bool,
		receivedRecommendedData = bool,
		receivedFromRecommendedData = bool,
		receivedFromBundleItemData = bool,
		receivedFromInventoryFetch = bool,
		receivedFromOutfitDetails = bool,
		receivedFromResaleData = bool,

		name = string,
		description = string,
		assetTypeId = string,
		id = number,

		priceInRobux = number,
		creator = {
			id = number,
			name = string,
			type = string,
			targetId = string,
		},
		created = string,
		updated = string,
		genre = string,
		minimumMembershipLevel = string,

		product = {
			id = string,
			type = string,
			isForSale = bool,
		}

		recommendedItemIds = {},
		favoritesCount = int,
		purchasesCount = int,
		priceStatus = string,
		itemRestrictions = {},
		itemStatus = {},
		lowestPrice = int?,
		numberRobloxHasAvailable = int?,

		resellers = {}
		self.soldCount = int
		self.averagePrice = int
		self.originalPrice = int

		isForRent = bool,
		isOwned = bool,
		isPurchasable = bool,

		expectedSellerId = string,
	}
]]
local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local MockId = require(Modules.NotLApp.MockId)

local LayeredClothingEnabled = require(Modules.Config.LayeredClothingEnabled)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)

local AssetInfo = {}

function AssetInfo.mock()
	local self = {}

	self.receivedCatalogData = false
	self.receivedRecommendedData = false
	self.receivedFromRecommendedData = false
	self.receivedFromBundleItemData = false
	self.receivedFromInventoryFetch = false
	self.receivedFromOutfitDetails = false
	self.receivedFromResaleData = false

	self.name = ""
	self.description = ""
	self.creatorName = ""
	self.assetType = "0"
	self.id = MockId()

	self.priceInRobux = 1
	self.creator = {
		id = MockId(),
		name = "",
		type = "",
		targetId = "",
	}
	self.created = ""
	self.updated = ""
	self.genres = {}
	self.minimumMembershipLevel = ""

	self.product = {
		id = MockId(),
		type = "",
		isForSale = true,
	}

	self.recommendedItemIds = {}
	self.favoritesCount = 0
	self.purchasesCount = 0
	self.priceStatus = ""
	self.itemRestrictions = {}
	self.itemStatus = {}
	self.lowestPrice = nil
	self.numberRobloxHasAvailable = nil

	self.resellers = {}

	self.soldCount = 0
	self.averagePrice = 0
	self.originalPrice = 0

	self.isForRent = false
	self.isOwned = false
	self.isPurchasable = false

	self.expectedSellerId = MockId()

	return self
end

function AssetInfo.fromGetRecommendedItems(recommendedItemIds)
	local assetInfo = {}

	assetInfo.receivedRecommendedData = true
	assetInfo.recommendedItemIds = recommendedItemIds

	return assetInfo
end

-- Optional: assetTypeId
function AssetInfo.fromGetRecommendedItemsData(recommendedItem, assetTypeId)
	local assetInfo = {}

	assetInfo.receivedFromRecommendedData = true
	if recommendedItem.item then
		assetInfo.name = recommendedItem.item.name
		assetInfo.id = tostring(recommendedItem.item.assetId)
		assetInfo.priceInRobux = recommendedItem.item.price
	end

	if recommendedItem.product and recommendedItem.product.isFree then
		assetInfo.priceInRobux = 0
	end

	if recommendedItem.product then
		assetInfo.product = {
			id = tostring(recommendedItem.product.id)
		}
	end

	if recommendedItem.creator then
		assetInfo.creator = {
			id = tostring(recommendedItem.creator.creatorId),
			name = recommendedItem.creator.name,
			type = recommendedItem.creator.type,
		}
	end

	if assetTypeId then
		assetInfo.assetType = assetTypeId
	end

	return assetInfo
end

function AssetInfo.fromGetCatalogItemData(newData)
	local assetInfo = {}

	local assetType = newData.assetType
	if type(assetType) == "string" then
		assetType = Enum.AvatarAssetType[assetType].Value
	end

	assetInfo.receivedCatalogData = true
	assetInfo.id = tostring(newData.id)
	assetInfo.assetType = tostring(assetType)
	assetInfo.name = newData.name
	assetInfo.description = newData.description
	assetInfo.product = {
		id = tostring(newData.productId)
	}

	assetInfo.genres = newData.genres
	assetInfo.creator = {
		id = tostring(newData.creatorTargetId),
		name = newData.creatorName,
		type = newData.creatorType,
	}
	assetInfo.priceInRobux = newData.price
	assetInfo.lowestPrice = newData.lowestPrice
	assetInfo.purchaseCount = newData.purchaseCount
	assetInfo.favoriteCount = newData.favoriteCount

	assetInfo.itemStatus = newData.itemStatus
	if newData.itemRestrictions then
		local restrictions = {}
		for _,val in ipairs(newData.itemRestrictions) do
			restrictions[val] = true
		end
		assetInfo.itemRestrictions = restrictions
	end

	assetInfo.priceStatus = newData.priceStatus
	assetInfo.numberRobloxHasAvailable = newData.unitsAvailableForConsumption or newData.numberRobloxHasAvailable

	assetInfo.isForRent = newData.isForRent
	assetInfo.isOwned = newData.owned
	assetInfo.isPurchasable = newData.isPurchasable
	assetInfo.expectedSellerId = tostring(newData.expectedSellerId)

	return assetInfo
end

function AssetInfo.fromBundleItemData(newData)
	local assetInfo = {}

	assetInfo.receivedFromBundleItemData = true
	assetInfo.id = tostring(newData.id)
	assetInfo.name = newData.name
	assetInfo.isOwned = newData.owned

	return assetInfo
end

function AssetInfo.fromSortResults(newData)
	local assetInfo = {}

	local assetType = newData.assetType
	if type(assetType) == "string" then
		assetType = Enum.AvatarAssetType[assetType].Value
	end

	assetInfo.receivedFromSortResults = true
	assetInfo.id = tostring(newData.id)
	assetInfo.assetType = tostring(assetType)
	assetInfo.name = newData.name
	assetInfo.description = newData.description
	assetInfo.product = {
		id = tostring(newData.productId)
	}
	assetInfo.genres = newData.genres

	assetInfo.creator = {
		id = tostring(newData.creatorTargetId),
		name = newData.creatorName,
		type = newData.creatorType,
	}

	assetInfo.priceInRobux = newData.price
	assetInfo.lowestPrice = newData.lowestPrice
	assetInfo.purchaseCount = newData.purchaseCount
	assetInfo.favoriteCount = newData.favoriteCount

	assetInfo.itemStatus = newData.itemStatus
	if newData.itemRestrictions then
		local restrictions = {}
		for _,val in ipairs(newData.itemRestrictions) do
			restrictions[val] = true
		end
		assetInfo.itemRestrictions = restrictions
	end

	assetInfo.priceStatus = newData.priceStatus
	assetInfo.numberRobloxHasAvailable = newData.unitsAvailableForConsumption or newData.numberRobloxHasAvailable

	return assetInfo
end

function AssetInfo.fromInventoryFetch(newData, assetType)
	local assetInfo = {}

	assetInfo.receivedFromInventoryFetch = true
	assetInfo.id = tostring(newData.assetId)
	assetInfo.name = newData.assetName or newData.name
	if LayeredClothingEnabled then
		assetInfo.assetType = AvatarExperienceConstants.AssetTypeIds[newData.assetType]
	else
		assetInfo.assetType = assetType
	end

	return assetInfo
end

function AssetInfo.fromOutfitDetails(newData)
	local assetInfo = {}

	assetInfo.receivedFromOutfitDetails = true
	assetInfo.id = tostring(newData.id)
	assetInfo.name = newData.name
	assetInfo.assetType = tostring(newData.assetType.id)

	return assetInfo
end

function AssetInfo.fromGetResellers(userAssetIds)
	local assetInfo = {}

	assetInfo.resellerUserAssetIds = userAssetIds

	return assetInfo
end

function AssetInfo.fromLowestPrice(lowestPrice)
	local assetInfo = {}

	assetInfo.lowestPrice = lowestPrice

	return assetInfo
end

function AssetInfo.fromResaleData(newData)
	local assetInfo = {}

	assetInfo.receivedFromResaleData = true
	assetInfo.soldCount = newData.sales
	assetInfo.averagePrice = newData.recentAveragePrice
	assetInfo.originalPrice = newData.originalPrice

	return assetInfo
end

function AssetInfo.fromIsOwned(isOwned)
	local assetInfo = {}
	assetInfo.isOwned = isOwned
	return assetInfo
end

return AssetInfo
