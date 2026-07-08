--[[
	Creates a grid of interactive BaseTiles. Used for sticker and kitbashing UIs.
	Takes in a list of IconButtonInfos, and adds them to a grid based on the
	order of the list.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local BaseTile = require(Components:WaitForChild("BaseTile"))
local IconButton = require(Components:WaitForChild("IconButton"))

local TileGrid = {}

function TileGrid.createComponentFrame(gridButtonInfos: { IconButton.IconButtonInfo })
	local frame = Instance.new("Frame")
	frame.Name = "TileGridFrame"
	StyleUtils.AddStyleTag(frame, StyleConsts.tags.TileGrid)

	for i, info in gridButtonInfos do
		local tile = BaseTile.createComponentFrame(info.iconId, info.callback)
		tile.Parent = frame
		tile.LayoutOrder = i
	end

	return frame
end

return TileGrid
