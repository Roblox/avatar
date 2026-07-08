--[[
	Generic text button with styling. Used primarily for modals.
]]

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local TextButton = {}

export type ButtonInfo = {
	text: string,
	callback: () -> (),
}

function TextButton.createComponentFrame(buttonInfo: ButtonInfo)
	local button = Instance.new("TextButton")
	button.Name = "TextButton"

	button.Text = buttonInfo.text
	button.Activated:Connect(buttonInfo.callback)

	-- Most styling is done via StyleSheets -- see UI/Style.lua
	StyleUtils.AddStyleTag(button, StyleConsts.tags.DefaultButton)

	return button
end

return TextButton
