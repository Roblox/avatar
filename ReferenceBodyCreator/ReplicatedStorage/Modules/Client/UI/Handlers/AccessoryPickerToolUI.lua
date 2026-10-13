--[[
	A panel with a preview grid for picking an eyebrow/eyelash accessory to
	preview on the makeup head. The single panel is reused for both categories;
	ShowCategory rebuilds the grid (and retitles the header) for the chosen one.
]]

local UI = script.Parent.Parent
local AccessoryThumbnailUtils = require(UI:WaitForChild("AccessoryThumbnailUtils"))

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local BaseTile = require(Components:WaitForChild("BaseTile"))
local Panel = require(Components:WaitForChild("Panel"))
local TextButton = require(Components:WaitForChild("TextButton"))
local TileGrid = require(Components:WaitForChild("TileGrid"))

local AccessoryPickerToolUI = {}
AccessoryPickerToolUI.__index = AccessoryPickerToolUI

local CATEGORY_TITLES = {
	Eyebrows = "Eyebrow Catalog",
	Eyelashes = "Eyelash Catalog",
}

export type ItemInfo = {
	name: string,
	previewInstance: Model | BasePart,
	viewportOptions: BaseTile.ViewportOptions?,
}

function AccessoryPickerToolUI.new(
	onClosePanelCallback: () -> (),
	onDeleteCallback: (category: string) -> (),
	previewAccessoryTool,
	onSelectCallback: (category: string, accessoryName: string) -> (),
	onCustomizeCallback: (category: string, itemInfo: ItemInfo) -> ()
)
	local self = {}
	setmetatable(self, AccessoryPickerToolUI)

	self.previewAccessoryTool = previewAccessoryTool
	self.onSelectCallback = onSelectCallback
	self.onCustomizeCallback = onCustomizeCallback
	self.customizeButtons = {}

	self.scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(self.scrollingFrame, StyleConsts.tags.ScrollFrame)

	local function onDeleteActiveCategory()
		if self.category then
			onDeleteCallback(self.category)
			self:UpdateSelection()
		end
	end

	self.panel = Panel.createComponentFrame(
		"Accessory Catalog",
		onClosePanelCallback,
		onDeleteActiveCategory,
		{ self.scrollingFrame }
	)
	self.panel.Name = "AccessoryPickerToolPanel"
	self.trashButton = self.panel.PanelHeaderBar.IconFrame.TrashButton
	self.trashButton.Visible = false
	self.thumbnailCache = Instance.new("Folder")
	self.thumbnailCache.Name = "ThumbnailCache"
	self.thumbnailCache.Parent = self.panel

	local headerBar = self.panel:FindFirstChild("PanelHeaderBar")
	self.titleLabel = headerBar and headerBar:FindFirstChild("TitleLabel")

	self:Close()
	task.spawn(function()
		local headModel = AccessoryThumbnailUtils.CreateHead()
		if not headModel then
			return
		end
		if not self.thumbnailCache.Parent then
			headModel:Destroy()
			return
		end
		self.thumbnailHead = headModel
		headModel.Parent = self.thumbnailCache
		if self.category then
			self:ShowCategory(self.category)
		end
	end)

	return self
end

function AccessoryPickerToolUI:GetItemInfo(category: string, accInfo): ItemInfo
	local previewInstance: Model | BasePart = accInfo.previewInstance
	local viewportOptions
	if self.thumbnailHead then
		local cacheKey = category .. "_" .. accInfo.name
		local preview = self.thumbnailCache:FindFirstChild(cacheKey) :: Model?
		if not preview then
			preview = AccessoryThumbnailUtils.CreatePreview(self.thumbnailHead, accInfo.accessory)
			preview.Name = cacheKey
			preview.Parent = self.thumbnailCache
		end
		previewInstance = preview
		viewportOptions = AccessoryThumbnailUtils.GetViewportOptions(category)
	end
	return {
		name = accInfo.name,
		previewInstance = previewInstance,
		viewportOptions = viewportOptions,
	}
end

function AccessoryPickerToolUI:GetSelectedItemInfo(category: string): ItemInfo?
	local selection = self.previewAccessoryTool.selections[category]
	if selection then
		for _, accInfo in self.previewAccessoryTool:GetAccessoryInfos(category) do
			if accInfo.name == selection.name then
				return self:GetItemInfo(category, accInfo)
			end
		end
	end
	return nil
end

-- Rebuilds the grid for the given category ("Eyebrows"/"Eyelashes") and retitles
-- the panel. Safe to call repeatedly; only the grid child is replaced.
function AccessoryPickerToolUI:ShowCategory(category: string)
	self.category = category
	if self.titleLabel then
		self.titleLabel.Text = CATEGORY_TITLES[category] or "Accessory Catalog"
	end

	if self.grid then
		self.grid:Destroy()
		self.grid = nil
	end

	local tileInfos = {}
	self.customizeButtons = {}
	for _, accInfo in self.previewAccessoryTool:GetAccessoryInfos(category) do
		local itemInfo = self:GetItemInfo(category, accInfo)
		local customizeButton = TextButton.createComponentFrame({
			text = "Customize",
			callback = function()
				self.onCustomizeCallback(category, itemInfo)
			end,
		})
		customizeButton.Name = "CustomizeButton"
		self.customizeButtons[accInfo.name] = customizeButton
		table.insert(tileInfos, {
			previewInstance = itemInfo.previewInstance,
			viewportOptions = itemInfo.viewportOptions,
			insetButton = customizeButton,
			callback = function()
				self.onSelectCallback(category, accInfo.name)
				self:UpdateSelection()
			end,
		})
	end

	self.grid = TileGrid.createComponentFrame(tileInfos)
	self.grid.Parent = self.scrollingFrame
	self:UpdateSelection()
end

function AccessoryPickerToolUI:UpdateSelection()
	local selection = self.previewAccessoryTool.selections[self.category]
	self.trashButton.Visible = selection ~= nil
	for accessoryName, button in self.customizeButtons do
		local isSelected = selection ~= nil and selection.name == accessoryName
		button.Visible = isSelected
		StyleUtils.SetStyleTag(button.Parent, StyleConsts.tags.MiniBaseTileSelected, isSelected)
	end
end

function AccessoryPickerToolUI:Open()
	self.panel.Visible = true
end

function AccessoryPickerToolUI:Close()
	self.panel.Visible = false
end

return AccessoryPickerToolUI
