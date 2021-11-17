--[[
	Tables describing each Category and Subcategory in the Avatar Editor page

	RenderItemTiles: Describes if this pages renders standard UIBlox item tiles.
	RecommendationsType: Describes if we show recommendations based on this page type and what kind.
]]
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Constants = require(Modules.AvatarExperience.Common.Constants)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local SearchUuid = require(Modules.NotLApp.SearchUuid)

local Character = {
	Name = AvatarEditorConstants.CharacterKey,
	Title = "Feature.Catalog.Label.Characters",

	RenderItemTiles = true,
	RenderCostumeItemTiles = true,
	RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
	MatchingCatalogPage = {
		CategoryIndex = Constants.CatalogStructureLC.Categories.Characters,
	},

	SearchUuid = AvatarEditorConstants.CharacterKey,
	Category = 1,
	Subcategory = nil,

	Subcategories = {
		[1] = {
			Name = "Creations",
			Title = "Feature.Avatar.Label.Creations",
			RenderItemTiles = true,
			RenderCostumeItemTiles = true,
			RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Characters,
			},
			SearchUuid = AvatarEditorConstants.EditableCharacterKey,
			Category = 1,
			Subcategory = 1,
			BundleTypes = {
				Constants.BundleType.BodyParts,
				Constants.BundleType.Animations,
			}
		},
		[2] = {
			Name = "Purchased",
			Title = "Feature.Avatar.Label.Purchased",
			RenderItemTiles = true,
			RenderCostumeItemTiles = true,
			RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Characters,
			},
			SearchUuid = AvatarEditorConstants.PurchasedCharacterKey,
			Category = 1,
			Subcategory = 2,
		}
	},
}

local Clothing = {
	Name = "Clothing",
	Title = "Feature.Catalog.Label.Clothing",
	Category = 2,
	Subcategory = nil,

	Subcategories = {
		[1] = {
			Name = "Tops",
			Title = "Feature.Catalog.Label.Tops",
			AssetTypeId = Constants.AssetTypes.TShirtAccessory,
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			-- According to Design, TShirts should be where to go.
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.TShirts,
			},

			AssetTypes = {
				Constants.AssetTypes.ShirtAccessory,
				Constants.AssetTypes.TShirtAccessory,
				Constants.AssetTypes.SweaterAccessory,
			},
			SearchUuid = SearchUuid(),
			Category = 2,
			Subcategory = 1,
		},
		[2] = {
			Name = "Outerwear",
			Title = "Feature.Avatar.Label.Outerwear",
			AssetTypeId = Constants.AssetTypes.JacketAccessory,
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			-- According to Design, Jackets should be where to go.
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Jackets,
			},

			AssetTypes = {
				Constants.AssetTypes.JacketAccessory,
			},
			SearchUuid = SearchUuid(),
			Category = 2,
			Subcategory = 2,
		},
		[3] = {
			Name = "Bottoms",
			Title = "Feature.Avatar.Label.Bottoms",
			AssetTypeId = Constants.AssetTypes.PantsAccessory,
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 12,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			-- According to Design, Pants should be where to go.
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Pants,
			},

			AssetTypes = {
				Constants.AssetTypes.PantsAccessory,
				Constants.AssetTypes.ShortsAccessory,
				Constants.AssetTypes.DressSkirtAccessory,
			},
			SearchUuid = SearchUuid(),
			Category = 2,
			Subcategory = 3,
		},
		[4] = {
			Name = "Left Shoes",
			Title = "Feature.Avatar.Label.LeftShoes",
			AssetTypeId = Constants.AssetTypes.LeftShoeAccessory,
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 12,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Shoes,
			},

			AssetTypes = { Constants.AssetTypes.LeftShoeAccessory },
			SearchUuid = SearchUuid(),
			Category = 2,
			Subcategory = 4,
		},
		[5] = {
			Name = "Right Shoes",
			Title = "Feature.Avatar.Label.RightShoes",
			AssetTypeId = Constants.AssetTypes.RightShoeAccessory,
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 12,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Shoes,
			},

			AssetTypes = { Constants.AssetTypes.RightShoeAccessory },
			SearchUuid = SearchUuid(),
			Category = 2,
			Subcategory = 5,
		},
		[6] = {
			Name = "Classic Shirts",
			Title = "Feature.Avatar.Label.ClassicShirts",
			AssetTypeId = "11",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.ClassicShirts,
			},

			AssetTypes = { Constants.AssetTypes.Shirt },
			SearchUuid = SearchUuid(),
			Category = 2,
			Subcategory = 6,
		},
		[7] = {
			Name = "Classic T-Shirts",
			Title = "Feature.Avatar.Label.ClassicTShirts",

			AssetTypeId = "2",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.ClassicTShirts,
			},

			AssetTypes = { Constants.AssetTypes.TShirt },
			SearchUuid = SearchUuid(),
			Category = 2,
			Subcategory = 7,
		},
		[8] = {
			Name = "Classic Pants",
			Title = "Feature.Avatar.Label.ClassicPants",
			AssetTypeId = "12",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 12,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.ClassicPants,
			},

			AssetTypes = { Constants.AssetTypes.Pants },
			SearchUuid = SearchUuid(),
			Category = 2,
			Subcategory = 8,
		},
	}
}

