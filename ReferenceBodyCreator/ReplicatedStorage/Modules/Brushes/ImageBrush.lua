--[[
	An image-based brush. The source alpha defines the shape; the selected color tints it.
]]

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Brushes = Modules:WaitForChild("Brushes")
local Config = Modules:WaitForChild("Config")

local BaseBrush = require(Brushes:WaitForChild("BaseBrush"))
local BrushInfo = require(Brushes:WaitForChild("BrushInfo"))
local BrushUtils = require(Brushes:WaitForChild("BrushUtils"))

local Constants = require(Config:WaitForChild("Constants"))

local ImageBrush = setmetatable({}, { __index = BaseBrush }) --Extend BaseBrush
ImageBrush.__index = ImageBrush

export type ImageBrushInput = {
	textureId: string,
	brushId: string,
	settings: BrushInfo.BrushSettings?,
	minSize: number,
	maxSize: number,
	defaultSize: number,
}

function ImageBrush.new(input: ImageBrushInput)
	local self = {}
	setmetatable(self, ImageBrush)

	self.BrushId = input.brushId
	self.settings = input.settings or {}
	self.minSize = input.minSize
	self.maxSize = input.maxSize
	self.defaultSize = input.defaultSize
	self.color = Color3.new()

	-- Load the configured brush shape and quantize it to the brush texture size.
	-- only alpha is read, UpdateTexture supplies the color.
	local loadedImage = AssetService:CreateEditableImageAsync(Content.fromUri(input.textureId))
	self.sourceImage = BrushUtils.QuantizeToBrushTextureSize(loadedImage)
	loadedImage:Destroy()

	self.editableImages = {
		color = AssetService:CreateEditableImage({ Size = self.sourceImage.Size }),
		metalness = AssetService:CreateEditableImage({ Size = self.sourceImage.Size }),
		roughness = AssetService:CreateEditableImage({ Size = self.sourceImage.Size }),
	} :: Constants.EditableImageSet
	self.mirroredEditableImages = {
		color = AssetService:CreateEditableImage({ Size = self.sourceImage.Size }),
		metalness = AssetService:CreateEditableImage({ Size = self.sourceImage.Size }),
		roughness = AssetService:CreateEditableImage({ Size = self.sourceImage.Size }),
	} :: Constants.EditableImageSet

	self:UpdateTexture()

	return self
end

-- Recolors the brush shape with the current color and set opacityScale, keeping the
-- source alpha as a soft falloff mask.
function ImageBrush:UpdateStampTexture(images: Constants.EditableImageSet, color: Color3, opacityScale: number)
	local size = images.color.Size
	for _, EI in images do
		-- reset the color to white, alpha to 0
		EI:DrawRectangle(Vector2.zero, size, Color3.new(1, 1, 1), 1, Enum.ImageCombineType.Overwrite)
		-- add in the alpha to our image, color stays white
		EI:DrawImage(Vector2.zero, self.sourceImage, Enum.ImageCombineType.Add)
	end

	-- multiply to set the color of the entire image
	images.color:DrawRectangle(Vector2.zero, size, color, 1 - opacityScale, Enum.ImageCombineType.Multiply)
	images.metalness:DrawRectangle(
		Vector2.zero,
		size,
		if self.isReflective then Constants.PBR_REFLECTIVE_METAL_COLOR else Constants.PBR_DEFAULT_METAL_COLOR,
		1 - opacityScale,
		Enum.ImageCombineType.Multiply
	)
	images.roughness:DrawRectangle(
		Vector2.zero,
		size,
		if self.isReflective then Constants.PBR_REFLECTIVE_ROUGH_COLOR else Constants.PBR_DEFAULT_ROUGH_COLOR,
		1 - opacityScale,
		Enum.ImageCombineType.Multiply
	)
end

function ImageBrush:UpdateMirroredTexture()
	local images = self.editableImages
	local size = images.color.Size
	-- Reflecting the projection's direction and up vector reverses its horizontal axis.
	-- Flip each decal to compensate, refreshing only when the brush texture changes.
	for channel, image in images do
		self.mirroredEditableImages[channel]:DrawImageTransformed(size / 2, Vector2.new(-1, 1), 0, image, {
			CombineType = Enum.ImageCombineType.Overwrite,
			SamplingMode = Enum.ResamplerMode.Pixelated,
		})
	end
end

function ImageBrush:UpdateTexture()
	self:UpdateStampTexture(self.editableImages, self.color, self:getSettings().opacityScale)
	self:UpdateMirroredTexture()
end

function ImageBrush:getSettings(): BrushInfo.BrushSettings
	return BrushInfo.ResolveSettings(self.settings)
end

function ImageBrush:Destroy()
	if self.sourceImage then
		self.sourceImage:Destroy()
		self.sourceImage = nil
	end
	-- Frees the original and mirrored color/metalness/roughness decals.
	BaseBrush.Destroy(self)
end

function ImageBrush:getMinSize()
	return self.minSize
end

function ImageBrush:getMaxSize()
	return self.maxSize
end

function ImageBrush:getDefaultSize()
	return self.defaultSize
end

return ImageBrush
