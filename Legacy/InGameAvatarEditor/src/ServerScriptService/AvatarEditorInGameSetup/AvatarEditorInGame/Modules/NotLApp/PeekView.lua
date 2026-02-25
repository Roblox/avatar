--[[

        -- |- CanvasPos x -| --
        |  |               |  |
        |  |               |  |
        |  |  FillingArea  |  |
        |  |               | ScrollingFrame
  PeekView |               |  |
 component |---------------|  | --
    height |  PeekHeader   |  |  |
        |  |---------------|  |  |
        |  |  Content ...  |  | ClipFrame
        |  |---------------|  |  |
        |  |BottomContainer|  |  |
        -- |---------------| -- --
           .               .
           .  ... Content  .
           .               .

  FillingArea:
    Input can penetrate this area

    --     |-------_-------| --
    |      |               |  |
    |      |               |  |
    |      |               | PeekView
  Full     |               | component
    |   -- |-------_-------| height
    |   |  |               |  |
    | Brief|               |  |
    |   |  |               |  |
    --  -- |-------_-------| -- -- Closed
            -------_-------     -- Hidden

  isTouched:
    PeekView is under holding or swiping

  isInGoToState:
    PeekView is automatically going up or down to brief, full or close view
    This state can NOT be stopped by any touch
]]

local Modules = script:FindFirstAncestorOfClass("ScreenGui").Modules

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService('RunService')

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local FitChildren = require(Modules.NotLApp.FitChildren)
local PeekViewState = require(Modules.NotLApp.PeekViewState)

local ExternalEventConnection = require(Modules.Common.RoactUtilities.ExternalEventConnection)
local ArgCheck = require(Modules.Common.ArgCheck)

local AXUtils = require(Modules.AvatarExperience.Common.Utils)

local ImageSetLabel = UIBlox.Core.ImageSet.Label

local FFlagAvatarExperiencePeekHeaderUpdate = true
local GetFFlagLuaAppPeekViewHeightChangeFix = function() return true end
local isRoactNavigationEnabled = function() return false end

local Images = UIBlox.App.ImageSet.Images

local UseTempHacks = require(Modules.Config.UseTempHacks)

local BACKGROUND_SLICE_CENTER = Rect.new(9, 9, 9, 9)
local BACKGROUND_IMAGE = Images["component_assets/circle_17"]
local DRAGGER_IMAGE = "http://www.roblox.com/asset/?id=7265157657"

local PEEK_HEADER_HEIGHT = 25
local GO_TO_TRANSITION_TIME = 0.35
local TRANSITION_FUNC_CONSTANT = 0.5 * math.pi / (GO_TO_TRANSITION_TIME / 0.55)
local FULL_VIEW_HEIGHT = UDim.new(1, 0)
local SWIPE_VELOCITY_THRESHOLD = 500
local STICK_MAX_SPEED = 1000

local VT_Hidden = PeekViewState.Hidden
local VT_Closed = PeekViewState.Closed
local VT_Brief = PeekViewState.Brief
local VT_Full = PeekViewState.Full
local VT_Extended = PeekViewState.Extended

local PeekView = Roact.PureComponent:extend("PeekView")

PeekView.defaultProps = {
	briefViewContentHeight = UDim.new(0.5, 0),
	bottomDockedContainerHeight = 0,
	bottomDockedContainerContent = nil,
	hidden = false,
	showDraggerInClosedState = true,
	mountAsFullView = false,
	mountAnimation = true,
	canDragFullViewToBrief = false,
	withNewThemeProvider = true,
	viewStateChanged = nil, -- function(viewState, preViewState)
	briefToFullTransitionPercent = nil, -- function(percent)
	peekHeaderClose = true,
	peekHeaderPositionYChange = nil, --function(scrollY)
	isScrollingEnabled = true,
}