local Accessories = {
	Name = "Accessories",
	Title = "Feature.Catalog.LabelAccessories",
	Category = 3,
	Subcategory = nil,

	Subcategories = {
		[1] = {
			Name = "Hats",
			Title = "Feature.Avatar.Label.Heads", -- Hats are shown as "Heads" to the user.
			AssetTypeId = "8",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Head,
			CameraZoomRadius = 11,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Accessories,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Hats,
			},

			AssetTypes = { Constants.AssetTypes.Hat },
			SearchUuid = SearchUuid(),
			Category = 3,
			Subcategory = 1,
		},
		[2] = {
			Name = "Face",
			Title = "Feature.Avatar.Label.Face",
			AssetTypeId = "42",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Face,
			CameraZoomRadius = 7,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Accessories,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Face,
			},

			AssetTypes = { Constants.AssetTypes.FaceAccessory },
			SearchUuid = SearchUuid(),
			Category = 3,
			Subcategory = 2,
		},
		[3] = {
			Name = "Neck",
			Title = "Feature.Avatar.Label.Neck",
			AssetTypeId = "43",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Neck,
			CameraZoomRadius = 9,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Accessories,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Neck,
			},

			AssetTypes = { Constants.AssetTypes.Neck },
			SearchUuid = SearchUuid(),
			Category = 3,
			Subcategory = 3,
		},
		[4] = {
			Name = "Shoulder",
			Title = "Feature.Avatar.Label.Shoulder",
			AssetTypeId = "44",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Shoulders,
			CameraZoomRadius = 11,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Accessories,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Shoulder,
			},

			AssetTypes = { Constants.AssetTypes.Shoulder },
			SearchUuid = SearchUuid(),
			Category = 3,
			Subcategory = 4,
		},
		[5] = {
			Name = "Front",
			Title = "Feature.Avatar.Label.Front",
			AssetTypeId = "45",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 9.5,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Accessories,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Front,
			},

			AssetTypes = { Constants.AssetTypes.Front },
			SearchUuid = SearchUuid(),
			Category = 3,
			Subcategory = 5,
		},
		[6] = {
			Name = "Back",
			Title = "Feature.Avatar.Label.Back",
			AssetTypeId = "46",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 21,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Accessories,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Back,
			},

			AssetTypes = { Constants.AssetTypes.Back },
			SearchUuid = SearchUuid(),
			Category = 3,
			Subcategory = 6,
		},
		[7] = {
			Name = "Waist",
			Title = "Feature.Avatar.Label.Waist",
			AssetTypeId = "47",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Waist,
			CameraZoomRadius = 17,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Accessories,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Waist,
			},

			AssetTypes = { Constants.AssetTypes.Waist },
			SearchUuid = SearchUuid(),
			Category = 3,
			Subcategory = 7,
		},
		[8] = {
			Name = "Gear",
			Title = "Feature.Avatar.Label.Gear",
			AssetTypeId = "19",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Accessories,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Gear,
			},

			AssetTypes = { Constants.AssetTypes.Gear },
			SearchUuid = SearchUuid(),
			Category = 3,
			Subcategory = 8,
		},
	}
}

