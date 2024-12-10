local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshTypes = require(MeshManipulation:WaitForChild("MeshTypes"))

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
	scaleFactor: number,
}

function MeshUtils.CastRayFromCamera(
	ray,
	editableMesh: EditableMesh,
	meshPart,
	scaleFactor: number
): (boolean, EditableMeshRaycastResult?)
	-- Convert to object-space coords that will be used by dynamic mesh raycast
	local objectSpaceRayOrigin = meshPart.CFrame:PointToObjectSpace(ray.Origin)
	local objectSpaceRayDirection = meshPart.CFrame:VectorToObjectSpace(ray.Direction)

	-- Scale the coords to match the scale of the dynamic mesh
	local meshScaleFactor = scaleFactor
	objectSpaceRayOrigin = objectSpaceRayOrigin * meshScaleFactor
	objectSpaceRayDirection = objectSpaceRayDirection * meshScaleFactor

	local triangleId, hitPoint, barycentricCoordinate =
		editableMesh:RaycastLocal(objectSpaceRayOrigin, objectSpaceRayDirection * 100)
	if not triangleId then
		return false, nil
	end

	local raycastResult: EditableMeshRaycastResult = {
		triangleId = triangleId,
		point = hitPoint,
		worldPoint = meshPart.CFrame:PointToWorldSpace(hitPoint / meshScaleFactor),
		barycentricCoordinate = barycentricCoordinate,
		editableMesh = editableMesh,
		meshPart = meshPart,
		scaleFactor = meshScaleFactor,
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
		local scaleFactor = scaleFactorMap[meshPart].X
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

return MeshUtils
