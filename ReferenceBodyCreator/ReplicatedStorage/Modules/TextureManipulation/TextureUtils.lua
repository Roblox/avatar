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

		editableImage:DrawCircle(interPosition, brushSize, brushColor, brushTransparency, Enum.ImageCombineType.Overwrite)
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

	lineTexture:DrawRectangle(
		Vector2.zero,
		lineTexture.Size,
		penColor,
		targetAlpha,
		Enum.ImageCombineType.Overwrite
	)

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
	castedDeltaVecLength: number
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

return TextureUtils