local Body = {
	Name = "Body",
	Title = "Feature.Avatar.Heading.Body",
	Category = 4,
	Subcategory = nil,

	Subcategories = {
		[1] = {
			Name = "Skin",
			Title = "Feature.Avatar.Label.Skin",
			RenderItemTiles = false,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.None,
			PageType = Constants.PageType.BodyColors,
			Category = 4,
			Subcategory = 1,
		},
		[2] = {
			Name = "Hair",
			Title = "Feature.Avatar.Label.Hair",
			AssetTypeId = "41",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Head,
			CameraZoomRadius = 8.5,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Body,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Hair,
			},

			AssetTypes = { Constants.AssetTypes.Hair },
			SearchUuid = SearchUuid(),
			Category = 4,
			Subcategory = 2,
		},
		[3] = {
			Name = "Heads",
			Title = "Feature.Avatar.Label.Heads",
			AssetTypeId = "17",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Face,
			CameraZoomRadius = 6.5,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Body,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Heads,
			},

			AssetTypes = { Constants.AssetTypes.Head },
			SearchUuid = SearchUuid(),
			Category = 4,
			Subcategory = 3,
		},
		[4] = {
			Name = "Faces",
			Title = "Feature.Avatar.Label.Faces",
			AssetTypeId = "18",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Face,
			CameraZoomRadius = 7,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Body,
				SubcategoryIndex = Constants.CatalogStructureLC.Subcategories.Faces,
			},

			AssetTypes = { Constants.AssetTypes.Face },
			SearchUuid = SearchUuid(),
			Category = 4,
			Subcategory = 4,
		},
		[5] = {
			Name = "Torsos",
			Title = "Feature.Avatar.Label.Torsos",
			AssetTypeId = "27",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 9,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Characters,
			},

			AssetTypes = { Constants.AssetTypes.Torso },
			SearchUuid = SearchUuid(),
			Category = 4,
			Subcategory = 5,
		},
		[6] = {
			Name = "Left Arms",
			Title = "Feature.Avatar.Label.LeftArms",
			AssetTypeId = "29",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 13,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Characters,
			},

			AssetTypes = { Constants.AssetTypes.LeftArm },
			SearchUuid = SearchUuid(),
			Category = 4,
			Subcategory = 6,
		},
		[7] = {
			Name = "Right Arms",
			Title = "Feature.Avatar.Label.RightArms",
			AssetTypeId = "28",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 13,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Characters,
			},

			AssetTypes = { Constants.AssetTypes.RightArm },
			SearchUuid = SearchUuid(),
			Category = 4,
			Subcategory = 7,
		},
		[8] = {
			Name = "Left Legs",
			Title = "Feature.Avatar.Label.LeftLegs",
			AssetTypeId = "30",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 13.5,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Characters,
			},

			AssetTypes = { Constants.AssetTypes.LeftLeg },
			SearchUuid = SearchUuid(),
			Category = 4,
			Subcategory = 8,
		},
		[9] = {
			Name = "Right Legs",
			Title = "Feature.Avatar.Label.RightLegs",
			AssetTypeId = "31",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 13.5,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Characters,
			},

			AssetTypes = { Constants.AssetTypes.RightLeg },
			SearchUuid = SearchUuid(),
			Category = 4,
			Subcategory = 9,
		},
		[10] = {
			Name = "Build",
			Title = "Feature.Avatar.Label.Build",
			RenderItemTiles = false,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.None,
			PageType = Constants.PageType.BodyStyle,
			Category = 4,
			Subcategory = 10,
		},
	}
}

