local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshTypes = require(MeshManipulation:WaitForChild("MeshTypes"))
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

export type MergeKitbashParams = {
	targetMeshPart: MeshPart,
	targetEditableMesh: EditableMesh,
	targetScaleFactor: Vector3,

	kitbashMeshId: string,
	kitbashTextureId: string,

	positionMarkerCFrame: CFrame,
	scale: number,
	rotation: CFrame,

	baseTextureLayer: EditableImage?,
	atlasSlot: number?,
	hasDrawnToAtlas: boolean,
}

local MeshUtils = {}

function MeshUtils.GetVertexPositionsMap(editableMesh: EditableMesh)
	local vertexPositions = {}
	for _, vertexId in editableMesh:GetVertices() do
		vertexPositions[vertexId] = editableMesh:GetPosition(vertexId)
	end

	return vertexPositions
end

function MeshUtils.GetVertexBounds(vertexPositions)
	local minX = 0
	local minY = 0
	local minZ = 0
	local maxX = 0
	local maxY = 0
	local maxZ = 0
	for _, position in pairs(vertexPositions) do
		minX = math.min(minX, position.X)
		minY = math.min(minY, position.Y)
		minZ = math.min(minZ, position.Z)

		maxX = math.max(maxX, position.X)
		maxY = math.max(maxY, position.Y)
		maxZ = math.max(maxZ, position.Z)
	end

	return Vector3.new(minX, minY, minZ), Vector3.new(maxX, maxY, maxZ)
end

-- Converts a mesh coordinate (triangleId + barycentricCoordinate) into a 2d UV coordinate.
-- Useful for mapping points on a EditableMesh to points on a EditableImage.
function MeshUtils.GetTextureCoordinate(editableMesh: EditableMesh, triangleId, barycentricCoordinate)
	local faceUVs = editableMesh:GetFaceUVs(triangleId)
	local uvCoord = (barycentricCoordinate.x * editableMesh:GetUV(faceUVs[1]))
		+ (barycentricCoordinate.y * editableMesh:GetUV(faceUVs[2]))
		+ (barycentricCoordinate.z * editableMesh:GetUV(faceUVs[3]))
	return uvCoord
end

function MeshUtils.GetScaleFactor(meshPart, vertexPositions)
	local min, max = MeshUtils.GetVertexBounds(vertexPositions)
	local editableMeshSize = max - min
	local scaleFactor = editableMeshSize / meshPart.Size
	return scaleFactor
end

function MeshUtils.LocalSpaceToEditableMeshSpace(localSpacePos, meshPart, vertexPositions)
	local meshScaleFactor = MeshUtils.GetScaleFactor(meshPart, vertexPositions)

	local editableMeshObjectSpacePos = localSpacePos * meshScaleFactor
	return editableMeshObjectSpacePos
end

-- Converts a raycast that hits a dynamic mesh from dynamic-mesh space into meshPart space into world space.
function MeshUtils.EditableMeshRaycastToCFrame(
	editableMesh: EditableMesh,
	meshPart,
	hitPoint,
	hitTriangle,
	meshScaleFactor
)
	local vertexNormals = editableMesh:GetFaceNormals(hitTriangle)

	local vertexNormal: Vector3 = (editableMesh:GetNormal(vertexNormals[1]) :: Vector3 + editableMesh:GetNormal(
		vertexNormals[2]
	) :: Vector3 + editableMesh:GetNormal(vertexNormals[3]) :: Vector3).Unit

	local objectSpaceVector = hitPoint / meshScaleFactor -- This is a vector in object space that is correctly scaled but may not be correctly rotated.
	local offset = meshPart.CFrame:VectorToWorldSpace(objectSpaceVector)
	local worldSpaceNormal = meshPart.CFrame:VectorToWorldSpace(vertexNormal)
	local newCFrame = CFrame.new(meshPart.Position + offset, meshPart.Position + offset + worldSpaceNormal)
	return newCFrame
end

