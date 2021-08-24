local RunService = game:GetService("RunService")

local Root = script:FindFirstAncestor("infinite-scroller").Parent
local Roact = require(Root.Roact)
local Cryo = require(Root.Cryo)
local t = require(Root.t)
local Otter = require(Root.Otter)

local FitFrame = require(Root.FitFrame).FitFrameOnAxis
local findNewIndices = require(script.Parent.findNewIndices)
local Round = require(script.Parent.Round)
local KeyPool = require(script.Parent.KeyPool)

local NotifyReady = require(script.Parent.NotifyReady)

local debugPrint = function() end

local Scroller = Roact.PureComponent:extend("Scroller")

Scroller.Orientation = require(script.Parent.Orientation)

local MOTOR_OPTIONS = {
	frequency = 4,
	dampingRatio = 1,
}

local isVertical = {
	[Scroller.Orientation.Up] = true,
	[Scroller.Orientation.Down] = true,
	[Scroller.Orientation.Left] = false,
	[Scroller.Orientation.Right] = false,
}

local isReverse = {
	[Scroller.Orientation.Up] = true,
	[Scroller.Orientation.Down] = false,
	[Scroller.Orientation.Left] = true,
	[Scroller.Orientation.Right] = false,
}

local direction = {
	[Scroller.Orientation.Up] = -1,
	[Scroller.Orientation.Down] = 1,
	[Scroller.Orientation.Left] = -1,
	[Scroller.Orientation.Right] = 1,
}

Scroller.validateProps = t.interface({
	-- Required. The list of items to scroll through.
	itemList = t.array(t.any),

	-- Required. A callback function, called with each visible item in the itemList when the list is rendered.
	renderItem = t.callback,

	-- A function to uniquely identify list items. Calling this on the same item twice should give the same result
	-- accoring to ==.
	identifier = t.optional(t.callback),

	-- One of the Scroller.Orientation enums. Determines the leading edge of the infinite scroll.
	orientation = t.optional(Scroller.Orientation.isOrientation),

	-- A callback function, called when the infinite scroll reaches the leading end of the itemList (index
	-- #itemList).
	loadNext = t.optional(t.callback),

	-- A callback function, called when the infinite scroll reaches the trailing end of the itemList (index 1).
	loadPrevious =  t.optional(t.callback),

	-- Padding between elements in the scrolling frame. The Scale is relative to the size of the scrolling frame.
	padding = t.optional(t.UDim),

	-- The minimum number of unmounted elements to keep at the top and bottom of the list. If there are fewer than
	-- this call loadNext or loadPrevious.
	loadingBuffer = t.optional(t.numberPositive),

	-- The amount of space above and below the view to render items in.
	mountingBuffer = t.optional(t.numberPositive),

	-- The amount of empty space to keep at the top and bottom on the scroll.
	dragBuffer = t.optional(t.numberMin(0)),

	-- An initial guess at the average size of an item.
	estimatedItemSize = t.optional(t.numberPositive),

	-- The maximum distance to search for moved elements.
	maximumSearchDistance = t.optional(t.numberPositive),

	-- The element to put in focus initially.
	focusIndex = t.optional(t.integer),

	-- An arbitrary value to prevent the list from refocusing every render. Change this to cause the list to reset
	-- and refocus on the new focusIndex.
	focusLock = t.optional(t.any),

	-- The position within the view to keep still as other things move. The Scale is relative to the size of the
	-- scrolling frame.
	anchorLocation = t.optional(t.UDim),

	-- Animate the scrolling
	animateScrolling = t.optional(t.boolean),

	--Animation options
	animateOptions = t.optional(t.table),

	-- Properties that should trigger rerenders of the children elements even though the scroller itself does not
	-- use them.
	extraProps = t.optional(t.table),

	-- A callback function that will update the index change
	onScrollUpdate = t.optional(t.callback),

	-- Which components to disable instance recycling for.
	recyclingDisabledFor = t.optional(t.array(t.string)),

	---- INTERNAL ONLY ----
	[NotifyReady] = t.any,
})

-- Default values for all the infinite-scroller-specific props. Any prop not in this list will be passed on to the
-- underlying ScrollingFrame.
Scroller.defaultProps = {
	itemList = {},
	renderItem = {},
	identifier = function(item)
		return item
	end,
	orientation = Scroller.Orientation.Down,
	loadNext = function() end,
	loadPrevious = function() end,
	padding = UDim.new(0, 0),
	loadingBuffer = 10,
	mountingBuffer = 200,
	dragBuffer = 0,
	estimatedItemSize = 50,
	maximumSearchDistance = 100,
	focusIndex = 1,
	focusLock = {},
	anchorLocation = UDim.new(0, 0),
	animateScrolling = false,
	animateOptions = MOTOR_OPTIONS,
	extraProps = {},
	onScrollUpdate = function() end,
	recyclingDisabledFor = {},
	[NotifyReady] = false,
}

function Scroller:render()
	debugPrint("render")

	-- Gather vertical/horizontal specific variables.
	local axis = isVertical[self.props.orientation] and {
		fillDirection = Enum.FillDirection.Vertical,
		fitDirection = FitFrame.Axis.Vertical,
		minimumSize = UDim2.new(1, 0, 0, 0),
		canvasSize = UDim2.new(0, 0, 0, self.state.size),
		paddingSize = UDim2.new(0, 0, 0, self.state.padding),
	} or {
		fillDirection = Enum.FillDirection.Horizontal,
		fitDirection = FitFrame.Axis.Horizontal,
		minimumSize = UDim2.new(0, 0, 1, 0),
		canvasSize = UDim2.new(0, self.state.size, 0, 0),
		paddingSize = UDim2.new(0, self.state.padding, 0, 0),
	}

	-- Remove non-standard props from list to pass on to ScrollingFrame. These are the same props given in
	-- defaultProps.
	local props = Cryo.Dictionary.join(
		self.props,
		self.propsToClear,
		{
			CanvasSize = axis.canvasSize,
			[Roact.Change.CanvasPosition] = self.onScroll,
			[Roact.Change.AbsoluteSize] = self.onResize,
			[Roact.Ref] = self:getRef(),
		}
	)

	local children = {
		layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = axis.fillDirection,
			Padding = UDim.new(0, self.itemPadding),
			[Roact.Change.AbsoluteContentSize] = self.onContentResize,
		}),
		padding = Roact.createElement("Frame", {
			Size = axis.paddingSize,
			LayoutOrder = -1 - (self.state.listSize or 0),
		}),
	}

	-- Trailing and leading indicies won't be set if this isn't true.
	if self.state.ready and not Cryo.isEmpty(self.props.itemList) then
		debugPrint("  Rendering elements between", self.state.trail.index, "and", self.state.lead.index)
		for n = self.state.trail.index, self.state.lead.index do
			local metadata = self:getMetadata(n)
			children[metadata.name] = Roact.createElement(FitFrame, {
				minimumSize = axis.minimumSize,
				axis = axis.fitDirection,
				FillDirection = axis.fillDirection,
				BackgroundTransparency = 1,
				LayoutOrder = isReverse[self.props.orientation] and -n or n,
				[Roact.Ref] = metadata.ref,
			}, {
				item = self.props.renderItem(self.props.itemList[n], false),
			})
		end
	end

	return Roact.createElement("ScrollingFrame", props, children)
