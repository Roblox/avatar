-- This is a module script that processes actions for editing images. It is used by both the client and the server.
-- Each action is a table with an action type and parameters.
-- In addition to action data, the functions in this module also take an editable image as a parameter.
-- This editable image comes from either the client or server.

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local ActionUtils = require(Modules:WaitForChild("ActionUtils"))
local Utils = require(Modules:WaitForChild("Utils"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureUtils = require(TextureManipulation:WaitForChild("TextureUtils"))
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))

local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

local Brushes = Modules:WaitForChild("Brushes")
local Utils = require(Modules:WaitForChild("Utils"))

local BrushInfo = require(Brushes:WaitForChild("BrushInfo"))
local BrushUtils = require(Brushes:WaitForChild("BrushUtils"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local StickerData = require(Config:WaitForChild("StickerData"))

local ImageEditActions = {}

export type RecolorActionMetadata = {
	color: Color3,
	targetMeshPartName: MeshPart,
	opacity: number?,
	isReflectiveMode: boolean?,
}

local function GetSizeForTextureBuffer(modelInfo, colorMap)
	if not modelInfo:GetKitbashingEnabled() then
		return colorMap.Size
	end

	-- If this creation support kitbashing,
	-- find the target buffer size as the top left
	-- grid entry in the atlas
	return Vector2.new(
		math.floor(colorMap.Size.X / Constants.ATLAS_GRID_SIZE),
		math.floor(colorMap.Size.Y / Constants.ATLAS_GRID_SIZE)
	)
end

local function GetAtlasBaseSize(modelInfo, colorMap: EditableImage)
	-- top-left cell size for accessories; full size otherwise
	local size = GetSizeForTextureBuffer(modelInfo, colorMap)
	return size
end

ImageEditActions.RecolorAction = {
	IsValidAction = function(modelInfo, actionMetaData: RecolorActionMetadata)
		if actionMetaData.color == nil then
			return false
		end

		if not modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName) then
			return false
		end

		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData: RecolorActionMetadata)
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo = modelInfo:GetTextureInfo()
		local colorMap: EditableImage =
			textureInfo:GetOrCreateLayer(targetMeshPart, { layerId = Constants.FABRIC_FILL_LAYER }).color

		colorMap:DrawRectangle(
			Vector2.new(0, 0),
			GetAtlasBaseSize(modelInfo, colorMap),
			actionMetaData.color,
			1 - actionMetaData.opacity,
			Enum.ImageCombineType.Overwrite
		)

		TextureUtils.ApplyPBRMaps(textureInfo, targetMeshPart, actionMetaData.isReflectiveMode)
	end,
}

export type RecolorRegionActionMetadata = {
	color: Color3,
	regionName: string,
	opacity: number?,
	isReflectiveMode: boolean?,
}

export type ApplyPBRToRegionActionMetadata = {
	regionName: string,
	isReflectiveMode: boolean?,
}

local function GetUniqueEditableImages(
	modelInfo: ModelInfo.ModelInfoClass,
	textureInfo: TextureInfo.TextureInfoClass,
	meshPartNames: { string }
)
	local uniqueEditableImages = {}

	for _, meshPartName in pairs(meshPartNames) do
		local meshPart = modelInfo:GetMeshPartByName(meshPartName)
		local colorMap = textureInfo:GetOrCreateLayer(meshPart, { layerId = Constants.FABRIC_FILL_LAYER }).color

		uniqueEditableImages[colorMap] = meshPartName
	end

	return uniqueEditableImages
end

ImageEditActions.RecolorRegionAction = {
	IsValidAction = function(modelInfo, actionMetaData: RecolorRegionActionMetadata)
		if actionMetaData.color == nil or actionMetaData.regionName == nil then
			return false
		end

		local textureInfo: TextureInfo.TextureInfoClass = modelInfo:GetTextureInfo()

		if not textureInfo:HasRegion(actionMetaData.regionName) then
			return false
		end

		return true
	end,
	ExecuteAction = function(modelInfo: ModelInfo.ModelInfoClass, actionMetaData: RecolorRegionActionMetadata)
		local textureInfo: TextureInfo.TextureInfoClass = modelInfo:GetTextureInfo()
		local region: TextureInfo.Region = textureInfo:GetRegion(actionMetaData.regionName)

		local uniqueEditableImages = GetUniqueEditableImages(modelInfo, textureInfo, region.meshPartNames)

		local opacity = if actionMetaData.opacity then actionMetaData.opacity else 1

		if region.regionBuffer then
			assert(region.regionColor, "Region color must be defined if regionBuffer is defined")

			for colorMap: EditableImage, targetMeshPartName in uniqueEditableImages do
				local textureSize = GetSizeForTextureBuffer(modelInfo, colorMap)
				local currentPixelsBuffer = colorMap:ReadPixelsBuffer(Vector2.zero, textureSize)
				local regionPixelsBuffer = region.regionBuffer
				local fillAlphaByte = math.floor(255 * opacity)
				fillAlphaByte = math.clamp(fillAlphaByte, 0, 255)

				if buffer.len(regionPixelsBuffer) == buffer.len(currentPixelsBuffer) then
					TextureUtils.PerformRegionColor(
						currentPixelsBuffer,
						region,
						actionMetaData.color,
						colorMap,
						textureSize,
						fillAlphaByte
					)
				else
					TextureUtils.WriteBufferForLargerRegionMap(
						textureSize,
						regionPixelsBuffer,
						currentPixelsBuffer,
						region.regionColor,
						actionMetaData.color,
						fillAlphaByte
					)
				end

				colorMap:WritePixelsBuffer(Vector2.zero, textureSize, currentPixelsBuffer)
			end

			-- Apply PBR to region: isReflectiveMode determines color of metalness & roughness maps
			TextureUtils.ApplyPBRToRegion(modelInfo, textureInfo, region, actionMetaData.isReflectiveMode)
		else
			for colorMap, _ in uniqueEditableImages do
				local textureSize = GetSizeForTextureBuffer(modelInfo, colorMap)
				colorMap:DrawRectangle(
					Vector2.new(0, 0),
					textureSize,
					actionMetaData.color,
					1 - opacity,
					Enum.ImageCombineType.Overwrite
				)
			end
		end

		TextureUtils.ApplyPBRToRegion(modelInfo, textureInfo, region, actionMetaData.isReflectiveMode)
	end,
}

