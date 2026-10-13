--[[
	Created at the start of each stroke and destroyed at the end. brushObjects are persistent and owned elsewhere.
	
	Strokes are written to an intermediate EI which is composited onto the target using the user-set opacity as a
	max for the transparency added. For live updates we save a pre-edit EI of the target
	(cachedTargetBuffer) and composite the intermediate buffer on that after each change to the
	intermediate buffer.

	Server replay is conducted in ImageEditActions. We batch draw positions and then send stroke data to the 
	server.
]]

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureUtils = require(TextureManipulation:WaitForChild("TextureUtils"))
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))

local Brushes = Modules:WaitForChild("Brushes")
local BrushInfo = require(Brushes:WaitForChild("BrushInfo"))
local BrushUtils = require(Brushes:WaitForChild("BrushUtils"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local ImageProjectionBrush = {}
ImageProjectionBrush.__index = ImageProjectionBrush

function ImageProjectionBrush.new(
	targetEditableImages: Constants.EditableImageSet,
	textureInfo: TextureInfo.TextureInfoClass
)
	local self = {}
	setmetatable(self, ImageProjectionBrush)

	self.targetEditableImages = targetEditableImages
	self.textureInfo = textureInfo

	-- Internal state
	self.penDown = false
	self.firstBatch = true -- must be saved for server replay
	self.batchDrawPositions = {}
	self.strokeDrawPositions = {}
	self.drawCamCFrame = nil

	-- BrushTool-owned data
	self.currentMeshPart = nil
	self.allMeshPart = nil
	self.commitBatchCallback = nil
	self.commitStrokeCallback = nil -- fires once per finished stroke with a full-stroke action, for undo history
	self.brushObject = nil
	self.surfaceSampleImage = nil -- Reusable brush-sized image for native surface sampling.

	-- Brush-owned settings
	self.colorBlendType = nil
	self.alphaBlendType = nil
	self.currentState = nil -- whether the brush is in painting or erasing state
	self.stampSpacingFactor = nil -- proportion of brush size the brush must move before stamping again
	self.stampOnPenDown = nil -- whether to stamp immediately on pen down or wait for a direction

	-- User-controlled settings owned by ImageProjectionBrush
	self.penSize = 1 -- Controlled by the user with size slider
	self.penTransparency = 0 -- Controlled by the user with opacity slider, works as a cap for opacity added (or removed) in a single stroke
	self.isReflectiveMode = false
	self.mirrorPlane = nil

	self.editingCache = textureInfo.editingCache
	if self.editingCache then
		self.editingCache:BeginUse()
	end
	return self
end

function ImageProjectionBrush:SetTransparency(newTransparency)
	self.penTransparency = newTransparency
end

function ImageProjectionBrush:SetSize(newSize)
	self.penSize = newSize * Constants.BRUSH_TO_PEN_SIZE
end

function ImageProjectionBrush:SetCurrentMeshPart(meshPart: MeshPart)
	self.currentMeshPart = meshPart
end

function ImageProjectionBrush:SetAllMeshPart(allMeshPart)
	self.allMeshPart = allMeshPart
end

function ImageProjectionBrush:SetIsReflective(isReflectiveMode)
	self.isReflectiveMode = isReflectiveMode
	self.brushObject:setReflective(isReflectiveMode)
end

function ImageProjectionBrush:SetMirrorPlane(mirrorPlane: CFrame?)
	self.mirrorPlane = mirrorPlane
end

function ImageProjectionBrush:GetRequireLocalExecute()
	return false
end

function ImageProjectionBrush:SetCommitBatchCallback(callback)
	self.commitBatchCallback = callback
end

-- Called once at the end of each stroke with a single action covering the whole stroke.
function ImageProjectionBrush:SetCommitStrokeCallback(callback)
	self.commitStrokeCallback = callback
end

-- Sets the brushObject to a certain brush. Updates brush-owned settings
function ImageProjectionBrush:SetBrush(brushObject)
	self.brushObject = brushObject
	local settings = BrushInfo.ResolveSettings(self.brushObject:getSettings())
	self.colorBlendType = settings.colorBlendType
	self.alphaBlendType = settings.alphaBlendType
	self.currentState = settings.brushType
	self.stampOnPenDown = settings.stampOnPenDown
	self.stampSpacingFactor = settings.stampSpacingFactor
	self.brushObject:setReflective(self.isReflectiveMode)
end

-- Stamps at the set interval between the last draw point and the current draw point
function ImageProjectionBrush:Draw(drawInfo)
	if not self.brushObject then
		return
	end

	local castedPoint = drawInfo.castedPoint

	local isFirstStamp = self.lastStampedPoint == nil
	if isFirstStamp then
		self.lastStampedPoint = castedPoint
	end

	local dist = (castedPoint - self.lastStampedPoint).Magnitude
	local spacing = self.penSize * self.stampSpacingFactor

	if not isFirstStamp and dist < spacing then -- ignore if the brush hasn't moved enough to do anything
		return
	end

	local cameraCFrame = drawInfo.cameraCFrame
	local projectionTarget = self.allMeshPart[self.currentMeshPart]
	local scaledBrushSize = self.penSize
	-- We edit the targetEditableImage directly when blending
	local imagesToDrawOn = if self.currentState == Constants.STATE_BLENDING
		then self.targetEditableImages
		else self.intermediateEIs

	local stampPoint = self.lastStampedPoint

	local function stampAt(point, brushUp)
		local projectionSettings: BrushUtils.ProjectionBrushSettings = {
			surfacePoint = point,
			cameraDirection = BrushUtils.GetProjectionDirection(projectionTarget, cameraCFrame, point),
			brushUp = brushUp,
			scaledBrushSize = scaledBrushSize,
		}
		local brushConfig = {
			ColorBlendType = self.colorBlendType,
			AlphaBlendType = self.alphaBlendType,
			BlendIntensity = 1,
			FadeAngle = 180.0,
		}
		if self.brushObject:RequiresSurfaceSample() then
			if not self.surfaceSampleImage then
				local brushSize = Constants.IMAGE_BRUSH_TEXTURE_SIZE
				self.surfaceSampleImage = AssetService:CreateEditableImage({ Size = Vector2.new(brushSize, brushSize) })
				assert(self.surfaceSampleImage, Constants.FAILED_TO_CREATE_EI_MSG)
			end
			BrushUtils.StampResampledBrush(
				self.allMeshPart,
				projectionSettings,
				brushConfig,
				imagesToDrawOn,
				self.brushObject,
				self.surfaceSampleImage,
				self.targetEditableImages,
				self.mirrorPlane
			)
		else
			BrushUtils.StampProjectedBrush(
				self.allMeshPart,
				projectionSettings,
				brushConfig,
				imagesToDrawOn,
				self.brushObject:getBrushEIs(),
				self.mirrorPlane,
				self.brushObject:getMirroredBrushEIs()
			)
		end
	end

	if isFirstStamp then -- First touch of the stroke: stamp iff stampOnPenDown
		if self.stampOnPenDown then
			stampAt(castedPoint, cameraCFrame.UpVector)
		end
	else -- Otherwise walk towards new casted point, stamping every spacing
		stampPoint = BrushUtils.WalkBrushTextureSegment(self.lastStampedPoint, castedPoint, spacing, stampAt)
	end

	self.lastStampedPoint = stampPoint

	-- Update live preview
	BrushUtils.CompositeBrushStroke(
		self.targetEditableImages,
		self.cachedTargetBuffers,
		self.intermediateEIs,
		self.currentState,
		1 - self.penTransparency
	)

	self.batchDrawPositions[#self.batchDrawPositions + 1] = self.currentMeshPart.CFrame:PointToObjectSpace(castedPoint)
	self.strokeDrawPositions[#self.strokeDrawPositions + 1] =
		self.currentMeshPart.CFrame:PointToObjectSpace(castedPoint)
	self.drawCamCFrame = self.currentMeshPart.CFrame:ToObjectSpace(cameraCFrame)
end

-- Initialize intermediate EI and cached target EI, draw first point if necessary
function ImageProjectionBrush:PenDown(drawInfo: BrushInfo.DrawInfo)
	self.penDown = true
	-- Moving off the model ends a stroke, but the same projection brush can resume on re-entry.
	self.firstBatch = true
	self.batchDrawPositions = {}
	self.strokeDrawPositions = {}

	if self.brushObject then
		self.brushObject:BeginStroke()
	end

	self.intermediateEIs = {}
	for _, channel in Constants.CHANNEL_NAMES do
		local intermediateEI = AssetService:CreateEditableImage({
			Size = self.targetEditableImages[channel].Size,
		})
		TextureUtils.Clear(intermediateEI)
		self.intermediateEIs[channel] = intermediateEI
	end

	self.cachedTargetBuffers = {}
	for _, channel in Constants.CHANNEL_NAMES do
		local targetEI = self.targetEditableImages[channel]
		self.cachedTargetBuffers[channel] = targetEI:ReadPixelsBuffer(Vector2.zero, targetEI.Size)
	end

	if self.brushObject.setSeed then
		self.brushObject:setSeed()
	end

	self:Draw(drawInfo)
end

function ImageProjectionBrush:MovePen(drawInfo: BrushInfo.DrawInfo)
	if not self.penDown then
		self:PenDown(drawInfo)
		return
	end

	self:Draw(drawInfo)

	-- send data to the server in batches
	if #self.batchDrawPositions > Constants.DRAW_POSITION_BATCH_SIZE then
		self:CommitCurrentDrawing()
	end
end

-- Reset when the pen is raised
function ImageProjectionBrush:PenUp()
	if not self.penDown then
		return
	end
	self.penDown = false

	self:CommitCurrentDrawing()

	if self.intermediateEIs then
		for _, channel in Constants.CHANNEL_NAMES do
			if self.intermediateEIs[channel] then
				self.intermediateEIs[channel]:Destroy()
				self.intermediateEIs[channel] = nil
			end
		end
	end

	self.cachedTargetBuffers = nil
	self.lastStampedPoint = nil
end

-- Send the current batch of draw positions to the server
function ImageProjectionBrush:CommitCurrentDrawing()
	if #self.batchDrawPositions == 0 then
		return
	end

	-- We send the brush id + its replicable settings (color, opacity) Brush-owned settings (blend
	-- types, brush type, stamp spacing, stamp-on-pen-down) are derived server-side from that brush.
	local actionMetadata = {
		referenceMeshPartName = self.currentMeshPart.Name,
		brushId = self.brushObject.BrushId,
		brushSettings = self.brushObject:getReplicationSettings(),
		brushSize = self.penSize,
		cameraCFrame = self.drawCamCFrame,
		drawPositions = self.batchDrawPositions,
		isReflectiveMode = self.isReflectiveMode,
		mirrorPlane = if self.mirrorPlane then self.currentMeshPart.CFrame:ToObjectSpace(self.mirrorPlane) else nil,
		brushTransparency = 1 - self.penTransparency,
		firstBatch = self.firstBatch,
		lastBatch = not self.penDown, -- Server destroys its intermediate EI at the end of the stroke
		seed = if self.brushObject.getSeed then self.brushObject:getSeed() else nil,
	}

	self.firstBatch = false

	-- Carry the final point into the next batch so the server can interpolate across the batch boundary
	local lastPosition = self.batchDrawPositions[#self.batchDrawPositions]

	-- Emit one whole-stroke action for undo history. Before the final batch so the server can grab
	-- the still-active stroke's pre-edit pixels before that batch tears it down.
	if not self.penDown and self.commitStrokeCallback then
		self.commitStrokeCallback({
			referenceMeshPartName = self.currentMeshPart.Name,
			brushId = self.brushObject.BrushId,
			brushSettings = self.brushObject:getReplicationSettings(),
			brushSize = self.penSize,
			cameraCFrame = self.drawCamCFrame,
			drawPositions = self.strokeDrawPositions,
			isReflectiveMode = self.isReflectiveMode,
			mirrorPlane = if self.mirrorPlane then self.currentMeshPart.CFrame:ToObjectSpace(self.mirrorPlane) else nil,
			brushTransparency = 1 - self.penTransparency,
			firstBatch = true,
			lastBatch = true,
			seed = if self.brushObject.getSeed then self.brushObject:getSeed() else nil,
		}, self.cachedTargetBuffers)
	end

	self.commitBatchCallback(actionMetadata)
	self.batchDrawPositions = if self.penDown then { lastPosition } else {}
end

function ImageProjectionBrush:Destroy()
	if self.intermediateEIs then
		for _, channel in Constants.CHANNEL_NAMES do
			if self.intermediateEIs[channel] then
				self.intermediateEIs[channel]:Destroy()
				self.intermediateEIs[channel] = nil
			end
		end
	end

	if self.surfaceSampleImage then
		self.surfaceSampleImage:Destroy()
		self.surfaceSampleImage = nil
	end

	-- brushObject is borrowed; the owner is responsible for destroying it.
	self.brushObject = nil
	if self.editingCache then
		self.editingCache:EndUse()
		self.editingCache = nil
	end
end

return ImageProjectionBrush
