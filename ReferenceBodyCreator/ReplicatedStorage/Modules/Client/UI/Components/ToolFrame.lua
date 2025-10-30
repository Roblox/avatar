--[[
	Frame with title, meant to house various tools in panels such as the color
	picker or the horizontal pill bar.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")

local UI = Client:WaitForChild("UI")
local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))

local ToolFrame = {}

function ToolFrame.createComponentFrame(tool: GuiObject, label: string)
	local frame = Instance.new("Frame")
	frame.Name = "Tool"
	-- Most styling is done via StyleSheets via tag -- see UI/Style.lua
	Utils.AddStyleTag(frame, StyleConsts.tags.ToolFrame)

	-- Title
	local toolTitleFrame = Instance.new("Frame")
	-- In the future, we may want to accommodate other gui objects in the header, such as a toggle.
	toolTitleFrame.LayoutOrder = 1
	toolTitleFrame.Name = "ToolTitle"
	toolTitleFrame.Parent = frame
	Utils.AddStyleTag(toolTitleFrame, StyleConsts.tags.ToolTitle)

	local title = Instance.new("TextLabel")
	title.Text = label
	title.Name = "ToolTitleLabel"
	title.Parent = toolTitleFrame

	-- Content
	tool.Parent = frame
	tool.LayoutOrder = 2

	return frame
end

return ToolFrame