ImageEditActions.ApplyPBRToRegionAction = {
	IsValidAction = function(modelInfo, actionMetaData: ApplyPBRToRegionActionMetadata)
		if actionMetaData.regionName == nil then
			return false
		end

		local textureInfo: TextureInfo.TextureInfoClass = modelInfo:GetTextureInfo()

		return textureInfo:HasRegion(actionMetaData.regionName)
	end,
	ExecuteAction = function(modelInfo: ModelInfo.ModelInfoClass, actionMetaData: ApplyPBRToRegionActionMetadata)
		local textureInfo: TextureInfo.TextureInfoClass = modelInfo:GetTextureInfo()
		local region: TextureInfo.Region = textureInfo:GetRegion(actionMetaData.regionName)

		TextureUtils.ApplyPBRToRegion(modelInfo, textureInfo, region, actionMetaData.isReflectiveMode)
	end,
}

-- Reads every PBR channel of a layer set into a fresh BufferSet.
local function ReadLayerSetBuffers(layerSet: Constants.EditableImageSet): Constants.BufferSet
	local buffers: Constants.BufferSet = {} :: Constants.BufferSet
	for _, channel in Constants.CHANNEL_NAMES do
		local channelEI = layerSet[channel]
		buffers[channel] = channelEI:ReadPixelsBuffer(Vector2.zero, channelEI.Size)
	end
	return buffers
end

export type ClearBrushActionMetadata = {
	targetMeshPartName: string,
}

ImageEditActions.ClearBrushAction = {
	IsValidAction = function(modelInfo, actionMetaData: ClearBrushActionMetadata)
		if not modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName) then
			return false
		end

		return true
	end,
	ExecuteAction = function(
		modelInfo,
		actionMetaData: ClearBrushActionMetadata,
		useReplayLayer: boolean?,
		historyTool: any?
	)
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo = modelInfo:GetTextureInfo()

		if useReplayLayer then
			-- Replace history checkpoint pixels instead of the live layer.
			local _, replaySizes = textureInfo:GetReplayBuffer()
			assert(replaySizes, "Replay layer information not found")

			local clearedReplayBuffers: Constants.BufferSet = {} :: Constants.BufferSet
			for _, channel in Constants.CHANNEL_NAMES do
				local size = replaySizes[channel]
				clearedReplayBuffers[channel] = buffer.create(size.X * size.Y * 4)
			end
			textureInfo:SetReplayBuffer(clearedReplayBuffers, replaySizes)
			return
		end

		local targetLayerInfo = textureInfo:GetTargetLayerInfo()
		local brushLayers: Constants.EditableImageSet = textureInfo:GetOrCreateLayer(targetMeshPart, targetLayerInfo)
		local preEditBuffers = if historyTool then ReadLayerSetBuffers(brushLayers) else nil

		TextureUtils.Clear(brushLayers.color)
		TextureUtils.Clear(brushLayers.metalness)
		TextureUtils.Clear(brushLayers.roughness)

		if historyTool and preEditBuffers then
			local clearAction = ActionUtils.CreateNewAction(ActionUtils.ActionTypes.ClearBrush, actionMetaData)
			historyTool:addUndoAction(targetMeshPart.Name, targetLayerInfo, clearAction, preEditBuffers)
		end
	end,
}

export type StickerActionMetadata = {
	targetMeshPartName: string,
	stickerLayerNumber: number,
	textureId: string,

	position: Vector2,
	rotation: number,
	scale: number,
}

local function IsAllowedSticker(textureId)
	if not textureId then
		return false
	end

	for _, sticker in StickerData do
		if textureId == sticker.textureId then
			return true
		end
	end

	return false
end

-- Stickers occupy slots 1..MAX_STICKER_LAYERS, the stamp tool uses the reserved STAMP_LAYER_NUMBER
local function IsValidStickerLayerNumber(stickerLayerNumber: number): boolean
	if stickerLayerNumber == Constants.STAMP_LAYER_NUMBER then
		return true
	end
	return stickerLayerNumber >= 1 and stickerLayerNumber <= Constants.MAX_STICKER_LAYERS
end

-- Where a sticker/stamp's layer lives. A stamp previews as a temporary layer inside the selected
-- layer's group so it can sit directly above it; regular stickers use their own reserved layer.
local function GetStickerTargetLayerInfo(textureInfo, actionMetaData)
	if actionMetaData.stickerLayerNumber == Constants.STAMP_LAYER_NUMBER then
		return { groupId = textureInfo:GetTargetLayerInfo().groupId, layerId = Constants.STAMP_LAYER }
	end
	return { layerId = Constants.STICKER_LAYER_PREFIX .. actionMetaData.stickerLayerNumber }
end

local function GetOrCreateStickerLayer(textureInfo, targetMeshPart, actionMetaData): (EditableImage, boolean)
	-- A stamp is inserted directly above the currently-selected layer so it previews in the correct
	-- position; regular stickers just land at the top of their stack.
	local insertAfterLayerName = if actionMetaData.stickerLayerNumber == Constants.STAMP_LAYER_NUMBER
		then textureInfo:GetTargetLayerInfo().layerId
		else nil

	return textureInfo:GetOrCreateLayer(
		targetMeshPart,
		GetStickerTargetLayerInfo(textureInfo, actionMetaData),
		insertAfterLayerName
	)
end

