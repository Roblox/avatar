--[[
	Input-sinking overlay used to provide contrast behind modals.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))

local Overlay = {}

function Overlay.createComponentFrame()
	-- Overlay should be a text button so it sinks input
	local overlay = Instance.new("TextButton")
	overlay.Text = ""
	overlay.Name = "Overlay"
	-- Most styling (including ZIndex) is done via StyleSheets -- see UI/Style.lua
	Utils.AddStyleTag(overlay, StyleConsts.tags.Overlay)

	return overlay
end

return Overlay
