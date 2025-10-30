--[[
	Simple frame used as a visual divider on toolbar groups.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))

local ToolbarGroupDivider = {}

function ToolbarGroupDivider.createComponentFrame()
	local divider = Instance.new("Frame")
	divider.Name = "Divider"

	Utils.AddStyleTag(divider, StyleConsts.tags.Divider)

	return divider
end

return ToolbarGroupDivider
