-- Keeps inactive accessories visible with smaller images while full-resolution outputs are cached.
-- Owns the display images; EditableManager keeps the originals and restores them for editing.
-- Interim until CreateSurfaceAppearanceAsync accepts baked runtime Content without a live EditableImage.

local AssetService = game:GetService("AssetService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Constants = require(Modules:WaitForChild("Config"):WaitForChild("Constants"))

local OutputPreviewCache = {}
OutputPreviewCache.__index = OutputPreviewCache

-- Display quality caps, separate from the resolution used for editable textures.
local MAX_PREVIEW_SIZE = { color = 512, metalness = 256, roughness = 256 }

-- Releases all display images, including a partially allocated preview set.
local function destroyImages(images)
	for _, image in images do
		image:Destroy()
	end
end

-- Computes display sizes without upscaling and reports whether a smaller preview is needed.
local function getPreviewSizes(originals)
	local sizes, needsPreview = {}, false
	for _, channel in Constants.CHANNEL_NAMES do
		local size = originals[channel].Size
		sizes[channel] =
			Vector2.new(math.min(size.X, MAX_PREVIEW_SIZE[channel]), math.min(size.Y, MAX_PREVIEW_SIZE[channel]))
		needsPreview = needsPreview or sizes[channel] ~= size
	end
	return sizes, needsPreview
end

-- Creates the preview owner; getParts resolves every mesh currently displaying an output.
function OutputPreviewCache.new(textureInfo, getParts)
	return setmetatable({ textureInfo = textureInfo, getParts = getParts, outputs = {} }, OutputPreviewCache)
end

-- Prepares all replacements before swapping bindings and destroying the previous appearances.
local function replaceAppearances(appearance, parts, replacements)
	for _, target in parts do
		local previous = target:FindFirstChildWhichIsA("SurfaceAppearance")
		local replacement = appearance:Clone()
		table.insert(replacements, { target = target, previous = previous, appearance = replacement })
		replacement.AlphaMode = if previous then previous.AlphaMode else Enum.AlphaMode.Transparency
		if previous then
			replacement.Name, replacement.Color = previous.Name, previous.Color
		end
	end
	for _, entry in replacements do
		entry.appearance.Parent = entry.target
	end
	for _, entry in replacements do
		if entry.previous then
			entry.previous:Destroy()
		end
	end
end

-- Prepare the appearance before changing any bindings. All parts share the same image set.
function OutputPreviewCache:Bind(part, images, shouldCancelCallback: () -> boolean): boolean
	local layer = self.textureInfo.modelTextureInfo[part]
	local manager = self.textureInfo.editableManager
	local normal = manager:GetEI(layer.normalMapId or self.textureInfo.defaultNormalMapId)
	local appearance = AssetService:CreateSurfaceAppearanceAsync({
		ColorMap = Content.fromObject(images.color),
		MetalnessMap = Content.fromObject(images.metalness),
		RoughnessMap = Content.fromObject(images.roughness),
		NormalMap = Content.fromObject(normal),
	})
	local replacements = {}
	local success, result = pcall(function()
		if shouldCancelCallback() then
			return false
		end
		replaceAppearances(appearance, self.getParts(part), replacements)
		return true
	end)
	appearance:Destroy()
	if not success or not result then
		for _, entry in replacements do
			entry.appearance:Destroy()
		end
	end
	if not success then
		error(result, 0)
	end
	return result
end

-- Creates and binds a display set, cleaning up partial allocations on cancellation or failure.
local function createAndBindPreview(self, part, originals, sizes, shouldCancelCallback: () -> boolean): boolean
	local texture = self.textureInfo
	local manager = texture.editableManager
	local images = {}
	local success, bound = pcall(function()
		for _, channel in Constants.CHANNEL_NAMES do
			local label = "OutputPreview owner=" .. texture.managerId .. " channel=" .. channel
			local image = AssetService:CreateEditableImage({ Size = sizes[channel] })
			if not image then
				manager:ThrowMemoryError(label)
			end
			images[channel] = image

			image:DrawImageTransformed(
				image.Size / 2,
				image.Size / originals[channel].Size,
				0,
				originals[channel],
				{ CombineType = Enum.ImageCombineType.Overwrite }
			)
		end
		if shouldCancelCallback() then
			return false
		end
		return self:Bind(part, images, shouldCancelCallback)
	end)
	if not success or not bound then
		destroyImages(images)
		if not success then
			error(bound, 0)
		end
		return false
	end
	self.outputs[part] = { images = images }
	return true
end

-- Binds smaller display images before caching each full-resolution output channel.
function OutputPreviewCache:Cache(shouldCancelCallback: () -> boolean): boolean
	if RunService:IsServer() then
		return true
	end
	local texture = self.textureInfo
	local manager = texture.editableManager
	for part, layer in texture:GetUniqueLayerMap() do
		if shouldCancelCallback() then
			return false
		end
		if not self.outputs[part] then
			local originals = manager:GetEISet(layer.outputEditableSetId)
			local sizes, needsPreview = getPreviewSizes(originals)
			if not needsPreview then
				continue
			end
			local previewReady = createAndBindPreview(self, part, originals, sizes, shouldCancelCallback)
			if not previewReady then
				return false
			end
		end
		-- Bind previews before releasing originals; partial bakes remain recoverable.
		for _, id in manager:GetEISetChannelImageIds(layer.outputEditableSetId) do
			local cachedContent = manager:CacheEI(id, texture.managerId, shouldCancelCallback)
			if not cachedContent then
				return false
			end
		end
	end
	return not shouldCancelCallback()
end

-- Restores and binds original outputs before releasing their display previews.
function OutputPreviewCache:Restore(shouldCancelCallback: () -> boolean): boolean
	local texture = self.textureInfo
	local manager = texture.editableManager
	for part, preview in self.outputs do
		if shouldCancelCallback() then
			return false
		end
		local originals = manager:GetEISet(texture.modelTextureInfo[part].outputEditableSetId)
		if shouldCancelCallback() then
			return false
		end
		local bound = self:Bind(part, originals, shouldCancelCallback)
		if not bound then
			return false
		end
		self.outputs[part] = nil
		destroyImages(preview.images)
	end
	return not shouldCancelCallback()
end

-- Releases only display previews; original outputs remain owned by EditableManager.
function OutputPreviewCache:Destroy()
	for _, preview in self.outputs do
		destroyImages(preview.images)
	end
	table.clear(self.outputs)
end

return OutputPreviewCache
