local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Cryo = require(Modules.Packages.Cryo)
local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local GridMetrics = UIBlox.App.Grid.GridMetrics

local AppPage = require(Modules.NotLApp.AppPage)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)
local EmptyStatePage = require(Modules.NotLApp.EmptyStatePage)
local FitChildren = require(Modules.NotLApp.FitChildren)
local Constants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local EmptyPage = require(Modules.AvatarExperience.AvatarEditor.Components.EmptyPage)
local ItemCard = require(Modules.AvatarExperience.AvatarEditor.Components.ItemCard)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local RefreshScrollingFrameWithLoadMore = require(Modules.NotLApp.RefreshScrollingFrameWithLoadMore)
local AvatarEditorUtils = require(Modules.AvatarExperience.AvatarEditor.Utils)
local LoadableGridView = require(Modules.AvatarExperience.Common.Components.LoadableGridView)
local Categories = require(Modules.AvatarExperience.AvatarEditor.Categories)
local RecommendedItems = require(Modules.AvatarExperience.AvatarEditor.Components.RecommendedItems)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local GetUserInventory = require(Modules.AvatarExperience.AvatarEditor.Thunks.GetUserInventory)
local GetUserInventoryLC = require(Modules.AvatarExperience.AvatarEditor.Thunks.GetUserInventoryLC)
local GetUserOutfits = require(Modules.AvatarExperience.AvatarEditor.Thunks.GetUserOutfits)

local LayeredClothingEnabled = require(Modules.Config.LayeredClothingEnabled)
local IsCatalogEnabled = require(Modules.Config.IsCatalogEnabled)

local SHIMMER_CARDS_TO_DISPLAY = AvatarExperienceConstants.ShimmerCardsToDisplay

local MIN_CARD_WIDTH = 140
local MIN_ITEMS_PER_ROW = 4
local SIDE_PADDING = 30
local TOP_PADDING = 15

local metricSettings = {
	minimumItemsPerRow = MIN_ITEMS_PER_ROW,
	minimumItemWidth = MIN_CARD_WIDTH,
}

local metricsGetter = GridMetrics.makeCustomMetricsGetter(metricSettings)

local ADD_COSTUME_BUTTON = AvatarEditorConstants.AddCostumeButton

local ItemsList = Roact.PureComponent:extend("ItemsList")

local function renderItemTile(itemId)
	if typeof(itemId) == "table" then
		itemId = nil
	end
	return Roact.createElement(ItemCard, {
		itemId = itemId,
		isCostume = false,
	})
end

local function renderCostumeTile(itemId)
	if typeof(itemId) == "table" then
		itemId = nil
	end

	return Roact.createElement(ItemCard, {
		itemId = itemId,
		isCostume = true,
	})
end

function ItemsList:init()
	self.state = {
		listWidth = 0,
	}

	self.listFrameRef = Roact.createRef()
	self.scrollingFrameRef = Roact.createRef()

	self.checkSetListWidth = function(rbx)
		if rbx and rbx:IsDescendantOf(game) then
			self:setState({
				listWidth = rbx.AbsoluteSize.X,
			})
		end
	end

	self.loadMoreItems = function()
		local isCostumesPage = self.props.isCostumesPage
		local assetTypeKey = self.props.assetTypeKey

		if isCostumesPage then
			return self.props.getUserOutfits(assetTypeKey)
		else
			if LayeredClothingEnabled then
				return self.props.getUserInventory(self.props.categoryInfo)
			else
				return self.props.getUserInventory(assetTypeKey)
			end
		end
	end
end

function ItemsList:getShowAddCostume()
	if LayeredClothingEnabled then
		if self.props.assetTypeKey ~= AvatarEditorConstants.EditableCharacterKey then
			return false
		end
	end
	return true
end

