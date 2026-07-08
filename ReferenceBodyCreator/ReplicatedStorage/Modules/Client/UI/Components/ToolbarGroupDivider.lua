--[[
	Simple frame used as a visual divider on toolbar groups.
]]

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local ToolbarGroupDivider = {}

function ToolbarGroupDivider.createComponentFrame()
	local divider = Instance.new("Frame")
	divider.Name = "Divider"

	StyleUtils.AddStyleTag(divider, StyleConsts.tags.Divider)

	return divider
end

return ToolbarGroupDivider