ImageEditActions.StickerAction = {
	IsValidAction = function(modelInfo, actionMetaData: StickerActionMetadata)
		if not actionMetaData.position or not actionMetaData.rotation or not actionMetaData.scale then
			return false
		end

		if not modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName) then
			return false
		end

		if not IsValidStickerLayerNumber(actionMetaData.stickerLayerNumber) then
			return false
		end

		if not IsAllowedSticker(actionMetaData.textureId) then
			return false
		end

		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData: StickerActionMetadata)
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo = modelInfo:GetTextureInfo()
		local layerSet: EditableImage, didCreateLayer: boolean =
			GetOrCreateStickerLayer(textureInfo, targetMeshPart, actionMetaData)

		local stickerLayer: EditableImage = layerSet.color

		if not didCreateLayer then
			TextureUtils.Clear(stickerLayer)
		end

		local stickerTexture = textureInfo:GetOrCreateEditableImageByTextureId(actionMetaData.textureId)
		local currentRegionMap = textureInfo:GetMeshPartRegion(actionMetaData.targetMeshPartName)

		if currentRegionMap == nil then
			local scaleVector = Vector2.new(actionMetaData.scale, actionMetaData.scale) * 0.5
			stickerLayer:DrawImageTransformed(
				actionMetaData.position,
				scaleVector,
				actionMetaData.rotation,
				stickerTexture,
				{
					CombineType = Enum.ImageCombineType.Overwrite,
					SamplingMode = Enum.ResamplerMode.Default,
				}
			)
		else
			local prevStickerBuffer = stickerLayer:ReadPixelsBuffer(Vector2.zero, stickerLayer.Size)

			local scaleVector = Vector2.new(actionMetaData.scale, actionMetaData.scale) * 0.5
			stickerLayer:DrawImageTransformed(
				actionMetaData.position,
				scaleVector,
				actionMetaData.rotation,
				stickerTexture,
				{
					CombineType = Enum.ImageCombineType.Overwrite,
					SamplingMode = Enum.ResamplerMode.Default,
				}
			)

			TextureUtils.PerformRegionStencil(currentRegionMap, prevStickerBuffer, stickerLayer)
		end
	end,
}

export type RemoveStickerActionMetadata = {
	targetMeshPartName: string,
	stickerLayerNumber: number,
}

ImageEditActions.RemoveStickerAction = {
	IsValidAction = function(modelInfo, actionMetaData: RemoveStickerActionMetadata)
		if not IsValidStickerLayerNumber(actionMetaData.stickerLayerNumber) then
			return false
		end

		if not modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName) then
			return false
		end

		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData: RemoveStickerActionMetadata)
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo: TextureInfo.TextureInfoClass = modelInfo:GetTextureInfo()

		local stickerTargetLayerInfo = GetStickerTargetLayerInfo(textureInfo, actionMetaData)

		local stickerLayerSet, _didCreateLayer: boolean =
			textureInfo:GetOrCreateLayer(targetMeshPart, stickerTargetLayerInfo)
		TextureUtils.Clear(stickerLayerSet.color) -- stickers only edit color for now
		textureInfo:RemoveLayer(targetMeshPart, stickerTargetLayerInfo)
	end,
}

export type StampProjection = {
	textureId: string,
	position: Vector3,
	direction: Vector3,
	rotation: number,
	scale: number,
	mirrorPlane: CFrame?,
}

export type BakeStampActionMetadata = {
	targetMeshPartName: string,
	stickerLayerNumber: number,
	-- Present for stamps placed via the stamp tool; enables recording an undo step.
	projection: StampProjection?,
}

-- Merges the stamp layer down into the currently-selected layer and removes the stamp layer.
ImageEditActions.BakeStampAction = {
	IsValidAction = function(modelInfo, actionMetaData: BakeStampActionMetadata)
		if not IsValidStickerLayerNumber(actionMetaData.stickerLayerNumber) then
			return false
		end

		if not modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName) then
			return false
		end

		return true
	end,
	ExecuteAction = function(
		modelInfo,
		actionMetaData: BakeStampActionMetadata,
		useReplayLayer: boolean?,
		historyTool: any?
	)
		assert(not useReplayLayer, "BakeStampAction should not be called with a replay layer")

		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo: TextureInfo.TextureInfoClass = modelInfo:GetTextureInfo()

		local targetLayerInfo = textureInfo:GetTargetLayerInfo()
		local targetLayerSet = textureInfo:GetOrCreateLayer(targetMeshPart, targetLayerInfo)
		-- The stamp previews as a temporary layer inside the selected layer's group.
		local stampLayerInfo = GetStickerTargetLayerInfo(textureInfo, actionMetaData)
		local stampLayerSet = textureInfo:GetOrCreateLayer(targetMeshPart, stampLayerInfo)

		-- Snapshot the pre-bake baseline before the composite mutates the target layer.
		local shouldRecord = historyTool ~= nil and actionMetaData.projection ~= nil
		local preEditBuffers
		if shouldRecord then
			preEditBuffers = ReadLayerSetBuffers(targetLayerSet)
		end

		-- Stamps are color-only decals, matching sticker semantics.
		targetLayerSet.color:DrawImage(Vector2.zero, stampLayerSet.color, Enum.ImageCombineType.BlendSourceOver)

		-- Layer has been stamped and is now useless.
		TextureUtils.Clear(stampLayerSet.color)
		textureInfo:RemoveLayer(targetMeshPart, stampLayerInfo)

		if shouldRecord then
			-- Record the bake as one undo step
			local projection = actionMetaData.projection
			local stampMergeAction = ActionUtils.CreateNewAction(ActionUtils.ActionTypes.StampMerge, {
				targetMeshPartName = actionMetaData.targetMeshPartName,
				textureId = projection.textureId,
				position = projection.position,
				direction = projection.direction,
				rotation = projection.rotation,
				scale = projection.scale,
				mirrorPlane = projection.mirrorPlane,
			})
			historyTool:addUndoAction(
				actionMetaData.targetMeshPartName,
				targetLayerInfo,
				stampMergeAction,
				preEditBuffers
			)
		end
	end,
}

