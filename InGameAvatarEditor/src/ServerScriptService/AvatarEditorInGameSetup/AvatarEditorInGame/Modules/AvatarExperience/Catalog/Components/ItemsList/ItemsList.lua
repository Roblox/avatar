local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local AvatarExperience = Modules.AvatarExperience
local Catalog = AvatarExperience.Catalog

local AppPage = require(Modules.NotLApp.AppPage)
local Promise = require(Modules.Packages.Promise)

local CatalogUtils = require(Catalog.CatalogUtils)

local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)
local EmptyStatePage = require(Modules.NotLApp.EmptyStatePage)
local withStyle = UIBlox.Style.withStyle

local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local CatalogItemCard = require(Modules.AvatarExperience.Catalog.Components.ItemsList.CatalogItemCard)
local LoadableGridView = require(Modules.AvatarExperience.Common.Components.LoadableGridView)
local RefreshScrollingFrameWithLoadMore = require(Modules.NotLApp.RefreshScrollingFrameWithLoadMore)
local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)


local ToggleUIFullView = require(Modules.AvatarExperience.Catalog.Thunks.ToggleUIFullView)

local ClearSelectedItem = require(Modules.AvatarExperience.Common.Actions.ClearSelectedItem)
local FetchCatalogPageData = require(Modules.AvatarExperience.Catalog.Thunks.FetchCatalogPageData)
local GetFFlagCatalogFullAvatarWifiIcon = function() return true end

local FFlagImproveCatalogPerformance = true

local SIDE_PADDING = 30
local TOP_PADDING = 15
local TOUCH_MOVE_MIN_TIME = 0.15
local EXPAND_BUTTON_PADDING = 12

local function renderItem(itemInfo, index)
	return Roact.createElement(CatalogItemCard, {
		index = index,
		itemType = itemInfo.type,
		itemId = itemInfo.id,
	})
end

local ItemsList = Roact.PureComponent:extend("ItemsList")

function ItemsList:init()
	self.connections = {}
	self.isTouched = false
	self.scrollingFrameMovedConnection = nil
	self.touchStarted = nil

	self.listFrameRef = Roact.createRef()
    self.scrollingFrameRef = Roact.createRef()

	self.onScrollingFrameMoved = function()
		if self.isTouched and self.props.itemIsSelected then
			if self.touchStarted and self.touchStarted + TOUCH_MOVE_MIN_TIME < tick() then
				self.props.deselectPeekedItem()
			end
		end
	end

	self.connectScrollingFrameMoved = function(rbx)
		if self.scrollingFrameMovedConnection then
			self.scrollingFrameMovedConnection:disconnect()
			self.scrollingFrameMovedConnection = nil
		end

		if not rbx then
			return
		end

		local scrollingFrame = rbx:FindFirstAncestorWhichIsA("ScrollingFrame")
		if scrollingFrame then
			local signal = scrollingFrame:GetPropertyChangedSignal("CanvasPosition")
			self.scrollingFrameMovedConnection = signal:connect(self.onScrollingFrameMoved)
		end
	end

	self.fetchSortContents = function()
		local categoryIndex = self.props.categoryIndex
		local subcategoryIndex = self.props.subcategoryIndex

		return self.props.fetchSortContents(categoryIndex, subcategoryIndex)
	end

	self.loadMoreItems = function()
		local dataStatus = self.props.dataStatus
		if dataStatus == RetrievalStatus.Fetching then
			return Promise.resolve("Currently fetching")
		end

		local categoryIndex = self.props.categoryIndex
		local subcategoryIndex = self.props.subcategoryIndex
		local nextPageCursor = self.props.sortContents.nextPageCursor

		return self.props.loadMoreItems(categoryIndex,
			subcategoryIndex, nextPageCursor)
	end

	self.toggleUIFullView = function()
		self.props.toggleUIFullView()
	end
end

