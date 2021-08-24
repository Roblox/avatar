local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local Promise = require(Modules.Packages.Promise)

local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)
local EmptyStatePage = require(Modules.NotLApp.EmptyStatePage)
local FitTextLabel = require(Modules.NotLApp.FitTextLabel)
local RefreshScrollingFrameWithLoadMore = require(Modules.NotLApp.RefreshScrollingFrameWithLoadMore)
local SearchRetrievalStatus = require(Modules.NotLApp.Enum.SearchRetrievalStatus)
local withLocalization = require(Modules.Packages.Localization.withLocalization)
local withStyle = UIBlox.Style.withStyle

local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local CatalogItemCard = require(Modules.AvatarExperience.Catalog.Components.ItemsList.CatalogItemCard)
local LoadableGridView = require(Modules.AvatarExperience.Common.Components.LoadableGridView)
local ResultsHeader = require(Modules.AvatarExperience.Catalog.Components.Search.ResultsHeader)

local ApiFetchCatalogSearch = require(Modules.AvatarExperience.Catalog.Thunks.ApiFetchCatalogSearch)
local FetchDataWithErrorToasts = require(Modules.NotLApp.Thunks.FetchDataWithErrorToasts)

local Toggle3DFullView = require(Modules.AvatarExperience.Catalog.Thunks.Toggle3DFullView)
local ToggleUIFullView = require(Modules.AvatarExperience.Catalog.Thunks.ToggleUIFullView)

local NO_ITEMS_FOUND_KEY = "Feature.Catalog.Response.NoItemsFound"

local SIDE_PADDING = 30
local TOP_PADDING = 10
local BOTTOM_PADDING = 10

local HEADER_GRID_PADDING = 12

local function renderItem(itemInfo, index)
    return Roact.createElement(CatalogItemCard, {
        index = index,
        itemType = itemInfo.type,
        itemId = itemInfo.id,
    })
end

local ResultsList = Roact.PureComponent:extend("ResultsList")

function ResultsList:init()
    self.loadMore = function()
		local searchInCatalogStatus = self.props.searchInCatalogStatus
		if searchInCatalogStatus == SearchRetrievalStatus.Fetching then
			return Promise.resolve("Currently fetching")
		end

		local searchUuid = self.props.searchUuid
		local searchInCatalog = self.props.searchInCatalog
        local dispatchLoadMore = self.props.dispatchLoadMore

        local nextPageCursor = searchInCatalog.nextPageCursor
        return dispatchLoadMore(searchInCatalog.keyword,
            searchUuid, nextPageCursor)
    end

    self.changeView = function()
        local isFullView = self.props.isFullView
        local toggle3DFullView = self.props.toggle3DFullView
        local toggleUIFullView = self.props.toggleUIFullView

		if isFullView then
			toggle3DFullView()
		else
			toggleUIFullView()
		end
    end
end