end

function Scroller:shouldUpdate(nextProps, nextState)
	debugPrint("shouldUpdate")

	-- Check for state and props changes in the same way PureComponent would,
	-- but go one more level down for extraProps.
	if nextState ~= self.state then
		debugPrint("  State changed")
		return true
	end

	for key, value in pairs(nextProps) do
		if self.props[key] ~= value then
			if key ~= "extraProps" then
				debugPrint("  Prop changed:", key)
				return true
			end

			for extraKey, extraValue in pairs(value) do
				if self.props.extraProps[extraKey] ~= extraValue then
					debugPrint("  Extra prop changed:", extraKey)
					return true
				end
			end
		end
	end

	for key, value in pairs(self.props) do
		if nextProps[key] ~= value then
			if key ~= "extraProps" then
				debugPrint("  Prop changed:", key)
				return true
			end

			for extraKey, extraValue in pairs(value) do
				if nextProps.extraProps[extraKey] ~= extraValue then
					debugPrint("  Extra prop changed:", extraKey)
					return true
				end
			end
		end
	end

	return false
end

function Scroller:willUpdate(nextProps, nextState)
	debugPrint("willUpdate")

	if not nextState.ready then
		return
	end

	self.sizeDebounce = true

	local deletions = {}
	local additions = {}

	if not Cryo.isEmpty(self.props.itemList) and self.state.lead then
		for n = self.state.trail.index, self.state.lead.index do
			local id = self.props.identifier(self.props.itemList[n])
			deletions[id] = true
		end
	end

	if not Cryo.isEmpty(nextProps.itemList) and nextState.lead then
		for n = nextState.trail.index, nextState.lead.index do
			local item = nextProps.itemList[n]
			local id = nextProps.identifier(item)
			if deletions[id] then
				-- Element is in both ranges.
				deletions[id] = nil
			else
				additions[id] = item
			end
		end
	end

	-- Clear names first, so new items can use them.
	for id, _ in pairs(deletions) do
		self:clearMetadata(id)
	end
	for id, item in pairs(additions) do
		self:updateMetadata(id, item, nextProps)
	end

	-- The focus lock changed, clear the non-state anchor variables.
	if self.state.lastFocusLock ~= nextState.lastFocusLock then
		self.motorActive = false
		self.anchorFramePosition = 0
		self.anchorCanvasPosition = self:absoluteToCanvasPosition(self.relativeAnchorLocation)
	end
