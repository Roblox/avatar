local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadService = game:GetService("GamepadService")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Config = Modules:WaitForChild("Config")
local BlanksData = require(Config:WaitForChild("BlanksData"))

-- deadzone is the distance from the center of the thumbstick that the thumbstick has to move before it registers
local THUMBSTICK_DEADZONE = 0.2
local MAX_ZOOM_SPEED = 10
local MIN_AXIS_THRESHOLD = 0.5
local MAX_STICK_ANGULAR_SPEED = math.rad(140) -- Radians per second

local utils = {}

utils.GetIsProjectionActivated = function()
	return true
end

utils.GetVisualizeServerEdits = function()
	return false
end

utils.GetAspectRatio = function(size: Vector2)
	return size.X / size.Y
end

utils.GetOBBCorners = function(cframe: CFrame, size: Vector3)
	-- Get the OBB corners in world space
	local halfSize = size / 2

	-- Define the local corners of the OBB (relative to part's center)
	local localCorners = {
		Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z),
		Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z),
		Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z),
		Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z),
		Vector3.new(-halfSize.X, halfSize.Y, -halfSize.Z),
		Vector3.new(halfSize.X, halfSize.Y, -halfSize.Z),
		Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z),
		Vector3.new(halfSize.X, halfSize.Y, halfSize.Z),
	}

	-- Apply the CFrame to convert the local corners to world space
	local worldCorners = {}
	for i, corner in ipairs(localCorners) do
		worldCorners[i] = cframe:PointToWorldSpace(corner)
	end

	return worldCorners
end

utils.GetOBBCornersFromMeshPart = function(part: MeshPart)
	return utils.GetOBBCorners(part.CFrame, part.Size)
end

utils.projectToAxis = function(corners, axis)
	local minProjection = math.huge
	local maxProjection = -math.huge

	-- Project each corner of the OBB onto the axis
	for _, corner in ipairs(corners) do
		local projection = corner:Dot(axis)
		minProjection = math.min(minProjection, projection)
		maxProjection = math.max(maxProjection, projection)
	end

	return minProjection, maxProjection
end

utils.TestOBBCollision = function(part1, cframe2: CFrame, size2: Vector3)
	-- Get the corners of the OBBs for part1 and part2
	local corners1 = utils.GetOBBCornersFromMeshPart(part1)
	local corners2 = utils.GetOBBCorners(cframe2, size2)

	-- Get the rotation axes (local X, Y, Z directions of the OBBs)
	local axes = {
		part1.CFrame.RightVector,
		part1.CFrame.UpVector,
		part1.CFrame.LookVector, -- axes of part1
		cframe2.LookVector, -- axes of part2
	}

	-- Check for overlap along each axis
	for _, axis in ipairs(axes) do
		local min1, max1 = utils.projectToAxis(corners1, axis)
		local min2, max2 = utils.projectToAxis(corners2, axis)

		-- If projections do not overlap along this axis, the OBBs do not collide
		if max1 < min2 or max2 < min1 then
			return false -- No collision
		end
	end

	-- If there is no separating axis, the OBBs collide
	return true
end

utils.ClipLineToRectangle = function(P0, P1, xmin, ymin, xmax, ymax)
	-- Parametric line equation: P(t) = P0 + t * (P1 - P0)
	local dx = P1.X - P0.X
	local dy = P1.Y - P0.Y

	-- Define the four boundaries of the rectangle
	local t0, t1 = 0, 1
	local p, q

	-- Clip against the left boundary (xmin)
	p = -dx
	q = P0.X - xmin
	if p == 0 then
		if q < 0 then
			return nil
		end -- line is parallel and outside
	else
		local r = q / p
		if p < 0 then
			if r > t1 then
				return nil
			end
			if r > t0 then
				t0 = r
			end
		else
			if r < t0 then
				return nil
			end
			if r < t1 then
				t1 = r
			end
		end
	end

	-- Clip against the right boundary (xmax)
	p = dx
	q = xmax - P0.X
	if p == 0 then
		if q < 0 then
			return nil
		end
	else
		local r = q / p
		if p < 0 then
			if r > t1 then
				return nil
			end
			if r > t0 then
				t0 = r
			end
		else
			if r < t0 then
				return nil
			end
			if r < t1 then
				t1 = r
			end
		end
	end

	-- Clip against the bottom boundary (ymin)
	p = -dy
	q = P0.Y - ymin
	if p == 0 then
		if q < 0 then
			return nil
		end
	else
		local r = q / p
		if p < 0 then
			if r > t1 then
				return nil
			end
			if r > t0 then
				t0 = r
			end
		else
			if r < t0 then
				return nil
			end
			if r < t1 then
				t1 = r
			end
		end
	end

	-- Clip against the top boundary (ymax)
	p = dy
	q = ymax - P0.Y
	if p == 0 then
		if q < 0 then
			return nil
		end
	else
		local r = q / p
		if p < 0 then
			if r > t1 then
				return nil
			end
			if r > t0 then
				t0 = r
			end
		else
			if r < t0 then
				return nil
			end
			if r < t1 then
				t1 = r
			end
		end
	end

	-- If the line is completely inside, return the clipped segment
	if t0 > t1 then
		return nil
	end

	-- Calculate the clipped points
	local clippedP0 = P0 + (P1 - P0) * t0
	local clippedP1 = P0 + (P1 - P0) * t1

	return clippedP0, clippedP1
