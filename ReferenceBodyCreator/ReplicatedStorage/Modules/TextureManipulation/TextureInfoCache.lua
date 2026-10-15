-- Coordinates cache/restore for a head or accessory editing context.
-- EditableManager owns originals; OutputPreviewCache owns optional display previews.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local OutputPreviewCache = require(
	ReplicatedStorage:WaitForChild("Modules"):WaitForChild("TextureManipulation"):WaitForChild("OutputPreviewCache")
)

local CACHE_OPERATION = "cache"
local REHYDRATE_OPERATION = "rehydrate"

local TextureInfoCache = {}
TextureInfoCache.__index = TextureInfoCache

function TextureInfoCache.new(modelInfo)
	local textureInfo = modelInfo:GetTextureInfo()
	local self = setmetatable({
		modelInfo = modelInfo,
		textureInfo = textureInfo,
		needsRehydrate = false,
		activeUseCount = 0,
		guideVisibility = {},
	}, TextureInfoCache)
	textureInfo.editingCache = self
	if textureInfo.isMakeupAccessory and RunService:IsClient() then
		-- Resolve current display targets when binding; the preview accessory can be replaced.
		self.outputPreviewCache = OutputPreviewCache.new(textureInfo, function(part)
			if self.getOutputParts then
				return self.getOutputParts(part)
			end
			return { part }
		end)
	end
	return self
end

function TextureInfoCache:Cache(stillIdle: () -> boolean): boolean
	if RunService:IsServer() then
		return true
	end

	if self.destroyed or self.busy or self.activeUseCount > 0 or not stillIdle() then
		return false
	end
	if self.cached then
		return true
	end

	-- Cancellation invalidates this request while image operations yield.
	local request = {}
	self.request, self.busy = request, CACHE_OPERATION
	local function shouldCancelCallback()
		return self.destroyed or self.request ~= request or self.activeUseCount ~= 0 or not stillIdle()
	end

	local textureInfo = self.textureInfo
	local manager = textureInfo.editableManager
	-- Even a partial cache must be restored before editing can resume.
	self.needsRehydrate = true

	local success, result = pcall(function()
		-- Hide guides while the output can still be recomposed, then suspend editing updates.
		local guideManager = self.modelInfo:GetMakeupGuideManager()
		if guideManager then
			guideManager:ReleaseActiveGuide()
		end
		if not self.suspended then
			for part, layerInfo in textureInfo:GetUniqueLayerMap() do
				self.guideVisibility[layerInfo] = layerInfo.showMakeupGuides
				textureInfo:SetShowMakeupGuides(part, false)
			end
		end
		self.suspended = true
		textureInfo:ReleaseStampEditableImage()
		textureInfo:ReleaseMirroredStickerImage()

		-- Cache editing resources, keeping the display outputs and normal maps live.
		local excludedIds = { [textureInfo.defaultNormalMapId] = true }
		for _, layerInfo in textureInfo:GetUniqueLayerMap() do
			if not layerInfo.groupLayers:CacheForContext(shouldCancelCallback, self.onChanged) then
				return false
			end

			if layerInfo.normalMapId then
				excludedIds[layerInfo.normalMapId] = true
			end
			for _, id in manager:GetEISetChannelImageIds(layerInfo.outputEditableSetId) or {} do
				excludedIds[id] = true
			end
		end

		if not manager:CacheImagesFor(textureInfo.managerId, excludedIds, shouldCancelCallback, self.onChanged) then
			return false
		end

		self.modelInfo:GetMeshInfo():SuspendDeformedMeshes()
		if self.outputPreviewCache then
			local previewsReady = self.outputPreviewCache:Cache(shouldCancelCallback)
			if not previewsReady then
				return false
			end
		end

		self.cached = true
		return true
	end)

	-- Release the operation lock on success, cancellation, or error.
	self.request, self.busy = nil, nil
	if not success then
		error(result, 0)
	end
	return result
end