local Animation = {
	Name = "Animation",
	Title = "Feature.Catalog.Label.Animation",

	CameraZoomRadius = Constants.AnimationCategoryCameraZoomRadius,

	PageType = Constants.PageType.Animation,
	Category = 5,
	Subcategory = nil,

	Subcategories = {
		[1] = {
			Name = "Idle Animations",
			Title = "Feature.Avatar.Label.Idle",
			EmptyString = "Feature.Avatar.Label.IdleAnimations",
			AssetTypeId = "51",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Animation,
			},

			AssetTypes = { Constants.AssetTypes.IdleAnim },
			SearchUuid = SearchUuid(),
			Category = 5,
			Subcategory = 1,
		},
		[2] = {
			Name = "Walk Animations",
			Title = "Feature.Avatar.Label.Walk",
			EmptyString = "Feature.Avatar.Label.WalkAnimations",
			AssetTypeId = "55",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Animation,
			},

			AssetTypes = { Constants.AssetTypes.WalkAnim },
			SearchUuid = SearchUuid(),
			Category = 5,
			Subcategory = 2,
		},
		[3] = {
			Name = "Run Animations",
			Title = "Feature.Avatar.Label.Run",
			EmptyString = "Feature.Avatar.Label.RunAnimations",
			AssetTypeId = "53",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Animation,
			},

			AssetTypes = { Constants.AssetTypes.RunAnim },
			SearchUuid = SearchUuid(),
			Category = 5,
			Subcategory = 3,
		},
		[4] = {
			Name = "Jump Animations",
			Title = "Feature.Avatar.Label.Jump",
			EmptyString = "Feature.Avatar.Label.JumpAnimations",
			AssetTypeId = "52",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Animation,
			},

			AssetTypes = { Constants.AssetTypes.JumpAnim },
			SearchUuid = SearchUuid(),
			Category = 5,
			Subcategory = 4,
		},
		[5] = {
			Name = "Fall Animations",
			Title = "Feature.Avatar.Label.Fall",
			EmptyString = "Feature.Avatar.Label.FallAnimations",
			AssetTypeId = "50",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Animation,
			},

			AssetTypes = { Constants.AssetTypes.FallAnim },
			SearchUuid = SearchUuid(),
			Category = 5,
			Subcategory = 5,
		},
		[6] = {
			Name = "Climb Animations",
			Title = "Feature.Avatar.Label.Climb",
			EmptyString = "Feature.Avatar.Label.ClimbAnimations",
			AssetTypeId = "48",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Animation,
			},

			AssetTypes = { Constants.AssetTypes.ClimbAnim },
			SearchUuid = SearchUuid(),
			Category = 5,
			Subcategory = 6,
		},
		[7] = {
			Name = "Swim Animations",
			Title = "Feature.Avatar.Label.Swim",
			EmptyString = "Feature.Avatar.Label.SwimAnimations",
			AssetTypeId = "54",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructureLC.Categories.Animation,
			},

			AssetTypes = { Constants.AssetTypes.SwimAnim },
			SearchUuid = SearchUuid(),
			Category = 5,
			Subcategory = 7,
		},
	},
}

local Emotes = {
	Name = AvatarExperienceConstants.AssetCategories.Emotes,
	Title = 'Feature.Avatar.Heading.Emotes',

	CameraZoomRadius = Constants.AnimationCategoryCameraZoomRadius,

	EquipSlotsCount = 8,
	AssetTypeId = "61",
	RenderItemTiles = true,
	PageType = Constants.PageType.Emotes,
	RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
	MatchingCatalogPage = {
		CategoryIndex = Constants.CatalogStructureLC.Categories.Emotes,
	},

	AssetTypes = { Constants.AssetTypes.Emote },
	SearchUuid = SearchUuid(),
	Category = 6,
	Subcategory = nil,
}

local defaultCategoryList = {
	Character,
	Clothing,
	Accessories,
	Body,
	Animation,
	Emotes,
}

return defaultCategoryList