function ResultsList:renderResultsList(stylePalette)
    local deviceOrientation = self.props.deviceOrientation
    local isUIFullView = self.props.isUIFullView
    local screenSize = self.props.screenSize
    local searchUuid = self.props.searchUuid
    local searchInCatalog = self.props.searchInCatalog
    local searchInCatalogStatus = self.props.searchInCatalogStatus
    local isPortrait = deviceOrientation == DeviceOrientationMode.Portrait

    local searchComplete = searchInCatalogStatus == SearchRetrievalStatus.Done
    local entries = searchInCatalog and searchInCatalog.items or nil
    local nextPageCursor = searchInCatalog and searchInCatalog.nextPageCursor or nil

    local hasEntries = entries and #entries ~= 0
    local numItemsExpected = entries and #entries or CatalogConstants.PageFetchLimit
    local showingEntries = not searchComplete or hasEntries

    local hasMoreEntries = hasEntries and nextPageCursor and nextPageCursor ~= ""
    local createEndOfScrollElement = hasEntries and not hasMoreEntries

    local fontInfo = stylePalette.Font
    local font = fontInfo.Body.Font
    local fontSize = fontInfo.BaseSize * fontInfo.Body.RelativeSize
	local itemTileFontHeight = fontInfo.Header2.RelativeSize * fontInfo.BaseSize

    local tileType = AvatarExperienceConstants.ItemType.CatalogItemTile
    local getItemHeightFunc = AvatarExperienceUtils.GridItemHeightGetter(tileType, itemTileFontHeight)

    local theme = stylePalette.Theme
    local textColor3 = theme.TextMuted.Color
    local textTransparency = theme.TextMuted.Transparency

    return withLocalization({
        noItemsFound = NO_ITEMS_FOUND_KEY,
    })(function(localized)
        return Roact.createElement("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
        }, {
            ScrollingFrame =  Roact.createElement(RefreshScrollingFrameWithLoadMore, {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                CanvasSize = UDim2.new(1, 0, 1, 0),
                onLoadMore = hasMoreEntries and self.loadMore,
                overrideBackgroundTransparency = 1,
                hasMoreRows = hasMoreEntries,
                createEndOfScrollElement = createEndOfScrollElement,
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, HEADER_GRID_PADDING),
                }),

                Padding = Roact.createElement("UIPadding", {
                    PaddingLeft = UDim.new(0, SIDE_PADDING),
                    PaddingRight = UDim.new(0, SIDE_PADDING),
                    PaddingTop = UDim.new(0, TOP_PADDING),
                    PaddingBottom = UDim.new(0, BOTTOM_PADDING),
                }),

                ResultsHeader = showingEntries and Roact.createElement(ResultsHeader, {
                    searchUuid = searchUuid,
                }),

                ItemsGrid = showingEntries and Roact.createElement(LoadableGridView, {
                    LayoutOrder = 2,
                    getItemHeight = getItemHeightFunc,
                    items = entries,
                    numItemsExpected = numItemsExpected,
                    renderItem = renderItem,
                    windowHeight = screenSize.Y,
                }),

                NoItemsFound = not showingEntries and Roact.createElement(FitTextLabel, {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0, TOP_PADDING),
                    Text = localized.noItemsFound,
                    TextSize = fontSize,
                    TextColor3 = textColor3,
                    TextTransparency = textTransparency,
                    Font = font,
                }),
            }),
        })
    end)
end

function ResultsList:render()
	local searchInCatalogStatus = self.props.searchInCatalogStatus

    local showFailedState = searchInCatalogStatus == SearchRetrievalStatus.Failed
    if showFailedState then
        return Roact.createElement(EmptyStatePage, {
			onRetry = self.dispatchInitialSearch,
		})
    end

    return withStyle(function(stylePalette)
        return self:renderResultsList(stylePalette)
    end)
end

local function selectSearchInCatalogStatus(state, props)
	local searchInCatalogStatus = state.RequestsStatus.SearchesInCatalogStatus[props.searchUuid]

	if searchInCatalogStatus == nil then
		searchInCatalogStatus = SearchRetrievalStatus.NotStarted
	end

	return searchInCatalogStatus
end

local function mapStateToProps(state, props)
    return {
        deviceOrientation = state.DeviceOrientation,
		fullView = state.AvatarExperience.Catalog.FullView,
        isUIFullView = state.AvatarExperience.Catalog.UIFullView,
        screenSize = state.ScreenSize,
        searchInCatalog = state.Search.SearchesInCatalog[props.searchUuid],
        searchInCatalogStatus = selectSearchInCatalogStatus(state, props),
    }
end

local function mapDispatchToProps(dispatch)
    return {
        dispatchLoadMore = function(searchKeyword, searchUuid, nextPageCursor)
            return dispatch(FetchDataWithErrorToasts(ApiFetchCatalogSearch({
                searchKeyword = searchKeyword,
                searchUuid = searchUuid,
                nextPageCursor = nextPageCursor,
            })))
        end,

		toggle3DFullView = function()
            dispatch(Toggle3DFullView())
		end,

		toggleUIFullView = function()
			dispatch(ToggleUIFullView())
		end,
    }
end

ResultsList = RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(ResultsList)

return ResultsList
