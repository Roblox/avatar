-- Tables describing each Category and Subcategory in the Catalog page

local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Constants = require(Modules.AvatarExperience.Common.Constants)
local SearchUuid = require(Modules.NotLApp.SearchUuid)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local AssetTypesAll = {
	Constants.AssetTypes.Hat,
	Constants.AssetTypes.Head,
	Constants.AssetTypes.Face,
	Constants.AssetTypes.Gear,
	Constants.AssetTypes.Hair,
	Constants.AssetTypes.FaceAccessory,
	Constants.AssetTypes.Neck,
	Constants.AssetTypes.Shoulder,
	Constants.AssetTypes.Front,
	Constants.AssetTypes.Back,
	Constants.AssetTypes.Waist,
	Constants.AssetTypes.Emote,
	Constants.AssetTypes.TShirtAccessory,
	Constants.AssetTypes.ShirtAccessory,
	Constants.AssetTypes.PantsAccessory,
	Constants.AssetTypes.JacketAccessory,
	Constants.AssetTypes.SweaterAccessory,
	Constants.AssetTypes.ShortsAccessory,
	Constants.AssetTypes.LeftShoeAccessory,
	Constants.AssetTypes.RightShoeAccessory,
	Constants.AssetTypes.DressSkirtAccessory,
}

local Recommended = {
	Name = "Recommended",
	Title = "Feature.Avatar.Heading.Recommended",
	CategoryFilter = Enum.CatalogCategoryFilter.Recommended,
	DisableFilters = true,
	SearchUuid = SearchUuid(),
	TimeToRefresh = CatalogConstants.MinSecsToRefreshRecommendedCatalogPage,

	Subcategories = {
		[1] = {
			Name = "Featured",
			Title = "Feature.Catalog.Label.Featured",
			CategoryFilter = Enum.CatalogCategoryFilter.Featured,
			DisableFilters = false,
			SearchUuid = SearchUuid(),
			-- We merge in properties from parent category in buildCategoryInfoOld.
			-- This has undesired side-effect that if parent category has a timeout
			-- on refresh, children do too. We have to explicitly set children to
			-- "don't care about refresh" value (anything less than 0)
			TimeToRefresh = -1,
		},
		[2] = {
			Name = "Limited",
			Title = "Feature.Catalog.Label.Limited",
			CategoryFilter = Enum.CatalogCategoryFilter.Collectibles,
			DisableFilters = false,
			SearchUuid = SearchUuid(),
			TimeToRefresh = -1,
		},
		[3] = {
			Name = "Community",
			Title = "Feature.Catalog.Label.Community",

			AssetTypes = AssetTypesAll,
			CategoryFilter = Enum.CatalogCategoryFilter.CommunityCreations,
			DisableFilters = false,
			SearchUuid = SearchUuid(),
			TimeToRefresh = -1,
		},
		[4] = {
			Name = "Premium",
			Title = "Feature.Catalog.Label.Premium",
			CategoryFilter = Enum.CatalogCategoryFilter.Premium,
			DisableFilters = false,
			SearchUuid = SearchUuid(),
			TimeToRefresh = -1,
		},
	},
}

local Characters = {
	Name = "Characters",
	Title = "Feature.Catalog.Label.Characters",

	BundleTypes = { Enum.BundleType.BodyParts },
	SearchUuid = SearchUuid(),
}

