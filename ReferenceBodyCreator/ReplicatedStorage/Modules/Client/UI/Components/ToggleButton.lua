--[[
	Toggle button with styling. Used for toggling reflective mode in the color
	picker.
]]

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local ToggleButton = {}

export type toggleButtonInfo = {
	label: string,
	callback: (isOn: boolean) -> (),
	-- When true, the pill starts in the "on" image state (default false).
	initialOn: boolean?,
}

local function setToggleImage(toggleButton: ImageButton, isOn: boolean)
	toggleButton.Image = if isOn then StyleConsts.uiImages.ToggleOn else StyleConsts.uiImages.ToggleOff
end

function ToggleButton.createComponentFrame(toggleButtonInfo: toggleButtonInfo)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Name = "ToggleFrame"
	StyleUtils.AddStyleTag(toggleFrame, StyleConsts.tags.ToggleFrame)

	local isOn = toggleButtonInfo.initialOn == true

	local toggleButton = Instance.new("ImageButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Parent = toggleFrame
	StyleUtils.AddStyleTag(toggleButton, StyleConsts.tags.TogglePill)
	setToggleImage(toggleButton, isOn)
	toggleButton.Activated:Connect(function()
		isOn = not isOn
		setToggleImage(toggleButton, isOn)
		toggleButtonInfo.callback(isOn)
	end)

	-- Label for the toggle
	local label = Instance.new("TextLabel")
	label.Name = "ToggleLabel"
	label.Text = toggleButtonInfo.label
	label.Parent = toggleFrame
	StyleUtils.AddStyleTag(label, StyleConsts.tags.ToggleLabel)

	return toggleFrame
end

return ToggleButton