export type StampMergeActionMetadata = StampProjection & {
	targetMeshPartName: string,
}

-- Replay-safe form of a baked stamp for undo/redo: reprojects the stamp decal onto the target
-- layer (color-only, BlendSourceOver — matching how the stamp was drawn). Never networked; each
-- peer builds it locally from the projection params. Supports the checkpoint replay layer like
-- ImageProjectionBrushAction.
ImageEditActions.StampMergeAction = {
	IsValidAction = function(modelInfo, actionMetaData: StampMergeActionMetadata)
		if not actionMetaData.textureId or not actionMetaData.position or not actionMetaData.direction then
			return false
		end
		if not modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName) then
			return false
		end
		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData: StampMergeActionMetadata, useReplayLayer: boolean?)
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo: TextureInfo.TextureInfoClass = modelInfo:GetTextureInfo()

		-- Resolve a dedicated decal image rather than TextureInfo's single-slot sticker cache: that
		-- cache is tuned for live editing and can hand back a nil/destroyed image during replay.
		local stickerTexture = AssetService:CreateEditableImageAsync(Content.fromUri(actionMetaData.textureId))
		assert(stickerTexture, Constants.FAILED_TO_CREATE_EI_MSG)

		local projectionRotater = CFrame.fromAxisAngle(actionMetaData.direction, actionMetaData.rotation)
		local projection = {
			Direction = actionMetaData.direction,
			Position = actionMetaData.position,
			Size = Vector3.one * actionMetaData.scale,
			Up = projectionRotater * Vector3.new(0, 1, 0),
		}
		local localBrushConfig = {
			Decal = stickerTexture,
			ColorBlendType = Enum.ImageCombineType.BlendSourceOver,
			AlphaBlendType = Enum.ImageAlphaType.Default,
			BlendIntensity = 1,
			FadeAngle = Constants.STICKER_FADE_ANGLE,
		}

		local meshInfo = modelInfo:GetMeshInfo()
		local projectionTarget = meshInfo:GetProjectionTarget(targetMeshPart)

		-- Keep makeup stamp depth independent of its width and height.
		if projectionTarget:IsA("WrapTextureTransfer") then
			projection.Size = Vector3.new(actionMetaData.scale, actionMetaData.scale, Constants.MAX_PAINTING_DISTANCE)
		end

		-- Draws the stamp (and its mirror, if any) onto one color EditableImage.
		local function drawOnto(colorImage: EditableImage)
			if actionMetaData.mirrorPlane then
				local mirroredProjection = {
					Direction = Utils.ReflectVectorAcrossPlane(projection.Direction, actionMetaData.mirrorPlane),
					Position = Utils.ReflectPointAcrossPlane(projection.Position, actionMetaData.mirrorPlane),
					Size = projection.Size,
					Up = Utils.ReflectVectorAcrossPlane(projection.Up, actionMetaData.mirrorPlane),
				}
				local mirroredBrushConfig = table.clone(localBrushConfig)
				mirroredBrushConfig.Decal =
					textureInfo:GetOrCreateMirroredStickerImage(actionMetaData.textureId, stickerTexture)
				colorImage:DrawImageProjected(projectionTarget, mirroredProjection, mirroredBrushConfig)
			end
			colorImage:DrawImageProjected(projectionTarget, projection, localBrushConfig)
		end

		if useReplayLayer then
			-- Draw onto the checkpoint replay layer, then write it back
			local replayBufs, replaySizes = textureInfo:GetReplayBuffer()
			assert(replayBufs and replaySizes, "Replay layer information not found")

			local replayImages: Constants.EditableImageSet = {} :: Constants.EditableImageSet
			for _, channel in Constants.CHANNEL_NAMES do
				local replayEI = AssetService:CreateEditableImage({ Size = replaySizes[channel] })
				assert(replayEI, Constants.FAILED_TO_CREATE_EI_MSG)
				replayEI:WritePixelsBuffer(Vector2.zero, replaySizes[channel], replayBufs[channel])
				replayImages[channel] = replayEI
			end

			drawOnto(replayImages.color)

			local newReplayBufs: Constants.BufferSet = {} :: Constants.BufferSet
			local newReplaySizes = {}
			for _, channel in Constants.CHANNEL_NAMES do
				local channelEI = replayImages[channel]
				newReplayBufs[channel] = channelEI:ReadPixelsBuffer(Vector2.zero, channelEI.Size)
				newReplaySizes[channel] = channelEI.Size
				channelEI:Destroy()
			end
			textureInfo:SetReplayBuffer(newReplayBufs, newReplaySizes)
		else
			local targetImages = textureInfo:GetOrCreateLayer(targetMeshPart, textureInfo:GetTargetLayerInfo())
			drawOnto(targetImages.color)
		end

		stickerTexture:Destroy()
	end,
}

export type ProjectedStickerActionMetadata = {
	targetMeshPartName: string,
	textureId: string,
	stickerLayerNumber: number,
	clearTexture: boolean,

	rotation: number,
	scale: number,
	direction: Vector3,
	position: Vector3,
	mirrorPlane: CFrame?,
}

