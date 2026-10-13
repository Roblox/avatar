-- Builds the same standalone eyebrow/eyelash edit model on the client and server.

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ModelInfo = require(Modules:WaitForChild("ModelInfo"))
local AccessoryUtils = require(Modules:WaitForChild("MeshManipulation"):WaitForChild("AccessoryUtils"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local AccessoryShape = require(Modules:WaitForChild("MeshManipulation"):WaitForChild("AccessoryShape"))
local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local GroupInfo = require(TextureManipulation:WaitForChild("GroupInfo"))

local AccessoryEditModel = {}

local CAGE_UV_MATCH_TOLERANCE = 1 / 1024

type BuildOptions = {
	parent: Instance?,
	serverEditTarget: string,
	serverEditRevision: string,
	textureResolution: Vector2,
	previousGroup: GroupInfo.GroupInfo?,
	cacheLayers: boolean?,
	shouldCancelCallback: (() -> boolean)?,
}

-- The on-head solver only uses authored differences between the inner and outer cages.
local function getShapeCageVertices(meshInfo): ({ [number]: boolean }, { [number]: Vector3 })
	local cageInfo = meshInfo.cageInfo
	local cageMesh = cageInfo.cageEditableMesh
	local wrapLayer = meshInfo.meshPart:FindFirstChildWhichIsA("WrapLayer")
	local referenceMesh = AssetService:CreateEditableMeshAsync(wrapLayer.ReferenceMeshContent, { FixedSize = true })
	assert(referenceMesh, "Failed to load accessory reference cage")
	local referencePositions = {}
	for _, faceId in referenceMesh:GetFaces() do
		local faceVertices = referenceMesh:GetFaceVertices(faceId)
		for index, uvId in referenceMesh:GetFaceUVs(faceId) do
			referencePositions[uvId] =
				wrapLayer.ReferenceOrigin:PointToWorldSpace(referenceMesh:GetPosition(faceVertices[index]))
		end
	end
	local referenceBuckets = {}
	for uvId, position in referencePositions do
		local uv = referenceMesh:GetUV(uvId)
		local bucket = math.floor(uv.X / CAGE_UV_MATCH_TOLERANCE)
		referenceBuckets[bucket] = referenceBuckets[bucket] or {}
		table.insert(referenceBuckets[bucket], { uv = uv, position = position })
	end
	referenceMesh:Destroy()

	local vertices = {}
	local referencePositionsByVertex = {}
	for _, faceId in cageMesh:GetFaces() do
		local faceVertices = cageMesh:GetFaceVertices(faceId)
		for index, uvId in cageMesh:GetFaceUVs(faceId) do
			local vertexId = faceVertices[index]
			if vertices[vertexId] then
				continue
			end
			local position = cageInfo.cageOrigin:PointToWorldSpace(cageInfo.initialVertexPositionsMap[vertexId])
			local uv = cageMesh:GetUV(uvId)
			local bucket = math.floor(uv.X / CAGE_UV_MATCH_TOLERANCE)
			local closestReference
			local closestDistance = CAGE_UV_MATCH_TOLERANCE
			for offset = -1, 1 do
				for _, reference in referenceBuckets[bucket + offset] or {} do
					local distance = (reference.uv - uv).Magnitude
					if distance < closestDistance then
						closestDistance = distance
						closestReference = reference
					end
				end
			end
			if closestReference and not position:FuzzyEq(closestReference.position) then
				vertices[vertexId] = true
				referencePositionsByVertex[vertexId] = closestReference.position
			end
		end
	end
	return vertices, referencePositionsByVertex
end

function AccessoryEditModel.Build(
	editableManager,
	template: Accessory,
	targetCFrame: CFrame,
	options: BuildOptions
): ModelInfo.ModelInfoClass?
	local accessory = template:Clone()
	local handle = accessory:FindFirstChildWhichIsA("MeshPart", true)
	if not handle then
		accessory:Destroy()
		return nil
	end

	AccessoryUtils.SetDefaultWrapLayerOrder(accessory, options.serverEditTarget)

	for _, descendant in accessory:GetDescendants() do
		if descendant:IsA("WeldConstraint") or descendant:IsA("Weld") then
			descendant:Destroy()
		end
	end

	handle.Anchored = true
	handle.CFrame = targetCFrame

	local model = Instance.new("Model")
	model.Name = template.Name .. "_Isolated"
	accessory.Parent = model
	model.PrimaryPart = handle
	handle.LocalTransparencyModifier = 1
	model.Parent = options.parent or workspace

	local useAsBlankCanvas = template:GetAttribute("UseAsBlankCanvas") == true
	local blankData = {
		name = template.Name,
		creationType = Constants.CREATION_TYPES.Makeup,
		enableYRotation = true,
		enableKitbashing = true,
		isMakeupAccessory = true,
		textureResolution = options.textureResolution,
		-- Blank canvases allow painting into initially transparent areas.
		preserveBaseTextureAlpha = not useAsBlankCanvas,
		-- Blank canvas guides are excluded from published textures.
		alphaClearBase = RunService:IsServer() and useAsBlankCanvas,
		sourceModel = model,
		initialZOffset = 2,
		regionMapSubParts = {},
		regionMapIndividual = {},
		individualPartsNames = { [handle.Name] = true },
	}

	local modelInfo
	local success, message = pcall(function()
		modelInfo = ModelInfo.new(editableManager, model, blankData)
		modelInfo:SetServerEditTarget(options.serverEditTarget, options.serverEditRevision)
		local textureInfo = modelInfo:GetTextureInfo()
		local part = modelInfo:GetMeshParts()[1]
		local meshInfo = modelInfo:GetMeshInfo():GetModelMeshInfo()[part]
		local affectedVertices, referencePositions = getShapeCageVertices(meshInfo)
		meshInfo.accessoryShape =
			AccessoryShape.new(meshInfo, affectedVertices, options.serverEditTarget, template.Name, referencePositions)
		if meshInfo.accessoryShape.isDeformed then
			modelInfo:GetMeshInfo():MarkMeshPartDirty(part)
		end
		local groupId = options.serverEditTarget .. " 1"
		textureInfo:CreateGroup(part, groupId, options.serverEditTarget)
		local previousGroup = options.previousGroup
		if previousGroup then
			local groupLayers = textureInfo.modelTextureInfo[part].groupLayers
			local group = groupLayers:GetGroup(groupId)
			local cacheReplacementLayers = options.cacheLayers and RunService:IsClient()

			for _, layer in previousGroup.inputLayers do
				local target = { groupId = groupId, layerId = layer.name }
				textureInfo:GetOrCreateLayer(part, target)
				-- Copy settings without compositing blank replacement layers.
				local replacementLayer = group.inputLayers[#group.inputLayers]
				replacementLayer.isVisible = layer.isVisible
				replacementLayer.opacity = layer.opacity or 1
				if cacheReplacementLayers then
					local layersCached = groupLayers:CacheForContext(options.shouldCancelCallback)
					assert(layersCached, "Accessory replacement was cancelled")
				end
			end
			textureInfo:SetGroupVisible(part, groupId, previousGroup.isVisible)
		end
	end)
	if not success then
		if modelInfo then
			modelInfo:Destroy()
		else
			model:Destroy()
		end
		error(message)
	end
	model.Parent = options.parent
	handle.LocalTransparencyModifier = 0
	return modelInfo
end

return AccessoryEditModel
