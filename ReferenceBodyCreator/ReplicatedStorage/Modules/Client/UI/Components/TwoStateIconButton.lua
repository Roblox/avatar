--[[
	Icon button with two toggleable states: active and inactive.
	These states are not toggled automatically, but should be controlled by
	the parent component via the SetActive method. The state change may be
	dependent on other factors, so the component allows for flexibility.
]]

local UI = script.Parent.Parent

local Components = UI:WaitForChild("Components")
local IconButton = require(Components:WaitForChild("IconButton"))

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local TwoStateIconButton = {}
TwoStateIconButton.__index = TwoStateIconButton

function TwoStateIconButton:GetFrame()
	return self.iconButton
end

function TwoStateIconButton:SetActive(isActive: boolean)
	self.isActive = isActive
	if isActive then
		self.imageLabel.Image = self.activeIconId
	else
		self.imageLabel.Image = self.inactiveIconId
	end
end

-- Enables or disables interaction with the button. A disabled button stays visible
-- but is faded and no longer fires its callback.
function TwoStateIconButton:SetEnabled(isEnabled: boolean)
	StyleUtils.SetStyleTag(self.iconButton, StyleConsts.tags.IconButtonMuted, not isEnabled)
end

function TwoStateIconButton.new(activeIconId: string, inactiveIconId: string?, callback: (isActive: boolean?) -> ())
	local self = {}
	setmetatable(self, TwoStateIconButton)

	self.activeIconId = activeIconId
	self.inactiveIconId = inactiveIconId

	self.isActive = false

	self.iconButton = IconButton.createComponentFrame(inactiveIconId, function()
		callback(self.isActive)
	end)
	self.imageLabel = self.iconButton.ImageLabel

	return self
end

return TwoStateIconButton
