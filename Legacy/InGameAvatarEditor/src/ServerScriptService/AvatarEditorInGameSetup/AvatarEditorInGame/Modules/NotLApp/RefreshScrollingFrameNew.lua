--[[
	A scrolling frame which auto fits the child elements, and:
	1. Refreshes after user pulled down the scrolling frame and release their finger;
	2. Scrolls to top when receiving a statusBarTapped signal. (sent from iOS)
	3. Scrolls to top/refreshes when receiving LuaAppEvents.ReloadPage signal. (sent from
		Lua Bottom Bar when user clicks on a button)
	4. Displays a spinner at the top of the scrolling frame when refreshing.

	props:
	parentAppPage -- identify which app page we're created on.
	refresh -- refresh function for this page, needs to be a promise. Can be nil.
	createFooter -- callback for rendering a footer at the end of the content
	getScrollToTopCallback -- callback for exposing the scrollToTop function to the parent
	Size
	BackgroundColor3
	Position
	onCanvasPositionChangedCallback
	onCanvasSizeChangedCallback
	_____________________
	|      Spinner      |
	|___________________|
	|                   |
	|                   |
	|                   |
	| ScrollingContent  |
	|___________________|
]]

local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local UserInputService = game:GetService("UserInputService")

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)
local Otter = require(Modules.Packages.Otter)

local withStyle = UIBlox.Style.withStyle

local FitChildren = require(Modules.NotLApp.FitChildren)
local LuaAppEvents = require(Modules.NotLApp.LuaAppEvents)

local Spinner = require(Modules.NotLApp.Spinner)
local ExternalEventConnection = require(Modules.Common.RoactUtilities.ExternalEventConnection)

local UseTempHacks = require(Modules.Config.UseTempHacks)

local SPINNER_ICON_SIZE = 20

local SPINNER_ROTATION = {
	Start = -240,
	End = 0,
}

local SPINNER_TRANSPARENCY = {
	Start = 1,
	End = 0,
}

local SPRING_OPTIONS = {
	dampingRatio = 1,
	frequency = 3.5,
}

local DOUBLE_CLICK_TIMEFRAME = 0.5 -- 500 ms

local function lerp(a, b, t)
	-- t need to be in range 0 - 1
	t = math.min(1, math.max(0, t))

	return a * (1 - t) + b * t
end

local RefreshScrollingFrameNew = Roact.PureComponent:extend("RefreshScrollingFrameNew")

RefreshScrollingFrameNew.defaultProps = {
	refreshThreshold = 25,
}

