
local FFlagLuaCatalogRedirectOwnedBundleToCorrectCategory = true

local CatalogConstants

CatalogConstants = {
	ThumbnailSize = {
		["48"] = 48,
		["100"] = 100,
		["150"] = 150,
		["420"] = 420,
		["720"] = 720,
	},

	ThumbnailType = {
		Avatar = "Avatar",
		AvatarHeadShot = "AvatarHeadShot",
		Asset = "Asset",
		BundleThumbnail = "BundleThumbnail",
		Outfit = "Outfit",
	},

	ItemType = {
		Bundle = "Bundle",
		Asset = "Asset",
		UserOutfit = "UserOutfit",
	},

	BundleType = not FFlagLuaCatalogRedirectOwnedBundleToCorrectCategory and {
		AvatarAnimations = "AvatarAnimations",
		BodyParts = "BodyParts",
	},

	PageFetchLimit = 30,

	ItemDetailsKey = "luaapp.itemapi.itemDetails.",
	BundlesInfoKey = "luaapp.itemapi.bundlesinfo.",
	BuyButtonInfoKey = "catalog.getispurchasable.",
	BuyButtonAssetInfoKey = "catalog.getispurchasable.",
	PurchaseProductKey = "catalog.purchaseproduct.",
	RecommendedItemsForAssetsKey = "catalog.getrecommendeditemsforassets.",
	RecommendedItemsForBundlesKey = "catalog.getrecommendeditemsforbundles.",
	GetFavoriteBundleKey = "catalog.getFavoriteBundle",
	GetFavoriteAssetKey = "catalog.getFavoriteAsset",
	SetFavoriteBundleKey = "catalog.setFavoriteBundle",
	SetFavoriteAssetKey = "catalog.setFavoriteAsset",
	GetItemOwnershipStatus = "catalog.getItemOwnershipStatus",
	GetSellPageDataKey = "catalog.getSellPageData",
	RemoveCurrentlySellingAssetKey = "catalog.removeCurrentlySellingAsset",
	RemoveAvailableToSellAssetKey = "catalog.removeAvailableToSellAsset",
	GetResellersKey = "catalog.getResellersKey",
	GetAssetResalesDataKey = "catalog.getAssetResalesDataKey",
	FetchBundleInfoKey = "catalog.itemapi.bundlesinfo.",

	ExpectedCurrencyRobux = 1,

	PriceStatus = {
		Free = "Free",
		Offsale = "OffSale",
		NoResellers = "NoResellers",
	},

	PurchaseStatus = {
		Owned = 1,
		Purchasable = 2,
		NotPurchasable = 3,
	},

	ActionBar = {
		ActionBarHeight = 44,
		ActionBarGradientHeight = 40,
		DisabledButtonTransparency = 0.5,
	},

	LargeCardWidth = 148,
	MediumCardWidth = 100,

	bundleIncludedItemsCount = 6,
	recommendedItemsCount = 6,

	ItemRestrictions = {
		Limited = "Limited",
		LimitedUnique = "LimitedUnique",
	},

	ItemStatus = {
		New = "New",
		Sale = "Sale",
	},

	MaxResellersPerPage = 10,

	Filters = {
		"Characters",
		"Body",
		"Clothing",
		"Accessories",
		"Animation",
		"Emotes",
	},

	FilterLabels = {
		Characters = "Feature.Catalog.Label.Characters",
		Body = "Feature.Catalog.Label.Body",
		Clothing = "Feature.Catalog.Label.Clothing",
		Accessories = "Feature.Catalog.LabelAccessories",
		Animation = "Feature.Catalog.Label.Animation",
		Emotes = "Feature.Catalog.Label.Emotes",
	},

	FiltersApiMap = {
		Characters = {category = "BodyParts", subCategory = "Bundles"},
		Body = {category = "BodyParts", subCategory = "BodyParts"},
		Clothing = {category = "Clothing", subCategory = "Clothing"},
		Accessories = {category = "Accessories", subCategory = "Accessories"},
		Animation = {category = "AvatarAnimations", subCategory = "AnimationBundles"},
		Emotes = {category = "AvatarAnimations", subCategory = "EmoteAnimations"},
	},

	MinPriceFilter = 0,
	MaxPriceFilter = 1000,
	PriceFilterStep = 100,
}

return CatalogConstants
