--[[
	Creates a panel that houses various tools for texture and mesh editing.
	Dynamically restyles for mobile and desktop.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local IconButton = require(Components:WaitForChild("IconButton"))

local Panel = {}

local function createHeaderBar(title, onClose, onTrash)
	local headerBar = Instance.new("Frame")
	headerBar.Name = "PanelHeaderBar"
	StyleUtils.AddStyleTag(headerBar, StyleConsts.tags.PanelHeader)

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Parent = headerBar
	titleLabel.Name = "TitleLabel"
	titleLabel.Text = title

	-- Icon Buttons
	local iconsFrame = Instance.new("Frame")
	iconsFrame.Parent = headerBar
	iconsFrame.Name = "IconFrame"

	local trashButton = IconButton.createComponentFrame(StyleConsts.icons.Delete, onTrash)
	trashButton.Parent = iconsFrame
	trashButton.LayoutOrder = 3
	StyleUtils.AddStyleTag(trashButton, StyleConsts.tags.MediumIconButton)

	local closeButton = IconButton.createComponentFrame(StyleConsts.icons.XButton, onClose)
	closeButton.Parent = iconsFrame
	closeButton.LayoutOrder = 4
	StyleUtils.AddStyleTag(closeButton, StyleConsts.tags.MediumIconButton)

	return headerBar
end

function Panel.createComponentFrame(title, onClose, onTrash, toolFrames: { GuiObject })
	local self = {}
	setmetatable(self, Panel)

	self.panel = Instance.new("Frame")
	self.panel.Name = "Panel"

	-- Most styling is done via StyleSheets -- see UI/Style.lua
	StyleUtils.AddStyleTag(self.panel, StyleConsts.tags.Panel)

	local headerBar = createHeaderBar(title, onClose, onTrash)
	headerBar.Parent = self.panel

	local toolsContainer = Instance.new("Frame")
	toolsContainer.Name = "ToolsContainer"
	StyleUtils.AddStyleTag(toolsContainer, StyleConsts.tags.PanelToolsContainer)
	for i, tool in toolFrames do
		tool.Parent = toolsContainer
		tool.LayoutOrder = i
	end
	toolsContainer.Parent = self.panel

	return self.panel
end

return Panel
