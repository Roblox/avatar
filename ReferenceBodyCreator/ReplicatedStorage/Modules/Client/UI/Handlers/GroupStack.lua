--[[
	UI handler for managing layer groups within a texture. Creates collapsible
	group containers, each holding a LayerStack, and coordinates adding,
	removing, and reordering groups.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local GroupInfo = require(TextureManipulation:WaitForChild("GroupInfo")) -- For type

local UI = script.Parent.Parent

local Components = UI:WaitForChild("Components")
local CollapsibleContainer = require(Components:WaitForChild("CollapsibleContainer"))
local LayerStack = require(Components:WaitForChild("LayerStack"))
local LayerTile = require(Components:WaitForChild("LayerTile"))
local DropdownMenu = require(Components:WaitForChild("DropdownMenu"))

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local GroupStack = {}
GroupStack.__index = GroupStack

type GroupList = {
	[--[[groupId: ]]string]: {
		collapsibleGroup: any, -- CollapsibleContainer
		layoutOrder: number,
		layerStack: any,
		layerTile: any, -- LayerTile (the group's visible tile)
		groupInfo: GroupInfo.GroupInfo,
	},
}

type LayerInfo = {
	layerId: string,
	addLayerCallbackInfo: LayerStack.addLayerCallbackInfo,
}

function GroupStack:GetGroupName(groupPrefix: string): string
	local count = 1

	for _ in self.groups do
		if not self.groups[groupPrefix .. " " .. count] then
			return groupPrefix .. " " .. count
		end
		count += 1
	end

	return groupPrefix .. " " .. count
end

function GroupStack:GenerateButtonList(groupId: string, isVisible: boolean)
	local menu = DropdownMenu.new({
		options = {
			{
				name = "Move Up",
				getIsDisabled = function()
					local group = self.groups[groupId]
					return group == nil or group.layoutOrder <= -self.groupCount
				end,
				onSelect = function()
					self:MoveGroup(groupId, -1)
				end,
			},
			{
				name = "Move Down",
				getIsDisabled = function()
					local group = self.groups[groupId]
					return group == nil or group.layoutOrder >= -1
				end,
				onSelect = function()
					self:MoveGroup(groupId, 1)
				end,
			},
			{
				name = "Delete",
				onSelect = function()
					self:DeleteGroup(groupId)
				end,
			},
		},
	})
	self.optionMenus[groupId] = menu

	local buttonInfos = {
		{
			iconId = StyleConsts.icons.Visibility,
			inactiveIconId = StyleConsts.icons.VisibilityOff,
			isActive = isVisible,
			callback = function(_, newIsVisible)
				assert(newIsVisible ~= nil)
				self.onSetGroupVisibilityCallback(groupId, newIsVisible)
			end,
		},
		{
			iconId = StyleConsts.icons.MoreOptions,
			callback = function(anchor)
				menu:Open(anchor)
			end,
		},
	}

	return buttonInfos
end

function GroupStack:CreateCollapsibleGroup(
	thumbnailContent: Content,
	groupId: string,
	isVisible: boolean,
	existingLayerInfos: { LayerInfo }
)
	-- First set up layer stack
	local addLayerCallback = function(layerId: string)
		return self.onAddLayerCallback({ groupId = groupId, layerId = layerId })
	end

	local deleteLayerCallback = function(layerId: string)
		return self.onDeleteLayerCallback({ groupId = groupId, layerId = layerId })
	end

	local selectLayerCallback = function(layerId: string)
		self:DeselectOtherGroups(groupId)
		local result = self.onSelectLayerCallback({ groupId = groupId, layerId = layerId })
		self:RefreshAllThumbnails()
		return result
	end
	local moveLayerCallback = function(layerId: string, direction: number)
		return self.onMoveLayerCallback({ groupId = groupId, layerId = layerId }, direction)
	end
	local setLayerVisibilityCallback = function(layerId: string, isVisible: boolean)
		return self.onSetLayerVisibilityCallback({ groupId = groupId, layerId = layerId }, isVisible)
	end

	local layerStack = LayerStack.new(
		Constants.MAX_LAYERS_PER_GROUP,
		addLayerCallback,
		selectLayerCallback,
		deleteLayerCallback,
		moveLayerCallback,
		setLayerVisibilityCallback
	)

	-- Populate existing layers in the layer stack
	for _, layerInfo in existingLayerInfos do
		layerStack:AddLayer(layerInfo.layerId, layerInfo.addLayerCallbackInfo)
	end

	-- The group tile and head preview share the same visibility-filtered composite.
	local layerTile = LayerTile.new(thumbnailContent, groupId, self:GenerateButtonList(groupId, isVisible))

	local collapsibleContainer
	collapsibleContainer = CollapsibleContainer.new(
		layerTile:GetFrame(), -- Visible content
		layerStack.frame, -- Bottom content
		function() -- onSelect
			self:DeselectAllGroupContainers()
			layerStack:DeselectAllLayers()
			self.onSelectGroupCallback(groupId)
			self:RefreshAllThumbnails()
		end,
		function() -- onDeselect
			layerStack:DeselectAllLayers()
		end,
		function()
			if collapsibleContainer:GetFrame():HasTag(StyleConsts.tags.CollapsibleSecondarySelection) then
				collapsibleContainer:ToggleCollapse()
			elseif next(layerStack.layers) then
				self:SelectFirstLayer(groupId)
			else
				collapsibleContainer:Select()
			end
		end
	)

	layerStack:AddManager(collapsibleContainer)

	return collapsibleContainer, layerStack, layerTile
end

function GroupStack:DeselectAllGroupContainers()
	for _, group in self.groups do
		group.collapsibleGroup:Deselect()
	end
end

-- Clears the selection highlight and layer selection from a single group,
-- collapsing it only if it currently has a selected layer.
local function deselectGroup(group)
	if group.layerStack:HasSelectedLayer() then
		group.collapsibleGroup:Collapse()
	end
	group.collapsibleGroup:ClearSelectionHighlight()
	group.layerStack:DeselectAllLayers()
end

-- Clears the selection highlight and layer selection from every group except the
-- given one.
function GroupStack:DeselectOtherGroups(exceptGroupId: string)
	for groupId, group in self.groups do
		if groupId ~= exceptGroupId then
			deselectGroup(group)
		end
	end
end

-- Clears the selection highlight and layer selection from every group in this
-- stack. Used to coordinate single-selection across sibling category stacks.
function GroupStack:DeselectAll()
	for _, group in self.groups do
		deselectGroup(group)
	end
end

-- Whether any group in this stack currently has a selected layer.
function GroupStack:HasSelectedLayer(): boolean
	for _, group in self.groups do
		if group.layerStack:HasSelectedLayer() then
			return true
		end
	end
	return false
end

-- Refreshes move availability for any menus that are currently open.
function GroupStack:UpdateMoveButtonStates()
	for _, menu in self.optionMenus do
		menu:UpdateOptionStates()
	end
end

function GroupStack:CloseOptionMenus()
	for _, menu in self.optionMenus do
		menu:Close()
	end
	for _, group in self.groups do
		group.layerStack:CloseOptionMenus()
	end
end

-- Repoints every layer tile's thumbnail at its layer's current renderable content:
-- the live EditableImage for the active group, or the baked static content for
-- cached (inactive) groups. Call after a group switch.
function GroupStack:RefreshAllThumbnails()
	for _, group in self.groups do
		group.layerTile:SetThumbnail(self.getGroupThumbnailContent(group.groupInfo))
		for _, layer in group.groupInfo.inputLayers do
			group.layerStack:SetLayerThumbnail(layer.name, layer.thumbnailContent)
		end
	end
end

function GroupStack:SelectLayer(targetLayerInfo: GroupInfo.TargetLayerInfo)
	local groupId = targetLayerInfo.groupId
	if not groupId then
		-- The brush layer is a reserved layer that lives outside every group,
		-- remove when this doesn't exist anymore
		self:DeselectAllGroupContainers()
		self.onSelectLayerCallback(targetLayerInfo)
		return
	end

	local group = self.groups[groupId]
	if not group then
		warn("GroupStack:SelectLayer called with unknown group: " .. groupId)
		return
	end

	self:DeselectAllGroupContainers()
	group.layerStack:SelectLayer(targetLayerInfo.layerId)
end

function GroupStack:AddGroup(groupPrefix: string?, groupInfo: GroupInfo.GroupInfo?, makeupAssetType: string?): string?
	local groupId
	local isNewGroup = groupInfo == nil
	-- Get groupId and groupInfo
	if groupInfo then
		groupId = groupInfo.name
	else
		assert(groupPrefix, "groupPrefix must be provided if groupInfo is not provided")
		groupId = self:GetGroupName(groupPrefix)
		groupInfo = self.onAddGroupCallback(groupId, makeupAssetType)

		-- A nil result means the add was rejected by the data layer (e.g. the
		-- MAX_GROUPS limit was reached), so there is no group to display.
		if not groupInfo then
			return
		end
	end
	assert(groupInfo, "groupInfo must be provided or onAddGroupCallback must return a valid GroupInfo")

	-- Get existing layers if any
	local existingLayerInfos = {}
	for _, layer in groupInfo.inputLayers do
		table.insert(existingLayerInfos, {
			layerId = layer.name,
			addLayerCallbackInfo = {
				thumbnailContent = layer.thumbnailContent,
				isVisible = layer.isVisible,
				opacity = layer.opacity or 1,
				onOpacityChangedCallback = function(newOpacity: number, isFinalInput: boolean)
					self.onChangeOpacityCallback({ groupId = groupId, layerId = layer.name }, newOpacity, isFinalInput)
				end,
			},
		})
	end

	-- Create new collapsible group component
	local newCollapsibleGroup, layerStack, layerTile = self:CreateCollapsibleGroup(
		self.getGroupThumbnailContent(groupInfo),
		groupId,
		groupInfo.isVisible,
		existingLayerInfos
	)
	self.groupCount += 1
	local layoutOrder = -self.groupCount

	self.groups[groupId] = {
		collapsibleGroup = newCollapsibleGroup,
		layoutOrder = layoutOrder,
		layerStack = layerStack,
		layerTile = layerTile,
		groupInfo = groupInfo,
	}
	local newCollapsibleGroupFrame = newCollapsibleGroup:GetFrame()
	newCollapsibleGroupFrame.Parent = self.groupsContainer
	newCollapsibleGroupFrame.LayoutOrder = layoutOrder

	-- Create and select a default layer for newly created groups.
	if isNewGroup then
		self:DeselectAllGroupContainers()
		layerStack:AddLayer()

		self:RefreshAllThumbnails()
	end

	self:UpdateMoveButtonStates()

	if self.onHasGroupsChanged then
		self.onHasGroupsChanged(self.groupCount > 0)
	end

	return groupId
end

function GroupStack:FindGroupByMakeupAssetType(makeupAssetType: string): string?
	for groupId, group in self.groups do
		if group.groupInfo.makeupAssetType == makeupAssetType then
			return groupId
		end
	end
	return nil
end

function GroupStack:SelectFirstLayer(groupId: string)
	local group = self.groups[groupId]
	if not group then
		warn("Group info not found: " .. groupId)
		return
	end

	local firstLayerId
	local firstLayoutOrder = math.huge
	for layerId, layer in group.layerStack.layers do
		if layer.layoutOrder < firstLayoutOrder then
			firstLayerId = layerId
			firstLayoutOrder = layer.layoutOrder
		end
	end
	if firstLayerId then
		self:SelectLayer({ groupId = groupId, layerId = firstLayerId })
	else
		group.layerStack:AddLayer()
	end
end

function GroupStack:MoveGroup(groupId: string, direction: number, noSwappableLayer: boolean?, replacing: boolean?)
	local group = self.groups[groupId]
	if not group then
		warn("Group info not found: " .. groupId)
		return
	end

	local currentGroupOrder = group.layoutOrder
	if currentGroupOrder <= -self.groupCount and direction <= -1 then
		warn("Group is already at the top; cannot move up.")
		return
	end
	if currentGroupOrder >= -1 and direction >= 1 then
		warn("Group is already at the bottom; cannot move down.")
		return
	end

	-- If we know there isn't a layer to swap with (as in deletion), just modify
	-- the layout order directly.
	if noSwappableLayer then
		group.layoutOrder = currentGroupOrder + direction
		group.collapsibleGroup:GetFrame().LayoutOrder = group.layoutOrder
		return
	end

	-- Find the other group that currently has the new layout order
	for _, otherGroup in self.groups do
		local newLayoutOrder = currentGroupOrder + direction
		if otherGroup.layoutOrder == newLayoutOrder then
			-- Swap layout orders
			otherGroup.layoutOrder = group.layoutOrder
			otherGroup.collapsibleGroup:GetFrame().LayoutOrder = otherGroup.layoutOrder

			group.layoutOrder = newLayoutOrder
			group.collapsibleGroup:GetFrame().LayoutOrder = group.layoutOrder

			if not replacing then
				self.onMoveGroupCallback(groupId, direction)
			end
			break
		end
	end

	self:UpdateMoveButtonStates()
end

function GroupStack:DeleteGroup(groupId: string, replacing: boolean?)
	local group = self.groups[groupId]
	if not group then
		warn("Group info not found: " .. groupId)
		return
	end

	local menu = self.optionMenus[groupId]
	if menu then
		menu:Destroy()
		self.optionMenus[groupId] = nil
	end
	group.layerStack:DestroyOptionMenus()
	group.collapsibleGroup:GetFrame():Destroy()
	self.groups[groupId] = nil
	self.groupCount -= 1

	-- Shift layout orders of remaining groups
	for otherGroupId, otherGroup in self.groups do
		if otherGroup.layoutOrder < group.layoutOrder then
			self:MoveGroup(otherGroupId, 1, true) -- Move up without swapping
		end
	end

	if not replacing then
		self.onDeleteGroupCallback(groupId)
	end

	self:UpdateMoveButtonStates()

	if self.onHasGroupsChanged then
		self.onHasGroupsChanged(self.groupCount > 0)
	end
end

function GroupStack:CreateExistingGroups(existingGroupInfos: { GroupInfo.GroupInfo })
	for _, groupInfo in existingGroupInfos do
		self:AddGroup(nil, groupInfo)
	end
end

function GroupStack.new(
	existingGroupInfos: { GroupInfo.GroupInfo },
	getGroupThumbnailContent: (GroupInfo.GroupInfo) -> Content,
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
	onHasGroupsChanged: ((hasGroups: boolean) -> ())?
)
	local self = {}
	setmetatable(self, GroupStack)

	self.groupCount = 0
	self.groups = {} :: GroupList
	self.optionMenus = {}

	self.getGroupThumbnailContent = getGroupThumbnailContent
	self.onAddLayerCallback = onAddLayerCallback
	self.onDeleteLayerCallback = onDeleteLayerCallback
	self.onSelectLayerCallback = onSelectLayerCallback
	self.onMoveLayerCallback = onMoveLayerCallback
	self.onAddGroupCallback = onAddGroupCallback
	self.onDeleteGroupCallback = onDeleteGroupCallback
	self.onMoveGroupCallback = onMoveGroupCallback
	self.onSelectGroupCallback = onSelectGroupCallback
	self.onChangeOpacityCallback = onChangeOpacityCallback
	self.onSetLayerVisibilityCallback = onSetLayerVisibilityCallback
	self.onSetGroupVisibilityCallback = onSetGroupVisibilityCallback

	-- Create groups container
	self.groupsContainer = Instance.new("Frame")
	self.groupsContainer.Name = "GroupsContainer"
	StyleUtils.AddStyleTag(self.groupsContainer, StyleConsts.tags.ToolFrame)

	self:CreateExistingGroups(existingGroupInfos)
	self.onHasGroupsChanged = onHasGroupsChanged

	return self
end

function GroupStack:GetFrame()
	return self.groupsContainer
end

function GroupStack:HasGroups(): boolean
	return self.groupCount > 0
end

function GroupStack:GetGroupCount(): number
	return self.groupCount
end

function GroupStack:HasGroup(groupId: string): boolean
	return self.groups[groupId] ~= nil
end

return GroupStack
