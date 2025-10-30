--[[
	Generic interactive tile displaying a thumbnail, for use in a grid system. Used for
	stickers and kitbashing.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))
local IconButton = require(Components:WaitForChild("IconButton"))

local BaseTile = {}

function BaseTile.createComponentFrame(imageAssetId, onButtonActivated)
	local frame = Instance.new("Frame")
	frame.Name = "BaseTile"
	Utils.AddStyleTag(frame, StyleConsts.tags.BaseTile)

	local button = IconButton.createComponentFrame(imageAssetId, onButtonActivated)
	button.Parent = frame
	Utils.AddStyleTag(button, StyleConsts.tags.BaseTileButton)

	return frame
end

return BaseTile