ImageEditActions.ProjectedStickerAction = {
	IsValidAction = function(modelInfo, actionMetaData: ProjectedStickerActionMetadata)
		if
			not actionMetaData.rotation
			or not actionMetaData.scale
			or not actionMetaData.direction
			or not actionMetaData.position
		then
			return false
		end

		if not modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName) then
			return false
		end

		if not IsValidStickerLayerNumber(actionMetaData.stickerLayerNumber) then
			return false
		end

		if not IsAllowedSticker(actionMetaData.textureId) then
			return false
		end

		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData: ProjectedStickerActionMetadata)
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo = modelInfo:GetTextureInfo()
		local layerSet: EditableImage, didCreateLayer: boolean =
			GetOrCreateStickerLayer(textureInfo, targetMeshPart, actionMetaData)

		local stickerLayer: EditableImage = layerSet.color

		if not didCreateLayer and actionMetaData.clearTexture then
			TextureUtils.Clear(stickerLayer)
		end

		local stickerTexture = textureInfo:GetOrCreateEditableImageByTextureId(actionMetaData.textureId)

		local projectionRotater = CFrame.fromAxisAngle(actionMetaData.direction, actionMetaData.rotation)

		local projection: ProjectionParams = {
			Direction = actionMetaData.direction,
			Position = actionMetaData.position,
			Size = Vector3.one * actionMetaData.scale,
			Up = projectionRotater * Vector3.new(0, 1, 0),
		}

		local localBrushConfig: BrushConfig = {
			Decal = stickerTexture,
			ColorBlendType = Enum.ImageCombineType.BlendSourceOver,
			AlphaBlendType = Enum.ImageAlphaType.Default,
			BlendIntensity = 1,
			FadeAngle = Constants.STICKER_FADE_ANGLE,
		}

		local meshInfo = modelInfo:GetMeshInfo()
		local projectionTarget = meshInfo:GetProjectionTarget(targetMeshPart)

		-- Keep makeup stamp depth independent of its width and height.
		if projectionTarget:IsA("WrapTextureTransfer") then
			projection.Size = Vector3.new(actionMetaData.scale, actionMetaData.scale, Constants.MAX_PAINTING_DISTANCE)
		end

		if actionMetaData.mirrorPlane then
			local mirroredProjection: ProjectionParams = {
				Direction = Utils.ReflectVectorAcrossPlane(projection.Direction, actionMetaData.mirrorPlane),
				Position = Utils.ReflectPointAcrossPlane(projection.Position, actionMetaData.mirrorPlane),
				Size = projection.Size,
				Up = Utils.ReflectVectorAcrossPlane(projection.Up, actionMetaData.mirrorPlane),
			}
			local mirroredBrushConfig = table.clone(localBrushConfig)
			mirroredBrushConfig.Decal =
				textureInfo:GetOrCreateMirroredStickerImage(actionMetaData.textureId, stickerTexture)
			stickerLayer:DrawImageProjected(projectionTarget, mirroredProjection, mirroredBrushConfig)
		end

		stickerLayer:DrawImageProjected(projectionTarget, projection, localBrushConfig)
	end,
}

export type TiledStickerActionMetadata = {
	targetMeshPartName: string,
	stickerLayerNumber: number,
	textureId: string,

	texturePosition: Vector2,
	rotation: number,
	scale: number,
	tilePadding: number,

	regionName: string,
}

ImageEditActions.TiledStickerAction = {
	IsValidAction = function(modelInfo, actionMetaData: TiledStickerActionMetadata)
		if
			not actionMetaData.rotation
			or not actionMetaData.scale
			or not actionMetaData.texturePosition
			or not actionMetaData.tilePadding
		then
			return false
		end

		if not modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName) then
			return false
		end

		if not IsValidStickerLayerNumber(actionMetaData.stickerLayerNumber) then
			return false
		end

		if not IsAllowedSticker(actionMetaData.textureId) then
			return false
		end

		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData: TiledStickerActionMetadata)
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo = modelInfo:GetTextureInfo()
		local layerSet: EditableImage, didCreateLayer: boolean =
			GetOrCreateStickerLayer(textureInfo, targetMeshPart, actionMetaData)

		local stickerLayer: EditableImage = layerSet.color
		local isAccessory = modelInfo:GetCreationType() == Constants.CREATION_TYPES.Accessory
		local kitbashingEnabled = modelInfo:GetKitbashingEnabled()

		if not didCreateLayer then
			TextureUtils.Clear(stickerLayer)
		end

		local stickerTexture: EditableImage = textureInfo:GetOrCreateEditableImageByTextureId(actionMetaData.textureId)

		local rotation = actionMetaData.rotation * -(math.pi / 180)

		local normVec = Vector3.new(0, 0, -1)
		local rotator = CFrame.fromAxisAngle(normVec, rotation)
		local upVec3 = rotator * Vector3.new(0, 1, 0)
		local rightVec3 = rotator * Vector3.new(1, 0, 0)

		local globalScale = 0.5

		local clampScale = math.max(
			actionMetaData.scale,
			if isAccessory
				then Constants.DEFAULT_TILED_STICKER_SCALE * Constants.ACCESSORY_STICKER_SCALE
				else Constants.DEFAULT_TILED_STICKER_SCALE
		)
		local upScale = actionMetaData.tilePadding + (clampScale * stickerTexture.Size.Y * globalScale)
		local rightScale = actionMetaData.tilePadding + (clampScale * stickerTexture.Size.X * globalScale)

		local function GetSideLengthFromNormal(pos: Vector2, normal: Vector2, size: Vector2)
			local corners = {}
			corners[1] = Vector2.new(0, 0)
			corners[2] = Vector2.new(0, size.Y)
			corners[3] = Vector2.new(size.X, 0)
			corners[4] = size

			local largest = -math.huge
			local smallest = math.huge
			for iter, cornerPos in pairs(corners) do
				local deltaVec = cornerPos - pos
				local deltaMag = normal:Dot(deltaVec)

				if largest < deltaMag then
					largest = deltaMag
				end
				if smallest > deltaMag then
					smallest = deltaMag
				end
			end
			return smallest, largest
		end

		local upVec = Vector2.new(upVec3.x, upVec3.y) * upScale
		local rightVec = Vector2.new(rightVec3.x, rightVec3.y) * rightScale

		local layerSize = if kitbashingEnabled then stickerLayer.Size / Constants.ATLAS_GRID_SIZE else stickerLayer.Size

		local leftLimit, rightLimit = GetSideLengthFromNormal(actionMetaData.texturePosition, rightVec.Unit, layerSize)
		local upLimit, downLimit = GetSideLengthFromNormal(actionMetaData.texturePosition, upVec.Unit, layerSize)

		leftLimit = math.floor(leftLimit / rightScale) -- - 1
		rightLimit = math.ceil(rightLimit / rightScale) -- + 1

		upLimit = math.floor(upLimit / upScale) -- - 1
		downLimit = math.ceil(downLimit / upScale) -- + 1

		local scaleVector = Vector2.new(clampScale, clampScale) * globalScale

		-- If creation is kitbashable, create a temporary layer to draw the tiled sticker onto that
		-- represents only the cell in the atlas representing the accessory texture

		if kitbashingEnabled then
			local temporaryLayer = AssetService:CreateEditableImage({ Size = layerSize })
			if not temporaryLayer then
				error(Constants.FAILED_TO_CREATE_EI_MSG)
				return
			end

			local prevBuffer = stickerLayer:ReadPixelsBuffer(Vector2.zero, temporaryLayer.Size)

			for yIter = leftLimit, rightLimit do
				for xIter = upLimit, downLimit do
					temporaryLayer:DrawImageTransformed(
						actionMetaData.texturePosition + (yIter * rightVec) + (xIter * upVec),
						scaleVector,
						actionMetaData.rotation,
						stickerTexture,
						{
							CombineType = Enum.ImageCombineType.BlendSourceOver,
							SamplingMode = Enum.ResamplerMode.Default,
						}
					)
				end
			end

			local currentRegion = textureInfo:GetRegion(actionMetaData.regionName)

			TextureUtils.PerformRegionStencil(currentRegion, prevBuffer, temporaryLayer)

			stickerLayer:DrawImage(Vector2.zero, temporaryLayer, Enum.ImageCombineType.Overwrite)

			temporaryLayer:Destroy()
		else
			local prevBuffer = stickerLayer:ReadPixelsBuffer(Vector2.zero, stickerLayer.Size)

			for yIter = leftLimit, rightLimit do
				for xIter = upLimit, downLimit do
					stickerLayer:DrawImageTransformed(
						actionMetaData.texturePosition + (yIter * rightVec) + (xIter * upVec),
						scaleVector,
						actionMetaData.rotation,
						stickerTexture,
						{
							CombineType = Enum.ImageCombineType.BlendSourceOver,
							SamplingMode = Enum.ResamplerMode.Default,
						}
					)
				end
			end

			local currentRegion = textureInfo:GetRegion(actionMetaData.regionName)
			TextureUtils.PerformRegionStencil(currentRegion, prevBuffer, stickerLayer)
		end
	end,
}

