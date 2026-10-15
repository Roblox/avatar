--[[
	Scatters tinted image shapes instead of glitter circles. Uses ImageBrush's asset loading,
	alpha mask, and PBR support, plus BaseRandomBrush's seeded randomness for stroke replay.
]]

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Brushes = Modules:WaitForChild("Brushes")
local BaseRandomBrush = require(Brushes:WaitForChild("BaseRandomBrush"))
local BrushInfo = require(Brushes:WaitForChild("BrushInfo"))
local ImageBrush = require(Brushes:WaitForChild("ImageBrush"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureUtils = require(TextureManipulation:WaitForChild("TextureUtils"))

export type ScatterSettings = {
	stampCount: number?,
	minStampScale: number?, -- fraction of the full brush footprint, rather than world-space size
	maxStampScale: number?,
	hueVariation: number?,
	saturationVariation: number?,
	valueVariation: number?,
	opacityVariation: number?, -- maximum opacity reduction per image
	rotationVariation: number?, -- random rotation between -variation and +variation, in degrees
}

export type GlitterImageBrushInput = ImageBrush.ImageBrushInput & { scatter: ScatterSettings? }

local DEFAULT_SCATTER = {
	stampCount = 4,
	minStampScale = 0.2,
	maxStampScale = 0.8,
	hueVariation = 0,
	saturationVariation = 0.4,
	valueVariation = 0.4,
	opacityVariation = 0.5,
	rotationVariation = 180,
}

local GlitterImageBrush = setmetatable({}, { __index = ImageBrush })
GlitterImageBrush.__index = GlitterImageBrush

local DEFAULT_STAMP_SPACING_FACTOR = 0.6

-- Share the random-brush protocol so live drawing, server replay, and undo/redo use identical stamps.
GlitterImageBrush.setSeed = BaseRandomBrush.setSeed
GlitterImageBrush.getSeed = BaseRandomBrush.getSeed
GlitterImageBrush.CloneForReplay = BaseRandomBrush.CloneForReplay

local function resolveScatterSettings(input: ScatterSettings?)
	if not input then
		return DEFAULT_SCATTER
	end

	return {
		stampCount = input.stampCount or DEFAULT_SCATTER.stampCount,
		minStampScale = input.minStampScale or DEFAULT_SCATTER.minStampScale,
		maxStampScale = input.maxStampScale or DEFAULT_SCATTER.maxStampScale,
		hueVariation = input.hueVariation and math.clamp(input.hueVariation, 0, 1) or DEFAULT_SCATTER.hueVariation,
		saturationVariation = input.saturationVariation and math.clamp(input.saturationVariation, 0, 1)
			or DEFAULT_SCATTER.saturationVariation,
		valueVariation = input.valueVariation and math.clamp(input.valueVariation, 0, 1)
			or DEFAULT_SCATTER.valueVariation,
		opacityVariation = input.opacityVariation and math.clamp(input.opacityVariation, 0, 1)
			or DEFAULT_SCATTER.opacityVariation,
		rotationVariation = input.rotationVariation or DEFAULT_SCATTER.rotationVariation,
	}
end

function GlitterImageBrush.new(input: GlitterImageBrushInput)
	-- Validate before allocating images or loading the asset.
	local scatter = resolveScatterSettings(input.scatter)
	local self = ImageBrush.new(input)
	setmetatable(self, GlitterImageBrush)

	self.scatter = scatter
	self.opacity = 1
	self.isReflective = false
	self:setSeed()
	self.stampEditableImages = {} :: Constants.EditableImageSet
	for _, channel in Constants.CHANNEL_NAMES do
		self.stampEditableImages[channel] = AssetService:CreateEditableImage({ Size = self.sourceImage.Size })
	end

	return self
end

-- Dynamic decals are generated once per stamp. Changing settings must not consume randomness.
function GlitterImageBrush:UpdateTexture() end

function GlitterImageBrush:tweakColor(color: Color3): Color3
	local scatter = self.scatter
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(
		(h + self.generator:NextNumber(-scatter.hueVariation, scatter.hueVariation)) % 1,
		math.clamp(s + self.generator:NextNumber(-scatter.saturationVariation, scatter.saturationVariation), 0, 1),
		math.clamp(v + self.generator:NextNumber(-scatter.valueVariation, scatter.valueVariation), 0, 1)
	)
end

function GlitterImageBrush:getBrushEIs(): Constants.EditableImageSet
	local images = self.editableImages
	local size = images.color.Size
	local scatter = self.scatter
	local opacityScale = self:getSettings().opacityScale
	for _, image in images do
		TextureUtils.Clear(image)
	end

	for _ = 1, scatter.stampCount do
		local rotation = self.generator:NextNumber(-scatter.rotationVariation, scatter.rotationVariation)
		local radians = math.rad(rotation)
		local extentFactor = math.abs(math.cos(radians)) + math.abs(math.sin(radians))
		-- Keep the entire rotated image inside the brush footprint, including at large scales.
		local scale =
			math.min(self.generator:NextNumber(scatter.minStampScale, scatter.maxStampScale), 1 / extentFactor)
		local halfExtent = size * (scale * extentFactor / 2)
		local position = Vector2.new(
			self.generator:NextNumber(halfExtent.X, math.max(halfExtent.X, size.X - halfExtent.X)),
			self.generator:NextNumber(halfExtent.Y, math.max(halfExtent.Y, size.Y - halfExtent.Y))
		)
		local opacity = math.clamp(self.opacity - self.generator:NextNumber(0, scatter.opacityVariation), 0, 1)
		self:UpdateStampTexture(self.stampEditableImages, self:tweakColor(self.color), opacity * opacityScale)
		for channel, image in images do
			image:DrawImageTransformed(
				position,
				Vector2.new(scale, scale),
				rotation,
				self.stampEditableImages[channel],
				{
					CombineType = Enum.ImageCombineType.BlendSourceOver,
				}
			)
		end
	end

	-- Mirror this exact scatter pattern; never generate a second random pattern for the other side.
	self:UpdateMirroredTexture()
	return images
end

function GlitterImageBrush:getSettings(): BrushInfo.BrushSettings
	local settings = table.clone(self.settings)
	if settings.stampSpacingFactor == nil then
		settings.stampSpacingFactor = DEFAULT_STAMP_SPACING_FACTOR
	end
	return BrushInfo.ResolveSettings(settings)
end

function GlitterImageBrush:Destroy()
	if self.stampEditableImages then
		for _, image in self.stampEditableImages do
			image:Destroy()
		end
		self.stampEditableImages = nil
	end
	ImageBrush.Destroy(self)
end

return GlitterImageBrush
