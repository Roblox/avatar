local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureUtils = require(TextureManipulation:WaitForChild("TextureUtils"))
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))

local ImageEditActions = require(TextureManipulation:WaitForChild("ImageEditActions"))

local Brushes = Modules:WaitForChild("Brushes")
local BrushInfo = require(Brushes:WaitForChild("BrushInfo"))

local LinearBrush = {}
LinearBrush.__index = LinearBrush

function LinearBrush.new(targetEditableImage, textureInfo: TextureInfo.TextureInfoClass)
	local self = {}
	setmetatable(self, LinearBrush)

	self.penSize = 10
	self.penColor = Color3.new()
	self.penTransparency = 0

	self.meshPart = nil
	self.textureInfo = textureInfo

	self.targetEditableImage = targetEditableImage

	self.penDown = false

	self.commitBrushStrokeCallback = nil

	self.drawPositions = {}
	self.lastPenPosition = nil

	return self
end

function LinearBrush:SetColor(newColor)
	self.penColor = newColor
end

function LinearBrush:SetSize(newSize)
	self.penSize = newSize
end

function LinearBrush:SetTransparency(newTransparency)
	self.penTransparency = newTransparency
end

function LinearBrush:SetCurrentMeshPart(meshPart: MeshPart)
	self.meshPart = meshPart
end

function LinearBrush:SetColorBlendType(colorBlendType) end

function LinearBrush:SetAlphaBlendType(alphaBlendType) end

function LinearBrush:SetAllMeshPart(allMeshPart) end

function LinearBrush:GetRequireLocalExecute()
	return false
end

function LinearBrush:SetCommitBrushStrokeCallback(callback)
	self.commitBrushStrokeCallback = callback
end

function LinearBrush:DoDrawAtPosition(newPosition)
	if self.lastPenPosition and (self.lastPenPosition - newPosition).magnitude < 1 then
		return
	end

	if self.lastPenPosition == nil then
		self.lastPenPosition = newPosition
	end

	local currentRegionMap = self.textureInfo:GetMeshPartRegion(self.meshPart.Name)
	local prevBrushBuffer = self.targetEditableImage:ReadPixelsBuffer(Vector2.zero, self.targetEditableImage.Size)
	TextureUtils.DrawCircleBetweenPoints(
		self.lastPenPosition,
		newPosition,
		self.penSize,
		self.penColor,
		self.penTransparency,
		self.targetEditableImage
	)
	TextureUtils.PerformRegionStencil(currentRegionMap, prevBrushBuffer, self.targetEditableImage)

	self.drawPositions[#self.drawPositions + 1] = newPosition
	self.lastPenPosition = newPosition
end

function LinearBrush:PenDown(drawInfo: BrushInfo.DrawInfo)
	self.penDown = true

	self.drawPositions = {}
	self.lastPenPosition = nil

	self:DoDrawAtPosition(drawInfo.textureDrawPosition)
end

function LinearBrush:MovePen(drawInfo: BrushInfo.DrawInfo)
	if not self.penDown then
		self:PenDown(drawInfo)
		return
	end

	local newPosition = drawInfo.textureDrawPosition
	if self.lastPenPosition and (self.lastPenPosition - newPosition).magnitude > 50 then
		-- Instead of connecting the two positions (which would draw a long line
		-- across the texture), we want to finish the old stroke and start a new one.
		self:PenUp()
		self:PenDown(drawInfo)
		return
	end

	self:DoDrawAtPosition(newPosition)
end

function LinearBrush:PenUp()
	if not self.penDown then
		return
	end
	self.penDown = false

	if self.drawPositions == nil or #self.drawPositions == 0 then
		return
	end

	local linearActionMetadata: ImageEditActions.LinearBrushActionMetadata = {
		targetMeshPartName = self.meshPart.Name,
		brushSize = self.penSize,
		brushColor = self.penColor,
		brushTransparency = self.penTransparency,
		drawPositions = self.drawPositions,
	}

	self.drawPositions = {}

	self.commitBrushStrokeCallback(linearActionMetadata)
end

function LinearBrush:Destroy() end

return LinearBrush
