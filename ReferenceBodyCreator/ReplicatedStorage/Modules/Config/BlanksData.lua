local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blanks = ReplicatedStorage:WaitForChild("Blanks")
local MeshEditControlGroups = ReplicatedStorage:WaitForChild("MeshEditControlGroups")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local RegionMaps = require(Config:WaitForChild("RegionMaps"))

-- Contains information about the various avatar models that the player can use as a starting point.

export type BlankData = {
	name: string,
	creationType: string,
	avatarAssetType: Enum.AvatarAssetType?,

	enableYRotation: boolean?,
	enableWidgetMeshEditing: boolean?,
	enableKitbashing: boolean?,
	enableStickerPatterning: boolean?,

	sourceModel: Model,

	initialZOffset: number,
	meshEditControlGroups: Folder,
	previewScale: number?,

	regionMapSubParts: RegionMaps.RegionMap,
	regionMapIndividual: RegionMaps.RegionMap,
	individualPartsNames: { [string]: boolean },
}

local function getIndividualPartNames(individualParts: RegionMaps.RegionMap)
	local partsNames = {}
	for _, region in individualParts do
		partsNames[region.name] = true
	end
	return partsNames
end

local BlanksData: { BlankData } = {
	{
		name = "RobotModel",
		creationType = Constants.CREATION_TYPES.Body,
		enableWidgetMeshEditing = true,
		enableStickerPatterning = true,
		enableRegionalStickerPatterning = true,

		sourceModel = Blanks:WaitForChild("RobotModel"),

		initialZOffset = 2,
		meshEditControlGroups = MeshEditControlGroups:WaitForChild("RobotModel"),

		regionMapSubParts = RegionMaps.RobotSubParts,
		regionMapIndividual = RegionMaps.RobotIndividualParts,
		individualPartsNames = getIndividualPartNames(RegionMaps.RobotIndividualParts),
	},
	{
		name = "TShirtModel",
		creationType = Constants.CREATION_TYPES.Accessory,
		avatarAssetType = Enum.AvatarAssetType.TShirtAccessory,
		enableStickerPatterning = true,
		enableRegionalStickerPatterning = true,
		enableWidgetMeshEditing = true,
		enableKitbashing = true,

		sourceModel = Blanks:WaitForChild("TShirtModel"),

		initialZOffset = 2,
		meshEditControlGroups = MeshEditControlGroups:WaitForChild("TShirtModel"),

		regionMapSubParts = RegionMaps.TShirtSubParts,
		regionMapIndividual = RegionMaps.TShirtIndividualParts,
		individualPartsNames = getIndividualPartNames(RegionMaps.TShirtIndividualParts),
	},
	{
		name = "HatModel",
		creationType = Constants.CREATION_TYPES.Accessory,
		avatarAssetType = Enum.AvatarAssetType.Hat,
		enableYRotation = true,
		enableStickerPatterning = true,
		enableRegionalStickerPatterning = true,
		enableKitbashing = true,

		sourceModel = Blanks:WaitForChild("HatModel"),

		initialZOffset = 2,
		meshEditControlGroups = MeshEditControlGroups:WaitForChild("HatModel"),
		previewScale = 1.2,

		regionMapSubParts = RegionMaps.HatSubParts,
		regionMapIndividual = RegionMaps.HatIndividualParts,
		individualPartsNames = getIndividualPartNames(RegionMaps.HatIndividualParts),
	},
}

local AVATAR_ASSET_TYPE_TO_ACCESSORY_TYPE = {
	[Enum.AvatarAssetType.Hat] = Enum.AccessoryType.Hat,
	[Enum.AvatarAssetType.TShirtAccessory] = Enum.AccessoryType.TShirt,
	[Enum.AvatarAssetType.JacketAccessory] = Enum.AccessoryType.Jacket,
	[Enum.AvatarAssetType.PantsAccessory] = Enum.AccessoryType.Pants,
	[Enum.AvatarAssetType.ShirtAccessory] = Enum.AccessoryType.Shirt,
	[Enum.AvatarAssetType.DressSkirtAccessory] = Enum.AccessoryType.DressSkirt,
	[Enum.AvatarAssetType.SweaterAccessory] = Enum.AccessoryType.Sweater,
	[Enum.AvatarAssetType.ShortsAccessory] = Enum.AccessoryType.Shorts,
	[Enum.AvatarAssetType.BackAccessory] = Enum.AccessoryType.Back,
	[Enum.AvatarAssetType.FaceAccessory] = Enum.AccessoryType.Face,
	[Enum.AvatarAssetType.NeckAccessory] = Enum.AccessoryType.Neck,
	[Enum.AvatarAssetType.WaistAccessory] = Enum.AccessoryType.Waist,
	[Enum.AvatarAssetType.FrontAccessory] = Enum.AccessoryType.Front,
	[Enum.AvatarAssetType.HairAccessory] = Enum.AccessoryType.Hair,
}

local function validateBlankData()
	for _, blankData in BlanksData do
		if blankData.creationType == Constants.CREATION_TYPES.Accessory then
			local sourceModel: Model = blankData.sourceModel
			local accessory = sourceModel:FindFirstChildWhichIsA("Accessory")
			assert(accessory, "Accessory model " .. blankData.name .. " is missing an Accessory instance.")
			assert(accessory.AccessoryType ~= Enum.AccessoryType.Unknown, "Accessory model " .. blankData.name .. " has AccessoryType set to Unknown.")

			local expectedAccessoryType = AVATAR_ASSET_TYPE_TO_ACCESSORY_TYPE[blankData.avatarAssetType]
			assert(accessory.AccessoryType == expectedAccessoryType, "Accessory model " .. blankData.name .. " has AccessoryType " .. tostring(accessory.AccessoryType) .. " but expected " .. tostring(expectedAccessoryType) .. ".")
		end
	end
end

validateBlankData()

return BlanksData
