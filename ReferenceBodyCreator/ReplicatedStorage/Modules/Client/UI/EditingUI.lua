--[[
	Creates and manages all of the editing tools, including both texture and
	mesh editing. This also creates the toolbar that opens said tools.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))
local Components = UI:WaitForChild("Components")

local Toolbar = require(Components:WaitForChild("Toolbar"))

local BrushToolUI = require(UI:WaitForChild("BrushToolUI"))
local EraserToolUI = require(UI:WaitForChild("EraserToolUI"))
local FillToolUI = require(UI:WaitForChild("FillToolUI"))
local StickerToolUI = require(UI:WaitForChild("StickerToolUI"))
local StickerPatternToolUI = require(UI:WaitForChild("StickerPatternToolUI"))
local KitbashToolUI = require(UI:WaitForChild("KitbashToolUI"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local StickerData = require(Config:WaitForChild("StickerData"))
local KitbashData = require(Config:WaitForChild("KitbashData"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local EditingUI = {}
EditingUI.__index = EditingUI

function EditingUI:CreateFillToolUI()
	-- Set up the fill/recolor/fabric tool UI
	local SelectedRegionCallback = function(selectedRegion)
		self.fabricTool:SetSelectedRegion(selectedRegion)
	end
	local ColorPickerCallback = function(color, isFinalInput)
		self.fabricTool:ApplyColor(color, isFinalInput)
	end
	local DeleteCallback = function()
		self.fabricTool:ClearAll()
	end
	local CloseCallback = function()
		self:onClosePanel()
	end
	local regionParts = self.manager.modelInfo:GetRegionPartsList()

	self.fillToolUI = FillToolUI.new(
		self.inputManager,
		CloseCallback,
		DeleteCallback,
		regionParts,
		SelectedRegionCallback,
		ColorPickerCallback
	)
	self.fillToolUI.panel.Parent = self.panelParent
end

function EditingUI:CreateStickerToolUI()
	local DeleteCallback = function()
		-- Delete the current sticker
		self.stickerTool:DeleteCurrentSticker()
		self.stickerToolUI:UpdateProgress()
	end
	local CloseCallback = function()
		self:onClosePanel()
	end

	self.stickerToolUI = StickerToolUI.new(CloseCallback, DeleteCallback, StickerData, self.stickerTool)
	self.stickerToolUI.panel.Parent = self.panelParent
end

function EditingUI:CreateStickerPatternToolUI()
	local DeleteCallback = function()
		-- Delete the current sticker
		self.stickerTool:DeleteCurrentSticker()
		self.stickerPatternToolUI:UpdateProgress()
	end
	local CloseCallback = function()
		self:onClosePanel()
	end

	local regionParts = if self.manager.modelInfo:GetRegionalStickerPatterningEnabled()
		then self.manager.modelInfo:GetRegionPartsList()
		else nil
	local SelectedRegionCallback = function(selectedRegion)
		self.stickerTool:SetSelectedRegion(selectedRegion)
	end

	local minPadding = Constants.MIN_STICKER_PADDING
	local maxPadding = Constants.MAX_STICKER_PADDING
	local defaultPadding = 0

	local SliderCallback = function(newValue, isFinalInput)
		-- When slider value changes, we change the pattern spacing.
		local paddingValue = newValue * (maxPadding - minPadding) + minPadding
		self.stickerTool:OnPatternPaddingChanged(paddingValue, isFinalInput)
	end

	self.stickerPatternToolUI = StickerPatternToolUI.new(
		self.inputManager,
		CloseCallback,
		DeleteCallback,
		SelectedRegionCallback,
		SliderCallback,
		defaultPadding,
		regionParts,
		StickerData,
		self.stickerTool
	)

	self.stickerPatternToolUI.panel.Parent = self.panelParent
end

function EditingUI:CreateKitbashToolUI()
	local DeleteCallback = function()
		-- Delete the current mesh piece
		self.kitbashTool:DeleteCurrentPiece()
		self.kitbashToolUI:UpdateProgress()
	end
	local CloseCallback = function()
		self:onClosePanel()
	end

	self.kitbashToolUI = KitbashToolUI.new(CloseCallback, DeleteCallback, KitbashData, self.kitbashTool)
	self.kitbashToolUI.panel.Parent = self.panelParent
end

function EditingUI:CreateBrushToolUI()
	local minBrushSize = Constants.MIN_BRUSH_SIZE
	local maxBrushSize = Constants.MAX_BRUSH_SIZE
	local defaultBrushSize = 10

	local defaultSliderVal = defaultBrushSize / (maxBrushSize - minBrushSize)

	local onClosePanelCallback = function()
		self:onClosePanel()
	end

	local onDeleteCallback = function()
		self.brushTool:ClearAll()
	end

	local onSliderChangedCallback = function(newValue, isFinalInput)
		-- When slider value changes, we want to change the brush size.
		local brushSize = newValue * (maxBrushSize - minBrushSize) + minBrushSize
		self:OnBrushSizeChanged(brushSize, isFinalInput)
	end

	local onColorChangedCallback = function(color, _isFinalInput)
		self.brushTool:OnColorChanged(color)
	end

	self.brushToolUI = BrushToolUI.new(
		self.inputManager,
		onClosePanelCallback,
		onDeleteCallback,
		defaultSliderVal,
		onSliderChangedCallback,
		onColorChangedCallback
	)

	-- Set default brush color
	self.brushTool:OnColorChanged(
		Color3.fromHSV(
			Constants.DefaultColorPickerColor.h,
			Constants.DefaultColorPickerColor.s,
			Constants.DefaultColorPickerColor.v
		)
	)

	self.brushToolUI.panel.Parent = self.panelParent
end

function EditingUI:CreateEraserToolUI()
	local minBrushSize = Constants.MIN_BRUSH_SIZE
	local maxBrushSize = Constants.MAX_BRUSH_SIZE
	local defaultBrushSize = 5

	local defaultSliderVal = defaultBrushSize / (maxBrushSize - minBrushSize)

	local onClosePanelCallback = function()
		self:onClosePanel()
	end

	local onDeleteCallback = function()
		self.brushTool:ClearAll()
	end

	local onSliderChangedCallback = function(newValue, isFinalInput)
		-- When slider value changes, we want to change the brush size.
		local brushSize = newValue * (maxBrushSize - minBrushSize) + minBrushSize
		self:OnBrushSizeChanged(brushSize, isFinalInput)
	end

	self.eraserToolUI = EraserToolUI.new(
		self.inputManager,
		onClosePanelCallback,
		onDeleteCallback,
		defaultSliderVal,
		onSliderChangedCallback
	)

	-- Set eraser default size
	self.brushTool:OnEraserSizeChanged(defaultBrushSize)

	self.eraserToolUI.panel.Parent = self.panelParent
end

function EditingUI:OpenWidgetControls(widgetControlName: string)
	self:CloseAndDisablePanels()
	self.baseUI:UnhideCoreUIBehindPanel()
	self.manager:ShowMeshEditControls(widgetControlName)
end

function EditingUI:CloseAndDisablePanels()
	self.brushToolUI:Close()
	self.eraserToolUI:Close()
	self.brushTool:Disable()

	self.stickerToolUI:Close()
	self.stickerPatternToolUI:Close()
	self.stickerTool:Disable()

	self.kitbashToolUI:Close()
	self.kitbashTool:Disable()

	self.fillToolUI:Close()

	self.manager:HideMeshEditControls()
end

function EditingUI:GetMeshEditingGroup()
	local widgetGroupNames = self.manager:GetWidgetGroupNames()

	if #widgetGroupNames == 0 then
		return nil
	end

	local group = {}
	for _, name in widgetGroupNames do
		local buttonInfo = {
			iconId = StyleConsts.widgetIcons[name],
			callback = function()
				self:OpenWidgetControls(name)
			end,
		}
		table.insert(group, buttonInfo)
	end

	return group
end

function EditingUI:SetupToolbar()
	-- Painting
	local paintingGroup = {
		-- Paintbrush
		{
			iconId = StyleConsts.icons.Paintbrush,
			callback = function()
				self:onOpenPanel()
				self.brushTool:SetStatePainting()
				self.brushToolUI:Open()
				self.brushTool:Enable()
				self.manager:PanToLeft()
			end,
		},
		-- Eraser
		{
			iconId = StyleConsts.icons.Eraser,
			callback = function()
				self:onOpenPanel()
				self.brushTool:SetStateErasing()
				self.eraserToolUI:Open()
				self.brushTool:Enable()
				self.manager:PanToLeft()
			end,
		},
	}

	-- Fill Tool
	local fillGroup = {
		{
			iconId = StyleConsts.icons.Recolor,
			callback = function()
				self:onOpenPanel()
				self.fillToolUI:Open()
				self.manager:PanToLeft()
			end,
		},
	}

	-- Stickers
	local stickerGroup = {
		-- Sticker
		{
			iconId = StyleConsts.icons.Decal,
			callback = function()
				self:onOpenPanel()
				self.stickerToolUI:Open()
				self.stickerTool:Enable()
				self.manager:PanToLeft()
			end,
		},
	}
	if self.manager.modelInfo:GetStickerPatterningEnabled() then
		-- Patterns
		local patternsButton = {
			iconId = StyleConsts.icons.Pattern,
			callback = function()
				self:onOpenPanel()
				self.stickerPatternToolUI:Open()
				self.stickerTool:Enable()
			end,
		}
		table.insert(stickerGroup, patternsButton)
	end

	-- Kitbashing
	local kitbashGroup = {
		{
			iconId = StyleConsts.icons.Kitbashing,
			callback = function()
				self:onOpenPanel()
				self.kitbashToolUI:Open()
				self.kitbashTool:Enable()
				self.manager:PanToLeft()
			end,
		},
	}

	-- Create toolbar
	local toolbarGroups = {
		paintingGroup,
		fillGroup,
		stickerGroup,
	}

	if self.manager.modelInfo:GetKitbashingEnabled() then
		-- Kitbashing is only enabled on accessories
		table.insert(toolbarGroups, kitbashGroup)
	end

	-- Widget editing
	if self.manager.modelInfo:GetWidgetMeshEditingEnabled() then
		local meshWidgetGroup = self:GetMeshEditingGroup()
		table.insert(toolbarGroups, meshWidgetGroup)
	end

	self.toolbar = Toolbar.new(toolbarGroups)
end

function EditingUI:onOpenPanel()
	self:CloseAndDisablePanels()
	self.baseUI:HideCoreUIBehindPanel()
end

function EditingUI:onClosePanel()
	self.baseUI:UnhideCoreUIBehindPanel()
	self.toolbar:RemoveSelection()
	self.manager:ResetCamera()
	self:CloseAndDisablePanels()
end

function EditingUI.new(baseUI, manager, fabricTool, stickerTool, brushTool, kitbashTool)
	local self = {}
	setmetatable(self, EditingUI)

	self.baseUI = baseUI
	self.manager = manager
	self.inputManager = manager:GetInputManager()
	self.style = baseUI.style

	self.fabricTool = fabricTool
	self.stickerTool = stickerTool
	self.brushTool = brushTool
	self.kitbashTool = kitbashTool

	-- Setup screen gui
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "EditingUI"
	self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.screenGui.DisplayOrder = 5
	self.screenGui.ResetOnSpawn = false
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.ScreenInsets = Enum.ScreenInsets.None
	self.screenGui.Parent = PlayerGui

	self.style:LinkGui(self.screenGui)

	-- Setup partitions for toolbar and panel
	local frame = Instance.new("Frame")
	Utils.AddStyleTag(frame, StyleConsts.tags.UIParent)
	frame.Parent = self.screenGui
	frame.Name = "UIParent"

	local toolbarParent = Instance.new("Frame")
	Utils.AddStyleTag(toolbarParent, StyleConsts.tags.ToolbarParent)
	toolbarParent.Parent = frame
	toolbarParent.Name = "ToolbarParent"

	self.panelParent = Instance.new("Frame")
	Utils.AddStyleTag(self.panelParent, StyleConsts.tags.PanelParent)
	self.panelParent.Parent = frame
	self.panelParent.Name = "PanelParent"

	-- Setup tools
	self:CreateBrushToolUI()
	self:CreateEraserToolUI()
	self:CreateFillToolUI()
	self:CreateStickerToolUI()
	self:CreateStickerPatternToolUI()
	self:CreateKitbashToolUI()

	-- Setup toolbar
	self:SetupToolbar()
	self.toolbar:GetFrame().Parent = toolbarParent

	return self
end

function EditingUI:Hide()
	self:CloseAndDisablePanels()
	self.baseUI:UnhideCoreUIBehindPanel()
	self.toolbar:RemoveSelection()
	self.screenGui.Enabled = false
end

function EditingUI:Show()
	self.screenGui.Enabled = true
end

function EditingUI:Destroy()
	self.screenGui:Destroy()
end

function EditingUI:OnBrushSizeChanged(newValue, isFinalInput)
	self.brushTool:OnBrushSizeChanged(newValue, isFinalInput)
end

return EditingUI