function ItemsList:renderItemsList()
	local categoryInfo = self.props.categoryInfo
	local dataStatus = self.props.dataStatus
	local hasMoreItems = self.props.hasMoreItems
	local screenSize = self.props.screenSize
	local page = self.props.page
	local nextPageCursor = self.props.nextPageCursor
	local items = self.state.items
	local itemsContainsCostumes = self.state.itemsContainsCostumes
	local listWidth = self.state.listWidth

	local hasItems = items and #items > 0 or false
	local isFetchingInitialItems = dataStatus == RetrievalStatus.Fetching and not hasItems
	local isLoading = dataStatus == RetrievalStatus.NotStarted or isFetchingInitialItems

	-- Temporary fix for single frame, 1 pixel item tiles
	local listPadding = listWidth > SIDE_PADDING and SIDE_PADDING or 0

	local itemsList = items
	if items and itemsContainsCostumes and items[1] ~= ADD_COSTUME_BUTTON and self:getShowAddCostume() then
		itemsList = Cryo.List.join({ ADD_COSTUME_BUTTON }, items)
	end

	local numItemsExpected = itemsList and #itemsList or 0

	if isLoading then
		itemsList = nil
		numItemsExpected = SHIMMER_CARDS_TO_DISPLAY
	end

	local recommendedItemsEnabled = categoryInfo.RecommendationsType
		and categoryInfo.RecommendationsType ~= AvatarEditorConstants.RecommendationsType.None
		and nextPageCursor == Constants.ReachedLastPage

	if not IsCatalogEnabled then
		recommendedItemsEnabled = false
	end

	return Roact.createElement(RefreshScrollingFrameWithLoadMore, {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(1, 0, 0, 0),
		onLoadMore = hasMoreItems and self.loadMoreItems,
		hasMoreRows = hasMoreItems,
		createEndOfScrollElement = false,

		parentAppPage = AppPage.AvatarEditor,

		[Roact.Ref] = self.scrollingFrameRef,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 24),
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		ListWrapper = Roact.createElement(FitChildren.FitFrame, {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, listWidth - listPadding, 0, 0),
			LayoutOrder = 1,
			fitAxis = FitChildren.FitAxis.Height,
		}, {
			LoadableGridView = (hasItems or isLoading) and Roact.createElement(LoadableGridView, {
				getItemMetrics = metricsGetter,
				items = itemsList,
				numItemsExpected = numItemsExpected,
				renderItem = itemsContainsCostumes and renderCostumeTile or renderItemTile,
				getItemHeight = AvatarExperienceUtils.GridItemHeightGetter(AvatarExperienceConstants.ItemType.AvatarEditorTile),
				windowHeight = screenSize.Y,
			}) or Roact.createElement(EmptyPage, {
				page = page,
			}),
		}),

		RecommendedItems = recommendedItemsEnabled and Roact.createElement(RecommendedItems, {
			LayoutOrder = 2
		}),

		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, TOP_PADDING),
		}),
	})
end

function ItemsList:render()
	local dataStatus = self.props.dataStatus
	local showFailedState = dataStatus == RetrievalStatus.Failed

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),

		[Roact.Change.AbsoluteSize] = self.checkSetListWidth,
		[Roact.Event.AncestryChanged] = self.checkSetListWidth,

		[Roact.Ref] = self.listFrameRef,
	}, {
		FailedState = showFailedState and Roact.createElement(EmptyStatePage, {
			onRetry = self.loadMoreItems,
		}),

		ItemsList = not showFailedState and self:renderItemsList(),
	})
end

local function getOwnedAssets(ownedAssets, equipped, assetTypeId)
	if not assetTypeId then
		return {}
	end

	local owned = ownedAssets[assetTypeId]
	if not owned then
		return {}
	end

	if not equipped or #equipped == 0 then
		return owned
	end

	local equippedMap = {}

	local resultTable = {}
	local tableSize = 0

	for i = 1, #equipped do
		local assetId = equipped[i]
		equippedMap[assetId] = true

		resultTable[i] = assetId
		tableSize = i
	end

	for i = 1, #owned do
		local assetId = owned[i]
		if not equippedMap[assetId] then
			tableSize = tableSize + 1
			resultTable[tableSize] = assetId
		end
	end

	return resultTable
end

local function getEquippedCostume(assetTypeKey, state)
	local costumes = state.AvatarExperience.AvatarEditor.Outfits
	local ownedAssets = state.AvatarExperience.AvatarEditor.Character.OwnedAssets

	local ownedCostumes = ownedAssets[assetTypeKey]

	if not ownedCostumes then
		return nil
	end

	for _, costumeId in ipairs(ownedCostumes) do
		local costumeInfo = costumes[costumeId]

		if costumeInfo and AvatarEditorUtils.isWearingOutfit(state, costumeInfo) then
			return costumeId
		end
	end

	return nil
end

function ItemsList:updateItems(updateInitialEquipped)
	local assetTypeKey = self.props.assetTypeKey
	local equippedEmote = self.props.equippedEmote
	local equippedAssets = self.props.equippedAssets
	local isCostumesPage = self.props.isCostumesPage
	local initialEquippedAssets = self.state.initialEquippedAssets
	local ownedAssets = self.props.ownedAssets

	if updateInitialEquipped then
		local newInitialEquippedAssets
		if assetTypeKey == AvatarExperienceConstants.AssetTypes.Emote then
			newInitialEquippedAssets = equippedEmote and { equippedEmote.assetId } or {}
		elseif isCostumesPage then
			local store = RoactRodux.UNSTABLE_getStore(self)
			local state = store:getState()

			local equippedCostume = getEquippedCostume(assetTypeKey, state)
			newInitialEquippedAssets = equippedCostume and { equippedCostume } or {}
		else
			newInitialEquippedAssets = AvatarEditorUtils.getEquippedAssetIdsForType(equippedAssets, assetTypeKey)
		end

		initialEquippedAssets = newInitialEquippedAssets
		self:setState({
			initialEquippedAssets = newInitialEquippedAssets,
		})
	end

	local items = getOwnedAssets(ownedAssets, initialEquippedAssets, assetTypeKey)
	self:setState({
		items = items,
		itemsContainsCostumes = isCostumesPage,
	})
