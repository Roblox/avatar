local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local AppPage = require(Modules.NotLApp.AppPage)
local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)
local NavigateSideways = require(Modules.NotLApp.Thunks.NavigateSideways)
local NavigateSameLevel = require(Modules.NotLApp.Thunks.NavigateSameLevel)

local SetSearchType = require(Modules.NotLApp.Actions.SetSearchType)
local SetSearchParameters = require(Modules.NotLApp.Actions.SetSearchParameters)

local AppPageLocalizationKeys = require(Modules.NotLApp.AppPageLocalizationKeys)
local SearchUuid = require(Modules.NotLApp.SearchUuid)
local LocalizedTextLabel = require(Modules.NotLApp.LocalizedTextLabel)
local SearchBar = require(Modules.NotLApp.SearchBar)
local TouchFriendlyIconButton = require(Modules.NotLApp.TouchFriendlyIconButton)

local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)

local FFlagEnableAvatarExperienceLandingPage = false

local Images = UIBlox.App.ImageSet.Images

local NAV_BAR_SIZE = 44

local ICON_IMAGE_SIZE = 36
local ICON_BUTTON_SIZE = 44
local BACK_BUTTON_IMAGE = Images["icons/navigation/pushBack"]
local SEARCH_ICON_IMAGE = Images["icons/common/search"]
local CUSTOMIZE_ICON = Images["icons/menu/customize"]
local CATALOG_ICON = Images["icons/menu/shop"]

local SEARCH_BAR_SIZE = 260
local SEARCH_BAR_PADDING = 6

local portraitFormFactor = {
	MarginRight = 13,
	Padding = 2,
	IconButtonSize = 34,
	BackImageOffset = 16,
}

local tabletFormFactor = {
	MarginRight = 12,
	Padding = 3,
	IconButtonSize = 44,
	BackImageOffset = 20,
}

local DEFAULT_TEXT_COLOR = Color3.fromRGB(255, 255, 255)

local DEFAULT_TITLE_FONT = Enum.Font.SourceSansSemibold
local DEFAULT_TITLE_FONT_SIZE = 23

local DEFAULT_ZINDEX = 2

local TopBar = Roact.PureComponent:extend("TopBar")

TopBar.defaultProps = {
	textColor = DEFAULT_TEXT_COLOR,
	titleFont = DEFAULT_TITLE_FONT,
	titleSize = DEFAULT_TITLE_FONT_SIZE,
	backButtonImage = BACK_BUTTON_IMAGE,
	showSearch = false,
	showAvatarButton = false,
	showCatalogButton = false,
	ZIndex = DEFAULT_ZINDEX,
}

function TopBar:init()
	self.isMounted = false

	self.state = {
		isSearching = false,
		siteMessageBannerHeight = 0,
		absolutePosition = Vector2.new(0, 0),
	}

	self.onSearchButtonActivated = function()
		self:setState({
			isSearching = true,
		})
	end

	self.onExitSearch = function()
		if not self.isMounted then
			return
		end

		self:setState({
			isSearching = false,
		})
	end

	self.cancelSearchCallback = function()
		self.onExitSearch()
	end

	self.showAvatarEditorCallback = function()
		self.props.openAvatarEditorPage(self.props.navigationHistory)
	end

	self.showCatalogCallback = function()
		self.props.openCatalogPage(self.props.navigationHistory)
	end

	self.onSearchBarFocused = function()
		if not self.props.isPortrait then
			self:setState({
				isSearching = true,
			})
		end
	end

	self.confirmSearchCallback = function(keyword)
		local searchUuid = SearchUuid()

		self.props.setSearchType(searchUuid, "Catalog")
		self.props.setSearchParameters(searchUuid, keyword, true)

		self.onExitSearch()
		self.props.navigateToSearch(self.props.currentRoute, searchUuid, "Catalog")
	end

	self.absolutePositionChangedCallback = function(rbx)
		self:setState({
			absolutePosition = rbx.AbsolutePosition
		})
	end
end

function TopBar:didMount()
	self.isMounted = true
end

function TopBar:willUnmount()
	self.isMounted = false
end

