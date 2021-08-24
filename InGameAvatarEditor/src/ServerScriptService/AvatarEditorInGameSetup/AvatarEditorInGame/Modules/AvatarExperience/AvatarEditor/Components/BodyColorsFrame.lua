local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)
local BodyColorButton = require(Modules.AvatarExperience.AvatarEditor.Components.BodyColorButton)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local ShimmerAnimation = require(Modules.NotLApp.ShimmerAnimation)
local FitChildren = require(Modules.NotLApp.FitChildren)

local UIBlox = require(Modules.Packages.UIBlox)
local GridMetrics = UIBlox.App.Grid.GridMetrics

local LoadableGridView = require(Modules.AvatarExperience.Common.Components.LoadableGridView)

local BodyColorsFrame = Roact.PureComponent:extend("BodyColorsFrame")

local SHIMMER_CARDS_NUMBER = AvatarEditorConstants.ShimmerColorCardsToDisplay
local SKIN_COLOR_GRID_PADDING = 12
local MIN_ITEMS_PER_ROW = 4
local MIN_WIDTH = 60

local metricSettings = {
	minimumItemsPerRow = MIN_ITEMS_PER_ROW,
	minimumItemWidth = MIN_WIDTH,
}

-- Change format of hex string from API ("#55555") to hex number (0x55555)
local function hexStringToNumber(hexString)
	return tonumber(string.sub(hexString, 2), 16)
end

function BodyColorsFrame:init()
	self.renderItem = function(item)
		if item.brickColorId then
			return Roact.createElement(BodyColorButton, {
				brickId = item.brickColorId,
				brickColor = hexStringToNumber(item.hexColor),
			})
		else
			return Roact.createElement(ShimmerAnimation, {
				Size = UDim2.new(1, 0, 1, 0),
			})
		end
	end
end

function BodyColorsFrame:render()
	local defaultBodyColors = self.props.defaultBodyColors
	local size = self.props.Size

	local hasDefaultBodyColors = defaultBodyColors and #defaultBodyColors > 0

	return Roact.createElement(FitChildren.FitScrollingFrame, {
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(1, 0, 0, 0),
		ScrollBarThickness = 0,
		Size = size,
		fitFields = {
			CanvasSize = FitChildren.FitAxis.Height,
		},
	}, {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, SKIN_COLOR_GRID_PADDING),
			PaddingBottom = UDim.new(0, SKIN_COLOR_GRID_PADDING),
			PaddingLeft = UDim.new(0, SKIN_COLOR_GRID_PADDING),
			PaddingRight = UDim.new(0, SKIN_COLOR_GRID_PADDING),
		}),
		Buttons = Roact.createElement(LoadableGridView, {
			getItemHeight = AvatarExperienceUtils.GridItemHeightGetter(AvatarExperienceConstants.ItemType.BodyColorButton),
			getItemMetrics = GridMetrics.makeCustomMetricsGetter(metricSettings),
			numItemsExpected = SHIMMER_CARDS_NUMBER,
			itemPadding = Vector2.new(SKIN_COLOR_GRID_PADDING, SKIN_COLOR_GRID_PADDING),
			items = hasDefaultBodyColors and defaultBodyColors or nil,
			renderItem = self.renderItem,
		}),
	})
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			defaultBodyColors = state.AvatarExperience.AvatarEditor.DefaultBodyColors,
		}
	end
)(BodyColorsFrame)
