--[[
	Generic collapsible container, which has visible and collapsible content.
	Is passed callback for selecting and deselecting, which are called *before*
	the container is visually selected/deselected.
]]
local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local TwoStateIconButton = require(Components:WaitForChild("TwoStateIconButton"))

local CollapsibleContainer = {}
CollapsibleContainer.__index = CollapsibleContainer

function CollapsibleContainer:Deselect()
	self.onDeselectCallback()
	self:ShowCollapsibleContent(false)

	StyleUtils.RemoveStyleTag(self.visibleContentFrame, StyleConsts.tags.CollapsiblePrimarySelection)
	StyleUtils.RemoveStyleTag(self.frame, StyleConsts.tags.CollapsibleSecondarySelection)

	self.chevronButton:SetActive(false)
end

--	Used when the selected layer moves to another group, so this group
-- stops showing as selected while staying open/closed as the user left it.
function CollapsibleContainer:ClearSelectionHighlight()
	StyleUtils.RemoveStyleTag(self.visibleContentFrame, StyleConsts.tags.CollapsiblePrimarySelection)
	StyleUtils.RemoveStyleTag(self.frame, StyleConsts.tags.CollapsibleSecondarySelection)
end

-- Collapsible container is selected, but not the primary selection. This is
-- used when a child is selected, but the container itself is not.
function CollapsibleContainer:SecondarySelect()
	self:ShowCollapsibleContent(true)

	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.CollapsibleSecondarySelection)
	StyleUtils.RemoveStyleTag(self.visibleContentFrame, StyleConsts.tags.CollapsiblePrimarySelection)

	self.chevronButton:SetActive(true)
end

function CollapsibleContainer:Select()
	self.onSelectCallback()
	self:ShowCollapsibleContent(true)

	StyleUtils.AddStyleTag(self.visibleContentFrame, StyleConsts.tags.CollapsiblePrimarySelection)
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.CollapsibleSecondarySelection)

	self.chevronButton:SetActive(true)
end

function CollapsibleContainer:ShowCollapsibleContent(visible: boolean)
	self.collapsibleContentFrame.Visible = visible
	self.isCollapsed = not visible
end

-- Collapses the container if it is open, leaving an already-collapsed container
-- untouched. Selection/highlight are not affected.
function CollapsibleContainer:Collapse()
	if not self.isCollapsed then
		self:ShowCollapsibleContent(false)
		self.chevronButton:SetActive(false)
	end
end

-- Collapse/expand is independent of selection
function CollapsibleContainer:ToggleCollapse()
	self:ShowCollapsibleContent(self.isCollapsed)
	self.chevronButton:SetActive(not self.isCollapsed)
end

function CollapsibleContainer:CreateVisibleContentFrame(visibleContent: GuiObject, onActivatedCallback: () -> ()): Frame
	-- Create button to expand content; entire visible area is clickable.
	local visibleContentFrame = Instance.new("Frame")
	visibleContentFrame.Name = "VisibleContentFrame"
	StyleUtils.AddStyleTag(visibleContentFrame, StyleConsts.tags.CollapsibleContainerVisibleContent)

	local visibleContentButton = Instance.new("ImageButton")
	visibleContentButton.Name = "VisibleContentButton"
	visibleContentButton.Activated:Connect(function()
		onActivatedCallback()
	end)
	visibleContentButton.Parent = visibleContentFrame

	-- Create chevron button to indicate expand/collapse state: points down when
	-- open (active) and right when collapsed (inactive).
	self.chevronButton = TwoStateIconButton.new(StyleConsts.icons.ChevronDown, StyleConsts.icons.ChevronRight, function()
		self:ToggleCollapse()
	end)
	self.chevronButton:GetFrame().Parent = visibleContentButton
	self.chevronButton:GetFrame().LayoutOrder = 1
	StyleUtils.AddStyleTag(self.chevronButton:GetFrame(), StyleConsts.tags.CollapsibleIndicatorButton)

	visibleContent.Parent = visibleContentButton
	visibleContent.LayoutOrder = 2

	return visibleContentFrame
end

function CollapsibleContainer:CreateCollapsibleContentFrame(): Frame
	local collapsibleContentFrame = Instance.new("Frame")
	collapsibleContentFrame.Name = "CollapsibleContentFrame"

	-- Collapsed by default
	collapsibleContentFrame.Visible = false

	return collapsibleContentFrame
end

function CollapsibleContainer.new(
	visibleContent: GuiObject,
	collapsibleContent: GuiObject,
	onSelectCallback: () -> (),
	onDeselectCallback: () -> (),
	onActivatedCallback: (() -> ())?
)
	local self = {}
	setmetatable(self, CollapsibleContainer)

	self.onSelectCallback = onSelectCallback
	self.onDeselectCallback = onDeselectCallback

	self.isCollapsed = true

	self.frame = Instance.new("Frame")
	self.frame.Name = "CollapsibleContainer"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.CollapsibleContainer)

	self.visibleContentFrame = self:CreateVisibleContentFrame(visibleContent, onActivatedCallback or function()
		self:ToggleCollapse()
	end)
	self.visibleContentFrame.Parent = self.frame
	self.visibleContentFrame.LayoutOrder = 1

	self.collapsibleContentFrame = self:CreateCollapsibleContentFrame()
	collapsibleContent.Parent = self.collapsibleContentFrame
	self.collapsibleContentFrame.Parent = self.frame
	self.collapsibleContentFrame.LayoutOrder = 2

	return self
end

function CollapsibleContainer:GetFrame()
	return self.frame
end

return CollapsibleContainer
