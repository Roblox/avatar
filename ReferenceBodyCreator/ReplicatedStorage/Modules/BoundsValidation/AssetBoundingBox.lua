-- Bounding Box Helper Class
-- Functions:
--      Extent: returns the size of the bounding box
--      Center: returns the center of the bounding box
--      Expand: grows the bounding to the passed in point if it is outside the box
--      Combine: merges the current bounding box with the passed in bounding box

local AssetBoundingBox = {}
AssetBoundingBox.__index = AssetBoundingBox

function AssetBoundingBox.new()
	return setmetatable({
		lo = Vector3.new(math.huge, math.huge, math.huge),
		hi = Vector3.new(-math.huge, -math.huge, -math.huge),
	}, AssetBoundingBox)
end

function AssetBoundingBox:Extent()
	return self.hi - self.lo
end

function AssetBoundingBox:Center()
	return (self.hi + self.lo) / 2
end

function AssetBoundingBox:Expand(point: Vector3)
	self.lo = Vector3.new(math.min(self.lo.X, point.X), math.min(self.lo.Y, point.Y), math.min(self.lo.Z, point.Z))

	self.hi = Vector3.new(math.max(self.hi.X, point.X), math.max(self.hi.Y, point.Y), math.max(self.hi.Z, point.Z))
end

function AssetBoundingBox:Combine(otherBox)
	self:Expand(otherBox.lo)
	self:Expand(otherBox.hi)
end

export type AssetBoundingBoxClass = typeof(AssetBoundingBox)

return AssetBoundingBox
