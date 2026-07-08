-- This is a module script that processes actions for editing images. It is used by both the client and the server.
-- Each action is a table with an action type and parameters.
-- In addition to action data, the functions in this module also take an editable image as a parameter.
-- This editable image comes from either the client or server.

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Utils = require(Modules:WaitForChild("Utils"))
local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureUtils = require(TextureManipulation:WaitForChild("TextureUtils"))
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))

local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

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
		local colorMap: EditableImage = textureInfo:GetOrCreateLayer(targetMeshPart, Constants.FABRIC_FILL_LAYER)

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
		local colorMap = textureInfo:GetOrCreateLayer(meshPart, Constants.FABRIC_FILL_LAYER)

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

		TextureUtils.ApplyPBRToRegion(
			modelInfo,
			textureInfo,
			region,
			actionMetaData.isReflectiveMode
		)
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

export type BrushStrokeActionMetadata = {
	targetMeshPartName: string,
	brushSize: number,
	brushColor: Color3,
	brushTransparency: number,
	drawPositions: { Vector2 },
}

ImageEditActions.BrushStrokeAction = {
	IsValidAction = function(modelInfo, actionMetaData: BrushStrokeActionMetadata)
		if
			not actionMetaData.brushSize
			or not actionMetaData.brushColor
			or not actionMetaData.brushTransparency
			or not actionMetaData.drawPositions
		then
			return false
		end

		if
			actionMetaData.brushSize < Constants.MIN_BRUSH_SIZE
			or actionMetaData.brushSize > Constants.MAX_BRUSH_SIZE
		then
			return false
		end

		if actionMetaData.brushTransparency < 0 or actionMetaData.brushTransparency > 1 then
			return false
		end

		if not modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName) then
			return false
		end

		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData: BrushStrokeActionMetadata)
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo = modelInfo:GetTextureInfo()
		local brushLayer: EditableImage = textureInfo:GetOrCreateLayer(targetMeshPart, Constants.BRUSH_LAYER)

		local brushSize = actionMetaData.brushSize
		local color = actionMetaData.brushColor
		local transparency = actionMetaData.brushTransparency

		local prevBrushBuffer = brushLayer:ReadPixelsBuffer(Vector2.zero, brushLayer.Size)

		for i, drawPosition in pairs(actionMetaData.drawPositions) do
			brushLayer:DrawCircle(drawPosition, brushSize, color, transparency, Enum.ImageCombineType.BlendSourceOver)
		end

		local currentRegionMap = textureInfo:GetMeshPartRegion(actionMetaData.targetMeshPartName)
		TextureUtils.PerformRegionStencil(currentRegionMap, prevBrushBuffer, brushLayer)
	end,
}

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
	ExecuteAction = function(modelInfo, actionMetaData: ClearBrushActionMetadata)
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo = modelInfo:GetTextureInfo()
		local brushLayer: EditableImage = textureInfo:GetOrCreateLayer(targetMeshPart, Constants.BRUSH_LAYER)

		TextureUtils.Clear(brushLayer)
		TextureUtils.ClearPBR(textureInfo, targetMeshPart)
	end,
}

export type LinearBrushActionMetadata = {
	targetMeshPartName: string,
	brushSize: number,
	brushColor: Color3,
	brushTransparency: number,
	drawPositions: { Vector2 },
}

ImageEditActions.LinearBrushAction = {
	IsValidAction = function(modelInfo, actionMetaData: LinearBrushActionMetadata)
		if not actionMetaData.brushSize or not actionMetaData.drawPositions then
			return false
		end

		if
			actionMetaData.brushSize < Constants.MIN_BRUSH_SIZE
			or actionMetaData.brushSize > Constants.MAX_BRUSH_SIZE
		then
			return false
		end

		if not modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName) then
			return false
		end

		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData: LinearBrushActionMetadata)
		local targetMeshPart = modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName)
		local textureInfo = modelInfo:GetTextureInfo()
		local brushLayer: EditableImage = textureInfo:GetOrCreateLayer(targetMeshPart, Constants.BRUSH_LAYER)

		local prevBrushBuffer = brushLayer:ReadPixelsBuffer(Vector2.zero, brushLayer.Size)

		local prevDrawPosition = #actionMetaData.drawPositions > 0 and actionMetaData.drawPositions[1] or nil
		for i, drawPosition in pairs(actionMetaData.drawPositions) do
			TextureUtils.DrawCircleBetweenPoints(
				prevDrawPosition,
				drawPosition,
				actionMetaData.brushSize,
				actionMetaData.brushColor,
				actionMetaData.brushTransparency,
				brushLayer
			)
			prevDrawPosition = drawPosition
		end

		local currentRegionMap = textureInfo:GetMeshPartRegion(actionMetaData.targetMeshPartName)
		TextureUtils.PerformRegionStencil(currentRegionMap, prevBrushBuffer, brushLayer)
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

