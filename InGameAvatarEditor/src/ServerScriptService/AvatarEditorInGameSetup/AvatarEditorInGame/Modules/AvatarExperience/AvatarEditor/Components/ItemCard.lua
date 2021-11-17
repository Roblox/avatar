local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local UIBlox = require(Modules.Packages.UIBlox)
local ItemTile = UIBlox.Tile.ItemTile
local ItemTileEnums = UIBlox.Tile.ItemTileEnums
local SaveTile = UIBlox.Tile.SaveTile

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local Logging = require(Modules.Packages.Logging)

local Constants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local FetchItemData = require(Modules.AvatarExperience.Catalog.Thunks.FetchItemData)
local EquipOutfit = require(Modules.AvatarExperience.AvatarEditor.Thunks.EquipOutfit)
local ToggleEquipAsset = require(Modules.AvatarExperience.AvatarEditor.Thunks.ToggleEquipAsset)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local AvatarEditorUtils = require(Modules.AvatarExperience.AvatarEditor.Utils)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local CatalogUtils = require(Modules.AvatarExperience.Catalog.CatalogUtils)
local ItemData = require(Modules.AvatarExperience.Common.Selectors.ItemData)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local Categories = require(Modules.AvatarExperience.AvatarEditor.Categories)
local ToggleUIFullView = require(Modules.AvatarExperience.AvatarEditor.Actions.ToggleUIFullView)

local OverlayType = require(Modules.NotLApp.Enum.OverlayType)
local SetCentralOverlay = require(Modules.NotLApp.Actions.SetCentralOverlay)

local CreateOutfit = require(Modules.AvatarExperience.AvatarEditor.Thunks.CreateOutfit)

local LayeredClothingEnabled = require(Modules.Config.LayeredClothingEnabled)

local FFlagAvatarEditorShowEquippedItem = true

local THUMBNAIL_SIZE = CatalogConstants.ThumbnailSize["150"]
local ADD_COSTUME_BUTTON = AvatarEditorConstants.AddCostumeButton

local ItemCard = Roact.PureComponent:extend("ItemCard")

local function isWearingAssetOrCostume(state, page, itemId, isCostume)
	local equippedAssets = state.AvatarExperience.AvatarEditor.Character.EquippedAssets
	local costumeInfo = state.AvatarExperience.AvatarEditor.Outfits
	local emotesSlotInfo = state.AvatarExperience.AvatarEditor.EquippedEmotes.slotInfo
	local selectedEmoteSlot = state.AvatarExperience.AvatarEditor.EquippedEmotes.selectedSlot

	if page.PageType == AvatarExperienceConstants.PageType.Emotes then
		local emoteInfo = emotesSlotInfo[selectedEmoteSlot]

		if emoteInfo then
			return emoteInfo.assetId == itemId
		end

		return false
	end

	if not equippedAssets then
		return false
	end

	if isCostume and costumeInfo[itemId] then
		local outfit = costumeInfo[itemId]

		return AvatarEditorUtils.isWearingOutfit(state, outfit)
	else
		for _, assetList in pairs(equippedAssets) do
			for _, equippedAssetId in pairs(assetList) do
				if equippedAssetId == itemId then
					return true
				end
			end
		end
	end

	return false
end

function ItemCard:init()
	self.toggleEquip = function()
		local itemId = self.props.itemId
		if not itemId then
			return
		end

		local page = self.props.page
		local isCostume = self.props.isCostume
		local costumeInfo = self.props.costumeInfo
		local assetTypeId = isCostume and Constants.Outfits or page.AssetTypeId
		if LayeredClothingEnabled and not isCostume then
			assetTypeId = self.props.assetTypeId
		end

		local isSelected = self.props.isWearingAssetOrCostume
		local toggleEquipAsset = self.props.toggleEquipAsset
		local equipOutfitThunk = self.props.equipOutfitThunk
		local isUIFullView = self.props.isUIFullView

		if LayeredClothingEnabled then
			local isLayered = AvatarExperienceConstants.LayeredClothingOrder[assetTypeId] ~= nil
			local isR6 = self.props.avatarType == AvatarExperienceConstants.AvatarType.R6

			local onSwitchSelected = function()
				toggleEquipAsset(assetTypeId, itemId)
			end

			if isR6 and (not isSelected) and isLayered then
				self.props.openLayeredClothingR15Upgrade(onSwitchSelected)
				return
			end
		end

		if isCostume then
			if costumeInfo then
				equipOutfitThunk(costumeInfo)
			else
				Logging.warn("Tried equipping a costume without any costume data!")
			end
		else
			toggleEquipAsset(assetTypeId, itemId)
		end

		if FFlagAvatarEditorShowEquippedItem and not isSelected and isUIFullView then
			self.props.toggleUIFullView()
		end
	end

	self.openCreateCostumesPrompt = function()
		local currentPage = self.props.currentPage
		self.props.openCreateCostumesPrompt({ currentPage })
	end
