local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local RoactServices = require(Modules.Common.RoactServices)

local AppPageLocalizationKeys = require(Modules.NotLApp.AppPageLocalizationKeys)
local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)
local AppPage = require(Modules.NotLApp.AppPage)

local AvatarExperienceView = require(Modules.AvatarExperience.Common.Components.AvatarExperienceView)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local AvatarNavigationItemsView = require(Modules.AvatarExperience.AvatarEditor.Components.AvatarNavigationItemsView)

local TopBar = require(Modules.InGameEditor.Components.TopBar)

local AppPageLocalizationKeys = require(Modules.NotLApp.AppPageLocalizationKeys)

local IsCatalogEnabled = require(Modules.Config.IsCatalogEnabled)

local Toggle3DFullView = require(Modules.AvatarExperience.AvatarEditor.Thunks.Toggle3DFullView)
local ToggleUIFullView = require(Modules.AvatarExperience.AvatarEditor.Thunks.ToggleUIFullView)

local FFlagEnableAvatarExperienceLandingPage = false

local AvatarEditorPage = Roact.PureComponent:extend("AvatarEditorPage")

function AvatarEditorPage:init()
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

function AvatarEditorPage:renderTopBar()

	return Roact.createElement(TopBar, {
		showNotifications = false,
		showCatalogButton = IsCatalogEnabled,
		showBackButton = false,
		showSearch = false,
		textKey = AppPageLocalizationKeys[AppPage.AvatarEditor],
		transparentBackground = FFlagEnableAvatarExperienceLandingPage,
		hideSiteMessageBanner = isPortrait,
	})
end

function AvatarEditorPage:render()
	local isUIFullView = self.props.isUIFullView
	local isFullView = self.props.isFullView
	local page = self.props.page

	return Roact.createElement(AvatarExperienceView, {
		bottomBarEnabled = not FFlagEnableAvatarExperienceLandingPage,
		changeViewFunction = self.changeView,
		isFullView = page == AppPage.AvatarExperienceLandingPage or isFullView,
		isUIFullView = isUIFullView,
		topBar = self:renderTopBar(),
	}, {
		AvatarNavigationItemsView = Roact.createElement(AvatarNavigationItemsView),
	})
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local deviceOrientation = state.DeviceOrientation
		local isPortrait = deviceOrientation == DeviceOrientationMode.Portrait

		return {
			page = AvatarExperienceUtils.getCurrentPage(state),
			isUIFullView = state.AvatarExperience.AvatarEditor.UIFullView,
			isFullView = state.AvatarExperience.AvatarEditor.FullView,
			isPortrait = isPortrait,
		}
	end,

	function(dispatch)
		return {
			toggleUIFullView = function()
				dispatch(ToggleUIFullView())
			end,
			toggle3DFullView = function()
				dispatch(Toggle3DFullView())
			end,
		}
	end
)(AvatarEditorPage)