function TopBar:render()
	local currentRoute = self.props.currentRoute

	local titleText = self.props.titleText

	local showSearch = self.props.showSearch
	local showAvatarButton = self.props.showAvatarButton
	local showCatalogButton = self.props.showCatalogButton

	local zIndex = self.props.ZIndex

	local topNavBarHeight = NAV_BAR_SIZE

	local currentPageName = currentRoute[#currentRoute].name
	local rootPageName = currentRoute[1].name

	local currentTopBarIconSpec = self.props.isPortrait and portraitFormFactor or tabletFormFactor

	local iconMarginRight = currentTopBarIconSpec and currentTopBarIconSpec.MarginRight or 0
	local iconPadding = currentTopBarIconSpec and currentTopBarIconSpec.Padding or 0
	local iconButtonSize = currentTopBarIconSpec and currentTopBarIconSpec.IconButtonSize or ICON_BUTTON_SIZE

	local pageNameLocalizationKey

	if FFlagEnableAvatarExperienceLandingPage and currentPageName == AppPage.ItemDetails
		and rootPageName == AppPage.AvatarExperienceLandingPage then

		local selectedPage = currentRoute[2] and currentRoute[2].name or rootPageName
		pageNameLocalizationKey = AppPageLocalizationKeys[selectedPage]
	else
		pageNameLocalizationKey = AppPageLocalizationKeys[currentPageName] or AppPageLocalizationKeys[rootPageName]
	end
	local isCompactView = self.props.isPortrait

	local navBarLayout = {}

	local searchPlaceholderText = "Search.GlobalSearch.Example.SearchCatalog"

	return withStyle(function(style)
		if isCompactView and self.state.isSearching then
			navBarLayout["SearchBar"] = Roact.createElement(SearchBar, {
				cancelSearch = self.cancelSearchCallback,
				confirmSearch = self.confirmSearchCallback,
				onFocused = self.onSearchBarFocused,
				isPhone = isCompactView,
				placeholderText = searchPlaceholderText,
			})
		else
			navBarLayout["Title"] = Roact.createElement(titleText and "TextLabel" or LocalizedTextLabel, {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Font = style.Font.Header1.Font,
				TextSize = style.Font.BaseSize * style.Font.Header1.RelativeSize,
				Text = titleText or pageNameLocalizationKey,
				TextColor3 = style.Theme.TextEmphasis.Color,
				TextTransparency = style.Theme.TextEmphasis.Transparency,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			})

			local rightIcons = {}
			rightIcons["Layout"] = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, iconPadding),
			})

			if showSearch then
				rightIcons["Search"] = isCompactView and Roact.createElement(TouchFriendlyIconButton, {
					Size = UDim2.new(0, iconButtonSize, 1, 0),
					LayoutOrder = 3,
					icon = SEARCH_ICON_IMAGE,
					iconSize = ICON_IMAGE_SIZE,
					iconColor = style.Theme.SystemPrimaryDefault.Color,
					iconTransparency = style.Theme.SystemPrimaryDefault.Transparency,
					onActivated = self.onSearchButtonActivated,
				}) or Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, SEARCH_BAR_SIZE + SEARCH_BAR_PADDING, 1, 0),
					LayoutOrder = 3,
				}, {
					SearchBar = Roact.createElement(SearchBar, {
						Size = UDim2.new(0, SEARCH_BAR_SIZE, 1, 0),
						cancelSearch = self.cancelSearchCallback,
						confirmSearch = self.confirmSearchCallback,
						onFocused = self.onSearchBarFocused,
						placeholderText = searchPlaceholderText,
						isPhone = isCompactView,
					})
				})
			end

			if showAvatarButton then
				rightIcons["Avatar"] = Roact.createElement(TouchFriendlyIconButton, {
					Size = UDim2.new(0, iconButtonSize, 1, 0),
					LayoutOrder = FFlagEnableAvatarExperienceLandingPage and 5 or 2,
					icon = CUSTOMIZE_ICON,
					iconSize = ICON_IMAGE_SIZE,
					iconColor = style.Theme.SystemPrimaryDefault.Color,
					iconTransparency = style.Theme.SystemPrimaryDefault.Transparency,
					useUIBloxImageSet = false,
					onActivated = self.state.isSearching and self.cancelSearchCallback or self.showAvatarEditorCallback,
				})
			end

			if showCatalogButton then
				rightIcons["Catalog"] = Roact.createElement(TouchFriendlyIconButton, {
					Size = UDim2.new(0, iconButtonSize, 1, 0),
					LayoutOrder = FFlagEnableAvatarExperienceLandingPage and 5 or 2,
					icon = CATALOG_ICON,
					iconSize = ICON_IMAGE_SIZE,
					iconColor = style.Theme.SystemPrimaryDefault.Color,
					iconTransparency = style.Theme.SystemPrimaryDefault.Transparency,
					useUIBloxImageSet = false,
					onActivated = self.state.isSearching and self.cancelSearchCallback or self.showCatalogCallback,
				})
			end

			navBarLayout["RightIcons"] = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -iconMarginRight, 0.5, 0),
				Size = UDim2.new(1, -iconMarginRight, 1, 0),
			}, rightIcons)
		end

		local topBarProps = {
			BackgroundColor3 = style.Theme.BackgroundDefault.Color,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, topNavBarHeight),
			ZIndex = 2,
		}
		topBarProps.Active = true

		local darkOverlaySize = UDim2.new(0, self.props.screenSize.X, 0, self.props.screenSize.Y)
		local darkOverlayPosition = UDim2.new(0, -self.state.absolutePosition.X, 0, -self.state.absolutePosition.Y)

		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = zIndex,

			[Roact.Change.AbsolutePosition] = self.absolutePositionChangedCallback,
		}, {
			TopBar = Roact.createElement("Frame", topBarProps,
			{
				NavBar = Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundColor3 = style.Theme.BackgroundDefault.Color,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 1, 0),
					Size = UDim2.new(1, 0, 0, NAV_BAR_SIZE),
				}, navBarLayout),
			}),
			DarkOverlay = Roact.createElement("TextButton", {
				Size = darkOverlaySize,
				Position = darkOverlayPosition,
				AutoButtonColor = false,
				BackgroundColor3 = style.Theme.Overlay.Color,
				BackgroundTransparency = style.Theme.Overlay.Transparency,
				Text = "",
				Visible = self.state.isSearching,
				[Roact.Event.Activated] = self.cancelSearchCallback,
				ZIndex = 1,
			}),
		})
	end)
