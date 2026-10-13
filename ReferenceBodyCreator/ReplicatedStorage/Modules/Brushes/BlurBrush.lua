--[[
	A blur brush: captures the surface beneath the brush at every stamp, blurs it, and
	deposits it back
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Brushes = Modules:WaitForChild("Brushes")
local BaseBrush = require(Brushes:WaitForChild("BaseBrush"))
local BrushUtils = require(Brushes:WaitForChild("BrushUtils"))

local Config = Modules:WaitForChild("Config")
local BrushData = require(Config:WaitForChild("BrushData"))
local Constants = require(Config:WaitForChild("Constants"))

local BlurBrush = setmetatable({}, { __index = BaseBrush })
BlurBrush.__index = BlurBrush

-- id for server replay
BlurBrush.BrushId = "BlurBrush"

-- Box-blur parameters: a BLUR_TAP_COUNT x BLUR_TAP_COUNT grid of taps, BLUR_TAP_SPACING texels apart.
-- Larger spacing is a wider blur.
local BLUR_TAP_SPACING = 6
local BLUR_TAP_COUNT = 3

-- Crop the output to use only the region of the blur that draws from all subimages
local BLUR_EDGE_MARGIN = BLUR_TAP_SPACING * (BLUR_TAP_COUNT // 2) + 1

-- Feather the edge such that the border of the blur is not harsh
local BLUR_EDGE_FEATHER = 20

-- Builds a circular soft-edge alpha mask (one byte per brush texel) for depositing a resampled
-- patch. [Edge, edgeMargin] = 0, [edgeMargin, edgeMargin + edgeFeather] is a linear ramp
-- [edgeMargin + edgeFeather, center] = 255
local FEATHER_MASK: buffer = BrushUtils.CreateFeatherMask(BLUR_EDGE_MARGIN, BLUR_EDGE_FEATHER)

function BlurBrush.new()
	local self = BaseBrush.new()
	setmetatable(self, BlurBrush)

	-- Reused per-channel scratch buffers the blur result is built in (avoids a per-stamp
	-- allocation). Resampling subclasses (SmudgeBrush) also carry the unfeathered blur here.
	local size = Constants.IMAGE_BRUSH_TEXTURE_SIZE
	self.blurScratch = {}
	for _, channel in Constants.CHANNEL_NAMES do
		self.blurScratch[channel] = buffer.create(size * size * 4)
	end

	return self
end

function BlurBrush:CloneForReplay()
	local replayBrush = BaseBrush.CloneForReplay(self)
	-- History replays a complete stroke, so its blur/smudge sample starts empty.
	replayBrush.blurScratch = {}
	for channel, scratch in self.blurScratch do
		replayBrush.blurScratch[channel] = buffer.create(buffer.len(scratch))
	end
	return replayBrush
end

function BlurBrush:getSettings()
	return {
		stampSpacingFactor = 0.3,
		brushType = Constants.STATE_BLENDING,
		colorBlendType = Enum.ImageCombineType.Overwrite,
	}
end

function BlurBrush:getBrushEIs(): Constants.EditableImageSet
	return self.editableImages
end

-- Nothing to be done on updating texture. Overload to do nothing
function BlurBrush:UpdateTexture() end

-- We do nothing with the color. Overload to do nothing
function BlurBrush:setColor(_newColor) end

-- Signals to ImageProjectionBrush that this brush must read from the surface
function BlurBrush:RequiresSurfaceSample(): boolean
	return true
end

-- Blurs a channel's sampled surface into its decal. Leaves the unfeathered blur in
-- self.blurScratch[channel], which resampling subclasses (for example, SmudgeBrush) carry across stamps.
-- Subclasses can supply separate scratch buffers for each side of a mirrored stroke.
function BlurBrush:WriteBlurredSample(channel: string, sampledBuffer: buffer, blurScratch: buffer?)
	BrushUtils.BoxBlur(
		sampledBuffer,
		self.editableImages[channel],
		blurScratch or self.blurScratch[channel],
		BLUR_TAP_SPACING,
		BLUR_TAP_COUNT
	)
end

-- Feathers a channel's decal edge back toward the sampled surface so the blur border is not harsh.
function BlurBrush:FeatherTowardSample(channel: string, sampledBuffer: buffer)
	BrushUtils.FeatherTowardSource(self.editableImages[channel], sampledBuffer, FEATHER_MASK)
end

-- Blurs and feathers each sampled channel to build the decal overwritten back onto the layer.
function BlurBrush:SampleSurface(sampledBuffers: Constants.BufferSet)
	for _, channel in Constants.CHANNEL_NAMES do
		local sampledBuffer = sampledBuffers[channel]
		self:WriteBlurredSample(channel, sampledBuffer)
		self:FeatherTowardSample(channel, sampledBuffer)
	end
end

function BlurBrush:getMinSize()
	return BrushData.BlendBrushData.BlurBrush.minSize
end

function BlurBrush:getMaxSize()
	return BrushData.BlendBrushData.BlurBrush.maxSize
end

function BlurBrush:getDefaultSize()
	return BrushData.BlendBrushData.BlurBrush.defaultSize
end

return BlurBrush