export type ClearActionMetadata = {
	targetMeshPartName: string,
}

ImageEditActions.ClearAction = {
	IsValidAction = function(modelInfo, actionMetaData: ClearActionMetadata)
		if not modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName) then
			return false
		end

		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData: ClearActionMetadata)
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo: TextureInfo.TextureInfoClass = modelInfo:GetTextureInfo()

		local colorMap: EditableImage =
			textureInfo:GetOrCreateLayer(targetMeshPart, { layerId = Constants.FABRIC_FILL_LAYER }).color

		colorMap:DrawRectangle(Vector2.new(0, 0), colorMap.Size, Color3.new(), 1.0, Enum.ImageCombineType.Overwrite)

		TextureUtils.ClearPBR(textureInfo, targetMeshPart)

		return colorMap
	end,
}

export type ClearRegionActionMetadata = {
	regionName: string,
}

ImageEditActions.ClearRegionAction = {
	IsValidAction = function(modelInfo, actionMetaData: ClearRegionActionMetadata)
		if actionMetaData.regionName == nil then
			return false
		end

		local textureInfo: TextureInfo.TextureInfoClass = modelInfo:GetTextureInfo()

		if not textureInfo:HasRegion(actionMetaData.regionName) then
			return false
		end

		return true
	end,
	ExecuteAction = function(modelInfo: ModelInfo.ModelInfoClass, actionMetaData: ClearRegionActionMetadata)
		local textureInfo: TextureInfo.TextureInfoClass = modelInfo:GetTextureInfo()
		local region: TextureInfo.Region = textureInfo:GetRegion(actionMetaData.regionName)

		local clearMeshPartName = region.meshPartNames[1]
		local targetMeshPart = modelInfo:GetMeshPartByName(clearMeshPartName)

		local colorMap: EditableImage =
			textureInfo:GetOrCreateLayer(targetMeshPart, { layerId = Constants.FABRIC_FILL_LAYER }).color
		-- The base layer holds the original texture at the fill layer's resolution; clearing a
		-- region restores those original pixels beneath the fabric fill.
		local baseLayer: EditableImage = textureInfo:GetBaseLayer(targetMeshPart)

		if region.regionBuffer then
			assert(region.regionColor, "Region color must be defined if regionBuffer is defined")

			local currentPixelsBuffer = colorMap:ReadPixelsBuffer(Vector2.zero, colorMap.Size)
			local originalBuffer = baseLayer:ReadPixelsBuffer(Vector2.zero, baseLayer.Size)
			local regionPixelsBuffer = region.regionBuffer

			local regionR255 = region.regionColor.r
			local regionG255 = region.regionColor.g
			local regionB255 = region.regionColor.b

			-- Only pixels where the region color matches the region image color are recolored
			for i = 0, buffer.len(currentPixelsBuffer) - 1, 4 do
				if
					buffer.readu8(regionPixelsBuffer, i) == regionR255
					and buffer.readu8(regionPixelsBuffer, i + 1) == regionG255
					and buffer.readu8(regionPixelsBuffer, i + 2) == regionB255
				then
					buffer.writeu8(currentPixelsBuffer, i, buffer.readu8(originalBuffer, i))
					buffer.writeu8(currentPixelsBuffer, i + 1, buffer.readu8(originalBuffer, i + 1))
					buffer.writeu8(currentPixelsBuffer, i + 2, buffer.readu8(originalBuffer, i + 2))
					buffer.writeu8(currentPixelsBuffer, i + 3, buffer.readu8(originalBuffer, i + 3))
				end
			end

			colorMap:WritePixelsBuffer(Vector2.zero, colorMap.Size, currentPixelsBuffer)

			-- Clear PBR for region
			TextureUtils.ApplyPBRToRegion(modelInfo, textureInfo, region, false --[[isReflective]])
		else
			colorMap:DrawImage(Vector2.zero, baseLayer, Enum.ImageCombineType.Overwrite)
			TextureUtils.ClearPBR(textureInfo, targetMeshPart)
		end

		return colorMap
	end,
}

