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

return BlanksData
