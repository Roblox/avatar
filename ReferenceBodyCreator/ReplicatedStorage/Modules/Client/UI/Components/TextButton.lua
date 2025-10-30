--[[
	Generic text button with styling. Used primarily for modals.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))

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
	Utils.AddStyleTag(button, StyleConsts.tags.DefaultButton)

	return button
end

return TextButton