ImageEditActions.StickerAction = {
	IsValidAction = function(modelInfo, actionMetaData: StickerActionMetadata)
		if not actionMetaData.position or not actionMetaData.rotation or not actionMetaData.scale then
			return false
		end

		if not modelInfo:GetMeshPartByName(actionMetaData.targetMeshPartName) then
			return false
		end

		if actionMetaData.stickerLayerNumber < 1 then
			return false
		end

		if actionMetaData.stickerLayerNumber > Constants.MAX_STICKER_LAYERS then
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
		local stickerLayer: EditableImage, didCreateLayer: boolean = textureInfo:GetOrCreateLayer(
			targetMeshPart,
			Constants.STICKER_LAYER_PREFIX .. actionMetaData.stickerLayerNumber
		)

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
		if actionMetaData.stickerLayerNumber < 1 then
			return false
		end

		if actionMetaData.stickerLayerNumber > Constants.MAX_STICKER_LAYERS then
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

		local stickerLayerName = Constants.STICKER_LAYER_PREFIX .. actionMetaData.stickerLayerNumber

		local stickerLayer: EditableImage, _didCreateLayer: boolean =
			textureInfo:GetOrCreateLayer(targetMeshPart, stickerLayerName)
		TextureUtils.Clear(stickerLayer)
		textureInfo:RemoveLayer(targetMeshPart, stickerLayerName)
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

		if actionMetaData.stickerLayerNumber < 1 then
			return false
		end

		if actionMetaData.stickerLayerNumber > Constants.MAX_STICKER_LAYERS then
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
		local stickerLayer: EditableImage, didCreateLayer: boolean = textureInfo:GetOrCreateLayer(
			targetMeshPart,
			Constants.STICKER_LAYER_PREFIX .. actionMetaData.stickerLayerNumber
		)

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
			FadeAngle = 45.0,
		}

		local meshInfo = modelInfo:GetMeshInfo()
		local editableMesh = meshInfo:GetEditableMesh(targetMeshPart)

		stickerLayer:DrawImageProjected(editableMesh, projection, localBrushConfig)
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

		if actionMetaData.stickerLayerNumber < 1 then
			return false
		end

		if actionMetaData.stickerLayerNumber > Constants.MAX_STICKER_LAYERS then
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
		local stickerLayer: EditableImage, didCreateLayer: boolean = textureInfo:GetOrCreateLayer(
			targetMeshPart,
			Constants.STICKER_LAYER_PREFIX .. actionMetaData.stickerLayerNumber
		)
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

		local colorMap: EditableImage = textureInfo:GetOrCreateLayer(targetMeshPart, Constants.FABRIC_FILL_LAYER)

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

		local colorMap: EditableImage = textureInfo:GetOrCreateLayer(targetMeshPart, Constants.FABRIC_FILL_LAYER)

		if region.regionBuffer then
			assert(region.regionColor, "Region color must be defined if regionBuffer is defined")

			local currentPixelsBuffer = colorMap:ReadPixelsBuffer(Vector2.zero, colorMap.Size)
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
			colorMap:DrawImage(Vector2.zero, originalEditableImage, Enum.ImageCombineType.Overwrite)
			TextureUtils.ClearPBR(textureInfo, targetMeshPart)
		end

		return colorMap
	end,
}

export type ProjectionBrushActionMetadata = {
	referenceMeshPartName: string,
	brushColor: Color3,
	brushSize: number,
	colorBlendType: Enum.ImageCombineType,
	alphaBlendType: Enum.ImageAlphaType,
	cameraCFrame: CFrame,
	drawPositions: { Vector2 },
	isReflectiveMode: boolean?,
	brushTransparency: number?,
	intermediateEditableImageBuffer: buffer,
	cachedTargetImageBuffer: buffer
}

