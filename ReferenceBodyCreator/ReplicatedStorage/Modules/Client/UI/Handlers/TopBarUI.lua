--[[
	Creates the ScreenGUI and components for the top bar menu used in the editor.
	Called in BaseUI, alongside other UIs used for editing.
]]

local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local ConfigConsts = require(Config:WaitForChild("Constants"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local LocalMenu = require(Components:WaitForChild("LocalMenu"))
local Badge = require(Components:WaitForChild("Badge"))
local DropdownMenu = require(Components:WaitForChild("DropdownMenu"))

local TopBarUI = {}
TopBarUI.__index = TopBarUI

local ASSET_TYPE_ICONS = {
	[ConfigConsts.MAKEUP_ASSET_TYPES.Face] = StyleConsts.icons.FaceMakeup,
	[ConfigConsts.MAKEUP_ASSET_TYPES.Eyes] = StyleConsts.icons.EyeMakeup,
	[ConfigConsts.MAKEUP_ASSET_TYPES.Lips] = StyleConsts.icons.LipsMakeup,
	[ConfigConsts.MAKEUP_ASSET_TYPES.Eyebrows] = StyleConsts.icons.Eyebrows,
	[ConfigConsts.MAKEUP_ASSET_TYPES.Eyelashes] = StyleConsts.icons.Eyelashes,
}

function TopBarUI.new(baseUI, manager)
	local self = {}
	setmetatable(self, TopBarUI)

	self.baseUI = baseUI
	self.manager = manager

	-- Avatar preview should only be shown for accessories
	local showAvatarPreview = manager.modelInfo:GetCreationType() == ConfigConsts.CREATION_TYPES.Accessory

	self.screenGui = Instance.new("ScreenGui")
	if GuiService:IsTenFootInterface() then
		self.screenGui.ScreenInsets = Enum.ScreenInsets.None
	else
		self.screenGui.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
	end
	self.screenGui.Name = "TopBarUI"
	self.screenGui.Parent = PlayerGui
	-- Render below other screenGuis
	self.displayOrder = 0

	-- Create and link styleSheet
	local style = baseUI.style
	style:LinkGui(self.screenGui)

	local editorInfos = {}
	local previewInfos = nil

	-- Button group infos that should be hidden when a panel is open on mobile.
	local hideBehindPanelGroupInfos = {}

	if manager.modelInfo:GetCreationType() ~= ConfigConsts.CREATION_TYPES.Body then
		local undoButtonInfo = {
			iconId = StyleConsts.icons.Undo,
			callback = function()
				manager:Undo()
			end,
			getIsMuted = function()
				return manager.historyTool:getUndoCount() == 0
			end,
		}
		local redoButtonInfo = {
			iconId = StyleConsts.icons.Redo,
			callback = function()
				manager:Redo()
			end,
			getIsMuted = function()
				return manager.historyTool:getRedoCount() == 0
			end,
		}

		table.insert(editorInfos, { undoButtonInfo, redoButtonInfo })
	end

	local resetOptions = {
		{
			name = "Reset All Edits",
			icon = StyleConsts.icons.ResetChanges,
			onSelect = function()
				baseUI.ResetEditsModalUI:Open()
			end,
		},
	}
	if manager.modelInfo:GetCreationType() == ConfigConsts.CREATION_TYPES.Makeup then
		table.insert(resetOptions, 1, {
			name = "Reset Camera Angle",
			icon = StyleConsts.icons.ResetCamera,
			onSelect = function()
				baseUI.EditingUI:ResetCameraToActiveMakeupLayer()
			end,
		})
	end
	self.resetMenu = DropdownMenu.new({ options = resetOptions })
	local resetMenuGroupInfo = {
		{
			iconId = StyleConsts.icons.KebabMenu,
			callback = function()
				self.resetMenu:Open(self.resetMenuAnchor, baseUI.EditingUI.screenGui)
			end,
		},
	}
	table.insert(editorInfos, resetMenuGroupInfo)
	table.insert(hideBehindPanelGroupInfos, resetMenuGroupInfo)

	local publishGroupInfo = {
		{
			iconId = StyleConsts.icons.ShoppingCart,
			callback = function()
				baseUI:OnClickedBuyButton()
			end,
		},
	}

	-- Exit Button
	local onExit = function()
		manager:Quit()
	end
	local exitButtonInfo = {
		iconId = StyleConsts.icons.ExitEditor,
		callback = onExit,
	}
	local exitGroupInfo = { exitButtonInfo }
	-- Avatar Preview Button and Preview Menu, if applicable
	if showAvatarPreview then
		local onPreview = function()
			self:SwitchToAvatarPreview()
		end
		local previewButtonInfo = {
			iconId = StyleConsts.icons.AvatarPreview,
			callback = onPreview,
		}
		local previewGroupInfo = { previewButtonInfo }
		table.insert(editorInfos, previewGroupInfo)
		table.insert(hideBehindPanelGroupInfos, previewGroupInfo)

		local modelName = manager.modelInfo:GetBlankName()

		local onEditorReturn = function()
			self:SwitchToEditor()
		end
		local returnButtonInfo = {
			iconId = StyleConsts.editorIcons[modelName],
			callback = onEditorReturn,
		}
		local returnGroupInfo = { returnButtonInfo }
		previewInfos = { returnGroupInfo, publishGroupInfo, exitGroupInfo }
	end

	table.insert(editorInfos, publishGroupInfo)
	table.insert(editorInfos, exitGroupInfo)

	table.insert(hideBehindPanelGroupInfos, publishGroupInfo)
	table.insert(hideBehindPanelGroupInfos, exitGroupInfo)

	-- Create local menus
	self.editorMenu, self.updateEditorMenuButtonStates, self.editorMenuButtonGroups =
		LocalMenu.createComponentFrame(editorInfos)
	self.editorMenu.Parent = self.screenGui

	-- Resolve the info groups flagged above to their created frames.
	local groupFrameByInfo = {}
	for i, groupInfo in editorInfos do
		groupFrameByInfo[groupInfo] = self.editorMenuButtonGroups[i]
	end
	self.resetMenuAnchor = groupFrameByInfo[resetMenuGroupInfo]
	StyleUtils.AddStyleTag(groupFrameByInfo[publishGroupInfo], StyleConsts.tags.EmphasisButton)
	self.hideBehindPanelGroups = {}
	for _, groupInfo in hideBehindPanelGroupInfos do
		table.insert(self.hideBehindPanelGroups, groupFrameByInfo[groupInfo])
	end

	self.editorMenu.Name = "EditorLocalMenu"
	manager.historyTool:setHistoryChangedCallback(function()
		self.updateEditorMenuButtonStates()
	end)
	if showAvatarPreview then
		local previewMenu, _, previewMenuButtonGroups = LocalMenu.createComponentFrame(previewInfos)
		self.previewMenu = previewMenu
		local previewGroupFrameByInfo = {}
		for i, groupInfo in previewInfos do
			previewGroupFrameByInfo[groupInfo] = previewMenuButtonGroups[i]
		end
		StyleUtils.AddStyleTag(previewGroupFrameByInfo[publishGroupInfo], StyleConsts.tags.EmphasisButton)
		self.previewMenu.Visible = false
		self.previewMenu.Parent = self.screenGui
		self.previewMenu.Name = "PreviewLocalMenu"
	end

	-- Center badge showing the currently selected layer.
	self.layerIndicator = Badge.new()
	self.layerIndicator:SetVisible(false)
	local indicatorFrame = self.layerIndicator:GetFrame()
	indicatorFrame.Name = "LayerIndicator"
	StyleUtils.AddStyleTag(indicatorFrame, StyleConsts.tags.TopBarLayerIndicator)
	indicatorFrame.Parent = self.screenGui

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.Parent = indicatorFrame
	local leadingButtonGroup = self.editorMenuButtonGroups[1]
	local function updateIndicatorLayout()
		-- Desktop and console keep the position supplied by StyleRules.
		indicatorFrame:ResetPropertyToDefault("Position")
		local maxWidth = math.huge
		if StyleUtils.GetIsMobile(self.screenGui) and not GuiService:IsTenFootInterface() then
			local tokens = StyleConsts.styleTokens
			local padding = tokens.Padding
			local buttonPosition = leadingButtonGroup.AbsolutePosition - self.screenGui.AbsolutePosition
			maxWidth = buttonPosition.X - 2 * padding.Medium.Offset
			-- Collapse the clipped badge when its icon and padding would not fit.
			if maxWidth <= tokens.IconSize.Small.X.Offset + 2 * padding.Small.Offset + padding.XSmall.Offset then
				maxWidth = 0
			end
			indicatorFrame.Position = UDim2.fromOffset(
				buttonPosition.X / 2,
				buttonPosition.Y + (leadingButtonGroup.AbsoluteSize.Y - tokens.BadgeSize.Y.Offset) / 2
			)
		end
		sizeConstraint.MaxSize = Vector2.new(maxWidth, math.huge)
	end
	-- The leading group follows menu/panel movement; the ScreenGui covers resizing and inset changes.
	leadingButtonGroup:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateIndicatorLayout)
	self.screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateIndicatorLayout)
	updateIndicatorLayout()

	return self