end

-- Rotates one 2d point around another 2d point (the pivot)
utils.RotatePoint = function(point, pivot, angleDegrees)
	local pX = point.X
	local pY = point.Y
	local pivotX = pivot.X
	local pivotY = pivot.Y

	local angleRadians = math.rad(angleDegrees)
	local sin = math.sin(angleRadians)
	local cos = math.cos(angleRadians)

	-- Translate point to origin:
	pX = pX - pivotX
	pY = pY - pivotY

	-- Rotate point
	local newX = pX * cos - pY * sin
	local newY = pX * sin + pY * cos

	-- Translate point back:
	newX = newX + pivotX
	newY = newY + pivotY
	return Vector2.new(newX, newY)
end

utils.GetSignedDistanceFromPointToPlane = function(point, planeNormal, planePoint)
	return planeNormal:Dot(point - planePoint)
end

utils.GetClosestPointOnPlane = function(point, planeNormal, planePoint)
	-- First calculate the distance from the point to the plane:
	local distance = utils.GetSignedDistanceFromPointToPlane(point, planeNormal, planePoint)

	distance = distance * -1

	local translationVector = planeNormal.Unit * distance

	return point + translationVector
end

utils.GetClosestPointOn3dLineSegment = function(point, lineStart, lineEnd)
	local lineVector = lineEnd - lineStart
	local length = lineVector.Magnitude
	lineVector = lineVector.Unit

	local v = point - lineStart
	local d = v:Dot(lineVector)
	d = math.clamp(d, 0, length)
	return lineStart + lineVector * d, d / length
end

-- Using Jordan curve theorem -For point inside the polygon
utils.Is2dPointInsidePolygon = function(polygonVerts, point2d)
	local isInside = false -- true if point is inside the polygon else false
	local numVerts = #polygonVerts
	for i = 1, numVerts, 1 do
		local j = i - 1
		if j == 0 then
			j = numVerts
		end

		if
			((polygonVerts[i].Y > point2d.Y) ~= (polygonVerts[j].Y > point2d.Y))
			and (
				point2d.X
				< (polygonVerts[j].X - polygonVerts[i].X)
						* (point2d.Y - polygonVerts[i].Y)
						/ (polygonVerts[j].Y - polygonVerts[i].Y)
					+ polygonVerts[i].X
			)
		then
			isInside = not isInside
		end
	end

	return isInside
end

utils.Is2dPointOnLineSegment = function(point2d, lineStart, lineEnd)
	local crossProduct = (point2d.y - lineStart.y) * (lineEnd.x - lineStart.x)
		- (point2d.x - lineStart.x) * (lineEnd.y - lineStart.y)

	-- compare versus epsilon for floating point values, or != 0 if using integers
	local EPSILON = 1e-3
	if math.abs(crossProduct) > EPSILON then
		return false
	end

	local dotProduct = (point2d.x - lineStart.x) * (lineEnd.x - lineStart.x)
		+ (point2d.y - lineStart.y) * (lineEnd.y - lineStart.y)
	if dotProduct < 0 then
		return false
	end

	local lineLengthSquared = (lineEnd.x - lineStart.x) * (lineEnd.x - lineStart.x)
		+ (lineEnd.y - lineStart.y) * (lineEnd.y - lineStart.y)
	if dotProduct > lineLengthSquared then
		return false
	end

	return true
end

-- For point on Polygon(on edge)
utils.Is2dPointOnEdgeOfPolygon = function(polygonVerts, point2d)
	local numVerts = #polygonVerts
	for i = 1, numVerts, 1 do
		local j = i - 1
		if j == 0 then
			j = numVerts
		end

		if utils.Is2dPointOnLineSegment(point2d, polygonVerts[i], polygonVerts[j]) then
			return true
		end
	end
	return false
end

-- Given a point outside a 2d polygon, find the closest point on one of the sides of the polygon.
utils.Project2dPointToPolygon = function(polygonVerts, point2d)
	local min_dist = 100000
	local numVerts = #polygonVerts
	local closestPoint = Vector2.zero
	for i = 1, numVerts, 1 do
		local closestPointToSide = Vector2.zero
		local j = i - 1
		if j == 0 then
			j = numVerts
		end

		local a = point2d.X - polygonVerts[i].X
		local b = point2d.Y - polygonVerts[i].Y
		local c = polygonVerts[j].x - polygonVerts[i].x
		local d = polygonVerts[j].y - polygonVerts[i].y
		local dot = a * c + b * d
		local len_sq = c * c + d * d
		local cos_theta = dot / len_sq
		if cos_theta < 0 then
			closestPointToSide = Vector2.new(polygonVerts[i].X, polygonVerts[i].Y)
		elseif cos_theta > 1 then
			closestPointToSide = Vector2.new(polygonVerts[j].X, polygonVerts[j].Y)
		else
			closestPointToSide = Vector2.new(polygonVerts[i].X + cos_theta * c, polygonVerts[i].Y + cos_theta * d)
		end

		local dx = point2d.X - closestPointToSide.X
		local dy = point2d.Y - closestPointToSide.Y
		local dist = math.sqrt(dx * dx + dy * dy)
		if dist < min_dist then
			closestPoint = closestPointToSide
			min_dist = dist
		end
	end
	return closestPoint
