--[[
	Manages an ordered list of named layer groups for a single texture. Each group holds
	input layers and a composite image set that is the merged result of those layers.

	Every layer has a PBR image set (color/metalness/roughness)
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

export type MaskLayer = {
	color: EditableImage?,
	metalness: EditableImage?,
	roughness: EditableImage?,
	imageIds: { [string]: string }?,
}

export type SingleLayer = {
	name: string,
	isVisible: boolean,
	imageSetId: string,
	previewImageId: string?,
	thumbnailContent: Content?,

	opacity: number?,
	-- Temporary stamps preview as part of this layer before its opacity is applied.
	stampTargetLayerId: string?,
}

export type GroupInfo = {
	name: string,
	isVisible: boolean,
	compositeSetId: string?, -- Cleared when the composite is released.
	inputLayers: { SingleLayer },
	-- Which makeup asset type this group represents (Face/Eyes/Lips/Eyebrows/Eyelashes), if any.
	makeupAssetType: string?,
	-- Client-only catalog selection, retained when the editor UI is recreated.
	previewAccessoryName: string?,
	-- Shared, manager-owned subtract mask composited after the visible layers.
	maskLayer: MaskLayer?,
}

export type TargetLayerInfo = {
	groupId: string?,
	layerId: string,
}

local GroupInfo = {}
GroupInfo.__index = GroupInfo

local function findGroup(groups: { GroupInfo }, groupId: string): (number?, GroupInfo?)
	for i, group in groups do
		if group.name == groupId then
			return i, group
		end
	end
	return nil, nil
end

-- MakeupMaskManager produces hidden masks that are transparent in the allowed
-- region and opaque black outside it. Subtracting that mask removes the target
-- image's alpha outside the allowed region without changing its color.
local function ApplyMask(image: EditableImage, mask: EditableImage)
	image:DrawImage(Vector2.zero, mask, Enum.ImageCombineType.Subtract)
end

local function GetMaskImage(self, maskLayer: MaskLayer, channel: string): EditableImage
	if maskLayer.imageIds then
		maskLayer[channel] = self.editableManager:GetEI(maskLayer.imageIds[channel])
	end
	return maskLayer[channel]
end

local function ApplyMaskLayer(self, imageSet: Constants.EditableImageSet, maskLayer: MaskLayer?)
	if maskLayer then
		for _, channel in Constants.CHANNEL_NAMES do
			ApplyMask(imageSet[channel], GetMaskImage(self, maskLayer, channel))
		end
	end
end

local function UpdateLayerPreview(self, groupInfo: GroupInfo, layer: SingleLayer, createIfMissing: boolean?)
	if not groupInfo.maskLayer then
		return
	end

	if not layer.previewImageId and not createIfMissing then
		return
	end

	local previousPreviewId, previousThumbnail = layer.previewImageId, layer.thumbnailContent
	local success, result = pcall(function()
		local function drawPreview(sourceImage: EditableImage)
			local previewImage
			if layer.previewImageId then
				previewImage = self.editableManager:GetEI(layer.previewImageId)
			else
				previewImage, layer.previewImageId = self.editableManager:CreateEI(
					self.previewSize,
					self:GetGroupManagerId(groupInfo.name, layer.name .. "Preview"),
					self.managerId
				)
			end

			previewImage:DrawImageTransformed(
				previewImage.Size / 2,
				previewImage.Size / sourceImage.Size,
				0,
				sourceImage,
				{ CombineType = Enum.ImageCombineType.Overwrite }
			)
			local mask = GetMaskImage(self, groupInfo.maskLayer, "color")
			previewImage:DrawImageTransformed(
				previewImage.Size / 2,
				previewImage.Size / mask.Size,
				0,
				mask,
				{ CombineType = Enum.ImageCombineType.Subtract }
			)
			layer.thumbnailContent = Content.fromObject(previewImage)

			if self.activeGroupId ~= groupInfo.name then
				-- Keep inactive thumbnails cached without rehydrating the input set.
				local content = self.editableManager:CacheEI(layer.previewImageId, self.managerId)
				if content then
					layer.thumbnailContent = content
				end
			end
		end

		local cached = self.editableManager:GetCachedEISetContent(layer.imageSetId)
		if cached == nil then
			-- EI set not found
			return
		end
		if cached.color then
			if createIfMissing then
				self.editableManager:UseTemporaryImage(cached.color, drawPreview)
			end
		else
			local channelImageIds = self.editableManager:GetEISetChannelImageIds(layer.imageSetId)
			local colorImage = channelImageIds and self.editableManager:GetEI(channelImageIds.color)
			if colorImage then
				drawPreview(colorImage)
			end
		end
	end)
	if not success then
		if layer.previewImageId and layer.previewImageId ~= previousPreviewId then
			self.editableManager:DestroyEI(layer.previewImageId, self.managerId)
			layer.previewImageId = previousPreviewId
			layer.thumbnailContent = previousThumbnail
		end
		error(result, 0)
	end
end

local function DrawLayerWithOpacity(
	self,
	target: Constants.EditableImageSet,
	layer: SingleLayer,
	stampLayer: SingleLayer?
)
	local opacity = math.clamp(layer.opacity or 1, 0, 1)
	if opacity <= 0 then
		return
	end

	local function drawSourceImage(channel: string, sourceImage: EditableImage, stampImage: EditableImage?)
		if opacity < 1 then
			if not self.opacityScratchSetId then
				local _, setId = self.editableManager:CreateEISet(
					self.colorSize,
					self.pbrMapSize,
					false,
					self.editableManager:CreateId(self.managerId .. ":OpacityScratch"),
					self.managerId
				)
				self.opacityScratchSetId = setId
			end
			local opacityImage = self.editableManager:GetEISet(self.opacityScratchSetId)[channel]
			opacityImage:DrawImage(Vector2.zero, sourceImage, Enum.ImageCombineType.Overwrite)
			if stampImage then
				-- Apply opacity to the combined layer so the preview matches the baked stamp.
				opacityImage:DrawImage(Vector2.zero, stampImage, Enum.ImageCombineType.BlendSourceOver)
			end
			opacityImage:DrawRectangle(
				Vector2.zero,
				opacityImage.Size,
				Color3.new(1, 1, 1),
				1 - opacity,
				Enum.ImageCombineType.Multiply
			)
			target[channel]:DrawImage(Vector2.zero, opacityImage, Enum.ImageCombineType.BlendSourceOver)
		else
			target[channel]:DrawImage(Vector2.zero, sourceImage, Enum.ImageCombineType.BlendSourceOver)
			if stampImage then
				target[channel]:DrawImage(Vector2.zero, stampImage, Enum.ImageCombineType.BlendSourceOver)
			end
		end
	end

	local cached = self.editableManager:GetCachedEISetContent(layer.imageSetId)
	local channelImageIds = self.editableManager:GetEISetChannelImageIds(layer.imageSetId)

	local function drawChannel(stampImage: EditableImage?, channel: string)
		if cached and cached[channel] then
			-- Recompose inactive groups without rehydrating their input sets.
			self.editableManager:UseTemporaryImage(cached[channel], function(sourceImage: EditableImage)
				drawSourceImage(channel, sourceImage, stampImage)
			end)
		else
			local imageId = channelImageIds and channelImageIds[channel]
			local sourceImage = imageId and self.editableManager:GetEI(imageId)
			if sourceImage then
				drawSourceImage(channel, sourceImage, stampImage)
			end
		end
	end

	for _, channel in Constants.CHANNEL_NAMES do
		-- BakeStampAction blends only the stamp's color into the target layer.
		if stampLayer and channel == "color" then
			local stampCached = self.editableManager:GetCachedEISetContent(stampLayer.imageSetId)
			if stampCached and stampCached.color then
				self.editableManager:UseTemporaryImage(stampCached.color, function(stampImage: EditableImage)
					drawChannel(stampImage, channel)
				end)
			else
				local stampImageIds = self.editableManager:GetEISetChannelImageIds(stampLayer.imageSetId)
				local stampImage = stampImageIds and self.editableManager:GetEI(stampImageIds.color)
				drawChannel(stampImage, channel)
			end
		else
			drawChannel(nil, channel)
		end
	end
end

local function DoMergeDownGroup(self, groupInfo: GroupInfo)
	local composite = self.editableManager:GetEISet(groupInfo.compositeSetId)

	for _, channel in Constants.CHANNEL_NAMES do
		local image = composite[channel]
		image:DrawRectangle(Vector2.zero, image.Size, Color3.new(), 1, Enum.ImageCombineType.Overwrite)
	end

	local stampLayer: SingleLayer? = nil
	for _, layer in groupInfo.inputLayers do
		if layer.name == Constants.STAMP_LAYER and layer.stampTargetLayerId and layer.isVisible then
			stampLayer = layer
			break
		end
	end

	for _, layer: SingleLayer in groupInfo.inputLayers do
		if not layer.isVisible or layer == stampLayer then
			continue
		end
		local layerStamp = if stampLayer and stampLayer.stampTargetLayerId == layer.name then stampLayer else nil
		DrawLayerWithOpacity(self, composite, layer, layerStamp)
	end

	ApplyMaskLayer(self, composite, groupInfo.maskLayer)
	for _, layer in groupInfo.inputLayers do
		UpdateLayerPreview(self, groupInfo, layer, false)
	end
end

-- Cache input layers and thumbnails, leaving the composite live.
local function cacheGroupLayers(
	self,
	groupInfo: GroupInfo,
	shouldCancelCallback: (() -> boolean)?,
	onChanged: (() -> ())?
)
	if RunService:IsServer() then
		return true
	end
	for _, layer in groupInfo.inputLayers do
		if shouldCancelCallback and shouldCancelCallback() then
			return false
		end
		if shouldCancelCallback and groupInfo.maskLayer and not layer.previewImageId then
			self:GetLayerThumbnailContent({ groupId = groupInfo.name, layerId = layer.name })
		end
		if layer.previewImageId then
			local content = self.editableManager:CacheEI(layer.previewImageId, self.managerId, shouldCancelCallback)
			if not content then
				if shouldCancelCallback then
					return false
				end
				continue
			end
			layer.thumbnailContent = content
			if onChanged then
				onChanged()
			end
		end
		local ids = self.editableManager:GetEISetChannelImageIds(layer.imageSetId)
		for _, channel in Constants.CHANNEL_NAMES do
			local content = self.editableManager:CacheEI(ids[channel], self.managerId, shouldCancelCallback)
			if content then
				if channel == "color" and not layer.previewImageId then
					layer.thumbnailContent = content
				end
				if onChanged then
					onChanged()
				end
			elseif shouldCancelCallback then
				return false
			end
		end
	end
	return true
end

-- Let SetActiveGroup or TextureInfoCache catch restore errors and preserve retry state.
-- TextureInfo's memory-error callback destroys existing artwork, so do not call it here.
local function rehydrateGroupLayers(self, groupInfo: GroupInfo)
	for _, layer in groupInfo.inputLayers do
		local images = self.editableManager:GetEISet(layer.imageSetId)
		assert(images, "Could not restore group images")
		local preview = if layer.previewImageId then self.editableManager:GetEI(layer.previewImageId) else images.color
		assert(preview, "Could not restore group preview")
		layer.thumbnailContent = Content.fromObject(preview)
	end
end

-- Allocation errors propagate to TextureInfoCache, which clears its lock and preserves retry state.
function GroupInfo:CacheForContext(shouldCancelCallback: (() -> boolean)?, onChanged: (() -> ())?): boolean
	for _, group in self.groups do
		if not cacheGroupLayers(self, group, shouldCancelCallback, onChanged) then
			return false
		end
	end
	return true
end

function GroupInfo:GetInactiveMaskIds(): { [string]: boolean }
	local excluded = {}
	if RunService:IsServer() then
		return excluded
	end
	local activeGroup = self:GetActiveGroup()
	local activeType = activeGroup and activeGroup.makeupAssetType
	for assetType, masks in self.maskLayersByMakeupAssetType do
		if assetType ~= activeType then
			for _, id in masks.imageIds or {} do
				excluded[id] = true
			end
		end
	end
	return excluded
end

function GroupInfo:GetInactiveImageIds(): { [string]: boolean }
	local excluded = self:GetInactiveMaskIds()
	for _, group in self.groups do
		if group.name ~= self.activeGroupId then
			for _, layer in group.inputLayers do
				if layer.previewImageId then
					excluded[layer.previewImageId] = true
				end
				for _, id in self.editableManager:GetEISetChannelImageIds(layer.imageSetId) or {} do
					excluded[id] = true
				end
			end
		end
	end
	return excluded
end

-- TextureInfoCache retries this method directly if context restoration fails.
function GroupInfo:RehydrateForContext()
	local group = self:GetActiveGroup()
	if group then
		rehydrateGroupLayers(self, group)
	end
	self.liveGroupId = if group then group.name else nil
	self.needsGroupRehydrate = false
end

-- Serialize yielding switches; only the active group keeps its input images live.
function GroupInfo:SetActiveGroup(groupId: string?)
	self.desiredActiveGroupId = groupId

	if self.isApplyingActiveGroup then
		return
	end
	self.isApplyingActiveGroup = true

	local success, message = pcall(function()
		while self.desiredActiveGroupId ~= self.activeGroupId or self.needsGroupRehydrate do
			local target = self.desiredActiveGroupId

			if self.activeGroupId and self.activeGroupId ~= target then
				local _, previousGroup = findGroup(self.groups, self.activeGroupId)
				if previousGroup then
					if self.liveGroupId == self.activeGroupId then
						DoMergeDownGroup(self, previousGroup)
					end
					-- A failed bake can leave mixed live/cached channels; retry without merging stale references.
					self.liveGroupId = nil
					self.needsGroupRehydrate = true
					cacheGroupLayers(self, previousGroup)
				end
			end

			self.activeGroupId = target
			self.needsGroupRehydrate = true
			for id in self:GetInactiveMaskIds() do
				self.editableManager:CacheEI(id, self.managerId)
			end

			local _, newGroup = findGroup(self.groups, target)
			if newGroup then
				rehydrateGroupLayers(self, newGroup)
			end
			self.liveGroupId = if newGroup then target else nil
			self.needsGroupRehydrate = false
		end
	end)
	self.isApplyingActiveGroup = false
	if not success then
		error(message, 0)
	end
end

function GroupInfo:DoMergeDownGroups()
	if not self.liveGroupId then
		return
	end

	local _, liveGroup = findGroup(self.groups, self.liveGroupId)
	if liveGroup then
		DoMergeDownGroup(self, liveGroup)
	end
end

function GroupInfo:SetMaskLayersByMakeupAssetType(maskLayersByType: { [string]: MaskLayer }?)
	self.maskLayersByMakeupAssetType = maskLayersByType or {}
	for _, groupInfo in self.groups do
		groupInfo.maskLayer = groupInfo.makeupAssetType and self.maskLayersByMakeupAssetType[groupInfo.makeupAssetType]
		local composite = self.editableManager:GetEISet(groupInfo.compositeSetId)
		ApplyMaskLayer(self, composite, groupInfo.maskLayer)
		for _, layer in groupInfo.inputLayers do
			UpdateLayerPreview(self, groupInfo, layer, false)
		end
	end
end

function GroupInfo:GetComposites(): { Constants.EditableImageSet }
	local composites = {}
	for _, groupInfo in self.groups do
		if groupInfo.isVisible then
			local composite = self.editableManager:GetEISet(groupInfo.compositeSetId)
			table.insert(composites, composite)
		end
	end

	return composites
end

function GroupInfo:DestroyAllTrackedImages()
	if self.opacityScratchSetId then
		self.editableManager:DestroyEISet(self.opacityScratchSetId, self.managerId)
		self.opacityScratchSetId = nil
	end

	for _, groupInfo in self.groups do
		if groupInfo.compositeSetId then
			self.editableManager:DestroyEISet(groupInfo.compositeSetId, self.managerId)
			groupInfo.compositeSetId = nil
		end

		for _, layer in groupInfo.inputLayers do
			self.editableManager:DestroyEISet(layer.imageSetId, self.managerId)
			if layer.previewImageId then
				self.editableManager:DestroyEI(layer.previewImageId, self.managerId)
				layer.previewImageId = nil
			end
			layer.thumbnailContent = nil
		end
	end
end

function GroupInfo:GetGroupManagerId(groupId: string, str: string): string
	return self.imageIdPrefix .. ":" .. groupId .. ":" .. str
end

function GroupInfo:CreateGroup(groupId: string, makeupAssetType: string?)
	local _, existing = findGroup(self.groups, groupId)
	if existing then
		warn("Group " .. groupId .. " already exists.")
		return
	end

	local _, compositeSetId = self.editableManager:CreateEISet(
		self.colorSize,
		self.pbrMapSize,
		false,
		self:GetGroupManagerId(groupId, "Composite"),
		self.managerId
	)

	table.insert(self.groups, {
		name = groupId,
		isVisible = true,
		compositeSetId = compositeSetId,
		inputLayers = {},
		makeupAssetType = makeupAssetType,
		maskLayer = makeupAssetType and self.maskLayersByMakeupAssetType[makeupAssetType],
	})
end

function GroupInfo:HasLayerInGroup(targetLayerInfo: TargetLayerInfo)
	if not targetLayerInfo.groupId then
		warn("HasLayerInGroup called with nil groupId")
		return false
	end

	local _, groupInfo = findGroup(self.groups, targetLayerInfo.groupId)
	if not groupInfo then
		warn("Group " .. targetLayerInfo.groupId .. " does not exist.")
		return false
	end

	for _, layer in groupInfo.inputLayers do
		if layer.name == targetLayerInfo.layerId then
			return true
		end
	end

	return false
end

function GroupInfo:GetGroup(groupId: string)
	local _, groupInfo = findGroup(self.groups, groupId)
	return groupInfo
end

function GroupInfo:GetActiveGroup(): GroupInfo?
	if not self.activeGroupId then
		return nil
	end
	return self:GetGroup(self.activeGroupId)
end

function GroupInfo:GetAllGroups()
	return self.groups
end

function GroupInfo:GetLayerThumbnailContent(targetLayerInfo: TargetLayerInfo): Content?
	if not targetLayerInfo.groupId then
		return nil
	end

	local _, groupInfo = findGroup(self.groups, targetLayerInfo.groupId)
	if not groupInfo then
		return nil
	end

	for _, layer in groupInfo.inputLayers do
		if layer.name == targetLayerInfo.layerId then
			if groupInfo.maskLayer and not layer.previewImageId then
				UpdateLayerPreview(self, groupInfo, layer, true)
			end
			return layer.thumbnailContent
		end
	end
	return nil
end

-- Returns the layer's image set ID and a boolean indicating if the layer was created.
function GroupInfo:GetOrCreateLayerInGroup(
	targetLayerInfo: TargetLayerInfo,
	insertAfterLayerId: string?
): (string?, boolean)
	if not targetLayerInfo.groupId then
		warn("GetOrCreateLayerInGroup called with nil groupId")
		return nil, false
	end

	local _, groupInfo = findGroup(self.groups, targetLayerInfo.groupId)
	if not groupInfo then
		warn("Group " .. targetLayerInfo.groupId .. " does not exist.")
		return nil, false
	end

	for _, layer in groupInfo.inputLayers do
		if layer.name == targetLayerInfo.layerId then
			local images = self.editableManager:GetEISet(layer.imageSetId)
			if images and not layer.previewImageId then
				-- A lookup may rehydrate an inactive layer before group activation.
				layer.thumbnailContent = Content.fromObject(images.color)
			end
			return layer.imageSetId, false
		end
	end

	-- Stamps only draw color.
	local pbrSize = if targetLayerInfo.layerId == Constants.STAMP_LAYER then Vector2.one else self.pbrMapSize
	local newLayer, imageSetId = self.editableManager:CreateEISet(
		self.colorSize,
		pbrSize,
		false, --[[default PBR]]
		self:GetGroupManagerId(targetLayerInfo.groupId, targetLayerInfo.layerId),
		self.managerId
	)

	-- Higher indices draw on top, so inserting after a layer places the new one directly above it.
	local insertionIndex = #groupInfo.inputLayers + 1
	if insertAfterLayerId then
		for i, layer in groupInfo.inputLayers do
			if layer.name == insertAfterLayerId then
				insertionIndex = i + 1
				break
			end
		end
	end

	local singleLayer: SingleLayer = {
		name = targetLayerInfo.layerId,
		isVisible = true,
		imageSetId = imageSetId,

		opacity = 1,
		stampTargetLayerId = if targetLayerInfo.layerId == Constants.STAMP_LAYER then insertAfterLayerId else nil,
		thumbnailContent = Content.fromObject(newLayer.color),
	}
	table.insert(groupInfo.inputLayers, insertionIndex, singleLayer)

	return imageSetId, true
end

function GroupInfo:SetGroupVisible(groupId: string, isVisible: boolean)
	local _, groupInfo = findGroup(self.groups, groupId)
	if not groupInfo then
		warn("Group " .. groupId .. " does not exist.")
		return
	end

	groupInfo.isVisible = isVisible
end

function GroupInfo:SetLayerVisible(targetLayerInfo: TargetLayerInfo, isVisible: boolean)
	if not targetLayerInfo.groupId then
		warn("SetLayerVisible called with nil groupId")
		return
	end

	local _, groupInfo = findGroup(self.groups, targetLayerInfo.groupId)
	if not groupInfo then
		warn("Group " .. targetLayerInfo.groupId .. " does not exist.")
		return
	end

	for _, layer in groupInfo.inputLayers do
		if layer.name == targetLayerInfo.layerId then
			layer.isVisible = isVisible
			DoMergeDownGroup(self, groupInfo)
			return
		end
	end

	warn("Layer " .. targetLayerInfo.layerId .. " does not exist in group " .. targetLayerInfo.groupId)
end

function GroupInfo:SetLayerOpacity(targetLayerInfo: TargetLayerInfo, opacity: number)
	if not targetLayerInfo.groupId then
		warn("SetLayerOpacity called with nil groupId")
		return
	end

	local _, groupInfo = findGroup(self.groups, targetLayerInfo.groupId)
	if not groupInfo then
		warn("Group " .. targetLayerInfo.groupId .. " does not exist.")
		return
	end

	for _, layer in groupInfo.inputLayers do
		if layer.name == targetLayerInfo.layerId then
			layer.opacity = math.clamp(opacity, 0, 1)
			return
		end
	end

	warn("Layer " .. targetLayerInfo.layerId .. " does not exist in group " .. targetLayerInfo.groupId)
end

function GroupInfo:DeleteGroup(groupId: string)
	local index, groupInfo = findGroup(self.groups, groupId)
	if not groupInfo then
		warn("Group " .. groupId .. " does not exist.")
		return
	end

	for _, layer in groupInfo.inputLayers do
		self.editableManager:DestroyEISet(layer.imageSetId, self.managerId)
		if layer.previewImageId then
			self.editableManager:DestroyEI(layer.previewImageId, self.managerId)
		end
	end

	if groupInfo.compositeSetId then
		self.editableManager:DestroyEISet(groupInfo.compositeSetId, self.managerId)
		groupInfo.compositeSetId = nil
	end

	if self.activeGroupId == groupId then
		self.activeGroupId = nil
	end
	if self.liveGroupId == groupId then
		self.liveGroupId = nil
	end

	table.remove(self.groups, index)
end

function GroupInfo:RemoveLayerFromGroup(targetLayerInfo: TargetLayerInfo)
	if not targetLayerInfo.groupId then
		warn("RemoveLayerFromGroup called with nil groupId")
		return
	end

	local _, groupInfo = findGroup(self.groups, targetLayerInfo.groupId)
	if not groupInfo then
		warn("Group " .. targetLayerInfo.groupId .. " does not exist.")
		return
	end

	for i, layer in ipairs(groupInfo.inputLayers) do
		if layer.name == targetLayerInfo.layerId then
			self.editableManager:DestroyEISet(layer.imageSetId, self.managerId)
			if layer.previewImageId then
				self.editableManager:DestroyEI(layer.previewImageId, self.managerId)
			end
			table.remove(groupInfo.inputLayers, i)
			return
		end
	end

	warn("Layer " .. targetLayerInfo.layerId .. " does not exist in group " .. targetLayerInfo.groupId)
end

function GroupInfo:MoveGroup(groupId: string, direction: number)
	local index, groupInfo = findGroup(self.groups, groupId)
	if not groupInfo then
		warn("Group " .. groupId .. " does not exist.")
		return
	end

	local newIndex = index - direction
	if newIndex < 1 then
		newIndex = 1
	elseif newIndex > #self.groups then
		newIndex = #self.groups
	end

	if newIndex == index then
		return -- No change in position
	end

	table.remove(self.groups, index)
	table.insert(self.groups, newIndex, groupInfo)
end

function GroupInfo:MoveLayerInGroup(targetLayerInfo: TargetLayerInfo, direction: number)
	if not targetLayerInfo.groupId then
		warn("MoveLayerInGroup called with nil groupId")
		return
	end

	local _, groupInfo = findGroup(self.groups, targetLayerInfo.groupId)
	if not groupInfo then
		warn("Group " .. targetLayerInfo.groupId .. " does not exist.")
		return
	end

	local currentIndex = nil
	for i, layer in groupInfo.inputLayers do
		if layer.name == targetLayerInfo.layerId then
			currentIndex = i
			break
		end
	end

	if not currentIndex then
		error("Layer " .. targetLayerInfo.layerId .. " not found in group " .. targetLayerInfo.groupId)
	end

	local layerToMove = table.remove(groupInfo.inputLayers, currentIndex)
	-- Direction is either 1 (move down) or -1 (move up)
	-- Since higher indices are drawn on top of lower indices, moving up means
	-- increasing the index and moving down means decreasing the index. so we
	-- subtract the direction.
	local newIndex = currentIndex - direction
	if newIndex < 1 then
		newIndex = 1
	elseif newIndex > #groupInfo.inputLayers + 1 then
		newIndex = #groupInfo.inputLayers + 1
	end
	table.insert(groupInfo.inputLayers, newIndex, layerToMove)
end

-- colorSize is the full texture resolution for the color channel; pbrMapSize is the
-- (smaller) size shared by the metalness/roughness channels.
function GroupInfo.new(editableManager, managerId: string, colorSize: Vector2, pbrMapSize: Vector2)
	local self = setmetatable({}, GroupInfo)

	self.editableManager = editableManager
	self.managerId = managerId
	-- Group stacks share a texture owner but need distinct image IDs.
	self.imageIdPrefix = editableManager:CreateId("GroupInfo")
	self.colorSize = colorSize
	self.pbrMapSize = pbrMapSize
	local previewScale = math.min(1, Constants.THUMBNAIL_EI_MAX_SIZE / math.max(colorSize.X, colorSize.Y))
	self.previewSize = Vector2.new(
		math.max(1, math.round(colorSize.X * previewScale)),
		math.max(1, math.round(colorSize.Y * previewScale))
	)

	-- Lazily allocated and reused across layers and groups until teardown.
	self.opacityScratchSetId = nil

	-- Groups of GroupInfo, each containing a composite image set and input layers.
	-- Ordered from bottom to top, with the first group being the bottom-most group.
	self.groups = {}

	-- The group the user is targeting. liveGroupId is the group whose layers are
	-- actually live right now (the only one safe to merge); they differ only during
	-- a switch. desiredActiveGroupId/isApplyingActiveGroup serialize SetActiveGroup.
	self.activeGroupId = nil
	self.liveGroupId = nil
	self.desiredActiveGroupId = nil
	self.isApplyingActiveGroup = false
	self.maskLayersByMakeupAssetType = {}

	return self
end

export type GroupInfoClass = typeof(GroupInfo)

return GroupInfo
