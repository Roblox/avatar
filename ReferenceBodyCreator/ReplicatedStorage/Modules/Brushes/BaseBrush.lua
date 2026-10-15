--[[
	A sharp circle brush. Useful as a base to extend other brushes from.
]]

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureUtils = require(TextureManipulation:WaitForChild("TextureUtils"))
local Brushes = Modules:WaitForChild("Brushes")
local BrushInfo = require(Brushes:WaitForChild("BrushInfo"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local BrushData = require(Config:WaitForChild("BrushData"))

local BaseBrush = {}
BaseBrush.__index = BaseBrush

-- Identifies the brush class for server-side reconstruction (see BrushRegistry)
-- Brushes based on BaseBrush should override this property with a unique id in BrushData
BaseBrush.BrushId = BrushData.PaintBrushData.BaseBrush.brushId

function BaseBrush.new(color: Color3?, opacity: number?)
	local self = {}
	setmetatable(self, BaseBrush)

	self.color = color or Color3.new()
	self.opacity = opacity or 1.0
	self.isReflective = false

	local size = Vector2.new(Constants.IMAGE_BRUSH_TEXTURE_SIZE, Constants.IMAGE_BRUSH_TEXTURE_SIZE)
	self.editableImages = {
		color = AssetService:CreateEditableImage({ Size = size }),
		metalness = AssetService:CreateEditableImage({ Size = size }),
		roughness = AssetService:CreateEditableImage({ Size = size }),
	} :: Constants.EditableImageSet

	self:UpdateTexture()

	return self
end

function BaseBrush:getSettings(): BrushInfo.BrushSettings
	local settings: BrushInfo.BrushSettings = {} -- Use defaults
	return settings
end

-- Resampling brushes override this to capture the surface beneath each stamp.
function BaseBrush:RequiresSurfaceSample(): boolean
	return false
end

-- Called before the first stamp of a stroke. Stateful brushes can override this to reset
-- per-stroke state.
function BaseBrush:BeginStroke() end

-- Borrow the decal images for synchronous history replay, but keep settings separate.
-- Stateful subclasses must isolate their mutable state. Do not Destroy this borrowed brush.
-- After replay, refresh static decals; dynamic brushes regenerate them on their next stamp.
function BaseBrush:CloneForReplay()
	return table.clone(self)
end

function BaseBrush:UpdateTexture()
	local images = self.editableImages
	TextureUtils.Clear(images.color)
	TextureUtils.Clear(images.metalness)
	TextureUtils.Clear(images.roughness)

	local function drawCircle(ei:EditableImage, color: Color3)
		ei:DrawCircle(
			ei.Size * 0.5,
			ei.Size.X * 0.5,
			color,
			1 - self.opacity, -- uses transparency, not opacity
			Enum.ImageCombineType.Overwrite,
			Enum.AntiAliasing.Disabled
		)
	end

	drawCircle(images.color, self.color)
	if self.isReflective then
		drawCircle(images.metalness, Constants.PBR_REFLECTIVE_METAL_COLOR)
		drawCircle(images.roughness, Constants.PBR_REFLECTIVE_ROUGH_COLOR)
	else
		drawCircle(images.metalness, Constants.PBR_DEFAULT_METAL_COLOR)
		drawCircle(images.roughness, Constants.PBR_DEFAULT_ROUGH_COLOR)
	end
end

function BaseBrush:getBrushEIs(): Constants.EditableImageSet
	return self.editableImages
end

-- Image brushes provide horizontally flipped decals for the reflected projection.
function BaseBrush:getMirroredBrushEIs(): Constants.EditableImageSet?
	return self.mirroredEditableImages
end

-- The changeable settings that are necessary for copying the current state of the brush
function BaseBrush:getReplicationSettings()
	return {
		color = self.color,
		opacity = self.opacity,
		isReflective = self.isReflective
	}
end

-- Applies replication settings to the brush
function BaseBrush:applyReplicationSettings(settings)
	if settings.color ~= nil then
		self:setColor(settings.color)
	end
	if settings.opacity ~= nil then
		self:setOpacity(settings.opacity)
	end
	if settings.isReflective ~= nil then
		self:setReflective(settings.isReflective)
	end
end

function BaseBrush:setColor(newColor: Color3)
	-- Don't update when nothing changed
	if self.color == newColor then
		return
	end
	self.color = newColor
	self:UpdateTexture()
end

function BaseBrush:setOpacity(newOpacity: number)
	if self.opacity == newOpacity then
		return
	end
	self.opacity = newOpacity
	self:UpdateTexture()
end

function BaseBrush:setReflective(isReflective: boolean): ()
	if self.isReflective == isReflective then
		return
	end
	self.isReflective = isReflective
	self:UpdateTexture()
end

function BaseBrush:Destroy()
	if self.mirroredEditableImages then
		for _, editableImage in self.mirroredEditableImages do
			editableImage:Destroy()
		end
		self.mirroredEditableImages = nil
	end
	if self.editableImages then
		for _, editableImage in self.editableImages do
			editableImage:Destroy()
		end
		self.editableImages = nil
	end
end

function BaseBrush:getMinSize()
	return BrushData.PaintBrushData.BaseBrush.minSize
end

function BaseBrush:getMaxSize()
	return BrushData.PaintBrushData.BaseBrush.maxSize
end

function BaseBrush:getDefaultSize()
	return BrushData.PaintBrushData.BaseBrush.defaultSize
end

return BaseBrush