end

utils.GetClosestPointIn2dPolygon = function(point2d, polygonVerts)
	-- Case 1: Check if point is inside the polygon
	if utils.Is2dPointInsidePolygon(polygonVerts, point2d) then
		return point2d
	end
	-- Case 2: If point is on the edge
	if utils.Is2dPointOnEdgeOfPolygon(polygonVerts, point2d) then
		return point2d
	end
	-- Case 3: When point is outside find the perpendicular projection
	return utils.Project2dPointToPolygon(polygonVerts, point2d)
end

-- point3d and polygonVerts should be coplanar
utils.GetClosestPointIn3dPolygon = function(planeNormal, point3d, polygonVerts)
	-- First, project the point onto the plane
	point3d = utils.GetClosestPointOnPlane(point3d, planeNormal, polygonVerts[1])

	-- Convert the 3d points into 2d points relative to the point
	local polygonVerts2d = {}
	local planeXVector = (polygonVerts[1] - polygonVerts[2]).Unit
	local planeYVector = (planeNormal:Cross(planeXVector)).Unit

	for i, vertPos3d in pairs(polygonVerts) do
		local diff3d = vertPos3d - point3d
		local x2d = diff3d:Dot(planeXVector)
		local y2d = diff3d:Dot(planeYVector)
		polygonVerts2d[i] = Vector2.new(x2d, y2d)
	end

	-- Solve the problem in 2d space (point3d is always (0, 0) in 2d space)
	local closestPoint2d = utils.GetClosestPointIn2dPolygon(Vector2.zero, polygonVerts2d)

	-- Convert back into 3d space
	local closestPoint3d = point3d + planeXVector * closestPoint2d.X + planeYVector * closestPoint2d.Y

	return closestPoint3d
end

utils.WorldSpaceToLocalSpace = function(worldPos, cframe)
	local objectSpacePos = cframe:PointToObjectSpace(worldPos)
	return objectSpacePos
end

utils.DeepCopy = function(tableToCopy)
	if tableToCopy == nil then
		return nil
	end

	local copy = {}
	for k, v in pairs(tableToCopy) do
		if type(v) == "table" then
			copy[k] = utils.DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

utils.GetBlankDataByName = function(blankName): BlanksData.BlankData?
	for _, blankData: BlanksData.BlankData in pairs(BlanksData) do
		if blankData.name == blankName then
			return blankData
		end
	end
	return nil
end

-- Handles thumbstick deadzones for gamepad support
utils.normalizeStickByDeadzone = function(stickVector: Vector2)
	local magnitude = stickVector.Magnitude
	if magnitude < THUMBSTICK_DEADZONE then
		return Vector2.new(0, 0)
	else
		return (magnitude - THUMBSTICK_DEADZONE) / (1 - THUMBSTICK_DEADZONE) * stickVector.Unit
	end
end

utils.rotateAndZoom = function(
	inputObject: InputObject,
	deltaTime: number,
	rotateByDegrees: ((number) -> ())?,
	zoomStraight: ((number) -> ())?
)
	local stickInput = utils.normalizeStickByDeadzone(Vector2.new(inputObject.Position.X, inputObject.Position.Y))
	if stickInput == Vector2.new(0, 0) then
		return
	end

	if rotateByDegrees and math.abs(stickInput.X) > MIN_AXIS_THRESHOLD then
		local radiansToDegrees = 180 / math.pi
		rotateByDegrees(deltaTime * stickInput.X * MAX_STICK_ANGULAR_SPEED * radiansToDegrees)
	end

	if zoomStraight and math.abs(stickInput.Y) > MIN_AXIS_THRESHOLD then
		zoomStraight(deltaTime * -stickInput.Y * MAX_ZOOM_SPEED)
	end
end

local gamepadInputTypes = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
	[Enum.UserInputType.Gamepad5] = true,
	[Enum.UserInputType.Gamepad6] = true,
	[Enum.UserInputType.Gamepad7] = true,
	[Enum.UserInputType.Gamepad8] = true,
}

function utils.isGamepadInputType(userInputType: Enum.UserInputType): boolean
	return userInputType and gamepadInputTypes[userInputType] == true
end

function utils.isVirtualCursor(userInputType: Enum.UserInputType): boolean
	return utils.isGamepadInputType(userInputType) and GamepadService.GamepadCursorEnabled
end

return utils
