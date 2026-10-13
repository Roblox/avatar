--[[
	A base for random brushes. Extends BaseBrush with the seed mechanisms that all random brushes require.
    When using randomness make sure to always use self.generator to ensure server-side replay is accurate.
	This brush is not meant to be used alone, extend it to make use of randomness.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Brushes = Modules:WaitForChild("Brushes")
local BaseBrush = require(Brushes:WaitForChild("BaseBrush"))

local BaseRandomBrush = setmetatable({}, { __index = BaseBrush })
BaseRandomBrush.__index = BaseRandomBrush

local MAX_INTEGER = 2 ^ 31 - 1

function BaseRandomBrush.new(color: Color3?, opacity: number?)
	local self = BaseBrush.new(color, opacity)
	setmetatable(self, BaseRandomBrush)

	self:setSeed()

	return self
end

function BaseRandomBrush:CloneForReplay()
	local replayBrush = BaseBrush.CloneForReplay(self)
	replayBrush.generator = self.generator:Clone()
	return replayBrush
end

-- REQUIRED for random brushes. Server-side replay uses this in combination with getSeed to ensure
-- accurate replay. Set the seed whenever you want to change the behavior. Do not change the seed
-- mid-stroke. Whenever using randomness make sure to use self.generator to generate randomness.
function BaseRandomBrush:setSeed(seed: number?) 
	self.seed = if seed then seed else math.random(MAX_INTEGER)
	self.generator = Random.new(self.seed)
end

-- REQUIRED for random brushes. Server-side replay uses this in combination with setSeed to ensure
-- accurate replay
function BaseRandomBrush:getSeed() 
	return self.seed
end

return BaseRandomBrush
