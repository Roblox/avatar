--[[
	Holds one reusable brush object per brush id for client drawing and server-side stroke replay.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Config = Modules:WaitForChild("Config")
local BrushData = require(Config:WaitForChild("BrushData"))

local Brushes = Modules:WaitForChild("Brushes")
local ImageBrush = require(Brushes:WaitForChild("ImageBrush"))
local GlitterImageBrush = require(Brushes:WaitForChild("GlitterImageBrush"))
local GlitterBrush = require(Brushes:WaitForChild("GlitterBrush"))
local BaseBrush = require(Brushes:WaitForChild("BaseBrush"))
local BaseEraserBrush = require(Brushes:WaitForChild("BaseEraserBrush"))
local SoftEraserBrush = require(Brushes:WaitForChild("SoftEraserBrush"))
local BlurBrush = require(Brushes:WaitForChild("BlurBrush"))
local SmudgeBrush = require(Brushes:WaitForChild("SmudgeBrush"))
local SpeckleBlendBrush = require(Brushes:WaitForChild("SpeckleBlendBrush"))

local BrushRegistry = {}
BrushRegistry.__index = BrushRegistry

-- brushId -> constructor used to create a brush owned by a registry instance.
local brushConstructors: { [string]: any } = {
	[BrushData.PaintBrushData.BaseBrush.brushId] = BaseBrush.new,
	[BrushData.PaintBrushData.GlitterBrush.brushId] = GlitterBrush.new,
	[BrushData.EraserBrushData.BaseEraserBrush.brushId] = BaseEraserBrush.new,
	[BrushData.EraserBrushData.SoftEraserBrush.brushId] = SoftEraserBrush.new,
	[BrushData.BlendBrushData.BlurBrush.brushId] = BlurBrush.new,
	[BrushData.BlendBrushData.SmudgeBrush.brushId] = SmudgeBrush.new,
	[BrushData.BlendBrushData.SpeckleBlendBrush.brushId] = SpeckleBlendBrush.new,
}

-- Image brushes need only a BrushData entry. Adding scatter = {} opts into glitter-style images.
for _, entry in BrushData.PaintBrushData do
	if entry.textureId then
		local brushClass = if entry.scatter then GlitterImageBrush else ImageBrush
		brushConstructors[entry.brushId] = function()
			return brushClass.new(entry)
		end
	end
end

function BrushRegistry.new(): BrushRegistryClass
	local self = setmetatable({}, BrushRegistry)

	self.brushes = {} :: { [string]: any }

	return self
end

-- Returns this registry's brush instance for brushId. Callers should configure it with
-- brush:applyReplicationSettings before reading its texture. The brush is owned by the registry;
-- do not Destroy it.
function BrushRegistry:GetBrush(brushId: string)
	local brush = self.brushes[brushId]

	if not brush then
		local constructor = brushConstructors[brushId]
		if not constructor then
			error("Unknown brushId: " .. tostring(brushId))
		end
		brush = constructor()
		self.brushes[brushId] = brush
	end

	return brush
end

function BrushRegistry:Destroy()
	for brushId, brush in self.brushes do
		brush:Destroy()
		self.brushes[brushId] = nil
	end
end

export type BrushRegistryClass = typeof(BrushRegistry)

return BrushRegistry
