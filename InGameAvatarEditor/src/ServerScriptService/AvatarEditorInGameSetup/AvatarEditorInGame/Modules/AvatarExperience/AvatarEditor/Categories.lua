--[[
	Tables describing each Category and Subcategory in the Avatar Editor page

	RenderItemTiles: Describes if this pages renders standard UIBlox item tiles.
	RecommendationsType: Describes if we show recommendations based on this page type and what kind.
]]
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Constants = require(Modules.AvatarExperience.Common.Constants)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)

local FFlagAvatarEditorEmotesSupport = true

local Character = {
	Name = AvatarEditorConstants.CharacterKey,
	Title = "Feature.Catalog.Label.Characters",

	RenderItemTiles = true,
	RenderCostumeItemTiles = true,
	RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
	MatchingCatalogPage = {
		CategoryIndex = Constants.CatalogStructure.Categories.Characters,
	}
}

local Body = {
	Name = "Body",
	Title = "Feature.Avatar.Heading.Body",

	Subcategories = {
		[1] = {
			Name = "Skin Tone",
			Title = "Feature.Avatar.Label.Skin",
			RenderItemTiles = false,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.None,
			PageType = Constants.PageType.BodyColors,
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
				CategoryIndex = Constants.CatalogStructure.Categories.Body,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.Hair,
			}
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
				CategoryIndex = Constants.CatalogStructure.Categories.Body,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.Heads,
			}
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
				CategoryIndex = Constants.CatalogStructure.Categories.Body,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.Faces,
			}
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
				CategoryIndex = Constants.CatalogStructure.Categories.Characters,
			}
		},
		[6] = {
			Name = "Right Arms",
			Title = "Feature.Avatar.Label.RightArms",
			AssetTypeId = "28",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 13,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Characters,
			}
		},
		[7] = {
			Name = "Left Arms",
			Title = "Feature.Avatar.Label.LeftArms",
			AssetTypeId = "29",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 13,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Characters,
			}
		},
		[8] = {
			Name = "Right Legs",
			Title = "Feature.Avatar.Label.RightLegs",
			AssetTypeId = "31",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 13.5,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Characters,
			}
		},
		[9] = {
			Name = "Left Legs",
			Title = "Feature.Avatar.Label.LeftLegs",
			AssetTypeId = "30",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 13.5,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.BodyParts,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Characters,
			}
		},
		[10] = {
			Name = "BodyStyle",
			Title = "Feature.Avatar.Label.BodyStyle",
			RenderItemTiles = false,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.None,
			PageType = Constants.PageType.BodyStyle,
		},
	}
}

local Clothing = {
	Name = "Clothing",
	Title = "Feature.Catalog.Label.Clothing",

	Subcategories = {
		[1] = {
			Name = "Hats",
			Title = "Feature.Avatar.Label.Hats",
			AssetTypeId = "8",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Head,
			CameraZoomRadius = 11,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.Hats,
			}
		},
		[2] = {
			Name = "Shirts",
			Title = "Feature.Avatar.Label.Shirts",
			AssetTypeId = "11",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.Shirts,
			}
		},
		[3] = {
			Name = "T-Shirts",
			Title = "Feature.Catalog.LabelTShirts",

			AssetTypeId = "2",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.TShirts,
			}
		},
		[4] = {
			Name = "Pants",
			Title = "Feature.Avatar.Label.Pants",
			AssetTypeId = "12",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 12,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.Pants,
			}
		},
		[5] = {
			Name = "Face Accessories",
			Title = "Feature.Avatar.Label.FaceAccessories",
			AssetTypeId = "42",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Face,
			CameraZoomRadius = 7,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.FaceAccessories,
			}
		},
		[6] = {
			Name = "Neck Accessories",
			Title = "Feature.Avatar.Label.NeckAccessories",
			AssetTypeId = "43",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Neck,
			CameraZoomRadius = 9,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.NeckAccessories,
			}
		},
		[7] = {
			Name = "Shoulder Accessories",
			Title = "Feature.Avatar.Label.ShoulderAccessories",
			AssetTypeId = "44",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Shoulders,
			CameraZoomRadius = 11,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.ShoulderAccessories,
			}
		},
		[8] = {
			Name = "Front Accessories",
			Title = "Feature.Avatar.Label.FrontAccessories",
			AssetTypeId = "45",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 9.5,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.FrontAccessories,
			}
		},
		[9] = {
			Name = "Back Accessories",
			Title = "Feature.Avatar.Label.BackAccessories",
			AssetTypeId = "46",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 21,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.BackAccessories,
			}
		},
		[10] = {
			Name = "Waist Accessories",
			Title = "Feature.Avatar.Label.WaistAccessories",
			AssetTypeId = "47",
			RenderItemTiles = true,

			CameraFocus = Constants.FocusType.Waist,
			CameraZoomRadius = 17,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.WaistAccessories,
			}
		},
		--[[
		[11] = {
			Name = "Gear",
			Title = "Feature.Avatar.Label.Gear",
			AssetTypeId = "19",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Clothing,
				SubcategoryIndex = Constants.CatalogStructure.Subcategories.Gear,
			}
		},
		--]]
	}
}

