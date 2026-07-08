--[[
	Generic interactive tile displaying a thumbnail, for use in a grid system. Used for
	stickers and kitbashing.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local IconButton = require(Components:WaitForChild("IconButton"))

local BaseTile = {}

function BaseTile.createComponentFrame(imageAssetId, onButtonActivated)
	local frame = Instance.new("Frame")
	frame.Name = "BaseTile"
	StyleUtils.AddStyleTag(frame, StyleConsts.tags.BaseTile)

	if not imageAssetId then
		return frame
	end

	local button = IconButton.createComponentFrame(imageAssetId, onButtonActivated)
	button.Parent = frame
	StyleUtils.AddStyleTag(button, StyleConsts.tags.BaseTileButton)

	return frame
end

return BaseTile