end

function Scroller:didUpdate(previousProps, previousState)
	debugPrint("didUpdate")

	if Cryo.isEmpty(self.props.itemList) then
		return
	end

	if not self.state.ready then
		self.onResize(self:getRef().current)
		return
	end

	if self.props.focusIndex ~= previousProps.focusIndex and
		self.props.focusLock ~= previousProps.focusLock then

			self.indexChanged = {
				oldIndex = previousProps.focusIndex,
				newIndex = self.props.focusIndex,
				lastFocusLock = self.props.focusLock,
			}
			self.motorActive = false

			debugPrint("self.props.focusIndex", self.props.focusIndex)
			debugPrint("self.state.anchor.index", self.state.anchor.index)
			debugPrint("previousState.anchor.index", previousState.anchor.index)
	end

	local adjustedCanvas = self:adjustCanvas(self.scrollingForward, self.scrollingBackward)
	if not adjustedCanvas then
		if self.indexChanged and self.props.animateScrolling then
			self:scrollToAnchor()
		else
			self:moveToAnchor()
		end

		if self.anchorOffset ~= 0 then
			self:setState({})
			return
		end

		self:loadMore()
		self.sizeDebounce = false

		--Return the updated index
		if self.props.onScrollUpdate then
			self.props.onScrollUpdate({
				leadIndex = self.state.lead.index,
				anchorIndex = self.state.anchor.index,
				trailIndex = self.state.trail.index,
				animationActive = self.motorActive,
			})
		end
	end
end

function Scroller.getDerivedStateFromProps(nextProps, lastState)
	debugPrint("getDerivedStateFromProps")
	if not lastState.ready or Cryo.isEmpty(nextProps.itemList) then
		return nil
	end

	local listSize = #nextProps.itemList

	-- Reset the state if the focus lock changes. This is guaranteed to be true the first time.
	if lastState.lastFocusLock ~= nextProps.focusLock then
		debugPrint("  Resetting focus lock", lastState.lastFocusLock," to ", nextProps.focusLock)
		if nextProps.animateScrolling and lastState.lastFocusLock ~= nil then
			return {
				lastFocusLock = nextProps.focusLock,
			}
		end
		local focusID = nextProps.identifier(nextProps.itemList[nextProps.focusIndex])
		return {
			listSize = listSize,
			trail = {index=nextProps.focusIndex, id=focusID},
			anchor = {index=nextProps.focusIndex, id=focusID},
			lead = {index=nextProps.focusIndex, id=focusID},
			padding = 0,
			size = 0,
			lastFocusLock = nextProps.focusLock,
		}
	end

	local trailIndex, anchorIndex, leadIndex = findNewIndices(nextProps, lastState)
	debugPrint("  Trailing index moved from", lastState.trail.index, "to", trailIndex)
	debugPrint("  Anchor index moved from", lastState.anchor.index, "to", anchorIndex)
	debugPrint("  Leading index moved from", lastState.lead.index, "to", leadIndex)

	-- Nothing changed. Return early to avoid triggering an update.
	if anchorIndex and lastState.anchor.index == anchorIndex
		and trailIndex and lastState.trail.index == trailIndex
		and leadIndex and lastState.lead.index == leadIndex then
			debugPrint("  No change, returning early")
			if listSize == lastState.listSize then
				return nil
			else
				return {
					listSize = listSize,
				}
			end
	end

	-- There are 8 possibilities here as any combination of these could be deleted. Also, we can't use findIndexAt
	-- here since that requires access to the children's measurements.
	if not anchorIndex then
		if leadIndex and trailIndex then
			-- Estimate that the new anchor is proportionally the same distance from the lead and trail indices.
			if leadIndex == trailIndex then
				-- Guard against divide by zero.
				anchorIndex = leadIndex
			else
				local oldRatio = (lastState.anchor.index - lastState.lead.index)
					/ (lastState.trail.index - lastState.lead.index)
				anchorIndex = Round.nearest((trailIndex - leadIndex) * oldRatio + leadIndex)
				anchorIndex = math.min(math.max(anchorIndex, 1), listSize)
			end
		elseif leadIndex then
			-- Given only the new leading index, estimate that the new anchor is the same distance away as it was.
			anchorIndex = leadIndex + lastState.anchor.index - lastState.lead.index
			anchorIndex = math.min(math.max(anchorIndex, 1), listSize)
		elseif trailIndex then
			-- Given only the new trailing index, estimate that the new anchor is the same distance away as it was.
			anchorIndex = trailIndex + lastState.anchor.index - lastState.trail.index
			anchorIndex = math.min(math.max(anchorIndex, 1), listSize)
		else
			-- Everything is gone. Just reuse the same index if that's still within the bounds of the list.
			anchorIndex = math.min(math.max(lastState.anchor.index, 1), listSize)
		end
		debugPrint("  Anchor index moved to", anchorIndex)
	end

	-- If the leading and trailing indices haven't been worked out yet, estimate that the new ones should be the
	-- same distance from the anchor as the old ones were.
	if not trailIndex then
		trailIndex = anchorIndex + lastState.trail.index - lastState.anchor.index
		trailIndex = math.min(math.max(trailIndex, 1), listSize)
		debugPrint("  Trailing index moved to", trailIndex)
	end
	if not leadIndex then
		leadIndex = anchorIndex + lastState.lead.index - lastState.anchor.index
		leadIndex = math.min(math.max(leadIndex, 1), listSize)
		debugPrint("  Leading index moved to", leadIndex)
	end

	local trailID = nextProps.identifier(nextProps.itemList[trailIndex])
	local anchorID = nextProps.identifier(nextProps.itemList[anchorIndex])
	local leadID = nextProps.identifier(nextProps.itemList[leadIndex])

	return {
		listSize = listSize,
		trail = {index=trailIndex, id=trailID},
		anchor = {index=anchorIndex, id=anchorID},
		lead = {index=leadIndex, id=leadID},
	}
