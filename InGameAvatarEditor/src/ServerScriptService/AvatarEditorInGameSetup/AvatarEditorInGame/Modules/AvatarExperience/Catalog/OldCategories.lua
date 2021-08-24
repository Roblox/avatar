-- Tables describing each Category and Subcategory in the Catalog page

local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Constants = require(Modules.AvatarExperience.Common.Constants)

local Featured = {
	Name = "Featured",
	Title = "Feature.Catalog.Label.Featured",

	ApiCategory = "Featured", Enum.CatalogCategoryFilter.Collectibles
	Subcategories = {
		[1] = {
			Name = "Limited",
			Title = "Feature.Catalog.Label.Limited",

			ApiCategory = "Collectibles",
		},
		[2] = {
			Name = "Community",
			Title = "Feature.Catalog.Label.Community",
			ApiCategory = "CommunityCreations"
		},
	},
}

local Characters = {
	Name = "Characters",
	Title = "Feature.Catalog.Label.Characters",

	ApiCategory = "BodyParts",
	ApiSubcategory = "Bundles",
}

local Body = {
	Name = "Body",
	Title = "Feature.Catalog.Label.Body",

	ApiCategory = "BodyParts",
	Subcategories = {
		[1] = {
			Name = "Hair",
			Title = "Feature.Catalog.Label.Hair",

			CameraFocus = Constants.FocusType.Head,
			CameraZoomRadius = 8.5,

			ApiCategory = "Accessories",
			ApiSubcategory = "HairAccessories",
		},
		[2] = {
			Name = "Head",
			Title = "Feature.Avatar.Label.Heads",

			CameraFocus = Constants.FocusType.Head,
			CameraZoomRadius = 6.5,

			ApiSubcategory = "Heads",
		},
		[3] = {
			Name = "Faces",
			Title = "Feature.Avatar.Label.Faces",

			CameraFocus = Constants.FocusType.Face,
			CameraZoomRadius = 7,

			ApiSubcategory = "Faces",
		},
	},
}


local Clothing = {
	Name = "Clothing",
	Title = "Feature.Catalog.Label.Clothing",

	ApiCategory = "Accessories",
	Subcategories = {
		[1] = {
			Name = "Hats",
			Title = "Feature.Catalog.LabelAccessoryHats",

			CameraFocus = Constants.FocusType.Head,
			CameraZoomRadius = 11,

			ApiCategory = "Accessories",
			ApiSubcategory = "Hats",
		},
		[2] = {
			Name = "Shirts",
			Title = "Feature.Catalog.LabelShirts",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			ApiCategory = "Clothing",
			ApiSubcategory = "Shirts",
		},
		[3] = {
			Name = "T-Shirts",
			Title = "Feature.Catalog.LabelTShirts",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			ApiCategory = "Clothing",
			ApiSubcategory = "Tshirts",
		},
		[4] = {
			Name = "Pants",
			Title = "Feature.Catalog.LabelPants",

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 12,

			ApiCategory = "Clothing",
			ApiSubcategory = "Pants",
		},
		[5] = {
			Name = "Face Accessories",
			Title = "Feature.Catalog.Label.FaceAccessories",

			CameraFocus = Constants.FocusType.Face,
			CameraZoomRadius = 4.5,

			ApiCategory = "Accessories",
			ApiSubcategory = "FaceAccessories",
		},
		[6] = {
			Name = "Neck Accessories",
			Title = "Feature.Catalog.Label.NeckAccessories",

			CameraFocus = Constants.FocusType.Neck,
			CameraZoomRadius = 9,

			ApiCategory = "Accessories",
			ApiSubcategory = "NeckAccessories",
		},
		[7] = {
			Name = "Shoulder Accessories",
			Title = "Feature.Catalog.Label.ShoulderAccessories",

			CameraFocus = Constants.FocusType.Shoulders,
			CameraZoomRadius = 11,

			ApiCategory = "Accessories",
			ApiSubcategory = "ShoulderAccessories",
		},
		[8] = {
			Name = "Front Accessories",
			Title = "Feature.Catalog.Label.FrontAccessories",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 9.5,

			ApiCategory = "Accessories",
			ApiSubcategory = "FrontAccessories",
		},
		[9] = {
			Name = "Back Accessories",
			Title = "Feature.Catalog.Label.BackAccessories",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 21,

			ApiCategory = "Accessories",
			ApiSubcategory = "BackAccessories",
		},
		[10] = {
			Name = "Waist Accessories",
			Title = "Feature.Catalog.Label.WaistAccessories",

			CameraFocus = Constants.FocusType.Waist,
			CameraZoomRadius = 17,

			ApiCategory = "Accessories",
			ApiSubcategory = "WaistAccessories",
		},
		[11] = {
			Name = "Gear",
			Title = "Feature.Catalog.Label.Gear",

			ApiCategory = "Gear",
		},
	}
}

local Animation = {
	Name = "Animation",
	Title = "Feature.Catalog.Label.Animation",

	ApiCategory = "AvatarAnimations",
	ApiSubcategory = "AnimationBundles",
	PageType = Constants.PageType.Animation,
}

local Emotes = {
	Name = "Emotes",
	Title = "Feature.Catalog.Label.Emotes",
	ApiCategory = "AvatarAnimations",
	ApiSubcategory = "EmoteAnimations",
	PageType = Constants.PageType.Emotes,
}

-- Main Categories list
local Categories = {
	Featured,
	Characters,
	Body,
	Clothing,
	Animation,
	Emotes,
}

return Categories