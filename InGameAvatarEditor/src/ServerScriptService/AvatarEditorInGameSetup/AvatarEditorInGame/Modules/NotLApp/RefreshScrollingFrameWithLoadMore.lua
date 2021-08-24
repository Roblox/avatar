local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Cryo = require(Modules.Packages.Cryo)
local Roact = require(Modules.Packages.Roact)

local Signal = require(Modules.Common.Signal)

local EndOfScroll = require(Modules.NotLApp.EndOfScroll)
local LoadingBarWithTheme = require(Modules.NotLApp.LoadingBarWithTheme)
local RefreshScrollingFrameNew = require(Modules.NotLApp.RefreshScrollingFrameNew)


local GetFFlagLuaAppFixGameListDupLoadMoreRequests = function() return true end
local GetFFlagLuaAppFillScrollingFrameWithLoadMore = function() return true end
local UseNewRefreshScrollingFrame = true

-- We would like to start loading more before user reaches the bottom.
-- The default distance from the bottom of that would be 2000.
local DEFAULT_PRELOAD_DISTANCE = 2000

local LOADING_BAR_PADDING = 20
local LOADING_BAR_HEIGHT = 16
local LOADING_BAR_TOTAL_HEIGHT = LOADING_BAR_PADDING * 2 + LOADING_BAR_HEIGHT

local RefreshScrollingFrameWithLoadMore = Roact.PureComponent:extend("RefreshScrollingFrameWithLoadMore")

RefreshScrollingFrameWithLoadMore.defaultProps = {
	preloadDistance = DEFAULT_PRELOAD_DISTANCE,
}

function RefreshScrollingFrameWithLoadMore:init()
	self._isMounted = false

	self.scrollToTopSignal = Signal.new()

	self.scrollToTop = function()
		self.scrollToTopSignal:fire()
	end

	self.state = {
		isLoadingMore = false,
		isScrollable = false,
	}

	self.lastLoadMoreThreshold = 0

	self.loadMore = function()
		local onLoadMore = self.props.onLoadMore

		self:setState({
			isLoadingMore = true
		})

		onLoadMore():andThen(
		function()
			if self._isMounted then
				self:setState({
					isLoadingMore = false
				})
			end
		end,
		function()
			-- Allow us to retry.
			if self._isMounted then
				self:setState({
					isLoadingMore = false
				})
			end
			if GetFFlagLuaAppFixGameListDupLoadMoreRequests() then
				-- Reset the lastLoadMoreThreshold if request fails
				-- Allow it to retry
				self.lastLoadMoreThreshold = 0
			end
		end
		)
	end

	self.onCanvasPositionChanged = function(rbx)
		local preloadDistance = self.props.preloadDistance
		local onLoadMore = self.props.onLoadMore
		local isLoadingMore = self.state.isLoadingMore
		local newPosition = rbx.CanvasPosition.Y

		local shouldLoadMore

		if UseNewRefreshScrollingFrame then
			local hasMoreRows = self.props.hasMoreRows
			shouldLoadMore = hasMoreRows and not isLoadingMore
		else
			shouldLoadMore = onLoadMore and not isLoadingMore
		end

		-- Check if we want to load more things
		if shouldLoadMore then
			if rbx.CanvasSize.Y.Scale ~= 0 then
				warn([[RefreshScrollingFrame: Scrollingframe.CanvasSize.Y.Scale is not 0!
				Content loading would not work properly.]])
				return
			end

			local loadMoreThreshold = rbx.CanvasSize.Y.Offset - rbx.AbsoluteWindowSize.Y - preloadDistance

			-- dispatch LoadMore
			if GetFFlagLuaAppFixGameListDupLoadMoreRequests() then
				-- If scrolling down fast, first loadMore request may be resolved before CanvasSize changes to large,
				-- which means newPosition > loadMoreThreshold is still met.
				-- We have to prevent second request being sent here
				local checkThreshold =
					newPosition > loadMoreThreshold and
					loadMoreThreshold ~= self.lastLoadMoreThreshold and
					loadMoreThreshold ~= self.lastLoadMoreThreshold + LOADING_BAR_TOTAL_HEIGHT

				if checkThreshold then
					self.lastLoadMoreThreshold = loadMoreThreshold
					self.loadMore()
				end
			else
				if newPosition > loadMoreThreshold then
					self.loadMore()
				end
			end
		end

		if self.props.onCanvasPositionChangedCallback then
			self.props.onCanvasPositionChangedCallback(newPosition)
		end

	end

	self.onCanvasSizeChanged = function(rbx)
		local canvasHeight = rbx.CanvasSize.Y.Offset
		local windowHeight = rbx.AbsoluteWindowSize.Y

		local isScrollable = self._isMounted and canvasHeight > windowHeight

		if isScrollable ~= self.state.isScrollable then
			if GetFFlagLuaAppFillScrollingFrameWithLoadMore() then
				if self._isMounted then
					self:setState({
						isScrollable = isScrollable,
					})
				end
			else
				spawn(function()
					if self._isMounted then
						self:setState({
							isScrollable = isScrollable,
						})
					end
				end)
			end
		end

		if GetFFlagLuaAppFillScrollingFrameWithLoadMore() then
			local shouldLoadMore

			if UseNewRefreshScrollingFrame then
				shouldLoadMore = self.props.hasMoreRows and not self.state.isLoadingMore and not isScrollable
			else
				shouldLoadMore = self.props.onLoadMore and not self.state.isLoadingMore and not isScrollable
			end

			if shouldLoadMore and not self.props.initalizing then
				self.loadMore()
			end
		end
	end
end

function RefreshScrollingFrameWithLoadMore:didMount()
	self._isMounted = true
end

function RefreshScrollingFrameWithLoadMore:willUnmount()
	self._isMounted = false
end

function RefreshScrollingFrameWithLoadMore:render()
	-- RefreshScrollingFrameNew is a PureComponent, so the createFooter function has to actually change
	-- for it to re-render.
	local hasMoreRows = self.props.hasMoreRows
	local isLoadingMore = self.state.isLoadingMore
	local isScrollable = self.state.isScrollable

	local createFooter = nil

	if isLoadingMore then
		createFooter = function()
			return Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, LOADING_BAR_TOTAL_HEIGHT),
			}, {
				LoadingBar = Roact.createElement(LoadingBarWithTheme),
			})
		end
	elseif (not hasMoreRows and isScrollable) then
		createFooter = function()
			return Roact.createElement(EndOfScroll, {
				backToTopCallback = self.scrollToTop,
			})
		end
	end

	local newProps = Cryo.Dictionary.join(self.props, {
		onCanvasPositionChangedCallback = self.onCanvasPositionChanged,
		onCanvasSizeChangedCallback = self.onCanvasSizeChanged,
		createFooter = createFooter,
		scrollToTopSignal = self.scrollToTopSignal,
		onLoadMore = Cryo.None,
		hasMoreRows = Cryo.None,
	})

	return Roact.createElement(RefreshScrollingFrameNew, newProps)
end

return RefreshScrollingFrameWithLoadMore