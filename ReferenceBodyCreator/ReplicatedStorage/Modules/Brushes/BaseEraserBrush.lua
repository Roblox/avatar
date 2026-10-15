--[[
	A sharp circle eraser. Useful to extend from for other eraser brushes.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Brushes = Modules:WaitForChild("Brushes")
local BrushInfo = require(Brushes:WaitForChild("BrushInfo"))
local BaseBrush = require(Brushes:WaitForChild("BaseBrush"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local BrushData = require(Config:WaitForChild("BrushData"))

local BaseEraserBrush = setmetatable({}, { __index = BaseBrush })
BaseEraserBrush.__index = BaseEraserBrush

BaseEraserBrush.BrushId = BrushData.EraserBrushData.BaseEraserBrush.brushId

function BaseEraserBrush.new()
	local self = BaseBrush.new(Color3.new(1, 1, 1), 1)
	setmetatable(self, BaseEraserBrush)

	return self
end

function BaseEraserBrush:getSettings(): BrushInfo.BrushSettings
	local settings = BaseBrush.getSettings(self)
	settings.brushType = Constants.STATE_ERASING
	return settings
end

function BaseEraserBrush:getMinSize()
	return BrushData.EraserBrushData.BaseEraserBrush.minSize
end

function BaseEraserBrush:getMaxSize()
	return BrushData.EraserBrushData.BaseEraserBrush.maxSize
end

function BaseEraserBrush:getDefaultSize()
	return BrushData.EraserBrushData.BaseEraserBrush.defaultSize
end

return BaseEraserBrush