end

function ItemsList:didMount()
	self.checkSetListWidth(self.listFrameRef.current)

	local dataStatus = self.props.dataStatus
	if dataStatus == RetrievalStatus.NotStarted then
		self.loadMoreItems()
	else
		self:updateItems(--[[ updateInitialEquipped = ]] true)
	end
end

function ItemsList:didUpdate(previousProps, _previousState)
	local appPage = self.props.appPage
	local categoryInfo = self.props.categoryInfo
	local dataStatus = self.props.dataStatus
	local oldDataStatus = previousProps.dataStatus
	local ownedAssets = self.props.ownedAssets

	local emoteSlotChanged = self.props.emoteSlot ~= previousProps.emoteSlot
	local assetTypeKeyChanged = self.props.assetTypeKey ~= previousProps.assetTypeKey
	local changedCategory = self.props.categoryIndex ~= previousProps.categoryIndex
	local changedSubcategory = self.props.subcategoryIndex ~= previousProps.subcategoryIndex
	local ownedAssetsChanged = ownedAssets ~= previousProps.ownedAssets
	local shouldFetchItems = changedCategory or changedSubcategory

	if appPage == AppPage.AvatarEditor and shouldFetchItems and categoryInfo.RenderItemTiles then
		if dataStatus == RetrievalStatus.NotStarted then
			self.loadMoreItems()
		end
	end

	if changedCategory or changedSubcategory then
		local scrollingFrame = self.scrollingFrameRef.current
		if scrollingFrame then
			scrollingFrame.CanvasPosition = Vector2.new(0, 0)
		end
	end

	local dataFetchingFinished = dataStatus == RetrievalStatus.Done and oldDataStatus == RetrievalStatus.Fetching

	if assetTypeKeyChanged or emoteSlotChanged or ownedAssetsChanged or dataFetchingFinished then
		local updateInitialEquipped = assetTypeKeyChanged or emoteSlotChanged or dataFetchingFinished
		self:updateItems(updateInitialEquipped)
	end
end

local function mapStateToProps(state, _props)
	local categoryIndex = state.AvatarExperience.AvatarEditor.Categories.category
	local subcategoryIndex = state.AvatarExperience.AvatarEditor.Categories.subcategory
	local emoteSlot = state.AvatarExperience.AvatarEditor.EquippedEmotes.selectedSlot
	local emotesSlotInfo = state.AvatarExperience.AvatarEditor.EquippedEmotes.slotInfo
	local categoryInfo = AvatarExperienceUtils.GetCategoryInfo(Categories, categoryIndex, subcategoryIndex)
	local assetTypeKey = categoryInfo.AssetTypeId and categoryInfo.AssetTypeId or categoryInfo.Name
	if LayeredClothingEnabled then
		assetTypeKey = categoryInfo.SearchUuid or categoryInfo.Name
	end

	local isCostumesPage = categoryInfo.RenderCostumeItemTiles == true
	local page = AvatarExperienceUtils.GetCategoryInfo(Categories, categoryIndex, subcategoryIndex)

	local dataStatus = RetrievalStatus.Failed
	local hasMoreItems = false

	if assetTypeKey then
		if isCostumesPage then
			dataStatus = PerformFetch.GetStatus(state, AvatarExperienceConstants.UserOutfitsKey .. assetTypeKey)
		else
			dataStatus = PerformFetch.GetStatus(state, AvatarExperienceConstants.UserInventoryKey .. assetTypeKey)
		end

		hasMoreItems = state.AvatarExperience.AvatarEditor.AssetTypeCursor[assetTypeKey] ~= Constants.ReachedLastPage
	end

	return {
		nextPageCursor = state.AvatarExperience.AvatarEditor.AssetTypeCursor[assetTypeKey],
		appPage = AvatarExperienceUtils.getCurrentPage(state),
		categoryInfo = categoryInfo,
		dataStatus = dataStatus,
		hasMoreItems = hasMoreItems,
		page = page,

		assetTypeKey = assetTypeKey,
		categoryIndex = categoryIndex,
		subcategoryIndex = subcategoryIndex,
		emoteSlot = emoteSlot,
		equippedEmote = emotesSlotInfo[emoteSlot],
		isCostumesPage = isCostumesPage,

		equippedAssets = state.AvatarExperience.AvatarEditor.Character.EquippedAssets,
		ownedAssets = state.AvatarExperience.AvatarEditor.Character.OwnedAssets,
		screenSize = state.ScreenSize,
	}
end

local function mapDispatchToProps(dispatch)
	local getUserInventory
	if LayeredClothingEnabled then
		getUserInventory = function(categoryInfo)
			return dispatch(GetUserInventoryLC(categoryInfo))
		end
	else
		getUserInventory = function(assetType)
			return dispatch(GetUserInventory(assetType))
		end
	end

	return {
		getUserInventory = getUserInventory,

		getUserOutfits = function(costumeType)
			return dispatch(GetUserOutfits(costumeType))
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(ItemsList)