end

function Scroller:init()
	debugPrint("init")

	-- Only self:getRef() should access this.
	self._ref = Roact.createRef()

	self.motorPrevValue = 0

	self.motorOnStep = function(value)
		debugPrint("onStep", value)
		if not self.motorActive or self.indexChanged == nil then
			self.motor:stop()
			return
		end
		local currentValue = self.indexChanged.currentPos
		if currentValue == nil then
			self.motor:stop()
			return
		end
		local diff = value - self.motorPrevValue
		if self:getCurrent() then
			self:scrollRelative(diff)
			self.motorPrevValue = value
		end
	end
	self.motorOnComplete = function()
		debugPrint("otter onComplete")
		self.motorActive = false
		--Return the updated index
		if self.props.onScrollUpdate then
			self.props.onScrollUpdate({
				leadIndex = self.props.focusIndex,
				anchorIndex = self.props.focusIndex,
				trailIndex = self.props.focusIndex,
				animationActive = self.motorActive,
			})
		end
		self.motorPrevValue = 0
		self.indexChanged = nil
		if self.motor then
			self.motor:destroy()
		end
	end

	self.motorActive = false
	self.springLock = 0
	self.scrollDebounce = false
	self.sizeDebounce = true

	--Used to track index changes
	self.indexChanged = nil

	self.onScroll = function(rbx)
		debugPrint("onScroll")
		debugPrint("  CanvasPosition is", rbx.CanvasPosition)
		if self.scrollDebounce then
			debugPrint("  Debouncing scroll")
			return
		end

		local delta, newState = self:recalculateAnchor()
		self.scrollingBackward = delta < 0
		self.scrollingForward = delta > 0
		debugPrint("  Delta is", delta)

		if not Cryo.isEmpty(newState) then
			self:setState(newState)
		end

		-- Handle any passed in scroll callback.
		if self.props[Roact.Change.CanvasPosition] then
			self.props[Roact.Change.CanvasPosition](rbx)
		end
	end

	self.onResize = function(rbx)
		debugPrint("onResize")
		local size = self:measure(rbx.AbsoluteSize)
		local pos = self:measure(rbx.AbsolutePosition)

		self.itemPadding = self.props.padding.Scale * size + self.props.padding.Offset
		if isReverse[self.props.orientation] then
			self.relativeAnchorLocation = Round.nearest(
				self.props.anchorLocation.Scale * size + self.props.anchorLocation.Offset)
		else
			self.relativeAnchorLocation = Round.nearest(
				(1 - self.props.anchorLocation.Scale) * size - self.props.anchorLocation.Offset)
		end
		self.absoluteAnchorLocation = self.relativeAnchorLocation + pos
		self.mountAboveAnchor = self.relativeAnchorLocation + self.props.mountingBuffer
		self.mountBelowAnchor = size - self.relativeAnchorLocation + self.props.mountingBuffer

		-- Handle any passed in resize callback.
		if self.props[Roact.Change.AbsoluteSize] then
			self.props[Roact.Change.AbsoluteSize](rbx)
		end

		if not self.state.ready then
			debugPrint("  Setting initial anchor position to", self.relativeAnchorLocation)
			self.anchorFramePosition = 0
			self.anchorCanvasPosition = self.relativeAnchorLocation

			coroutine.wrap(function()
				RunService.Heartbeat:Wait()
				self:setState({
					ready = true
				})

				-- This should only be set by tests.
				if self.props[NotifyReady] then
					self.props[NotifyReady]:Fire()
				end
			end)()
		else
			self:moveToAnchor()
			self:setState({})  -- Force a rerender.
		end
	end

	self.onContentResize = function()
		debugPrint("onContentResize")

		if self.sizeDebounce or not self.state.ready then
			debugPrint("  Skipping onContentResize")
			return
		end

		self:moveToAnchor()
		self:setState({})  -- Force a rerender.
	end

	self.anchorCanvasPosition = 0
	self.anchorFramePosition = 0
	self.anchorOffset = 0

	self.metadata = {}
	self.pools = {}
	self.refpool = {}

	self.scrollingBackward = false
	self.scrollingForward = false

	-- Store the list of props to not pass on to the underlying scrolling frame.
	self.propsToClear = {}
	for k, _ in pairs(Scroller.defaultProps) do
		self.propsToClear[k] = Cryo.None
	end

	-- This will get updated shortly, but one render will happen before state.ready is set
	self.state = {
		ready = false,
		lastFocusLock = nil,
		padding = 0,
		size = 0,
	}
