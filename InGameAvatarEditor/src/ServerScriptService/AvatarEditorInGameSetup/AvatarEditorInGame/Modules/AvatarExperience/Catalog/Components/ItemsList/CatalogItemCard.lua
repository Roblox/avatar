-- Props:
-- itemId (string)
-- itemType (string)
-- index (number)

local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local RoactServices = require(Modules.Common.RoactServices)

local UIBlox = require(Modules.Packages.UIBlox)

local AppPage = require(Modules.NotLApp.AppPage)
local AnimationTabs = require(Modules.AvatarExperience.Catalog.Components.ItemsList.AnimationTabs)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local CatalogUtils = require(Modules.AvatarExperience.Catalog.CatalogUtils)
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local SetItemDetailsProps = require(Modules.Setup.Actions.SetItemDetailsProps)

local CloseAllItemDetails = require(Modules.AvatarExperience.Catalog.Thunks.CloseAllItemDetails)
local OpenNewItemDetailsPage = require(Modules.AvatarExperience.Catalog.Thunks.OpenNewItemDetailsPage)

local ItemData = require(Modules.AvatarExperience.Common.Selectors.ItemData)

local ItemTile = UIBlox.Tile.ItemTile
local ItemTileEnums = UIBlox.Tile.ItemTileEnums
local ItemCardFooter = require(Modules.AvatarExperience.Catalog.Components.ItemsList.ItemCardFooter)

local THUMBNAIL_SIZE = CatalogConstants.ThumbnailSize["150"]
local NEW_TEXT_KEY = "Feature.Catalog.Label.New"
local SALE_TEXT_KEY = "Feature.Catalog.Label.Sale"

local CatalogItemCard = Roact.PureComponent:extend("CatalogItemCard")

function CatalogItemCard:init()
	self.peekAndTryOn = function()
		if self.props.isSelected then
			self.props.closeAllItemDetails()
			return
		end

		if not self.props.itemId then
			return
		end

		local itemId = self.props.itemId
		local itemType = self.props.itemType

		local navDetail = itemType .. itemId
		local extraProps = {
			itemId = itemId,
			itemType = itemType,
		}

		self.props.setItemDetailsProps(itemId, itemType)
		self.props.openNewItemDetailsPage({ name = AppPage.ItemDetails, detail = navDetail, extraProps = extraProps })
	end
end

function CatalogItemCard:render()
	local isSelected = self.props.isSelected
	local itemData = self.props.itemData
	local itemId = self.props.itemId
	local itemType = self.props.itemType
	local restrictionTypes = self.props.restrictionTypes
	local statusStyle = self.props.statusStyle
	local statusText = self.props.statusText

	local itemIconType = itemType == CatalogConstants.ItemType.Bundle and ItemTileEnums.ItemIconType.Bundle or nil
	local thumbType = itemType and CatalogUtils.GetRbxThumbType(itemType) or nil
	local thumbnailUrl = itemId and CatalogUtils.MakeRbxThumbUrl(thumbType, itemId, THUMBNAIL_SIZE, THUMBNAIL_SIZE) or nil
	local name = itemData and itemData.name
	local price = itemData and (itemData.lowestPrice or itemData.priceInRobux) or nil
	local isPriceLoaded = itemData ~= nil

	local isAnimationBundle = itemData and itemData.bundleType == AvatarExperienceConstants.BundleType.AvatarAnimations

	return withLocalization({
		statusText = statusText,
	})(function(localized)
		return Roact.createFragment({
			AnimationTabs = isSelected and isAnimationBundle and Roact.createElement(AnimationTabs, {
				bundleDetails = itemData,
			}),

			Tile = Roact.createElement(ItemTile, {
				itemIconType = itemIconType,
				isSelected = isSelected,
				name = name,
				restrictionTypes = restrictionTypes,
				statusStyle = statusStyle,
				statusText = localized.statusText,
				onActivated = self.peekAndTryOn,
				thumbnail = thumbnailUrl,
				footer = Roact.createElement(ItemCardFooter, {
					price = price,
					isPriceLoaded = isPriceLoaded,
				}),
			}),
		})
	end)
end

local function cardIsSelected(state, props)
	local selectedItem = state.AvatarExperience.AvatarScene.TryOn.SelectedItem

	if props.itemId and props.itemId == selectedItem.itemId then
		return true
	end

	return false
end

local function getRestrictions(itemData)
	if not itemData then
		return
	end

	local itemRestrictions = itemData.itemRestrictions
	if not itemRestrictions then
		return
	end

	local isLimited = itemRestrictions[CatalogConstants.ItemRestrictions.Limited]
	local isLimitedUnique = itemRestrictions[CatalogConstants.ItemRestrictions.LimitedUnique]

	if not (isLimited or isLimitedUnique) then
		return
	end

	return {
		[ItemTileEnums.Restriction.Limited] = isLimited and true or nil,
		[ItemTileEnums.Restriction.LimitedUnique] = isLimitedUnique and true or nil,
	}
end

local function getStatus(itemData)
	if not itemData then
		return
	end

	local itemStatus = itemData.itemStatus
	if not itemStatus then
		return
	end

	if #itemStatus == 0 then
		return
	end

	local statusMap = {}
	for _, status in ipairs(itemStatus) do
		statusMap[status] = true
	end

	local statusStyle, statusText
	if statusMap[CatalogConstants.ItemStatus.Sale] then
		statusStyle = ItemTileEnums.StatusStyle.Alert
		statusText = SALE_TEXT_KEY
	elseif statusMap[CatalogConstants.ItemStatus.New] then
		statusStyle = ItemTileEnums.StatusStyle.Info
		statusText = NEW_TEXT_KEY
	end

	return statusStyle, statusText
end

local function mapStateToProps(state, props)
	local itemData = ItemData(state.AvatarExperience.Common, props.itemId, props.itemType)
	local statusStyle, statusText = getStatus(itemData)

	return {
		categoryIndex = state.AvatarExperience.Catalog.Categories.category,
		subcategoryIndex = state.AvatarExperience.Catalog.Categories.subcategory,
		itemData = itemData,
		isSelected = cardIsSelected(state, props),
		restrictionTypes = getRestrictions(itemData),
		statusStyle = statusStyle,
		statusText = statusText,
	}
end

local function mapDispatchToProps(dispatch)
    return {
		closeAllItemDetails = function()
			dispatch(CloseAllItemDetails())
		end,

		openNewItemDetailsPage = function(page)
			dispatch(OpenNewItemDetailsPage(page))
		end,

		setItemDetailsProps = function(itemId, itemType)
			dispatch(SetItemDetailsProps(itemId, itemType))
		end,
    }
end

CatalogItemCard = RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(CatalogItemCard)

return CatalogItemCard
