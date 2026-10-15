--[[
	A soft-edged eraser. Extends the base eraser for its erasing strength/settings,
	but stamps the soft brush texture so the erase falls off toward the edges
	instead of using a hard circle.
]]

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Brushes = Modules:WaitForChild("Brushes")
local BaseEraserBrush = require(Brushes:WaitForChild("BaseEraserBrush"))
local BrushUtils = require(Brushes:WaitForChild("BrushUtils"))

local Config = Modules:WaitForChild("Config")
local BrushData = require(Config:WaitForChild("BrushData"))

local SoftEraserBrush = setmetatable({}, { __index = BaseEraserBrush })
SoftEraserBrush.__index = SoftEraserBrush

SoftEraserBrush.BrushId = BrushData.EraserBrushData.SoftEraserBrush.brushId

function SoftEraserBrush.new()
	local self = BaseEraserBrush.new()
	setmetatable(self, SoftEraserBrush)

	local loadedImage =
		AssetService:CreateEditableImageAsync(Content.fromUri(BrushData.EraserBrushData.SoftEraserBrush.textureId))
	self.sourceImage = BrushUtils.QuantizeToBrushTextureSize(loadedImage)
	loadedImage:Destroy()

	self:setOpacity(0.2)

	self:UpdateTexture()

	return self
end

function SoftEraserBrush:UpdateTexture()
	if not self.sourceImage then
		return
	end

	local size = self.editableImages.color.Size
	for _, editableImage in self.editableImages do
		-- Reset to a fully transparent stamp.
		editableImage:DrawRectangle(Vector2.zero, size, self.color, 1, Enum.ImageCombineType.Overwrite)
		-- Bring in the soft shape's alpha; color stays the eraser color.
		editableImage:DrawImage(Vector2.zero, self.sourceImage, Enum.ImageCombineType.Add)
		-- Scale the stamp alpha by the eraser strength (transparency, matching BaseBrush).
		editableImage:DrawRectangle(
			Vector2.zero,
			size,
			self.color,
			1 - self.opacity,
			Enum.ImageCombineType.Multiply
		)
	end
end

function SoftEraserBrush:Destroy()
	if self.sourceImage then
		self.sourceImage:Destroy()
		self.sourceImage = nil
	end
	BaseEraserBrush.Destroy(self)
end

function SoftEraserBrush:getMinSize()
	return BrushData.EraserBrushData.SoftEraserBrush.minSize
end

function SoftEraserBrush:getMaxSize()
	return BrushData.EraserBrushData.SoftEraserBrush.maxSize
end

function SoftEraserBrush:getDefaultSize()
	return BrushData.EraserBrushData.SoftEraserBrush.defaultSize
end

return SoftEraserBrush