end

function Scroller:willUnmount()
	if self.motor then
		self.motor:destroy()
	end
end

-- Find which element is currently closest to the anchor position.
function Scroller:recalculateAnchor()
	debugPrint("recalculateAnchor")

	-- Find the index of the element at the appropriate position
	local index = self:findIndexAt(
		self:absoluteToCanvasPosition(self.absoluteAnchorLocation), self.state.anchor.index, false)

	local delta
	if index == self.state.anchor.index then
		debugPrint("  Current anchor still works")
		return 0, {}
	elseif index < self.state.anchor.index then
		delta = -1
	else
		delta = 1
	end

	debugPrint("  New anchor at index", index)

	-- Store the new anchor's details
	self.anchorCanvasPosition = self:getAnchorCanvasFromIndex(index)
	self.anchorFramePosition = self:getAnchorFrameFromIndex(index)
	debugPrint("  New anchor at canvas position", self.anchorCanvasPosition)
	debugPrint("  New anchor at frame position", self.anchorFramePosition)
	return delta, {
		anchor = {index=index, id=self:getID(index)},
	}
end

-- Move all the rendered elements up or down to put the anchor back where it was.
function Scroller:resetAnchorPosition()
	debugPrint("resetAnchorPosition")
	debugPrint("  Anchor index is", self.state.anchor.index)
	local offset = self:getAnchorCanvasPosition()
	debugPrint("  Anchor is at", offset)
	debugPrint("  Anchor offset is", self.anchorOffset)
	local newPos = self.anchorCanvasPosition - self.anchorOffset
	debugPrint("  Anchor should be at", newPos)
	local diff = Round.nearest(newPos - offset)
	if diff ~= 0 then
		debugPrint("  Changing padding from", self.state.padding, "to", (self.state.padding + diff))
		self.anchorCanvasPosition = self.anchorCanvasPosition - self.anchorOffset
		self.anchorOffset = 0
		return {padding = self.state.padding + diff}
	else
		return {}
	end
end

-- Get the current padding from the UIPadding child.
function Scroller:getCurrentPadding()
	local pad = self:getCurrent().padding
	-- Only one of these will be non-zero
	return pad.Size.X.Offset + pad.Size.Y.Offset
end

-- Move the top and bottom of the range to be rendered up and down to make sure
-- enough things are being rendered.
function Scroller:recalculateBounds(trimTrailing, trimLeading)
	debugPrint("recalculateBounds")
	debugPrint("  Leading index was", self.state.lead.index)
	debugPrint("  Trailing index was", self.state.trail.index)

	local anchorPos = self:getAnchorCanvasPosition()
	local mountTop = anchorPos - self.mountAboveAnchor
	local mountBottom = anchorPos + self.mountBelowAnchor
	debugPrint("  Target for top at", mountTop)
	debugPrint("  Target for bottom at", mountBottom)

	local topIndex = self:findIndexAt(mountTop, nil, true)
	debugPrint("  Found new top index at", topIndex)
	local bottomIndex = self:findIndexAt(mountBottom, nil, true)
	debugPrint("  Found new bottom index at", bottomIndex)

	local leadIndex = math.max(topIndex, bottomIndex)
	if leadIndex < self.state.lead.index and not trimLeading then
		leadIndex = self.state.lead.index
	end

	local trailIndex = math.min(topIndex, bottomIndex)
	if trailIndex > self.state.trail.index and not trimTrailing then
		trailIndex = self.state.trail.index
	end

	if trailIndex < self.state.trail.index or leadIndex > self.state.lead.index then
		debugPrint("  Changing leading index to", leadIndex)
		debugPrint("  Changing trailing index to", trailIndex)
		return {
			trail = {index=trailIndex, id=self:getID(trailIndex)},
			lead = {index=leadIndex, id=self:getID(leadIndex)},
		}
	else
		return {}
	end
end

