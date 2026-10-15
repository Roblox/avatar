--[[
	Non-interactive display badge: a rounded, semi-transparent capsule
	containing a single line of text with an optional leading icon.

	All visuals come from the StyleConsts.tags.Badge style rule. Callers may add
	additional style tags to the frame returned by GetFrame() to control
	placement (e.g. tags.TopBarLayerIndicator).
]]

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Badge = {}
Badge.__index = Badge

function Badge:GetFrame()
	return self.frame
end

function Badge:SetText(text: string)
	self.label.Text = text
end

function Badge:SetIcon(iconId: string?)
	self.icon.Image = iconId or ""
	self.icon.Visible = iconId ~= nil
end

function Badge:SetVisible(visible: boolean)
	self.frame.Visible = visible
end

function Badge.new(text: string?)
	local self = setmetatable({}, Badge)

	self.frame = Instance.new("Frame")
	self.frame.Name = "Badge"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.Badge)

	self.icon = Instance.new("ImageLabel")
	self.icon.Name = "Icon"
	self.icon.LayoutOrder = 1
	self.icon.Visible = false
	self.icon.Parent = self.frame

	self.label = Instance.new("TextLabel")
	self.label.Name = "Label"
	self.label.Text = text or ""
	self.label.LayoutOrder = 2
	self.label.Parent = self.frame

	return self
end

return Badge
