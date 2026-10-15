--[[
	Empty-state card shown in a section before any group exists. Stacks, top to
	bottom: an icon, a centered primary label, a centered smaller secondary
	label, and an action button. The caller supplies
	the strings, icon, and button callback (e.g. opening a dropdown menu).
]]

local UI = script.Parent.Parent

local Components = UI:WaitForChild("Components")
local TextButton = require(Components:WaitForChild("TextButton"))

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local GroupCard = {}

export type GroupCardConfig = {
	icon: string,
	title: string,
	subtitle: string,
	buttonText: string,
	onButtonPressed: (button: GuiObject) -> (),
}

function GroupCard.createComponentFrame(config: GroupCardConfig)
	local card = Instance.new("Frame")
	card.Name = "GroupCard"
	StyleUtils.AddStyleTag(card, StyleConsts.tags.GroupCard)

	-- Container holds the list slot and adds a gap below the icon frame.
	local iconContainer = Instance.new("Frame")
	iconContainer.Name = "GroupCardIconContainer"
	iconContainer.LayoutOrder = 1
	iconContainer.Parent = card
	StyleUtils.AddStyleTag(iconContainer, StyleConsts.tags.GroupCardIconContainer)

	local iconFrame = Instance.new("Frame")
	iconFrame.Name = "GroupCardIconFrame"
	iconFrame.Parent = iconContainer
	StyleUtils.AddStyleTag(iconFrame, StyleConsts.tags.GroupCardIconFrame)

	local icon = Instance.new("ImageLabel")
	icon.Name = "GroupCardIcon"
	icon.Image = config.icon
	icon.Parent = iconFrame
	StyleUtils.AddStyleTag(icon, StyleConsts.tags.GroupCardIcon)

	local title = Instance.new("TextLabel")
	title.Name = "GroupCardTitle"
	title.Text = config.title
	title.LayoutOrder = 2
	title.Parent = card
	StyleUtils.AddStyleTag(title, StyleConsts.tags.GroupCardTitle)

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "GroupCardSubtitle"
	subtitle.Text = config.subtitle
	subtitle.LayoutOrder = 3
	subtitle.Parent = card
	StyleUtils.AddStyleTag(subtitle, StyleConsts.tags.GroupCardSubtitle)

	local button
	button = TextButton.createComponentFrame({
		text = config.buttonText,
		callback = function()
			config.onButtonPressed(button)
		end,
	})
	button.LayoutOrder = 4
	StyleUtils.AddStyleTag(button, StyleConsts.tags.EmphasisButton)
	button.Parent = card

	return card
end

return GroupCard
