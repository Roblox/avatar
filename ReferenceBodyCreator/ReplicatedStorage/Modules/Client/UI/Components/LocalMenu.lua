--[[
	Sets up a "local menu" at the top of the screen for general editing controls:
	resetting edits, previewing accessories, and exiting the editor.
	Meant to emulate the style of the the Roblox top bar menu.
]]

local GuiService = game:GetService("GuiService")

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local LocalMenuButtonGroup = require(Components:WaitForChild("LocalMenuButtonGroup"))

local LocalMenu = {}

function LocalMenu.createComponentFrame(localMenuButtonGroupInfos: { LocalMenuButtonGroup.localMenuButtonGroupInfo })
	local localMenu = Instance.new("Frame")
	localMenu.Name = "LocalMenu"

	-- Most styling is done via StyleSheets -- see UI/Style.lua
	if GuiService:IsTenFootInterface() then
		StyleUtils.AddStyleTag(localMenu, StyleConsts.tags.LocalMenuConsole)
	else
		StyleUtils.AddStyleTag(localMenu, StyleConsts.tags.LocalMenu)
	end

	for i, buttonGroupInfo in localMenuButtonGroupInfos do
		local buttonGroup = LocalMenuButtonGroup.createComponentFrame(buttonGroupInfo)
		buttonGroup.LayoutOrder = i
		buttonGroup.Parent = localMenu
	end

	return localMenu
end

return LocalMenu