export type EditableMeshRaycastResult = {
	triangleId: number,
	point: Vector3,
	barycentricCoordinate: Vector3,
	editableMesh: EditableMesh,
	meshPart: MeshPart,
	scaleFactor: Vector3,
}

function MeshUtils.CastRayFromCamera(
	ray,
	editableMesh: EditableMesh,
	meshPart,
	scaleFactor: Vector3
): (boolean, EditableMeshRaycastResult?)
	-- Convert to object-space coords that will be used by dynamic mesh raycast
	local objectSpaceRayOrigin = meshPart.CFrame:PointToObjectSpace(ray.Origin)
	local objectSpaceRayDirection = meshPart.CFrame:VectorToObjectSpace(ray.Direction).Unit

	-- Scale the coords to match the scale of the dynamic mesh
	objectSpaceRayOrigin = objectSpaceRayOrigin * scaleFactor
	objectSpaceRayDirection = objectSpaceRayDirection * scaleFactor

	local triangleId, hitPoint, barycentricCoordinate =
		editableMesh:RaycastLocal(objectSpaceRayOrigin, objectSpaceRayDirection * 100)
	if not triangleId then
		return false, nil
	end

	local raycastResult: EditableMeshRaycastResult = {
		triangleId = triangleId,
		point = hitPoint,
		worldPoint = meshPart.CFrame:PointToWorldSpace(hitPoint / scaleFactor),
		barycentricCoordinate = barycentricCoordinate,
		editableMesh = editableMesh,
		meshPart = meshPart,
		scaleFactor = scaleFactor,
	}
	return true, raycastResult
end

function MeshUtils.GetVertexPositions(editableMesh: EditableMesh)
	local vertexPositions = {}
	for _, vertexId in editableMesh:GetVertices() do
		vertexPositions[vertexId] = editableMesh:GetPosition(vertexId)
	end
	return vertexPositions
end

-- Raycasts against a set of EditableMeshes and returns the one that was hit first by the raycast (if any).
function MeshUtils.RaycastAll(ray, editableMeshMap: MeshTypes.EditableMeshMap, scaleFactorMap: MeshTypes.ScaleFactorMap)
	local origin = ray.Origin

	local closestDistance = 100000
	local closestResult = nil
	for meshPart, editableMesh in pairs(editableMeshMap) do
		local scaleFactor = scaleFactorMap[meshPart]
		local didHit, result = MeshUtils.CastRayFromCamera(ray, editableMesh, meshPart, scaleFactor)

		if didHit then
			local hitPoint = result.worldPoint
			local distance = (origin - hitPoint).Magnitude
			if distance < closestDistance then
				closestDistance = distance
				result.scaleFactor = scaleFactor
				closestResult = result
			end
		end
	end

	return closestResult
end

