--[[
	Builds and caches Face/Eyes/Lips subtract masks for makeup group composites.
	Fits authored cage-space masks to the WTT's UV bounds without baking into head UVs.
	PrebakeAll() runs on client and server so preview and published makeup use the same masks.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local MakeupProjectionUtils = require(Modules:WaitForChild("MeshManipulation"):WaitForChild("MakeupProjectionUtils"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local MakeupRegionMasks = require(TextureManipulation:WaitForChild("MakeupRegionMasks"))

local HEAD_PART_NAME = "Head"

local MakeupMaskManager = {}
MakeupMaskManager.__index = MakeupMaskManager

function MakeupMaskManager.new(modelInfo)
	local self = setmetatable({}, MakeupMaskManager)
	self.modelInfo = modelInfo
	self.editableManager = modelInfo:GetTextureInfo().editableManager
	self.maskLayersByType = {}
	self.maskIdsByType = {}
	self.prebaked = false
	return self
end

-- Creates a subtract layer by subtracting the allow mask from an opaque black image.
local function createSubtractMask(textureInfo, mask: EditableImage, size: Vector2): (EditableImage, string)
	-- PrebakeAll catches allocation failures. Once allocated, release this image
	-- if drawing fails before the caller can record its ID.
	local subtractMask, maskId = textureInfo.editableManager:CreateEI(size, nil, textureInfo.managerId)
	local success, message = pcall(function()
		subtractMask:DrawRectangle(Vector2.zero, size, Color3.new(), 0, Enum.ImageCombineType.Overwrite)

		if mask.Size == size then
			subtractMask:DrawImage(Vector2.zero, mask, Enum.ImageCombineType.Subtract)
		else
			local scale = math.max(mask.Size.X / size.X, mask.Size.Y / size.Y)
			subtractMask:DrawImageTransformed(
				size / 2,
				Vector2.one / scale,
				0,
				mask,
				{ CombineType = Enum.ImageCombineType.Subtract }
			)
		end
	end)
	if not success then
		textureInfo.editableManager:DestroyEI(maskId, textureInfo.managerId)
		error(message, 0)
	end
	return subtractMask, maskId
end

-- Caches the decal-region masks in projection texture space at each channel size.
function MakeupMaskManager:PrebakeAll()
	if self.prebaked then
		return
	end
	self.prebaked = true

	local headPart = self.modelInfo:GetMeshPartByName(HEAD_PART_NAME)
	if not headPart then
		warn("[MakeupMaskManager] No Head MeshPart found; makeup masking disabled.")
		return
	end

	local textureInfo = self.modelInfo:GetTextureInfo()
	local projectionTarget = self.modelInfo:GetMeshInfo():GetProjectionTarget(headPart)
	assert(projectionTarget:IsA("WrapTextureTransfer"), "Missing makeup projection transfer")
	local colorSize = textureInfo:GetTextureSize(headPart)
	local pbrSize = textureInfo:GetPBRMapSize()

	local cageMasks = MakeupRegionMasks.Load()
	for _, makeupAssetType in Constants.MAKEUP_DECAL_ASSET_TYPES do
		local ok, targetMaskOrError = pcall(function()
			return MakeupProjectionUtils.CreateTransferredRegionImage(cageMasks[makeupAssetType], projectionTarget)
		end)

		if not ok then
			warn(
				("[MakeupMaskManager] %s bake failed; skipping confinement for it. %s"):format(
					makeupAssetType,
					tostring(targetMaskOrError)
				)
			)
		elseif not targetMaskOrError then
			warn(
				("[MakeupMaskManager] %s bake returned nil, possibly due to insufficient EditableImage memory; skipping confinement for it."):format(
					makeupAssetType
				)
			)
		else
			local targetMask = targetMaskOrError
			local ids = {}
			local success, masks = pcall(function()
				local pbrMask, pbrId = createSubtractMask(textureInfo, targetMask, pbrSize)
				ids.metalness, ids.roughness = pbrId, pbrId
				local colorMask, colorId = createSubtractMask(textureInfo, targetMask, colorSize)
				ids.color = colorId
				return { color = colorMask, metalness = pbrMask, roughness = pbrMask, imageIds = ids }
			end)
			targetMask:Destroy()
			if success then
				self.maskIdsByType[makeupAssetType] = ids
				self.maskLayersByType[makeupAssetType] = masks
			else
				-- Do not expose an incomplete mask set to later context restores.
				for _, id in ids do
					self.editableManager:DestroyEI(id, textureInfo.managerId)
				end
				warn("[MakeupMaskManager] Could not create " .. makeupAssetType .. " masks: " .. tostring(masks))
			end
		end

		task.wait()
	end

	-- Source masks are consumed once baked.
	for _, makeupAssetType in Constants.MAKEUP_DECAL_ASSET_TYPES do
		cageMasks[makeupAssetType]:Destroy()
	end

	textureInfo:SetGroupMaskLayers(headPart, self.maskLayersByType)
end

-- TextureInfoCache calls this after restoring the active context's images.
-- Rebind existing live images only; inactive masks stay cached until GroupInfo requests them.
function MakeupMaskManager:Rehydrate()
	local manager = self.editableManager
	for assetType, ids in self.maskIdsByType do
		local masks = self.maskLayersByType[assetType]
		for channel, id in ids do
			masks[channel] = manager.liveEditableImages[id]
		end
	end
end

function MakeupMaskManager:Destroy()
	local textureInfo = self.modelInfo:GetTextureInfo()
	local destroyed = {}
	for _, ids in self.maskIdsByType do
		for _, id in ids do
			if not destroyed[id] then
				self.editableManager:DestroyEI(id, textureInfo.managerId)
				destroyed[id] = true
			end
		end
	end
	self.maskIdsByType = {}
	self.maskLayersByType = {}
end

export type MakeupMaskManagerClass = typeof(MakeupMaskManager)

return MakeupMaskManager
