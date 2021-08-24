local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local SearchRetrievalStatus = require(Modules.NotLApp.Enum.SearchRetrievalStatus)

local AppPage = require(Modules.NotLApp.AppPage)
local Constants = require(Modules.NotLApp.Constants)
local SearchUuid = require(Modules.NotLApp.SearchUuid)

local AvatarExperienceView = require(Modules.AvatarExperience.Common.Components.AvatarExperienceView)
local CatalogSearchResultsList = require(Modules.AvatarExperience.Catalog.Components.Search.ResultsList)
local SearchBar = require(Modules.NotLApp.SearchBar)
local withStyle = UIBlox.Style.withStyle

local RemoveSearchInCatalog = require(Modules.AvatarExperience.Catalog.Actions.RemoveSearchInCatalog)
local SetSearchInCatalogStatus = require(Modules.AvatarExperience.Catalog.Actions.SetSearchInCatalogStatus)
local SetSearchParameters = require(Modules.NotLApp.Actions.SetSearchParameters)
local SetSearchType = require(Modules.NotLApp.Actions.SetSearchType)

local Toggle3DFullView = require(Modules.AvatarExperience.Catalog.Thunks.Toggle3DFullView)
local ToggleUIFullView = require(Modules.AvatarExperience.Catalog.Thunks.ToggleUIFullView)

local ApiFetchCatalogSearch = require(Modules.AvatarExperience.Catalog.Thunks.ApiFetchCatalogSearch)
local NavigateSideways = require(Modules.NotLApp.Thunks.NavigateSideways)
local CatalogNavigateBack = require(Modules.AvatarExperience.Catalog.Thunks.CatalogNavigateBack)
local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)

local FFlagLuaCatalogPageDisable3DView = false
local FFlagEnableAvatarExperienceLandingPage = false

local SEARCH_BAR_PADDING = 20

local CatalogSearch = Roact.PureComponent:extend("CatalogSearch")

function CatalogSearch:init()
	self.dispatchInitialSearch = function()
		local searchUuid = self.props.searchUuid
		local searchParameters = self.props.searchParameters
		local dispatchSearch = self.props.dispatchSearch
		local isFullView = self.props.isFullView
		local toggle3DFullView = self.props.toggle3DFullView

		if isFullView then
			toggle3DFullView()
		end

		return dispatchSearch(searchParameters.searchKeyword, searchUuid,
			searchParameters.isKeywordSuggestionEnabled)
	end

	self.confirmSearchCallback = function(keyword)
		local searchUuid = SearchUuid()

		self.props.setSearchType(searchUuid, Constants.SearchTypes.Catalog)
		self.props.setSearchParameters(searchUuid, keyword, true)
		self.props.navigateToSearch(self.props.currentRoute, searchUuid)
	end

	self.cancelSearchCallback = function()
		self.props.catalogNavigateBack()
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

function CatalogSearch:renderSearchBar(stylePalette)
	local theme = stylePalette.Theme

	local searchParameters = self.props.searchParameters
	local searchKeyword = searchParameters.searchKeyword
	local topBarHeight = self.props.topBarHeight

	local isBackgroundTransparent = FFlagEnableAvatarExperienceLandingPage

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, topBarHeight),
		BackgroundColor3 = theme.BackgroundDefault.Color,
		BackgroundTransparency = isBackgroundTransparent and 1 or theme.BackgroundDefault.Transparency,
		BorderSizePixel = 0,
	}, {
		PaddedFrame = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 1, -SEARCH_BAR_PADDING)
		}, {
			SearchBar = Roact.createElement(SearchBar, {
				cancelSearch = self.cancelSearchCallback,
				confirmSearch = self.confirmSearchCallback,
				placeholderText = "Search.GlobalSearch.Example.SearchCatalog",
				isPhone = true, -- Cancel button should always be visible, always use compact mode.
				initialSearchText = searchKeyword,
			}),
		}),
	})
end

function CatalogSearch:renderWithStyle(stylePalette)
	local isFullView = self.props.isFullView
	local isUIFullView = self.props.isUIFullView
	local searchParameters = self.props.searchParameters
	local searchUuid = self.props.searchUuid

	return Roact.createElement(AvatarExperienceView, {
		changeViewFunction = self.changeView,
		isDisabled = FFlagLuaCatalogPageDisable3DView,
		isFullView = isFullView,
		isUIFullView = isUIFullView,
		topBar = self:renderSearchBar(stylePalette),
	}, {
		ResultsList = Roact.createElement(CatalogSearchResultsList, {
			searchUuid = searchUuid,
			searchParameters = searchParameters,
		}),
	})
end

function CatalogSearch:render()
	return withStyle(function(stylePalette)
		return self:renderWithStyle(stylePalette)
	end)
end

function CatalogSearch:didMount()
	self.dispatchInitialSearch()
end

function CatalogSearch:willUnmount()
	local searchUuid = self.props.searchUuid
	local dispatchRemoveSearch = self.props.dispatchRemoveSearch

	dispatchRemoveSearch(searchUuid)
end

local function mapStateToProps(state, props)
	return {
		isFullView = state.AvatarExperience.Catalog.FullView,
		isUIFullView = state.AvatarExperience.Catalog.UIFullView,
		topBarHeight = 36, --state.TopBar.topBarHeight,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		catalogNavigateBack = function()
			--return dispatch(CatalogNavigateBack())
			return dispatch(NavigateDown({ name = AppPage.Catalog }))
		end,

		navigateToSearch = function(currentRoute, searchUuid)
			dispatch(NavigateSideways({ name = AppPage.SearchPage, detail = searchUuid }))
		end,

		dispatchSearch = function(searchKeyword, searchUuid)
			return dispatch(ApiFetchCatalogSearch({
				searchKeyword = searchKeyword,
				searchUuid = searchUuid,
			}))
		end,

		dispatchRemoveSearch = function(searchUuid)
			dispatch(RemoveSearchInCatalog(searchUuid))
			dispatch(SetSearchInCatalogStatus(searchUuid, SearchRetrievalStatus.Removed))
		end,

		setSearchType = function(searchUuid, searchType)
			return dispatch(SetSearchType(searchUuid, searchType))
		end,

		setSearchParameters = function(searchUuid, searchKeyword, isKeywordSuggestionEnabled)
			return dispatch(SetSearchParameters(searchUuid, {
				searchKeyword = searchKeyword,
				isKeywordSuggestionEnabled = isKeywordSuggestionEnabled,
			}))
		end,

		toggle3DFullView = function()
			dispatch(Toggle3DFullView())
		end,

		toggleUIFullView = function()
			dispatch(ToggleUIFullView())
		end,
	}
end

CatalogSearch = RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(CatalogSearch)

return CatalogSearch