--  Combine the kitbash piece with the target MeshPart. This involves the following:
-- 1. Combining geometry via adding vertices/faces
-- 2. Updating our texture atlas with the kitbash piece texture
-- 3. Updating the piece's UVs to map to the atlas texture
function MeshUtils.MergeKitbashPiece(params: MergeKitbashParams): { number }
	local targetMeshPart = params.targetMeshPart
	local targetEditableMesh = params.targetEditableMesh
	local targetScaleFactor = params.targetScaleFactor

	-- Create EditableMesh from kitbash piece
	local kitbashEditableMesh =
		AssetService:CreateEditableMeshAsync(Content.fromUri(params.kitbashMeshId), { FixedSize = false })

	local kitbashVertices = kitbashEditableMesh:GetVertices()
	local kitbashFaces = kitbashEditableMesh:GetFaces()

	-- Get root bone for skinning support
	local rootBoneId = nil
	local bones = targetEditableMesh:GetBones()
	for _, boneId in bones do
		if targetEditableMesh:GetBoneParent(boneId) == 0 then
			rootBoneId = boneId
			break
		end
	end

	-- If this piece has not previously been merged and drawn its texture to the
	-- 2x2 texture atlas, draw the texture to the atlas
	local hasKitbashTexture = params.kitbashTextureId ~= ""
	if hasKitbashTexture and not params.hasDrawnToAtlas and params.atlasSlot and params.baseTextureLayer then
		local atlasSize = params.baseTextureLayer.Size
		local slotInfo = Constants.ATLAS_SLOTS[params.atlasSlot]

		local kitbashTexture = AssetService:CreateEditableImageAsync(Content.fromUri(params.kitbashTextureId))

		-- Calculate scale to fit slot
		local slotSize = atlasSize.X / Constants.ATLAS_GRID_SIZE
		local scaleX = slotSize / kitbashTexture.Size.X
		local scaleY = slotSize / kitbashTexture.Size.Y

		-- Draw to slot
		params.baseTextureLayer:DrawImageTransformed(
			Vector2.new(atlasSize.X * slotInfo.uCenter, atlasSize.Y * slotInfo.vCenter),
			Vector2.new(scaleX, scaleY),
			0,
			kitbashTexture
		)

		kitbashTexture:Destroy()
	end

	local rotationDegrees = params.rotation or 0
	local rotationCFrame = CFrame.Angles(0, 0, math.rad(rotationDegrees))
	local kitbashToWorld = params.positionMarkerCFrame * rotationCFrame
	local vertexIdMap = {}
	local uvIdMap = {}
	local addedFaceIds = {}

	-- Add vertex geometry to target mesh. Set the bones for skinning as well
	for _, oldVertexId in kitbashVertices do
		local localPos = kitbashEditableMesh:GetPosition(oldVertexId)
		local scaledPos = localPos * params.scale
		local worldPos = kitbashToWorld:PointToWorldSpace(scaledPos)
		local targetLocalPos = targetMeshPart.CFrame:PointToObjectSpace(worldPos)
		local normalizedPos = targetLocalPos * targetScaleFactor

		local newVertexId = targetEditableMesh:AddVertex(normalizedPos)
		vertexIdMap[oldVertexId] = newVertexId

		if rootBoneId then
			targetEditableMesh:SetVertexBones(newVertexId, { rootBoneId })
			targetEditableMesh:SetVertexBoneWeights(newVertexId, { 1 })
		end
	end

	-- Copy UVs from kitbash piece and remap them according to the texture atlas
	if hasKitbashTexture and params.atlasSlot then
		local kitbashUVs = kitbashEditableMesh:GetUVs()
		local slotInfo = Constants.ATLAS_SLOTS[params.atlasSlot]
		local slotScale = 1.0 / Constants.ATLAS_GRID_SIZE

		for _, oldUVId in kitbashUVs do
			local uvCoord = kitbashEditableMesh:GetUV(oldUVId)
			local remappedUV =
				Vector2.new(slotInfo.uOffset + (uvCoord.X * slotScale), slotInfo.vOffset + (uvCoord.Y * slotScale))

			local newUVId = targetEditableMesh:AddUV(remappedUV)
			uvIdMap[oldUVId] = newUVId
		end
	end

	-- Copy faces from kitbash piece
	for _, oldFaceId in kitbashFaces do
		local oldVertices = kitbashEditableMesh:GetFaceVertices(oldFaceId)
		local oldUVs = kitbashEditableMesh:GetFaceUVs(oldFaceId)

		local newVertices = {}
		local newUVs = {}

		for i, oldVertexId in oldVertices do
			newVertices[i] = vertexIdMap[oldVertexId]
		end

		if hasKitbashTexture then
			for i, oldUVId in oldUVs do
				newUVs[i] = uvIdMap[oldUVId]
			end
		end

		if #newVertices == 3 then
			local newFaceId = targetEditableMesh:AddTriangle(newVertices[1], newVertices[2], newVertices[3])

			if hasKitbashTexture and #newUVs == 3 then
				targetEditableMesh:SetFaceUVs(newFaceId, newUVs)
			end

			table.insert(addedFaceIds, newFaceId)
		end
	end

	targetEditableMesh:RemoveUnused()
	kitbashEditableMesh:Destroy()

	return addedFaceIds
end

return MeshUtils
