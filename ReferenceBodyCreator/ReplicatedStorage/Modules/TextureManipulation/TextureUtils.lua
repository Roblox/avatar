local AssetService = game:GetService("AssetService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))

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
	targetEditableImage: EditableImage
)
	local currentDirection = currMeshPart.CFrame:VectorToObjectSpace(projectionDirection)

	local circleBrushProjection: ProjectionParams = {
		Direction = currentDirection,
		Position = currMeshPart.CFrame:PointToObjectSpace(circlePosition),
		Size = Vector3.new(brushSize, brushSize, 100),
		Up = currMeshPart.CFrame:VectorToObjectSpace(Vector3.new(0, 1, 0)),
	}

	targetEditableImage:DrawImageProjected(currEditableMesh, circleBrushProjection, circleBrushConfig)

	local lineExist = lineLength > 0
	if lineExist then
		local lineBrushProjection: ProjectionParams = {
			Direction = currentDirection,
			Position = currMeshPart.CFrame:PointToObjectSpace(linePosition),
			Size = Vector3.new(lineLength, brushSize, 100),
			Up = currMeshPart.CFrame:VectorToObjectSpace(lineUpVec),
		}

		targetEditableImage:DrawImageProjected(currEditableMesh, lineBrushProjection, lineBrushConfig)
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
		Color3.new(0, 0, 0),
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

-- Given a larger region map and a smaller color map, and a position, check if
-- any of the pixels on the region map corresponding to the position on the
-- color map match the region we want to edit.
-- Used in RecolorRegionAction.
function TextureUtils.WriteBufferForLargerRegionMap(
	colorMapSize,
	regionPixelsBuffer,
	currentPixelsBuffer,
	regionColor,
	actionColor
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
				-- Recolor the pixel in the current buffer if it maps to any corresponding region pixel
				buffer.writeu8(currentPixelsBuffer, currentPos, colorR255)
				buffer.writeu8(currentPixelsBuffer, currentPos + 1, colorG255)
				buffer.writeu8(currentPixelsBuffer, currentPos + 2, colorB255)
			end
		end
	end
end

return TextureUtils
