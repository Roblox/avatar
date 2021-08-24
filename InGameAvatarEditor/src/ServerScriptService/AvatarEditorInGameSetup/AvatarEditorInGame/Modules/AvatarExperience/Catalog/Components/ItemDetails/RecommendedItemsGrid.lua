local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)

local AppPage = require(Modules.NotLApp.AppPage)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local GetRecommendedAssets = require(Modules.AvatarExperience.Catalog.Thunks.GetRecommendedAssets)
local GetRecommendedBundles = require(Modules.AvatarExperience.Catalog.Thunks.GetRecommendedBundles)
local BaseItemCard = require(Modules.AvatarExperience.Catalog.Components.ItemsList.BaseItemCard)
local LoadableGridView = require(Modules.AvatarExperience.Common.Components.LoadableGridView)

local ItemData = require(Modules.AvatarExperience.Common.Selectors.ItemData)
local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)

local SetItemDetailsProps = require(Modules.Setup.Actions.SetItemDetailsProps)

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local NAME_TEXT_LINE_COUNT = 2
local TILE_PADDING = 10

local RecommendedItemsGrid = Roact.PureComponent:extend("RecommendedItemsGrid")

RecommendedItemsGrid.defaultProps = {
	itemType = CatalogConstants.ItemType.Asset,
}

function RecommendedItemsGrid:init()
	self.selectRecommendedItem = function(entry, index)
		local itemId = entry.id
		local itemType = entry.type

		if not itemId or not itemType then
			return
		end

		if true then
			self.props.setItemDetailsProps(itemId, itemType)
			return
		end

		local navDetail = itemType .. itemId
		local extraProps = {
			itemId = itemId,
			itemType = itemType,
			mountAsFullView = true,
			mountAnimation = false,
		}

		self.props.navigateDown({ name = AppPage.ItemDetails, detail = navDetail, extraProps = extraProps })
	end

	self.renderRecommendedItem = function(entry, index)
		return Roact.createElement(BaseItemCard, {
			itemId = entry.id,
			itemType = entry.type,
			onActivated = function() self.selectRecommendedItem(entry, index) end,
		})
	end

	self.fetchRecommended = function()
		local itemId = self.props.itemId
		local itemType = self.props.itemType
		local itemSubType = self.props.itemSubType

		if not itemId or not itemType or not itemSubType then
			return
		end

		if itemType == CatalogConstants.ItemType.Asset then
			self.props.getRecommendedAssets(itemId, itemSubType)
		else
			self.props.getRecommendedBundles(itemId, itemSubType)
		end
	end
end

function RecommendedItemsGrid:didMount()
	self.fetchRecommended()
end

function RecommendedItemsGrid:didUpdate(prevProps)
	local prevItemSubType = prevProps.itemSubType
	local itemSubType = self.props.itemSubType

	if itemSubType and not prevItemSubType then
		self.fetchRecommended()
	end
end

function RecommendedItemsGrid:render()
	if self.props.itemId == nil then
		return
	end

	local layoutOrder = self.props.LayoutOrder
	local recommendedItemsList = self.props.recommendedItemIds

	return withStyle(function(stylePalette)
		local font = stylePalette.Font
		return Roact.createElement(LoadableGridView, {
			items = recommendedItemsList,
			renderItem = self.renderRecommendedItem,
			getItemHeight = function(width)
				local nameHeight = font.BaseSize * font.Header2.RelativeSize * NAME_TEXT_LINE_COUNT
				return width + TILE_PADDING + nameHeight
			end,
			LayoutOrder = layoutOrder,
			numItemsExpected = CatalogConstants.recommendedItemsCount,
		})
	end)
end

RecommendedItemsGrid = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local itemInfo = ItemData(state.AvatarExperience.Common, props.itemId, props.itemType)
		return {
			recommendedItemIds = itemInfo and itemInfo.recommendedItemIds,
		}
	end,
	function(dispatch)
		return {
			getRecommendedAssets = function(assetId, assetTypeId)
				dispatch(GetRecommendedAssets(assetId, assetTypeId))
			end,
			getRecommendedBundles = function(bundleId)
				dispatch(GetRecommendedBundles(bundleId))
			end,
			setItemDetailsProps = function(itemId, itemType)
				dispatch(SetItemDetailsProps(itemId, itemType))
			end,
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
		}
	end
)(RecommendedItemsGrid)

return RecommendedItemsGrid
