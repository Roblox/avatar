local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local CommonConstants = require(Modules.AvatarExperience.Common.Constants)

local Constants = {
	AvatarType = {
		R6 = "R6",
		R15 = "R15",
	},
	AvatarSettings = {
		minDeltaBodyColorDifference = "minDeltaBodyColorDifference",
		scalesRules = "scalesRules",
	},
	RecommendationsType = {
		Asset = "Asset",
		BodyParts = "BodyParts",
		AvatarAnimations = "AvatarAnimations",
		None = "None",
	},
	NumRecommendedItems = 6,
	ShimmerColorCardsToDisplay = 30,

	CreateOutfitKey = "avatar.createOutfit",
	AddCostumeButton = "ADD_COSTUME_BUTTON",

	CharacterKey = "Character",
	EditableCharacterKey = "EditableCharacter",
	PurchasedCharacterKey = "PurchasedCharacter",
	ReachedLastPage = "LastPage",
	Outfits = "Outfits",

	AvatarEditorStructure = {
		Categories = {
			Characters = 1,
			Body = 2,
			Clothing = 3,
			Animation = 4,
			Emotes = 5,
		},
		Subcategories = {
			SkinTone = 1,
			Hair = 2,
			Heads = 3,
			Faces = 4,
			Torso = 5,
			RightArms = 6,
			LeftArms = 7,
			RightLegs = 8,
			LeftLegs = 9,
			BodyStyle = 10,
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
			Idle = 1,
			Walk = 2,
			Run = 3,
			Jump = 4,
			Fall = 5,
			Climb = 6,
			Swim = 7,
		},
	},
}

Constants.AssetTypeToCategory = {
	[CommonConstants.AssetTypes.Hat] = Constants.AvatarEditorStructure.Categories.Clothing,
	[CommonConstants.AssetTypes.Hair] = Constants.AvatarEditorStructure.Categories.Body,
	[CommonConstants.AssetTypes.FaceAccessory] = Constants.AvatarEditorStructure.Categories.Clothing,
	[CommonConstants.AssetTypes.Neck] = Constants.AvatarEditorStructure.Categories.Clothing,
	[CommonConstants.AssetTypes.Shoulder] = Constants.AvatarEditorStructure.Categories.Clothing,
	[CommonConstants.AssetTypes.Front] = Constants.AvatarEditorStructure.Categories.Clothing,
	[CommonConstants.AssetTypes.Back] = Constants.AvatarEditorStructure.Categories.Clothing,
	[CommonConstants.AssetTypes.Waist] = Constants.AvatarEditorStructure.Categories.Clothing,
	[CommonConstants.AssetTypes.Shirt] = Constants.AvatarEditorStructure.Categories.Clothing,
	[CommonConstants.AssetTypes.TShirt] = Constants.AvatarEditorStructure.Categories.Clothing,
	[CommonConstants.AssetTypes.Pants] = Constants.AvatarEditorStructure.Categories.Clothing,
	[CommonConstants.AssetTypes.Gear] = Constants.AvatarEditorStructure.Categories.Clothing,
	[CommonConstants.AssetTypes.Head] = Constants.AvatarEditorStructure.Categories.Body,
	[CommonConstants.AssetTypes.Face] = Constants.AvatarEditorStructure.Categories.Body,
	[CommonConstants.AssetTypes.Torso] = Constants.AvatarEditorStructure.Categories.Body,
	[CommonConstants.AssetTypes.RightArm] = Constants.AvatarEditorStructure.Categories.Body,
	[CommonConstants.AssetTypes.LeftArm] = Constants.AvatarEditorStructure.Categories.Body,
	[CommonConstants.AssetTypes.RightLeg] = Constants.AvatarEditorStructure.Categories.Body,
	[CommonConstants.AssetTypes.LeftLeg] = Constants.AvatarEditorStructure.Categories.Body,
	[CommonConstants.AssetTypes.ClimbAnim] = Constants.AvatarEditorStructure.Categories.Animation,
	[CommonConstants.AssetTypes.FallAnim] = Constants.AvatarEditorStructure.Categories.Animation,
	[CommonConstants.AssetTypes.IdleAnim] = Constants.AvatarEditorStructure.Categories.Animation,
	[CommonConstants.AssetTypes.JumpAnim] = Constants.AvatarEditorStructure.Categories.Animation,
	[CommonConstants.AssetTypes.RunAnim] = Constants.AvatarEditorStructure.Categories.Animation,
	[CommonConstants.AssetTypes.SwimAnim] = Constants.AvatarEditorStructure.Categories.Animation,
	[CommonConstants.AssetTypes.WalkAnim] = Constants.AvatarEditorStructure.Categories.Animation,
	[CommonConstants.AssetTypes.Emote] = Constants.AvatarEditorStructure.Categories.Emotes,
}

