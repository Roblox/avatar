--[[
	AppPageProperties.lua

	Created by David Brooks on 10/3/2018.

	This module returns a table that contains a set of properties attached to a given page.
	If a page does not have an entry for the property you want to access, you should assume
	a reasonable default.

	Property Name           : Description
	nameLocalizationKey     : Localization key. See AppPageLocalizationKeys.lua (slowly migrating to this file)
	tabBarHidden            : Hide the tab bar automatically when this page is on screen (AppRouter).
	overridesAppRouterTabBarControl : The page has custom tab bar management, so disengage AppRouter control.
	nativeWrapper			: Page is a wrapper that represents a native overlaid UI element.
	renderUnderlyingPage	: The page requires the immediately underlying page to be rendered (e.g. for transparency effect).
]]

local luaGameDetailsEnabled = true
local FFlagEnableLuaChatDiscussions = true
local FFlagEnableAvatarExperienceLandingPage = false

local CATALOG_TEXT = "CommonUI.Features.Label.Catalog"
local SHOP_TEXT = "Feature.Avatar.Action.Shop"

local AppPage = require(game:getService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules.NotLApp.AppPage)

local AppPageProperties = {
	[AppPage.None] = {
		nameLocalizationKey = "CommonUI.Features.Label.Nil"
	},
	[AppPage.Startup] = {
		tabBarHidden = true,
		nameLocalizationKey = "CommonUI.Features.Label.Startup",
	},
	[AppPage.Landing] = {
		tabBarHidden = true,
		nameLocalizationKey = "CommonUI.Features.Label.Startup",
	},
	[AppPage.Login] = {
		nameLocalizationKey = "Authentication.Login.Heading.Login",
		tabBarHidden = true,
	},
	[AppPage.TwoStep] = {
		nameLocalizationKey = "Authentication.TwoStepVerification.Label.TwoStepVerification",
		tabBarHidden = true,
	},
	[AppPage.Birthday] = {
		nameLocalizationKey = "Authentication.SignUp.Label.WhensYourBirthday",
		tabBarHidden = true,
	},
	[AppPage.CharacterSelectionPage] = {
		nameLocalizationKey = "Authentication.SignUp.Heading.SelectStartingAvatar",
		tabBarHidden = true,
	},
	[AppPage.UsernameSelectionPage] = {
		nameLocalizationKey = "Authentication.SignUp.Heading.UsernamePage",
		tabBarHidden = true,
	},
	[AppPage.PasswordSelectionPage] = {
		nameLocalizationKey = "Authentication.SignUp.Heading.PasswordPage",
		tabBarHidden = true,
	},
	[AppPage.SignUpVerificationPage] = {
		nameLocalizationKey = "Authentication.SignUp.Heading.VerificationPage",
		tabBarHidden = true,
	},
	[AppPage.SinglePageSignUp] = {
		nameLocalizationKey = "Authentication.SignUp.Label.SignUp",
		tabBarHidden = true,
	},
	[AppPage.WeChatLoginWrapper] = {
		nativeWrapper = true,
		tabBarHidden = true,
	},
	[AppPage.Home] = {
		nameLocalizationKey = "CommonUI.Features.Label.Home"
	},
	[AppPage.Games] = {
		nameLocalizationKey = "CommonUI.Features.Label.Home"
	},
	[AppPage.GameDetail] = {
		nameLocalizationKey = "CommonUI.Features.Heading.GameDetails",
		tabBarHidden = true,
		renderUnderlyingPage = true,
		blurUnderlyingPage = true,
	},
	[AppPage.AvatarEditor] = {
		nameLocalizationKey = FFlagEnableAvatarExperienceLandingPage and "Feature.Catalog.Action.Customize"
			or "CommonUI.Features.Label.Avatar",
		tabBarHidden = FFlagEnableAvatarExperienceLandingPage,
	},
	[AppPage.AvatarExperienceLandingPage] = {
		nameLocalizationKey = "CommonUI.Features.Label.Avatar",
	},
	[AppPage.Chat] = {
		nameLocalizationKey = "CommonUI.Features.Label.Chat",
		overridesAppRouterTabBarControl = true,
	},
	[AppPage.Discussions] = FFlagEnableLuaChatDiscussions and {
		nameLocalizationKey = "CommonUI.Features.Label.Discussions",
	} or nil,
	[AppPage.ShareGameToChat] = {
		tabBarHidden = true,
	},
	[AppPage.Catalog] = {
		nameLocalizationKey = (true or FFlagEnableAvatarExperienceLandingPage) and SHOP_TEXT
			or CATALOG_TEXT,
		tabBarHidden = true,
	},
	[AppPage.ItemDetails] = {
		overridesAppRouterTabBarControl = true,
		renderUnderlyingPage = true,
	},
	[AppPage.SearchPage] = true and {
		-- Search Page inherits visability from parent page
		overridesAppRouterTabBarControl = true,
	} or nil,
	[AppPage.More] = {
		nameLocalizationKey = "CommonUI.Features.Label.More"
	},
	[AppPage.About] = {
		nameLocalizationKey = "CommonUI.Features.Label.About"
	},
	[AppPage.Settings] = {
		nameLocalizationKey = "CommonUI.Features.Label.Settings"
	},
	[AppPage.DevSubs] = {
		nameLocalizationKey = "CommonUI.Features.Label.DevSubs"
	},
	[AppPage.Trades] = {
		nameLocalizationKey = "CommonUI.Features.Label.Trades"
	},
	[AppPage.Events] = {
		nameLocalizationKey = "CommonUI.Features.Label.Events"
	},
	[AppPage.BuildersClub] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
	[AppPage.GenericWebPage] = {
		nativeWrapper = true,
		tabBarHidden = true,
		renderUnderlyingPage = true,
	},
	[AppPage.SettingsSubPage] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
	[AppPage.YouTubePlayer] = {
		nativeWrapper = true,
		tabBarHidden = true,
		renderUnderlyingPage = true,
	},
	[AppPage.PurchaseRobux] = {
		nativeWrapper = true,
		tabBarHidden = false,
		renderUnderlyingPage = true,
	},
	[AppPage.Notifications] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
	[AppPage.MyFeed] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
	[AppPage.LogoutConfirmation] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
	[AppPage.AddFriends] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
	[AppPage.ViewUserProfile] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
	[AppPage.ViewProfile] = {
		nativeWrapper = true,
		renderUnderlyingPage = true,
	},
    [AppPage.LoginNative] = {
        nativeWrapper = true,
		tabBarHidden = true,
        renderUnderlyingPage = true,
    },
	[AppPage.CaptchaNative] = {
		nativeWrapper = true,
		tabBarHidden = true,
		renderUnderlyingPage = true,
	},
	[AppPage.ViewFriends] = {
		nativeWrapper = true,
		tabBarHidden = true,
		renderUnderlyingPage = true,
	},
	[AppPage.SellItemPage] = {
		nameLocalizationKey = "Feature.Catalog.Heading.SellItem",
		tabBarHidden = true,
		renderUnderlyingPage = true,
	},
	[AppPage.ResellersPage] = {
		nameLocalizationKey = "Feature.Catalog.Heading.Sellers",
		tabBarHidden = true,
		renderUnderlyingPage = true,
	},
	[AppPage.ShareSheet] = {
		nativeWrapper = true,
		tabBarHidden = true,
		renderUnderlyingPage = true,
	},
}

return AppPageProperties
