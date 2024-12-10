local AvatarCreationService = game:GetService("AvatarCreationService")

export type SimMeshInfo = {
	Verts: { [number]: Vector3 },
	CFrame: CFrame,
}

export type SimMeshInfos = {
	[string]: SimMeshInfo,
}

local BoundsConstants = {}

BoundsConstants.ScaleType = "ProportionsNormal"

BoundsConstants.BoundsPadding = 0.8

BoundsConstants.PartToEnumMap = {
	Head = Enum.AssetType.DynamicHead,
	UpperTorso = Enum.AssetType.Torso,
	LowerTorso = Enum.AssetType.Torso,
	LeftHand = Enum.AssetType.LeftArm,
	LeftLowerArm = Enum.AssetType.LeftArm,
	LeftUpperArm = Enum.AssetType.LeftArm,
	RightHand = Enum.AssetType.RightArm,
	RightLowerArm = Enum.AssetType.RightArm,
	RightUpperArm = Enum.AssetType.RightArm,
	LeftFoot = Enum.AssetType.LeftLeg,
	LeftLowerLeg = Enum.AssetType.LeftLeg,
	LeftUpperLeg = Enum.AssetType.LeftLeg,
	RightFoot = Enum.AssetType.RightLeg,
	RightLowerLeg = Enum.AssetType.RightLeg,
	RightUpperLeg = Enum.AssetType.RightLeg,
}

-- In Hierarchy Order
BoundsConstants.EnumToPartsMap = {
	[Enum.AssetType.DynamicHead] = { "Head" },
	[Enum.AssetType.Torso] = { "LowerTorso", "UpperTorso" },
	[Enum.AssetType.LeftArm] = { "LeftUpperArm", "LeftLowerArm", "LeftHand" },
	[Enum.AssetType.RightArm] = { "RightUpperArm", "RightLowerArm", "RightHand" },
	[Enum.AssetType.LeftLeg] = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
	[Enum.AssetType.RightLeg] = { "RightUpperLeg", "RightLowerLeg", "RightFoot" },
}

local validationRules = AvatarCreationService:GetValidationRules()
BoundsConstants.BodyPartRules = validationRules.BodyPartRules

return BoundsConstants
