
local Constants = {
	DeviceType = {
		Android = "Android",
		IOS = "iOS",
		Other = "Other"
	},

	NavigationDirection = {
		IS_LEFT = "IS_LEFT",
		IS_RIGHT = "IS_RIGHT",
		Left = "Left",
		Right = "Right",
	},

	-- Location of the HumanoidRootPart of the default rig in Mobile.rbxl
	DefaultRigPosition = Vector3.new(11.7777386, 6.76653099, 0.274315476),

	AvatarType = {
		R6 = "R6",
		R15 = "R15",
	},

	ItemType = {
		AvatarEditorTile = "AvatarEditorTile",
		BodyColorButton = "BodyColorButton",
		BundleItemTile = "BundleItemTile",
		CatalogItemTile = "CatalogItemTile",
	},

	BundleType = {
		BodyParts = "1",
		AvatarAnimations = "2",
	},

	BundleTypeAsString = {
		AvatarAnimations = "AvatarAnimations",
		BodyParts = "BodyParts",
	},

	ItemTilePadding = 10,
	ItemTileTitleMaxLines = 2,

	FocusType = {
		Legs = "Legs",
		Face = "Face",
		Arms = "Arms",
		Head = "Head",
		Neck = "Neck",
		Waist = "Waist",
		Shoulders = "Shoulders",
	},

	AssetCategories = {
		Animation = "Animation",
		Body = "Body",
		Clothing = "Clothing",
		Emotes = "Emotes",
	},

	PageType = {
		Normal = "Normal",
		Animation = "Animation",
		BodyColors = "BodyColors",
		BodyStyle = "BodyStyle",
		Emotes = "Emotes",
		Other = "Other",
	},

	ShimmerCardsToDisplay = 30,

	UserInventoryKey = "avatar.inventory.",
	UserOutfitsKey = "avatar.outfits.",
	OutfitInfoKey = "avatar.outfit.info.",
	RecommendedItemsKey = "avatar.recommendedItems.",

	CommunityCreationsCategoryFilter = "CommunityCreations",
	PremiumCategoryFilter = "Premium",

	LandscapeNavWidth = 0.6,
	LandscapeSceneWidth = 0.4,

	PortraitSceneHeight = 0.4,
	LandingPagePortraitSceneHeight = 0.5,

	CatalogStructure = {
		Categories = {
			Featured = 1,
			Characters = 2,
			Body = 3,
			Clothing = 4,
			Animation = 5,
			Emotes = 6,
		},
		Subcategories = {
			Limited = 1,
			Community = 2,
			Hair = 1,
			Heads = 2,
			Faces = 3,
			Hats = 1,
			Shirts = 2,
			TShirts = 3,
			Pants = 4,
			FaceAccessories = 5,
			NeckAccessories = 6,
			ShoulderAccessories = 7,
			FrontAccessories = 8,
			BackAccessories = 9,
			WaistAccessories = 10,
			Gear = 11,
		},
	},

	AssetTypes = {
		TShirt = "2",
		Hat = "8",
		Hair = "41",
		FaceAccessory = "42",
		Neck = "43",
		Shoulder = "44",
		Front = "45",
		Back = "46",
		Waist = "47",
		Shirt = "11",
		Pants = "12",
		Gear = "19",
		Head = "17",
		Face = "18",
		Torso = "27",
		RightArm = "28",
		LeftArm = "29",
		LeftLeg = "30",
		RightLeg = "31",
		ClimbAnim = "48",
		FallAnim = "50",
		IdleAnim = "51",
		JumpAnim = "52",
		RunAnim = "53",
		SwimAnim = "54",
		WalkAnim = "55",
		Emote = "61",
		TShirtAccessory = "64",
		ShirtAccessory = "65",
		PantsAccessory = "66",
		JacketAccessory = "67",
		SweaterAccessory = "68",
		ShortsAccessory = "69",
		LeftShoeAccessory = "70",
		RightShoeAccessory = "71",
		DressSkirtAccessory = "72",
	},

	AssetTypeIds = {
		TShirt = "2",
		Hat = "8",
		HairAccessory = "41",
		FaceAccessory = "42",
		NeckAccessory = "43",
		ShoulderAccessory = "44",
		FrontAccessory = "45",
		BackAccessory = "46",
		WaistAccessory = "47",
		Shirt = "11",
		Pants = "12",
		Gear = "19",
		Head = "17",
		Face = "18",
		Torso = "27",
		RightArm = "28",
		LeftArm = "29",
		LeftLeg = "30",
		RightLeg = "31",
		ClimbAnimation = "48",
		FallAnimation = "50",
		IdleAnimation = "51",
		JumpAnimation = "52",
		RunAnimation = "53",
		SwimAnimation = "54",
		WalkAnimation = "55",
		EmoteAnimation = "61",
		TShirtAccessory = "64",
		ShirtAccessory = "65",
		PantsAccessory = "66",
		JacketAccessory = "67",
		SweaterAccessory = "68",
		ShortsAccessory = "69",
		LeftShoeAccessory = "70",
		RightShoeAccessory = "71",
		DressSkirtAccessory = "72",
	},

	AssetTypeNames = {
		["2"]  = "TShirt",
		["8"]  = "Hat",
		["41"] = "Hair",
		["42"] = "FaceAccessory",
		["43"] = "Neck",
		["44"] = "Shoulder",
		["45"] = "Front",
		["46"] = "Back",
		["47"] = "Waist",
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
		["48"] = "ClimbAnim",
		["50"] = "FallAnim",
		["51"] = "IdleAnim",
		["52"] = "JumpAnim",
		["53"] = "RunAnim",
		["54"] = "SwimAnim",
		["55"] = "WalkAnim",
		["61"] = "Emote",
	},
}

