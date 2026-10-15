local AssetService = game:GetService("AssetService")

local KitbashSurface = {}
KitbashSurface.__index = KitbashSurface

function KitbashSurface.new(info)
	local self = setmetatable({
		info = info,
		restPositions = {},
		faces = {},
		sourceFaceIds = {},
		revision = -1,
	}, KitbashSurface)
	local success, message = pcall(function()
		local source = info.kitbashEditableMesh
		-- Preserve IDs without allocating a temporary flexible mesh.
		local mesh = assert(
			AssetService:CreateEditableMeshAsync(Content.fromObject(source), { FixedSize = true }),
			"Could not create fixed-size kitbash placement surface"
		)
		self.mesh = mesh

		local excludedFaces = {}
		for _, faceIds in info.kitbashFacesBySlot or {} do
			for _, faceId in faceIds do
				excludedFaces[faceId] = true
			end
		end
		local baseFaceId
		for _, faceId in mesh:GetFaces() do
			if excludedFaces[faceId] then
				continue
			end
			baseFaceId = baseFaceId or faceId
			local corners = mesh:GetFaceVertices(faceId)
			local normals = {}
			local normalIds = mesh:GetFaceNormals(faceId)
			for index, vertexId in corners do
				if not self.restPositions[vertexId] then
					self.restPositions[vertexId] = mesh:GetPosition(vertexId) / info.scaleFactor
				end
				normals[index] = mesh:GetNormal(normalIds[index]) * info.scaleFactor
			end
			self.sourceFaceIds[faceId] = faceId
			self.faces[faceId] = { vertices = corners, normals = normals }
		end
		assert(baseFaceId, "Kitbash placement surface has no base faces")
		-- Fixed-size meshes cannot remove faces. Repoint attached-piece triangles to a base triangle
		-- so raycasts and closest-point queries still hit only the base, with matching barycentrics.
		local baseFace = self.faces[baseFaceId]
		for faceId in excludedFaces do
			mesh:SetFaceVertices(faceId, baseFace.vertices)
			mesh:SetFaceNormals(faceId, mesh:GetFaceNormals(baseFaceId))
			self.sourceFaceIds[faceId] = baseFaceId
		end
		for vertexId, position in self.restPositions do
			mesh:SetPosition(vertexId, position)
		end
	end)
	if not success then
		if self.mesh then
			self:Destroy()
		end

		error(message)
	end

	return self
end

function KitbashSurface:Update()
	local revision = self.info.accessoryShape.revision
	if self.revision == revision then
		return
	end
	-- Forward evaluation preserves source correspondence and avoids baked-mesh recentering.
	-- This runs once per shape revision, never for each pointer movement.
	local positions = {}
	for vertexId, restPosition in self.restPositions do
		local position = positions[restPosition]
		if not position then
			-- An unchanged isolated cage needs no async deformation query.
			position = if self.info.accessoryShape.isDeformed
				then self.info.cageInfo.wrapDeformer:GetDeformedCFrameAsync(CFrame.new(restPosition)).Position
				else restPosition
			positions[restPosition] = position
		end
		self.mesh:SetPosition(vertexId, position)
	end
	self.revision = revision
end

function KitbashSurface:GetAnchor(faceId: number, barycentric: Vector3)
	return { faceId = assert(self.sourceFaceIds[faceId], "Unknown kitbash picking face"), barycentric = barycentric }
end

function KitbashSurface:GetFrames(faceId: number, barycentric: Vector3): (CFrame, CFrame)
	local face = assert(self.faces[faceId], "Unknown kitbash surface face")
	local ids = face.vertices
	local a, b, c = self.restPositions[ids[1]], self.restPositions[ids[2]], self.restPositions[ids[3]]
	local x, y, z = self.mesh:GetPosition(ids[1]), self.mesh:GetPosition(ids[2]), self.mesh:GetPosition(ids[3])
	local restPoint = a * barycentric.X + b * barycentric.Y + c * barycentric.Z
	local point = x * barycentric.X + y * barycentric.Y + z * barycentric.Z
	local normal = face.normals[1] * barycentric.X + face.normals[2] * barycentric.Y + face.normals[3] * barycentric.Z
	local u, v = b - a, c - a
	local restCross = u:Cross(v)
	if normal.Magnitude < 1e-8 then
		normal = if restCross.Magnitude > 1e-8 then restCross else Vector3.zAxis
	end
	local restFrame = CFrame.lookAt(restPoint, restPoint + normal.Unit)
	local du, dv = y - x, z - x
	local deformedCross = du:Cross(dv)
	local up = restFrame.UpVector
	local uu, uv, vv = u:Dot(u), u:Dot(v), v:Dot(v)
	local determinant = uu * vv - uv * uv
	if determinant > 1e-16 and deformedCross.Magnitude > 1e-8 then
		local restNormal, deformedNormal = restCross.Unit, deformedCross.Unit
		-- Preserve authored normals using the inverse transpose of the triangle deformation.
		local displayNormal = (dv:Cross(deformedNormal) * normal:Dot(u) + deformedNormal:Cross(du) * normal:Dot(v))
				/ deformedCross.Magnitude
			+ deformedNormal * normal:Dot(restNormal)
		local tu, tv = up:Dot(u), up:Dot(v)
		up = du * ((tu * vv - tv * uv) / determinant)
			+ dv * ((tv * uu - tu * uv) / determinant)
			+ deformedNormal * up:Dot(restNormal)
		if up.Magnitude > 1e-8 and displayNormal.Magnitude > 1e-8 then
			return restFrame, CFrame.lookAt(point, point + displayNormal.Unit, up.Unit)
		end
	end
	return restFrame, CFrame.new(point) * restFrame.Rotation
end

function KitbashSurface:Destroy()
	self.mesh:Destroy()
end

return KitbashSurface