end

function TopBarUI:SetHistoryTool(historyTool)
	self.manager.historyTool:setHistoryChangedCallback(function() end)
	self.manager.historyTool = historyTool
	self.manager.historyTool:setHistoryChangedCallback(function()
		self.updateEditorMenuButtonStates()
	end)
	self.updateEditorMenuButtonStates()
end

-- Updates the center layer indicator pill.
function TopBarUI:SetLayerIndicator(assetType: string?, layerName: string?)
	if assetType and layerName then
		self.layerIndicator:SetIcon(ASSET_TYPE_ICONS[assetType])
		self.layerIndicator:SetText(layerName)
		self.layerIndicator:SetVisible(true)
	else
		self.layerIndicator:SetVisible(false)
	end
end

function TopBarUI:HideBehindPanel()
	self.resetMenu:Close()
	-- Panels cannot be opened in preview mode, so we only need to worry about
	-- the editor menu.
	for _, buttonGroup in self.hideBehindPanelGroups do
		StyleUtils.AddStyleTag(buttonGroup, StyleConsts.tags.CoreUIWithOpenPanel)
	end
	StyleUtils.AddStyleTag(self.editorMenu, StyleConsts.tags.LocalMenuWithOpenPanel)
end

function TopBarUI:UnhideBehindPanel()
	self.resetMenu:Close()
	for _, buttonGroup in self.hideBehindPanelGroups do
		StyleUtils.RemoveStyleTag(buttonGroup, StyleConsts.tags.CoreUIWithOpenPanel)
	end
	StyleUtils.RemoveStyleTag(self.editorMenu, StyleConsts.tags.LocalMenuWithOpenPanel)
end

function TopBarUI:SwitchToEditor()
	self.editorMenu.Visible = true
	if self.previewMenu then
		self.previewMenu.Visible = false
	end
	self.baseUI:ReturnToEditor()
end

function TopBarUI:SwitchToAvatarPreview()
	self.resetMenu:Close()
	self.editorMenu.Visible = false
	if self.previewMenu then
		self.previewMenu.Visible = true
	end
	self.baseUI:OpenAvatarPreview()
end

function TopBarUI:Destroy()
	self.manager.historyTool:setHistoryChangedCallback(function() end)
	self.resetMenu:Destroy()
	self.screenGui:Destroy()
end

return TopBarUI