-- Find the index of the element that overlaps the given canvas-relative position.
function Scroller:findIndexAt(targetPos, hintIndex, extrapolate)
	debugPrint("  findIndexAt")
	-- Get the distance from the hinted index or the anchor.
	local currentIndex = hintIndex or self.state.anchor.index
	local currentDist = self:distanceToPosition(currentIndex, targetPos)
	debugPrint("    Searching from index", currentIndex)
	debugPrint("    Position is", currentDist, "from", targetPos)
	if currentDist == 0 then
		return currentIndex
	end

	-- Get the distance from one end of the list.
	local nextIndex = (currentDist < 0) and self.state.trail.index or self.state.lead.index
	debugPrint("    Nearest end at", nextIndex)
	if currentIndex == nextIndex then
		debugPrint("    Hint index already at end")
		-- If the target position lies outside of the loaded elements.
		if currentIndex + currentDist < self.state.trail.index
			or currentIndex + currentDist > self.state.lead.index then
			debugPrint("    Target out of bounds")
			if not extrapolate then
				-- Do not extrapolate. Return the closest loaded element.
				return currentIndex
			end

			-- Extrapolate using the estimated item size.
			local delta = Round.awayFromZero(currentDist / self.props.estimatedItemSize)
			debugPrint("    Estimating target at", delta, "from end")
			return math.min(math.max(currentIndex + delta, 1), self.state.listSize)
		end
	else
		local nextDist = self:distanceToPosition(nextIndex, targetPos)
		debugPrint("    End is", nextDist, "from target")
		if nextDist == 0 then
			return nextIndex
		end

		-- If the target position lies outside of the loaded elements.
		if currentDist * nextDist > 0 then
			debugPrint("    Target out of bounds")
			if not extrapolate then
				-- Do not extrapolate. Return the closest loaded element.
				return nextIndex
			end

			-- Extrapolate using the estimated item size.
			local delta = Round.awayFromZero(nextDist / self.props.estimatedItemSize)
			debugPrint("    Estimating target at", delta, "from end")
			return math.min(math.max(nextIndex + delta, 1), self.state.listSize)
		end

		-- Jump to the approximate location of the target based on the distance from current and next.
		local totalDist = math.abs(currentDist) + math.abs(nextDist)
		local indexCount = math.abs(currentIndex - nextIndex)
		currentIndex = currentIndex + Round.nearest(indexCount * currentDist / totalDist)
		currentDist = self:distanceToPosition(currentIndex, targetPos)
		debugPrint("    Interpolated index is", currentIndex)
		debugPrint("    Distance from interpolated index is", currentDist)
	end

	-- Linear search from best guess index.
	while currentDist ~= 0 do
		if currentDist < 0 then
			currentIndex = currentIndex - 1
		else
			currentIndex = currentIndex + 1
		end
		currentDist = self:distanceToPosition(currentIndex, targetPos)
		debugPrint("    Distance after step is", currentDist)
	end

	return currentIndex
end

-- Expand the size of the scrolling frame's canvas to make sure everything still fits.
function Scroller:expandCanvas(newState)
	debugPrint("expandCanvas")
	local reverse = isReverse[self.props.orientation]
	local bottomIndex = reverse and self.state.trail.index or self.state.lead.index

	local size = self.state.size
	local newPadding = newState.padding or self.state.padding
	local oldPadding = self:getCurrentPadding()

	local bottomPos = self:getChildCanvasPosition(bottomIndex)
		+ self:getChildSize(bottomIndex) - (oldPadding - newPadding)

	local bottomTarget = bottomPos + self.props.dragBuffer

	debugPrint("  Bottom of bottom child is", bottomPos)
	debugPrint("  Canvas size is", self.state.size)
	debugPrint("  Canvas bottom should be", bottomTarget)

	local minSize = self:measure(self:getCurrent().AbsoluteSize) - math.max(0, newPadding)
	if self.state.size < minSize then
		size = minSize
		debugPrint("  Expanding canvas to minimum size", size)
	end

	if self.state.size < bottomTarget then
		-- Plus footer
		size = math.max(bottomTarget, size)
		debugPrint("  Expanding canvas bottom to size", size)
	end

	debugPrint("  Padding is", newPadding)
	debugPrint("  Padding should be at least", self.props.dragBuffer)
	if newPadding < self.props.dragBuffer then
		-- Minus header
		local diff = newPadding - self.props.dragBuffer
		size = size - diff
		self.anchorCanvasPosition = self.anchorCanvasPosition - diff
		newPadding = self.props.dragBuffer
		debugPrint("  Expanding canvas top to size", size)
		debugPrint("  Shifting anchor to", self.anchorCanvasPosition)
		debugPrint("  Padding is now", newPadding)
	end

	if size ~= self.state.size or newPadding ~= self.state.padding then
		debugPrint("  Changing size from", self.state.size, "to", size)
		debugPrint("  Changing padding from", self.state.padding, "to", newPadding)
		return {
			size = size,
			padding = newPadding,
		}
	else
		debugPrint("  No changes to size or padding")
		return {}
	end