local Clothing = {
	Name = "Clothing",
	Title = "Feature.Catalog.Label.Clothing",

	AssetTypes = {
		Constants.AssetTypes.ShirtAccessory,
		Constants.AssetTypes.TShirtAccessory,
		Constants.AssetTypes.SweaterAccessory,
		Constants.AssetTypes.JacketAccessory,
		Constants.AssetTypes.PantsAccessory,
		Constants.AssetTypes.ShortsAccessory,
		Constants.AssetTypes.DressSkirtAccessory,
		Constants.AssetTypes.LeftShoeAccessory,
		Constants.AssetTypes.RightShoeAccessory,
		Constants.AssetTypes.Shirt,
		Constants.AssetTypes.TShirt,
		Constants.AssetTypes.Pants,
	},
	SearchUuid = SearchUuid(),
	Subcategories = {
		[1] = {
			Name = "Shirts",
			Title = "Feature.Avatar.Label.Shirts",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			AssetTypes = {
				Constants.AssetTypes.ShirtAccessory,
			},
			SearchUuid = SearchUuid(),
		},
		[2] = {
			Name = "TShirts",
			Title = "Feature.Catalog.LabelTShirts",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			AssetTypes = {
				Constants.AssetTypes.TShirtAccessory,
			},
			SearchUuid = SearchUuid(),
		},
		[3] = {
			Name = "Sweaters",
			Title = "Feature.Avatar.Label.Sweaters",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			AssetTypes = {
				Constants.AssetTypes.SweaterAccessory,
			},
			SearchUuid = SearchUuid(),
		},
		[4] = {
			Name = "Jackets",
			Title = "Feature.Avatar.Label.Jackets",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,
			AssetTypes = {
				Constants.AssetTypes.JacketAccessory
			},
			SearchUuid = SearchUuid(),
		},
		[5] = {
			Name = "Pants",
			Title = "Feature.Avatar.Label.Pants",

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 12,
			AssetTypes = {
				Constants.AssetTypes.PantsAccessory,
			},
			SearchUuid = SearchUuid(),
		},
		[6] = {
			Name = "DressSkirt",
			Title = "Feature.Avatar.Label.DressesAndSkirts",

			AssetTypes = {
				Constants.AssetTypes.DressSkirtAccessory,
			},
			SearchUuid = SearchUuid(),
		},
		[7] = {
			Name = "Shorts",
			Title = "Feature.Avatar.Label.Shorts",

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 12,
			AssetTypes = {
				Constants.AssetTypes.ShortsAccessory,
			},
			SearchUuid = SearchUuid(),
		},
		[8] = {
			Name = "Shoes",
			Title = "Feature.Avatar.Label.Shoes",

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 12,
			AssetTypes = {
				Constants.AssetTypes.LeftShoeAccessory,
				Constants.AssetTypes.RightShoeAccessory,
			},
			SearchUuid = SearchUuid(),
		},
		[9] = {
			Name = "Classic Shirts",
			Title = "Feature.Avatar.Label.ClassicShirts",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			AssetTypes = { Constants.AssetTypes.Shirt },
			SearchUuid = SearchUuid(),
		},
		[10] = {
			Name = "Classic T-Shirts",
			Title = "Feature.Avatar.Label.ClassicTShirts",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			AssetTypes = { Constants.AssetTypes.TShirt },
			SearchUuid = SearchUuid(),
		},
		[11] = {
			Name = "Classic Pants",
			Title = "Feature.Avatar.Label.ClassicPants",

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 12,

			AssetTypes = { Constants.AssetTypes.Pants },
			SearchUuid = SearchUuid(),
		},
	}
}

