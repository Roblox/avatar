--[[
	Holds utility functions for brushes and the BrushTool
]]
local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Config = Modules:WaitForChild("Config")
local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local Utils = require(Modules:WaitForChild("Utils"))

local Constants = require(Config:WaitForChild("Constants"))
local MeshTypes = require(MeshManipulation:WaitForChild("MeshTypes"))

local BrushUtils = {}

export type ProjectionBrushSettings = {
	surfacePoint: Vector3, -- projected point on target mesh
	cameraDirection: Vector3, -- world-space projection direction
	brushUp: Vector3, -- "up" direction for the brush (usually direction of stroke)
	scaledBrushSize: number,
}

local function clearEditableImage(editableImage: EditableImage)
	editableImage:DrawRectangle(Vector2.zero, editableImage.Size, Color3.new(), 1, Enum.ImageCombineType.Overwrite)
end

local function applyAlpha(editableImage: EditableImage, targetAlpha: number)
	-- Scale only the alpha by using the multiply blending mode
	editableImage:DrawRectangle(
		Vector2.zero,
		editableImage.Size,
		Color3.new(1, 1, 1), -- white to avoid changing colors
		1 - targetAlpha,
		Enum.ImageCombineType.Multiply
	)
end

-- Subtracts alpha of source from alpha of dest, saving to dest. dest = dest - (source * scaleFactor)
local function subtractAlpha(sourceEI: EditableImage, destEI: EditableImage, scaleFactor: number?)
	local size = sourceEI.Size
	assert(size == destEI.Size, "Subtraction expects images of the same size")

	local sourceBuffer = sourceEI:ReadPixelsBuffer(Vector2.zero, size)
	local destBuffer = destEI:ReadPixelsBuffer(Vector2.zero, size)
	for i = 0, buffer.len(sourceBuffer) - 1, 4 do
		local subtractedAlpha = buffer.readu8(destBuffer, i + 3)
			- buffer.readu8(sourceBuffer, i + 3) * (scaleFactor or 1) -- scale subtract by scaleFactor
		buffer.writeu8(destBuffer, i + 3, math.max(subtractedAlpha, 0)) -- ensure values are non-negative
	end
	destEI:WritePixelsBuffer(Vector2.zero, size, destBuffer)
end

function BrushUtils.GetProjectionDirection(
	projectionTarget: MeshTypes.ProjectionTarget,
	cameraCFrame: CFrame,
	surfacePoint: Vector3
): Vector3
	if projectionTarget:IsA("WrapTextureTransfer") then
		local cursorDirection = surfacePoint - cameraCFrame.Position
		if cursorDirection.Magnitude > 0 then
			return cursorDirection.Unit
		end
	end
	return cameraCFrame.LookVector
end

local function projectionBrushSettingsToParams(meshCFrame: CFrame, settings: ProjectionBrushSettings)
	return {
		Direction = meshCFrame:VectorToObjectSpace(settings.cameraDirection),
		Position = meshCFrame:PointToObjectSpace(settings.surfacePoint - settings.cameraDirection),
		Size = Vector3.new(settings.scaledBrushSize, settings.scaledBrushSize, Constants.MAX_PAINTING_DISTANCE),
		Up = meshCFrame:VectorToObjectSpace(settings.brushUp),
	}
end

function BrushUtils.QuantizeToBrushTextureSize(source: EditableImage): EditableImage
	local targetSize = Vector2.new(Constants.IMAGE_BRUSH_TEXTURE_SIZE, Constants.IMAGE_BRUSH_TEXTURE_SIZE)
	local quantized = AssetService:CreateEditableImage({ Size = targetSize })
	quantized:DrawImageTransformed(
		targetSize * 0.5,
		targetSize / source.Size,
		0,
		source,
		{ CombineType = Enum.ImageCombineType.Overwrite }
	)
	return quantized
end