end

-- Try and get the canvas as close to correct as possible this rendering pass.
function Scroller:adjustCanvas(trimTrailing, trimLeading)
	debugPrint("adjustCanvas")

	local newState = Cryo.Dictionary.join(
		self:resetAnchorPosition(),
		self:recalculateBounds(trimTrailing, trimLeading)
	)

	if not newState.trail and not newState.lead then
		newState = Cryo.Dictionary.join(newState, self:expandCanvas(newState))
	end

	if Cryo.isEmpty(newState) then
		debugPrint("  No state changes after adjustment")
		return false
	end

	self:setState(newState)
	return true
end

-- Move the canvas position so that the anchor element is in the same place on the screen.
function Scroller:scrollToAnchor()
	if self.motorActive then
		return
	end
	debugPrint("scrollToAnchor")
	if self.indexChanged == nil then
		self:moveToAnchor()
	end

	local newIndex = self.indexChanged.newIndex
	local previousIndex = self.indexChanged.oldIndex
	debugPrint(" newIndex", newIndex)
	debugPrint(" previousIndex", previousIndex)

	local oldPos = self:getAnchorCanvasFromIndex(previousIndex)
	local newPos = self:getAnchorCanvasFromIndex(newIndex)

	debugPrint(" old anchor pos", oldPos)
	debugPrint(" new anchor pos", newPos)

	self.indexChanged.currentPos = oldPos
	self.indexChanged.newPos = newPos
	self.motorActive = true
	self.springLock = self.springLock + 1

	local delta = newPos - oldPos
	debugPrint(" delta", delta)
	self.motor = Otter.createSingleMotor(0)
	self.motor:onStep(self.motorOnStep)
	self.motor:onComplete(self.motorOnComplete)
	self.motor:setGoal(Otter.spring(delta, self.props.animateOptions))
end

-- Move the canvas position so that the anchor element is in the same place on the screen.
function Scroller:moveToAnchor()
	debugPrint("moveToAnchor")
	if self.motorActive then
		return
	end
	local currentPos = self:getAnchorFramePosition()
	debugPrint("  Anchor was at frame position", self.anchorFramePosition)
	debugPrint("  Anchor is currently at frame position", currentPos)
	local newPos = self:measure(self:getCurrent().CanvasPosition) + currentPos - self.anchorFramePosition
	debugPrint("  Canvas should scroll to", newPos)
	local current = self:getCurrent()
	local maxPos = math.max(0, self:measure(current.CanvasSize).Offset - self:measure(current.AbsoluteSize))

	self:setScroll(newPos)
	if newPos < 0 then
		debugPrint("  Canvas scroll limited to 0, was", newPos)
		self.anchorOffset = newPos
	elseif newPos >= maxPos then
		debugPrint("  Canvas scroll limited to", maxPos, ", was", newPos)
		self.anchorOffset = (newPos - maxPos)
	else
		debugPrint("  Clearing anchorOffset")
		self.anchorOffset = 0
	end
end

-- Call loadNext and loadPrevious if needed.
function Scroller:loadMore()
	debugPrint("loadMore")
	if self.props.loadPrevious and self.state.trail.index <= self.props.loadingBuffer then
		debugPrint("  Calling loadPrevious")
		self.props.loadPrevious()
	end
	if self.props.loadNext and self.state.lead.index > self.state.listSize - self.props.loadingBuffer then
		debugPrint("  Calling loadNext")
		self.props.loadNext()
	end
end

-- Set the current canvas position according to Orientation without calling
-- onScroll.
function Scroller:setScroll(pos)
	debugPrint("    Scrolling to", pos)
	self.scrollDebounce = true
	self:getCurrent().CanvasPosition = isVertical[self.props.orientation]
		and Vector2.new(self:getCurrent().CanvasPosition.X, pos)
		or Vector2.new(pos, self:getCurrent().CanvasPosition.Y)
	self.scrollDebounce = false
end

-- Scroll by a relative amount
function Scroller:scrollRelative(amount)
	debugPrint("  Current CanvasPosition", self:getCurrent().CanvasPosition)
	debugPrint("self.motorActive", self.motorActive)
	self:setScroll(self:measure(self:getCurrent().CanvasPosition) + amount, true)
	self.onScroll(self:getCurrent())
end


-- Returns the signed distance from the element to the given canvas-relative
-- position, or 0 if the element overlaps it. The sign of the distance is
-- relative to the list indices. For this distance calculation, the padding
-- between elements is considered part of the current element. Returns nil if
-- the element is not currently rendered.
function Scroller:distanceToPosition(index, pos)
	local child = self:getRbx(index)
	if not child then
		return nil
	end

	local childTop = self:absoluteToCanvasPosition(self:measure(child.AbsolutePosition)) - self.itemPadding
	local childBottom = childTop + self:measure(child.AbsoluteSize) + 2 * self.itemPadding

	if pos < childTop then
		return (pos - childTop) * direction[self.props.orientation]
	elseif pos > childBottom then
		return (pos - childBottom) * direction[self.props.orientation]
	else
		return 0
	end
