local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local EquipSlots = require(Modules.AvatarExperience.AvatarEditor.Components.EquipSlots)
local ItemsList = require(Modules.AvatarExperience.AvatarEditor.Components.ItemsList)
local SetSelectedEmoteSlot = require(Modules.AvatarExperience.AvatarEditor.Actions.SetSelectedEmoteSlot)

local EmotesPage = Roact.PureComponent:extend("EmotesPage")

local SLOTS_HEIGHT = 72

function EmotesPage:render()
	return withStyle(function(stylePalette)
		local lockNavigationCallback = self.props.lockNavigationCallback
		local unlockNavigationCallback = self.props.unlockNavigationCallback
		local categoryInfo = self.props.categoryInfo
		local setSelectedEmoteSlot = self.props.setSelectedEmoteSlot

		return Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			BackgroundTransparency = 1,
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),
			}),

			EquipSlots = Roact.createElement(EquipSlots, {
				slotsCount = categoryInfo.EquipSlotsCount,
				lockNavigationCallback = lockNavigationCallback,
				unlockNavigationCallback = unlockNavigationCallback,
				onActivated = setSelectedEmoteSlot,
				LayoutOrder = 1,
			}),

			Tiles = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, -SLOTS_HEIGHT),
				LayoutOrder = 2,
			}, {
				ItemsList = Roact.createElement(ItemsList),
			}),
		})
	end)
end

local function mapDispatchToProps(dispatch)
	return {
		setSelectedEmoteSlot = function(selectedSlot)
			dispatch(SetSelectedEmoteSlot(selectedSlot))
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(nil, mapDispatchToProps)(EmotesPage)