--[[
	Popover menu that opens beneath an anchor button, showing an optional title,
	a list of selectable options, and an optional footer. Each option renders an
	optional left icon, a label, and optional right-aligned text (e.g. a price),
	and invokes its own onSelect callback when chosen.

	The menu parents itself into the ScreenGui of the anchor button on open, so
	it inherits the existing StyleLink and renders above the panel via ZIndex.
]]

local UI = script.Parent.Parent

local Components = UI:WaitForChild("Components")
local Overlay = require(Components:WaitForChild("Overlay"))
local DropdownMenuItem = require(Components:WaitForChild("DropdownMenuItem"))

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

export type DropdownOption = DropdownMenuItem.DropdownOption

export type DropdownConfig = {
	title: string?,
	footer: string?,
	options: { DropdownOption },
}

local DropdownMenu = {}
DropdownMenu.__index = DropdownMenu

function DropdownMenu.new(config: DropdownConfig)
	local self = setmetatable({}, DropdownMenu)

	-- Overlay to dismiss the menu when clicking elsewhere.
	self.overlay = Overlay.createComponentFrame(function()
		self:Close()
	end)
	self.overlay.Name = "DropdownMenuOverlay"
	self.overlay.Visible = false

	-- The popover.
	self.menuFrame = Instance.new("Frame")
	self.menuFrame.Name = "DropdownMenu"
	self.menuFrame.Visible = false
	StyleUtils.AddStyleTag(self.menuFrame, StyleConsts.tags.DropdownMenu)

	-- Lay out title, options, then footer in order; skip the optional pieces.
	local layoutOrder = 0

	if config.title then
		layoutOrder += 1
		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Text = config.title
		title.LayoutOrder = layoutOrder
		title.Parent = self.menuFrame
		StyleUtils.AddStyleTag(title, StyleConsts.tags.DropdownMenuTitle)
	end

	self.optionButtons = {}
	for _, option in config.options do
		layoutOrder += 1
		local button = DropdownMenuItem.createComponentFrame(option, function()
			self:Close()
			option.onSelect()
		end)
		button.LayoutOrder = layoutOrder
		button.Parent = self.menuFrame
		table.insert(self.optionButtons, {
			button = button,
			option = option,
		})
	end

	if config.footer then
		layoutOrder += 1
		local footer = Instance.new("TextLabel")
		footer.Name = "Footer"
		footer.Text = config.footer
		footer.LayoutOrder = layoutOrder
		footer.Parent = self.menuFrame
		StyleUtils.AddStyleTag(footer, StyleConsts.tags.DropdownMenuFooter)
	end

	return self
end

-- Opens the menu beside the given anchor button, right-aligned to it. Prefer
-- below the anchor, but flip above when the menu would extend off-screen.
function DropdownMenu:Open(anchor: GuiObject, screenGui: ScreenGui?)
	screenGui = screenGui or anchor:FindFirstAncestorWhichIsA("ScreenGui")
	if not screenGui then
		warn("DropdownMenu:Open called with an anchor not in a ScreenGui")
		return
	end

	self:Close()
	self.overlay.Parent = screenGui
	self.menuFrame.Parent = screenGui
	self:UpdateOptionStates()

	-- AutomaticSize can settle after the first open's styles and layout apply.
	self.menuSizeChangedConnection = self.menuFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:UpdatePosition(anchor, screenGui)
	end)

	self.overlay.Visible = true
	self.menuFrame.Visible = true
	self:UpdatePosition(anchor, screenGui)
end

function DropdownMenu:UpdatePosition(anchor: GuiObject, screenGui: ScreenGui)
	-- AbsolutePosition is reported offset by the top-left GUI inset, while this
	-- ScreenGui ignores that inset for its own offset coordinates. Subtract the
	-- inset to convert the button's absolute position into the menu's space.
	local topLeftInset = StyleUtils.GetTopLeftInset()
	local absPos = anchor.AbsolutePosition
	local absSize = anchor.AbsoluteSize
	local gap = StyleConsts.styleTokens.Padding.XSmall.Offset
	local anchorTop = absPos.Y - topLeftInset.Y
	local anchorRight = absPos.X + absSize.X - topLeftInset.X
	local availableBelow = screenGui.AbsoluteSize.Y - (anchorTop + absSize.Y + gap)

	if self.menuFrame.AbsoluteSize.Y > availableBelow then
		-- Anchor the bottom-right corner just above the button's top-right.
		self.menuFrame.AnchorPoint = Vector2.new(1, 1)
		self.menuFrame.Position = UDim2.fromOffset(anchorRight, anchorTop - gap)
	else
		-- Anchor the top-right corner just below the button's bottom-right.
		self.menuFrame.AnchorPoint = Vector2.new(1, 0)
		self.menuFrame.Position = UDim2.fromOffset(anchorRight, anchorTop + absSize.Y + gap)
	end
end

-- Re-evaluates stateful options so callers can keep an open menu in sync after
-- an action changes whether another option is available.
function DropdownMenu:UpdateOptionStates()
	for _, optionInfo in self.optionButtons do
		local getIsDisabled = optionInfo.option.getIsDisabled
		DropdownMenuItem.setDisabled(optionInfo.button, getIsDisabled ~= nil and getIsDisabled())
	end
end

function DropdownMenu:Close()
	if self.menuSizeChangedConnection then
		self.menuSizeChangedConnection:Disconnect()
		self.menuSizeChangedConnection = nil
	end

	self.overlay.Visible = false
	self.menuFrame.Visible = false

	-- Clear any lingering hover highlight (MouseLeave may not fire when hidden).
	for _, optionInfo in self.optionButtons do
		StyleUtils.RemoveStyleTag(optionInfo.button, StyleConsts.tags.DropdownMenuOptionHover)
	end
end

function DropdownMenu:Destroy()
	self:Close()
	self.overlay:Destroy()
	self.menuFrame:Destroy()
end

return DropdownMenu
