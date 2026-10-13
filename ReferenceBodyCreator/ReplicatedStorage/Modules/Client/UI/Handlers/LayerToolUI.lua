local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local GroupInfo = require(TextureManipulation:WaitForChild("GroupInfo")) -- For type

local UI = script.Parent.Parent

local Components = UI:WaitForChild("Components")
local LayerStack = require(Components:WaitForChild("LayerStack"))
local Panel = require(Components:WaitForChild("Panel"))
local TextButton = require(Components:WaitForChild("TextButton"))
local Chip = require(Components:WaitForChild("Chip"))
local DropdownMenu = require(Components:WaitForChild("DropdownMenu"))
local GroupCard = require(Components:WaitForChild("GroupCard"))

local Handlers = UI:WaitForChild("Handlers")
local GroupStack = require(Handlers:WaitForChild("GroupStack"))

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local LayerToolUI = {}
LayerToolUI.__index = LayerToolUI

-- The two makeup category sections shown in the panel, in display order. Each
-- has its display copy (cardInfo, from Constants), a card icon, and the makeup
-- asset type options offered by its dropdown. Icons come from StyleConsts.
local MAKEUP_CATEGORIES = {
	{
		cardInfo = Constants.MAKEUP_SELECTION_SECTIONS.Decals,
		cardIcon = StyleConsts.icons.MakeupCard,
		groupLimit = Constants.MAKEUP_POOL_GROUP_LIMITS[Constants.MAKEUP_GROUP_POOLS.Decals],
		options = {
			{ assetType = Constants.MAKEUP_ASSET_TYPES.Face, icon = StyleConsts.icons.FaceMakeup },
			{ assetType = Constants.MAKEUP_ASSET_TYPES.Eyes, icon = StyleConsts.icons.EyeMakeup },
			{ assetType = Constants.MAKEUP_ASSET_TYPES.Lips, icon = StyleConsts.icons.LipsMakeup },
		},
	},
	{
		cardInfo = Constants.MAKEUP_SELECTION_SECTIONS.BrowsLashes,
		cardIcon = StyleConsts.icons.BrowsLashesCard,
		groupLimit = Constants.MAKEUP_POOL_GROUP_LIMITS[Constants.MAKEUP_GROUP_POOLS.Eyebrows]
			+ Constants.MAKEUP_POOL_GROUP_LIMITS[Constants.MAKEUP_GROUP_POOLS.Eyelashes],
		options = {
			{ assetType = Constants.MAKEUP_ASSET_TYPES.Eyebrows, icon = StyleConsts.icons.Eyebrows },
			{ assetType = Constants.MAKEUP_ASSET_TYPES.Eyelashes, icon = StyleConsts.icons.Eyelashes },
		},
	},
}

-- Maps each makeup asset type to the index of the category that owns it, so
-- existing groups can be routed to the correct per-category stack.
local CATEGORY_INDEX_BY_ASSET_TYPE = {}
for categoryIndex, category in MAKEUP_CATEGORIES do
	for _, option in category.options do
		CATEGORY_INDEX_BY_ASSET_TYPE[option.assetType] = categoryIndex
	end
end

-- Buckets existing groups by the category that owns their asset type
local function partitionExistingGroups(existingGroupInfos: { GroupInfo.GroupInfo })
	local buckets = {}
	for categoryIndex in MAKEUP_CATEGORIES do
		buckets[categoryIndex] = {}
	end
	for _, groupInfo in existingGroupInfos do
		local categoryIndex = CATEGORY_INDEX_BY_ASSET_TYPE[groupInfo.makeupAssetType] or 1
		table.insert(buckets[categoryIndex], groupInfo)
	end
	return buckets
end

-- Dropdown of the category's makeup asset types. Face/Eyes/Lips immediately
-- create a group. Eyebrows/Eyelashes open their catalog and defer group creation
-- until an accessory is actually chosen.
local function makeCategoryMenu(
	category,
	groupStack,
	makeupItemPrices: { [string]: number },
	onOpenAccessoryPicker: (string) -> ()
)
	local options = {}
	for _, option in category.options do
		local assetType = option.assetType
		table.insert(options, {
			name = assetType,
			icon = option.icon,
			rightText = Constants.ROBUX_ICON .. " " .. tostring(makeupItemPrices[assetType] or 0),
			getIsDisabled = function()
				return Constants.MAKEUP_ACCESSORY_ASSET_TYPES[assetType] == true
					and groupStack:FindGroupByMakeupAssetType(assetType) ~= nil
			end,
			onSelect = function()
				if Constants.MAKEUP_ACCESSORY_ASSET_TYPES[assetType] then
					onOpenAccessoryPicker(assetType)
				else
					groupStack:AddGroup(assetType, nil, assetType)
				end
			end,
		})
	end
	return DropdownMenu.new({
		title = Constants.ADD_MAKEUP_ITEM_TITLE,
		footer = Constants.ADD_MAKEUP_ITEM_FOOTER,
		options = options,
	})
