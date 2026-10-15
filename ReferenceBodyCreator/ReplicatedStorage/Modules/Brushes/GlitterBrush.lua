--[[
	A glitter brush. Useful as an example of a random brush.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureUtils = require(TextureManipulation:WaitForChild("TextureUtils"))

local Brushes = Modules:WaitForChild("Brushes")
local BaseRandomBrush = require(Brushes:WaitForChild("BaseRandomBrush"))
local BrushInfo = require(Brushes:WaitForChild("BrushInfo"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local BrushData = require(Config:WaitForChild("BrushData"))

local GlitterBrush = setmetatable({}, { __index = BaseRandomBrush })
GlitterBrush.__index = GlitterBrush

GlitterBrush.BrushId = BrushData.PaintBrushData.GlitterBrush.brushId

local NUM_GLITTER_DOTS = 4
local HUE_VARIATION = 0 -- no hue variation for now
local MIN_GLITTER_RADIUS = 1
local MAX_GLITTER_RADIUS = 5
local SATURATION_VARIATION = 0.4
local VALUE_VARIATION = 0.4
local STAMP_SPACING_FACTOR = 0.6

function GlitterBrush.new()
	local self = BaseRandomBrush.new()
	setmetatable(self, GlitterBrush)

	return self
end

function GlitterBrush:tweakColor(color: Color3): Color3
	local h, s, v = color:ToHSV()
	local new_h = h
	_, new_h = math.modf(h + self.generator:NextNumber(-HUE_VARIATION, HUE_VARIATION))
	local new_s = math.clamp(s + self.generator:NextNumber(-SATURATION_VARIATION, SATURATION_VARIATION), 0, 1)
	local new_v = math.clamp(v + self.generator:NextNumber(-VALUE_VARIATION, VALUE_VARIATION), 0, 1)
	return Color3.fromHSV(new_h, new_s, new_v)
end

function GlitterBrush:getBrushEIs(): Constants.EditableImageSet
	local images = self.editableImages
	local size = images.color.Size

	for _, EI in images do
		TextureUtils.Clear(EI)
	end

	for i = 1, NUM_GLITTER_DOTS do
		local glitterSize = self.generator:NextInteger(MIN_GLITTER_RADIUS, MAX_GLITTER_RADIUS)
		local xPos = self.generator:NextInteger(glitterSize, size.X - glitterSize - 1) -- in a random position
		local yPos = self.generator:NextInteger(glitterSize, size.Y - glitterSize - 1)
		local opacity = math.clamp(1 - self.opacity + self.generator:NextNumber(0, 1), 0, 1)
		local function drawCircle(ei: EditableImage, color: Color3)
			ei:DrawCircle(
				Vector2.new(xPos, yPos),
				glitterSize,
				color,
				opacity,
				Enum.ImageCombineType.Overwrite,
				Enum.AntiAliasing.Disabled
			)
		end
		drawCircle(images.color, self:tweakColor(self.color))
		if self.isReflective then
			drawCircle(images.metalness, Constants.PBR_REFLECTIVE_METAL_COLOR)
			drawCircle(images.roughness, Constants.PBR_REFLECTIVE_ROUGH_COLOR)
		else
			drawCircle(images.metalness, Constants.PBR_DEFAULT_METAL_COLOR)
			drawCircle(images.roughness, Constants.PBR_DEFAULT_ROUGH_COLOR)
		end
	end
	return images
end

function GlitterBrush:getSettings()
	local settings: BrushInfo.BrushSettings = {
		stampSpacingFactor = STAMP_SPACING_FACTOR,
	}
	return settings
end

function GlitterBrush:getMinSize()
	return BrushData.PaintBrushData.GlitterBrush.minSize
end

function GlitterBrush:getMaxSize()
	return BrushData.PaintBrushData.GlitterBrush.maxSize
end

function GlitterBrush:getDefaultSize()
	return BrushData.PaintBrushData.GlitterBrush.defaultSize
end

return GlitterBrush
