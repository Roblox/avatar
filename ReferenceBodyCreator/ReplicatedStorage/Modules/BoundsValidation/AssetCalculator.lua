-- Module with helper functions for calculating mesh part locations
-- Functions:
--		CalculateStraightenedLimb: Returns the cframes of the parts after rotating them such that they align with I-Pose
--		CalculateAllTransformsForAsset: Returns the cframes of each part in the body part asset relative to the "root" mesh part

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local BoundsValidation = Modules:WaitForChild("BoundsValidation")
local BoundsConstants = require(BoundsValidation:WaitForChild("BoundsConstants"))

export type PartsCFrames = {
	[string]: CFrame?,
}

local AssetCalculator = {}

local EPSILON = 1e-12

local function FloatEquals(a: number, b: number)
	return math.abs(a - b) <= EPSILON
end

local function CanBeNormalized(vect: Vector3)
	return (not FloatEquals(vect.X, 0)) or (not FloatEquals(vect.Y, 0)) or (not FloatEquals(vect.Z, 0))
end

local function CalculateCFrame(root: Vector3, leaf: Vector3)
	local yVector = leaf - root
	if not CanBeNormalized(yVector) then
		return -- error, top and bottom are in the same location
	end

	yVector = yVector.Unit

	local xVector = yVector:Cross(Vector3.zAxis).Unit
	if not CanBeNormalized(xVector) then -- yVector is pointing along the world z axis
		local crossWith = if yVector.Z < 0 then Vector3.yAxis else -Vector3.yAxis
		xVector = yVector:Cross(crossWith).Unit
	end
	local zVector = xVector:Cross(yVector).Unit

	return CFrame.fromMatrix(Vector3.new(), xVector, yVector, zVector)
end

local function CalculateHierarchyTransforms(assetTypeEnum: Enum.AssetType, assetParts: BoundsConstants.SimMeshInfos)
	local partsHierarchyOrder = BoundsConstants.EnumToPartsMap[assetTypeEnum]
	local rootPart = assetParts[partsHierarchyOrder[1]]
	local results = {} :: PartsCFrames
	for index, partName in partsHierarchyOrder do
		if index == 1 then
			results[partName] = CFrame.new()
			continue
		end

		local currentPart = assetParts[partName]
		results[partName] = rootPart.CFrame:inverse() * currentPart.CFrame
	end

	return results
end

function AssetCalculator.CalculateStraightenedLimb(
	partsCFrames: PartsCFrames,
	assetTypeEnum: Enum.AssetType,
	assetParts: BoundsConstants.SimMeshInfos
)
	local partsHierarchyOrder = BoundsConstants.EnumToPartsMap[assetTypeEnum]
	local rootPart = assetParts[partsHierarchyOrder[1]]
	local leafPart = assetParts[partsHierarchyOrder[#partsHierarchyOrder]]
	local transform = CalculateCFrame(rootPart.CFrame.Position, leafPart.CFrame.Position)

	local result = {} :: PartsCFrames
	for part, cframe in partsCFrames do
		result[part] = transform:inverse() * cframe
	end

	return result
end

function AssetCalculator.CalculateAllTransformsForAsset(
	assetTypeEnum: Enum.AssetType,
	assetParts: BoundsConstants.SimMeshInfos
)
	if Enum.AssetType.DynamicHead == assetTypeEnum then
		return {
			Head = CFrame.new(),
		}
	end

	return CalculateHierarchyTransforms(assetTypeEnum, assetParts)
end

return AssetCalculator