local Animation = {
	Name = "Animation",
	Title = "Feature.Catalog.Label.Animation",

	PageType = Constants.PageType.Animation,

	Subcategories = {
		[1] = {
			Name = "Idle Animations",
			Title = "Feature.Avatar.Label.Idle",
			EmptyString = "Feature.Avatar.Label.IdleAnimations",
			AssetTypeId = "51",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Animation,
			}
		},
		[2] = {
			Name = "Walk Animations",
			Title = "Feature.Avatar.Label.Walk",
			EmptyString = "Feature.Avatar.Label.WalkAnimations",
			AssetTypeId = "55",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Animation,
			}
		},
		[3] = {
			Name = "Run Animations",
			Title = "Feature.Avatar.Label.Run",
			EmptyString = "Feature.Avatar.Label.RunAnimations",
			AssetTypeId = "53",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Animation,
			}
		},
		[4] = {
			Name = "Jump Animations",
			Title = "Feature.Avatar.Label.Jump",
			EmptyString = "Feature.Avatar.Label.JumpAnimations",
			AssetTypeId = "52",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Animation,
			}
		},
		[5] = {
			Name = "Fall Animations",
			Title = "Feature.Avatar.Label.Fall",
			EmptyString = "Feature.Avatar.Label.FallAnimations",
			AssetTypeId = "50",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Animation,
			}
		},
		[6] = {
			Name = "Climb Animations",
			Title = "Feature.Avatar.Label.Climb",
			EmptyString = "Feature.Avatar.Label.ClimbAnimations",
			AssetTypeId = "48",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Animation,
			}
		},
		[7] = {
			Name = "Swim Animations",
			Title = "Feature.Avatar.Label.Swim",
			EmptyString = "Feature.Avatar.Label.SwimAnimations",
			AssetTypeId = "54",
			RenderItemTiles = true,

			RecommendationsType = AvatarEditorConstants.RecommendationsType.AvatarAnimations,
			MatchingCatalogPage = {
				CategoryIndex = Constants.CatalogStructure.Categories.Animation,
			}
		},
	},
}


local Emotes = {
	Name = AvatarExperienceConstants.AssetCategories.Emotes,
	Title = 'Feature.Avatar.Heading.Emotes',

	EquipSlotsCount = 8,
	AssetTypeId = "61",
	RenderItemTiles = true,
	PageType = Constants.PageType.Emotes,
	RecommendationsType = AvatarEditorConstants.RecommendationsType.Asset,
	MatchingCatalogPage = {
		CategoryIndex = Constants.CatalogStructure.Categories.Emotes,
	}
}

local Categories = FFlagAvatarEditorEmotesSupport and {
	Character,
	Body,
	Clothing,
	Animation,
	Emotes,
} or {
	Character,
	Body,
	Clothing,
	Animation,
}

return Categories