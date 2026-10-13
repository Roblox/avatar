--[[
	Manager for keeping track of editable images, caching them, and managing
	their lifecycle in order to reliably track memory usage.

	Stores cached and live editable images in separate tables, indexed by either
	a unique generated ID or the asset ID of the image.
]]
local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local EditableManager = {}

type EditableImageSet = Constants.EditableImageSet

function EditableManager.new()
	local self = setmetatable({}, { __index = EditableManager })

	self.idCounter = 0

	self.cachedImages = {} :: { [string]: Content }
	self.liveEditableImages = {} :: { [string]: EditableImage }
	self.eiSetToImagesMap = {} :: { [string]: { [string]: string } }
	self.imageAccessVersions = {} :: { [string]: number }
	self.eiManagerMap = {} :: { [string]: { [string]: boolean } }

	return self
end

-- Throws a memory error with an optional context message. Does not initiate
-- teardown; partial or complete teardown can be done by the caller.
-- pcall recommended when calling this to handle the error gracefully.
function EditableManager:ThrowMemoryError(context: string?)
	if context then
		warn("Memory error: " .. context)
	end

	error(Constants.FAILED_TO_CREATE_EI_MSG)
end

function EditableManager:IdExists(id: string): boolean
	return self.liveEditableImages[id] ~= nil or self.cachedImages[id] ~= nil
end

function EditableManager:AddManager(imageId: string, managerId: string)
	assert(self:IdExists(imageId), "Editable image not found: " .. imageId)

	local managers = self.eiManagerMap[imageId] or {}
	managers[managerId] = true
	self.eiManagerMap[imageId] = managers
end

-- Create a unique ID for an editable image.
function EditableManager:CreateId(prefix: string?): string
	self.idCounter = self.idCounter + 1
	return (prefix or "ID") .. "-" .. tostring(self.idCounter - 1)
end

-- Creates an editable image of the given size and tracks it for cleanup.
function EditableManager:CreateEI(size: Vector2, imageId: string?, managerId: string): (EditableImage, string)
	local id = imageId or self:CreateId()
	assert(not self:IdExists(id), "Editable image ID already exists: " .. id)

	local editableImage = AssetService:CreateEditableImage({ Size = size })

	if not editableImage then
		self:ThrowMemoryError()
	end

	self.liveEditableImages[id] = editableImage
	self.eiManagerMap[id] = { [managerId] = true }
	return editableImage, id
end

-- Loads an editable image from content and tracks it for cleanup.
function EditableManager:CreateEIFromContent(
	imageContent: Content,
	imageId: string?,
	managerId: string
): (EditableImage, string)
	local id = imageId or self:CreateId()
	assert(not self:IdExists(id), "Editable image ID already exists: " .. id)

	local editableImage = AssetService:CreateEditableImageAsync(imageContent)
	if not editableImage then
		self:ThrowMemoryError()
	end

	self.liveEditableImages[id] = editableImage
	self.eiManagerMap[id] = { [managerId] = true }

	return editableImage, id
end

-- Loads content or creates a blank image at the given size, then destroys it after the callback.
function EditableManager:UseTemporaryImage(contentOrSize: Content | Vector2, callback: (EditableImage) -> ()): ()
	local editableImage

	local success, result = pcall(function()
		if typeof(contentOrSize) == "Vector2" then
			return AssetService:CreateEditableImage({ Size = contentOrSize })
		end
		return AssetService:CreateEditableImageAsync(contentOrSize)
	end)

	if not success or not result then
		self:ThrowMemoryError()
	end
	editableImage = result

	local callbackSuccess, callbackResult = pcall(function()
		callback(editableImage)
	end)

	editableImage:Destroy()

	if not callbackSuccess then
		error(callbackResult, 0)
	end
end

local function fillEI(editableImage: EditableImage, color: Color3)
	editableImage:DrawRectangle(Vector2.zero, editableImage.Size, color, 0, Enum.ImageCombineType.Overwrite)
end

