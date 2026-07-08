--[[
	Displays a scrollable list of thumbnails of "equipped" items (such as
	stickers or add-ons) and a counter.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local Counter = require(Components:WaitForChild("Counter"))
local MiniBaseTileGroup = require(Components:WaitForChild("MiniBaseTileGroup"))

local ItemSelector = {}
ItemSelector.__index = ItemSelector

function ItemSelector.new(maxAddable: number, onClickTileCallback: (number) -> ())
	local self = {}
	setmetatable(self, ItemSelector)

	self.frame = Instance.new("Frame")
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.ItemSelectorFrame)

	local selectorFlexFrame = Instance.new("Frame")
	StyleUtils.AddStyleTag(selectorFlexFrame, StyleConsts.tags.ItemSelectorFlexFrame)
	selectorFlexFrame.Parent = self.frame
	selectorFlexFrame.LayoutOrder = 1

	local selectorScrollFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(selectorScrollFrame, StyleConsts.tags.ItemSelectorScrollFrame)
	selectorScrollFrame.Parent = selectorFlexFrame

	local selectorTiles = {}
	for i = 1, maxAddable do
		table.insert(selectorTiles, {
			callback = function()
				onClickTileCallback(i)
			end,
		})
	end
	self.tileGroup = MiniBaseTileGroup.new(selectorTiles)
	self.tileGroup.frame.Name = "TileGroup"
	self.tileGroup.frame.Parent = selectorScrollFrame

	self.counter = Counter.new(maxAddable)
	self.counter.frame.Parent = self.frame
	self.counter.frame.LayoutOrder = 2

	return self
end

function ItemSelector:UpdateProgress(appliedItemInfos, selectedIndex)
	self.counter:UpdateProgress(#appliedItemInfos)
	self.tileGroup:UpdateTiles(appliedItemInfos, selectedIndex)
end

return ItemSelector
