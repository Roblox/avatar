--[[
	Specific UI component for managing layers within a container.
	This includes adding, removing, and reordering layers.
]]

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local LayerTile = require(Components:WaitForChild("LayerTile"))
local TextButton = require(Components:WaitForChild("TextButton"))
local CollapsibleChild = require(Components:WaitForChild("CollapsibleChild"))
local Slider = require(Components:WaitForChild("Slider"))
local DropdownMenu = require(Components:WaitForChild("DropdownMenu"))

local LayerStack = {}
LayerStack.__index = LayerStack

export type addLayerCallbackInfo = {
	-- Content for the layer's thumbnail. Wraps the live EditableImage when the
	-- layer's group is active, or the baked static content when it is cached.
	thumbnailContent: Content?,
	isVisible: boolean,
	opacity: number?,
	onOpacityChangedCallback: (opacity: number, isFinalInput: boolean) -> (),
}

-- We can assume this will return an ID; while we don't expect layer info to get
-- out of sync, if it does, the error will be caught by the client and will stop
-- execution.
function LayerStack:GetUniqueLayerId(): string
	-- Get first available number based on existing layers.
	for i = 1, self.maxLayers do
		local potentialId = "Layer " .. i
		if not self.layers[potentialId] then
			return potentialId
		end
	end

	error("No unique layer ID available.")
end

