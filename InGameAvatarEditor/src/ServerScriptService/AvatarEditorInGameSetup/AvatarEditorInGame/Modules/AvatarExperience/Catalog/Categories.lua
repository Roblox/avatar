-- Tables describing each Category and Subcategory in the Catalog page

local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Constants = require(Modules.AvatarExperience.Common.Constants)

local Featured = {
	Name = "Featured",
	Title = "Feature.Catalog.Label.Featured",
	
	ExtraAssetTypes = {
		Enum.AvatarAssetType.Hat,
		Enum.AvatarAssetType.Face,
		Enum.AvatarAssetType.HairAccessory,
		Enum.AvatarAssetType.FaceAccessory,
		Enum.AvatarAssetType.NeckAccessory,
		Enum.AvatarAssetType.ShoulderAccessory,
		Enum.AvatarAssetType.FrontAccessory,
		Enum.AvatarAssetType.BackAccessory,
		Enum.AvatarAssetType.WaistAccessory,
	},
	ExtraBundleTypes = {
		Enum.BundleType.Animations,
		Enum.BundleType.BodyParts,
	},

	ApiCategory = Enum.CatalogCategoryFilter.Featured,
	Subcategories = {
		[1] = {
			Name = "Limited",
			Title = "Feature.Catalog.Label.Limited",
			
			ExtraAssetTypes = {
				Enum.AvatarAssetType.Hat,
				Enum.AvatarAssetType.Face,
				Enum.AvatarAssetType.HairAccessory,
				Enum.AvatarAssetType.FaceAccessory,
				Enum.AvatarAssetType.NeckAccessory,
				Enum.AvatarAssetType.ShoulderAccessory,
				Enum.AvatarAssetType.FrontAccessory,
				Enum.AvatarAssetType.BackAccessory,
				Enum.AvatarAssetType.WaistAccessory,
			},
			ApiCategory = Enum.CatalogCategoryFilter.Collectibles,
		},
		[2] = {
			Name = "Community",
			Title = "Feature.Catalog.Label.Community",
			
			ExtraAssetTypes = {
				Enum.AvatarAssetType.Hat,
				Enum.AvatarAssetType.Face,
				Enum.AvatarAssetType.HairAccessory,
				Enum.AvatarAssetType.FaceAccessory,
				Enum.AvatarAssetType.NeckAccessory,
				Enum.AvatarAssetType.ShoulderAccessory,
				Enum.AvatarAssetType.FrontAccessory,
				Enum.AvatarAssetType.BackAccessory,
				Enum.AvatarAssetType.WaistAccessory,
				Enum.AvatarAssetType.EmoteAnimation,
			},
			ApiCategory = Enum.CatalogCategoryFilter.CommunityCreations
		},
		[3] = {
			Name = "Premium",
			Title = "Feature.Catalog.Label.Premium",

			ExtraAssetTypes = {
				Enum.AvatarAssetType.Hat,
				Enum.AvatarAssetType.HairAccessory,
				Enum.AvatarAssetType.FaceAccessory,
				Enum.AvatarAssetType.NeckAccessory,
				Enum.AvatarAssetType.ShoulderAccessory,
				Enum.AvatarAssetType.FrontAccessory,
				Enum.AvatarAssetType.BackAccessory,
				Enum.AvatarAssetType.WaistAccessory,
			},
			ApiCategory = Enum.CatalogCategoryFilter.Premium,
		},
	},
}

local Characters = {
	Name = "Characters",
	Title = "Feature.Catalog.Label.Characters",

	ApiCategory = Enum.BundleType.BodyParts,
}

local Body = {
	Name = "Body",
	Title = "Feature.Catalog.Label.Body",

	ApiCategory = {Enum.AvatarAssetType.HairAccessory, Enum.AvatarAssetType.Head, Enum.AvatarAssetType.Face},
	Subcategories = {
		[1] = {
			Name = "Hair",
			Title = "Feature.Catalog.Label.Hair",

			CameraFocus = Constants.FocusType.Head,
			CameraZoomRadius = 8.5,

			ApiCategory = Enum.AvatarAssetType.HairAccessory,
		},
		[2] = {
			Name = "Head",
			Title = "Feature.Avatar.Label.Heads",

			CameraFocus = Constants.FocusType.Head,
			CameraZoomRadius = 6.5,

			ApiCategory = Enum.AvatarAssetType.Head,
		},
		[3] = {
			Name = "Faces",
			Title = "Feature.Avatar.Label.Faces",

			CameraFocus = Constants.FocusType.Face,
			CameraZoomRadius = 7,

			ApiCategory = Enum.AvatarAssetType.Face,
		},
	},
}


