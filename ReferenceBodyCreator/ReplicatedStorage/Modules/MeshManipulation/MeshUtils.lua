local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local EditableManager = require(Modules:WaitForChild("EditableManager"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshTypes = require(MeshManipulation:WaitForChild("MeshTypes"))
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local KitbashData = require(Config:WaitForChild("KitbashData"))

export type MergeKitbashParams = {
	editableManager: EditableManager.EditableManagerClass,
	targetMeshPart: MeshPart,
	targetEditableMesh: EditableMesh,
	targetScaleFactor: Vector3,

	kitbashMeshId: string,
	kitbashTextureId: string,
	kitbashSourcePart: MeshPart?,

	positionMarkerCFrame: CFrame,
	scale: number,
	rotation: number,

	baseTextureLayer: EditableImage?,
	atlasSlot: number?,
	hasDrawnToAtlas: boolean,
	useSkinningTransfer: boolean?,
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

function MeshUtils.RaycastMeshPart(ray: Ray, meshPart: MeshPart): RaycastResult?
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { meshPart }
	return workspace:Raycast(ray.Origin, ray.Direction * Constants.MAX_PAINTING_DISTANCE, raycastParams)
end

export type EditableMeshRaycastResult = {
	triangleId: number?,
	point: Vector3,
	barycentricCoordinate: Vector3?,
	editableMesh: EditableMesh?,
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

-- On a miss, project onto a camera-facing plane and find the closest mesh point.
function MeshUtils.RaycastOrFindNearestSurface(
	ray: Ray,
	editableMeshMap: MeshTypes.EditableMeshMap,
	scaleFactorMap: MeshTypes.ScaleFactorMap,
	planePoint: Vector3,
	planeNormal: Vector3
): EditableMeshRaycastResult?
	local hit = MeshUtils.RaycastAll(ray, editableMeshMap, scaleFactorMap)
	if hit then
		return hit
	end

	local denominator = ray.Direction:Dot(planeNormal)
	if math.abs(denominator) < 1e-6 then
		return nil
	end
	local distanceAlongRay = (planePoint - ray.Origin):Dot(planeNormal) / denominator
	if distanceAlongRay < 0 then
		return nil
	end
	local planeHit = ray.Origin + ray.Direction * distanceAlongRay
	local closestDistance = math.huge
	local closestResult = nil
	for meshPart, editableMesh in editableMeshMap do
		local scaleFactor = scaleFactorMap[meshPart]
		local localPoint = meshPart.CFrame:PointToObjectSpace(planeHit) * scaleFactor
		local triangleId, point, barycentricCoordinate = editableMesh:FindClosestPointOnSurface(localPoint)
		if triangleId then
			local worldPoint = meshPart.CFrame:PointToWorldSpace(point / scaleFactor)
			local distance = (worldPoint - planeHit).Magnitude
			if distance < closestDistance then
				closestDistance = distance
				closestResult = {
					triangleId = triangleId,
					point = point,
					barycentricCoordinate = barycentricCoordinate,
					editableMesh = editableMesh,
					meshPart = meshPart,
					scaleFactor = scaleFactor,
				}
			end
		end
	end
	return closestResult
end

-- Brow/lash add-ons require RBX_Follower; other accessories can use the root.
function MeshUtils.GetKitbashBoneId(editableMesh: EditableMesh, useSkinningTransfer: boolean?): number?
	for _, boneId in editableMesh:GetBones() do
		if useSkinningTransfer then
			if editableMesh:GetBoneName(boneId) == "RBX_Follower" then
				return boneId
			end
		elseif editableMesh:GetBoneParent(boneId) == 0 then
			return boneId
		end
	end
	assert(not useSkinningTransfer, "Brow/lash template is missing the RBX_Follower skinning-transfer bone")
	return nil
end

local function MergeKitbashGeometry(params: MergeKitbashParams, kitbashEditableMesh, skinningBoneId, addedFaceIds)
	local targetEditableMesh = params.targetEditableMesh
	local kitbashToTarget = params.targetMeshPart.CFrame:ToObjectSpace(params.positionMarkerCFrame)
		* CFrame.Angles(0, 0, math.rad(params.rotation or 0))
	local vertexIdMap = {}
	local uvIdMap = {}
	local sourcePositions = {}
	local placementRotation = KitbashData.GetPlacementRotation(params.kitbashSourcePart)
	local bones = if skinningBoneId then { skinningBoneId } else nil
	local weights = { 1 }
	for _, oldVertexId in kitbashEditableMesh:GetVertices() do
		local localPos = placementRotation:VectorToWorldSpace(kitbashEditableMesh:GetPosition(oldVertexId))
		local scaledPos = localPos * params.scale
		local normalizedPos = kitbashToTarget:PointToWorldSpace(scaledPos) * params.targetScaleFactor

		local newVertexId = targetEditableMesh:AddVertex(normalizedPos)
		vertexIdMap[oldVertexId] = newVertexId
		sourcePositions[newVertexId] = localPos

		if skinningBoneId then
			targetEditableMesh:SetVertexBones(newVertexId, bones)
			targetEditableMesh:SetVertexBoneWeights(newVertexId, weights)
		end
	end

	if params.atlasSlot then
		local slotInfo = Constants.ATLAS_SLOTS[params.atlasSlot]
		local slotScale = 1.0 / Constants.ATLAS_GRID_SIZE

		for _, oldUVId in kitbashEditableMesh:GetUVs() do
			local uvCoord = kitbashEditableMesh:GetUV(oldUVId)
			local remappedUV =
				Vector2.new(slotInfo.uOffset + (uvCoord.X * slotScale), slotInfo.vOffset + (uvCoord.Y * slotScale))

			local newUVId = targetEditableMesh:AddUV(remappedUV)
			uvIdMap[oldUVId] = newUVId
		end
	end

	local faceUVs = table.create(3)
	for _, oldFaceId in kitbashEditableMesh:GetFaces() do
		local oldVertices = kitbashEditableMesh:GetFaceVertices(oldFaceId)
		if #oldVertices == 3 then
			local newFaceId = targetEditableMesh:AddTriangle(
				vertexIdMap[oldVertices[1]],
				vertexIdMap[oldVertices[2]],
				vertexIdMap[oldVertices[3]]
			)
			table.insert(addedFaceIds, newFaceId)
			if params.atlasSlot then
				local oldUVs = kitbashEditableMesh:GetFaceUVs(oldFaceId)
				if #oldUVs == 3 then
					for i, oldUVId in oldUVs do
						faceUVs[i] = uvIdMap[oldUVId]
					end
					targetEditableMesh:SetFaceUVs(newFaceId, faceUVs)
				end
			end
		end
	end
	return sourcePositions
end

function MeshUtils.MergeKitbashPiece(params: MergeKitbashParams): ({ number }, { [number]: Vector3 })
	local targetEditableMesh = params.targetEditableMesh
	local skinningBoneId = MeshUtils.GetKitbashBoneId(targetEditableMesh, params.useSkinningTransfer)
	-- Release the source texture before allocating the source mesh.
	if not params.hasDrawnToAtlas and params.atlasSlot and params.baseTextureLayer then
		local atlasSize = params.baseTextureLayer.Size
		local slotInfo = Constants.ATLAS_SLOTS[params.atlasSlot]
		local slotSize = atlasSize / Constants.ATLAS_GRID_SIZE
		local position = Vector2.new(atlasSize.X * slotInfo.uOffset, atlasSize.Y * slotInfo.vOffset)
		if params.kitbashTextureId == "" then
			params.baseTextureLayer:DrawRectangle(
				position,
				slotSize,
				Color3.new(1, 1, 1),
				0,
				Enum.ImageCombineType.Overwrite
			)
		else
			params.editableManager:UseTemporaryImage(Content.fromUri(params.kitbashTextureId), function(kitbashTexture)
				params.baseTextureLayer:DrawImageTransformed(
					position + slotSize / 2,
					slotSize / kitbashTexture.Size,
					0,
					kitbashTexture,
					{ CombineType = Enum.ImageCombineType.Overwrite }
				)
			end)
		end
	end

	local kitbashEditableMesh =
		AssetService:CreateEditableMeshAsync(Content.fromUri(params.kitbashMeshId), { FixedSize = true })
	assert(kitbashEditableMesh, "Could not allocate kitbash mesh")
	local addedFaceIds = {}
	local success, sourcePositions =
		pcall(MergeKitbashGeometry, params, kitbashEditableMesh, skinningBoneId, addedFaceIds)
	kitbashEditableMesh:Destroy()
	if not success then
		for _, faceId in addedFaceIds do
			targetEditableMesh:RemoveFace(faceId)
		end
	end
	targetEditableMesh:RemoveUnused()
	assert(success, sourcePositions)
	local usedVertices = {}
	for _, faceId in addedFaceIds do
		for _, vertexId in targetEditableMesh:GetFaceVertices(faceId) do
			usedVertices[vertexId] = sourcePositions[vertexId]
		end
	end
	return addedFaceIds, usedVertices
end

function MeshUtils.UpdateKitbashVertices(
	mesh,
	sourcePositions,
	markerOffset: CFrame,
	scale: number,
	rotation: number,
	scaleFactor: Vector3
)
	local transform = markerOffset * CFrame.Angles(0, 0, math.rad(rotation))
	for vertexId, position in sourcePositions do
		mesh:SetPosition(vertexId, transform:PointToWorldSpace(position * scale) * scaleFactor)
	end
end

return MeshUtils
