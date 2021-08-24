--[[
	Model for a Bundle.
	{
		receivedBundleDetails = bool
		receivedCatalogData = bool
		receivedRecommendedData = bool
		receivedFromRecommendedData = bool

		name = string,
		description = string,
		bundleType = string,
		id = string,

		items = table of tables
			Example: {
				{
					owned = "",
					id = "",
					name = "",
					type = "",
				}
			},
		creator = {
			id = number,
			name = string,
			type = string,
		},
		priceInRobux = number or nil,
		isPublicDomain = bool,
		product = {
			id = number,
			type = string
			isForSale = bool,
		}
	}

	isForRent = bool,
	isOwned = bool,
	isPurchasable = bool,
	expectedSellerId = string,
]]
local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local MockId = require(Modules.NotLApp.MockId)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local FFlagLuaCatalogRedirectOwnedBundleToCorrectCategory = true
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)

local BundleInfo = {}

function BundleInfo.mock()
	local self = {}

	self.receivedBundleDetails = false
	self.receivedCatalogData = false
	self.receivedRecommendedData = false
	self.receivedFromRecommendedData = false

	self.name = ""
	self.description = ""
	self.bundleType = ""

	self.id = ""
	self.items = {}

	self.creator = {
		id = MockId(),
		name = "",
		type = "",
	}

	self.priceInRobux = 1
	self.isPublicDomain = true
	self.product = {
		id = MockId(),
		type = "",
		isForSale = true,
	}

	self.recommendedItemIds = {}
	self.favoritesCount = 0
	self.purchasesCount = 0
	self.productId = 0

	self.priceStatus = ""
	self.itemRestrictions = {}
	self.itemStatus = {}
	self.lowestPrice = nil
	self.numberRobloxHasAvailable = nil

	self.isForRent = false
	self.isOwned = false
	self.isPurchasable = false

	self.expectedSellerId = MockId()

	return self
end

local function getRobuxPrice(priceInRobux, isPublicDomain)
	if not priceInRobux and isPublicDomain then
		priceInRobux = 0
	end
	return priceInRobux
end

local function getBundleType(checkBundleType)
	local bundleType
	if FFlagLuaCatalogRedirectOwnedBundleToCorrectCategory then
		if checkBundleType == AvatarExperienceConstants.BundleTypeAsString.BodyParts then
			bundleType = AvatarExperienceConstants.BundleType.BodyParts
		elseif checkBundleType == AvatarExperienceConstants.BundleTypeAsString.AvatarAnimations then
			bundleType = AvatarExperienceConstants.BundleType.AvatarAnimations
		else
			bundleType = tostring(checkBundleType)
		end
	else
		if checkBundleType == 1 then
			bundleType = CatalogConstants.BundleType.BodyParts
		elseif checkBundleType == 2 then
			bundleType = CatalogConstants.BundleType.AvatarAnimations
		else
			bundleType = tostring(checkBundleType)
		end
	end

	return bundleType
end

function BundleInfo.fromMultigetBundle(newBundleInfo)
	local bundleInfo = {}
	bundleInfo.receivedBundleDetails = true

	bundleInfo.name = newBundleInfo.name
	bundleInfo.description = newBundleInfo.description

	-- TODO AVBURST-2084: Fix this when the APIs return consistent results
	bundleInfo.bundleType = getBundleType(newBundleInfo.bundleType)

	local includedItemList = {}
	if newBundleInfo.items then
		for _, bundleItem in pairs(newBundleInfo.items) do
			local includedItem = {
				id = tostring(bundleItem.id),
				type = bundleItem.type,
			}
			table.insert(includedItemList, includedItem)
		end
		bundleInfo.items = includedItemList
	end

	if newBundleInfo.creator ~= nil then
		bundleInfo.creator = {
			id = tostring(newBundleInfo.creator.id),
			name = newBundleInfo.creator.name,
			type = newBundleInfo.creator.type,
			targetId = newBundleInfo.creator.targetId,
		}
	end

	if newBundleInfo.product ~= nil then
		-- PriceInRobux and isPublicDomain are separate from the product
		-- to remove inconsistencies between BundleInfo and AssetInfo
		bundleInfo.isPublicDomain = newBundleInfo.product.isPublicDomain == true
		bundleInfo.priceInRobux = getRobuxPrice(newBundleInfo.product.priceInRobux, newBundleInfo.product.isPublicDomain)
		bundleInfo.product = {
			id = tostring(newBundleInfo.product.id),
			type = newBundleInfo.product.type,
			isForSale = newBundleInfo.product.isForSale,
		}
	end

	return bundleInfo
end

