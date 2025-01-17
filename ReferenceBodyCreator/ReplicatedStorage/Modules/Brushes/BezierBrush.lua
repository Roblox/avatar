local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureUtils = require(TextureManipulation:WaitForChild("TextureUtils"))
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))

local Brushes = Modules:WaitForChild("Brushes")
local BrushInfo = require(Brushes:WaitForChild("BrushInfo"))

local MAX_DISCARD_TIME = 1

export type BrushStrokeData = {
	brushSize: number,
	brushColor: Color3,
	brushTransparency: number,
	drawPositions: { Vector2 },
}

local BezierBrush = {}
BezierBrush.__index = BezierBrush

-- Bezier brush constantly redraws the last N points on the painted curve as the user moves the paintbrush.
-- This allows us to have smooth curves that also stick to the tip of the brush.
function BezierBrush.new(targetEditableImage, textureInfo: TextureInfo.TextureInfoClass)
	local self = {}
	setmetatable(self, BezierBrush)

	self.penSize = 10
	self.penColor = Color3.new()
	self.penTransparency = 0

	self.meshPart = nil
	self.textureInfo = textureInfo

	self.targetEditableImage = targetEditableImage

	self.workingEditableTexture = AssetService:CreateEditableImage({
		Size = targetEditableImage.Size,
	})
	self.oldEditableTexture = AssetService:CreateEditableImage({
		Size = targetEditableImage.Size,
	})

	self.lastPenPosition = nil
	self.penDown = false

	self.penTimes = {}
	self.penPositions = {}

	self.drawnCircles = {}

	self.smoothing = 0.25
	self.discardTime = MAX_DISCARD_TIME * self.smoothing

	self.commitBrushStrokeCallback = nil

	return self
end

function BezierBrush:SetColor(newColor)
	self.penColor = newColor
end

function BezierBrush:SetSize(newSize)
	self.penSize = newSize
end

function BezierBrush:SetTransparency(newTransparency)
	self.penTransparency = newTransparency
end

function BezierBrush:SetCurrentMeshPart(meshPart: MeshPart)
	self.meshPart = meshPart
end

function BezierBrush:SetColorBlendType(colorBlendType) end

function BezierBrush:SetAlphaBlendType(alphaBlendType) end

function BezierBrush:SetAllMeshPart(allMeshPart) end

function BezierBrush:GetRequireLocalExecute()
	return true
end

function BezierBrush:SetCommitBrushStrokeCallback(callback)
	self.commitBrushStrokeCallback = callback
end

function BezierBrush:SetSmoothness(newSmoothness)
	self.smoothing = newSmoothness
	self.discardTime = MAX_DISCARD_TIME * self.smoothing
end

-- berenstein polynomial (used in position and derivative functions for brush smoothing)
function BerensteinPolynomial(n: number, i: number, t: number)
	-- factorial function
	local function fact(n: number): number
		if n == 0 then
			return 1
		else
			return n * fact(n - 1)
		end
	end

	-- return
	return (fact(n) / (fact(i) * fact(n - i))) * t ^ i * (1 - t) ^ (n - i)
end

local function CalculatePositionAt(points, t)
	local n = #points

	-- get position at t
	local c_t = Vector2.new(0, 0)
	for i = 1, n do
		local p_i = points[i]
		local B_nit = BerensteinPolynomial(n - 1, i - 1, t)
		c_t += B_nit * p_i
	end
	return c_t
end

function BezierBrush:DrawCircle(position)
	if position.X < 0 or position.Y < 0 then
		return
	end

	if position.x > self.workingEditableTexture.Size.X or position.y > self.workingEditableTexture.Size.Y then
		return
	end

	-- Record this in the drawnCircles table, which makes it easy for us to re-draw on redo.
	table.insert(self.drawnCircles, position)

	self.workingEditableTexture:DrawCircle(
		position,
		self.penSize,
		self.penColor,
		0,
		Enum.ImageCombineType.BlendSourceOver
	)
end

function BezierBrush:DrawBetween(oldPosition, newPosition)
	self:DrawCircle(oldPosition)

	local distBetween = (oldPosition - newPosition).magnitude

	for i = 1, distBetween, math.max(math.floor(self.penSize / 5), 1) do
		local interPosition = oldPosition:Lerp(newPosition, i / distBetween)

		self:DrawCircle(interPosition)
	end

	self:DrawCircle(newPosition)