function ItemsList:renderItemsList(stylePalette)
	local dataStatus = self.props.dataStatus
	local deviceOrientation = self.props.deviceOrientation
	local screenSize = self.props.screenSize
	local sortContents = self.props.sortContents
	local appPage = self.props.appPage

	local font = stylePalette.Font
	local fontHeight = font.Header2.RelativeSize * font.BaseSize

    local tileType = AvatarExperienceConstants.ItemType.CatalogItemTile
    local getItemHeightFunc = AvatarExperienceUtils.GridItemHeightGetter(tileType, fontHeight)

	local isPortrait = deviceOrientation == DeviceOrientationMode.Portrait

	local isLoadingMore = dataStatus == RetrievalStatus.Fetching and #sortContents.entries > 0
	local hasItems = dataStatus == RetrievalStatus.Done or isLoadingMore

	local items = hasItems and sortContents.entries or nil
	local numItemsExpected = hasItems and #sortContents.entries or CatalogConstants.PageFetchLimit

	local displayLoadableGrid = (not FFlagImproveCatalogPerformance) or
		(appPage == AppPage.Catalog or dataStatus ~= RetrievalStatus.NotStarted)

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),

		[Roact.Ref] = self.listFrameRef,
	}, {
		ScrollList = Roact.createElement(RefreshScrollingFrameWithLoadMore, {
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(1, 0, 0, 0),
			ZIndex = 1,
			onLoadMore = sortContents.hasMoreRows and self.loadMoreItems,
			hasMoreRows = sortContents.hasMoreRows,
			createEndOfScrollElement = not sortContents.hasMoreRows,
			parentAppPage = AppPage.Catalog,

			[Roact.Ref] = self.scrollingFrameRef,
		}, {
			CanvasMovedListener = isPortrait and Roact.createElement("Frame", {
				Size = UDim2.new(0, 0, 0, 0),
				Transparency = 1,

				[Roact.Event.AncestryChanged] = self.connectScrollingFrameMoved,
				[Roact.Ref] = self.connectScrollingFrameMoved,
			}),

			LoadableGridView = displayLoadableGrid and Roact.createElement(LoadableGridView, {
				items = items,
				numItemsExpected = numItemsExpected,
				renderItem = renderItem,
				getItemHeight = getItemHeightFunc,
				windowHeight = screenSize.Y,
			}),

			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, TOP_PADDING),
			}),
		}),
	})
end

function ItemsList:renderWithStyle(stylePalette)
	local dataStatus = self.props.dataStatus
	local theme = stylePalette.Theme

	local listSize = self.props.size or UDim2.new(1, 0, 1, 0)
	local showFailedState = dataStatus == RetrievalStatus.Failed

	return Roact.createElement("Frame", {
		Active = true,
		Size = listSize,
		BorderSizePixel = 0,
		BackgroundColor3 = theme.BackgroundDefault.Color,
		BackgroundTransparency = theme.BackgroundDefault.Transparency,
		LayoutOrder = self.props.layoutOrder,

		[Roact.Ref] = self.props.ref,
	}, {
		PaddedFrame = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -SIDE_PADDING, 1, 0),
		}, {
			FailedState = showFailedState and Roact.createElement(EmptyStatePage, {
				onRetry = self.fetchSortContents,
				ClipsDescendants = GetFFlagCatalogFullAvatarWifiIcon(),
			}),

			ItemsList = not showFailedState and self:renderItemsList(stylePalette),
		}),
	})
end

function ItemsList:render()
    return withStyle(function(stylePalette)
        return self:renderWithStyle(stylePalette)
    end)
end

function ItemsList:onTouchEnded(touch, gameProcessedEvent)
	self.isTouched = false
	self.touchStarted = nil
end

function ItemsList:onTouchMoved(touch, gameProcessedEvent)
	self.isTouched = false

	local listFrame = self.listFrameRef.current
	if not listFrame then
		self.touchStarted = nil
		return
	end

	local absolutePosition = listFrame.AbsolutePosition
	local absoluteSize = listFrame.AbsoluteSize

	local farCorner = Vector2.new(absolutePosition.X + absoluteSize.X, absolutePosition.Y + absoluteSize.Y)

	if touch.Position.X > listFrame.AbsolutePosition.X and
		touch.Position.Y > listFrame.AbsolutePosition.Y and
		touch.Position.X < farCorner.X and
		touch.Position.Y < farCorner.Y then

		self.isTouched = true
		if not self.touchStarted then
			self.touchStarted = tick()
		end
	end

	if not self.isTouched then
		self.touchStarted = nil
	end
end

function ItemsList:didMount()
	self.fetchSortContents()
end