Constants.AssetTypeIdToAccessoryTypeEnum = {
	["8"] = Enum.AccessoryType.Hat,
	["41"] = Enum.AccessoryType.Hair,
	["42"] = Enum.AccessoryType.Face,
	["43"] = Enum.AccessoryType.Neck,
	["44"] = Enum.AccessoryType.Shoulder,
	["45"] = Enum.AccessoryType.Front,
	["46"] = Enum.AccessoryType.Back,
	["47"] = Enum.AccessoryType.Waist,
	["64"] = Enum.AccessoryType.TShirt,
	["65"] = Enum.AccessoryType.Shirt,
	["66"] = Enum.AccessoryType.Pants,
	["67"] = Enum.AccessoryType.Jacket,
	["68"] = Enum.AccessoryType.Sweater,
	["69"] = Enum.AccessoryType.Shorts,
	["70"] = Enum.AccessoryType.LeftShoe,
	["71"] = Enum.AccessoryType.RightShoe,
	["72"] = Enum.AccessoryType.DressSkirt,
}

Constants.LayeredClothingOrder = {
	[Constants.AssetTypes.LeftShoeAccessory] = 3,
	[Constants.AssetTypes.RightShoeAccessory] = 3,
	[Constants.AssetTypes.PantsAccessory] = 4, -- Layered Pants
	[Constants.AssetTypes.ShortsAccessory] = 5,
	[Constants.AssetTypes.DressSkirtAccessory] = 6,
	[Constants.AssetTypes.TShirtAccessory] = 7, -- Layered TShirt
	[Constants.AssetTypes.ShirtAccessory] = 8, -- Layered Shirt
	[Constants.AssetTypes.SweaterAccessory] = 9,
	[Constants.AssetTypes.JacketAccessory] = 10,
	[Constants.AssetTypes.Hair] = 11,
}

-- Body parts the camera can focus on
-- TODO: Remove with FFlagAvatarEditorAttachmentCameraFocus
Constants.AvatarTypeFocusGroupsOld = {
	[Constants.AvatarType.R15] = {
		[Constants.FocusType.Legs] = { "RightUpperLeg", "LeftUpperLeg", "RightLowerLeg", "LeftLowerLeg" },
		[Constants.FocusType.Face] = { "Head" },
		[Constants.FocusType.Arms] = { "UpperTorso" },
		[Constants.FocusType.Head] = { "Head" },
		[Constants.FocusType.Neck] = { "Head", "UpperTorso" },
		[Constants.FocusType.Waist] = { "LowerTorso", "RightUpperLeg", "LeftUpperLeg" },
		[Constants.FocusType.Shoulders] = { "Head", "RightUpperArm", "LeftUpperArm" },
	},

	[Constants.AvatarType.R6] = {
		[Constants.FocusType.Legs] = { "Right Leg", "Left Leg"},
		[Constants.FocusType.Face] = { "Head" },
		[Constants.FocusType.Arms] = { "Torso" },
		[Constants.FocusType.Head] = { "Head" },
		[Constants.FocusType.Neck] = { "Head", "Torso" },
		[Constants.FocusType.Waist] = { "Torso", "Right Leg", "Left Leg" },
		[Constants.FocusType.Shoulders] = { "Head", "Right Arm", "Left Arm" },
	}
}