-- Creates a set of editable images, including color, metalness, and roughness maps.
-- The editable images are stored individually in the liveEditableImages table,
-- and their IDs are tracked in the eiSetToImagesMap.
function EditableManager:CreateEISet(
	colorSize: Vector2,
	pbrSize: Vector2,
	fillPBRDefaults: boolean,
	setId: string,
	managerId: string
): (EditableImageSet, string)
	assert(not self.eiSetToImagesMap[setId], "Editable image set already exists: " .. setId)

	local eiSet = {} :: EditableImageSet

	local setImageIds = {} :: { [string]: string }

	local success, result = pcall(function()
		-- Color
		local colorEI, colorId = self:CreateEI(colorSize, setId .. ":Color", managerId)
		setImageIds.color = colorId
		eiSet.color = colorEI

		-- Metalness
		local metalnessEI, metalnessId = self:CreateEI(pbrSize, setId .. ":Metalness", managerId)
		setImageIds.metalness = metalnessId
		if fillPBRDefaults then
			fillEI(metalnessEI, Constants.PBR_DEFAULT_METAL_COLOR)
		end
		eiSet.metalness = metalnessEI

		-- Roughness
		local roughnessEI, roughnessId = self:CreateEI(pbrSize, setId .. ":Roughness", managerId)
		setImageIds.roughness = roughnessId
		if fillPBRDefaults then
			fillEI(roughnessEI, Constants.PBR_DEFAULT_ROUGH_COLOR)
		end
		eiSet.roughness = roughnessEI
	end)
	if not success then
		for _, id in setImageIds do
			self:DestroyEI(id, managerId)
		end

		error(result, 0)
		-- Error thrown, execution stops.
	end

	self.eiSetToImagesMap[setId] = setImageIds

	return eiSet, setId
end

function EditableManager:GetEISet(setId: string, managerId: string?): EditableImageSet?
	local setImageIds = self.eiSetToImagesMap[setId]
	if not setImageIds then
		warn("Editable image set not found: " .. setId)
		return nil
	end

	local eiSet = {} :: EditableImageSet
	for _, channel in Constants.CHANNEL_NAMES do
		local imageId = setImageIds[channel]
		local editableImage = if imageId then self:GetEI(imageId) else nil
		if not editableImage then
			warn("Could not load Editable Image for channel: " .. channel .. " in set: " .. setId)
			return nil
		end
		eiSet[channel] = editableImage
	end

	return eiSet
end

function EditableManager:GetEISetChannelImageIds(setId: string): { [string]: string }?
	local setImageIds = self.eiSetToImagesMap[setId]
	if not setImageIds then
		warn("Editable image set not found: " .. setId)
		return nil
	end
	return setImageIds
end

-- Returns a fresh map of cached channel contents without rehydrating images.
function EditableManager:GetCachedEISetContent(setId: string): { [string]: Content }?
	local setImageIds = self:GetEISetChannelImageIds(setId)
	if not setImageIds then
		return nil
	end

	local contents = {}
	for _, channel in Constants.CHANNEL_NAMES do
		local imageId = setImageIds[channel]
		if imageId then
			contents[channel] = self.cachedImages[imageId]
		end
	end
	return contents
end

function EditableManager:DestroyEISet(setId: string, managerId: string?)
	local setImageIds = self.eiSetToImagesMap[setId]
	if setImageIds then
		for _, id in setImageIds do
			self:DestroyEI(id, managerId)
		end

		local inUse = false
		for _, id in setImageIds do
			if self.eiManagerMap[id] and next(self.eiManagerMap[id]) then
				inUse = true
				break
			end
		end

		if not inUse then
			self.eiSetToImagesMap[setId] = nil
		end
	else
		warn("Editable image set not found: " .. setId)
	end
end

local function isOnlyManager(managers: { [string]: boolean }?, managerId: string): boolean
	if not managers or not managers[managerId] then
		return false
	end
	for id in managers do
		if id ~= managerId then
			return false
		end
	end
	return true
end

