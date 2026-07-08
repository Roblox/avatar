local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Utils = require(Modules:WaitForChild("Utils"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")

local TextureUtils = require(TextureManipulation:WaitForChild("TextureUtils"))

local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))

local ImageEditActions = require(TextureManipulation:WaitForChild("ImageEditActions"))

local Brushes = Modules:WaitForChild("Brushes")
local BrushInfo = require(Brushes:WaitForChild("BrushInfo"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local ProjectionBrush = {}
ProjectionBrush.__index = ProjectionBrush

-- Bezier brush constantly redraws the last N points on the painted curve as the user moves the paintbrush.
-- This allows us to have smooth curves that also stick to the tip of the brush.
function ProjectionBrush.new(targetEditableImage, textureInfo: TextureInfo.TextureInfoClass, pbrMaps)
	local self = {}
	setmetatable(self, ProjectionBrush)

	self.penSize = 1
	self.penColor = Color3.new()
	self.penTransparency = 0
	self.isReflectiveMode = false

	self.colorBlendType = Enum.ImageCombineType.BlendSourceOver
	self.alphaBlendType = Enum.ImageAlphaType.Default

	self.currentMeshPart = nil
	self.allMeshPart = nil
	self.textureInfo = textureInfo

	self.targetEditableImage = targetEditableImage
	self.roughnessMap = pbrMaps.roughnessMap
	self.metalnessMap = pbrMaps.metalnessMap
	self.normalMap = pbrMaps.normalMap

	self.penDown = false

	self.drawPositions = {}
	self.drawCamCFrame = nil

	self.commitBrushStrokeCallback = nil

	self.currentState = nil -- whether the brush is in painting or erasing state

	return self
end

function ProjectionBrush:SetColor(newColor)
	self.penColor = newColor
end

function ProjectionBrush:SetTransparency(newTransparency)
	self.penTransparency = newTransparency
end

function ProjectionBrush:SetIsReflective(isReflectiveMode)
	self.isReflectiveMode = isReflectiveMode
end

function ProjectionBrush:SetSize(newSize)
	self.penSize = newSize * 0.01
end

function ProjectionBrush:SetCurrentMeshPart(meshPart: MeshPart)
	self.currentMeshPart = meshPart
end

function ProjectionBrush:SetColorBlendType(colorBlendType)
	self.colorBlendType = colorBlendType
end

function ProjectionBrush:SetAlphaBlendType(alphaBlendType)
	self.alphaBlendType = alphaBlendType
end

function ProjectionBrush:SetAllMeshPart(allMeshPart)
	self.allMeshPart = allMeshPart
end

function ProjectionBrush:SetState(state)
	self.currentState = state
end

function ProjectionBrush:GetRequireLocalExecute()
	return false
end

function ProjectionBrush:SetCommitBrushStrokeCallback(callback)
	self.commitBrushStrokeCallback = callback
end

function ProjectionBrush:DoDraw(drawInfo: BrushInfo.DrawInfo)
	local castedPoint = drawInfo.castedPoint

	if self.lastCastedPoint == nil then
		self.lastCastedPoint = castedPoint
	end

	local sourceAlpha = self.alphaBlendType == Enum.ImageAlphaType.Default and 1.0 or 0.0
	local targetAlpha = self.alphaBlendType == Enum.ImageAlphaType.Default and 0.0 or 1.0

	local projectionBrushCircleTexture, projectionBrushLineTexture, circleBrushConfig, lineBrushConfig
	= TextureUtils.CreateAndSetupProjectionBrushTexturesAndConfigs(sourceAlpha, targetAlpha, self.penColor, self.colorBlendType, self.alphaBlendType)

	local isPainting = self.currentState == Constants.STATE_PAINTING
	local pbrInfo, pbrBrushTextures = TextureUtils.GeneratePBRInfo(
		not isPainting,
		self.isReflectiveMode,
		self.roughnessMap,
		self.metalnessMap,
		self.normalMap
	)

	local cameraCFrame = drawInfo.cameraCFrame
	local cameraDirection = cameraCFrame.LookVector

	local scaledBrushSize = self.penSize

	local pbResult = TextureUtils.GenerateProjectionBrushPoints(self.lastCastedPoint, castedPoint, cameraCFrame, scaledBrushSize)

	local imageToDrawOn = if isPainting then self.intermediateEditableImage else self.targetEditableImage
	for currMeshPart, currEditableMesh in pairs(self.allMeshPart) do
		local collisionTest = Utils.TestOBBCollision(currMeshPart, pbResult.projectorCFrame, pbResult.projectorBrushSize)
		if collisionTest then
			TextureUtils.DrawProjectionBrush(
				cameraDirection,
				currMeshPart,
				currEditableMesh,
				pbResult.castedPointOffSet,
				pbResult.castedCenterPointOffSet,
				scaledBrushSize,
				pbResult.castedDeltaVecLength,
				pbResult.castedUp,
				circleBrushConfig,
				lineBrushConfig,
				imageToDrawOn,
				pbrInfo)
		end
	end

	-- In order to paint with transparency, we paint to an intermediate EI which we then apply the
	-- desired alpha value before drawing it to our target EI. This way we get consistent transparency
	-- across the stroke.
	if isPainting then
		local tempEditableImageBuffer =
			self.intermediateEditableImage:ReadPixelsBuffer(Vector2.zero, self.intermediateEditableImage.Size)
		TextureUtils.ApplyAlpha(self.intermediateEditableImage, 1 - self.penTransparency)
		self.targetEditableImage:WritePixelsBuffer(Vector2.zero, self.targetEditableImage.Size, self.cachedTargetBuffer)
		self.targetEditableImage:DrawImage(Vector2.zero, self.intermediateEditableImage, Enum.ImageCombineType.BlendSourceOver)
		self.intermediateEditableImage:WritePixelsBuffer(Vector2.zero, self.intermediateEditableImage.Size, tempEditableImageBuffer)
	end

	self.lastCastedPoint = castedPoint

	self.drawPositions[#self.drawPositions + 1] = self.currentMeshPart.CFrame:PointToObjectSpace(castedPoint)
	self.drawCamCFrame = self.currentMeshPart.CFrame:ToObjectSpace(cameraCFrame)

	projectionBrushLineTexture:Destroy()
	projectionBrushCircleTexture:Destroy()

	for _, pbrBrushTexture in pairs(pbrBrushTextures) do
		pbrBrushTexture:Destroy()
	end
end

function ProjectionBrush:PenDown(drawInfo: BrushInfo.DrawInfo)
	self.penDown = true

	-- Create an intermediate EI to paint brush strokes on so we can apply desired
	-- transparency cleanly
	self.intermediateEditableImage = AssetService:CreateEditableImage({
		Size = self.targetEditableImage.Size
	})

	-- Store a buffer of the image before editing with this stroke so we can
	-- re-apply the intermediate EI to the target without applying transparency multiple times
	-- throughout the stroke
	self.cachedTargetBuffer = self.targetEditableImage:ReadPixelsBuffer(Vector2.zero, self.targetEditableImage.Size)

	self:DoDraw(drawInfo)
end

function ProjectionBrush:MovePen(drawInfo: BrushInfo.DrawInfo)
	if not self.penDown then
		self:PenDown(drawInfo)
		return
	end

	self:DoDraw(drawInfo)

	-- we batch updates by rate limiting it to 30 edit
	if #self.drawPositions > 30 then
		self:CommitCurrentDrawing()
	end
end

function ProjectionBrush:PenUp()
	if not self.penDown then
		return
	end
	self.penDown = false

	self:CommitCurrentDrawing()

	if self.intermediateEditableImage then
		self.intermediateEditableImage:Destroy()
		self.intermediateEditableImage = nil
	end

	self.cachedTargetBuffer = nil
    self.lastCastedPoint = nil
end

function ProjectionBrush:CommitCurrentDrawing()
	local projectionBrushActionMetadata: ImageEditActions.ProjectionBrushActionMetadata = {
		referenceMeshPartName = self.currentMeshPart.Name,
		brushColor = self.penColor,
		brushSize = self.penSize,
		colorBlendType = self.colorBlendType,
		alphaBlendType = self.alphaBlendType,
		cameraCFrame = self.drawCamCFrame,
		drawPositions = self.drawPositions,
		isReflectiveMode = self.isReflectiveMode,
		brushTransparency = 1 - self.penTransparency,
		intermediateEditableImageBuffer = self.intermediateEditableImage:ReadPixelsBuffer(
			Vector2.zero,
			self.intermediateEditableImage.Size
		),
		cachedTargetImageBuffer = self.cachedTargetBuffer,
	}

	self.drawPositions = {}

	self.commitBrushStrokeCallback(projectionBrushActionMetadata)
end

function ProjectionBrush:Destroy() end

return ProjectionBrush