-- Parts and attachments the camera can focus on
Constants.AvatarTypeFocusGroups = {
	[Constants.AvatarType.R15] = {
		[Constants.FocusType.Legs] = {
			{Part = "RightUpperLeg"},
			{Part = "LeftUpperLeg"},
			{Part = "RightLowerLeg"},
			{Part = "LeftLowerLeg"},
		},
		[Constants.FocusType.Face] = { {Part = "Head", Attachment = "FaceFrontAttachment"} },
		[Constants.FocusType.Arms] = { {Part = "UpperTorso"} },
		[Constants.FocusType.Head] = {
			{Part = "Head", Attachment = "HatAttachment"},
			{Part = "Head", Attachment = "NeckRigAttachment"},
		},
		[Constants.FocusType.Neck] = {
			{Part = "Head"},
			{Part = "UpperTorso"},
		},
		[Constants.FocusType.Waist] = {
			{Part = "LowerTorso"},
			{Part = "RightUpperLeg"},
			{Part = "LeftUpperLeg"},
		},
		[Constants.FocusType.Shoulders] = {
			{Part = "Head"},
			{Part = "RightUpperArm"},
			{Part = "LeftUpperArm"},
		},
	},

	[Constants.AvatarType.R6] = {
		[Constants.FocusType.Legs] = {
			{Part = "Right Leg"},
			{Part = "Left Leg"},
		},
		[Constants.FocusType.Face] = { {Part = "Head", Attachment = "FaceFrontAttachment"} },
		[Constants.FocusType.Arms] = { {Part = "Torso"} },
		[Constants.FocusType.Head] = {
			{Part = "Head", Attachment = "HatAttachment"},
			{Part = "Head", Attachment = "NeckRigAttachment"}
		},
		[Constants.FocusType.Neck] = {
			{Part = "Head"},
			{Part = "Torso"},
		},
		[Constants.FocusType.Waist] = {
			{Part = "Torso"},
			{Part = "Right Leg"},
			{Part = "Left Leg"},
		},
		[Constants.FocusType.Shoulders] = {
			{Part = "Head"},
			{Part = "Right Arm"},
			{Part = "Left Arm"},
		},
	}
}

Constants.AssetTypeIdToCategory = {
	[Constants.AssetTypes.TShirt] = Constants.AssetCategories.Clothing,
	[Constants.AssetTypes.Hat] = Constants.AssetCategories.Clothing,
	[Constants.AssetTypes.Hair] = Constants.AssetCategories.Clothing,
	[Constants.AssetTypes.FaceAccessory] = Constants.AssetCategories.Clothing,
	[Constants.AssetTypes.Neck] = Constants.AssetCategories.Clothing,
	[Constants.AssetTypes.Shoulder] = Constants.AssetCategories.Clothing,
	[Constants.AssetTypes.Front] = Constants.AssetCategories.Clothing,
	[Constants.AssetTypes.Back] = Constants.AssetCategories.Clothing,
	[Constants.AssetTypes.Waist] = Constants.AssetCategories.Clothing,
	[Constants.AssetTypes.Shirt] = Constants.AssetCategories.Clothing,
	[Constants.AssetTypes.Pants] = Constants.AssetCategories.Clothing,
	[Constants.AssetTypes.Gear] = Constants.AssetCategories.Clothing,
	[Constants.AssetTypes.Head] = Constants.AssetCategories.Body,
	[Constants.AssetTypes.Face] = Constants.AssetCategories.Body,
	[Constants.AssetTypes.Torso] = Constants.AssetCategories.Body,
	[Constants.AssetTypes.RightArm] = Constants.AssetCategories.Body,
	[Constants.AssetTypes.LeftArm] = Constants.AssetCategories.Body,
	[Constants.AssetTypes.RightLeg] = Constants.AssetCategories.Body,
	[Constants.AssetTypes.LeftLeg] = Constants.AssetCategories.Body,
	[Constants.AssetTypes.ClimbAnim] = Constants.AssetCategories.Animation,
	[Constants.AssetTypes.FallAnim] = Constants.AssetCategories.Animation,
	[Constants.AssetTypes.IdleAnim] = Constants.AssetCategories.Animation,
	[Constants.AssetTypes.JumpAnim] = Constants.AssetCategories.Animation,
	[Constants.AssetTypes.RunAnim] = Constants.AssetCategories.Animation,
	[Constants.AssetTypes.SwimAnim] = Constants.AssetCategories.Animation,
	[Constants.AssetTypes.WalkAnim] = Constants.AssetCategories.Animation,
	[Constants.AssetTypes.Emote] = Constants.AssetCategories.Animation,
}

