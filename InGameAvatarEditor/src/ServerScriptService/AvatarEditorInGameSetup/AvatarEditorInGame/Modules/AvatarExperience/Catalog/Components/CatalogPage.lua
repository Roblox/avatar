local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)

local AppPage = require(Modules.NotLApp.AppPage)
local AppPageLocalizationKeys = require(Modules.NotLApp.AppPageLocalizationKeys)
local Constants = require(Modules.NotLApp.Constants)
local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local AvatarExperienceView = require(Modules.AvatarExperience.Common.Components.AvatarExperienceView)
local NavigationItemsView = require(Modules.AvatarExperience.Catalog.Components.NavigationItemsView)

local CatalogNavigateBack = require(Modules.AvatarExperience.Catalog.Thunks.CatalogNavigateBack)

local TopBar = require(Modules.InGameEditor.Components.TopBar)

local Toggle3DFullView = require(Modules.AvatarExperience.Catalog.Thunks.Toggle3DFullView)
local ToggleUIFullView = require(Modules.AvatarExperience.Catalog.Thunks.ToggleUIFullView)

local FFlagLuaCatalogPageDisable3DView = false
local FFlagEnableAvatarExperienceLandingPage = false

local CatalogPage = Roact.PureComponent:extend("CatalogPage")

function CatalogPage:init()
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

	self.topBarBackButtonActivated = function()
		local catalogNavigateBack = self.props.catalogNavigateBack

		catalogNavigateBack()
	end
end

function CatalogPage:renderTopBar()
	local isPortrait = self.props.isPortrait
	local itemDetailsExpanded = self.props.itemDetailsExpanded


	return withLocalization({
		title = AppPageLocalizationKeys[AppPage.Catalog],
	})(function(localized)
		return Roact.createElement(TopBar, {
			forceCompactMode = true,
			showBuyRobux = false,
			showNotifications = false,
			showAvatarButton = true,
			showBackButton = not (isPortrait and itemDetailsExpanded),
			showSearch = true,
			searchType = Constants.SearchTypes.Catalog,
			titleText = localized.title,
			ZIndex = 2,
			onBackButtonActivated = self.topBarBackButtonActivated,
			transparentBackground = FFlagEnableAvatarExperienceLandingPage,
			hideSiteMessageBanner = isPortrait,
		})
	end)
end

function CatalogPage:render()
	local isFullView = self.props.isFullView
	local isUIFullView = self.props.isUIFullView

	return Roact.createElement(AvatarExperienceView, {
		changeViewFunction = self.changeView,
		isDisabled = FFlagLuaCatalogPageDisable3DView,
		isFullView = isFullView,
		isUIFullView = isUIFullView,
		topBar = self:renderTopBar(),
	}, {
		NavigationAndItemsList = Roact.createElement(NavigationItemsView),
	})
end

local function mapStateToProps(state)
	local deviceOrientation = state.DeviceOrientation
	local isPortrait = deviceOrientation == DeviceOrientationMode.Portrait

    return {
		isFullView = state.AvatarExperience.Catalog.FullView,
		isUIFullView = state.AvatarExperience.Catalog.UIFullView,
		isPortrait = isPortrait,
		itemDetailsExpanded = state.AvatarExperience.Common.ItemDetailsExpanded,
		page = AvatarExperienceUtils.getCurrentPage(state),
	}
end

local function mapDispatchToProps(dispatch)
	return {
		toggle3DFullView = function()
			dispatch(Toggle3DFullView())
		end,
		toggleUIFullView = function()
			dispatch(ToggleUIFullView())
		end,
		catalogNavigateBack = function()
			dispatch(CatalogNavigateBack())
		end,
	}
end

CatalogPage = RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(CatalogPage)

return CatalogPage