end

function ItemCard:render()
	local isCostume = self.props.isCostume
	local itemId = self.props.itemId
	local name = self.props.name
	local thumbnail = self.props.thumbnail

	if itemId == ADD_COSTUME_BUTTON then
		return Roact.createElement(SaveTile, {
			onActivated = self.openCreateCostumesPrompt,
		})
	else
		return Roact.createElement(ItemTile, {
			LayoutOrder = self.props.layoutOrder,
			isSelected = self.props.isWearingAssetOrCostume,
			itemIconType = isCostume and ItemTileEnums.ItemIconType.Bundle or nil,
			onActivated = self.toggleEquip,
			name = name,
			titleTextLineCount = 0,
			thumbnail = thumbnail,
		})
	end
end

function ItemCard:checkFetchInfo()
	if self.props.isCostume then
		return
	end

	local assetId = self.props.itemId
	if assetId and not self.props.name then
		print("Fetching item details from ItemCard!")
		self.props.fetchAssetInfo(assetId, CatalogConstants.ItemType.Asset)
	end
end

function ItemCard:didUpdate(oldProps)
	local oldAssetId = oldProps.itemId
	local assetId = self.props.itemId

	if oldAssetId == assetId then
		return
	end

	self:checkFetchInfo()
end

function ItemCard:didMount()
	self:checkFetchInfo()
end

local function mapStateToProps(state, props)
	local itemId = props.itemId
	local categoryIndex = state.AvatarExperience.AvatarEditor.Categories.category
	local subcategoryIndex = state.AvatarExperience.AvatarEditor.Categories.subcategory
	local page = AvatarExperienceUtils.GetCategoryInfo(Categories, categoryIndex, subcategoryIndex)
	local isWearingAssetOrCostume = isWearingAssetOrCostume(state, page, props.itemId, props.isCostume)
	local costumeInfo = state.AvatarExperience.AvatarEditor.Outfits[itemId]
	local name, thumbnail

	local itemData
	if itemId then
		if props.isCostume then
			local costumeData = state.AvatarExperience.AvatarEditor.Outfits[props.itemId]
			name = costumeData and costumeData.name or nil
			local thumbType = CatalogConstants.ThumbnailType.Outfit
			thumbnail = CatalogUtils.MakeRbxThumbUrl(thumbType, itemId, THUMBNAIL_SIZE, THUMBNAIL_SIZE)
		else
			itemData = ItemData(state.AvatarExperience.Common, props.itemId, CatalogConstants.ItemType.Asset)
			name = itemData and itemData.name or nil
			local thumbType = CatalogConstants.ThumbnailType.Asset
			thumbnail = CatalogUtils.MakeRbxThumbUrl(thumbType, itemId, THUMBNAIL_SIZE, THUMBNAIL_SIZE)
		end
	end

	return {
		currentPage = AvatarExperienceUtils.getCurrentPage(state),
		name = name,
		thumbnail = thumbnail,
		assetTypeId = itemData and itemData.assetType or nil,
		isWearingAssetOrCostume = isWearingAssetOrCostume,
		isUIFullView = state.AvatarExperience.AvatarEditor.UIFullView,
		costumeInfo = costumeInfo,
		page = page,
		avatarType = state.AvatarExperience.AvatarEditor.Character.AvatarType,
	}
end

local function mapDispatchToProps(dispatch)
	return {
        fetchAssetInfo = function(itemId, itemType)
			return dispatch(FetchItemData(itemId, itemType))
        end,
		toggleEquipAsset = function(assetType, assetId)
			dispatch(ToggleEquipAsset(assetType, assetId))
		end,
		equipOutfitThunk = function(outfit)
			dispatch(EquipOutfit(outfit))
		end,
		openCreateCostumesPrompt = function(_pageFilter)
			dispatch(CreateOutfit(nil, ""))
		end,
		toggleUIFullView = function()
			dispatch(ToggleUIFullView())
		end,
		openLayeredClothingR15Upgrade = function(onSwitchSelected)
			dispatch(SetCentralOverlay(OverlayType.R15UpgradePrompt, {
				bodyText = "Feature.Avatar.Label.LayeredClothingR15Warning",
				onSwitchSelected = onSwitchSelected,
			}))
		end,
	}
end

ItemCard = RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(ItemCard)

return ItemCard