function PeekView:init()
	self.isMounted = false

	self.isTouched = false
	self.isInGoToState = false

	self.viewType = VT_Hidden

	self.containerFrameRef = Roact.createRef()
	self.clipFrameRef = Roact.createRef()
	self.shadowRef = Roact.createRef()
	self.fillingAreaRef = Roact.createRef()
	self.swipeScrollingFrameRef = Roact.createRef()
	self.bottomContainterRef = Roact.createRef()

	self.withStyle = function(func)
		if self.props.withNewThemeProvider then
			return UIBlox.Style.withStyle(func)
		end

		return func({ Theme = {
			BackgroundDefault = {
				Color = Color3.fromRGB(35, 37, 39),
				Transparency = 0,
			},
			UIEmphasis = {
				Color = Color3.fromRGB(255, 255, 255),
				Transparency = 0.7, -- Alpha 0.3
			},
			DropShadow = {
				Color = Color3.fromRGB(0, 0, 0),
				Transparency = 0,
			}
		}})
	end

	self.inputBeganCallback = function(input)
		if not self.isMounted then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		self.isTouched = true
	end

	self.inputEndedCallback = function(input)
		if not self.isMounted then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		self.isTouched = false
		self.checkGoTo()
	end

	self.getViewSize = function(viewType)
		local viewSize = nil

		if viewType == VT_Hidden then
			viewSize = UDim.new(0, 0)
		elseif viewType == VT_Closed then
			if self.props.showDraggerInClosedState then
				viewSize = UDim.new(0, PEEK_HEADER_HEIGHT)
			else
				viewSize = UDim.new(0, 0)
			end
		elseif viewType == VT_Brief then
			local briefViewContentHeight = self.props.briefViewContentHeight
			viewSize = UDim.new(briefViewContentHeight.Scale, briefViewContentHeight.Offset + PEEK_HEADER_HEIGHT)
		elseif viewType == VT_Full then
			viewSize = FULL_VIEW_HEIGHT
		end

		return viewSize
	end

	self.reconcileRbxInstances = function()
		local swipeScrollingFrame = self.swipeScrollingFrameRef.current
		local scrollingFrameCanvasY = swipeScrollingFrame and swipeScrollingFrame.CanvasPosition.Y or 0

		local containerFrame = self.containerFrameRef.current
		local clipFrame = self.clipFrameRef.current
		local shadow = self.shadowRef.current
		local fillingArea = self.fillingAreaRef.current

		local width = containerFrame.AbsoluteSize.X
		local height = containerFrame.AbsoluteSize.Y

		clipFrame.Size = UDim2.new(0, width, 0, scrollingFrameCanvasY)
		clipFrame.Position = UDim2.new(0, 0, 0, height - scrollingFrameCanvasY)

		shadow.Size = UDim2.new(0, width, 0, 36)
		shadow.Position = UDim2.new(0, 0, 0, height - scrollingFrameCanvasY - 30)

		swipeScrollingFrame.Size = UDim2.new(0, width, 0, height)
		swipeScrollingFrame.Position = UDim2.new(0, 0, 0, - (height - scrollingFrameCanvasY))

		fillingArea.Size = UDim2.new(0, width, 0, height)

		local bottomContainter = self.bottomContainterRef.current
		if bottomContainter then
			local bottomDockedContainerHeight = self.props.bottomDockedContainerHeight
			if clipFrame.AbsoluteSize.Y > PEEK_HEADER_HEIGHT + bottomDockedContainerHeight then
				bottomContainter.Active = true
				bottomContainter.Position = UDim2.new(0, 0, 1, - bottomDockedContainerHeight)
			else
				bottomContainter.Active = false
				bottomContainter.Position = UDim2.new(0, 0, 1, - clipFrame.AbsoluteSize.Y + PEEK_HEADER_HEIGHT)
			end
		end

		self.transitionCallbacks()
	end

	self.updateSwipeScrollingFrame = function()
		local viewSize = self.getViewSize(self.viewType)

		local scrollingFrameRefValid = true
		if isRoactNavigationEnabled() then
			scrollingFrameRefValid = self.containerFrameRef.current and self.swipeScrollingFrameRef.current
		end

		if viewSize and scrollingFrameRefValid then
			local containerFrame = self.containerFrameRef.current
			local containerFrameHeight = containerFrame.AbsoluteSize.Y
			local swipeScrollingFrame = self.swipeScrollingFrameRef.current
			local goToPosY = containerFrameHeight * viewSize.Scale + viewSize.Offset
			if swipeScrollingFrame.CanvasPosition.Y ~= goToPosY then
				swipeScrollingFrame.CanvasPosition = Vector2.new(0, goToPosY)
				if FFlagAvatarExperiencePeekHeaderUpdate and self.props.peekHeaderPositionYChange then
					self.props.peekHeaderPositionYChange(goToPosY)
				end
			end
		end
	end

	self.onContainerFrameAbsoluteSizeChanged = function()
		if not self.isMounted then
			return
		end

		self.reconcileRbxInstances()
		self.updateSwipeScrollingFrame()
	end

	self.onSwipeScrollingFrameCanvasPositionChanged = function()
		if not self.isMounted then
			return
		end
		-- Round scrollingFrameCanvasY to an integer to prevent PeekHeader & BottomContainer jittering
		local swipeScrollingFrame = self.swipeScrollingFrameRef.current
		local scrollingFrameCanvasY = swipeScrollingFrame.CanvasPosition.Y
		if scrollingFrameCanvasY ~= math.floor(scrollingFrameCanvasY) then
			swipeScrollingFrame.CanvasPosition = Vector2.new(0, math.floor(scrollingFrameCanvasY + 0.5))
			if FFlagAvatarExperiencePeekHeaderUpdate and self.props.peekHeaderPositionYChange then
				self.props.peekHeaderPositionYChange(scrollingFrameCanvasY)
			end
			return
		end
		self.reconcileRbxInstances()
		self.checkGoTo()
	end

	self.getBriefViewY = function()
		local containerFrameHeight = self.containerFrameRef.current.AbsoluteSize.Y
		local bfvContentHeight = self.props.briefViewContentHeight
		return (containerFrameHeight * bfvContentHeight.Scale + bfvContentHeight.Offset + PEEK_HEADER_HEIGHT)
	end

	self.getFullViewY = function()
		local containerFrameHeight = self.containerFrameRef.current.AbsoluteSize.Y
		return (containerFrameHeight * FULL_VIEW_HEIGHT.Scale + FULL_VIEW_HEIGHT.Offset)
	end

	self.transitionCallbacks = function()
		local briefToFullTransitionPercent = self.props.briefToFullTransitionPercent
		if briefToFullTransitionPercent then
			local swipeScrollingFrame = self.swipeScrollingFrameRef.current
			local curY = swipeScrollingFrame.CanvasPosition.Y
			local briefViewY = self.getBriefViewY()
			local fullViewY = self.getFullViewY()
			local briefToFullDistance = fullViewY - briefViewY
			local percent = 0
			if curY > briefViewY and curY <= fullViewY then
				percent = (curY - briefViewY) / briefToFullDistance
			elseif curY > fullViewY then
				percent = 1
			end
			briefToFullTransitionPercent(percent)
		end
	end

	self.checkGoTo = function()
		if self.isInGoToState then
			return
		end

		if self.isTouched then
			return
		end

		local briefViewY = self.getBriefViewY()
		local fullViewY = self.getFullViewY()

		if briefViewY > fullViewY then
			return
		end

		local swipeScrollingFrame = self.swipeScrollingFrameRef.current
		local inertialVelocityY = 0
		if not UseTempHacks then
			inertialVelocityY = swipeScrollingFrame:GetSampledInertialVelocity().Y
		end

		local inertiaUp = inertialVelocityY < 0
		local inertiaDown = inertialVelocityY > 0
		local curY = swipeScrollingFrame.CanvasPosition.Y

		local canDragFullViewToBrief = self.props.canDragFullViewToBrief

		if curY > briefViewY and curY <= fullViewY then
			local briefToFullDistance = fullViewY - briefViewY
			if self.viewType == VT_Full then
				if inertiaDown or curY < briefViewY + briefToFullDistance * 0.8 then
					local isSwipe = inertiaDown and inertialVelocityY > SWIPE_VELOCITY_THRESHOLD
					if canDragFullViewToBrief and not isSwipe then
						self.goTo(VT_Brief)
					else
						self.goTo(VT_Closed)
					end
				else
					self.goTo(VT_Full)
				end
			elseif self.viewType == VT_Extended then
				if not inertiaDown or curY < briefViewY + briefToFullDistance * 0.8 or inertialVelocityY > -1 then
					self.goTo(VT_Full)
				end
			else
				if inertiaUp or curY > briefViewY + briefToFullDistance * 0.2 then
					self.goTo(VT_Full)
				else
					self.goTo(VT_Brief)
				end
			end
		elseif curY <= briefViewY then
			local closedToBriefDistance = briefViewY - 0
			if self.viewType == VT_Brief then
				if inertiaDown or curY < 0 + closedToBriefDistance * 0.8 then
					self.goTo(VT_Closed)
				else
					self.goTo(VT_Brief)
				end
			else
				if inertiaUp or curY > 0 + closedToBriefDistance * 0.2 then
					self.goTo(VT_Brief)
				else
					self.goTo(VT_Closed)
				end
			end
		elseif curY > fullViewY then
			if self.viewType ~= VT_Full and self.viewType ~= VT_Extended then
				if inertiaUp then
					self.goTo(VT_Full)
				else
					self.setViewType(VT_Extended)
				end
			elseif self.viewType == VT_Full then
				self.setViewType(VT_Extended)
			end
		end
	end

	self.onPeekHeaderActivated = function()
		if self.viewType == VT_Closed then
			self.goTo(VT_Brief)
		elseif self.viewType == VT_Brief then
			self.goTo(VT_Full)
		elseif self.viewType == VT_Full then
			if FFlagAvatarExperiencePeekHeaderUpdate then
				if self.props.peekHeaderClose then
					self.goTo(VT_Closed)
				else
					self.goTo(VT_Brief)
				end
			else
				self.goTo(VT_Closed)
			end
		end
	end

	self.setViewType = function(viewType)
		-- clear goto state
		if self.goToAnimationConnection then
			self.goToAnimationConnection:disconnect()
			self.goToAnimationConnection = nil
		end
		self.isInGoToState = false
		self.clipFrameRef.current.Active = false

		-- fire viewStateChanged
		local preViewType = self.viewType
		if preViewType ~= viewType then
			self.viewType = viewType
			local viewStateChanged = self.props.viewStateChanged
			if viewStateChanged then
				viewStateChanged(viewType, preViewType)
			end
		end

		-- update swipeScrollingFrame
		self.updateSwipeScrollingFrame()
	end

	self.goTo = function(viewType, animation)
		if ArgCheck.isEqual(self.isInGoToState, false, "self.isInGoToState") then
			return
		end

		if ArgCheck.isEqual(self.goToAnimationConnection, nil, "self.goToAnimationConnection") then
			return
		end

		self.isInGoToState = true
		if not UseTempHacks then
			self.swipeScrollingFrameRef.current:ClearInertialScrolling()
		end
		self.clipFrameRef.current.Active = true

		if animation == false then
			self.setViewType(viewType)
		else
			local startTime = tick()

			self.goToAnimationConnection = RunService.RenderStepped:Connect(function()
				if not self.isMounted then
					return
				end

				if not UseTempHacks then
					self.swipeScrollingFrameRef.current:ClearInertialScrolling()
				end

				local swipeScrollingFrame = self.swipeScrollingFrameRef.current
				local containerFrameHeight = self.containerFrameRef.current.AbsoluteSize.Y
				local viewSize = ArgCheck.isNotNil(self.getViewSize(viewType), "self.goTo.viewSize")
				local goToPosY = containerFrameHeight * viewSize.Scale + viewSize.Offset
				local timeElapsed = tick() - startTime

				-- On Complete
				if timeElapsed >= GO_TO_TRANSITION_TIME then
					self.setViewType(viewType)
					return
				end

				local startPosY = swipeScrollingFrame.CanvasPosition.Y
				local distance = goToPosY - startPosY
				swipeScrollingFrame.CanvasPosition = Vector2.new(0,
					startPosY + distance * math.sin(timeElapsed * TRANSITION_FUNC_CONSTANT))
			end)
		end
	end
