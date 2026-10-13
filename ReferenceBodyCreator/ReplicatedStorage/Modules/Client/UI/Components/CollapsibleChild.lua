--[[
	Child of collapsible container, which itself has collapsible content that is
	hidden when unselected. Used in the layer editor to contain the layer tiles
	and opacity sliders.
]]

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local CollapsibleChild = {}
CollapsibleChild.__index = CollapsibleChild

function CollapsibleChild:Select()
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.CollapsiblePrimarySelection)
	self.collapsibleContentFrame.Visible = true
	self.selectionButton.Active = false
end

function CollapsibleChild:Deselect()
	StyleUtils.RemoveStyleTag(self.frame, StyleConsts.tags.CollapsiblePrimarySelection)
	self.collapsibleContentFrame.Visible = false
	self.selectionButton.Active = true
end

function CollapsibleChild:GetFrame()
	return self.frame
end

function CollapsibleChild.new(topContent: GuiObject, collapsibleContent: GuiObject, onSelectCallback: () -> ())
	local self = {}
	setmetatable(self, CollapsibleChild)

	self.frame = Instance.new("Frame")
	self.frame.Name = "CollapsibleChild"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.CollapsibleChild)

	-- Selection button, also parents the content frames
	self.selectionButton = Instance.new("ImageButton")
	self.selectionButton.Name = "SelectionButton"
	self.selectionButton.Parent = self.frame
	self.selectionButton.Activated:Connect(function()
		onSelectCallback()
		self:Select()
	end)

	local topContentFrame = Instance.new("Frame")
	topContentFrame.Name = "TopContentFrame"
	topContentFrame.Parent = self.selectionButton
	topContent.Parent = topContentFrame
	topContent.LayoutOrder = 1

	self.collapsibleContentFrame = Instance.new("Frame")
	self.collapsibleContentFrame.Name = "CollapsibleContent"
	self.collapsibleContentFrame.Parent = self.selectionButton
	collapsibleContent.Parent = self.collapsibleContentFrame
	self.collapsibleContentFrame.Visible = false
	self.collapsibleContentFrame.LayoutOrder = 2

	return self
end

function CollapsibleChild:Destroy()
	self.frame:Destroy()
end

return CollapsibleChild