-- Bake before releasing; failures or cancellation leave the image live.
-- Reacquire images with GetEI after caching. Ownership and set membership are preserved.
-- managerId restricts caching to exclusive ownership; shouldCancelCallback can stop a pending bake.
function EditableManager:CacheEI(imageId: string, managerId: string?, shouldCancelCallback: (() -> boolean)?): Content?
	if RunService:IsServer() then
		-- Servers do not have the client EditableImage memory budget, so keep images live.
		return nil
	end
	if
		(shouldCancelCallback and shouldCancelCallback())
		or (managerId and not isOnlyManager(self.eiManagerMap[imageId], managerId))
	then
		return nil
	end

	if self.cachedImages[imageId] then
		return self.cachedImages[imageId]
	end

	local editableImage = self.liveEditableImages[imageId]
	if not editableImage then
		warn("Editable image not found: " .. imageId)
		return nil
	end

	-- GetEI increments this version whenever an image is requested.
	-- If it changes while the bake yields, keep the image live.
	local version = self.imageAccessVersions[imageId]
	local result, content = AssetService:CreateDataModelContentAsync(Content.fromObject(editableImage))
	if result ~= Enum.CreateContentResult.Success or not content then
		warn("Failed to cache editable image '" .. imageId .. "': " .. tostring(result))
		return nil
	end
	if
		(shouldCancelCallback and shouldCancelCallback())
		or self.liveEditableImages[imageId] ~= editableImage
		or self.imageAccessVersions[imageId] ~= version
		or (managerId and not isOnlyManager(self.eiManagerMap[imageId], managerId))
	then
		return nil
	end

	self.cachedImages[imageId] = content
	self.liveEditableImages[imageId] = nil
	editableImage:Destroy()
	return content
end

-- Channels are cached independently; a failure can leave a partially cached set.
-- GetEISet supports these mixed sets and rehydrates the cached channels on demand.
-- Returns the successfully cached contents.
function EditableManager:CacheEISet(setId: string, managerId: string?): { [string]: Content }?
	if RunService:IsServer() then
		-- Servers do not have the client EditableImage memory budget, so keep images live.
		return nil
	end
	local setImageIds = self.eiSetToImagesMap[setId]
	if not setImageIds then
		warn("Editable image set not found: " .. setId)
		return
	end

	local contents = {}
	for _, channel in Constants.CHANNEL_NAMES do
		local imageId = setImageIds[channel]
		local content = if imageId then self:CacheEI(imageId, managerId) else nil
		if not content then
			warn("Failed to cache editable image for channel '" .. tostring(channel) .. "' in set '" .. setId .. "'")
			continue
		end
		contents[channel] = content
	end
	return contents
end

-- Cache exclusively owned images, preserving excluded display images.
-- onCached lets callers update bindings before the next image bake yields.
function EditableManager:CacheImagesFor(
	managerId: string,
	excludedIds: { [string]: boolean }?,
	shouldCancelCallback: (() -> boolean)?,
	onCached: ((string, Content) -> ())?
): boolean
	if RunService:IsServer() then
		return true
	end
	local imageIds = {}
	for id, owners in self.eiManagerMap do
		if isOnlyManager(owners, managerId) and not (excludedIds and excludedIds[id]) then
			table.insert(imageIds, id)
		end
	end
	for _, id in imageIds do
		local content = self:CacheEI(id, managerId, shouldCancelCallback)
		if not content then
			return false
		end
		if onCached then
			onCached(id, content)
		end
	end
	return not (shouldCancelCallback and shouldCancelCallback())
end

-- Completed restores survive failure or cancellation so callers can retry.
function EditableManager:RehydrateImagesFor(
	managerId: string,
	shouldCancelCallback: (() -> boolean)?,
	excludedIds: { [string]: boolean }?
): boolean
	local imageIds = {}
	for id, owners in self.eiManagerMap do
		if owners[managerId] and not (excludedIds and excludedIds[id]) then
			table.insert(imageIds, id)
		end
	end
	for _, id in imageIds do
		if shouldCancelCallback and shouldCancelCallback() then
			return false
		end
		local owners = self.eiManagerMap[id]
		if owners and owners[managerId] and not self:GetEI(id) then
			return false
		end
	end
	return not (shouldCancelCallback and shouldCancelCallback())
end

-- Rehydrates a cached image under the same ID. Remains cached on memory failure.
function EditableManager:RehydrateEI(imageId: string): EditableImage?
	if self.liveEditableImages[imageId] then
		return self.liveEditableImages[imageId]
	end

	local content = self.cachedImages[imageId]
	if not content then
		warn("Editable image not found: " .. imageId)
		return nil
	end

	local editableImage = AssetService:CreateEditableImageAsync(content)
	if self.cachedImages[imageId] ~= content then
		if editableImage then
			editableImage:Destroy()
		end
		-- Another restore may have completed and been cached again while this one yielded.
		if not self.liveEditableImages[imageId] and self.cachedImages[imageId] then
			return self:RehydrateEI(imageId)
		end
		return self.liveEditableImages[imageId]
	end
	if not editableImage then
		self:ThrowMemoryError("Rehydrating editable image: " .. imageId)
	end

	self.liveEditableImages[imageId] = editableImage
	self.cachedImages[imageId] = nil
	return editableImage
