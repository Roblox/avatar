local AssetService = game:GetService("AssetService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

-- Top-left editable cell matches Constants.PBR_MAP_CELL_SIZE; body uses that full image,
-- accessories pack a 2×2 atlas so the backing image is cell × ATLAS_GRID_SIZE per axis.
local function getPbrAtlasCellSize(pbrMap: EditableImage): Vector2
	if
		pbrMap.Size.X == Constants.PBR_MAP_CELL_SIZE.X * Constants.ATLAS_GRID_SIZE
		and pbrMap.Size.Y == Constants.PBR_MAP_CELL_SIZE.Y * Constants.ATLAS_GRID_SIZE
	then
		return Constants.PBR_MAP_CELL_SIZE
	end
	return Vector2.new(pbrMap.Size.X, pbrMap.Size.Y)
end

type RegionColorUInt8 = { r: number, g: number, b: number }

-- One byte per PBR texel (0 = no mask, 1 = paint). Built once per ApplyPBRToRegion.
-- Region masks are square; side length must be an integer multiple of each PBR axis (typically 256×256 cell).
local function computePbrRegionMask(
	pbrMapSize: Vector2,
	regionBuffer: buffer,
	regionColor: RegionColorUInt8
): buffer
	local regionR255 = regionColor.r
	local regionG255 = regionColor.g
	local regionB255 = regionColor.b

	local pbrWidth = pbrMapSize.X
	local pbrHeight = pbrMapSize.Y
	local pixelCount = pbrWidth * pbrHeight
	local mask = buffer.create(pixelCount)

	local regionTexelCount = buffer.len(regionBuffer) / 4
	local regionSideLength = math.sqrt(regionTexelCount)
	local regionSideRounded = math.floor(regionSideLength + 0.5)

	local stepX = regionSideRounded // pbrWidth
	local stepY = regionSideRounded // pbrHeight
	local flatMaskIndex = 0
	for pbrY = 0, pbrHeight - 1 do
		for pbrX = 0, pbrWidth - 1 do
			local regionPixelX = pbrX * stepX
			local regionPixelY = pbrY * stepY
			local regionByteOffset = (regionPixelY * regionSideRounded + regionPixelX) * 4
			local matched = buffer.readu8(regionBuffer, regionByteOffset) == regionR255
				and buffer.readu8(regionBuffer, regionByteOffset + 1) == regionG255
				and buffer.readu8(regionBuffer, regionByteOffset + 2) == regionB255
			buffer.writeu8(mask, flatMaskIndex, if matched then 1 else 0)
			flatMaskIndex += 1
		end
	end

	return mask
end

local function applyMaskToPbrReadBuffer(
	rgbaBuffer: buffer,
	mask1bpp: buffer,
	pixelCount: number,
	colorR255: number,
	colorG255: number,
	colorB255: number
)
	for texelIndex = 0, pixelCount - 1 do
		if buffer.readu8(mask1bpp, texelIndex) ~= 0 then
			local rgbaByteOffset = texelIndex * 4
			buffer.writeu8(rgbaBuffer, rgbaByteOffset, colorR255)
			buffer.writeu8(rgbaBuffer, rgbaByteOffset + 1, colorG255)
			buffer.writeu8(rgbaBuffer, rgbaByteOffset + 2, colorB255)
		end
	end
end

local TextureUtils = {}

function TextureUtils.Clear(editableImage: EditableImage)
	editableImage:DrawRectangle(Vector2.new(), editableImage.Size, Color3.new(), 1.0, Enum.ImageCombineType.Overwrite)
end

function TextureUtils.DrawCircleBetweenPoints(
	oldPosition,
	newPosition,
	brushSize,
	brushColor,
	brushTransparency,
	editableImage: EditableImage
)
	local circleRadius = brushSize / 2
	local distBetween = (oldPosition - newPosition).magnitude

	if distBetween <= 0 then
		editableImage:DrawCircle(newPosition, brushSize, brushColor, brushTransparency, Enum.ImageCombineType.Overwrite)
	end

	for i = 1, distBetween, math.max(math.floor(circleRadius), 1) do
		local interPosition = oldPosition:Lerp(newPosition, i / distBetween)
		interPosition = Vector2.new(math.floor(interPosition.X), math.floor(interPosition.Y))

		editableImage:DrawCircle(
			interPosition,
			brushSize,
			brushColor,
			brushTransparency,
			Enum.ImageCombineType.Overwrite
		)
	end
end

function TextureUtils.PerformRegionStencil(
	currentRegion: TextureInfo.Region,
	previousBuffer,
	targetTexture: EditableImage
)
	if
		currentRegion ~= nil
		and currentRegion.regionBuffer ~= nil
		and currentRegion.regionColor ~= nil
		and previousBuffer ~= nil
		and targetTexture ~= nil
	then
		local currentBuffer = targetTexture:ReadPixelsBuffer(Vector2.zero, targetTexture.Size)

		local regionBuffer = currentRegion.regionBuffer
		local regionR255 = currentRegion.regionColor.r
		local regionG255 = currentRegion.regionColor.g
		local regionB255 = currentRegion.regionColor.b

		-- Only pixels where the region color matches the region image color are recolored
		for i = 0, buffer.len(regionBuffer) - 1, 4 do
			if
				buffer.readu8(regionBuffer, i) == regionR255
				and buffer.readu8(regionBuffer, i + 1) == regionG255
				and buffer.readu8(regionBuffer, i + 2) == regionB255
			then
				buffer.writeu8(previousBuffer, i, buffer.readu8(currentBuffer, i))
				buffer.writeu8(previousBuffer, i + 1, buffer.readu8(currentBuffer, i + 1))
				buffer.writeu8(previousBuffer, i + 2, buffer.readu8(currentBuffer, i + 2))
				buffer.writeu8(previousBuffer, i + 3, buffer.readu8(currentBuffer, i + 3))
			end
		end

		targetTexture:WritePixelsBuffer(Vector2.zero, targetTexture.Size, previousBuffer)
	end
end

function TextureUtils.ApplyAlpha(
	editableImage,
	targetAlpha
)
	local size = editableImage.Size
	local pixelCount = size.X * size.Y

	local eiBuffer = editableImage:ReadPixelsBuffer(Vector2.zero, size)

	for i = 0, buffer.len(eiBuffer) - 1, 4 do
		local alpha = buffer.readu8(eiBuffer, i + 3)
		buffer.writeu8(eiBuffer, i + 3, alpha * targetAlpha)
	end

	editableImage:WritePixelsBuffer(Vector2.zero, size, eiBuffer)
end

function TextureUtils.GetRoughnessMaps(
	modelInfo: ModelInfo.ModelInfoClass,
	textureInfo: TextureInfo.TextureInfoClass,
	meshPartNames: { string }
)
	local uniqueEditableImages = {}

	for _, meshPartName in pairs(meshPartNames) do
		local meshPart = modelInfo:GetMeshPartByName(meshPartName)
		local roughnessEI = textureInfo:GetRoughnessMap(meshPart)

		uniqueEditableImages[roughnessEI] = meshPartName
	end

	return uniqueEditableImages
end

function TextureUtils.GetMetalnessMaps(
	modelInfo: ModelInfo.ModelInfoClass,
	textureInfo: TextureInfo.TextureInfoClass,
	meshPartNames: { string }
)
	local uniqueEditableImages = {}

	for _, meshPartName in pairs(meshPartNames) do
		local meshPart = modelInfo:GetMeshPartByName(meshPartName)
		local metalnessEI = textureInfo:GetMetalnessMap(meshPart)

		uniqueEditableImages[metalnessEI] = meshPartName
	end

	return uniqueEditableImages
end

function TextureUtils.GetBufferFromPBRRegionRecolor(
	pbrMap,
	region,
	color
)
	local pbrMapSize = getPbrAtlasCellSize(pbrMap)
	local mask = computePbrRegionMask(pbrMapSize, region.regionBuffer :: buffer, region.regionColor :: RegionColorUInt8)
	local currentPixelsBuffer = pbrMap:ReadPixelsBuffer(Vector2.zero, pbrMapSize)

	local colorR255 = color.R * 255
	local colorG255 = color.G * 255
	local colorB255 = color.B * 255

	applyMaskToPbrReadBuffer(
		currentPixelsBuffer,
		mask,
		pbrMapSize.X * pbrMapSize.Y,
		colorR255,
		colorG255,
		colorB255
	)

	return currentPixelsBuffer
end

local function getMetalAndRoughColor(isReflective)
	if isReflective then
		return Constants.PBR_REFLECTIVE_METAL_COLOR, Constants.PBR_REFLECTIVE_ROUGH_COLOR
	end
	return Constants.PBR_DEFAULT_METAL_COLOR, Constants.PBR_DEFAULT_ROUGH_COLOR
end

function TextureUtils.ApplyPBRToRegion(modelInfo, textureInfo, region, isReflective)
	if not region.regionBuffer then
		for _, meshPartName in ipairs(region.meshPartNames) do
			local meshPart = modelInfo:GetMeshPartByName(meshPartName)
			if meshPart then
				TextureUtils.ApplyPBRMaps(textureInfo, meshPart, isReflective)
			end
		end
		return
	end

	local metalColor, roughnessColor = getMetalAndRoughColor(isReflective)

	local roughnessMaps = TextureUtils.GetRoughnessMaps(modelInfo, textureInfo, region.meshPartNames)
	local metalnessMaps = TextureUtils.GetMetalnessMaps(modelInfo, textureInfo, region.meshPartNames)

	local sampleEditableImage: EditableImage? = nil
	for roughnessEditable, _ in roughnessMaps do
		sampleEditableImage = roughnessEditable
		break
	end
	if not sampleEditableImage then
		for metalnessEditable, _ in metalnessMaps do
			sampleEditableImage = metalnessEditable
			break
		end
	end
	if not sampleEditableImage then
		return
	end

	local pbrCellSize = getPbrAtlasCellSize(sampleEditableImage)
	local mask = computePbrRegionMask(pbrCellSize, region.regionBuffer, region.regionColor :: RegionColorUInt8)
	local texelCount = pbrCellSize.X * pbrCellSize.Y

	local roughnessR255 = roughnessColor.R * 255
	local roughnessG255 = roughnessColor.G * 255
	local roughnessB255 = roughnessColor.B * 255
	local metalnessR255 = metalColor.R * 255
	local metalnessG255 = metalColor.G * 255
	local metalnessB255 = metalColor.B * 255

	for roughnessEditable, _ in roughnessMaps do
		local atlasWriteSize = getPbrAtlasCellSize(roughnessEditable)
		local roughnessBuffer = roughnessEditable:ReadPixelsBuffer(Vector2.zero, atlasWriteSize)
		applyMaskToPbrReadBuffer(
			roughnessBuffer,
			mask,
			texelCount,
			roughnessR255,
			roughnessG255,
			roughnessB255
		)
		roughnessEditable:WritePixelsBuffer(Vector2.zero, atlasWriteSize, roughnessBuffer)
	end

	for metalnessEditable, _ in metalnessMaps do
		local atlasWriteSize = getPbrAtlasCellSize(metalnessEditable)
		local metalnessBuffer = metalnessEditable:ReadPixelsBuffer(Vector2.zero, atlasWriteSize)
		applyMaskToPbrReadBuffer(
			metalnessBuffer,
			mask,
			texelCount,
			metalnessR255,
			metalnessG255,
			metalnessB255
		)
		metalnessEditable:WritePixelsBuffer(Vector2.zero, atlasWriteSize, metalnessBuffer)
	end
end

function TextureUtils.ApplyPBRMaps(textureInfo, meshPart, isReflective)
	local metalnessEI = textureInfo:GetMetalnessMap(meshPart)
    local roughnessEI = textureInfo:GetRoughnessMap(meshPart)

	local metalColor, roughnessColor = getMetalAndRoughColor(isReflective)

	metalnessEI:DrawRectangle(
		Vector2.new(0, 0),
		metalnessEI.Size,
		metalColor,
		0,
		Enum.ImageCombineType.Overwrite
	)

	roughnessEI:DrawRectangle(
		Vector2.new(0, 0),
		roughnessEI.Size,
		roughnessColor,
		0,
		Enum.ImageCombineType.Overwrite
	)
end

function TextureUtils.ClearPBR(textureInfo, meshPart)
	TextureUtils.ApplyPBRMaps(textureInfo, meshPart, false --[[isReflective]])
end

-- Colors parts of a texture based on a region map and a target color
function TextureUtils.PerformRegionColor(
	currentPixelsBuffer: buffer,
	currentRegion: TextureInfo.Region,
	color: Color3,
	targetTexture: EditableImage,
	textureSize: Vector2,
	fillAlphaByte: number
)
	local regionPixelsBuffer = currentRegion.regionBuffer

	local regionR255 = currentRegion.regionColor.r
	local regionG255 = currentRegion.regionColor.g
	local regionB255 = currentRegion.regionColor.b

	local colorR255 = color.R * 255
	local colorG255 = color.G * 255
	local colorB255 = color.B * 255

	-- Only pixels where the region color matches the region image color are recolored
	for i = 0, buffer.len(currentPixelsBuffer) - 1, 4 do
		if
			buffer.readu8(regionPixelsBuffer, i) == regionR255
			and buffer.readu8(regionPixelsBuffer, i + 1) == regionG255
			and buffer.readu8(regionPixelsBuffer, i + 2) == regionB255
		then
			buffer.writeu8(currentPixelsBuffer, i, colorR255)
			buffer.writeu8(currentPixelsBuffer, i + 1, colorG255)
			buffer.writeu8(currentPixelsBuffer, i + 2, colorB255)
			buffer.writeu8(currentPixelsBuffer, i + 3, fillAlphaByte)
		end
	end

	targetTexture:WritePixelsBuffer(Vector2.zero, textureSize, currentPixelsBuffer)
end

function TextureUtils.DrawProjectionBrush(
	projectionDirection: Vector3,
	currMeshPart: MeshPart,
	currEditableMesh: EditableMesh,
	circlePosition: Vector3,
	linePosition: Vector3,
	brushSize: number,
	lineLength: number,
	lineUpVec: Vector3,
	circleBrushConfig,
	lineBrushConfig,
	targetEditableImage: EditableImage,
	pbrInfo
)
	local currentDirection = currMeshPart.CFrame:VectorToObjectSpace(projectionDirection)

	local circleBrushProjection: ProjectionParams = {
		Direction = currentDirection,
		Position = currMeshPart.CFrame:PointToObjectSpace(circlePosition),
		Size = Vector3.new(brushSize, brushSize, 100),
		Up = currMeshPart.CFrame:VectorToObjectSpace(Vector3.new(0, 1, 0)),
	}

	targetEditableImage:DrawImageProjected(currEditableMesh, circleBrushProjection, circleBrushConfig)

	for _, channelInfo in pairs(pbrInfo) do
		if channelInfo and channelInfo.editableImage then
			channelInfo.editableImage:DrawImageProjected(currEditableMesh, circleBrushProjection, channelInfo.circleBrushConfig)
		end
	end

	local lineExist = lineLength > 0
	if lineExist then
		local lineBrushProjection: ProjectionParams = {
			Direction = currentDirection,
			Position = currMeshPart.CFrame:PointToObjectSpace(linePosition),
			Size = Vector3.new(lineLength, brushSize, 100),
			Up = currMeshPart.CFrame:VectorToObjectSpace(lineUpVec),
		}

		targetEditableImage:DrawImageProjected(currEditableMesh, lineBrushProjection, lineBrushConfig)

		for _, channelInfo in pairs(pbrInfo) do
			if channelInfo and channelInfo.editableImage then
				channelInfo.editableImage:DrawImageProjected(currEditableMesh, lineBrushProjection, channelInfo.lineBrushConfig)
			end
		end
	end
end

function TextureUtils.CreateAndSetupProjectionBrushTexturesAndConfigs(
	sourceAlpha: number,
	targetAlpha: number,
	penColor: Color3,
	colorBlendType: Enum.ImageCombineType,
	alphaBlendType: Enum.ImageAlphaType
)
	local circleTexture = AssetService:CreateEditableImage({
		Size = Vector2.new(64, 64),
	})

	local lineTexture = AssetService:CreateEditableImage({
		Size = Vector2.new(4, 4),
	})

	local circleTextureSize = circleTexture.Size
	local circleTextureSizeHalfSize = circleTextureSize * 0.5
	circleTexture:DrawRectangle(
		Vector2.zero,
		circleTextureSize,
		penColor,
		sourceAlpha,
		Enum.ImageCombineType.Overwrite
	)
	circleTexture:DrawCircle(
		circleTextureSizeHalfSize,
		circleTextureSizeHalfSize.X,
		penColor,
		targetAlpha,
		Enum.ImageCombineType.Overwrite
	)

	lineTexture:DrawRectangle(Vector2.zero, lineTexture.Size, penColor, targetAlpha, Enum.ImageCombineType.Overwrite)

	local circleBrushConfig: BrushConfig = {
		Decal = circleTexture,
		ColorBlendType = colorBlendType,
		AlphaBlendType = alphaBlendType,
		BlendIntensity = 1,
		FadeAngle = 180.0,
	}

	local lineBrushConfig: BrushConfig = {
		Decal = lineTexture,
		ColorBlendType = colorBlendType,
		AlphaBlendType = alphaBlendType,
		BlendIntensity = 1,
		FadeAngle = 180.0,
	}

	return circleTexture, lineTexture, circleBrushConfig, lineBrushConfig
end

export type ProjectionBrushComputeResult = {
	castedPointOffSet: Vector3,
	castedUp: Vector3,
	projectorCFrame: CFrame,
	projectorBrushSize: number,
	castedCenterPointOffSet: Vector3,
	castedDeltaVecLength: number,
}

function TextureUtils.GenerateProjectionBrushPoints(
	prevPoint: Vector3,
	currPoint: Vector3,
	cameraCFrame: CFrame,
	brushSize: number
)
	local castedDelta = currPoint + prevPoint
	local castedCenterPoint = castedDelta * 0.5

	local cameraDirection = cameraCFrame.LookVector

	local currPointOffSet = currPoint - cameraDirection
	local castedCenterPointOffSet = castedCenterPoint - cameraDirection

	local castedDeltaVec = currPoint - prevPoint
	local castedDeltaVecLength = castedDeltaVec.Magnitude
	local castedUp = castedDeltaVec:Cross(cameraDirection).Unit

	local projectorCFrame = CFrame.new(castedCenterPointOffSet) * cameraCFrame.Rotation
	local projectorBrushSize = Vector3.new(castedDeltaVecLength + brushSize, brushSize, 100)

	local projectionBrushComputeResult: ProjectionBrushComputeResult = {
		castedPointOffSet = currPointOffSet,
		castedUp = castedUp,
		projectorCFrame = projectorCFrame,
		projectorBrushSize = projectorBrushSize,
		castedCenterPointOffSet = castedCenterPointOffSet,
		castedDeltaVecLength = castedDeltaVecLength,
	}

	return projectionBrushComputeResult
end

function TextureUtils.GeneratePBRInfo(
	isErasing,
	isReflectiveMode,
	roughnessMap,
	metalnessMap,
	normalMap
)
	local pbrInfo = {}
	local pbrBrushTextures = {}
	local projectionBrushCircleTexturePBR, projectionBrushLineTexturePBR, circleBrushConfigPBR, lineBrushConfigPBR
	local pbrChannels = {}
	if not isErasing and isReflectiveMode then
		pbrChannels = {
			Metalness = {
				defaultColor = Constants.PBR_REFLECTIVE_METAL_COLOR,
				editableImage = metalnessMap
			},
			Roughness = {
				defaultColor = Constants.PBR_REFLECTIVE_ROUGH_COLOR,
				editableImage = roughnessMap
			}
		}
	else
		pbrChannels = {
			Metalness = {
				defaultColor = Constants.PBR_DEFAULT_METAL_COLOR,
				editableImage = metalnessMap
			},
			Roughness = {
				defaultColor = Constants.PBR_DEFAULT_ROUGH_COLOR,
				editableImage = roughnessMap
			},
			Normal = {
				defaultColor = Constants.PBR_DEFAULT_NORMAL_COLOR,
				editableImage = normalMap
			}
		}
	end

	-- Create configs for each channel
	for channelName, channelData in pairs(pbrChannels) do
		local circleBrush, lineBrush, circleConfig, lineConfig = 
			TextureUtils.CreateAndSetupProjectionBrushTexturesAndConfigs(
				1.0, 0.0, channelData.defaultColor, 
				Enum.ImageCombineType.BlendSourceOver, 
				Enum.ImageAlphaType.Default)

		pbrInfo[channelName] = {
			circleBrushConfig = circleConfig,
			lineBrushConfig = lineConfig,
			editableImage = channelData.editableImage
		}

		-- Populate pbrBrushTextures and return them for cleanup later
		table.insert(pbrBrushTextures, circleBrush)
		table.insert(pbrBrushTextures, lineBrush)
	end

	return pbrInfo, pbrBrushTextures
end

-- Given a larger region map and a smaller color map, and a position, check if
-- any of the pixels on the region map corresponding to the position on the
-- color map match the region we want to edit.
-- Used in RecolorRegionAction.
function TextureUtils.WriteBufferForLargerRegionMap(
	colorMapSize,
	regionPixelsBuffer,
	currentPixelsBuffer,
	originalPixelsBuffer,
	regionColor,
	actionColor,
	fillAlphaByte
)
	local regionR255 = regionColor.r
	local regionG255 = regionColor.g
	local regionB255 = regionColor.b

	local colorR255 = actionColor.R * 255
	local colorG255 = actionColor.G * 255
	local colorB255 = actionColor.B * 255

	local currentWidth, currentHeight = colorMapSize.X, colorMapSize.Y
	local regionTotalPixels = buffer.len(regionPixelsBuffer) / 4
	local regionSize = math.sqrt(regionTotalPixels)
	local scaleX = regionSize / currentWidth
	local scaleY = regionSize / currentHeight

	for y = 0, currentHeight - 1 do
		for x = 0, currentWidth - 1 do
			local currentPos = ((y * currentWidth) + x) * 4
			local matchFound = false

			-- Calculate the positions in the region buffer for this pixel
			local regionStartX = math.floor(x * scaleX)
			local regionStartY = math.floor(y * scaleY)
			local regionEndX = math.floor((x + 1) * scaleX)
			local regionEndY = math.floor((y + 1) * scaleY)

			-- For each pixel in the smaller texture, check the corresponding area in the large texture
			for regionY = regionStartY, regionEndY - 1 do
				for regionX = regionStartX, regionEndX - 1 do
					local regionPos = ((regionY * regionSize) + regionX) * 4

					if regionPos >= 0 and regionPos < buffer.len(regionPixelsBuffer) - 3 then
						-- Check if this pixel in the region matches the target color
						if
							buffer.readu8(regionPixelsBuffer, regionPos) == regionR255
							and buffer.readu8(regionPixelsBuffer, regionPos + 1) == regionG255
							and buffer.readu8(regionPixelsBuffer, regionPos + 2) == regionB255
						then
							matchFound = true
							break
						end
					end
				end

				if matchFound then
					break
				end
			end
			if matchFound then
				-- Write the color and alpha to the current pixels buffer
                buffer.writeu8(currentPixelsBuffer, currentPos, colorR255)
                buffer.writeu8(currentPixelsBuffer, currentPos + 1, colorG255)
                buffer.writeu8(currentPixelsBuffer, currentPos + 2, colorB255)
                buffer.writeu8(currentPixelsBuffer, currentPos + 3, fillAlphaByte)
			end
		end
	end
end

return TextureUtils
