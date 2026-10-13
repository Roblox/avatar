--[[
	A single selectable row in a DropdownMenu: an optional left icon, a label,
	and optional right-aligned text (e.g. a price). Highlights on hover and
	invokes onActivated when clicked.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

export type DropdownOption = {
	name: string,
	icon: string?, -- optional left icon image asset
	rightText: string?, -- optional right-aligned text (e.g. a price)
	onSelect: () -> (),
	getIsDisabled: (() -> boolean)?, -- evaluated whenever the menu opens
}

local DropdownMenuItem = {}

function DropdownMenuItem.setDisabled(button: TextButton, isDisabled: boolean)
	button.Active = not isDisabled
	button.Selectable = not isDisabled
	StyleUtils.SetStyleTag(button, StyleConsts.tags.DropdownMenuOptionDisabled, isDisabled)

	if isDisabled then
		StyleUtils.RemoveStyleTag(button, StyleConsts.tags.DropdownMenuOptionHover)
	end
end

function DropdownMenuItem.createComponentFrame(option: DropdownOption, onActivated: () -> ()): TextButton
	local button = Instance.new("TextButton")
	button.Name = "DropdownMenuOption"
	button.Text = ""
	button.Activated:Connect(function()
		if button.Active then
			onActivated()
		end
	end)
	StyleUtils.AddStyleTag(button, StyleConsts.tags.DropdownMenuOption)

	-- Highlight the row on hover (desktop only; touch has no hover state).
	button.MouseEnter:Connect(function()
		if button.Active then
			StyleUtils.AddStyleTag(button, StyleConsts.tags.DropdownMenuOptionHover)
		end
	end)
	button.MouseLeave:Connect(function()
		StyleUtils.RemoveStyleTag(button, StyleConsts.tags.DropdownMenuOptionHover)
	end)

	-- Left: optional icon + name.
	local info = Instance.new("Frame")
	info.Name = "OptionInfo"
	info.LayoutOrder = 1
	info.Parent = button
	StyleUtils.AddStyleTag(info, StyleConsts.tags.DropdownMenuOptionInfo)

	if option.icon then
		-- Size and BackgroundTransparency come from the DropdownMenuOptionInfo rule.
		local icon = Instance.new("ImageLabel")
		icon.Name = "OptionIcon"
		icon.Image = option.icon
		icon.LayoutOrder = 1
		icon.Parent = info
	end

	local name = Instance.new("TextLabel")
	name.Name = "OptionName"
	name.Text = option.name
	name.LayoutOrder = 2
	name.Parent = info

	-- Right: optional right-aligned text.
	if option.rightText then
		local rightText = Instance.new("TextLabel")
		rightText.Name = "OptionRight"
		rightText.Text = option.rightText
		rightText.LayoutOrder = 2
		rightText.Parent = button
		StyleUtils.AddStyleTag(rightText, StyleConsts.tags.DropdownMenuOptionRight)
	end

	return button
end

return DropdownMenuItem