end

-- The empty-state card shown while a category has no groups. Its button opens
-- the same dropdown as the section's "Add Item" button.
local function makeZeroStateCard(category, onOpenMenu: (anchor: GuiObject) -> ())
	return GroupCard.createComponentFrame({
		icon = category.cardIcon,
		title = category.cardInfo.cardTitle,
		subtitle = category.cardInfo.cardSubtitle,
		buttonText = category.cardInfo.buttonText,
		onButtonPressed = onOpenMenu,
	})
end

-- Body holds both states stacked; only the visible one lays out.
local function makeSectionBody(card: GuiObject, groupContainer: GuiObject)
	local body = Instance.new("Frame")
	body.Name = "MakeupSectionBody"
	body.LayoutOrder = 2
	StyleUtils.AddStyleTag(body, StyleConsts.tags.MakeupSectionBody)
	card.Parent = body
	groupContainer.Parent = body
	return body
end

-- Title row (label + "Add Item" button) stacked above the body.
local function makeSectionFrame(category, triggerButton: GuiObject, body: GuiObject, layoutOrder: number)
	local sectionFrame = Instance.new("Frame")
	sectionFrame.Name = "MakeupSection"
	sectionFrame.LayoutOrder = layoutOrder
	StyleUtils.AddStyleTag(sectionFrame, StyleConsts.tags.MakeupSection)

	local titleRow = Instance.new("Frame")
	titleRow.Name = "MakeupSectionTitle"
	titleRow.LayoutOrder = 1
	StyleUtils.AddStyleTag(titleRow, StyleConsts.tags.MakeupSectionTitle)
	titleRow.Parent = sectionFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "MakeupSectionTitleLabel"
	titleLabel.Text = category.cardInfo.sectionTitle
	titleLabel.LayoutOrder = 1
	titleLabel.Parent = titleRow

	triggerButton.LayoutOrder = 2
	triggerButton.Parent = titleRow

	body.LayoutOrder = 2
	body.Parent = sectionFrame

	return sectionFrame
end

function LayerToolUI.new(
	existingGroupInfos: { GroupInfo.GroupInfo },
	getGroupThumbnailContent: (GroupInfo.GroupInfo) -> Content,
	makeupItemPrices: { [string]: number },
	onClosePanelCallback: () -> (),
	onAddLayerCallback: (GroupInfo.TargetLayerInfo) -> LayerStack.addLayerCallbackInfo,
	onDeleteLayerCallback: (GroupInfo.TargetLayerInfo) -> (),
	onSelectLayerCallback: (GroupInfo.TargetLayerInfo) -> (),
	onMoveLayerCallback: (GroupInfo.TargetLayerInfo, number) -> (),
	onAddGroupCallback: (string, string?) -> GroupInfo.GroupInfo?,
	onDeleteGroupCallback: (string) -> (),
	onMoveGroupCallback: (string, number) -> (),
	onSelectGroupCallback: (string) -> (),
	onChangeOpacityCallback: (GroupInfo.TargetLayerInfo, number, boolean) -> (),
	onSetLayerVisibilityCallback: (GroupInfo.TargetLayerInfo, boolean) -> (),
	onSetGroupVisibilityCallback: (string, boolean) -> (),
	onOpenAccessoryPickerCallback: (string) -> (),
	onShowGuidesChangedCallback: (boolean) -> ()
)
	local self = {}
	setmetatable(self, LayerToolUI)

	self.groupStacks = {}
	self.makeupItemMenus = {}
	self.onOpenAccessoryPickerCallback = onOpenAccessoryPickerCallback
	self.makeupItemPrices = makeupItemPrices

	-- Shared with every section's group stack.
	local groupStackCallbacks = {
		getGroupThumbnailContent = getGroupThumbnailContent,
		onAddLayerCallback = onAddLayerCallback,
		onDeleteLayerCallback = onDeleteLayerCallback,
		onSelectLayerCallback = onSelectLayerCallback,
		onMoveLayerCallback = onMoveLayerCallback,
		onAddGroupCallback = onAddGroupCallback,
		onDeleteGroupCallback = onDeleteGroupCallback,
		onMoveGroupCallback = onMoveGroupCallback,
		onSelectGroupCallback = onSelectGroupCallback,
		onChangeOpacityCallback = onChangeOpacityCallback,
		onSetLayerVisibilityCallback = onSetLayerVisibilityCallback,
		onSetGroupVisibilityCallback = onSetGroupVisibilityCallback,
	}

	local scrollingFrame = Instance.new("ScrollingFrame")
	StyleUtils.AddStyleTag(scrollingFrame, StyleConsts.tags.ScrollFrame)

	local chipFrame = Instance.new("Frame")
	chipFrame.Name = "LayerToolChipFrame"
	StyleUtils.AddStyleTag(chipFrame, StyleConsts.tags.ChipFrame)
	chipFrame.LayoutOrder = 1
	chipFrame.Parent = scrollingFrame
	self.showGuidesChipFrame = chipFrame
	self:SetShowGuidesVisible(false)

	local showGuidesChip = Chip.new("Show Guides", function(isActive: boolean?)
		onShowGuidesChangedCallback(isActive :: boolean)
	end, true --[[startActive]])
	showGuidesChip:GetFrame().Parent = chipFrame
	onShowGuidesChangedCallback(true) -- Start with guides on by default

	-- One section per makeup category; the empty-state card shows while its stack
	-- is empty and is replaced by the group list once a group exists.
	local existingByCategory = partitionExistingGroups(existingGroupInfos)
	for categoryIndex, category in MAKEUP_CATEGORIES do
		local sectionFrame = self:BuildCategorySection(
			category,
			categoryIndex + 1,
			existingByCategory[categoryIndex],
			groupStackCallbacks
		)
		sectionFrame.Parent = scrollingFrame
	end

	self.panel = Panel.createComponentFrame("Creation Layers", onClosePanelCallback, nil, { scrollingFrame })
	self.panel.Name = "LayerToolPanel"

	self:Close()

	return self
