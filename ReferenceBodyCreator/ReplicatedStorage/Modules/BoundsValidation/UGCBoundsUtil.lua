-- Module script with util functions for validating if body part meshes follow the UGC Validation rules
-- Functions:
--      ValidateBounds: Calculates the original and deformed bounds of a body asset (ie: RightHand, RightLowerArm, RightUpperArm)
--          and returns information about the asset if the deformed bounds do not fall within the UGC limits.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local BoundsValidation = Modules:WaitForChild("BoundsValidation")
local BoundsCalculator = require(BoundsValidation:WaitForChild("BoundsCalculator"))
local BoundsConstants = require(BoundsValidation:WaitForChild("BoundsConstants"))
local AssetBoundingBox = require(BoundsValidation:WaitForChild("AssetBoundingBox"))

local UGCBoundsUtil = {}

export type OutOfBoundsData = {
	assetTypeEnum: Enum.AssetType,
	size: Vector3,
	originalSize: Vector3,
	minSize: Vector3,
	maxSize: Vector3,
}

local function ValidateBoundingBox(
	assetTypeEnum: Enum.AssetType,
	scaleTypeKey: string,
	originalAssetBoundingBox: AssetBoundingBox.AssetBoundingBoxClass,
	assetBoundingBox: AssetBoundingBox.AssetBoundingBoxClass
)
	local boundsLimits = BoundsConstants.BodyPartRules[assetTypeEnum].Bounds[scaleTypeKey]
	local dimensions = { "X", "Y", "Z" }
	local assetSize = assetBoundingBox:Extent()
	local boundsInfo = {
		assetTypeEnum = assetTypeEnum,
		size = assetSize,
		originalSize = originalAssetBoundingBox:Extent(),
		minSize = boundsLimits.MinSize,
		maxSize = boundsLimits.MaxSize,
	} :: OutOfBoundsData

	for _, dimension in dimensions do
		local assetSizeOnAxis = assetSize[dimension]
		local minSizeOnAxis = boundsLimits.MinSize[dimension] / BoundsConstants.BoundsPadding
		local maxSizeOnAxis = boundsLimits.MaxSize[dimension] * BoundsConstants.BoundsPadding

		if assetSizeOnAxis < minSizeOnAxis then
			return false,
				boundsInfo,
				string.format(
					"Asset size for %s is too small. Asset size is (%.2f, %.2f, %.2f) but the minimum asset size is (%s)",
					assetTypeEnum.Name,
					assetSize.X,
					assetSize.Y,
					assetSize.Z,
					tostring(boundsLimits.MinSize)
				)
		end

		if assetSizeOnAxis > maxSizeOnAxis then
			return false,
				boundsInfo,
				string.format(
					"Asset size for %s is too big. Asset size is (%.2f, %.2f, %.2f) but the maximum asset size is (%s)",
					assetTypeEnum.Name,
					assetSize.X,
					assetSize.Y,
					assetSize.Z,
					tostring(boundsLimits.MaxSize)
				)
		end
	end

	return true
end

function UGCBoundsUtil.ValidateBounds(
	initialMeshInfo: BoundsConstants.SimMeshInfos,
	deformedMeshInfo: BoundsConstants.SimMeshInfos,
	deformsPartNames: { string }
)
	local errorBoundsInfos = {}
	for _, deformedPartName in deformsPartNames do
		local assetTypeEnum = BoundsConstants.PartToEnumMap[deformedPartName]
		local originalAssetBoundingBox = BoundsCalculator.CalculateAssetBounds(assetTypeEnum, initialMeshInfo)
		local assetBoundingBox = BoundsCalculator.CalculateAssetBounds(assetTypeEnum, deformedMeshInfo)
		local success, errorBoundsInfo, _errorMessage =
			ValidateBoundingBox(assetTypeEnum, BoundsConstants.ScaleType, originalAssetBoundingBox, assetBoundingBox)
		if not success then
			table.insert(errorBoundsInfos, errorBoundsInfo)
		end
	end

	return errorBoundsInfos
end

return UGCBoundsUtil