end

-- Check if the scrolling frame position needs to be adjusted after changing focused component and engine auto-scroll
function PeekView:adjustScrollingFramePosition()
	local currentSelection = GuiService.SelectedCoreObject
	if not currentSelection or not self.props.contentFrameRef
		or not currentSelection:IsDescendantOf(self.props.contentFrameRef.current) then
		return
	end

	local swipeScrollingFrameRef = self.swipeScrollingFrameRef.current
	if self.viewType ~= VT_Extended and self.viewType ~= VT_Full then
		--[[
			When PeekView is mounted as Hidden, engine auto-scroll will auto-scroll to the focussed components
			in the PeekView. This ensures the mount animation from hidden to brief view will work as expected
		]]
		local viewSize = self.getViewSize(self.viewType)
		swipeScrollingFrameRef.CanvasPosition = Vector2.new(swipeScrollingFrameRef.CanvasPosition.X, viewSize.Offset)
	else
		local currentPosition = currentSelection.AbsolutePosition.Y - self.props.topBarHeight
		local currentSize = currentSelection.AbsoluteSize.Y
		local scrollingFrameYBottom = swipeScrollingFrameRef.AbsoluteWindowSize.Y
		local bottomDistance = scrollingFrameYBottom - (currentPosition + currentSize)
		local newCanvasPositionY = swipeScrollingFrameRef.CanvasPosition.Y
		if bottomDistance < self.props.bottomDockedContainerHeight then
			--if the focused component is covered by the bottom docked container, adjust position so it is not covered
			newCanvasPositionY = newCanvasPositionY + self.props.bottomDockedContainerHeight - bottomDistance
		elseif currentPosition + currentSize + (newCanvasPositionY - scrollingFrameYBottom) <
			scrollingFrameYBottom - self.props.bottomDockedContainerHeight then
			--[[
				if the focused component can be visible when the PeekView is in FullView,
				adjust position to FullView (rather than generically Extended)
			]]
			newCanvasPositionY = scrollingFrameYBottom
		end
		newCanvasPositionY = math.max(0, math.min(newCanvasPositionY,
			swipeScrollingFrameRef.CanvasSize.Y.Offset - swipeScrollingFrameRef.AbsoluteWindowSize.Y))
		swipeScrollingFrameRef.CanvasPosition = Vector2.new(swipeScrollingFrameRef.CanvasPosition.X, newCanvasPositionY)
	end
