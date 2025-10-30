--[[
	Creates a grid of interactive BaseTiles. Used for sticker and kitbashing UIs.
	Takes in a list of IconButtonInfos, and adds them to a grid based on the
	order of the list.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))
local BaseTile = require(Components:WaitForChild("BaseTile"))
local IconButton = require(Components:WaitForChild("IconButton"))

local TileGrid = {}

function TileGrid.createComponentFrame(gridButtonInfos: { IconButton.IconButtonInfo })
	local frame = Instance.new("Frame")
	frame.Name = "TileGridFrame"
	Utils.AddStyleTag(frame, StyleConsts.tags.TileGrid)

	for i, info in gridButtonInfos do
		local tile = BaseTile.createComponentFrame(info.iconId, info.callback)
		tile.Parent = frame
		tile.LayoutOrder = i
	end

	return frame
end

return TileGrid