function BundleInfo.fromGetCatalogItemData(newData)
	local bundleInfo = {}

	bundleInfo.receivedCatalogData = true
	bundleInfo.id = tostring(newData.id)
	bundleInfo.itemType = newData.itemType
	-- TODO AVBURST-2084 Fix this when the APIs return consistent results
	bundleInfo.bundleType = getBundleType(newData.bundleType)
	bundleInfo.name = newData.name
	bundleInfo.description = newData.description
	bundleInfo.product = {
		id = tostring(newData.productId),
	}

	bundleInfo.genres = newData.genres
	bundleInfo.creator = {
		id = tostring(newData.creatorTargetId),
		name = newData.creatorName,
		type = newData.creatorType,
	}

	bundleInfo.priceInRobux = newData.price
	bundleInfo.purchaseCount = newData.purchaseCount
	bundleInfo.favoriteCount = newData.favoriteCount

	bundleInfo.itemStatus = newData.itemStatus
	if newData.itemRestrictions then
		local restrictions = {}
		for _, val in ipairs(newData.itemRestrictions) do
			restrictions[val] = true
		end
		bundleInfo.itemRestrictions = restrictions
	end

	bundleInfo.lowestPrice = newData.lowestPrice
	bundleInfo.priceStatus = newData.priceStatus
	bundleInfo.numberRobloxHasAvailable = newData.unitsAvailableForConsumption or newData.numberRobloxHasAvailable

	bundleInfo.isForRent = newData.isForRent
	bundleInfo.isOwned = newData.owned
	bundleInfo.isPurchasable = newData.isPurchasable
	bundleInfo.expectedSellerId = tostring(newData.expectedSellerId)

	local includedItemList = {}
	if newData.bundledItems then
		for _, bundleItem in pairs(newData.bundledItems) do
			local includedItem = {
				id = tostring(bundleItem.id),
				type = bundleItem.type,
			}
			table.insert(includedItemList, includedItem)
		end
		bundleInfo.items = includedItemList
	end

	return bundleInfo
end

function BundleInfo.fromGetRecommendedItems(recommendedItemIds)
	local bundleInfo = {}

	bundleInfo.receivedRecommendedData = true
	bundleInfo.recommendedItemIds = recommendedItemIds

	return bundleInfo
end

function BundleInfo.fromGetRecommendedBundleItemsData(newData)
	local bundleInfo = {}

	bundleInfo.receivedFromRecommendedData = true

	-- TODO AVBURST-2084: Fix this when the APIs return consistent results
	bundleInfo.bundleType = getBundleType(newData.bundleType)
	bundleInfo.name = newData.name
	bundleInfo.description = newData.description
	bundleInfo.id = tostring(newData.id)

	if newData.product then
		bundleInfo.product = {
			id = tostring(newData.product.id),
			type = newData.product.type,
			isForSale = newData.product.isForSale,
		}
	end

	bundleInfo.creator = {
		id = newData.creatorTargetId,
		name = newData.creatorName,
		type = newData.creatorType,
	}

	return bundleInfo
end

function BundleInfo.fromSortResults(newData)
	local bundleInfo = {}

	bundleInfo.receivedFromSortResults = true
	bundleInfo.id = tostring(newData.id)
	-- TODO AVBURST-2084: Fix this when the APIs return consistent results
	bundleInfo.bundleType = getBundleType(newData.bundleType)
	bundleInfo.name = newData.name
	bundleInfo.description = newData.description
	bundleInfo.product = {
		id = tostring(newData.productId),
	}

	bundleInfo.genres = newData.genres
	bundleInfo.creator = {
		id = tostring(newData.creatorTargetId),
		name = newData.creatorName,
		type = newData.creatorType,
	}

	bundleInfo.priceInRobux = newData.price
	bundleInfo.lowestPrice = newData.lowestPrice
	bundleInfo.purchaseCount = newData.purchaseCount
	bundleInfo.favoriteCount = newData.favoriteCount

	bundleInfo.itemStatus = newData.itemStatus
	if newData.itemRestrictions then
		local restrictions = {}
		for _, val in ipairs(newData.itemRestrictions) do
			restrictions[val] = true
		end
		bundleInfo.itemRestrictions = restrictions
	end

	bundleInfo.priceStatus = newData.priceStatus
	bundleInfo.numberRobloxHasAvailable = newData.unitsAvailableForConsumption or newData.numberRobloxHasAvailable
	return bundleInfo
end

function BundleInfo.fromIsOwned(isOwned)
	local bundleInfo = {}
	bundleInfo.isOwned = isOwned
	return bundleInfo
end

return BundleInfo