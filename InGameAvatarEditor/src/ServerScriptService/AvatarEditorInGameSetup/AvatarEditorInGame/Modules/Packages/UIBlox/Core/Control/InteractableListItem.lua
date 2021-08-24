
local Control = script.Parent
local Core = Control.Parent
local UIBlox = Core.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)
local Cryo = require(Packages.Cryo)

local Interactable = require(UIBlox.Core.Control.Interactable)
local UIBloxConfig = require(Packages.UIBlox.UIBloxConfig)

local SelectionMode = require(script.Parent.Enum.SelectionMode)

local ID_PROP_NAME = UIBloxConfig.renameKeyProp and "id" or "key"

--[[
	subcomponent of InteractableList, not intended for use separately
	extracted from the main component's code to cache the onStateChanged and onActivated callbacks
]]

local InteractableListItem = Roact.PureComponent:extend("InteractableListItem")

function InteractableListItem:init()
	self.onStateChanged = function(oldState, newState)
		self.props.setInteractableState(self.props[ID_PROP_NAME], newState)
	end
	self.onActivated = function()
		local oldSelection = self.props.selection
		local newSelection = { self.props[ID_PROP_NAME] }
		if self.props.selectionMode == SelectionMode.Multiple then
			newSelection = Cryo.List.filter(oldSelection, function(selectedKey)
				return selectedKey ~= self.props[ID_PROP_NAME]
			end)
			if #newSelection == #oldSelection then
				table.insert(newSelection, self.props[ID_PROP_NAME])
			end
		end
		if self.props.onSelectionChanged then
			self.props.onSelectionChanged(newSelection, oldSelection)
		end
		if self.props.selectionMode ~= SelectionMode.None then
			self.props.setSelection(newSelection)
		end
	end
end

function InteractableListItem:render()
	local selected = Cryo.List.find(self.props.selection, self.props[ID_PROP_NAME]) ~= nil
	local renderedItem, extraProps = self.props.renderItem(self.props.item, self.props.interactableState, selected)

	return Roact.createElement(Interactable, Cryo.Dictionary.join({
		Size = self.props.itemSize,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, extraProps or {}, {
		onStateChanged = self.onStateChanged,
		[Roact.Event.Activated] = self.onActivated,
	}), {
		[self.props[ID_PROP_NAME]] = renderedItem,
	})
end

return InteractableListItem
