--[[
	Creates the UI handle for moving, rotating, and resizing stickers and
	kitbashing parts. Does not connect functionality; this should be done on the
	tool or component invoking this UI.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local IconButton = require(Components:WaitForChild("IconButton"))

local EditHandle = {}
EditHandle.__index = EditHandle

local scaleDegrees = StyleConsts.styleTokens.ScaleHandlePosDegrees
local rotateDegrees = StyleConsts.styleTokens.RotateHandlePosDegrees

function EditHandle.new()
	local self = {}
	setmetatable(self, EditHandle)

	self.moveHandle = Instance.new("TextButton")
	self.moveHandle.Name = "MoveHandle"
	self.moveHandle.Text = ""

	-- We don't use Activated so we disable this to avoid consuming the mouse wheel input
	self.moveHandle.Active = false
	StyleUtils.AddStyleTag(self.moveHandle, StyleConsts.tags.MainHandle)

	self.rotateHandle = IconButton.createComponentFrame(StyleConsts.icons.Rotate)
	self.rotateHandle.Name = "RotateHandle"
	self.rotateHandle.Parent = self.moveHandle
	StyleUtils.AddStyleTag(self.rotateHandle, StyleConsts.tags.SmallHandle)

	self.scaleHandle = IconButton.createComponentFrame(StyleConsts.icons.Scale)
	self.scaleHandle.Name = "ScaleHandle"
	self.scaleHandle.Parent = self.moveHandle
	StyleUtils.AddStyleTag(self.scaleHandle, StyleConsts.tags.SmallHandle)

	return self
end

-- worldPos: Vector3 anchor of the handle in the world
-- worldRadius: the handle's footprint radius in studs
function EditHandle:Refresh(worldPos, worldRadius, rotation)
	local camera = workspace.CurrentCamera
	local screenPos = camera:WorldToScreenPoint(worldPos)
	self.moveHandle.Visible = screenPos.Z > 0
	if not self.moveHandle.Visible then
		return
	end

	-- Offset along the camera's right axis and re-project for on-screen radius in pixels
	local rimPos3d = worldPos + camera.CFrame.RightVector * worldRadius
	local rimScreenPos = camera:WorldToScreenPoint(rimPos3d)
	-- clamp pixel radius to avoid extreme sizes
	local pixelRadius =
		(Vector2.new(rimScreenPos.X, rimScreenPos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
	local radius =
		math.clamp(pixelRadius, StyleConsts.styleTokens.MinHandleRadius, StyleConsts.styleTokens.MaxHandleRadius)

	-- Update move handle
	self.moveHandle.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
	self.moveHandle.Rotation = rotation
	self.moveHandle.Size = UDim2.fromOffset(radius * 2, radius * 2)

	-- Update rotate handle
	local rotateRadians = math.rad(rotateDegrees)
	local rotateHandlePos = Vector2.new(math.cos(rotateRadians), -math.sin(rotateRadians)) * radius
	rotateHandlePos = rotateHandlePos + Vector2.new(radius, radius)
	self.rotateHandle.Position = UDim2.fromOffset(rotateHandlePos.X, rotateHandlePos.Y)

	-- Update scale handle
	local scaleRadians = math.rad(scaleDegrees)
	local scaleHandlePos = Vector2.new(math.cos(scaleRadians), -math.sin(scaleRadians)) * radius
	scaleHandlePos = scaleHandlePos + Vector2.new(radius, radius)
	self.scaleHandle.Position = UDim2.fromOffset(scaleHandlePos.X, scaleHandlePos.Y)
end

return EditHandle
