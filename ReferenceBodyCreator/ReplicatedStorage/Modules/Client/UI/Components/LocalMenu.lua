--[[
	Sets up a "local menu" at the top of the screen for general editing controls:
	undoing and redoing, resetting edits, previewing accessories, and exiting.
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

-- Returns the menu, a callback that re-evaluates any stateful button getters,
-- and the button group frames.
function LocalMenu.createComponentFrame(localMenuButtonGroupInfos: { LocalMenuButtonGroup.localMenuButtonGroupInfo })
	local localMenu = Instance.new("Frame")
	localMenu.Name = "LocalMenu"
	local buttonGroupStateUpdaters = {}
	local buttonGroups = {}

	-- Most styling is done via StyleSheets -- see UI/Style.lua
	if GuiService:IsTenFootInterface() then
		StyleUtils.AddStyleTag(localMenu, StyleConsts.tags.LocalMenuConsole)
	else
		StyleUtils.AddStyleTag(localMenu, StyleConsts.tags.LocalMenu)
	end

	for i, buttonGroupInfo in localMenuButtonGroupInfos do
		local buttonGroup, updateButtonGroupStates = LocalMenuButtonGroup.createComponentFrame(buttonGroupInfo)
		buttonGroup.LayoutOrder = i
		buttonGroup.Parent = localMenu
		table.insert(buttonGroups, buttonGroup)
		table.insert(buttonGroupStateUpdaters, updateButtonGroupStates)
	end

	local updateButtonStates = function()
		for _, updateButtonGroupStates in buttonGroupStateUpdaters do
			updateButtonGroupStates()
		end
	end

	return localMenu, updateButtonStates, buttonGroups
end

return LocalMenu