-- Builds a circular soft-edge alpha mask (one byte per brush texel) for depositing a resampled
-- patch. [Edge, edgeMargin] = 0, [edgeMargin, edgeMargin + edgeFeather] is a linear ramp,
-- and [edgeMargin + edgeFeather, center] = 255.
function BrushUtils.CreateFeatherMask(edgeMargin: number, edgeFeather: number): buffer
	local width = Constants.IMAGE_BRUSH_TEXTURE_SIZE
	local mask = buffer.create(width * width)
	local center = (width - 1) / 2
	local outerRadius = width / 2 - edgeMargin
	local innerRadius = math.max(outerRadius - edgeFeather, 0)
	local outerRadiusSq = outerRadius * outerRadius
	local innerRadiusSq = innerRadius * innerRadius
	for y = 0, width - 1 do
		local deltaY = y - center
		for x = 0, width - 1 do
			local deltaX = x - center
			-- Get the pixel distance from the center
			local distSq = deltaX * deltaX + deltaY * deltaY
			local alpha
			-- Outside the outer radius, set alpha to transparent
			if distSq > outerRadiusSq then
				alpha = 0
			-- Inside the inner radius, set alpha to full
			elseif distSq <= innerRadiusSq then
				alpha = 255
			else
				-- Between the inner and outer radii, linearly interpolate the alpha
				alpha = math.round(255 * (outerRadius - math.sqrt(distSq)) / edgeFeather)
			end
			buffer.writeu8(mask, y * width + x, alpha)
		end
	end
	return mask
end

-- Box-blurs sampledBuf (RGBA) into targetImage.
function BrushUtils.BoxBlur(
	sampledBuf: buffer,
	targetImage: EditableImage,
	outScratch: buffer,
	spacing: number,
	count: number
)
	local readu8 = buffer.readu8
	local writeu8 = buffer.writeu8

	local size = targetImage.Size
	local width = size.X
	local height = size.Y
	local center = (count - 1) // 2 -- center the grid: taps sit at (i - center) * spacing

	-- Loop through each pixel
	for y = 0, height - 1 do
		for x = 0, width - 1 do
			local r, g, b, a, n = 0, 0, 0, 0, 0
			-- Loop through each valid neighbor used in the blur
			for tapY = 0, count - 1 do
				local sampleY = y + (tapY - center) * spacing
				if sampleY < 0 or sampleY >= height then
					continue -- ignore out of bounds on Y
				end
				for tapX = 0, count - 1 do
					local sampleX = x + (tapX - center) * spacing
					if sampleX < 0 or sampleX >= width then
						continue -- ignore out of bounds on X
					end

					-- Add the RGBA values to the sum
					local src = (sampleY * width + sampleX) * 4
					local alpha = readu8(sampledBuf, src + 3)
					r += readu8(sampledBuf, src) * alpha / 255
					g += readu8(sampledBuf, src + 1) * alpha / 255
					b += readu8(sampledBuf, src + 2) * alpha / 255
					a += alpha
					n += 1
				end
			end

			-- Color is the alpha-weighted average, so divide by total alpha
			local dst = (y * width + x) * 4
			if a > 0 then -- avoid division by zero on fully transparent areas
				writeu8(outScratch, dst, math.round(r / a * 255))
				writeu8(outScratch, dst + 1, math.round(g / a * 255))
				writeu8(outScratch, dst + 2, math.round(b / a * 255))
			else
				writeu8(outScratch, dst, 0)
				writeu8(outScratch, dst + 1, 0)
				writeu8(outScratch, dst + 2, 0)
			end
			writeu8(outScratch, dst + 3, math.round(a / n))
		end
	end

	targetImage:WritePixelsBuffer(Vector2.zero, size, outScratch)
end