local Accessories = {
	Name = "Accessories",
	Title = "Feature.Catalog.LabelAccessories",

	AssetTypes = {
		Constants.AssetTypes.Hat,
		Constants.AssetTypes.FaceAccessory,
		Constants.AssetTypes.Neck,
		Constants.AssetTypes.Shoulder,
		Constants.AssetTypes.Front,
		Constants.AssetTypes.Back,
		Constants.AssetTypes.Waist,
		Constants.AssetTypes.Gear,
	},
	SearchUuid = SearchUuid(),
	Subcategories = {
		[1] = {
			Name = "Hats",
			Title = "Feature.Avatar.Label.Heads", -- Hats are shown as "Heads" to the user.

			CameraFocus = Constants.FocusType.Head,
			CameraZoomRadius = 11,

			AssetTypes = { Constants.AssetTypes.Hat },
			SearchUuid = SearchUuid(),
		},
		[2] = {
			Name = "Face",
			Title = "Feature.Avatar.Label.Face",

			CameraFocus = Constants.FocusType.Face,
			CameraZoomRadius = 4.5,

			AssetTypes = { Constants.AssetTypes.FaceAccessory },
			SearchUuid = SearchUuid(),
		},
		[3] = {
			Name = "Neck",
			Title = "Feature.Avatar.Label.Neck",

			CameraFocus = Constants.FocusType.Neck,
			CameraZoomRadius = 9,

			AssetTypes = { Constants.AssetTypes.Neck },
			SearchUuid = SearchUuid(),
		},
		[4] = {
			Name = "Shoulder",
			Title = "Feature.Avatar.Label.Shoulder",

			CameraFocus = Constants.FocusType.Shoulders,
			CameraZoomRadius = 11,

			AssetTypes = { Constants.AssetTypes.Shoulder },
			SearchUuid = SearchUuid(),
		},
		[5] = {
			Name = "Front",
			Title = "Feature.Avatar.Label.Front",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 9.5,

			AssetTypes = { Constants.AssetTypes.Front },
			SearchUuid = SearchUuid(),
		},
		[6] = {
			Name = "Back",
			Title = "Feature.Avatar.Label.Back",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 21,

			AssetTypes = { Constants.AssetTypes.Back },
			SearchUuid = SearchUuid(),
		},
		[7] = {
			Name = "Waist",
			Title = "Feature.Avatar.Label.Waist",

			CameraFocus = Constants.FocusType.Waist,
			CameraZoomRadius = 17,

			AssetTypes = { Constants.AssetTypes.Waist },
			SearchUuid = SearchUuid(),
		},
		[8] = {
			Name = "Gear",
			Title = "Feature.Catalog.Label.Gear",

			AssetTypes = { Constants.AssetTypes.Gear },
			SearchUuid = SearchUuid(),
		},
	}
}

local Body = {
	Name = "Body",
	Title = "Feature.Catalog.Label.Body",

	AssetTypes = {
		Constants.AssetTypes.Hair,
		Constants.AssetTypes.Head,
		Constants.AssetTypes.Face
	},
	SearchUuid = SearchUuid(),
	Subcategories = {
		[1] = {
			Name = "Hair",
			Title = "Feature.Catalog.Label.Hair",

			CameraFocus = Constants.FocusType.Head,
			CameraZoomRadius = 8.5,

			AssetTypes = { Constants.AssetTypes.Hair },
			SearchUuid = SearchUuid(),
		},
		[2] = {
			Name = "Head",
			Title = "Feature.Avatar.Label.Heads",

			CameraFocus = Constants.FocusType.Head,
			CameraZoomRadius = 6.5,

			AssetTypes = { Constants.AssetTypes.Head },
			SearchUuid = SearchUuid(),
		},
		[3] = {
			Name = "Faces",
			Title = "Feature.Avatar.Label.Faces",

			CameraFocus = Constants.FocusType.Face,
			CameraZoomRadius = 7,

			AssetTypes = { Constants.AssetTypes.Face },
			SearchUuid = SearchUuid(),
		},
	},
}

local Animation = {
	Name = "Animation",
	Title = "Feature.Catalog.Label.Animation",

	CameraZoomRadius = Constants.AnimationCategoryCameraZoomRadius,

	BundleTypes = { Enum.BundleType.Animations },
	PageType = Constants.PageType.Animation,
	SearchUuid = SearchUuid(),
}

local Emotes = {
	Name = "Emotes",
	Title = "Feature.Catalog.Label.Emotes",

	CameraZoomRadius = Constants.AnimationCategoryCameraZoomRadius,

	AssetTypes = { Constants.AssetTypes.Emote },
	PageType = Constants.PageType.Emotes,
	SearchUuid = SearchUuid(),
}

local RecommendedCategoryList = {
	Recommended,
	Characters,
	Clothing,
	Accessories,
	Body,
	Animation,
	Emotes,
}

return RecommendedCategoryList
