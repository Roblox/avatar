local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blanks = ReplicatedStorage:WaitForChild("Blanks")
local MeshEditControlGroups = ReplicatedStorage:WaitForChild("MeshEditControlGroups")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local RegionMaps = require(Config:WaitForChild("RegionMaps"))

-- Contains information about the various avatar models that the player can use as a starting point.

export type BlankData = {
	name: string,
	sourceModel: Model,

	initialZOffset: number,
	meshEditControlGroups: Folder,

	regionMapSubParts: RegionMaps.RegionMap,
	regionMapIndividual: RegionMaps.RegionMap,
}

local BlanksData: { BlankData } = {
	{
		name = "RobotModel",

		sourceModel = Blanks:WaitForChild("RobotModel"),

		initialZOffset = 2,
		meshEditControlGroups = MeshEditControlGroups:WaitForChild("RobotModel"),

		regionMapSubParts = RegionMaps.RobotSubParts,
		regionMapIndividual = RegionMaps.RobotIndividualParts,
	},
}

return BlanksData