-- Lerps targetImage (the blurred decal) back toward sourceBuf (the original sampled surface,
-- RGBA) per featherMask (one byte per texel): 255 keeps target while 0 keeps sourceBuf.
function BrushUtils.FeatherTowardSource(targetImage: EditableImage, sourceBuf: buffer, featherMask: buffer)
	local readu8 = buffer.readu8
	local writeu8 = buffer.writeu8

	local size = targetImage.Size
	local resultBuf = targetImage:ReadPixelsBuffer(Vector2.zero, size)
	for p = 0, buffer.len(featherMask) - 1 do
		local t = readu8(featherMask, p) -- weight toward the blurred result
		local inv = 255 - t -- weight toward the original surface
		local i = p * 4
		writeu8(resultBuf, i, (readu8(resultBuf, i) * t + readu8(sourceBuf, i) * inv + 127) // 255)
		writeu8(resultBuf, i + 1, (readu8(resultBuf, i + 1) * t + readu8(sourceBuf, i + 1) * inv + 127) // 255)
		writeu8(resultBuf, i + 2, (readu8(resultBuf, i + 2) * t + readu8(sourceBuf, i + 2) * inv + 127) // 255)
		writeu8(resultBuf, i + 3, (readu8(resultBuf, i + 3) * t + readu8(sourceBuf, i + 3) * inv + 127) // 255)
	end
	targetImage:WritePixelsBuffer(Vector2.zero, size, resultBuf)
end

-- Sample into a brush-sized image; the native projection reads the source texture directly.
-- ReadPixelsBuffer returns an independent buffer, allowing the scratch image to be reused
-- for the other mirror side before either sample is deposited.
local function sampleProjectedBrush(
	allProjectionTargets: MeshTypes.ProjectionTargetMap,
	projectionSettings: ProjectionBrushSettings,
	surfaceSampleImage: EditableImage,
	sourceImages: Constants.EditableImageSet
): Constants.BufferSet
	local sampleConfig = {
		ColorBlendType = Enum.ImageCombineType.Overwrite,
		AlphaBlendType = Enum.ImageAlphaType.Default,
		FadeAngle = 180.0,
	}

	local sampledBuffers = {} :: Constants.BufferSet
	for _, channel in Constants.CHANNEL_NAMES do
		-- Uncovered pixels are left unchanged by SampleImageProjected, so clear per side and channel.
		clearEditableImage(surfaceSampleImage)
		for meshPart, projectionTarget in pairs(allProjectionTargets) do
			local projection = projectionBrushSettingsToParams(meshPart.CFrame, projectionSettings)
			surfaceSampleImage:SampleImageProjected(projectionTarget, sourceImages[channel], projection, sampleConfig)
		end
		sampledBuffers[channel] = surfaceSampleImage:ReadPixelsBuffer(Vector2.zero, surfaceSampleImage.Size)
	end
	return sampledBuffers
end

-- Stamps a brush once at projectionSettings.surfacePoint, projected along its camera direction,
-- onto targetImage and every PBR channel across all mesh parts. Calling with mirrored draws both
-- the mirrored and unmirrored versions.
function BrushUtils.StampProjectedBrush(
	allProjectionTargets: MeshTypes.ProjectionTargetMap,
	projectionSettings: ProjectionBrushSettings,
	brushConfig, -- without decal
	targetImages: Constants.EditableImageSet,
	brushDecals: Constants.EditableImageSet,
	mirrorPlane: CFrame?,
	mirroredBrushDecals: Constants.EditableImageSet?
)
	local function stamp(settings: ProjectionBrushSettings, decals: Constants.EditableImageSet): ()
		for currMeshPart, projectionTarget in pairs(allProjectionTargets) do
			local projection = projectionBrushSettingsToParams(currMeshPart.CFrame, settings)
			for _, channel in Constants.CHANNEL_NAMES do
				local target = targetImages[channel]
				local decal = decals[channel]
				if target and decal then
					brushConfig.Decal = decal
					target:DrawImageProjected(projectionTarget, projection, brushConfig)
				end
			end
		end
	end

	-- Draw the mirrored version first.
	if mirrorPlane then
		-- Mirror in world space before converting the projection into each mesh part's local space.
		stamp(Utils.ReflectProjectionSettings(projectionSettings, mirrorPlane), mirroredBrushDecals or brushDecals)
	end
	-- Draw the unmirrored version as well.
	stamp(projectionSettings, brushDecals)
end

-- Sampling brushes must read each side's own pixels in the same orientation used to stamp them.
-- Capture both sides before writing either one, so overlapping stamps sample the same texture state.
function BrushUtils.StampResampledBrush(
	allProjectionTargets: MeshTypes.ProjectionTargetMap,
	projectionSettings: ProjectionBrushSettings,
	brushConfig,
	targetImages: Constants.EditableImageSet,
	brushObject,
	surfaceSampleImage: EditableImage,
	sourceImages: Constants.EditableImageSet,
	mirrorPlane: CFrame?
)
	local sampledBuffers =
		sampleProjectedBrush(allProjectionTargets, projectionSettings, surfaceSampleImage, sourceImages)
	if mirrorPlane then
		local mirroredSettings = Utils.ReflectProjectionSettings(projectionSettings, mirrorPlane)
		local mirroredSample =
			sampleProjectedBrush(allProjectionTargets, mirroredSettings, surfaceSampleImage, sourceImages)
		brushObject:SampleSurface(mirroredSample, true)
		BrushUtils.StampProjectedBrush(
			allProjectionTargets,
			mirroredSettings,
			brushConfig,
			targetImages,
			brushObject:getBrushEIs(),
			nil
		)
	end
	brushObject:SampleSurface(sampledBuffers, false)
	BrushUtils.StampProjectedBrush(
		allProjectionTargets,
		projectionSettings,
		brushConfig,
		targetImages,
		brushObject:getBrushEIs(),
		nil
	)
end

-- Walks from sourcePoint toward destPoint, invoking stampFn(point, direction) at each step (wider spacing if capped).
-- Returns the last stamped point (not necessarily destPoint, but within spacing of destPoint).
function BrushUtils.WalkBrushTextureSegment(
	sourcePoint: Vector3,
	destPoint: Vector3,
	spacing: number,
	stampFn: (point: Vector3, direction: Vector3) -> ()
): Vector3
	local delta = destPoint - sourcePoint
	local distance = delta.Magnitude
	if not (spacing > 0 and spacing < math.huge and distance > 0 and distance < math.huge) then
		return sourcePoint
	end

	local requestedCount = math.floor(distance / spacing)
	local stampCount = math.min(requestedCount, Constants.MAX_BRUSH_STAMPS_PER_SEGMENT)
	if stampCount == 0 then
		return sourcePoint
	end

	local capped = requestedCount > stampCount
	local direction = delta.Unit
	local stampPoint = sourcePoint
	for i = 1, stampCount do
		local fraction = if capped then i / stampCount else math.min(i * spacing / distance, 1)
		-- Avoid accumulated Vector3 rounding error.
		stampPoint = if fraction == 1 then destPoint else sourcePoint + delta * fraction
		stampFn(stampPoint, direction)
	end
	return stampPoint
end

-- Composites the accumulated stroke intermediate onto target, blended for painting versus erasing.
-- intermediate is unchanged; brushOpacity acts as a cap on opacity for the whole stroke.
function BrushUtils.CompositeBrushStroke(
	targetEIs: Constants.EditableImageSet,
	cachedTargetBuffers: Constants.BufferSet,
	intermediateEIs: Constants.EditableImageSet,
	state: number,
	brushOpacity: number
)
	-- Blending is done directly on the target buffer
	if state == Constants.STATE_BLENDING then
		return
	end

	-- Save intermediates to a temporary buffer
	for _, channel in Constants.CHANNEL_NAMES do
		local preCompositeBuffer: buffer =
			intermediateEIs[channel]:ReadPixelsBuffer(Vector2.zero, intermediateEIs[channel].Size)

		-- Reset the target to its cached state
		targetEIs[channel]:WritePixelsBuffer(
			Vector2.zero,
			targetEIs[channel].Size,
			cachedTargetBuffers[channel]
		)

		if state == Constants.STATE_ERASING then
			-- Scaling and subtracting are done together for performance
			subtractAlpha(intermediateEIs[channel], targetEIs[channel], brushOpacity)
		else
			-- Scale the intermediate EditableImage by the required alpha
			applyAlpha(intermediateEIs[channel], brushOpacity)
			targetEIs[channel]:DrawImage(
				Vector2.zero,
				intermediateEIs[channel],
				Enum.ImageCombineType.BlendSourceOver
			)
		end

		-- Restore the unscaled stamps so the next composite builds on the full accumulated stroke.
		intermediateEIs[channel]:WritePixelsBuffer(
			Vector2.zero,
			intermediateEIs[channel].Size,
			preCompositeBuffer
		)
	end
end

return BrushUtils
