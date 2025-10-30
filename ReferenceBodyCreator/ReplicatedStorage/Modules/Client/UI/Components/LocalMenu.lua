--[[
	Sets up a "local menu" at the top of the screen for general editing controls:
	resetting edits, previewing accessories, and exiting the editor.
	Meant to emulate the style of the the Roblox top bar menu.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))
local IconButton = require(Components:WaitForChild("IconButton"))

local LocalMenu = {}

function LocalMenu.createComponentFrame(buttonInfos: { IconButton.IconButtonInfo })
	local localMenu = Instance.new("Frame")
	localMenu.Name = "LocalMenu"

	-- Most styling is done via StyleSheets -- see UI/Style.lua
	Utils.AddStyleTag(localMenu, StyleConsts.tags.LocalMenu)

	for i, buttonInfo in buttonInfos do
		local button = IconButton.createComponentFrame(buttonInfo.icon, buttonInfo.callback)
		button.LayoutOrder = i
		button.Parent = localMenu
		Utils.AddStyleTag(button, StyleConsts.tags.LocalMenuButton)
	end

	return localMenu
end

return LocalMenu