Constants.AssetCategoriesLocalized = {
	[Constants.AssetCategories.Animation] = "Feature.Catalog.Label.Animation",
	[Constants.AssetCategories.Body] = "Feature.Catalog.Label.Body",
	[Constants.AssetCategories.Clothing] = "Feature.Avatar.Heading.Clothing",
	[Constants.AssetCategories.Emotes] = "Feature.Catalog.Label.Emotes",
}

Constants.AssetTypeLocalized = {
	[Constants.AssetTypes.TShirt] = "Feature.Avatar.Label.TShirt",
	[Constants.AssetTypes.Hat] = "Feature.Avatar.Label.Hat",
	[Constants.AssetTypes.Hair] = "Feature.Avatar.Label.Hair",
	[Constants.AssetTypes.FaceAccessory] = "Feature.Avatar.Label.Face",
	[Constants.AssetTypes.Neck] = "Feature.Avatar.Label.Neck",
	[Constants.AssetTypes.Shoulder] = "Feature.Avatar.Label.Shoulder",
	[Constants.AssetTypes.Front] = "Feature.Avatar.Label.Front",
	[Constants.AssetTypes.Back] = "Feature.Avatar.Label.Back",
	[Constants.AssetTypes.Waist] = "Feature.Avatar.Label.Waist",
	[Constants.AssetTypes.Shirt] = "Feature.Avatar.Label.Shirt",
	[Constants.AssetTypes.Pants] = "Feature.Avatar.Label.Pants",
	[Constants.AssetTypes.Gear] = "Feature.Avatar.Label.Gear",
	[Constants.AssetTypes.Head] = "Feature.Avatar.Label.Head",
	[Constants.AssetTypes.Face] = "Feature.Avatar.Label.Face",
	[Constants.AssetTypes.Torso] = "Feature.Avatar.Label.Torso",
	[Constants.AssetTypes.RightArm] = "Feature.Avatar.Label.RightArm",
	[Constants.AssetTypes.LeftArm] = "Feature.Avatar.Label.LeftArm",
	[Constants.AssetTypes.LeftLeg] = "Feature.Avatar.Label.LeftLeg",
	[Constants.AssetTypes.RightLeg] = "Feature.Avatar.Label.RightLeg",
	[Constants.AssetTypes.ClimbAnim] = "Feature.Avatar.Label.Climb",
	[Constants.AssetTypes.FallAnim] = "Feature.Avatar.Label.Fall",
	[Constants.AssetTypes.IdleAnim] = "Feature.Avatar.Label.Idle",
	[Constants.AssetTypes.JumpAnim] = "Feature.Avatar.Label.Jump",
	[Constants.AssetTypes.RunAnim] = "Feature.Avatar.Label.Run",
	[Constants.AssetTypes.SwimAnim] = "Feature.Avatar.Label.Swim",
	[Constants.AssetTypes.WalkAnim] = "Feature.Avatar.Label.Walk",
	[Constants.AssetTypes.Emote] = "Feature.Avatar.Label.Emote",
}

Constants.HumanoidDescriptionIdToName = {
	["2"]  = "GraphicTShirt",
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
}

Constants.HumanoidDescriptionScaleToName = {
	bodyType = "BodyTypeScale",
	head = "HeadScale",
	height = "HeightScale",
	proportion = "ProportionScale",
	depth = "DepthScale",
	width = "WidthScale",
}

Constants.HumanoidDescriptionBodyColorIdToName = {
	headColorId = "HeadColor",
	leftArmColorId = "LeftArmColor",
	leftLegColorId = "LeftLegColor",
	rightArmColorId = "RightArmColor",
	rightLegColorId = "RightLegColor",
	torsoColorId = "TorsoColor",
}

Constants.CatalogStructureLC = {
	Categories = {
		Featured = 1,
		Recommended = 1,
		Characters = 2,
		Clothing = 3,
		Accessories = 4,
		Body = 5,
		Animation = 6,
		Emotes = 7,
	},
	Subcategories = {
		-- Recommended
		Featured = 1,
		Limited = 2,
		Community = 3,
		Premium = 4,
		-- Clothing
		Shirts = 1,
		TShirts = 2,
		Sweaters = 3,
		Jackets = 4,
		Pants = 5,
		DressesAndSkirts = 6,
		Shorts = 7,
		Shoes = 8,
		ClassicShirts = 9,
		ClassicTShirts = 10,
		ClassicPants = 11,
		-- Accessories
		Hats = 1,
		Face = 2,
		Neck = 3,
		Shoulder = 4,
		Front = 5,
		Back = 6,
		Waist = 7,
		Gear = 8,
		-- Body
		Hair = 1,
		Heads = 2,
		Faces = 3,
	},
}

return Constants