function RefreshScrollingFrameNew:init()
	self.state = {
		isRefreshing = false,
	}

	self.isUserInteracting = false

	local propsRef = self.props[Roact.Ref]
	assert(
		type(propsRef) ~= "function",
		("%s does not support function ref forwarding"):format(tostring(RefreshScrollingFrameNew))
	)

	self.scrollingFrameRef = propsRef or Roact.createRef()
	self.spinnerFrameRef = Roact.createRef()
	self.spinnerRef = Roact.createRef()

	self.updateSpinner = function(newSpinnerFrameHeight)
		if self.spinnerFrameRef.current then
			self.spinnerFrameRef.current.Size = UDim2.new(1, 0, 0, newSpinnerFrameHeight)
			local refreshThreshold = self.props.refreshThreshold

			-- As the spinner is pulled down, it slightly rotates, and also changes transparency
			local lerpValue = newSpinnerFrameHeight / refreshThreshold
			self.spinnerRef.current.ImageTransparency =
				lerp(SPINNER_TRANSPARENCY.Start, SPINNER_TRANSPARENCY.End, lerpValue)

			local isSpinning = self.state.isRefreshing
			if not isSpinning then
				self.spinnerRef.current.Rotation = lerp(SPINNER_ROTATION.Start, SPINNER_ROTATION.End, lerpValue)
			end
		end
	end

	self.motor = Otter.createSingleMotor(0)
	self.motor:onStep(self.updateSpinner)

	self.resetSpinner = function()
		self.motor:setGoal(Otter.spring(0, SPRING_OPTIONS))
	end

	self.dispatchRefresh = function()
		local refresh = self.props.refresh
		local refreshThreshold = self.props.refreshThreshold
		local isRefreshing = self.state.isRefreshing

		if refresh == nil then
			return
		end

		if not isRefreshing then
			self:setState({
				isRefreshing = true,
			})

			self.motor:setGoal(Otter.spring(refreshThreshold, SPRING_OPTIONS))

			local function onRefreshComplete()
				if self.isMounted then
					self:setState({
						isRefreshing = false,
					})
					self.resetSpinner()
				end
			end

			refresh():andThen(onRefreshComplete, onRefreshComplete)
		end
	end


	self.onInputBegan = function(input)
		self.isUserInteracting = true
	end

	self.onInputEnded = function(input)
		self.isUserInteracting = false

		-- After the user has pulled down the scrolling frame far enough, and released
		-- their finger, we do a refresh
		if self.props.refresh ~= nil and self.scrollingFrameRef.current then
			local pulldownDistance = -self.scrollingFrameRef.current.CanvasPosition.Y
			local refreshThreshold = self.props.refreshThreshold

			if pulldownDistance > refreshThreshold then
				self.dispatchRefresh()
			elseif pulldownDistance > 0 then
				self.resetSpinner()
			end
		end
	end

	self.onCanvasPositionChanged = function(rbx)
		if self.props.onCanvasPositionChangedCallback ~= nil then
			self.props.onCanvasPositionChangedCallback(rbx)
		end

		if self.props.refresh ~= nil and self.isUserInteracting and not self.state.isRefreshing then
			local pulldownDistance = -rbx.CanvasPosition.Y
			local refreshThreshold = self.props.refreshThreshold

			if pulldownDistance >= 0 and pulldownDistance <= refreshThreshold then
				self.motor:setGoal(Otter.instant(pulldownDistance))
			end
		end
	end

	self.onCanvasSizeChanged = function(rbx)
		if self.props.onCanvasSizeChangedCallback ~= nil then
			self.props.onCanvasSizeChangedCallback(rbx)
		end
	end

	self.scrollToTop = function()
		if UseTempHacks then
			if self.scrollingFrameRef.current then
				self.scrollingFrameRef.current.CanvasPosition = Vector2.new(0, 0)
			end
		else
			if self.scrollingFrameRef.current then
				self.scrollingFrameRef.current:ScrollToTop()
			end
		end
	end

	-- If the user taps the status bar, we would like to scroll back to top.
	self.statusBarTapCallback = function()
		self.scrollToTop()
	end

	-- If the user does a quick double tap, we would like to do both a
	-- scrollToTop and a refresh
	self._lastReloadEventTime = tick()

	self.onReloadPage = function()
		if not self.scrollingFrameRef.current then
			return
		end

		local canvasPosition = self.scrollingFrameRef.current.CanvasPosition.Y
		local currentTime = tick()

		local shouldRefresh = self.props.refresh ~= nil

		if canvasPosition ~= 0 then
			self.scrollToTop()

			if currentTime - self._lastReloadEventTime < DOUBLE_CLICK_TIMEFRAME and shouldRefresh then
				self.dispatchRefresh()
			end
		elseif shouldRefresh then
			self.dispatchRefresh()
		end

		self._lastReloadEventTime = currentTime
	end

	-- BottomBar button pressed for Lua bottom bar:
	self.luaAppReloadPageEventConnection = LuaAppEvents.ReloadPage:connect(function(pageName)
		local parentAppPage = self.props.parentAppPage
		local currentRoute = self.props.currentRoute

		if pageName == parentAppPage and #currentRoute == 1 then
			self.onReloadPage()
		end
	end)

	self.scrollToTopSignalConnection = nil

	self.connectToScrollToTopSignal = function()
		if self.scrollToTopSignalConnection ~= nil then
			self.scrollToTopSignalConnection:disconnect()
			self.scrollToTopSignalConnection = nil
		end

		self.scrollToTopSignalConnection = self.props.scrollToTopSignal:connect(function()
			self.scrollToTop()
		end)
	end