end

-- Assembles one category section: its group stack, dropdown, "Add Item" button, and
-- empty-state card, wired so the card and group list swap on add/delete.
-- Registers the stack and menu on self and returns the section frame.
function LayerToolUI:BuildCategorySection(category, layoutOrder: number, existingGroups, groupStackCallbacks)
	local groupStack, card, groupContainer, addGroupButton

	-- Optional per-section group cap (e.g. the Decals pool). nil means uncapped.
	local groupLimit = category.groupLimit
	local function setAddButtonEnabled(isEnabled: boolean)
		StyleUtils.SetStyleTag(addGroupButton, StyleConsts.tags.AddItemButtonDisabled, not isEnabled)
	end

	-- Re-evaluate the "Add Item" button against the section cap after a group is added/removed.
	local function refreshAddButtonEnabled()
		if groupLimit then
			setAddButtonEnabled(groupStack:GetGroupCount() < groupLimit)
		end
	end

	local function onBodyStateChangedCallback(hasGroups: boolean)
		StyleUtils.SetStyleTag(addGroupButton, StyleConsts.tags.Hidden, not hasGroups)
		if hasGroups then
			StyleUtils.AddStyleTag(card, StyleConsts.tags.Hidden)
			StyleUtils.RemoveStyleTag(groupContainer, StyleConsts.tags.Hidden)
		else
			StyleUtils.RemoveStyleTag(card, StyleConsts.tags.Hidden)
			StyleUtils.AddStyleTag(groupContainer, StyleConsts.tags.Hidden)
		end
		refreshAddButtonEnabled()
	end

	-- Enforce single-selection across every category stack
	local function deselectOtherStacks()
		for _, otherStack in self.groupStacks do
			if otherStack ~= groupStack then
				otherStack:DeselectAll()
			end
		end
	end
	local function onSelectLayerInThisStack(targetLayerInfo: GroupInfo.TargetLayerInfo)
		deselectOtherStacks()
		return groupStackCallbacks.onSelectLayerCallback(targetLayerInfo)
	end
	local function onSelectGroupInThisStack(groupId: string)
		deselectOtherStacks()
		return groupStackCallbacks.onSelectGroupCallback(groupId)
	end

	groupStack = GroupStack.new(
		existingGroups,
		groupStackCallbacks.getGroupThumbnailContent,
		groupStackCallbacks.onAddLayerCallback,
		groupStackCallbacks.onDeleteLayerCallback,
		onSelectLayerInThisStack,
		groupStackCallbacks.onMoveLayerCallback,
		groupStackCallbacks.onAddGroupCallback,
		groupStackCallbacks.onDeleteGroupCallback,
		groupStackCallbacks.onMoveGroupCallback,
		onSelectGroupInThisStack,
		groupStackCallbacks.onChangeOpacityCallback,
		groupStackCallbacks.onSetLayerVisibilityCallback,
		groupStackCallbacks.onSetGroupVisibilityCallback,
		onBodyStateChangedCallback
	)
	table.insert(self.groupStacks, groupStack)
	groupContainer = groupStack:GetFrame()

	local menu = makeCategoryMenu(category, groupStack, self.makeupItemPrices, self.onOpenAccessoryPickerCallback)
	table.insert(self.makeupItemMenus, menu)

	addGroupButton = TextButton.createComponentFrame({
		text = "Add Item",
		callback = function()
			-- Ignore taps while the section is at its group cap.
			if groupLimit and groupStack:GetGroupCount() >= groupLimit then
				return
			end
			menu:Open(addGroupButton)
		end,
	})
	StyleUtils.AddStyleTag(addGroupButton, StyleConsts.tags.EmphasisButton)
	StyleUtils.AddStyleTag(addGroupButton, StyleConsts.tags.AddItemButton)

	card = makeZeroStateCard(category, function(cardButton)
		menu:Open(cardButton)
	end)

	local body = makeSectionBody(card, groupContainer)
	onBodyStateChangedCallback(groupStack:HasGroups())

	return makeSectionFrame(category, addGroupButton, body, layoutOrder)