function TextureInfoCache:Rehydrate(): boolean
	-- Cancel pending caching and wait for the current operation to finish.
	if self.busy == CACHE_OPERATION then
		self:Cancel()
	end
	while self.busy and not self.destroyed do
		task.wait()
	end

	if self.destroyed then
		return false
	end
	if not self.needsRehydrate then
		return true
	end

	local request = {}
	self.request, self.busy = request, REHYDRATE_OPERATION
	-- A failed or cancelled restore can leave live images that must be cached again.
	self.cached = false
	local function shouldCancelCallback()
		return self.destroyed or self.request ~= request
	end

	local textureInfo = self.textureInfo
	local success, result = pcall(function()
		-- Release display previews first to leave room for editing images.
		if self.outputPreviewCache then
			local outputsRestored = self.outputPreviewCache:Restore(shouldCancelCallback)
			if not outputsRestored then
				return false
			end
		end

		-- Restore required images while leaving inactive groups cached.
		local excludedIds = {}
		for _, layerInfo in textureInfo:GetUniqueLayerMap() do
			for id in layerInfo.groupLayers:GetInactiveImageIds() do
				excludedIds[id] = true
			end
		end

		if
			not textureInfo.editableManager:RehydrateImagesFor(textureInfo.managerId, shouldCancelCallback, excludedIds)
		then
			return false
		end

		-- Refresh mask and active-group references after their images are available.
		local masks = self.modelInfo:GetMakeupMaskManager()
		if masks then
			masks:Rehydrate()
		end
		for _, layerInfo in textureInfo:GetUniqueLayerMap() do
			if shouldCancelCallback() then
				return false
			end
			layerInfo.groupLayers:RehydrateForContext()
		end

		if shouldCancelCallback() then
			return false
		end
		self.modelInfo:GetMeshInfo():ResumeDeformedMeshes()
		self.suspended, self.cached = false, false

		-- Restore guide visibility now that output updates can safely use editing images.
		for layerInfo, visible in self.guideVisibility do
			layerInfo.showMakeupGuides = visible
		end
		local guides = self.modelInfo:GetMakeupGuideManager()
		if guides then
			guides:RefreshActiveGuide()
		elseif textureInfo.isMakeupAccessory then
			-- Accessories have no guide manager to redraw the restored guide/base texture.
			for part, layerInfo in textureInfo:GetUniqueLayerMap() do
				if layerInfo.showMakeupGuides then
					textureInfo:UpdateOutputColorMap(part)
				end
			end
		end

		-- Preserve saved visibility and retry state until all required redraws succeed.
		table.clear(self.guideVisibility)
		self.needsRehydrate = false
		if self.onChanged then
			self.onChanged()
		end
		return true
	end)

	self.request, self.busy = nil, nil
	if not success then
		error(result, 0)
	end
	return result
end

function TextureInfoCache:Destroy()
	self.destroyed = true
	self:Cancel()
	if self.outputPreviewCache then
		self.outputPreviewCache:Destroy()
	end
	self.getOutputParts = nil
	self.onIdle, self.onChanged = nil, nil
end

function TextureInfoCache:Cancel()
	self.request = nil
end

-- Hold resources until EndUse; overlapping operations each take their own hold.
-- Restores editing resources by default; pass false for display-only access.
function TextureInfoCache:BeginUse(restore: boolean?)
	assert(not self.destroyed, "Texture context was destroyed")
	self.activeUseCount += 1

	local success, ready = pcall(function()
		if restore ~= false then
			return self:Rehydrate()
		end

		-- Display-only operations leave editing images cached.
		if self.busy == CACHE_OPERATION then
			self:Cancel()
		end
		while self.busy and not self.destroyed do
			task.wait()
		end
		return not self.destroyed
	end)

	if not success or not ready then
		self.activeUseCount -= 1
		error(if success then "Texture context restore was cancelled" else ready, 0)
	end
end

-- Notify the owner when the last operation releases its hold; it decides whether to cache.
function TextureInfoCache:EndUse()
	self.activeUseCount -= 1
	if self.activeUseCount == 0 and self.onIdle then
		self.onIdle()
	end
end

export type TextureInfoCache = typeof(TextureInfoCache)

return TextureInfoCache
