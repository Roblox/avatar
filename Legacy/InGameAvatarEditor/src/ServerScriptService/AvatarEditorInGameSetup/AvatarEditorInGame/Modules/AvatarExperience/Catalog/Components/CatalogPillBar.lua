local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local withLocalization = require(Modules.Packages.Localization.withLocalization)

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)
local Cryo = require(Modules.Packages.Cryo)
local t = require(Modules.Packages.t)

local SmallPill = UIBlox.App.Pill.SmallPill
local PillBar = require(Modules.AvatarExperience.Catalog.Components.PillBar)
local OverlayType = require(Modules.NotLApp.Enum.OverlayType)
local SetCentralOverlay = require(Modules.NotLApp.Actions.SetCentralOverlay)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local SetSearchParameters = require(Modules.NotLApp.Actions.SetSearchParameters)
local SetSearchType = require(Modules.NotLApp.Actions.SetSearchType)
local NavigateSideways = require(Modules.NotLApp.Thunks.NavigateSideways)
local AppPage = require(Modules.NotLApp.AppPage)
local Constants = require(Modules.NotLApp.Constants)
local SearchUuid = require(Modules.NotLApp.SearchUuid)

local BUTTON_PADDING = 15

local CatalogPillBar = Roact.PureComponent:extend("CatalogPillBar")

CatalogPillBar.validateProps = t.strictInterface({
	pillbarHeight = t.optional(t.number),
	showCategories = t.optional(t.boolean),
	isLoading = t.optional(t.boolean),
	filtersSelection = t.table,
	searchParameters = t.optional(t.table),
	openCategoryFiltersPrompt = t.callback,
	openPriceFilterPrompt = t.callback,
	searchUuid = t.optional(t.number),
	setSearchType = t.callback,
	setSearchParameters = t.callback,
	navigateToSearch = t.callback,
	minPrice = t.number,
	maxPrice = t.number,
})

function CatalogPillBar:init()
	self.showCategoryFiltersPrompt = function()
		self.props.openCategoryFiltersPrompt(function() self:refreshSearch() end)
	end

	self.showPriceFilterPrompt = function()
		self.props.openPriceFilterPrompt(function() self:refreshSearch() end)
	end
end

function CatalogPillBar:refreshSearch()
	if self.props.searchParameters == nil then
		-- TODO: Adjust main catalog page
	else
		-- Create a new search to apply the new filters
		local searchUuid = SearchUuid()
		self.props.setSearchType(searchUuid, Constants.SearchTypes.Catalog)
		self.props.setSearchParameters(searchUuid, self.props.searchParameters)
		self.props.navigateToSearch(self.props.currentRoute, searchUuid)
	end
end

function CatalogPillBar:getCategoryInfo(localized)
	local category
	local count = 0
	for categoryId, isSelected in pairs(self.props.filtersSelection) do
		if isSelected then
			count = count + 1
			category = categoryId
		end
	end

	local label = localized["category"]
	if count == 1 then
		label = label .. ": " .. localized[category]
	elseif count > 1 then
		label = label .. " (" .. tostring(count) .. ")"
	end

	return label, count
end

function CatalogPillBar:getPriceInfo(localized)
	if self.props.minPrice == CatalogConstants.MinPriceFilter and self.props.maxPrice == CatalogConstants.MaxPriceFilter then
		return localized["price"], false
	end

	if self.props.maxPrice == 0 then
		return localized["price"] .. ": " .. localized["free"], true
	end

	local label = localized["price"] .. ": "

	local minPrice = tostring(self.props.minPrice)
	local maxPrice = tostring(self.props.maxPrice)

	if self.props.maxPrice == CatalogConstants.MaxPriceFilter then
		maxPrice = maxPrice .. "+"
	end

	if self.props.minPrice == self.props.maxPrice then
		label = label .. maxPrice
	else
		label = label .. minPrice .. " - " .. maxPrice
	end

	return label, true
end

function CatalogPillBar:render()
	return withLocalization(Cryo.Dictionary.join(CatalogConstants.FilterLabels, {
		category = "Feature.Catalog.Label.Category",
		price = "Feature.Catalog.Label.Price",
		free = "Feature.Catalog.LabelFree",
	}))(function(localized)
		local categoryLabel, categoryCount = self:getCategoryInfo(localized)
		local priceLabel, isPriceSelected = self:getPriceInfo(localized)

		return Roact.createElement(PillBar, {
			height = self.props.pillbarHeight
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, BUTTON_PADDING),
			}),
			UIPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 15),
				PaddingRight = UDim.new(0, 15),
			}),

			SortPill = Roact.createElement(SmallPill, {
				text = "Sort: Relevance",
				layoutOrder = 1,
				isSelected = true,
				isLoading = self.props.isLoading,
				onActivated = function() print("Sort pushed") end,
			}),
			PricePill = Roact.createElement(SmallPill, {
				text = priceLabel,
				layoutOrder = 2,
				isSelected = isPriceSelected,
				isLoading = self.props.isLoading,
				onActivated = self.showPriceFilterPrompt,
			}),
			CategoryPill = self.props.showCategories and Roact.createElement(SmallPill, {
				text = categoryLabel,
				layoutOrder = 3,
				isSelected = categoryCount > 0,
				isLoading = self.props.isLoading,
				onActivated = self.showCategoryFiltersPrompt,
			}),
		})
	end)
end

local function mapStateToProps(state, props)
	return {
		filtersSelection = state.AvatarExperience.Catalog.SortAndFilters.CategoryFilters,
		minPrice = state.AvatarExperience.Catalog.SortAndFilters.PriceRange.minPrice,
		maxPrice = state.AvatarExperience.Catalog.SortAndFilters.PriceRange.maxPrice,
		searchParameters = state.SearchesParameters[props.searchUuid],
	}
end

local function mapDispatchToProps(dispatch)
	return {
		openCategoryFiltersPrompt = function(onAcceptCallback)
			dispatch(SetCentralOverlay(OverlayType.CategoryFiltersPrompt, {
				onAcceptCallback = onAcceptCallback
			}))
		end,

		openPriceFilterPrompt = function(onAcceptCallback)
			dispatch(SetCentralOverlay(OverlayType.PriceFilterPrompt, {
				onAcceptCallback = onAcceptCallback
			}))
		end,

		navigateToSearch = function(currentRoute, searchUuid)
			dispatch(NavigateSideways({ name = AppPage.SearchPage, detail = searchUuid }))
		end,

		setSearchType = function(searchUuid, searchType)
			return dispatch(SetSearchType(searchUuid, searchType))
		end,

		setSearchParameters = function(searchUuid, searchParameters)
			return dispatch(SetSearchParameters(searchUuid, searchParameters))
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(CatalogPillBar)