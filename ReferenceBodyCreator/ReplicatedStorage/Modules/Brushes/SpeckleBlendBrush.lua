--[[
	A speckle blend brush: swaps randomly selected colors from the sampled surface
	within the circular brush area.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Brushes = Modules:WaitForChild("Brushes")
local BaseRandomBrush = require(Brushes:WaitForChild("BaseRandomBrush"))
local BlurBrush = require(Brushes:WaitForChild("BlurBrush"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local BrushData = require(Config:WaitForChild("BrushData"))

local SpeckleBlendBrush = setmetatable({}, { __index = BlurBrush })
SpeckleBlendBrush.__index = SpeckleBlendBrush

SpeckleBlendBrush.BrushId = BrushData.BlendBrushData.SpeckleBlendBrush.brushId

local SPECKLES = 30

-- Returns the byte offset of a uniformly selected pixel whose center is inside
-- the brush circle.
local function randomPixelOffsetInCircle(generator: Random, size: Vector2): number
	local width = size.X
	local height = size.Y
	local centerX = width * 0.5
	local centerY = height * 0.5
	local radius = math.min(width, height) * 0.5
	local radiusSquared = radius * radius

	while true do
		local x = generator:NextInteger(0, width - 1)
		local y = generator:NextInteger(0, height - 1)
		local offsetX = x + 0.5 - centerX
		local offsetY = y + 0.5 - centerY

		if offsetX * offsetX + offsetY * offsetY <= radiusSquared then
			return (y * width + x) * 4
		end
	end
end

local function swapPixelColors(pixelBuffer: buffer, offset1: number, offset2: number)
	local red1 = buffer.readu8(pixelBuffer, offset1)
	local green1 = buffer.readu8(pixelBuffer, offset1 + 1)
	local blue1 = buffer.readu8(pixelBuffer, offset1 + 2)
	local alpha1 = buffer.readu8(pixelBuffer, offset1 + 3)

	buffer.writeu8(pixelBuffer, offset1, buffer.readu8(pixelBuffer, offset2))
	buffer.writeu8(pixelBuffer, offset1 + 1, buffer.readu8(pixelBuffer, offset2 + 1))
	buffer.writeu8(pixelBuffer, offset1 + 2, buffer.readu8(pixelBuffer, offset2 + 2))
	buffer.writeu8(pixelBuffer, offset1 + 3, buffer.readu8(pixelBuffer, offset2 + 3))
	buffer.writeu8(pixelBuffer, offset2, red1)
	buffer.writeu8(pixelBuffer, offset2 + 1, green1)
	buffer.writeu8(pixelBuffer, offset2 + 2, blue1)
	buffer.writeu8(pixelBuffer, offset2 + 3, alpha1)
end

function SpeckleBlendBrush.new()
	local self = BlurBrush.new()
	setmetatable(self, SpeckleBlendBrush)
	self:setSeed()

	return self
end

function SpeckleBlendBrush:CloneForReplay()
	local replayBrush = BlurBrush.CloneForReplay(self)
	replayBrush.generator = self.generator:Clone()
	return replayBrush
end

function SpeckleBlendBrush:SampleSurface(sampledBuffers: Constants.BufferSet)
	-- Copy each channel's sampled surface into its scratch buffer.
	local size
	for _, channel in Constants.CHANNEL_NAMES do
		local editableImage = self.editableImages[channel]
		size = editableImage.Size
		buffer.copy(self.blurScratch[channel], 0, sampledBuffers[channel])
	end

	-- Pick each swap once and apply it to every channel so a texel's full PBR data
	-- moves together. Advancing self.generator identically regardless of channel count
	-- keeps server-side replay accurate.
	for _ = 1, SPECKLES do
		local offset1 = randomPixelOffsetInCircle(self.generator, size)
		local offset2 = randomPixelOffsetInCircle(self.generator, size)
		for _, channel in Constants.CHANNEL_NAMES do
			swapPixelColors(self.blurScratch[channel], offset1, offset2)
		end
	end

	for _, channel in Constants.CHANNEL_NAMES do
		local editableImage = self.editableImages[channel]
		editableImage:WritePixelsBuffer(Vector2.zero, editableImage.Size, self.blurScratch[channel])
	end
end

-- SpeckleBlendBrush derives from BlurBrush, so explicitly mix in the seed API
-- shared by random brushes.
SpeckleBlendBrush.setSeed = BaseRandomBrush.setSeed
SpeckleBlendBrush.getSeed = BaseRandomBrush.getSeed

function SpeckleBlendBrush:getSettings()
	return {
		stampSpacingFactor = 0.1,
		brushType = Constants.STATE_BLENDING,
		colorBlendType = Enum.ImageCombineType.Overwrite,
	}
end

function SpeckleBlendBrush:getMinSize()
	return BrushData.BlendBrushData.SpeckleBlendBrush.minSize
end

function SpeckleBlendBrush:getMaxSize()
	return BrushData.BlendBrushData.SpeckleBlendBrush.maxSize
end

function SpeckleBlendBrush:getDefaultSize()
	return BrushData.BlendBrushData.SpeckleBlendBrush.defaultSize
end

return SpeckleBlendBrush