end

TopBar = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local currentRoute = state.Navigation.history[#state.Navigation.history]

		return {
			screenSize = state.ScreenSize,
			isPortrait = state.DeviceOrientation == DeviceOrientationMode.Portrait,
			currentRoute = currentRoute,
			navigationHistory = state.Navigation.history,
		}
	end,
	function(dispatch)
		return {
			setSearchType = function(searchUuid, searchType)
				return dispatch(SetSearchType(searchUuid, searchType))
			end,
			setSearchParameters = function(searchUuid, searchKeyword, isKeywordSuggestionEnabled)
				return dispatch(SetSearchParameters(searchUuid, {
					searchKeyword = searchKeyword,
					isKeywordSuggestionEnabled = isKeywordSuggestionEnabled,
				}))
			end,
			navigateToSearch = function(currentRoute, searchUuid, searchType)
				local page = currentRoute[#currentRoute].name
				local isOnRootPage = page == AppPage.Catalog or page == AppPage.ItemDetails

				if isOnRootPage then
					dispatch(NavigateDown({ name = AppPage.SearchPage, detail = searchUuid }))
				else
					dispatch(NavigateSideways({ name = AppPage.SearchPage, detail = searchUuid }))
				end
			end,
			openAvatarEditorPage = function(navigationHistory)
				return dispatch(NavigateDown({ name = AppPage.AvatarEditor }))
			end,
			openCatalogPage = function(navigationHistory)
				--return dispatch(NavigateSameLevel(navigationHistory, AppPage.Catalog))
				return dispatch(NavigateDown({ name = AppPage.Catalog }))
			end,
		}
	end
)(TopBar)

return TopBar
