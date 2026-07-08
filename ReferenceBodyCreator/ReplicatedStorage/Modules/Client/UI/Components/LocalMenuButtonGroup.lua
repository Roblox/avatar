--[[
	Grouped buttons for the local menu. This is used for the buttons that appear
	at the top of the screen while editing. Can be singular or a group.
]]

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local IconButton = require(Components:WaitForChild("IconButton"))

export type localMenuButtonGroupInfo = { { IconButton.IconButtonInfo } }

local LocalMenuButtonGroup = {}
function LocalMenuButtonGroup.createComponentFrame(localMenuButtonGroupInfo: localMenuButtonGroupInfo)
	local localMenuButtonGroup = Instance.new("Frame")
	localMenuButtonGroup.Name = "LocalMenuButtonGroup"

	for i, buttonInfo in localMenuButtonGroupInfo do
		local button = IconButton.createComponentFrame(buttonInfo.iconId, buttonInfo.callback)
		button.LayoutOrder = i * 2
		button.Parent = localMenuButtonGroup
		StyleUtils.AddStyleTag(button, StyleConsts.tags.LocalMenuButton)
	end

	-- Most styling is done via StyleSheets -- see UI/Style.lua
	StyleUtils.AddStyleTag(localMenuButtonGroup, StyleConsts.tags.LocalMenuButtonGroup)

	return localMenuButtonGroup
end

return LocalMenuButtonGroup