end

-- Whether any layer is selected across all of this tool's category group stacks.
function LayerToolUI:HasSelectedLayer(): boolean
	for _, groupStack in self.groupStacks do
		if groupStack:HasSelectedLayer() then
			return true
		end
	end
	return false
end

function LayerToolUI:SetShowGuidesVisible(isVisible: boolean)
	StyleUtils.SetStyleTag(self.showGuidesChipFrame, StyleConsts.tags.Hidden, not isVisible)
end

-- Display the accessory's actual group, rebuilding layer rows when its mesh is replaced.
function LayerToolUI:SetAccessoryGroup(groupInfo: GroupInfo.GroupInfo)
	local groupStack = self.groupStacks[CATEGORY_INDEX_BY_ASSET_TYPE[groupInfo.makeupAssetType]]
	local existing = groupStack.groups[groupInfo.name]
	if existing and existing.groupInfo ~= groupInfo then
		local previousOrder = existing.layoutOrder
		groupStack:DeleteGroup(groupInfo.name, true)
		groupStack:AddGroup(nil, groupInfo)
		if previousOrder ~= groupStack.groups[groupInfo.name].layoutOrder then
			groupStack:MoveGroup(groupInfo.name, 1, nil, true)
		end
	elseif not existing then
		groupStack:AddGroup(nil, groupInfo)
	end
	groupStack:SelectFirstLayer(groupInfo.name)
end

function LayerToolUI:DeleteAccessoryGroup(assetType: string): boolean
	local categoryIndex = CATEGORY_INDEX_BY_ASSET_TYPE[assetType]
	local groupStack = categoryIndex and self.groupStacks[categoryIndex]
	if not groupStack or not Constants.MAKEUP_ACCESSORY_ASSET_TYPES[assetType] then
		return false
	end

	local groupId = groupStack:FindGroupByMakeupAssetType(assetType)
	if not groupId then
		return false
	end

	groupStack:DeleteGroup(groupId)
	return true
end

function LayerToolUI:Open()
	self.panel.Visible = true
end

function LayerToolUI:Close()
	self.panel.Visible = false
	for _, menu in self.makeupItemMenus do
		menu:Close()
	end
	for _, groupStack in self.groupStacks do
		groupStack:CloseOptionMenus()
	end
end

-- Programmatically select a layer in the stack
function LayerToolUI:SelectLayer(targetLayerInfo: GroupInfo.TargetLayerInfo)
	-- select default group
	if not targetLayerInfo.groupId then
		local groupStack = self.groupStacks[1]
		if groupStack then
			groupStack:SelectLayer(targetLayerInfo)
		end
		return
	end

	for _, groupStack in self.groupStacks do
		if groupStack:HasGroup(targetLayerInfo.groupId) then
			groupStack:SelectLayer(targetLayerInfo)
			return
		end
	end

	warn("LayerToolUI:SelectLayer called with unknown group: " .. targetLayerInfo.groupId)
end

return LayerToolUI
