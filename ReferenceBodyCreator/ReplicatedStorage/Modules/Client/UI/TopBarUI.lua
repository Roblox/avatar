--[[
	Creates the ScreenGUI and components for the top bar menu used in the editor.
	Called in BaseUI, alongside other UIs used for editing.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local Config = Modules:WaitForChild("Config")
local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")
local StyleConsts = require(UI:WaitForChild("StyleConsts"))
local Utils = require(Modules:WaitForChild("Utils"))

local ConfigConsts = require(Config:WaitForChild("Constants"))

local LocalMenu = require(Components:WaitForChild("LocalMenu"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local TopBarUI = {}
TopBarUI.__index = TopBarUI

function TopBarUI.new(baseUI, manager)
	local self = {}
	setmetatable(self, TopBarUI)

	self.baseUI = baseUI
	self.manager = manager

	-- Avatar preview should only be shown for accessories
	local showAvatarPreview = manager.modelInfo:GetCreationType() == ConfigConsts.CREATION_TYPES.Accessory

	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
	self.screenGui.Name = "TopBarUI"
	self.screenGui.Parent = PlayerGui
	-- Render below other screenGuis
	self.displayOrder = 0

	-- Create and link styleSheet
	local style = baseUI.style
	style:LinkGui(self.screenGui)

	local editorInfos = {}
	local previewInfos = nil

	-- Reset Button
	local onDestroy = function()
		baseUI.ResetEditsModalUI:Open()
	end
	local destroyButtonInfo = {
		icon = StyleConsts.icons.ResetChanges,
		callback = onDestroy,
	}
	table.insert(editorInfos, destroyButtonInfo)

	-- Exit Button
	local onExit = function()
		manager:Quit()
	end
	local exitButtonInfo = {
		icon = StyleConsts.icons.ExitEditor,
		callback = onExit,
	}
	table.insert(editorInfos, exitButtonInfo)

	-- Avatar Preview Button and Preview Menu, if applicable
	if showAvatarPreview then
		local onPreview = function()
			self:SwitchToAvatarPreview()
		end
		local previewButtonInfo = {
			icon = StyleConsts.icons.AvatarPreview,
			callback = onPreview,
		}
		table.insert(editorInfos, 2, previewButtonInfo) -- Insert at second position

		local modelName = manager.modelInfo:GetBlankName()

		local onEditorReturn = function()
			self:SwitchToEditor()
		end
		local returnButtonInfo = {
			icon = StyleConsts.editorIcons[modelName],
			callback = onEditorReturn,
		}
		previewInfos = { returnButtonInfo, exitButtonInfo }
	end

	-- Create local menus
	self.editorMenu = LocalMenu.createComponentFrame(editorInfos)
	self.editorMenu.Parent = self.screenGui
	self.editorMenu.Name = "EditorLocalMenu"
	if showAvatarPreview then
		self.previewMenu = LocalMenu.createComponentFrame(previewInfos)
		self.previewMenu.Visible = false
		self.previewMenu.Parent = self.screenGui
		self.previewMenu.Name = "PreviewLocalMenu"
	end

	return self
end

function TopBarUI:HideBehindPanel()
	-- Panels cannot be opened in preview mode, so we only need to worry about
	-- the editor menu.
	Utils.AddStyleTag(self.editorMenu, StyleConsts.tags.CoreUIWithOpenPanel)
end

function TopBarUI:UnhideBehindPanel()
	Utils.RemoveStyleTag(self.editorMenu, StyleConsts.tags.CoreUIWithOpenPanel)
end

function TopBarUI:SwitchToEditor()
	self.editorMenu.Visible = true
	if self.previewMenu then
		self.previewMenu.Visible = false
	end
	self.baseUI:ReturnToEditor()
end

function TopBarUI:SwitchToAvatarPreview()
	self.editorMenu.Visible = false
	if self.previewMenu then
		self.previewMenu.Visible = true
	end
	self.baseUI:OpenAvatarPreview()
end

function TopBarUI:Destroy()
	self.screenGui:Destroy()
end

return TopBarUI
