--[[
	Client tool for selecting eyebrow/eyelash accessories, previewing them on the
	makeup head, and editing their textures and shapes on isolated accessory models.

	The accessories live in category folders under
	ReplicatedStorage.Eyebrows_Eyelashes_Template and deform onto the head via the
	layered clothing system.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ModelInfo = require(Modules:WaitForChild("ModelInfo"))
local AccessoryEditModel = require(Modules:WaitForChild("AccessoryEditModel"))
local ResolutionManager = require(Modules:WaitForChild("ResolutionManager"))
local ActionUtils = require(Modules:WaitForChild("ActionUtils"))
local Actions = require(Modules:WaitForChild("Actions"))
local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local GroupInfo = require(TextureManipulation:WaitForChild("GroupInfo"))
local TextureInfoCache = require(TextureManipulation:WaitForChild("TextureInfoCache"))

local Constants = require(Modules:WaitForChild("Config"):WaitForChild("Constants"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")
local SetAccessoryEditModelEvent = Remotes:WaitForChild("SetAccessoryEditModelEvent")

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local AccessoryUtils = require(MeshManipulation:WaitForChild("AccessoryUtils"))
local AccessoryShape = require(MeshManipulation:WaitForChild("AccessoryShape"))

local TEMPLATE_FOLDER_NAME = "Eyebrows_Eyelashes_Template"

local PreviewAccessoryTool = {}
PreviewAccessoryTool.__index = PreviewAccessoryTool

type AccessoryInfo = {
	name: string,
	accessory: Accessory,
	previewInstance: MeshPart,
}

type TextureContents = {
	color: Content,
	metalness: Content,
	roughness: Content,
	normal: Content,
}

type AccessorySelection = {
	name: string,
	accessory: Accessory?,
	previewMesh: EditableMesh?,
	previewShapeRevision: number?,
	previewKitbashRevision: number?,
	editModelInfo: ModelInfo.ModelInfoClass,
	group: GroupInfo.GroupInfo,
	order: number,
	resolutionIndex: number,
	editingCache: TextureInfoCache.TextureInfoCache?,
}

-- Returns the mesh data for the accessory's single editable mesh part.
local function getAccessoryMeshInfo(modelInfo: ModelInfo.ModelInfoClass)
	local part = modelInfo:GetMeshParts()[1]
	return modelInfo:GetMeshInfo():GetModelMeshInfo()[part]
end

local function getCategoryFolder(templateFolder: Folder, category: string): Folder?
	local categoryFolder = templateFolder:FindFirstChild(category)
	if not categoryFolder or not categoryFolder:IsA("Folder") then
		warn("PreviewAccessoryTool: missing category folder " .. category)
		return nil
	end
	return categoryFolder
end

local function bindAccessoryTextures(accessory: Accessory, textureContents: TextureContents)
	local handle = accessory:FindFirstChildWhichIsA("MeshPart", true)
	if not handle then
		return
	end

	local surfaceAppearance = AssetService:CreateSurfaceAppearanceAsync({
		ColorMap = textureContents.color,
		MetalnessMap = textureContents.metalness,
		RoughnessMap = textureContents.roughness,
		NormalMap = textureContents.normal,
	})
	surfaceAppearance.AlphaMode = Enum.AlphaMode.Transparency

	local previousSurfaceAppearance = handle:FindFirstChildWhichIsA("SurfaceAppearance")
	if previousSurfaceAppearance then
		previousSurfaceAppearance:Destroy()
	end
	surfaceAppearance.Parent = handle
end

local function restoreBakedPosition(
	previewMesh: EditableMesh,
	sourceMesh: EditableMesh,
	deformer: WrapDeformer,
	sourceScaleFactor: Vector3,
	previewScale: Vector3
): Vector3
	local minimum = Vector3.new(math.huge, math.huge, math.huge)
	local maximum = -minimum
	local deformedPositions = {}
	for _, vertexId in sourceMesh:GetVertices() do
		local position = sourceMesh:GetPosition(vertexId)
		local deformed = deformedPositions[position]
		if not deformed then
			deformed = deformer:GetDeformedCFrameAsync(CFrame.new(position / sourceScaleFactor)).Position
			deformedPositions[position] = deformed
		end
		minimum = minimum:Min(deformed)
		maximum = maximum:Max(deformed)
	end
	if next(deformedPositions) == nil then
		return Vector3.zero
	end
	local offset = (minimum + maximum) * 0.5 / previewScale - previewMesh:GetCenter()
	if offset.Magnitude > 1e-6 then
		-- Apply after binding the mesh so its new bounds cannot recenter the handle again.
		for _, vertexId in previewMesh:GetVertices() do
			previewMesh:SetPosition(vertexId, previewMesh:GetPosition(vertexId) + offset)
		end
	end
	return offset
end

function PreviewAccessoryTool.new(modelInfo: ModelInfo.ModelInfoClass, editableManager, onUnequip: (string) -> ())
	local self = {}
	setmetatable(self, PreviewAccessoryTool)

	self.modelInfo = modelInfo
	self.editableManager = editableManager
	self.onUnequip = onUnequip
	self.pending = {}
	self.headEditingCache = modelInfo:GetTextureInfo().editingCache or TextureInfoCache.new(modelInfo)
	local templateFolder = ReplicatedStorage:FindFirstChild(TEMPLATE_FOLDER_NAME)
	if not templateFolder or not templateFolder:IsA("Folder") then
		warn("PreviewAccessoryTool: missing ReplicatedStorage." .. TEMPLATE_FOLDER_NAME)
		return nil
	end
	self.templateFolder = templateFolder

	self.selections = modelInfo:GetAccessoryEditSelections() :: { [string]: AccessorySelection }
	self:Refresh()

	return self
end

-- Returns the pickable accessories for a category, including the mesh used by
-- the catalog's ViewportFrame.
-- `category` is a MAKEUP_ASSET_TYPES value ("Eyebrows"/"Eyelashes") and the
-- corresponding subfolder name in the template folder.
function PreviewAccessoryTool:GetAccessoryInfos(category: string): { AccessoryInfo }
	local categoryFolder = getCategoryFolder(self.templateFolder, category)
	if not categoryFolder then
		return {}
	end

	-- Set CatalogOrder on template accessories; unnumbered items follow in name order.
	local children = categoryFolder:GetChildren()
	table.sort(children, function(a, b)
		local aOrder, bOrder = a:GetAttribute("CatalogOrder"), b:GetAttribute("CatalogOrder")
		aOrder = if typeof(aOrder) == "number" then aOrder else math.huge
		bOrder = if typeof(bOrder) == "number" then bOrder else math.huge
		return if aOrder == bOrder then a.Name < b.Name else aOrder < bOrder
	end)

	local infos: { AccessoryInfo } = {}
	for _, child in children do
		if not child:IsA("Accessory") then
			continue
		end

		local handle = child:FindFirstChildWhichIsA("MeshPart", true)
		if not handle or not handle:FindFirstChildWhichIsA("WrapLayer") then
			warn("PreviewAccessoryTool: accessory needs a MeshPart with a WrapLayer: " .. child.Name)
			continue
		end

		table.insert(infos, { name = child.Name, accessory = child, previewInstance = handle })
	end

	return infos
end

function PreviewAccessoryTool:SyncSelection(category: string, syncLayers: boolean?)
	local selection = self.selections[category]
	SetAccessoryEditModelEvent:FireServer(
		category,
		selection.name,
		selection.resolutionIndex,
		selection.editModelInfo:GetServerEditRevision(),
		selection.order
	)
	if syncLayers then
		local modelInfo = selection.editModelInfo
		local part = modelInfo:GetMeshParts()[1]
		local function sendLayerAction(actionType, metadata)
			metadata.targetMeshPartName = part.Name
			SendActionToServerEvent:FireServer(ActionUtils.CreateNewAction(actionType, metadata, modelInfo))
		end
		for _, layer in selection.group.inputLayers do
			local target = { groupId = selection.group.name, layerId = layer.name }
			sendLayerAction(ActionUtils.ActionTypes.AddLayer, { targetLayerInfo = target })
			sendLayerAction(ActionUtils.ActionTypes.SetLayerVisibility, {
				targetLayerInfo = target,
				isVisible = layer.isVisible,
			})
			sendLayerAction(ActionUtils.ActionTypes.SetLayerOpacity, {
				targetLayerInfo = target,
				opacity = layer.opacity or 1,
			})
		end
		sendLayerAction(ActionUtils.ActionTypes.SetGroupVisibility, {
			groupId = selection.group.name,
			isVisible = selection.group.isVisible,
		})
	end
end

-- Frees outgoing editing resources before allocating a replacement accessory.
function PreviewAccessoryTool:PrepareAccessoryBuild(isCurrent: () -> boolean): boolean
	self.contextReady = false
	if self.beforeContextSwitch then
		self.beforeContextSwitch()
	end

	local caches = { self:GetEditingCache(nil) }
	for category in self.selections do
		table.insert(caches, self:GetEditingCache(category))
	end

	for _, cache in caches do
		while (cache.busy or cache.activeUseCount > 0) and isCurrent() do
			task.wait()
		end
		if not isCurrent() then
			return false
		end
		local cached = cache:Cache(isCurrent)
		if not cached then
			return false
		end
	end
	return isCurrent()
end

-- Builds the candidate model and group, retrying at lower resolutions if image memory runs out.
local function buildAccessorySelection(
	self,
	category: string,
	template: Accessory,
	selection,
	previous,
	isCurrent: () -> boolean
): boolean
	local buildOptions = {
		serverEditTarget = category,
		serverEditRevision = HttpService:GenerateGUID(false),
		previousGroup = previous and previous.group,
		cacheLayers = true,
		shouldCancelCallback = function()
			return not isCurrent()
		end,
	}
	-- Rebuild the whole candidate, including copied layers, if it exceeds the image budget.
	-- Keep the previous selection alive until a replacement succeeds.
	for resolutionIndex = ResolutionManager.GetCurrentIndex(), #Constants.TEXTURE_RESOLUTION_STEPS do
		if not isCurrent() then
			return false
		end
		buildOptions.textureResolution = Constants.TEXTURE_RESOLUTION_STEPS[resolutionIndex]
		local built, result = pcall(
			AccessoryEditModel.Build,
			self.editableManager,
			template,
			self.modelInfo:GetModel():GetPivot(),
			buildOptions
		)
		if not isCurrent() then
			if built and result then
				result:Destroy()
			end
			return false
		end
		if built then
			selection.editModelInfo = result
			selection.resolutionIndex = resolutionIndex
			break
		end
		if
			resolutionIndex == #Constants.TEXTURE_RESOLUTION_STEPS
			or not string.find(tostring(result), Constants.FAILED_TO_CREATE_EI_MSG, 1, true)
		then
			error(result)
		end
	end
	assert(selection.editModelInfo, "Failed to prepare accessory edit model")
	local textureInfo = selection.editModelInfo:GetTextureInfo()
	local part = selection.editModelInfo:GetMeshParts()[1]
	selection.group = textureInfo:GetGroup(part, category .. " 1")
	selection.group.previewAccessoryName = selection.name
	return true
end

-- Prepare the editable model before replacing the selection. Its group is also
-- the layer panel's data; there is no second layer stack on the head.
function PreviewAccessoryTool:Equip(category: string, accessoryName: string): boolean
	local categoryFolder = getCategoryFolder(self.templateFolder, category)
	local template = categoryFolder and categoryFolder:FindFirstChild(accessoryName)
	if self.destroyed or not template or not template:IsA("Accessory") then
		return false
	end

	local request = {}
	self.pending[category] = request
	-- Builds and restores share the same allocation headroom.
	while (self.equipping or self.switchingContext) and not self.destroyed and self.pending[category] == request do
		task.wait()
	end
	if self.destroyed or self.pending[category] ~= request then
		return false
	end
	self.equipping = request
	local editingCategory = self.editingCategory
	local previous = self.selections[category]
	local keepEdits = previous and previous.name == accessoryName

	-- Checks whether this equip request still owns the category after yielding.
	local function isCurrent()
		return not self.destroyed
			and self.pending[category] == request
			and (keepEdits or self.editingCategory == editingCategory)
	end

	local selection = if keepEdits then previous else { name = accessoryName }
	local clone = template:Clone()
	local previewSourceModel
	local previewMeshPart
	local previewMesh
	local previewShapeRevision
	local previewKitbashRevision
	local usedCache
	local equipped = false
	local success, err = pcall(function()
		if not keepEdits then
			local contextPrepared = self:PrepareAccessoryBuild(isCurrent)
			if not contextPrepared then
				return
			end

			local built = buildAccessorySelection(self, category, template, selection, previous, isCurrent)
			if not built then
				return
			end
		end
		local editModelInfo = selection.editModelInfo
		selection.editingCache = selection.editingCache or TextureInfoCache.new(editModelInfo)
		-- Rebind both the editable mesh and the current accessory preview when outputs change.
		selection.editingCache.getOutputParts = function(part)
			local parts = { part }
			local accessory = selection.accessory
			local handle = accessory and accessory:FindFirstChildWhichIsA("MeshPart", true)
			if handle then
				table.insert(parts, handle)
			end
			return parts
		end
		selection.editingCache:BeginUse(false)
		usedCache = selection.editingCache
		local editMeshInfo = getAccessoryMeshInfo(editModelInfo)
		local previewHandle = clone:FindFirstChildWhichIsA("MeshPart", true)
		local previewDeformer = previewHandle:FindFirstChildWhichIsA("WrapDeformer")
		if previewDeformer then
			previewDeformer:Destroy()
		end
		previewShapeRevision = editMeshInfo.accessoryShape.revision
		previewKitbashRevision = editMeshInfo.kitbashRevision or 0
		-- Bake atlas UVs even when no add-ons are present.
		if editModelInfo:GetKitbashingEnabled() or editMeshInfo.accessoryShape.isDeformed then
			previewSourceModel = editModelInfo:GetModel():Clone()
			previewSourceModel.Parent = ReplicatedStorage
			local sourceDeformer = previewSourceModel:FindFirstChildWhichIsA("WrapDeformer", true)
			previewMesh = sourceDeformer:CreateEditableMeshAsync()
			previewMeshPart = AssetService:CreateMeshPartAsync(Content.fromObject(previewMesh))
			local meshScale = previewHandle.Size / previewHandle.MeshSize
			previewHandle:ApplyMesh(previewMeshPart)
			previewHandle.Size = previewMeshPart.MeshSize * meshScale
			restoreBakedPosition(
				previewMesh,
				editMeshInfo.kitbashEditableMesh,
				sourceDeformer,
				editMeshInfo.scaleFactor,
				meshScale
			)
		end
		local images, normalMap =
			editModelInfo:GetTextureInfo():GetDisplayOutputImageSet(editModelInfo:GetMeshParts()[1])
		-- Both models use the same output images; painting needs no preview synchronization.
		bindAccessoryTextures(clone, {
			color = Content.fromObject(images.color),
			metalness = Content.fromObject(images.metalness),
			roughness = Content.fromObject(images.roughness),
			normal = Content.fromObject(normalMap),
		})
		-- Equipping is synchronous. Commit only if yielding preparation is still current.
		if isCurrent() then
			AccessoryUtils.SetDefaultWrapLayerOrder(clone, category)
			AccessoryUtils.EquipLayeredAccessoryOntoWrapTarget(self.modelInfo:GetModel(), clone)
			equipped = true
		end
	end)
	if previewSourceModel then
		previewSourceModel:Destroy()
	end
	if previewMeshPart then
		previewMeshPart:Destroy()
	end
	if not success or not equipped or not isCurrent() then
		local ownsRequest = self.pending[category] == request
		if ownsRequest then
			self.pending[category] = nil
		end
		if usedCache then
			usedCache:EndUse()
		end
		clone:Destroy()
		if previewMesh then
			previewMesh:Destroy()
		end
		if not keepEdits and selection.editModelInfo then
			selection.editModelInfo:Destroy()
		end
		self.equipping = nil
		if not keepEdits and ownsRequest and not self.destroyed and self.editingCategory == editingCategory then
			self:SetEditingCategory(editingCategory)
		end
		if not success then
			warn("PreviewAccessoryTool: could not prepare " .. accessoryName .. ": " .. tostring(err))
		end
		return false
	end
	self.pending[category] = nil

	if keepEdits then
		if previous.accessory then
			previous.accessory:Destroy()
		end
		if previous.previewMesh then
			previous.previewMesh:Destroy()
		end
	else
		self:Unequip(category, true)
	end
	selection.order = if previous then previous.order else #self:GetAccessoryGroups() + 1
	selection.accessory = clone
	selection.previewMesh = previewMesh
	selection.previewShapeRevision = previewShapeRevision
	selection.previewKitbashRevision = previewKitbashRevision
	self.selections[category] = selection
	self.equipping = nil
	if usedCache then
		usedCache:EndUse()
	end
	self:SetVisible(category, selection.group.isVisible)
	self:SyncSelection(category, not keepEdits)
	self:CacheIdleSelection(category)
	return true
end

-- Returns the head or accessory cache and connects its idle and image-change callbacks.
function PreviewAccessoryTool:GetEditingCache(category: string?): TextureInfoCache.TextureInfoCache?
	local selection = category and self.selections[category]
	local cache = if category then selection and selection.editingCache else self.headEditingCache
	if not cache then
		return nil
	end

	-- Retry idle caching after the last operation releases its resources.
	cache.onIdle = function()
		self:CacheIdleSelection(category)
	end
	-- Notify the UI when caching or restoring changes image references.
	cache.onChanged = function()
		if self.onCacheChanged then
			self.onCacheChanged()
		end
	end
	return cache
end

-- Caches an inactive context immediately or on the next deferred task; nil selects the head.
function PreviewAccessoryTool:CacheIdleSelection(category: string?, immediate: boolean?): boolean
	local cache = self:GetEditingCache(category)
	if self.destroyed or not cache then
		return false
	end
	if self.editingCategory == category then
		return true
	end

	-- Equip requests queued behind this switch cannot use its outgoing resources yet.
	-- Checks that this cache still belongs to an inactive selection before releasing its resources.
	local function stillIdle()
		return not self.destroyed
			and self.editingCategory ~= category
			and self:GetEditingCache(category) == cache
			and (not category or not self.pending[category] or self.switchingContext)
	end

	-- Runs idle caching with cancellation checks and reports unexpected failures.
	local function cacheIdle()
		local success, ready = pcall(cache.Cache, cache, stillIdle)
		if not success and stillIdle() then
			warn("Could not cache texture context: " .. tostring(ready))
		end
		return success and ready
	end

	if immediate then
		return cacheIdle()
	end
	task.defer(cacheIdle)
	return true
end

-- Checks that the tool is alive and the requested editing category has not changed.
local function isCurrentEditingCategory(self, category: string?): boolean
	return not self.destroyed and self.editingCategory == category
end

-- Waits for outgoing resources to become idle and caches them before restoring the target.
local function cacheInactiveContexts(self, target: string?): boolean
	local idleCaches = {}
	if target then
		table.insert(idleCaches, { cache = self:GetEditingCache(nil) })
	end
	for category in self.selections do
		if category ~= target then
			table.insert(idleCaches, { category = category, cache = self:GetEditingCache(category) })
		end
	end

	for _, idle in idleCaches do
		-- Wait for pending cache work and operations holding its resources.
		while
			idle.cache
			and (idle.cache.busy or idle.cache.activeUseCount > 0)
			and isCurrentEditingCategory(self, target)
		do
			task.wait()
		end
		if not isCurrentEditingCategory(self, target) then
			return false
		end
		if idle.cache then
			local cached = self:CacheIdleSelection(idle.category, true)
			if not cached then
				return false
			end
		end
	end
	return true
end

-- Disables editing tools, caches outgoing contexts, and restores the latest requested context.
local function switchEditingContext(self): boolean
	while not self.destroyed do
		local target = self.editingCategory
		if self.beforeContextSwitch then
			self.beforeContextSwitch()
		end
		local incoming = self:GetEditingCache(target)
		if incoming then
			incoming:Cancel()
		end

		local cached = cacheInactiveContexts(self, target)
		-- A newer selection takes over this loop after any yielding cache/restore work.
		if not isCurrentEditingCategory(self, target) then
			continue
		end
		if not cached then
			return false
		end
		if incoming then
			local restored = incoming:Rehydrate()
			if not restored then
				return false
			end
		end
		if not isCurrentEditingCategory(self, target) then
			continue
		end
		self.contextReady = true
		return true
	end
	return false
end

-- Requests an editing context and waits for it to be ready, sharing any switch already in progress.
function PreviewAccessoryTool:SetEditingCategory(category: string?): boolean
	if self.destroyed then
		return false
	end
	local changed = self.editingCategory ~= category
	self.editingCategory = category
	while self.equipping and isCurrentEditingCategory(self, category) do
		task.wait()
	end
	if not isCurrentEditingCategory(self, category) then
		return false
	end
	if self.switchingContext then
		while self.switchingContext and isCurrentEditingCategory(self, category) do
			task.wait()
		end
		return isCurrentEditingCategory(self, category) and self.contextReady
	end
	if not changed and self.contextReady then
		return true
	end

	self.switchingContext, self.contextReady = true, false
	local success, result = pcall(switchEditingContext, self)
	self.switchingContext = false
	if not success then
		warn("Could not switch texture context: " .. tostring(result))
	end
	return success and result and isCurrentEditingCategory(self, category)
end

function PreviewAccessoryTool:GetShape(category: string): AccessoryShape.AccessoryShape
	local modelInfo = self.selections[category].editModelInfo
	local meshInfo = getAccessoryMeshInfo(modelInfo)
	return meshInfo.accessoryShape
end

-- Uses the same validated mesh action locally and on the server.
function PreviewAccessoryTool:SetShapeControl(category: string, controlId: string, value: number, historyTool)
	local selection = self.selections[category]
	if not selection then
		return
	end
	local modelInfo = selection.editModelInfo
	if self:GetShape(category).values[controlId] == value then
		return
	end
	local action = ActionUtils.CreateNewAction(ActionUtils.ActionTypes.SetAccessoryShapeControl, {
		targetMeshPartName = modelInfo:GetMeshParts()[1].Name,
		controlId = controlId,
		value = value,
	}, modelInfo)
	if Actions.ExecuteAction(modelInfo, action, nil, historyTool) then
		SendActionToServerEvent:FireServer(action)
	end
end

-- Returns accessory groups in display order.
function PreviewAccessoryTool:GetAccessoryGroups(): { GroupInfo.GroupInfo }
	local groups = {}
	for _, selection in self.selections do
		groups[selection.order] = selection.group
	end
	return groups
end

-- Reorders accessory entries, not groups within a texture.
function PreviewAccessoryTool:MoveAccessoryGroup(groupId: string, direction: number)
	local groups = self:GetAccessoryGroups()
	for index, group in groups do
		if group.name == groupId and groups[index - direction] then
			local other = self.selections[groups[index - direction].makeupAssetType]
			local selection = self.selections[group.makeupAssetType]
			selection.order, other.order = other.order, selection.order
			self:SyncSelection(group.makeupAssetType)
			self:SyncSelection(groups[index - direction].makeupAssetType)
			return
		end
	end
end

-- Restores the accessory's editing context and displays its model in place of the head.
function PreviewAccessoryTool:ShowIsolated(category: string): { BasePart }?
	local selection = self.selections[category]
	if self.destroyed or not selection then
		return nil
	end
	self:ShowOnHead()
	local contextReady = self:SetEditingCategory(category)
	if not contextReady then
		return nil
	end
	self.isolatedCategory = category
	-- Removing the head from Workspace invalidates its prepared makeup projection data.
	self.hiddenHeadTransparency = {}
	for _, descendant in self.modelInfo:GetModel():GetDescendants() do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") then
			self.hiddenHeadTransparency[descendant] = descendant.LocalTransparencyModifier
			descendant.LocalTransparencyModifier = 1
		end
	end
	selection.editModelInfo:GetModel().Parent = workspace
	return self:GetIsolatedParts()
end

function PreviewAccessoryTool:GetIsolatedParts(): { BasePart }?
	local category = self.isolatedCategory
	local selection = category and self.selections[category]
	if not selection then
		return nil
	end

	local parts = {}
	local isolatedModel = selection.editModelInfo and selection.editModelInfo:GetModel()
	if not isolatedModel then
		return nil
	end

	for _, descendant in isolatedModel:GetDescendants() do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
		end
	end
	return parts
end

-- Restores the head preview without discarding accessory edits.
function PreviewAccessoryTool:ShowOnHead()
	table.clear(self.pending)
	local category = self.isolatedCategory
	local selection = category and self.selections[category]
	if selection and selection.editModelInfo then
		selection.editModelInfo:GetModel().Parent = nil
	end

	if self.hiddenHeadTransparency then
		for instance, transparency in self.hiddenHeadTransparency do
			if instance.Parent then
				instance.LocalTransparencyModifier = transparency
			end
		end
	end

	self.hiddenHeadTransparency = nil
	self.isolatedCategory = nil
	for accessoryCategory, accessorySelection in self.selections do
		local editModelInfo = accessorySelection.editModelInfo
		local meshInfo = getAccessoryMeshInfo(editModelInfo)
		if
			accessorySelection.previewShapeRevision ~= meshInfo.accessoryShape.revision
			or accessorySelection.previewKitbashRevision ~= (meshInfo.kitbashRevision or 0)
		then
			task.defer(function()
				if
					not self.destroyed
					and not self.isolatedCategory
					and self.selections[accessoryCategory] == accessorySelection
					and not self.pending[accessoryCategory]
				then
					self:Equip(accessoryCategory, accessorySelection.name)
				end
			end)
		end
	end
end

function PreviewAccessoryTool:SetVisible(category: string, isVisible: boolean)
	local selection = self.selections[category]
	local accessory = selection and selection.accessory
	if accessory then
		for _, descendant in accessory:GetDescendants() do
			if descendant:IsA("BasePart") then
				local transparency = if isVisible then 0 else 1
				if self.hiddenHeadTransparency and self.hiddenHeadTransparency[descendant] ~= nil then
					self.hiddenHeadTransparency[descendant] = transparency
				else
					descendant.LocalTransparencyModifier = transparency
				end
			end
		end
	end
end

-- Rebuild against the current head after reentry or a head swap.
function PreviewAccessoryTool:Refresh()
	for category, selection in self.selections do
		self:Equip(category, selection.name)
	end
end

-- Removes the accessory preview and its editing model.
function PreviewAccessoryTool:Unequip(category: string, replacing: boolean?)
	self.pending[category] = nil
	self.onUnequip(category)
	if self.isolatedCategory == category then
		self:ShowOnHead()
	end
	local selection = self.selections[category]
	if selection then
		if selection.editingCache then
			selection.editingCache:Destroy()
		end
		if not replacing then
			SetAccessoryEditModelEvent:FireServer(category, nil, nil, selection.editModelInfo:GetServerEditRevision())
		end
		if selection.editModelInfo then
			selection.editModelInfo:Destroy()
		end
		if selection.accessory then
			selection.accessory:Destroy()
		end
		if selection.previewMesh then
			selection.previewMesh:Destroy()
		end
		self.selections[category] = nil
		for remainingCategory, remaining in self.selections do
			if not replacing and remaining.order > selection.order then
				remaining.order -= 1
				self:SyncSelection(remainingCategory)
			end
		end
	end
end

-- Removes previews while retaining editing models for reentry.
function PreviewAccessoryTool:Destroy()
	self.destroyed = true
	self.headEditingCache:Cancel()
	self.headEditingCache.onIdle, self.headEditingCache.onChanged = nil, nil
	self:ShowOnHead()
	for category, selection in self.selections do
		if selection.editingCache then
			selection.editingCache:Cancel()
			selection.editingCache.onIdle, selection.editingCache.onChanged = nil, nil
		end
		self.onUnequip(category)
		if selection.accessory then
			selection.accessory:Destroy()
			selection.accessory = nil
		end
		if selection.previewMesh then
			selection.previewMesh:Destroy()
			selection.previewMesh = nil
		end
		selection.previewShapeRevision = nil
		selection.previewKitbashRevision = nil
	end
end

return PreviewAccessoryTool