end

function PeekView:handleThumbstickInput(inputObject, deltaTime)
	local stickInput = inputObject.Position
	local swipeScrollingFrame = self.swipeScrollingFrameRef:getValue()
	if self.containerFrameRef:getValue() and swipeScrollingFrame then
		local yPos = swipeScrollingFrame.CanvasPosition.Y
		local stickVector = AXUtils.normalizeStickByDeadzone(stickInput)
		local newYPos = yPos + deltaTime * -stickVector.Y * STICK_MAX_SPEED
		if newYPos > self.getFullViewY() then
			swipeScrollingFrame.CanvasPosition = Vector2.new(0, newYPos)
		end
	end
end

function PeekView:render()
	local children = self.props[Roact.Children]

	local bottomDockedContainerHeight = self.props.bottomDockedContainerHeight
	local bottomDockedContainerContent = self.props.bottomDockedContainerContent
	local includeScrollBinding = false

	return self.withStyle(function(style)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			[Roact.Ref] = self.containerFrameRef,
			[Roact.Change.AbsoluteSize] = self.onContainerFrameAbsoluteSizeChanged,
		}, {
			DropShadowBackground = Roact.createElement("Frame", {
				ZIndex = 0,
				[Roact.Ref] = self.shadowRef,
			},{
				UIGradient = Roact.createElement("UIGradient", {
					Rotation = 90,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, style.Theme.DropShadow.Color),
						ColorSequenceKeypoint.new(1, style.Theme.DropShadow.Color)
					}),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1.0),
						NumberSequenceKeypoint.new(1, 0.7)
					}),
				})
			}),
			ClipFrame = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					[Roact.Ref] = self.clipFrameRef,
				}, {
					SwipeScrollingFrame = Roact.createElement(FitChildren.FitScrollingFrame, {
						Active = true,
						BackgroundTransparency = 1,
						ZIndex = 1,
						BorderSizePixel = 0,
						ScrollBarThickness = 0,
						ClipsDescendants = false,
						ScrollingDirection = Enum.ScrollingDirection.Y,
						ElasticBehavior = Enum.ElasticBehavior.Always,
						ScrollingEnabled = self.props.isScrollingEnabled,
						fitFields = {
							CanvasSize = FitChildren.FitAxis.Height,
						},
						[Roact.Ref] = self.swipeScrollingFrameRef,
						[Roact.Change.CanvasPosition] = self.onSwipeScrollingFrameCanvasPositionChanged,
					}, {
						UIListLayout = Roact.createElement("UIListLayout", {
							Padding = UDim.new(0, 0),
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
							VerticalAlignment = Enum.VerticalAlignment.Top,
						}),
						FillingArea = Roact.createElement("Frame", {
							LayoutOrder = 1,
							BackgroundTransparency = 1,
							Active = false,
							[Roact.Ref] = self.fillingAreaRef,
						}),
						BackgroundFrame = Roact.createElement("Frame", {
							LayoutOrder = 2,
							ZIndex = 1,
							-- In order not to affect SwipeScrollingFrame CanvasSize
							Size = UDim2.new(1, 0, 0, 0),
							Active = false,
						}, {
							BackgroundImage = Roact.createElement(ImageSetLabel, {
								Size = UDim2.new(1, 0, 0, 9999),
								BackgroundTransparency = 1,
								ImageTransparency = style.Theme.BackgroundDefault.Transparency,
								ImageColor3 = style.Theme.BackgroundDefault.Color,
								BorderSizePixel = 0,
								ScaleType = Enum.ScaleType.Slice,
								SliceCenter = BACKGROUND_SLICE_CENTER,
								Image = BACKGROUND_IMAGE,
								Active = false,
							}),
						}),
						PeekHeader = Roact.createElement("TextButton", {
							Text = "",
							LayoutOrder = 3,
							ZIndex = 2,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, PEEK_HEADER_HEIGHT),
							[Roact.Event.Activated] = self.onPeekHeaderActivated,
						}, {
							Dragger = Roact.createElement("ImageLabel", {
								BackgroundTransparency = 1,
								Size = UDim2.new(0, 48, 0, 5),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.new(0.5, 0, 0.5, 0),
								Image = DRAGGER_IMAGE,
								ImageColor3 = style.Theme.UIEmphasis.Color,
								ImageTransparency = style.Theme.UIEmphasis.Transparency,
								Active = false,
							}),
						}),
						ContentFrame = Roact.createElement(FitChildren.FitFrame, {
								LayoutOrder = 4,
								ZIndex = 2,
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								ClipsDescendants = false,
								Size = UDim2.new(1, 0, 0, 0),
								fitAxis = FitChildren.FitAxis.Height,
							}, children),
						BottomContainterPlaceHolder = bottomDockedContainerHeight > 0 and Roact.createElement("Frame", {
							LayoutOrder = 5,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, bottomDockedContainerHeight),
							Active = false,
						}),
					}),
					BottomContainter = bottomDockedContainerHeight > 0 and Roact.createElement("Frame", {
						Active = true,
						ZIndex = 2,
						Size = UDim2.new(1, 0, 0, bottomDockedContainerHeight),
						BackgroundTransparency = 1,
						[Roact.Ref] = self.bottomContainterRef,
					}, bottomDockedContainerContent),
				}),
			InputBegan = Roact.createElement(ExternalEventConnection, {
				event = UserInputService.InputBegan,
				callback = self.inputBeganCallback,
			}),
			InputEnded = Roact.createElement(ExternalEventConnection, {
				event = UserInputService.InputEnded,
				callback = self.inputEndedCallback,
			}),
		})
	end)
end

function PeekView:didMount()
	self.isMounted = true

	local hidden = self.props.hidden
	local mountAsFullView = self.props.mountAsFullView
	local mountAnimation = self.props.mountAnimation

	if not hidden then
		if mountAsFullView then
			self.goTo(VT_Full, mountAnimation)
		else
			self.goTo(VT_Brief, mountAnimation)
		end
	end
end

function PeekView:didUpdate(prevProps, prevState)
	if GetFFlagLuaAppPeekViewHeightChangeFix()
		and prevProps.bottomDockedContainerHeight ~= self.props.bottomDockedContainerHeight then
		self.onContainerFrameAbsoluteSizeChanged()
	end

	if prevProps.hidden == false and self.props.hidden == true then
		self.goTo(VT_Hidden)
	elseif prevProps.hidden == true and self.props.hidden == false then
		self.goTo(VT_Brief)
	end
end

function PeekView:willUnmount()
	self.isMounted = false

	if isRoactNavigationEnabled() and self.goToAnimationConnection then
		self.goToAnimationConnection:disconnect()
		self.goToAnimationConnection = nil
	end
end

return PeekView