local Clothing = {
	Name = "Clothing",
	Title = "Feature.Catalog.Label.Clothing",

	ApiCategory = {Enum.AvatarAssetType.Hat, --[[Enum.AvatarAssetType.Shirt, Enum.AvatarAssetType.TShirt, Enum.AvatarAssetType.Pants, --]]
		Enum.AvatarAssetType.FaceAccessory, Enum.AvatarAssetType.NeckAccessory, Enum.AvatarAssetType.ShoulderAccessory, Enum.AvatarAssetType.FrontAccessory,
		Enum.AvatarAssetType.BackAccessory, Enum.AvatarAssetType.WaistAccessory},
	Subcategories = {
		[1] = {
			Name = "Hats",
			Title = "Feature.Catalog.LabelAccessoryHats",

			CameraFocus = Constants.FocusType.Head,
			CameraZoomRadius = 11,

			ApiCategory = Enum.AvatarAssetType.Hat,
		},
		[2] = {
			Name = "Shirts",
			Title = "Feature.Catalog.LabelShirts",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			ApiCategory = Enum.AvatarAssetType.Shirt,
		},
		[3] = {
			Name = "T-Shirts",
			Title = "Feature.Catalog.LabelTShirts",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 12,

			ApiCategory = Enum.AvatarAssetType.TShirt,
		},
		[4] = {
			Name = "Pants",
			Title = "Feature.Catalog.LabelPants",

			CameraFocus = Constants.FocusType.Legs,
			CameraZoomRadius = 12,

			ApiCategory = Enum.AvatarAssetType.Pants,
		},
		[5] = {
			Name = "Face Accessories",
			Title = "Feature.Catalog.Label.FaceAccessories",

			CameraFocus = Constants.FocusType.Face,
			CameraZoomRadius = 4.5,

			ApiCategory = Enum.AvatarAssetType.FaceAccessory,
		},
		[6] = {
			Name = "Neck Accessories",
			Title = "Feature.Catalog.Label.NeckAccessories",

			CameraFocus = Constants.FocusType.Neck,
			CameraZoomRadius = 9,

			ApiCategory = Enum.AvatarAssetType.NeckAccessory,
		},
		[7] = {
			Name = "Shoulder Accessories",
			Title = "Feature.Catalog.Label.ShoulderAccessories",

			CameraFocus = Constants.FocusType.Shoulders,
			CameraZoomRadius = 11,

			ApiCategory = Enum.AvatarAssetType.ShoulderAccessory,
		},
		[8] = {
			Name = "Front Accessories",
			Title = "Feature.Catalog.Label.FrontAccessories",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 9.5,

			ApiCategory = Enum.AvatarAssetType.FrontAccessory,
		},
		[9] = {
			Name = "Back Accessories",
			Title = "Feature.Catalog.Label.BackAccessories",

			CameraFocus = Constants.FocusType.Arms,
			CameraZoomRadius = 21,

			ApiCategory = Enum.AvatarAssetType.BackAccessory,
		},
		[10] = {
			Name = "Waist Accessories",
			Title = "Feature.Catalog.Label.WaistAccessories",

			CameraFocus = Constants.FocusType.Waist,
			CameraZoomRadius = 17,

			ApiCategory = Enum.AvatarAssetType.WaistAccessory,
		},
	}
}

local Animation = {
	Name = "Animation",
	Title = "Feature.Catalog.Label.Animation",

	ApiCategory = Enum.BundleType.Animations,
	PageType = Constants.PageType.Animation,
}

local Emotes = {
	Name = "Emotes",
	Title = "Feature.Catalog.Label.Emotes",
	ApiCategory = Enum.AvatarAssetType.EmoteAnimation,
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