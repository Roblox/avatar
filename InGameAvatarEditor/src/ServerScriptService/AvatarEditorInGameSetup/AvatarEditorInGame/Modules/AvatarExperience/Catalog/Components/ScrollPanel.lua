local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules


local Roact = require(Modules.Packages.Roact)
local t = require(Modules.Packages.t)
local RefreshScrollingFrameWithLoadMore = require(Modules.NotLApp.RefreshScrollingFrameWithLoadMore)

local ScrollPanel = Roact.PureComponent:extend("ScrollPanel")

ScrollPanel.validateProps = t.strictInterface({
	showCategories = t.optional(t.boolean),
	isLoading = t.optional(t.boolean),
	panelHeight = t.number,
	topPanel = t.table,
	-- These are passed to the underlying RefreshScrollingFrameWithLoadMore component
	onLoadMore = t.optional(t.callback),
	hasMoreRows = t.optional(t.boolean),
	canvasMovedListener = t.optional(t.table),
	parentAppPage = t.optional(t.string),
	scrollingFrameRef = t.optional(t.table),
	createEndOfScrollElement = t.optional(t.boolean),
	[Roact.Children] = t.optional(t.table),
})

function ScrollPanel:init()
	self.state = {
		panelPosition = self.props.panelHeight,
		lastYPosition = 0
	}
end

function ScrollPanel:onItemsListScroll(yPosition)
	local panelPosition = self.state.panelPosition
	local deltaY = yPosition - self.state.lastYPosition

	if deltaY > 0 then -- scrolling up
		if yPosition < 1 then
			panelPosition = self.props.panelHeight
		else
			panelPosition = math.max(panelPosition - deltaY, 0)
		end
	else -- scrolling down
		panelPosition = math.min(panelPosition - deltaY, self.props.panelHeight)
	end

	self:setState({
		panelPosition = panelPosition,
		lastYPosition = yPosition
	})
end

function ScrollPanel:render()
	local children = {
		CanvasMovedListener = self.props.canvasMovedListener,
		Children = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, self.props.panelHeight),
		}, self.props[Roact.Children])
	}

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ClipsDescendants = true,
	}, {
		TopPanel = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, self.props.panelHeight),
			Position = UDim2.new(0, 0, 0, self.state.panelPosition),
			Size = UDim2.new(1, 0, 0, self.props.panelHeight),
			ZIndex = 2,
		}, self.props.topPanel),
		ScrollPanel = Roact.createElement(RefreshScrollingFrameWithLoadMore, {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			CanvasSize = UDim2.new(1, 0, 1, 0),
			onLoadMore = self.props.onLoadMore,
			overrideBackgroundTransparency = 1,
			onCanvasPositionChangedCallback = function(yPosition) self:onItemsListScroll(yPosition) end,
			hasMoreRows = self.props.hasMoreRows,
			createEndOfScrollElement = self.props.createEndOfScrollElement,
			LayoutOrder = 2,
			parentAppPage = self.props.parentAppPage,
			[Roact.Ref] = self.props.scrollingFrameRef,
		}, children)
	})
end

return ScrollPanel