end

function EditableManager:GetEI(imageId: string): EditableImage?
	self.imageAccessVersions[imageId] = (self.imageAccessVersions[imageId] or 0) + 1
	if self.cachedImages[imageId] then
		return self:RehydrateEI(imageId)
	end

	if not self.liveEditableImages[imageId] then
		warn("Editable image not found: " .. imageId)
		return nil
	end

	return self.liveEditableImages[imageId]
end

function EditableManager:DestroyEI(imageId: string, managerId: string?): ()
	if managerId then
		local managers = self.eiManagerMap[imageId]
		if managers then
			managers[managerId] = nil
			if next(managers) then
				-- In use by other managers, do not destroy
				return
			end
		end
	end

	local editableImage = self.liveEditableImages[imageId]
	if editableImage then
		editableImage:Destroy()
		self.liveEditableImages[imageId] = nil
	end
	self.cachedImages[imageId] = nil
	self.eiManagerMap[imageId] = nil
	self.imageAccessVersions[imageId] = nil
end

-- Debug function to inspect the current state of the EditableManager
function EditableManager:PrintImages(): ()
	local rows = {} :: { { label: string, size: string? } }
	local columnWidth = 0
	local setIds = {}
	for setId in self.eiSetToImagesMap do
		table.insert(setIds, setId)
	end
	table.sort(setIds)

	local function addImage(imageId: string, channel: string?, size: string?)
		local label = "    " .. (if channel then channel .. ": " else "") .. imageId
		columnWidth = math.max(columnWidth, #label)
		table.insert(rows, { label = label, size = size })
	end

	local function addSection(title: string, images, isLive: boolean)
		table.insert(rows, { label = title })
		local groupedIds = {}
		for _, setId in setIds do
			local hasHeader = false
			for _, channel in Constants.CHANNEL_NAMES do
				local imageId = self.eiSetToImagesMap[setId][channel]
				local editableImage = imageId and images[imageId]
				if editableImage and not groupedIds[imageId] then
					if not hasHeader then
						table.insert(rows, { label = "  Set: " .. setId })
						hasHeader = true
					end
					addImage(imageId, channel, if isLive then tostring(editableImage.Size) else nil)
					groupedIds[imageId] = true
				end
			end
		end

		local ungroupedIds = {}
		for imageId in images do
			if not groupedIds[imageId] then
				table.insert(ungroupedIds, imageId)
			end
		end
		table.sort(ungroupedIds)
		if #ungroupedIds > 0 then
			table.insert(rows, { label = "  Ungrouped:" })
			for _, imageId in ungroupedIds do
				addImage(imageId, nil, if isLive then tostring(images[imageId].Size) else nil)
			end
		end
	end

	addSection("Cached editable images:", self.cachedImages, false)
	addSection("Live editable images:", self.liveEditableImages, true)

	local lines = { "!! EditableManager State !!", "" }
	for _, row in rows do
		local line = row.label
		if row.size then
			line = line .. string.rep(" ", columnWidth - #row.label + 2) .. "(size " .. row.size .. ")"
		end
		table.insert(lines, line)
	end
	print(table.concat(lines, "\n"))
end

-- Cache this manager's live images, including set channels, while keeping shared
-- images live. Keep ownership and set membership so getters can rehydrate them.
function EditableManager:CacheTrackedImagesFor(managerId: string): ()
	for imageId in self.liveEditableImages do
		self:CacheEI(imageId, managerId)
	end
end

function EditableManager:DestroyTrackedImagesFor(managerId: string): ()
	for setId in self.eiSetToImagesMap do
		self:DestroyEISet(setId, managerId)
	end
	for imageId in self.liveEditableImages do
		self:DestroyEI(imageId, managerId)
	end
	for imageId in self.cachedImages do
		self:DestroyEI(imageId, managerId)
	end
end

-- Destroy all live editable images and clear the cache
function EditableManager:Destroy(): ()
	for imageId, editableImage in self.liveEditableImages do
		editableImage:Destroy()
	end

	self.idCounter = 0
	self.liveEditableImages = {}
	self.cachedImages = {}
	self.eiSetToImagesMap = {}
	self.imageAccessVersions = {}
	self.eiManagerMap = {}
end

export type EditableManagerClass = typeof(EditableManager)

return EditableManager
