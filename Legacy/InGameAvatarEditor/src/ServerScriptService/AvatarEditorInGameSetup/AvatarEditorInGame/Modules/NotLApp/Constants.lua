
local Constants = {
	Color = {
		GRAY1 = Color3.fromRGB(25, 25, 25),
		GRAY2 = Color3.fromRGB(117, 117, 117),
		GRAY3 = Color3.fromRGB(184, 184, 184),
		GRAY4 = Color3.fromRGB(227, 227, 227),
		GRAY5 = Color3.fromRGB(242, 242, 242),
		GRAY6 = Color3.fromRGB(245, 245, 245),
		GRAY_SEPARATOR = Color3.fromRGB(172, 170, 161),
		GRAY_AVATAR_BACKGROUND = Color3.fromRGB(209, 209, 209),
		WHITE = Color3.fromRGB(255, 255, 255),
		BLUE_PRIMARY = Color3.fromRGB(0, 162, 255),
		BLUE_HOVER = Color3.fromRGB(50, 181, 255),
		BLUE_PRESSED = Color3.fromRGB(0, 116, 189),
		BLUE_DISABLED = Color3.fromRGB(153, 218, 255),
		GREEN_PRIMARY = Color3.fromRGB(2, 183, 87),
		GREEN_HOVER = Color3.fromRGB(63, 198, 121),
		GREEN_PRESSED = Color3.fromRGB(17, 130, 55),
		GREEN_DISABLED = Color3.fromRGB(163, 226, 189),
		RED_PRIMARY = Color3.fromRGB(226, 35, 26),
		RED_NEGATIVE = Color3.fromRGB(216, 104, 104),
		RED_HOVER = Color3.fromRGB(226, 118, 118),
		RED_PRESSED = Color3.fromRGB(172, 30, 45),
		BROWN_WARNING = Color3.fromRGB(162, 89, 1),
		ORANGE = Color3.fromRGB(246, 136, 2),
		ORANGE_FAVORITE = Color3.fromRGB(246, 183, 2),
		ALPHA_SHADOW_PRIMARY = 0.3, -- Used with Gray1
		ALPHA_SHADOW_HOVER = 0.75, -- Used with Gray1
	},
	DisplayOrder = {
		BottomBar = 10,
		--TODO: ContextualListMenu should be moved into CentralOverlay and the display order control by it.
		--https://jira.rbx.com/browse/MOBLUAPP-1834
		ContextualListMenu = 11,
		CentralOverlay = 12,
		Toast = 13,
		AntiAddictionPrompt = 100,
		AutoUpgradePrompt = 101,
	},
	DEFAULT_GAME_FETCH_COUNT = 40,
	DEFAULT_RECOMMENDED_GAMES_FETCH_COUNT = 6,
	DEFAULT_GAME_ICON = "rbxasset://textures/ui/LuaApp/icons/ic-game.png",
	UNIFIED_HOME_GAMES_FETCH_COUNT = 72,
	DEFAULT_WIDE_CONTEXTUAL_MENU__WIDTH = 320,
	DEFAULT_CONTEXTUAL_MENU_CANCEL_HEIGHT = 64,
	TOP_BAR_SIZE = 64,
	BOTTOM_BAR_SIZE = 48,
	SECTION_HEADER_HEIGHT = 26,
	USER_CAROUSEL_PADDING = 15,
	GAME_CAROUSEL_PADDING = 15,
	GAME_CAROUSEL_CHILD_PADDING = 12,
	GAME_GRID_PADDING = 15,
	GAME_GRID_CHILD_PADDING = 12,
	MORE_PAGE_ROW_HEIGHT = 50,
	MORE_PAGE_SECTION_PADDING = 20,
	MORE_PAGE_ROW_PADDING_LEFT = 20,
	MORE_PAGE_ROW_PADDING_RIGHT = 10,
	MORE_PAGE_TEXT_PADDING_WITH_ICON = 56,
	MORE_PAGE_WIDE_PADDING_VERTICAL = 40,
	MORE_PAGE_WIDE_PADDING_HORIZONTAL = 60,
	PeopleList = {
		ADD_FRIENDS_FRAME_WIDTH = 80,
	},
	PlacesList = {
		ContextualMenu = {
			EntryHeight = 67,
			HorizontalOuterPadding = 15,
			HorizontalInnerPadding = 12,
			AvatarSize = 44,
		},
	},
	GameSortGroups = {
		ChatGames = "ChatGames",
		Games = "Games",
		HomeGames = "HomeGames",
        GamesSeeAll = "GamesSeeAll",
		UnifiedHomeSorts = "UnifiedHomeSorts",
	},
	ApiUsedForSorts = {
		ChatGames = "ChatSorts",
		Games = "GamesDefaultSorts",
		HomeGames = "HomeSorts",
        GamesSeeAll = "GamesAllSorts",
		UnifiedHomeSorts = "UnifiedHomeSorts",
	},
	SearchTypes = {
		Games = "Games",
		Groups = "Groups",
		Players = "Players",
		Catalog = "Catalog",
		Library = "Library",
	},
	AvatarThumbnailSizes = {
		Size48x48 = "Size48x48",
		Size100x100 = "Size100x100",
		Size150x150 = "Size150x150",
		Size720x720 = "Size720x720",
	},
	AVATAR_PLACEHOLDER_IMAGE = "rbxasset://textures/ui/LuaApp/graphic/ph-avatar-portrait.png",

	HumanoidDescriptionIdToName = {
		["2"]  = "Shirt",
		["8"]  = "HatAccessory",
		["41"] = "HairAccessory",
		["42"] = "FaceAccessory",
		["43"] = "NeckAccessory",
		["44"] = "ShouldersAccessory",
		["45"] = "FrontAccessory",
		["46"] = "BackAccessory",
		["47"] = "WaistAccessory",
		["11"] = "Shirt",
		["12"] = "Pants",
		["19"] = "Gear",
		["17"] = "Head",
		["18"] = "Face",
		["27"] = "Torso",
		["28"] = "RightArm",
		["29"] = "LeftArm",
		["30"] = "LeftLeg",
		["31"] = "RightLeg",
		["48"] = "ClimbAnimation",
		["50"] = "FallAnimation",
		["51"] = "IdleAnimation",
		["52"] = "JumpAnimation",
		["53"] = "RunAnimation",
		["54"] = "SwimAnimation",
		["55"] = "WalkAnimation",
	},

	LEGACY_GAME_SORT_IDS = {
		default = 0,
		BuildersClub = 14,
		Featured = 3,
		FriendActivity = 17,
		MyFavorite = 5,
		MyRecent = 6,
		Popular = 1,
		PopularInCountry = 20,
		PopularInVr = 19,
		Purchased = 10,
		Recommended = 16,
		TopFavorite = 2,
		TopGrossing = 8,
		TopPaid = 9,
		TopRated = 11,
		TopRetaining = 16,
	},

	GameMediaImageType = {
		Image = 1,
		YouTubeVideo = 33
	},

	GameDetails = {
		ActionBarHeight = 44,
		ActionBarGradientHeight = 40,
	},

	Currency = {
		Robux = 1,
	},

	GameCardLayoutType = {
		Small = "Small",
		Medium = "Medium",
		Large = "Large",
	},

	HomePagePanelProps = {
		WidgetTextSize = 24,
		WidgetIconSize = 26,
		WidgetIconTextGutter = 9,
		WidgetContentText = {
			Size = 16,
		},
	},

	HomePageLogoSize = Vector2.new(60, 60),

	Themes = {
		Dark = "dark",
		Light = "light",
		Classic = "classic",
	},

	TempRnSwitchNavigatorName = "RootSwitchNavigator",
}

Constants.GameBasicStatsLayoutType = {
	[Constants.GameCardLayoutType.Small] = "SmallGameCard",
	[Constants.GameCardLayoutType.Medium] = "MediumGameCard",
	[Constants.GameCardLayoutType.Large] = "LargeGameCard",
	GameDetails = "GameDetails",
}

return Constants