export type ImageProjectionBrushActionMetadata = {
	referenceMeshPartName: string,
	brushId: string,
	brushSettings: { color: Color3?, opacity: number?, isReflective: boolean? },
	brushSize: number,
	cameraCFrame: CFrame,
	drawPositions: { Vector3 },
	isReflectiveMode: boolean?,
	mirrorPlane: CFrame?,
	brushTransparency: number,
	firstBatch: boolean,
	lastBatch: boolean,
	seed: number?,
}

-- Stores relevant information for each stroke that is currently being drawn. The key is the target
-- layer's color EditableImage. surfaceSampleImage is the reused brush-sized native sampling
-- image; nil for non-resampling brushes.
local ActiveStrokes: {
	[EditableImage]: {
		intermediateEIs: Constants.EditableImageSet,
		cachedTargetBuffers: Constants.BufferSet,
		lastStampedPoint: Vector3?,
		surfaceSampleImage: EditableImage?,
	},
} =
	{}

local CompletedStrokePreEdits: { [EditableImage]: Constants.BufferSet } = {}

function ImageEditActions.GetStrokePreEdit(targetLayer: Constants.EditableImageSet): Constants.BufferSet
	local completed = CompletedStrokePreEdits[targetLayer.color]
	if completed then
		CompletedStrokePreEdits[targetLayer.color] = nil
		return completed
	end

	local preEdit: Constants.BufferSet = {}
	for _, channel in Constants.CHANNEL_NAMES do
		local channelEI = targetLayer[channel]
		preEdit[channel] = channelEI:ReadPixelsBuffer(Vector2.zero, channelEI.Size)
	end
	return preEdit
end

