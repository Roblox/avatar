local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local FitChildren = require(Modules.NotLApp.FitChildren)

local GridView = UIBlox.App.Grid.DefaultMetricsGridView
local GridMetrics = UIBlox.App.Grid.GridMetrics

local CELL_PADDING = 10

local LoadableGridView = Roact.PureComponent:extend("LoadableGridView")

LoadableGridView.defaultProps = {
	getItemMetrics = GridMetrics.getSmallMetrics,
}

function LoadableGridView:render()
	local items = self.props.items
	local numItemsExpected = self.props.numItemsExpected
	local layoutOrder = self.props.LayoutOrder
	local getItemHeight = self.props.getItemHeight
	local windowHeight = self.props.windowHeight
	local getItemMetrics = self.props.getItemMetrics

	if not items then
		items = {}
		for i = 1, numItemsExpected do
			items[i] = {}
		end
	end

	return Roact.createElement(FitChildren.FitFrame, {
		Size = UDim2.new(1, 0, 0, 0),
		fitAxis = FitChildren.FitAxis.Height,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 0),
		}),

		GridView = Roact.createElement(GridView, {
			renderItem = self.props.renderItem,
			windowHeight = windowHeight,
			getItemHeight = getItemHeight,
			getItemMetrics = getItemMetrics,
			itemPadding = Vector2.new(CELL_PADDING, CELL_PADDING),
			items = items,
			maxHeight = math.huge,
			LayoutOrder = layoutOrder,
		}),
	})
end

return LoadableGridView