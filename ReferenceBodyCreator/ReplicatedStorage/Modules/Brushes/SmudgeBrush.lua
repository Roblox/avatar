--[[
	A smudge brush: captures and blurs the surface beneath the brush, then carries that
	sample across multiple stamps.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Brushes = Modules:WaitForChild("Brushes")
local BlurBrush = require(Brushes:WaitForChild("BlurBrush"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local BrushData = require(Config:WaitForChild("BrushData"))

local SmudgeBrush = setmetatable({}, { __index = BlurBrush })
SmudgeBrush.__index = SmudgeBrush

SmudgeBrush.BrushId = BrushData.BlendBrushData.SmudgeBrush.brushId

local SAMPLE_INTERVAL = 3

function SmudgeBrush.new()
	local self = BlurBrush.new()
	setmetatable(self, SmudgeBrush)

	self.sampleStates = {}

	return self
end

function SmudgeBrush:CloneForReplay()
	local replayBrush = BlurBrush.CloneForReplay(self)
	-- History must not reset or overwrite the live stroke's samples on either side.
	replayBrush.sampleStates = {}
	return replayBrush
end

function SmudgeBrush:BeginStroke()
	for _, state in self.sampleStates do
		state.stepUntilSample = 0
	end
end

function SmudgeBrush:SampleSurface(sampledBuffers: Constants.BufferSet, isMirrored: boolean?)
	-- Each side carries its own pixels and advances its sampling interval once per stamp.
	local side = if isMirrored then "mirrored" else "original"
	local state = self.sampleStates[side]
	if not state then
		state = {
			stepUntilSample = 0,
			blurScratch = {},
		}
		for channel, scratch in self.blurScratch do
			state.blurScratch[channel] = if isMirrored then buffer.create(buffer.len(scratch)) else scratch
		end
		self.sampleStates[side] = state
	end
	local takeFreshSample = state.stepUntilSample == 0
	for _, channel in Constants.CHANNEL_NAMES do
		local editableImage = self.editableImages[channel]
		local sampledBuffer = sampledBuffers[channel]
		if takeFreshSample then
			self:WriteBlurredSample(channel, sampledBuffer, state.blurScratch[channel])
		else
			-- Restore the carried, unfeathered sample before applying this stamp's feathering.
			editableImage:WritePixelsBuffer(Vector2.zero, editableImage.Size, state.blurScratch[channel])
		end
		-- The carried sample is reused, but its edge always blends into the surface under this stamp.
		self:FeatherTowardSample(channel, sampledBuffer)
	end
	if takeFreshSample then
		state.stepUntilSample = SAMPLE_INTERVAL
	end
	state.stepUntilSample -= 1
end

function SmudgeBrush:getSettings()
	return {
		stampSpacingFactor = 0.1,
		brushType = Constants.STATE_BLENDING,
		colorBlendType = Enum.ImageCombineType.Overwrite,
		stampOnPenDown = false,
	}
end

function SmudgeBrush:getMinSize()
	return BrushData.BlendBrushData.SmudgeBrush.minSize
end

function SmudgeBrush:getMaxSize()
	return BrushData.BlendBrushData.SmudgeBrush.maxSize
end

function SmudgeBrush:getDefaultSize()
	return BrushData.BlendBrushData.SmudgeBrush.defaultSize
end

return SmudgeBrush