ImageEditActions.ImageProjectionBrushAction = {
	IsValidAction = function(modelInfo, actionMetaData: ImageProjectionBrushActionMetadata)
		if not modelInfo:GetMeshPartByName(actionMetaData.referenceMeshPartName) then
			return false
		end
		if #actionMetaData.drawPositions <= 0 then
			return false
		end
		return true
	end,
	ExecuteAction = function(
		modelInfo,
		actionMetaData: ImageProjectionBrushActionMetadata,
		useReplayLayer: boolean?,
		_historyTool,
		brushOverride
	)
		local referenceMeshPart = modelInfo:GetMeshPartByName(actionMetaData.referenceMeshPartName)
		local textureInfo = modelInfo:GetTextureInfo()

		local targetImages: Constants.EditableImageSet
		if useReplayLayer then
			local replayBufs, replaySizes = textureInfo:GetReplayBuffer()
			assert(replayBufs and replaySizes, "Replay layer information not found")
			targetImages = {} :: Constants.EditableImageSet
			for _, channel in Constants.CHANNEL_NAMES do
				local replayEI = AssetService:CreateEditableImage({ Size = replaySizes[channel] })
				assert(replayEI, Constants.FAILED_TO_CREATE_EI_MSG)
				replayEI:WritePixelsBuffer(Vector2.zero, replaySizes[channel], replayBufs[channel])
				targetImages[channel] = replayEI
			end
		else
			local targetLayerInfo = textureInfo:GetTargetLayerInfo()
			targetImages = textureInfo:GetOrCreateLayer(referenceMeshPart, targetLayerInfo)
		end

		-- The color map is a stable EditableImage across batches, so it keys the active stroke.
		local strokeKey = targetImages.color

		-- History supplies isolated brush state while borrowing the existing decal images.
		local brushObject = brushOverride or modelInfo:GetBrushRegistry():GetBrush(actionMetaData.brushId)
		brushObject:applyReplicationSettings(actionMetaData.brushSettings)

		local settings = BrushInfo.ResolveSettings(brushObject:getSettings())
		local state = settings.brushType

		local meshInfo = modelInfo:GetMeshInfo()
		local allProjectionTargets = meshInfo:GetProjectionTargetMap()
		local projectionTarget = allProjectionTargets[referenceMeshPart]

		local cameraCFrame = referenceMeshPart.CFrame:ToWorldSpace(actionMetaData.cameraCFrame)
		local mirrorPlane = if actionMetaData.mirrorPlane
			then referenceMeshPart.CFrame:ToWorldSpace(actionMetaData.mirrorPlane)
			else nil
		local scaledBrushSize = actionMetaData.brushSize
		local stampSpacingFactor = settings.stampSpacingFactor
		local spacing = scaledBrushSize * stampSpacingFactor

		if actionMetaData.firstBatch and actionMetaData.seed then
			brushObject:setSeed(actionMetaData.seed)
		end
		if actionMetaData.firstBatch then
			brushObject:BeginStroke()
		end

		-- Sampling brushes capture the surface beneath each stamp into the brush decal before stamping
		local needsResample = brushObject:RequiresSurfaceSample()

		-- Destroys a stroke's per-channel intermediate images.
		local function destroyIntermediateEIs(intermediateEIs: Constants.EditableImageSet)
			for _, channel in Constants.CHANNEL_NAMES do
				if intermediateEIs[channel] then
					intermediateEIs[channel]:Destroy()
				end
			end
		end

		-- Reuse the stroke's persistent intermediates across batches; create them on the first batch.
		local stroke = ActiveStrokes[strokeKey]
		if actionMetaData.firstBatch or not stroke then
			if stroke then
				-- A previous stroke on this layer never received its final batch; reclaim its EIs.
				destroyIntermediateEIs(stroke.intermediateEIs)
				if stroke.surfaceSampleImage then
					stroke.surfaceSampleImage:Destroy()
					stroke.surfaceSampleImage = nil
				end
			end

			-- One intermediate per channel, matched to the corresponding target channel's size.
			local intermediateEIs = {}
			for _, channel in Constants.CHANNEL_NAMES do
				local intermediateEI = AssetService:CreateEditableImage({ Size = targetImages[channel].Size })
				TextureUtils.Clear(intermediateEI)
				intermediateEIs[channel] = intermediateEI
			end

			local cachedTargetBuffers = {}
			for _, channel in Constants.CHANNEL_NAMES do
				local targetEI = targetImages[channel]
				cachedTargetBuffers[channel] = targetEI:ReadPixelsBuffer(Vector2.zero, targetEI.Size)
			end

			stroke = {
				intermediateEIs = intermediateEIs,
				cachedTargetBuffers = cachedTargetBuffers,
			}
			ActiveStrokes[strokeKey] = stroke
		end

		local intermediateEIs = stroke.intermediateEIs
		local cachedTargetBuffers = stroke.cachedTargetBuffers

		-- Blending writes straight onto the layer (replace); other brushes accumulate on the intermediates.
		local imagesToDrawOn = if state == Constants.STATE_BLENDING then targetImages else intermediateEIs
		local function stampAt(point, brushUp)
			local projectionSettings: BrushUtils.ProjectionBrushSettings = {
				surfacePoint = point,
				cameraDirection = BrushUtils.GetProjectionDirection(projectionTarget, cameraCFrame, point),
				brushUp = brushUp,
				scaledBrushSize = scaledBrushSize,
			}
			local brushConfig = {
				ColorBlendType = settings.colorBlendType,
				AlphaBlendType = settings.alphaBlendType,
				BlendIntensity = 1,
				FadeAngle = 180.0,
			}
			if needsResample then
				if not stroke.surfaceSampleImage then
					local brushSize = Constants.IMAGE_BRUSH_TEXTURE_SIZE
					stroke.surfaceSampleImage =
						AssetService:CreateEditableImage({ Size = Vector2.new(brushSize, brushSize) })
					assert(stroke.surfaceSampleImage, Constants.FAILED_TO_CREATE_EI_MSG)
				end
				BrushUtils.StampResampledBrush(
					allProjectionTargets,
					projectionSettings,
					brushConfig,
					imagesToDrawOn,
					brushObject,
					stroke.surfaceSampleImage,
					targetImages,
					mirrorPlane
				)
			else
				BrushUtils.StampProjectedBrush(
					allProjectionTargets,
					projectionSettings,
					brushConfig,
					imagesToDrawOn,
					brushObject:getBrushEIs(),
					mirrorPlane,
					brushObject:getMirroredBrushEIs()
				)
			end
		end

		-- Stamp along stroke path at `spacing` intervals, carrying the last stamp position across batches
		local lastStampedPoint = stroke.lastStampedPoint
		local startIndex
		if lastStampedPoint == nil then
			-- Stroke start
			lastStampedPoint = referenceMeshPart.CFrame:PointToWorldSpace(actionMetaData.drawPositions[1])
			if actionMetaData.firstBatch and settings.stampOnPenDown ~= false then
				stampAt(lastStampedPoint, cameraCFrame.UpVector)
			end
			startIndex = 2 -- start the walk from the first point, looking at the second point
		else
			startIndex = 1 -- start the walk at the last stamped point, looking at the first point
		end

		for i = startIndex, #actionMetaData.drawPositions do
			local castedPoint = referenceMeshPart.CFrame:PointToWorldSpace(actionMetaData.drawPositions[i])
			lastStampedPoint = BrushUtils.WalkBrushTextureSegment(lastStampedPoint, castedPoint, spacing, stampAt)
		end

		stroke.lastStampedPoint = lastStampedPoint

		-- Composite the whole accumulated stroke onto the pre-stroke target. Non-blending only
		if not needsResample then
			BrushUtils.CompositeBrushStroke(
				targetImages,
				cachedTargetBuffers,
				intermediateEIs,
				state,
				actionMetaData.brushTransparency
			)
		end

		if actionMetaData.lastBatch then
			destroyIntermediateEIs(intermediateEIs)
			if stroke.surfaceSampleImage then
				stroke.surfaceSampleImage:Destroy()
				stroke.surfaceSampleImage = nil
			end
			if not useReplayLayer then
				CompletedStrokePreEdits[strokeKey] = cachedTargetBuffers
			end
			ActiveStrokes[strokeKey] = nil
		end

		if useReplayLayer then
			-- Persist the post-stroke pixels back into the checkpoint (per channel), then release the
			-- throwaway replay images.
			local newReplayBufs: Constants.BufferSet = {} :: Constants.BufferSet
			local newReplaySizes = {}
			for _, channel in Constants.CHANNEL_NAMES do
				local channelEI = targetImages[channel]
				newReplayBufs[channel] = channelEI:ReadPixelsBuffer(Vector2.zero, channelEI.Size)
				newReplaySizes[channel] = channelEI.Size
			end
			textureInfo:SetReplayBuffer(newReplayBufs, newReplaySizes)
			for _, channel in Constants.CHANNEL_NAMES do
				targetImages[channel]:Destroy()
			end
		end
	end,
}

return ImageEditActions
