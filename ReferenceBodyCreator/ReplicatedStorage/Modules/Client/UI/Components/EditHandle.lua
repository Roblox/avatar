--[[
	Creates the UI handle for moving, rotating, and resizing stickers and
	kitbashing parts. Does not connect functionality; this should be done on the
	tool or component invoking this UI.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))
local IconButton = require(Components:WaitForChild("IconButton"))

local EditHandle = {}
EditHandle.__index = EditHandle

local defaultHandleRadius = StyleConsts.styleTokens.MainHandleDefaultRadius
local scaleDegrees = StyleConsts.styleTokens.ScaleHandlePosDegrees
local rotateDegrees = StyleConsts.styleTokens.RotateHandlePosDegrees

function EditHandle.new()
	local self = {}
	setmetatable(self, EditHandle)

	self.moveHandle = Instance.new("TextButton")
	self.moveHandle.Name = "MoveHandle"
	self.moveHandle.Text = ""
	Utils.AddStyleTag(self.moveHandle, StyleConsts.tags.MainHandle)

	self.rotateHandle = IconButton.createComponentFrame(StyleConsts.icons.Rotate)
	self.rotateHandle.Name = "RotateHandle"
	self.rotateHandle.Parent = self.moveHandle
	Utils.AddStyleTag(self.rotateHandle, StyleConsts.tags.SmallHandle)

	self.scaleHandle = IconButton.createComponentFrame(StyleConsts.icons.Scale)
	self.scaleHandle.Name = "ScaleHandle"
	self.scaleHandle.Parent = self.moveHandle
	Utils.AddStyleTag(self.scaleHandle, StyleConsts.tags.SmallHandle)

	return self
end

function EditHandle:Refresh(screenPos, scale, rotation)
	-- Update move handle
	self.moveHandle.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
	self.moveHandle.Rotation = rotation
	self.moveHandle.Size = UDim2.fromOffset(defaultHandleRadius * scale, defaultHandleRadius * scale)

	local currentHandleRadius = defaultHandleRadius * scale / 2

	-- Update rotate handle
	local rotateRadians = math.rad(rotateDegrees)
	local rotateHandlePos = Vector2.new(math.cos(rotateRadians), -math.sin(rotateRadians)) * currentHandleRadius
	rotateHandlePos = rotateHandlePos + Vector2.new(currentHandleRadius, currentHandleRadius)
	self.rotateHandle.Position = UDim2.fromOffset(rotateHandlePos.X, rotateHandlePos.Y)

	-- Update scale handle
	local scaleRadians = math.rad(scaleDegrees)
	local scaleHandlePos = Vector2.new(math.cos(scaleRadians), -math.sin(scaleRadians)) * currentHandleRadius
	scaleHandlePos = scaleHandlePos + Vector2.new(currentHandleRadius, currentHandleRadius)
	self.scaleHandle.Position = UDim2.fromOffset(scaleHandlePos.X, scaleHandlePos.Y)
end

return EditHandle
