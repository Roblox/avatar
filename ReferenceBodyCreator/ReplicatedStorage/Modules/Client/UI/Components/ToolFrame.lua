--[[
	Frame with title, meant to house various tools in panels such as the color
	picker or the horizontal pill bar.
]]

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local ToolFrame = {}

function ToolFrame.createComponentFrame(tool: GuiObject, label: string, rightContent: GuiObject?)
	local frame = Instance.new("Frame")
	frame.Name = "Tool"
	-- Most styling is done via StyleSheets via tag -- see UI/Style.lua
	StyleUtils.AddStyleTag(frame, StyleConsts.tags.ToolFrame)

	-- Title
	local toolTitleFrame = Instance.new("Frame")
	toolTitleFrame.LayoutOrder = 1
	toolTitleFrame.Name = "ToolTitle"
	toolTitleFrame.Parent = frame
	StyleUtils.AddStyleTag(toolTitleFrame, StyleConsts.tags.ToolTitle)

	local title = Instance.new("TextLabel")
	title.Text = label
	title.Name = "ToolTitleLabel"
	title.Parent = toolTitleFrame
	title.LayoutOrder = 1

	if rightContent then
		rightContent.Parent = toolTitleFrame
		rightContent.LayoutOrder = 2
	end

	-- Content
	tool.Parent = frame
	tool.LayoutOrder = 2

	return frame
end

return ToolFrame