Constants.AssetTypeToSubcategory = {
	[CommonConstants.AssetTypes.Hat] = Constants.AvatarEditorStructure.Subcategories.Hats,
	[CommonConstants.AssetTypes.Hair] = Constants.AvatarEditorStructure.Subcategories.Hair,
	[CommonConstants.AssetTypes.FaceAccessory] = Constants.AvatarEditorStructure.Subcategories.FaceAccessories,
	[CommonConstants.AssetTypes.Neck] = Constants.AvatarEditorStructure.Subcategories.NeckAccessories,
	[CommonConstants.AssetTypes.Shoulder] = Constants.AvatarEditorStructure.Subcategories.ShoulderAccessories,
	[CommonConstants.AssetTypes.Front] = Constants.AvatarEditorStructure.Subcategories.FrontAccessories,
	[CommonConstants.AssetTypes.Back] = Constants.AvatarEditorStructure.Subcategories.BackAccessories,
	[CommonConstants.AssetTypes.Waist] = Constants.AvatarEditorStructure.Subcategories.WaistAccessories,
	[CommonConstants.AssetTypes.Shirt] = Constants.AvatarEditorStructure.Subcategories.Shirts,
	[CommonConstants.AssetTypes.TShirt] = Constants.AvatarEditorStructure.Subcategories.TShirts,
	[CommonConstants.AssetTypes.Pants] = Constants.AvatarEditorStructure.Subcategories.Pants,
	[CommonConstants.AssetTypes.Gear] = Constants.AvatarEditorStructure.Subcategories.Gear,
	[CommonConstants.AssetTypes.Head] = Constants.AvatarEditorStructure.Subcategories.Heads,
	[CommonConstants.AssetTypes.Face] = Constants.AvatarEditorStructure.Subcategories.Faces,
	[CommonConstants.AssetTypes.Torso] = Constants.AvatarEditorStructure.Subcategories.Torso,
	[CommonConstants.AssetTypes.RightArm] = Constants.AvatarEditorStructure.Subcategories.RightArms,
	[CommonConstants.AssetTypes.LeftArm] = Constants.AvatarEditorStructure.Subcategories.LeftArms,
	[CommonConstants.AssetTypes.RightLeg] = Constants.AvatarEditorStructure.Subcategories.RightLegs,
	[CommonConstants.AssetTypes.LeftLeg] = Constants.AvatarEditorStructure.Subcategories.LeftLegs,
	[CommonConstants.AssetTypes.ClimbAnim] = Constants.AvatarEditorStructure.Subcategories.Climb,
	[CommonConstants.AssetTypes.FallAnim] = Constants.AvatarEditorStructure.Subcategories.Fall,
	[CommonConstants.AssetTypes.IdleAnim] = Constants.AvatarEditorStructure.Subcategories.Idle,
	[CommonConstants.AssetTypes.JumpAnim] = Constants.AvatarEditorStructure.Subcategories.Jump,
	[CommonConstants.AssetTypes.RunAnim] = Constants.AvatarEditorStructure.Subcategories.Run,
	[CommonConstants.AssetTypes.SwimAnim] = Constants.AvatarEditorStructure.Subcategories.Swim,
	[CommonConstants.AssetTypes.WalkAnim] = Constants.AvatarEditorStructure.Subcategories.Walk,
}

Constants.BundleTypeToCategory = {
	[CommonConstants.BundleType.BodyParts] = Constants.AvatarEditorStructure.Categories.Characters,
	[CommonConstants.BundleType.AvatarAnimations] = Constants.AvatarEditorStructure.Categories.Animation,
}

return Constants
