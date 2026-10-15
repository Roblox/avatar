--[[
	Creates and manages all of the editing tools, including both texture and
	mesh editing. This also creates the toolbar that opens said tools.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local BrushData = require(Config:WaitForChild("BrushData"))
local StickerData = require(Config:WaitForChild("StickerData"))
local KitbashData = require(Config:WaitForChild("KitbashData"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local GroupInfo = require(TextureManipulation:WaitForChild("GroupInfo")) -- For type definitions

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Handlers = UI:WaitForChild("Handlers")
local BrushToolUI = require(Handlers.BrushToolUI)
local EraserToolUI = require(Handlers.EraserToolUI)
local BlendToolUI = require(Handlers.BlendToolUI)
local FillToolUI = require(Handlers.FillToolUI)
local StickerToolUI = require(Handlers.StickerToolUI)
local StampToolUI = require(Handlers.StampToolUI)
local StickerPatternToolUI = require(Handlers.StickerPatternToolUI)
local KitbashToolUI = require(Handlers.KitbashToolUI)
local LayerToolUI = require(Handlers.LayerToolUI)
local AccessoryPickerToolUI = require(Handlers.AccessoryPickerToolUI)
local AccessoryCustomizeToolUI = require(Handlers.AccessoryCustomizeToolUI)
local AccessorySwapModalUI = require(Handlers.AccessorySwapModalUI)
local MakeupPreviewUI = require(Handlers.MakeupPreviewUI)

local Components = UI:WaitForChild("Components")
local Chip = require(Components:WaitForChild("Chip"))
local Toolbar = require(Components:WaitForChild("Toolbar"))
local StampActionBar = require(Components:WaitForChild("StampActionBar"))

local EditingUI = {}
EditingUI.__index = EditingUI

local function isAccessoryAssetType(assetType: string?): boolean
	return assetType ~= nil and Constants.MAKEUP_ACCESSORY_ASSET_TYPES[assetType] == true
end

function EditingUI:GetMirrorPlane(isEnabled: boolean): CFrame?
	return if isEnabled then self.manager.modelDisplay:GetModel():GetPivot() else nil
end

function EditingUI:SetTextureTools(brushTool, stampTool)
	self:setLastSliderValue(Constants.STATE_PAINTING, self.paintSliderValue)
	self:setLastSliderValue(Constants.STATE_ERASING, self.eraseSliderValue)
	self:setLastSliderValue(Constants.STATE_BLENDING, self.blendSliderValue)
	brushTool:CopySettingsFrom(self.brushTool)
	self.brushTool = brushTool
	local sizeContext = if brushTool.modelInfo.blankData.isMakeupAccessory then "makeupAccessory" else "default"
	self.lastSliderValueById = self.sliderValuesByContext[sizeContext]
	local paintBrush = brushTool:getMostRecentBrushByType(Constants.STATE_PAINTING)
	local eraserBrush = brushTool:getMostRecentBrushByType(Constants.STATE_ERASING)
	local blendBrush = brushTool:getMostRecentBrushByType(Constants.STATE_BLENDING)
	self.brushToolUI:SetBrushSizeSliderValue(self:getLastSliderValue(paintBrush.BrushId))
	self.eraserToolUI:SetBrushSizeSliderValue(self:getLastSliderValue(eraserBrush.BrushId))
	self.blendToolUI:SetBrushSizeSliderValue(self:getLastSliderValue(blendBrush.BrushId))
	if self.brushColor then
		self.brushTool:OnColorChanged(self.brushColor)
	end
	self.stampTool = stampTool
	if self.stampToolUI then
		self.stampToolUI.stickerTool = stampTool
	end
end

function EditingUI:CreateFillToolUI()
	-- Set up the fill/recolor/fabric tool UI
	local SelectedRegionCallback = function(selectedRegion)
		self.fabricTool:SetSelectedRegion(selectedRegion)
	end
	local ColorPickerCallback = function(color, isFinalInput)
		self.fabricTool:ApplyColor(color, isFinalInput)
	end
	local ReflectiveModeCallback = function(isReflectiveMode)
		self.fabricTool:SetIsReflective(isReflectiveMode)
		self.fabricTool:ReapplyFillForReflectivity()
	end
	local OpacityPickerCallback = function(opacity)
		self.fabricTool:SetOpacity(opacity)
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
		ColorPickerCallback,
		ReflectiveModeCallback,
		OpacityPickerCallback
	)
	self.fillToolUI.panel.Parent = self.panelParent
	table.insert(self.toolUIs, self.fillToolUI)
end

function EditingUI:CreateStickerToolUI()
	if not self.stickerTool then
		return
	end

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
	table.insert(self.toolUIs, self.stickerToolUI)
end

-- The stamp tool replaces the sticker tool during makeup. It shares the sticker tool's interface
-- (StampToolUI extends StickerToolUI), so this mirrors CreateStickerToolUI against self.stampTool.
function EditingUI:CreateStampToolUI()
	if not self.stampTool then
		return
	end

	local DeleteCallback = function()
		-- Delete the current stamp
		self.stampTool:DeleteCurrentSticker()
		self.stampToolUI:UpdateProgress()
	end
	local CloseCallback = function()
		self.stampTool:RequestBake(function()
			self:onClosePanel()
		end)
	end

	local showActionBarCallback = function(showActionBar: boolean)
		StyleUtils.SetStyleTag(self.toolbar:GetFrame(), StyleConsts.tags.ToolbarWithStampActionBar, showActionBar)
		if showActionBar then
			self.stampActionBar:Open()
		else
			self.stampActionBar:Close()
		end
	end

	self.stampToolUI =
		StampToolUI.new(CloseCallback, DeleteCallback, StickerData, self.stampTool, showActionBarCallback)
	self.stampToolUI.panel.Parent = self.panelParent
	table.insert(self.toolUIs, self.stampToolUI)
end

function EditingUI:CreateStickerPatternToolUI()
	-- Patterning is a sticker tool feature; skip it when only the stamp tool is present.
	if not self.stickerTool then
		return
	end

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
	table.insert(self.toolUIs, self.stickerPatternToolUI)
end

function EditingUI:CreateKitbashToolUI()
	local DeleteCallback = function()
		-- Delete the current mesh piece
		self.kitbashTool:DeleteCurrentPiece()
		self.kitbashToolUI:UpdateProgress()
	end
	local CloseCallback = function()
		local category = self.accessoryKitbashCategory
		if category then
			self:OpenAccessoryCustomize(category)
		else
			self:onClosePanel()
		end
	end

	self.kitbashToolUI = KitbashToolUI.new(CloseCallback, DeleteCallback, KitbashData, self.kitbashTool)
	self.kitbashToolUI.panel.Parent = self.panelParent

	table.insert(self.toolUIs, self.kitbashToolUI)
end

function EditingUI:SetKitbashTool(kitbashTool)
	self.kitbashTool = kitbashTool
	if self.kitbashToolUI then
		self.kitbashToolUI:SetKitbashTool(kitbashTool)
	end
end

function EditingUI:OpenAccessoryCustomize(category: string, itemInfo: AccessoryPickerToolUI.ItemInfo?)
	self:onOpenPanel()
	if not self.manager:ShowAccessoryInIsolation(category) then
		self:OpenAccessoryPicker(category)
		return
	end
	itemInfo = itemInfo or self.accessoryPickerToolUI:GetSelectedItemInfo(category)
	if not itemInfo then
		self:OpenAccessoryPicker(category)
		return
	end
	local shape = self.previewAccessoryTool:GetShape(category)
	self.accessoryCustomizeToolUI:Open(category, shape.controls, itemInfo, shape.values)
	self.toolbar:GetFrame().Visible = not StyleUtils.GetIsMobile(self.screenGui)
	self:UpdateAccessoryPickerToolbar()
	self:SelectAccessoryToolbarButton(1)
	self.manager:PanToLeft()
end

function EditingUI:OpenAccessoryKitbash(category: string)
	self:onOpenPanel()
	if not self.manager:ShowAccessoryInIsolation(category) then
		self:OpenAccessoryPicker(category)
		return
	end
	self.accessoryKitbashCategory = category
	self.kitbashToolUI:Open()
	self.kitbashTool:Enable()
	self:UpdateAccessoryPickerToolbar()
	self:SelectAccessoryToolbarButton(2)
	self.manager:PanToLeft()
end

function EditingUI:setLastSliderValue(brushState, sliderValue)
	local oldBrushId = self.brushTool:getMostRecentBrushByType(brushState).BrushId
	self.lastSliderValueById[oldBrushId] = sliderValue
end

function EditingUI:getLastSliderValue(brushId)
	return self.lastSliderValueById[brushId] or self:getDefaultSliderVal(brushId)
end

function EditingUI:GetBrushSizes(brush)
	if self.brushTool.modelInfo.blankData.isMakeupAccessory then
		local sizes = BrushData.MakeupAccessoryBrushSizes[brush.BrushId]
		if sizes then
			return sizes.minSize, sizes.maxSize, sizes.defaultSize
		end
	end
	return brush:getMinSize(), brush:getMaxSize(), brush:getDefaultSize()
end

function EditingUI:CreateBrushToolUI()
	local defaultBrushId = self.brushTool.GetDefaultBrush(Constants.STATE_PAINTING)
	local defaultSliderVal = self:getDefaultSliderVal(defaultBrushId)
	self.paintSliderValue = defaultSliderVal

	local onClosePanelCallback = function()
		self:onClosePanel()
	end

	local onDeleteCallback = function()
		self.brushTool:ClearAll()
	end

	local onSliderChangedCallback = function(newValue, isFinalInput)
		self.paintSliderValue = newValue
		-- When slider value changes, we want to change the brush size.
		local brush = self.brushTool:getMostRecentBrushByType(Constants.STATE_PAINTING)
		local minBrushSize, maxBrushSize = self:GetBrushSizes(brush)

		local brushSize = newValue * (maxBrushSize - minBrushSize) + minBrushSize
		self:OnBrushSizeChanged(brushSize, isFinalInput, Constants.STATE_PAINTING)
	end

	local onColorChangedCallback = function(color, _isFinalInput)
		self.brushColor = color
		self.brushTool:OnColorChanged(color)
	end
	local ReflectiveModeCallback = function(isReflectiveMode)
		self.brushTool:SetIsReflective(isReflectiveMode)
	end
	local onMirrorCallback = function(isEnabled)
		self.brushTool:SetMirrorPlane(self:GetMirrorPlane(isEnabled))
	end
	local onMirrorGuideToggleCallback = function(isVisible)
		self.brushTool:SetMirrorGuideVisible(isVisible == true)
	end
	local TransparencyPickerCallback = function(opacity)
		self:OnBrushOpacityChanged(opacity)
	end
	local onBrushSelectedCallback = function(brushId)
		self:setLastSliderValue(Constants.STATE_PAINTING, self.paintSliderValue)
		self.brushTool:setBrush(brushId)
		self.brushToolUI:SetBrushSizeSliderValue(self:getLastSliderValue(brushId))
	end

	self.brushToolUI = BrushToolUI.new(
		self.inputManager,
		onClosePanelCallback,
		onDeleteCallback,
		defaultSliderVal,
		onSliderChangedCallback,
		onColorChangedCallback,
		ReflectiveModeCallback,
		onMirrorCallback,
		onMirrorGuideToggleCallback,
		TransparencyPickerCallback,
		onBrushSelectedCallback
	)

	-- Set default brush color
	self.brushColor = Color3.fromHSV(
		StyleConsts.DefaultColorPickerColor.h,
		StyleConsts.DefaultColorPickerColor.s,
		StyleConsts.DefaultColorPickerColor.v
	)
	self.brushTool:OnColorChanged(self.brushColor)

	self.brushToolUI.panel.Parent = self.panelParent

	table.insert(self.toolUIs, self.brushToolUI)
end

function EditingUI:CreateEraserToolUI()
	local defaultBrushId = self.brushTool.GetDefaultBrush(Constants.STATE_ERASING)
	local defaultSliderVal = self:getDefaultSliderVal(defaultBrushId)
	self.eraseSliderValue = defaultSliderVal

	local onClosePanelCallback = function()
		self:onClosePanel()
	end

	local onDeleteCallback = function()
		self.brushTool:ClearAll()
	end

	local onSliderChangedCallback = function(newValue, isFinalInput)
		self.eraseSliderValue = newValue
		-- When slider value changes, we want to change the brush size.
		local brush = self.brushTool:getMostRecentBrushByType(Constants.STATE_ERASING)
		local minBrushSize, maxBrushSize = self:GetBrushSizes(brush)

		local brushSize = newValue * (maxBrushSize - minBrushSize) + minBrushSize
		self:OnBrushSizeChanged(brushSize, isFinalInput, Constants.STATE_ERASING)
	end
	local onOpacitySliderChangedCallback = function(opacity, isFinalInput)
		self:OnBrushOpacityChanged(opacity, isFinalInput)
	end
	local onMirrorCallback = function(isMirrorMode)
		self.brushTool:SetMirrorPlane(self:GetMirrorPlane(isMirrorMode))
	end
	local onMirrorGuideToggleCallback = function(isVisible)
		self.brushTool:SetMirrorGuideVisible(isVisible)
	end
	local onBrushSelectedCallback = function(brushId)
		self:setLastSliderValue(Constants.STATE_ERASING, self.eraseSliderValue)
		self.brushTool:setBrush(brushId)
		self.eraserToolUI:SetBrushSizeSliderValue(self:getLastSliderValue(brushId))
	end

	self.eraserToolUI = EraserToolUI.new(
		self.inputManager,
		onClosePanelCallback,
		onDeleteCallback,
		defaultSliderVal,
		onSliderChangedCallback,
		onOpacitySliderChangedCallback,
		onMirrorCallback,
		onMirrorGuideToggleCallback,
		onBrushSelectedCallback
	)

	self.eraserToolUI.panel.Parent = self.panelParent

	table.insert(self.toolUIs, self.eraserToolUI)
end

-- Refreshes the top bar layer indicator pill from the current target layer.
function EditingUI:UpdateLayerIndicator()
	if not self.layerTool then
		return
	end

	local target = self.layerTool:GetTargetLayerInfo()
	local group = if target and target.groupId then self.layerTool:GetGroup(target.groupId) else nil
	if group and group.makeupAssetType then
		self.baseUI.TopBarUI:SetLayerIndicator(group.makeupAssetType, target.layerId)
	else
		self.baseUI.TopBarUI:SetLayerIndicator(nil, nil)
	end

	self:UpdateAccessoryPickerToolbar()
end

function EditingUI:GetAccessoryPickerCategory(): string?
	if self.accessoryPickerToolUI and self.accessoryPickerToolUI.panel.Visible then
		return self.accessoryPickerToolUI.category
	end
	if self.accessoryCustomizeToolUI and self.accessoryCustomizeToolUI.panel.Visible then
		return self.accessoryCustomizeToolUI.category
	end
	if self.accessoryKitbashCategory and self.kitbashToolUI and self.kitbashToolUI.panel.Visible then
		return self.accessoryKitbashCategory
	end

	local activeGroup = self.layerTool and self.layerTool:GetActiveGroup()
	local activeAssetType = activeGroup and activeGroup.makeupAssetType
	return if isAccessoryAssetType(activeAssetType) then activeAssetType else nil
end

function EditingUI:SelectAccessoryToolbarButton(buttonIndex: number)
	if not self.toolbar or not self.accessoryPickerToolbarIndex then
		return
	end
	self.toolbar:MakeSelection(self.accessoryPickerToolbarIndex)
	local buttonGroup = self.toolbar.buttonGroups[self.accessoryPickerToolbarIndex]
	buttonGroup:UnhideAll()
	buttonGroup:ChangeSelection(buttonIndex)
end

function EditingUI:UpdateAccessoryPickerToolbar()
	if not self.toolbar then
		return
	end
	local activeCategory = self:GetAccessoryPickerCategory()
	if self.accessoryPickerToolbarIndex then
		self.toolbar:SetGroupVisible(self.accessoryPickerToolbarIndex, activeCategory ~= nil)
		local kitbashButton = self.toolbar.buttonGroups[self.accessoryPickerToolbarIndex].childButtons[2]
		if kitbashButton then
			local selection = self.previewAccessoryTool and self.previewAccessoryTool.selections[activeCategory]
			kitbashButton:SetEnabled(selection ~= nil)
		end
	end
	if self.previewAccessoryTool then
		local previewing = self.makeupPreviewToolUI and self.makeupPreviewToolUI.panel.Visible
		local editingCategory = if previewing then nil else activeCategory
		local contextReady = self.previewAccessoryTool:SetEditingCategory(editingCategory)
		if not contextReady then
			return
		end
		for category, selection in self.previewAccessoryTool.selections do
			local modelInfo = selection.editModelInfo
			local textureInfo = modelInfo:GetTextureInfo()
			local showGuides = category == activeCategory and not previewing
			textureInfo:SetShowMakeupGuides(modelInfo:GetMeshParts()[1], showGuides)
			if not showGuides then
				self.previewAccessoryTool:CacheIdleSelection(category)
			end
		end
	end
end

-- Builds the reusable eyebrow/eyelash picker panel. Selecting a tile equips
-- that accessory on the head via the preview accessory tool.
function EditingUI:CreateAccessoryPickerToolUI()
	if not self.previewAccessoryTool then
		return
	end

	self.accessorySwapModal = AccessorySwapModalUI.new(self.baseUI.style)

	local onClosePanelCallback = function()
		self:onClosePanel()
	end
	local onDeleteCallback = function(category: string)
		if not self.layerToolUI or not self.layerToolUI:DeleteAccessoryGroup(category) then
			self.previewAccessoryTool:Unequip(category)
		end
	end
	local onSelectCallback = function(category: string, accessoryName: string)
		local previous = self.previewAccessoryTool.selections[category]
		local request = {}
		self.accessorySwapRequest = request
		self.accessorySwapModal:Close()
		local function isCurrent(): boolean
			return self.accessorySwapRequest == request
				and self.accessoryPickerToolUI.panel.Visible
				and self.accessoryPickerToolUI.category == category
				and self.previewAccessoryTool.selections[category] == previous
		end
		local function equip()
			if isCurrent() and self.previewAccessoryTool:Equip(category, accessoryName) then
				self.layerToolUI:SetAccessoryGroup(self.previewAccessoryTool.selections[category].group)
				self.accessoryPickerToolUI:UpdateSelection()
			end
		end
		if previous and previous.name ~= accessoryName then
			self.accessorySwapModal:Open(category, equip)
			return
		end
		equip()
	end
	local onCustomizeCallback = function(category: string, itemInfo: AccessoryPickerToolUI.ItemInfo)
		self:OpenAccessoryCustomize(category, itemInfo)
	end

	self.accessoryPickerToolUI = AccessoryPickerToolUI.new(
		onClosePanelCallback,
		onDeleteCallback,
		self.previewAccessoryTool,
		onSelectCallback,
		onCustomizeCallback
	)
	self.accessoryPickerToolUI.panel.Parent = self.panelParent
	table.insert(self.toolUIs, self.accessoryPickerToolUI)

	local onConfirmCustomizeCallback = function()
		self:OpenLayerPanel()
	end
	local onSwapCustomizeCallback = function()
		self:OpenAccessoryPicker(self.accessoryCustomizeToolUI.category)
	end
	local onCustomizeDeleteCallback = function()
		local category = self.accessoryCustomizeToolUI.category
		onDeleteCallback(category)
		self:OpenAccessoryPicker(category)
	end
	local onPreviewChangedCallback = function(category: string, previewing: boolean): boolean
		if previewing then
			self.manager:FinishAccessoryTextureEditing()
		elseif not self.manager:ShowAccessoryInIsolation(category) then
			return false
		end
		self.manager:PanToLeft()
		return true
	end
	local onShapeControlChangedCallback = function(category: string, controlId: string, value: number)
		local selection = self.previewAccessoryTool.selections[category]
		if selection then
			local layerTool = self.manager:GetLayerToolForGroup(selection.group.name)
			self.previewAccessoryTool:SetShapeControl(category, controlId, value, layerTool.historyTool)
		end
	end

	self.accessoryCustomizeToolUI = AccessoryCustomizeToolUI.new(
		onClosePanelCallback,
		onConfirmCustomizeCallback,
		onSwapCustomizeCallback,
		onCustomizeDeleteCallback,
		onPreviewChangedCallback,
		onShapeControlChangedCallback
	)
	self.accessoryCustomizeToolUI.panel.Parent = self.panelParent
	self.accessoryCustomizeToolUI.actionBar:GetFrame().Parent = self.screenGui
	table.insert(self.toolUIs, self.accessoryCustomizeToolUI)
end

-- Opens the picker for a category ("Eyebrows"/"Eyelashes"), rebuilding its grid.
function EditingUI:OpenAccessoryPicker(category: string)
	if not self.accessoryPickerToolUI then
		return
	end

	self:onOpenPanel()
	self.accessoryPickerToolUI:ShowCategory(category)
	self.accessoryPickerToolUI:Open()
	self:UpdateAccessoryPickerToolbar()
	self:SelectAccessoryToolbarButton(1)
	self:PanCameraForPanel()
end

function EditingUI:FocusCameraOnActiveMakeupGroup(useTween: boolean, panForPanel: boolean)
	if self.manager:GetCreationType() ~= Constants.CREATION_TYPES.Makeup then
		return
	end

	local group = self.layerTool and self.layerTool:GetActiveGroup()
	local groupId = group and group.name
	local target = self.layerTool and self.layerTool:GetTargetLayerInfo()
	local layerId = target and target.groupId and target.layerId
	local selectionChanged = self.cameraLayerTool ~= self.layerTool
		or self.cameraGroupId ~= groupId
		or self.cameraLayerId ~= layerId

	-- Keep selection tracking current during undo/redo, without moving the camera.
	self.cameraLayerTool = self.layerTool
	self.cameraGroupId = groupId
	self.cameraLayerId = layerId
	if self.isRestoringLayerSelection or not selectionChanged then
		return
	end

	local makeupAssetType = group and group.makeupAssetType or nil
	self.manager:FocusCameraOnMakeupAssetType(makeupAssetType, useTween, panForPanel)
end

-- Explicit resets must refocus even when the selected layer has not changed.
function EditingUI:ResetCameraToActiveMakeupLayer()
	if
		self.manager:GetCreationType() ~= Constants.CREATION_TYPES.Makeup
		or self.inputManager:IsLocked()
		or self.manager.modelInfo:GetMakeupHeadSwapInProgress()
	then
		return
	end

	local isolatedParts = self.previewAccessoryTool and self.previewAccessoryTool:GetIsolatedParts()
	if isolatedParts and #isolatedParts > 0 then
		self.manager.modelDisplay:ResetCameraRotation()
		self.manager:PanToLeft()
		return
	end

	local panForPanel = false
	for _, toolUI in self.toolUIs do
		if toolUI.panel.Visible then
			panForPanel = true
			break
		end
	end
	local group = self.layerTool and self.layerTool:GetActiveGroup()
	self.manager:FocusCameraOnMakeupAssetType(group and group.makeupAssetType, true, panForPanel)
end

function EditingUI:OpenLayerPanel()
	self:onOpenPanel()
	self.layerToolUI:Open()
	self.toolbar:MakeSelection(self.layerToolToolbarIndex)
	self.toolbar.buttonGroups[self.layerToolToolbarIndex]:ChangeSelection(1)
	self:PanCameraForPanel()
end

function EditingUI:SelectLayerTool(groupId: string?)
	local layerTool = self.manager:GetLayerToolForGroup(groupId)
	self.layerTool = layerTool
	self.baseUI.TopBarUI:SetHistoryTool(layerTool.historyTool)
end

function EditingUI:CreateLayerToolUI()
	if not self.layerTool then
		return
	end

	local onClosePanelCallback = function()
		self:onClosePanel()
	end

	local onAddLayerCallback = function(targetLayerInfo: GroupInfo.TargetLayerInfo)
		return self.manager:GetLayerToolForGroup(targetLayerInfo.groupId):AddLayerToGroup(targetLayerInfo)
	end

	local onDeleteLayerCallback = function(targetLayerInfo: GroupInfo.TargetLayerInfo)
		local result = self.manager:GetLayerToolForGroup(targetLayerInfo.groupId):DeleteLayerFromGroup(targetLayerInfo)
		self.layerTool:RefreshMakeupGuides()
		-- Deleting the last layer can leave nothing selected, which disables editing.
		self:UpdateEditingToolsEnabled()
		self:UpdateLayerIndicator()
		self:FocusCameraOnActiveMakeupGroup(true, true)
		return result
	end

	local onSelectLayerCallback = function(targetLayerInfo: GroupInfo.TargetLayerInfo)
		self:SelectLayerTool(targetLayerInfo.groupId)
		local result = self.layerTool:SelectLayerInGroup(targetLayerInfo)
		self.layerTool:RefreshMakeupGuides()
		self:UpdateEditingToolsEnabled()
		self:UpdateLayerIndicator()
		self:FocusCameraOnActiveMakeupGroup(true, true)
		return result
	end

	local onMoveLayerCallback = function(targetLayerInfo: GroupInfo.TargetLayerInfo, direction: number)
		local layerTool = self.manager:GetLayerToolForGroup(targetLayerInfo.groupId)
		local result = layerTool:MoveLayerInGroup(targetLayerInfo, direction)
		self:UpdateEditingToolsEnabled()
		return result
	end

	local onAddGroupCallback = function(groupId: string, makeupAssetType: string?)
		if self.previewAccessoryTool then
			local contextReady = self.previewAccessoryTool:SetEditingCategory(nil)
			if not contextReady then
				return nil
			end
		end
		return self.manager.layerTool:AddGroup(groupId, makeupAssetType)
	end

	local onDeleteGroupCallback = function(groupId: string)
		local layerTool = self.manager:GetLayerToolForGroup(groupId)
		local group = layerTool:GetGroup(groupId)
		if group and isAccessoryAssetType(group.makeupAssetType) and self.previewAccessoryTool then
			self.previewAccessoryTool:Unequip(group.makeupAssetType)
		else
			layerTool:DeleteGroup(groupId)
		end
		self.layerTool:RefreshMakeupGuides()
		-- Deleting a group removes its layers, which can leave nothing selected.
		self:UpdateEditingToolsEnabled()
		self:UpdateLayerIndicator()
		self:FocusCameraOnActiveMakeupGroup(true, true)
	end

	local onChangeOpacityCallback = function(
		targetLayerInfo: GroupInfo.TargetLayerInfo,
		newOpacity: number,
		isFinalInput: boolean
	)
		return self.manager
			:GetLayerToolForGroup(targetLayerInfo.groupId)
			:ChangeOpacity(targetLayerInfo, newOpacity, isFinalInput)
	end

	local onSetLayerVisibilityCallback = function(targetLayerInfo: GroupInfo.TargetLayerInfo, isVisible: boolean)
		self.manager:GetLayerToolForGroup(targetLayerInfo.groupId):SetLayerVisible(targetLayerInfo, isVisible)
		self:UpdateEditingToolsEnabled()
	end

	local onSetGroupVisibilityCallback = function(groupId: string, isVisible: boolean)
		local layerTool = self.manager:GetLayerToolForGroup(groupId)
		layerTool:SetGroupVisible(groupId, isVisible)
		local group = layerTool:GetGroup(groupId)
		if group and isAccessoryAssetType(group.makeupAssetType) and self.previewAccessoryTool then
			self.previewAccessoryTool:SetVisible(group.makeupAssetType, group.isVisible)
		end
		self:UpdateEditingToolsEnabled()
	end

	local onMoveGroupCallback = function(groupId: string, direction: number)
		local layerTool = self.manager:GetLayerToolForGroup(groupId)
		if layerTool == self.manager.layerTool then
			layerTool:MoveGroup(groupId, direction)
		else
			self.previewAccessoryTool:MoveAccessoryGroup(groupId, direction)
		end
		-- Reordering another context does not change the UI's selected layer.
		self:UpdateEditingToolsEnabled()
	end

	local onSelectGroupCallback = function(groupId: string)
		self:SelectLayerTool(groupId)
		local result = self.layerTool:SelectGroup(groupId)
		self.layerTool:RefreshMakeupGuides()
		self:UpdateEditingToolsEnabled()
		self:UpdateLayerIndicator()
		self:FocusCameraOnActiveMakeupGroup(true, true)
		return result
	end

	local onOpenAccessoryPickerCallback = function(assetType: string)
		self:OpenAccessoryPicker(assetType)
	end

	local onShowGuidesChangedCallback = function(showGuides: boolean)
		self.manager.layerTool:SetShowMakeupGuides(showGuides)
	end

	local groups = table.clone(self.manager.layerTool:GetExistingGroupInfos())
	if self.previewAccessoryTool then
		for _, group in self.previewAccessoryTool:GetAccessoryGroups() do
			-- Rehydrate thumbnail content through the same tool that owns these layers.
			local layerTool = self.manager:GetLayerToolForGroup(group.name)
			table.insert(groups, layerTool:GetExistingGroupInfos()[1])
		end
	end

	local getGroupThumbnailContent = function(groupInfo: GroupInfo.GroupInfo): Content?
		local manager = self.manager.editableManager
		local ids = manager.eiSetToImagesMap[groupInfo.compositeSetId]
		if not ids then
			return nil
		end
		local image = manager.liveEditableImages[ids.color]
		return manager.cachedImages[ids.color] or (image and Content.fromObject(image))
	end

	self.layerToolUI = LayerToolUI.new(
		groups,
		getGroupThumbnailContent,
		self.manager.modelInfo:GetMakeupItemPrices(),
		onClosePanelCallback,
		onAddLayerCallback,
		onDeleteLayerCallback,
		onSelectLayerCallback,
		onMoveLayerCallback,
		onAddGroupCallback,
		onDeleteGroupCallback,
		onMoveGroupCallback,
		onSelectGroupCallback,
		onChangeOpacityCallback,
		onSetLayerVisibilityCallback,
		onSetGroupVisibilityCallback,
		onOpenAccessoryPickerCallback,
		onShowGuidesChangedCallback
	)

	if self.previewAccessoryTool then
		self.previewAccessoryTool.onCacheChanged = function()
			for _, stack in self.layerToolUI.groupStacks do
				stack:RefreshAllThumbnails()
			end
		end
	end
	self.layerToolUI.panel.Parent = self.panelParent

	table.insert(self.toolUIs, self.layerToolUI)
	self:FocusCameraOnActiveMakeupGroup(false, false)
end

function EditingUI:CreateMakeupPreviewToolUI()
	local onClosePanelCallback = function()
		self:onClosePanel()
	end

	self.makeupPreviewToolUI = MakeupPreviewUI.new(onClosePanelCallback, self.manager.modelInfo, function()
		if self.previewAccessoryTool then
			self.previewAccessoryTool:Refresh()
		end
		self.manager.layerTool.historyTool:clear()
		self.manager:ResetCamera()
		if self.makeupPreviewToolUI.panel.Visible then
			self.manager:PanToLeft()
		end
	end, function()
		return not self.manager.inputManager:IsLocked()
	end, self.style)

	self.makeupPreviewToolUI.panel.Parent = self.panelParent

	table.insert(self.toolUIs, self.makeupPreviewToolUI)
end

-- Currently only used by undo/redo to restore layer selection without refocusing the camera.
function EditingUI:SelectLayer(targetLayerInfo: GroupInfo.TargetLayerInfo)
	if self.layerToolUI then
		self.isRestoringLayerSelection = true
		self.layerToolUI:SelectLayer(targetLayerInfo)
		self.isRestoringLayerSelection = false
	end
end

function EditingUI:CreateBlendToolUI()
	local defaultBrushId = self.brushTool.GetDefaultBrush(Constants.STATE_BLENDING)
	local defaultSliderVal = self:getDefaultSliderVal(defaultBrushId)
	self.blendSliderValue = defaultSliderVal

	local onClosePanelCallback = function()
		self:onClosePanel()
	end

	local onDeleteCallback = function()
		self.brushTool:ClearAll()
	end

	local onSliderChangedCallback = function(newValue, isFinalInput)
		self.blendSliderValue = newValue
		-- When slider value changes, we want to change the brush size.
		local brush = self.brushTool:getMostRecentBrushByType(Constants.STATE_BLENDING)
		local minBrushSize, maxBrushSize = self:GetBrushSizes(brush)

		local brushSize = newValue * (maxBrushSize - minBrushSize) + minBrushSize
		self:OnBrushSizeChanged(brushSize, isFinalInput, Constants.STATE_BLENDING)
	end
	local onMirrorCallback = function(isEnabled)
		self.brushTool:SetMirrorPlane(self:GetMirrorPlane(isEnabled))
	end
	local onMirrorGuideToggleCallback = function(isVisible)
		self.brushTool:SetMirrorGuideVisible(isVisible == true)
	end
	local onBrushSelectedCallback = function(brushId)
		self:setLastSliderValue(Constants.STATE_BLENDING, self.blendSliderValue)
		self.brushTool:setBrush(brushId)
		self.blendToolUI:SetBrushSizeSliderValue(self:getLastSliderValue(brushId))
	end

	self.blendToolUI = BlendToolUI.new(
		self.inputManager,
		onClosePanelCallback,
		onDeleteCallback,
		defaultSliderVal,
		onSliderChangedCallback,
		onMirrorCallback,
		onMirrorGuideToggleCallback,
		onBrushSelectedCallback
	)

	self.blendToolUI.panel.Parent = self.panelParent
	table.insert(self.toolUIs, self.blendToolUI)
end

function EditingUI:OpenWidgetControls(widgetControlName: string)
	self:CloseAndDisablePanels()
	self.baseUI:UnhideCoreUIBehindPanel()
	self.manager:ShowMeshEditControls(widgetControlName)
end

function EditingUI:CloseAndDisablePanels()
	self.accessoryKitbashCategory = nil
	self.accessorySwapRequest = nil
	if self.accessorySwapModal then
		self.accessorySwapModal:Close()
	end
	for _, toolUI in self.toolUIs do
		toolUI:Close()
	end

	self.brushTool:Disable()
	if self.stickerTool then
		self.stickerTool:Disable()
	end
	if self.stampTool then
		self.stampTool:Disable()
	end
	if self.stampActionBar then
		self.stampActionBar:Close()
	end
	if self.toolbar then
		self.toolbar:GetFrame().Visible = true
		StyleUtils.RemoveStyleTag(self.toolbar:GetFrame(), StyleConsts.tags.ToolbarWithStampActionBar)
	end
	self.kitbashTool:Disable()

	self.manager:HideMeshEditControls()
	self.manager:FinishAccessoryTextureEditing()
end

-- Editing tools require a selected layer, so every toolbar group except the layer
-- tool is disabled while no layer is selected. Only applies in layer contexts (where
-- the layer tool exists).
function EditingUI:UpdateEditingToolsEnabled()
	if not self.toolbar or not self.layerToolUI then
		return
	end
	if self.manager:GetCreationType() ~= Constants.CREATION_TYPES.Makeup then
		self.toolbar:SetEnabledExcept(true)
		return
	end
	local target = self.layerTool:GetTargetLayerInfo()
	local group = if target and target.groupId then self.layerTool:GetGroup(target.groupId) else nil
	local hasSelectedLayer = self.layerToolUI:HasSelectedLayer()
	self.layerToolUI:SetShowGuidesVisible(
		hasSelectedLayer
			and group ~= nil
			and table.find(Constants.MAKEUP_DECAL_ASSET_TYPES, group.makeupAssetType) ~= nil
	)
	local canEdit = false
	if hasSelectedLayer and group and group.isVisible then
		for _, layer in group.inputLayers do
			if layer.name == target.layerId then
				canEdit = layer.isVisible
				break
			end
		end
	end
	self.toolbar:SetEnabledExcept(canEdit, self.exceptedIndices)
	if
		not canEdit
		and self.toolbar.currentSelection
		and not table.find(self.exceptedIndices, self.toolbar.currentSelection)
	then
		self:onClosePanel()
	end
	-- Catalog and add-ons do not require an individual layer selection.
	self:UpdateAccessoryPickerToolbar()
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
			mutedIconId = StyleConsts.widgetIcons[name .. "Muted"],
			callback = function()
				self:OpenWidgetControls(name)
			end,
		}
		table.insert(group, buttonInfo)
	end

	return group
end

-- Adds an excepted index at a specific location, moving other excepted indices
-- if insert causes shift.
function EditingUI.addExceptedIndex(self, index: number)
	if not self.exceptedIndices then
		self.exceptedIndices = {}
	end

	for i, existingIndex in self.exceptedIndices do
		if existingIndex >= index then
			self.exceptedIndices[i] = existingIndex + 1
		end
	end

	table.insert(self.exceptedIndices, index)
end

-- Edits the provided toolbarGroups table in place, adding the provided group at
-- the provided index or at the end if not provided. Automatically adds to
-- exceptedIndices if indicated, accounting for index shifting.
function EditingUI:AddToolbarGroup(toolbarGroups, group, index: number?, shouldExcept: boolean?)
	if index then
		table.insert(toolbarGroups, index, group)
	else
		table.insert(toolbarGroups, group)
	end

	if shouldExcept then
		self.addExceptedIndex(self, index or #toolbarGroups)
	end
end

function EditingUI:SetupToolbar()
	-- Painting
	local paintingGroup = {
		-- Paintbrush
		{
			iconId = StyleConsts.icons.Paintbrush,
			mutedIconId = StyleConsts.icons.PaintbrushMuted,
			callback = function()
				if not self:onOpenTexturePanel() then
					return
				end
				self.brushTool:SetStatePainting()
				self.brushToolUI:Open(self.brushTool:IsMirrorEnabled(), self.brushTool:IsMirrorGuideEnabled())
				self.brushTool:Enable()
				self:PanCameraForPanel()
			end,
		},
		-- Eraser
		{
			iconId = StyleConsts.icons.Eraser,
			mutedIconId = StyleConsts.icons.EraserMuted,
			callback = function()
				if not self:onOpenTexturePanel() then
					return
				end
				self.brushTool:SetStateErasing()
				self.eraserToolUI:Open(self.brushTool:IsMirrorEnabled(), self.brushTool:IsMirrorGuideEnabled())
				self.brushTool:Enable()
				self:PanCameraForPanel()
			end,
		},
		-- Blend
		{
			iconId = StyleConsts.icons.Blend,
			mutedIconId = StyleConsts.icons.BlendMuted,
			callback = function()
				if not self:onOpenTexturePanel() then
					return
				end
				self.brushTool:SetStateBlending()
				self.blendToolUI:Open(self.brushTool:IsMirrorEnabled(), self.brushTool:IsMirrorGuideEnabled())
				self.brushTool:Enable()
				self:PanCameraForPanel()
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
				self:PanCameraForPanel()
			end,
		},
	}

	-- Stickers
	local stickerGroup = {
		-- Sticker
		{
			iconId = StyleConsts.icons.Decal,
			mutedIconId = StyleConsts.icons.DecalMuted,
			callback = function()
				self:onOpenPanel()
				self.stickerTool:Enable()
				self.stickerToolUI:Open()
				self:PanCameraForPanel()
			end,
		},
	}
	if self.manager.modelInfo:GetStickerPatterningEnabled() then
		-- Patterns
		local patternsButton = {
			iconId = StyleConsts.icons.Pattern,
			mutedIconId = StyleConsts.icons.PatternMuted,
			callback = function()
				self:onOpenPanel()
				self.stickerPatternToolUI:Open()
				self.stickerTool:Enable()
			end,
		}
		table.insert(stickerGroup, patternsButton)
	end

	local stampGroup = {
		{
			iconId = StyleConsts.icons.Stamp,
			mutedIconId = StyleConsts.icons.StampMuted,
			callback = function()
				if not self:onOpenTexturePanel() then
					return
				end
				self.stampTool:Enable()
				self.stampToolUI:Open()
				self:PanCameraForPanel()
			end,
		},
	}

	-- Kitbashing
	local kitbashGroup = {
		{
			iconId = StyleConsts.icons.Kitbashing,
			callback = function()
				if self.accessoryPickerToolUI then
					local category = self:GetAccessoryPickerCategory()
					if category then
						self:OpenAccessoryKitbash(category)
					end
					return
				end
				self:onOpenPanel()
				self.kitbashToolUI:Open()
				self.kitbashTool:Enable()
				self:PanCameraForPanel()
			end,
		},
	}

	-- Layering
	local layerGroup = {
		{
			iconId = StyleConsts.icons.MakeupLayers,
			callback = function()
				self:OpenLayerPanel()
			end,
		},
	}

	local accessoryPickerGroup = {
		{
			iconId = StyleConsts.icons.BrowsLashesCatalog,
			callback = function()
				local category = self:GetAccessoryPickerCategory()
				if category then
					self:OpenAccessoryPicker(category)
				end
			end,
		},
	}

	-- Preview
	local previewGroup = {
		{
			iconId = StyleConsts.icons.MakeupPreview,
			callback = function()
				self:onOpenPanel()
				self.makeupPreviewToolUI:Open()
				self:UpdateAccessoryPickerToolbar()
				self:PanCameraForPanel()
			end,
		},
	}

	-- Create toolbar
	local toolbarGroups = {}
	self:AddToolbarGroup(toolbarGroups, paintingGroup)
	if self.fillToolUI then
		self:AddToolbarGroup(toolbarGroups, fillGroup)
	end

	if self.stickerTool then
		self:AddToolbarGroup(toolbarGroups, stickerGroup)
	end

	if self.stampTool then
		-- Stamps take the sticker group's place during makeup
		self:AddToolbarGroup(toolbarGroups, stampGroup)
	end

	if self.kitbashToolUI and self.manager.modelInfo:GetKitbashingEnabled() and not self.accessoryPickerToolUI then
		self:AddToolbarGroup(toolbarGroups, kitbashGroup)
	end

	if self.layerToolUI then
		-- Layering is only enabled on accessories, so the UI may not exist
		-- Insert layering at the front
		self:AddToolbarGroup(toolbarGroups, layerGroup, 1, true --[[shouldExcept]])
	end

	if self.makeupPreviewToolUI then
		-- Insert at very front
		self:AddToolbarGroup(toolbarGroups, previewGroup, 1, true --[[shouldExcept]])
	end

	if self.accessoryPickerToolUI and self.layerToolUI then
		self:AddToolbarGroup(toolbarGroups, accessoryPickerGroup, 3, true --[[shouldExcept]])
		self.accessoryPickerToolbarIndex = 3
		if self.kitbashToolUI then
			table.insert(accessoryPickerGroup, kitbashGroup[1])
		end
	end

	-- Widget editing
	if self.manager.modelInfo:GetWidgetMeshEditingEnabled() then
		local meshWidgetGroup = self:GetMeshEditingGroup()
		self:AddToolbarGroup(toolbarGroups, meshWidgetGroup)
	end

	self.layerToolToolbarIndex = table.find(toolbarGroups, layerGroup)
	self.toolbar = Toolbar.new(toolbarGroups, function()
		-- On reselect
		self:onClosePanel()
	end)

	-- Editing tools start disabled until a layer is selected.
	self:UpdateEditingToolsEnabled()
end

function EditingUI:CreateStampActionBar()
	if not self.stampTool or not self.stampToolUI then
		return
	end

	local onMirrorChanged: (boolean?) -> () = function(isEnabled)
		self.stampTool:SetMirrorPlane(self:GetMirrorPlane(isEnabled))
	end

	local onMirrorGuideToggle: (boolean?) -> () = function(isVisible)
		self.stampTool:SetMirrorGuideVisible(isVisible == true)
	end

	local onDelete: () -> () = function()
		self.stampTool:DeleteCurrentSticker()
		self.stampToolUI:UpdateProgress()
	end

	local onApply: () -> () = function()
		self.stampTool:CommitStamp()
		self.stampToolUI:UpdateProgress()
	end

	local mirrorChip = Chip.new("Mirror", onMirrorChanged, true, StyleConsts.icons.MirrorPlane, onMirrorGuideToggle)
	self.stampActionBar = StampActionBar.new(mirrorChip:GetFrame(), onDelete, onApply)
	self.stampActionBar:GetFrame().Parent = self.screenGui
end

function EditingUI:onOpenPanel()
	self:CloseAndDisablePanels()
	self:UpdateAccessoryPickerToolbar()
	self.baseUI:HideCoreUIBehindPanel()
end

function EditingUI:PanCameraForPanel()
	-- Makeup is framed when selecting a layer; tool panels preserve that view.
	if self.manager:GetCreationType() ~= Constants.CREATION_TYPES.Makeup then
		self.manager:PanToLeft()
	end
end

function EditingUI:onOpenTexturePanel(): boolean
	self:onOpenPanel()
	local activeGroup = self.layerTool and self.layerTool:GetActiveGroup()
	local activeAssetType = activeGroup and activeGroup.makeupAssetType
	if isAccessoryAssetType(activeAssetType) then
		return self.manager:ShowAccessoryInIsolation(activeAssetType)
	end
	return true
end

function EditingUI:onClosePanel()
	self.baseUI:UnhideCoreUIBehindPanel()
	self.toolbar:RemoveSelection()
	self:CloseAndDisablePanels()
	if self.manager:GetCreationType() ~= Constants.CREATION_TYPES.Makeup then
		self.manager:ResetCamera()
	end
	self:UpdateAccessoryPickerToolbar()
end

function EditingUI:getDefaultSliderVal(brushId)
	local brushRegistry = self.brushTool.modelInfo:GetBrushRegistry()
	local brush = brushRegistry:GetBrush(brushId)
	local minSize, maxSize, defaultSize = self:GetBrushSizes(brush)
	return (defaultSize - minSize) / (maxSize - minSize)
end

function EditingUI.new(baseUI, manager, fabricTool, stickerTool, stampTool, brushTool, kitbashTool, layerTool)
	local self = {}
	setmetatable(self, EditingUI)

	self.toolUIs = {}

	self.baseUI = baseUI
	self.manager = manager
	self.inputManager = manager:GetInputManager()
	self.style = baseUI.style

	self.fabricTool = fabricTool
	self.stickerTool = stickerTool
	self.stampTool = stampTool
	self.brushTool = brushTool
	self.kitbashTool = kitbashTool
	self.layerTool = layerTool
	self.previewAccessoryTool = manager.previewAccessoryTool

	self.sliderValuesByContext = { default = {}, makeupAccessory = {} }
	local sizeContext = if brushTool.modelInfo.blankData.isMakeupAccessory then "makeupAccessory" else "default"
	self.lastSliderValueById = self.sliderValuesByContext[sizeContext]

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
	StyleUtils.AddStyleTag(frame, StyleConsts.tags.UIParent)
	frame.Parent = self.screenGui
	frame.Name = "UIParent"

	local toolbarParent = Instance.new("Frame")
	StyleUtils.AddStyleTag(toolbarParent, StyleConsts.tags.ToolbarParent)
	toolbarParent.Parent = frame
	toolbarParent.Name = "ToolbarParent"

	self.panelParent = Instance.new("Frame")
	StyleUtils.AddStyleTag(self.panelParent, StyleConsts.tags.PanelParent)
	self.panelParent.Parent = frame
	self.panelParent.Name = "PanelParent"

	-- Setup tools
	self:CreateBrushToolUI()
	self:CreateEraserToolUI()
	self:CreateBlendToolUI()
	if self.fabricTool then
		self:CreateFillToolUI()
	end
	self:CreateStickerToolUI()
	self:CreateStampToolUI()
	self:CreateStickerPatternToolUI()

	if self.kitbashTool and (self.manager.modelInfo:GetKitbashingEnabled() or self.previewAccessoryTool) then
		self:CreateKitbashToolUI()
	end

	if self.previewAccessoryTool then
		self:CreateAccessoryPickerToolUI()
	end

	if self.layerTool then
		self:CreateLayerToolUI()
	end

	if self.manager:GetCreationType() == Constants.CREATION_TYPES.Makeup then
		self:CreateMakeupPreviewToolUI()
	end

	self:CreateStampActionBar()

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
	self.accessorySwapRequest = nil
	if self.accessorySwapModal then
		self.accessorySwapModal:Destroy()
	end
	if self.makeupPreviewToolUI then
		self.makeupPreviewToolUI:Destroy()
	end
	self.brushToolUI:Destroy()
	self.eraserToolUI:Destroy()
	self.blendToolUI:Destroy()
	self.screenGui:Destroy()
end

function EditingUI:OnBrushSizeChanged(newValue, isFinalInput, brushState)
	self.brushTool:OnBrushSizeChanged(newValue, isFinalInput, brushState)
end

function EditingUI:OnBrushOpacityChanged(newValue, isFinalInput)
	self.brushTool:OnBrushOpacityChanged(newValue, isFinalInput)
end

return EditingUI
