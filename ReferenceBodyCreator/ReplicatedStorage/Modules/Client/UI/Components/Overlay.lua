--[[
	Input-sinking overlay used to provide contrast behind modals.
]]

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Overlay = {}

function Overlay.createComponentFrame()
	-- Overlay should be a text button so it sinks input
	local overlay = Instance.new("TextButton")
	overlay.Text = ""
	overlay.Name = "Overlay"
	-- Most styling (including ZIndex) is done via StyleSheets -- see UI/Style.lua
	StyleUtils.AddStyleTag(overlay, StyleConsts.tags.Overlay)

	return overlay
end

return Overlay
