local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)

local CatalogUtils = {}

function CatalogUtils.GetItemSubType(itemType, itemInfo)
	if not itemInfo then
		return
	end
	if itemType == CatalogConstants.ItemType.Asset then
		return itemInfo.assetType
	elseif itemType == CatalogConstants.ItemType.Bundle then
		return itemInfo.bundleType
	else
		return nil
	end
end

function CatalogUtils.Round(num)
	return math.floor(num + 0.5)
end

function CatalogUtils.IsResellable(itemInfo)
	if not itemInfo then
		return
	end

	local numberRobloxHasAvailable = itemInfo.numberRobloxHasAvailable
	local itemRestrictions = itemInfo.itemRestrictions
	local isLimited = itemRestrictions and itemRestrictions[CatalogConstants.ItemRestrictions.Limited]
	local isLimitedUnique = itemRestrictions and itemRestrictions[CatalogConstants.ItemRestrictions.LimitedUnique]
	return isLimited or (isLimitedUnique and numberRobloxHasAvailable and numberRobloxHasAvailable == 0)
end

function CatalogUtils.GetRbxThumbType(itemType)
	if itemType == CatalogConstants.ItemType.Asset then
		return CatalogConstants.ThumbnailType.Asset
	elseif itemType == CatalogConstants.ItemType.Bundle then
		return CatalogConstants.ThumbnailType.BundleThumbnail
	else
		return nil
	end
end

function CatalogUtils.MakeRbxThumbUrl(thumbType, targetId, width, height)
	assert(type(targetId) == "string", "CatalogUtils.MakeRbxThumbUrl expects targetId to be a string.")
	assert(type(thumbType) == "string", "CatalogUtils.MakeRbxThumbUrl expects thumbType to be a string.")
	assert(type(height) == "number", "CatalogUtils.MakeRbxThumbUrl expects height to be a number.")
	assert(type(width) == "number", "CatalogUtils.MakeRbxThumbUrl expects width to be a number.")
	return string.format("rbxthumb://type=%s&id=%s&w=%s&h=%s", thumbType, targetId, width, height)
end

function CatalogUtils.GetItemDetailsKey(itemId, itemType)
	if not itemId or not itemType then
		return CatalogConstants.ItemDetailsKey
	end
	return CatalogConstants.ItemDetailsKey .. itemId .. itemType
end

function CatalogUtils.GetSortDataStatus(state, categoryIndex, subcategoryIndex)
	local dataStatusTable = state.AvatarExperience.Catalog.SortsContents.DataStatus

	local categoryTable = dataStatusTable[categoryIndex]
	if categoryTable then
		local dataStatus = categoryTable[subcategoryIndex]
		if dataStatus then
			return dataStatus
		end
	end

	return RetrievalStatus.NotStarted
end


return CatalogUtils