end

function BezierBrush:RedrawCurve()
	if #self.penPositions == 0 then
		return
	end

	TextureUtils.Clear(self.workingEditableTexture)

	self.drawnCircles = {}

	local prevTextureBuffer =
		self.workingEditableTexture:ReadPixelsBuffer(Vector2.zero, self.workingEditableTexture.Size)

	local lastPosition = self.penPositions[1]
	for i = 1, 100 do
		local newPosition = CalculatePositionAt(self.penPositions, i / 100)

		self:DrawBetween(lastPosition, newPosition)

		lastPosition = newPosition
	end

	local currentRegionMap = self.textureInfo:GetMeshPartRegion(self.meshPart.Name)
	TextureUtils.PerformRegionStencil(currentRegionMap, prevTextureBuffer, self.workingEditableTexture)
end

function BezierBrush:DoMergeDown()
	self.targetEditableImage:DrawImage(Vector2.new(0, 0), self.oldEditableTexture, Enum.ImageCombineType.Overwrite)
	self.targetEditableImage:DrawImage(
		Vector2.new(0, 0),
		self.workingEditableTexture,
		Enum.ImageCombineType.BlendSourceOver
	)
end

function BezierBrush:DoDraw(drawInfo: BrushInfo.DrawInfo, time: number)
	local position = drawInfo.textureDrawPosition
	local alwaysConnect = drawInfo.isVirtualCursorMovement
	if self.lastPenPosition then
		if (self.lastPenPosition - position).magnitude < 3 then
			return
		elseif not alwaysConnect and (self.lastPenPosition - position).magnitude > 50 then
			-- Instead of connecting the two positions (which would draw a long line
			-- across the texture), we want to finish the old stroke and start a new one.
			self:PenUp()
			self:PenDown(drawInfo)
			return
		end
	end

	self.lastPenPosition = position

	table.insert(self.penTimes, time)
	table.insert(self.penPositions, position)

	self:RedrawCurve()

	self:DoMergeDown()

	if time - self.penTimes[1] > self.discardTime then
		self:FinishBrushPreview()

		table.insert(self.penTimes, time)
		table.insert(self.penPositions, position)
	end
end

function BezierBrush:PenDown(drawInfo: BrushInfo.DrawInfo)
	self.penDown = true

	self.oldEditableTexture:DrawImage(Vector2.new(0, 0), self.targetEditableImage, Enum.ImageCombineType.Overwrite)
	self:DoDraw(drawInfo, tick())
end

function BezierBrush:MovePen(drawInfo: BrushInfo.DrawInfo)
	if not self.penDown then
		self:PenDown(drawInfo)
		return
	end

	self:DoDraw(drawInfo, tick())
end

function BezierBrush:PenUp()
	if not self.penDown then
		return
	end
	self.penDown = false

	self:FinishBrushPreview()

	self.lastPenPosition = nil
end

function BezierBrush:FinishBrushPreview()
	-- Change the targetEditableImage to the oldEditableTexture
	self.targetEditableImage:DrawImage(Vector2.new(0, 0), self.oldEditableTexture, Enum.ImageCombineType.Overwrite)

	local newBrushStroke: BrushStrokeData = {
		brushSize = self.penSize,
		brushColor = self.penColor,
		brushTransparency = self.penTransparency,
		drawPositions = {},
	}
	for i, drawPosition in pairs(self.drawnCircles) do
		table.insert(newBrushStroke.drawPositions, drawPosition)
	end

	self.commitBrushStrokeCallback(newBrushStroke)

	self.drawnCircles = {}
	self.penTimes = {}
	self.penPositions = {}

	-- The commit callback has updated the targetEditableImage, so we need to update the oldEditableTexture
	self.oldEditableTexture:DrawImage(Vector2.new(0, 0), self.targetEditableImage, Enum.ImageCombineType.Overwrite)
end

function BezierBrush:Destroy()
	self.workingEditableTexture:Destroy()
	self.oldEditableTexture:Destroy()
end

return BezierBrush
