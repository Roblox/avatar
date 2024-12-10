-- Module with helper functions for calculating the bounds of a body part asset.
-- Functions:
--		CalculateAssetBounds: Returns a bounding box of the combined size of all meshes for a body part. For arms and legs, the limb is straightened to I-pose first before calculating bounds

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local BoundsValidation = Modules:WaitForChild("BoundsValidation")
local AssetCalculator = require(BoundsValidation:WaitForChild("AssetCalculator"))
local AssetBoundingBox = require(BoundsValidation:WaitForChild("AssetBoundingBox"))
local BoundsConstants = require(BoundsValidation:WaitForChild("BoundsConstants"))

local BoundsCalculator = {}

local function OrientSingleAssetToWorldAxes(
	partsCFrames: AssetCalculator.PartsCFrames,
	assetTypeEnum: Enum.AssetType,
	assetParts: BoundsConstants.SimMeshInfos
)
	if
		assetTypeEnum ~= Enum.AssetType.LeftArm
		and assetTypeEnum ~= Enum.AssetType.RightArm
		and assetTypeEnum ~= Enum.AssetType.LeftLeg
		and assetTypeEnum ~= Enum.AssetType.RightLeg
	then
		return
	end

	-- change order of args
	local results = AssetCalculator.CalculateStraightenedLimb(partsCFrames, assetTypeEnum, assetParts)

	for name, newCFrame in results do
		partsCFrames[name] = newCFrame
	end
end

local function CalculateBoundsDataForPart(meshPartInfo: BoundsConstants.SimMeshInfo, cframe: CFrame)
	local verts = meshPartInfo.Verts
	local boundingBoxForPart: AssetBoundingBox.AssetBoundingBoxClass = AssetBoundingBox.new()
	for _, vertPos in verts do
		boundingBoxForPart:Expand(cframe:PointToWorldSpace(vertPos))
	end

	return boundingBoxForPart
end

local function CalculateAllPartsBoundsData(
	partsCFrames: AssetCalculator.PartsCFrames,
	assetParts: BoundsConstants.SimMeshInfos
)
	local result = {}
	for partName, cframe in partsCFrames do
		result[partName] = CalculateBoundsDataForPart(assetParts[partName], cframe)
	end
	return result
end

local function CalculateTotalBoundsForAsset(
	partsCFrames: AssetCalculator.PartsCFrames,
	assetParts: BoundsConstants.SimMeshInfos
)
	local allPartsBoundsData = CalculateAllPartsBoundsData(partsCFrames, assetParts)
	local overallBounds: AssetBoundingBox.AssetBoundingBoxClass = AssetBoundingBox.new()
	for partName, boundingBoxForPart in allPartsBoundsData do
		overallBounds:Combine(boundingBoxForPart)
	end
	return overallBounds
end

function BoundsCalculator.CalculateAssetBounds(assetTypeEnum: Enum.AssetType, assetParts: BoundsConstants.SimMeshInfos)
	if assetTypeEnum == Enum.AssetType.DynamicHead then
		return CalculateTotalBoundsForAsset({ Head = CFrame.new() }, assetParts)
	end

	local partsCFrames = AssetCalculator.CalculateAllTransformsForAsset(assetTypeEnum, assetParts)

	OrientSingleAssetToWorldAxes(partsCFrames, assetTypeEnum, assetParts)

	return CalculateTotalBoundsForAsset(partsCFrames, assetParts)
end

return BoundsCalculator