ImageEditActions.ProjectionBrushAction = {
	IsValidAction = function(modelInfo, actionMetaData: ProjectionBrushActionMetadata)
		if not actionMetaData.brushColor then
			return false
		end

		if not modelInfo:GetMeshPartByName(actionMetaData.referenceMeshPartName) then
			return false
		end

		if #actionMetaData.drawPositions <= 0 then
			return false
		end

		return true
	end,
	ExecuteAction = function(modelInfo, actionMetaData: ProjectionBrushActionMetadata)
		local referenceMeshPart = modelInfo:GetMeshPartByName(actionMetaData.referenceMeshPartName)
		local textureInfo = modelInfo:GetTextureInfo()
		local targetLayer: EditableImage = textureInfo:GetOrCreateLayer(referenceMeshPart, Constants.BRUSH_LAYER)
		local isErasing = actionMetaData.alphaBlendType ~= Enum.ImageAlphaType.Default

		local intermediateEditableImage = nil
		local imageToDrawOn = targetLayer
		if not isErasing then
			intermediateEditableImage = textureInfo:GetMemorySafeEditableImage(nil, targetLayer.Size)
			intermediateEditableImage:WritePixelsBuffer(Vector2.zero, targetLayer.Size, actionMetaData.intermediateEditableImageBuffer)

			imageToDrawOn = intermediateEditableImage
		end

		local sourceAlpha = if not isErasing then 1.0 else 0.0
		local targetAlpha = if not isErasing then 0.0 else 1.0

		local projectionBrushCircleTexture, projectionBrushLineTexture, circleBrushConfig, lineBrushConfig =
			TextureUtils.CreateAndSetupProjectionBrushTexturesAndConfigs(
				sourceAlpha,
				targetAlpha,
				actionMetaData.brushColor,
				actionMetaData.colorBlendType,
				actionMetaData.alphaBlendType
			)

		local pbrInfo, pbrBrushTextures = TextureUtils.GeneratePBRInfo(
			actionMetaData.alphaBlendType ~= Enum.ImageAlphaType.Default,
			actionMetaData.isReflectiveMode,
			textureInfo:GetRoughnessMap(referenceMeshPart),
			textureInfo:GetMetalnessMap(referenceMeshPart),
			textureInfo:GetNormalMap(referenceMeshPart)
		)

		local meshInfo = modelInfo:GetMeshInfo()
		local allEditableMesh = meshInfo:GetEditableMeshMap()

		local cameraCFrame = referenceMeshPart.CFrame:ToWorldSpace(actionMetaData.cameraCFrame)
		local cameraDirection = cameraCFrame.LookVector

		local lastCastedPoint = referenceMeshPart.CFrame:PointToWorldSpace(actionMetaData.drawPositions[1])
		for i, currentPosition in pairs(actionMetaData.drawPositions) do
			local castedPoint = referenceMeshPart.CFrame:PointToWorldSpace(currentPosition)
			local scaledBrushSize = actionMetaData.brushSize

			local pbResult =
				TextureUtils.GenerateProjectionBrushPoints(lastCastedPoint, castedPoint, cameraCFrame, scaledBrushSize)

			for currMeshPart, currEditableMesh in pairs(allEditableMesh) do
				local collisionTest =
					Utils.TestOBBCollision(currMeshPart, pbResult.projectorCFrame, pbResult.projectorBrushSize)
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
						pbrInfo
					)
				end
			end

			lastCastedPoint = castedPoint
		end

		-- In order to paint with transparency, we paint to an intermediate EI which we then apply the
		-- desired alpha value before drawing it to our target EI. This way we get consistent transparency
		-- across the stroke.
		if not isErasing then
			TextureUtils.ApplyAlpha(intermediateEditableImage, actionMetaData.brushTransparency)
			targetLayer:WritePixelsBuffer(Vector2.zero, targetLayer.Size, actionMetaData.cachedTargetImageBuffer)
			targetLayer:DrawImage(Vector2.zero, intermediateEditableImage, Enum.ImageCombineType.BlendSourceOver)
		end

		projectionBrushLineTexture:Destroy()
		projectionBrushCircleTexture:Destroy()
		for _, pbrBrushTexture in pairs(pbrBrushTextures) do
			pbrBrushTexture:Destroy()
		end
	end,
}

return ImageEditActions