end

-- Get the canvas-relative position of the current anchor element.
function Scroller:getAnchorCanvasPosition()
	return self:getAnchorCanvasFromIndex(self.state.anchor.index)
end

function Scroller:getAnchorCanvasFromIndex(index)
	local scale = self.props.anchorLocation.Scale
	if not isReverse[self.props.orientation] then
		scale = 1 - scale
	end

	return Round.nearest(self:getChildCanvasPosition(index) + scale * self:getChildSize(index))
end

-- Get the frame-relative position of the current anchor element.
function Scroller:getAnchorFramePosition()
	return self:getAnchorFrameFromIndex(self.state.anchor.index)
end

function Scroller:getAnchorFrameFromIndex(index)
	local scale = self.props.anchorLocation.Scale
	if not isReverse[self.props.orientation] then
		scale = 1 - scale
	end

	return Round.nearest(self:getChildFramePosition(index) + scale * self:getChildSize(index))
		- self.relativeAnchorLocation
end

-- Convert an AbsolutePosition to a position relative to the top-left corner of the canvas.
function Scroller:absoluteToCanvasPosition(position)
	local current = self:getCurrent()
	local canvas = current.CanvasPosition
	local absolute = current.AbsolutePosition
	return position + self:measure(canvas) - self:measure(absolute)
end

-- Convert an AbsolutePosition to a position relative to the top-left corner of the scrolling frame.
function Scroller:absoluteToFramePosition(position)
	local current = self:getCurrent()
	local absolute = current.AbsolutePosition
	return position - self:measure(absolute)
end

-- Get the canvas-relative position of the element at the specified index.
function Scroller:getChildCanvasPosition(index)
	local current = self:getRbx(index)
	return current and self:absoluteToCanvasPosition(self:measure(current.AbsolutePosition)) or 0
end

-- Get the frame-relative position of the element at the specified index.
function Scroller:getChildFramePosition(index)
	local current = self:getRbx(index)
	return current and self:absoluteToFramePosition(self:measure(current.AbsolutePosition)) or 0
end

-- Get the absolute size of the element at the specified index.
function Scroller:getChildSize(index)
	local current = self:getRbx(index)
	return current and self:measure(current.AbsoluteSize) or 0
end

-- Get the ID of an element at a specific index.
function Scroller:getID(index)
	return self.props.identifier(self.props.itemList[index])
end

-- Create or update a metadata entry for the given element. This can't use
-- self.props in willUpdate as any props it uses could be out of date.
function Scroller:updateMetadata(id, item, props)
	local meta = self.metadata[id]
	if not meta then
		meta = {}
		self.metadata[id] = meta
	end

	if not meta.name then
		local elem = props.renderItem(item, false)
		meta.class = tostring(elem.component)
		local pool = self:getKeyPool(meta.class)
		meta.name = pool:get()
	end

	if not self.refpool[meta.name] then
		self.refpool[meta.name] = Roact.createRef()
	end
	meta.ref = self.refpool[meta.name]
end

-- Clear the metadata for an element that is being unloaded.
function Scroller:clearMetadata(id)
	local meta = self.metadata[id]
	if not meta then
		return
	end

	-- Not releasing the names seems like it would be a memory leak, but this
	-- relies on the fact that the key pool does not track in use keys. Rather,
	-- the key tracks which pool it came from. So if nothing is using an
	-- unreleased key, it will be garbage collected and never reused.
	if not Cryo.List.find(self.props.recyclingDisabledFor, meta.class) then
		meta.name:release()
	end
	meta.name = nil
	meta.ref = nil
end

-- Get the key pool for the given class of elements, or create a new one if that doesn't exist yet.
function Scroller:getKeyPool(class)
	if not self.pools[class] then
		self.pools[class] = KeyPool.new(class)
	end
	return self.pools[class]
end

-- Get the metadata info for the element at the specified index.
function Scroller:getMetadata(index)
	return self.metadata[self:getID(index)]
end

-- Get the current Roblox instance from the ref stored in the metadata.
function Scroller:getRbx(index)
	local meta = self:getMetadata(index)
	return meta and meta.ref and meta.ref.current
end

-- Return X or Y depending on the orientation.
function Scroller:measure(vecOrUDim2)
	return isVertical[self.props.orientation] and vecOrUDim2.Y or vecOrUDim2.X
end

-- Get the current ScrollingFrame instance.
function Scroller:getCurrent()
	return self:getRef().current
end

function Scroller:getRef()
	-- Make sure to get the ref from props if that exists.
	return self.props[Roact.Ref] or self._ref
end

return Scroller