end

function RefreshScrollingFrameNew:didMount()
	self.isMounted = true

	self.resetSpinner()

	if self.props.scrollToTopSignal ~= nil then
		self.connectToScrollToTopSignal()
	end
end

function RefreshScrollingFrameNew:didUpdate(prevProps)
	if prevProps.scrollToTopSignal ~= self.props.scrollToTopSignal and
		self.props.scrollToTopSignal ~= nil then
		self.connectToScrollToTopSignal()
	end
end

function RefreshScrollingFrameNew:willUnmount()
	self.isMounted = false

	self.motor:destroy()
	self.motor = nil

	if self.luaAppReloadPageEventConnection ~= nil then
		self.luaAppReloadPageEventConnection:disconnect()
		self.luaAppReloadPageEventConnection = nil
	end

	if self.scrollToTopSignalConnection ~= nil then
		self.scrollToTopSignalConnection:disconnect()
		self.scrollToTopSignalConnection = nil
	end
end

function RefreshScrollingFrameNew:render()
	local backgroundTransparency = self.props.BackgroundTransparency
	local backgroundColor3 = self.props.BackgroundColor3
	local size = self.props.Size
	local position = self.props.Position
	local children = self.props[Roact.Children]
	local createFooter = self.props.createFooter
	local isRefreshing = self.state.isRefreshing

	return withStyle(function(style)
		return Roact.createElement(FitChildren.FitScrollingFrame, {
			Size = size,
			Position = position,
			ScrollBarThickness = 0,
			BackgroundColor3 = backgroundColor3 or style.Theme.BackgroundDefault.Color,
			BackgroundTransparency = backgroundTransparency or style.Theme.BackgroundDefault.Transparency,
			BorderSizePixel = 0,
			ElasticBehavior = Enum.ElasticBehavior.Always,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			fitFields = {
				CanvasSize = FitChildren.FitAxis.Height,
			},
			[Roact.Change.CanvasPosition] = self.onCanvasPositionChanged,
			[Roact.Change.CanvasSize] = self.onCanvasSizeChanged,
			[Roact.Ref] = self.scrollingFrameRef,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			SpinnerFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				LayoutOrder = 1,
				BackgroundTransparency = 1,
				ClipsDescendants = false,
				[Roact.Ref] = self.spinnerFrameRef,
			}, {
				Spinner = Roact.createElement(Spinner, {
					Size = UDim2.new(0, SPINNER_ICON_SIZE, 0, SPINNER_ICON_SIZE),
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 1, 0),
					isSpinning = isRefreshing,
					[Roact.Ref] = self.spinnerRef,
				}),
			}),
			Content = Roact.createElement(FitChildren.FitFrame, {
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 1, 0),
				fitFields = {
					Size = FitChildren.FitAxis.Height,
				},
			}, children),
			Footer = createFooter and Roact.createElement(FitChildren.FitFrame, {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				fitFields = {
					Size = FitChildren.FitAxis.Height,
				},
				LayoutOrder = 3,
			}, {
				FooterContent = createFooter(),
			}),
			inputBegan = Roact.createElement(ExternalEventConnection, {
				event = UserInputService.InputBegan,
				callback = self.onInputBegan,
			}),
			inputEnded = Roact.createElement(ExternalEventConnection, {
				event = UserInputService.InputEnded,
				callback = self.onInputEnded,
			}),
			--[[
			statusBarTapped = Roact.createElement(ExternalEventConnection, {
				event = UserInputService.StatusBarTapped,
				callback = self.statusBarTapCallback,
			}),
			--]]
		})
	end)
end

RefreshScrollingFrameNew = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			currentRoute = state.Navigation.history[#state.Navigation.history]
		}
	end
)(RefreshScrollingFrameNew)

return RefreshScrollingFrameNew