function ItemsList:onTouchSwipe(direction, numberOfTouches, gameProcessedEvent)
	if not numberOfTouches == 1 then
		return
	end

	if not self.isTouched then
		return
	end

	if direction == Enum.SwipeDirection.Right then
		if self.props.navigateLeft then
			self.props.navigateLeft()
		end
	elseif direction == Enum.SwipeDirection.Left then
		if self.props.navigateRight then
			self.props.navigateRight()
		end
	end
end

function ItemsList:didUpdate(previousProps, previousState)
	local changedCategory = self.props.categoryIndex ~= previousProps.categoryIndex
	local changedSubcategory = self.props.subcategoryIndex ~= previousProps.subcategoryIndex
	local newAppPage = self.props.appPage
	local oldAppPage = previousProps.appPage

	if changedCategory or changedSubcategory then
		-- If we have no sort data then trigger a fetch.
		if #self.props.sortContents.entries == 0 then
			self.fetchSortContents()
		end

		local scrollingFrame = self.scrollingFrameRef.current
		if scrollingFrame then
			scrollingFrame.CanvasPosition = Vector2.new(0, 0)
		end
	end

	if newAppPage ~= oldAppPage then
		if newAppPage == AppPage.Catalog or newAppPage == AppPage.AvatarEditor then
			if self.props.dataStatus == RetrievalStatus.NotStarted then
				self.fetchSortContents()
			end
		end

		if newAppPage == AppPage.Catalog then
			local touchMovedConnection = UserInputService.TouchMoved:Connect(function(...) self:onTouchMoved(...) end)
			local touchSwipeConnection = UserInputService.TouchSwipe:Connect(function(...) self:onTouchSwipe(...) end)
			local touchEndedConnection = UserInputService.TouchEnded:Connect(function(...) self:onTouchEnded(...) end)
			self.connections[#self.connections + 1] = touchMovedConnection
			self.connections[#self.connections + 1] = touchSwipeConnection
			self.connections[#self.connections + 1] = touchEndedConnection
		elseif oldAppPage == AppPage.Catalog and newAppPage ~= AppPage.Catalog then
			self:disconnectListeners()
		end
	end
end

function ItemsList:disconnectListeners()
	for _, connection in ipairs(self.connections) do
		connection:disconnect()
	end
	self.connections = {}

	if self.scrollingFrameMovedConnection then
		self.scrollingFrameMovedConnection:disconnect()
		self.scrollingFrameMovedConnection = nil
	end

	self.isTouched = false
	self.touchStarted = nil
end

function ItemsList:willUnmount()
	self:disconnectListeners()
end

local function getSortContents(state, categoryIndex, subcategoryIndex)
	local categoryTable = state.AvatarExperience.Catalog.SortsContents[categoryIndex]
	if categoryTable then
		local subcategoryTable = categoryTable[subcategoryIndex]
		if subcategoryTable then
			return subcategoryTable
		end
	end

	return {
		entries = {},
	}
end

local function mapStateToProps(state, props)
	local itemIsSelected = state.AvatarExperience.AvatarScene.TryOn.SelectedItem.itemId ~= nil

    return {
		deviceOrientation = state.DeviceOrientation,
		isUIFullView = state.AvatarExperience.Catalog.UIFullView,
		dataStatus = CatalogUtils.GetSortDataStatus(state, props.categoryIndex, props.subcategoryIndex),
		itemIsSelected = itemIsSelected,
        sortContents = getSortContents(state, props.categoryIndex, props.subcategoryIndex),
        screenSize = state.ScreenSize,
        appPage = AvatarExperienceUtils.getCurrentPage(state),
    }
end

local function mapDispatchToProps(dispatch)
    return {
        fetchSortContents = function(categoryIndex, subcategoryIndex)
			return dispatch(FetchCatalogPageData(categoryIndex, subcategoryIndex,
				nil))
        end,

		loadMoreItems = function(categoryIndex,
			subcategoryIndex, nextPageCursor)
			return dispatch(FetchCatalogPageData(categoryIndex, subcategoryIndex,
				nextPageCursor))
		end,

		deselectPeekedItem = function()
			dispatch(ClearSelectedItem())
		end,

		toggleUIFullView = function()
			dispatch(ToggleUIFullView())
		end,
    }
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(ItemsList)