function LayerStack:GenerateButtonList(layerId: string, isVisible: boolean)
	local menu = DropdownMenu.new({
		options = {
			{
				name = "Move Up",
				getIsDisabled = function()
					local layerInfo = self.layers[layerId]
					return layerInfo == nil or layerInfo.layoutOrder <= -self.currentLayerCount
				end,
				onSelect = function()
					self:MoveLayer(layerId, -1)
				end,
			},
			{
				name = "Move Down",
				getIsDisabled = function()
					local layerInfo = self.layers[layerId]
					return layerInfo == nil or layerInfo.layoutOrder >= -1
				end,
				onSelect = function()
					self:MoveLayer(layerId, 1)
				end,
			},
			{
				name = "Delete",
				onSelect = function()
					self:DeleteLayer(layerId)
				end,
			},
		},
	})
	self.optionMenus[layerId] = menu

	local buttonInfos = {
		{
			iconId = StyleConsts.icons.Visibility,
			inactiveIconId = StyleConsts.icons.VisibilityOff,
			isActive = isVisible,
			callback = function(_, newIsVisible)
				assert(newIsVisible ~= nil)
				self.onSetVisibilityCallback(layerId, newIsVisible)
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

function LayerStack:SelectLayer(layerId: string)
	if self.manager then
		self.manager:SecondarySelect()
	end
	self:DeselectAllLayers()
	self.selectedLayerId = layerId
	self.onSelectLayerCallback(layerId)

	-- select the layer's collapsible child (skip if the layer isn't tracked in the stack)
	local layerInfo = self.layers[layerId]
	if layerInfo then
		layerInfo.collapsibleChild:Select()
	end
end

function LayerStack:HasSelectedLayer(): boolean
	return self.selectedLayerId ~= nil
end

-- Refreshes move availability for any menus that are currently open.
function LayerStack:UpdateMoveButtonStates()
	for _, menu in self.optionMenus do
		menu:UpdateOptionStates()
	end
end

function LayerStack:CloseOptionMenus()
	for _, menu in self.optionMenus do
		menu:Close()
	end
end

function LayerStack:DestroyOptionMenus()
	for _, menu in self.optionMenus do
		menu:Destroy()
	end
	table.clear(self.optionMenus)
end

function LayerStack:DeselectAllLayers()
	self.selectedLayerId = nil
	for _, layerInfo in self.layers do
		local collapsibleChild = layerInfo.collapsibleChild
		collapsibleChild:Deselect()
	end
end

function LayerStack:MoveLayer(layerId: string, direction: number, noSwappableLayer: boolean?)
	local layerInfo = self.layers[layerId]
	if not layerInfo then
		warn("Layer with ID " .. layerId .. " does not exist.")
		return
	end

	local currentLayoutOrder = layerInfo.layoutOrder
	if currentLayoutOrder <= -self.currentLayerCount and direction <= -1 then
		warn("Layer is already at the top; cannot move up.")
		return
	end
	if currentLayoutOrder >= -1 and direction >= 1 then
		warn("Layer is already at the bottom; cannot move down.")
		return
	end

	-- If we know there isn't a layer to swap with (as in deletion), just modify
	-- the layout order directly.
	if noSwappableLayer then
		layerInfo.layoutOrder = currentLayoutOrder + direction
		layerInfo.collapsibleChild:GetFrame().LayoutOrder = layerInfo.layoutOrder
		return
	end

	-- Find existing layer in specified direction and swap layout orders
	for _, otherLayerInfo in self.layers do
		if otherLayerInfo.layoutOrder == currentLayoutOrder + direction then
			-- Swap layout orders
			layerInfo.layoutOrder = currentLayoutOrder + direction
			otherLayerInfo.layoutOrder = currentLayoutOrder

			-- Update UI elements' LayoutOrder properties
			layerInfo.collapsibleChild:GetFrame().LayoutOrder = layerInfo.layoutOrder
			otherLayerInfo.collapsibleChild:GetFrame().LayoutOrder = otherLayerInfo.layoutOrder

			-- Notify once per swap (primary layer only)
			self.onMoveLayerCallback(layerId, direction)
			self:UpdateMoveButtonStates()
			return
		end
	end

	warn("No layer found in direction " .. direction .. " to swap with for layer ID: " .. layerId)
end

function LayerStack:DeleteLayer(layerId: string)
	-- Delete layer from layer info table
	local layerInfo = self.layers[layerId]
	if not layerInfo then
		warn("Layer with ID " .. layerId .. " does not exist.")
		return
	end

	-- If currently selected, select a neighboring layer if possible
	if self.selectedLayerId == layerId then
		-- Capture the nearest neighbor IDs before any layout order shifts so
		-- the comparisons reflect the original stack positions.
		-- Prefer above neighbor (more negative layout order) if available,
		-- otherwise fallback to below neighbor.
		local neighborId = nil
		for otherLayerId, otherLayer in self.layers do
			if otherLayer.layoutOrder == layerInfo.layoutOrder - 1 then
				neighborId = otherLayerId -- directly above
				break
			elseif otherLayer.layoutOrder == layerInfo.layoutOrder + 1 then
				neighborId = otherLayerId -- directly below
			end
		end
		if neighborId then
			self:SelectLayer(neighborId)
		else
			self.selectedLayerId = nil
		end
	end

	local collapsibleChild = layerInfo.collapsibleChild
	local menu = self.optionMenus[layerId]
	if menu then
		menu:Destroy()
		self.optionMenus[layerId] = nil
	end
	self.layers[layerId] = nil
	self.currentLayerCount -= 1

	-- Shift layout orders of layers above the deleted slot down to fill the gap.
	for otherLayerId, otherLayer in self.layers do
		if otherLayer.layoutOrder < layerInfo.layoutOrder then
			self:MoveLayer(otherLayerId, 1, true)
		end
	end

	collapsibleChild:Destroy()
	self.onDeleteLayerCallback(layerId)

	if self.currentLayerCount < self.maxLayers then
		self:SetAddLayerButtonVisibility(true)
	end

	self:UpdateMoveButtonStates()
end

function LayerStack:AddLayer(layerId: string?, addLayerCallbackInfo: addLayerCallbackInfo)
	if self.currentLayerCount >= self.maxLayers then
		warn("Cannot add more layers; maximum reached.")
		return
	end

	local newLayer = false

	-- Get layerId if not provided
	if not layerId then
		layerId = self:GetUniqueLayerId()
		newLayer = true
	end
	assert(layerId, "Layer ID must be provided or generated.")

	-- Negate layout order so that new layers appear at the top of the stack
	local layoutOrder = -(self.currentLayerCount + 1)

	-- Get callback info if not provided
	if not addLayerCallbackInfo then
		addLayerCallbackInfo = self.onAddLayerCallback(layerId)
	end

	if not addLayerCallbackInfo.onOpacityChangedCallback then
		warn("Invalid addLayerCallbackInfo for layer: " .. layerId)
		return
	end

	-- Create layer tile and collapsible frame
	local layerTile = LayerTile.new(
		addLayerCallbackInfo.thumbnailContent,
		layerId,
		self:GenerateButtonList(layerId, addLayerCallbackInfo.isVisible)
	)
	local layerTileFrame = layerTile:GetFrame()
	layerTileFrame.Parent = self.layersContainer

	-- Slider construction emits its initial value; suppress that callback so
	-- rebuilding the UI does not create a redundant opacity action.
	local isSliderInitialized = false
	local layerOpacitySlider = Slider.new(
		addLayerCallbackInfo.opacity or 1,
		function(value, isFinalInput)
			if isSliderInitialized then
				addLayerCallbackInfo.onOpacityChangedCallback(value, isFinalInput)
			end
		end
	):GetFrame()
	isSliderInitialized = true
	StyleUtils.AddStyleTag(layerOpacitySlider, StyleConsts.tags.LayerOpacitySlider)

	local collapsibleChild = CollapsibleChild.new(layerTileFrame, layerOpacitySlider, function()
		self:SelectLayer(layerId)
	end)
	local collapsibleChildFrame = collapsibleChild:GetFrame()
	collapsibleChildFrame.Parent = self.layersContainer
	collapsibleChildFrame.LayoutOrder = layoutOrder

	-- Update internal state
	self.layers[layerId] = {
		collapsibleChild = collapsibleChild,
		layoutOrder = layoutOrder,
		layerTile = layerTile,
	}
	self.currentLayerCount += 1

	-- Select the newly added layer only if not populating existing layers
	if newLayer then
		self:SelectLayer(layerId)
	end

	if self.currentLayerCount >= self.maxLayers then
		self:SetAddLayerButtonVisibility(false)
	end

	self:UpdateMoveButtonStates()
end

function LayerStack:AddManager(manager)
	-- Manager should be a stateful component with a :SecondarySelect method.
	self.manager = manager
end

function LayerStack:SetAddLayerButtonVisibility(isVisible: boolean)
	self.addLayerButton.Visible = isVisible
end

-- Updates a layer tile's thumbnail image. Used when a layer's group is cached or
-- rehydrated, so the preview follows the layer between its live EditableImage and
-- its baked static content.
function LayerStack:SetLayerThumbnail(layerId: string, content: Content?)
	local layerInfo = self.layers[layerId]
	if layerInfo and layerInfo.layerTile then
		layerInfo.layerTile:SetThumbnail(content)
	end
end

function LayerStack:CreateAddLayerButton(): Frame
	local button = TextButton.createComponentFrame({
		callback = function()
			self:AddLayer()
		end,
	})
	button.Name = "AddLayerButton"
	StyleUtils.AddStyleTag(button, StyleConsts.tags.AddLayerButton)

	local iconFrame = Instance.new("Frame")
	iconFrame.Name = "AddLayerIconFrame"
	iconFrame.LayoutOrder = 1
	iconFrame.Parent = button

	local icon = Instance.new("ImageLabel")
	icon.Name = "AddLayerIcon"
	icon.Image = StyleConsts.icons.PlusButton
	icon.Parent = iconFrame

	local label = Instance.new("TextLabel")
	label.Name = "AddLayerLabel"
	label.Text = "Add Layer"
	label.LayoutOrder = 2
	label.Parent = button

	return button
end

function LayerStack.new(
	maxLayers: number,
	onAddLayerCallback: (layerId: string) -> addLayerCallbackInfo,
	onSelectLayerCallback: (layerId: string) -> (),
	onDeleteLayerCallback: (layerId: string) -> (),
	onMoveLayerCallback: (layerId: string, direction: number) -> (),
	onSetVisibilityCallback: (layerId: string, isVisible: boolean) -> ()
)
	local self = {}
	setmetatable(self, LayerStack)

	self.onAddLayerCallback = onAddLayerCallback
	self.onSelectLayerCallback = onSelectLayerCallback
	self.onDeleteLayerCallback = onDeleteLayerCallback
	self.onMoveLayerCallback = onMoveLayerCallback
	self.onSetVisibilityCallback = onSetVisibilityCallback

	self.maxLayers = maxLayers
	self.currentLayerCount = 0
	self.selectedLayerId = nil
	self.optionMenus = {}
	self.layers = {
		--[[
			Structure:
			[layerId] : {
				collapsibleChild: CollapsibleChild,
				layoutOrder: number,
			}
		]]
	}

	self.frame = Instance.new("Frame")
	self.frame.Name = "LayerStack"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.LayerStack)

	self.layersContainer = Instance.new("Frame")
	self.layersContainer.Name = "LayersContainer"
	self.layersContainer.Parent = self.frame
	self.layersContainer.LayoutOrder = 1
	StyleUtils.AddStyleTag(self.layersContainer, StyleConsts.tags.LayersContainer)

	self.addLayerButton = self:CreateAddLayerButton()
	self.addLayerButton.Parent = self.frame
	self.addLayerButton.LayoutOrder = 2

	return self
end

return LayerStack
