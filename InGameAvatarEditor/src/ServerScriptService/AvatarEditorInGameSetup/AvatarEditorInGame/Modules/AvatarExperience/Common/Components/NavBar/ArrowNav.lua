local RunService = game:GetService("RunService")

local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local Otter = require(Modules.Packages.Otter)
local t = require(Modules.Packages.t)

local ImageSetButton = UIBlox.Core.ImageSet.Button
local withStyle = UIBlox.Style.withStyle
local Constants = require(Modules.AvatarExperience.Common.Constants)

local FFlagAXArrowNavFix = true
local GetAENewNavigationEnabled = function() return false end
local FFlagAvatarExperienceNewNavigationEnabledForAll
	= false

local ARROW_SIZE = 36

local SCROLL_CONSTANT = 500

local ANIMATION_SPRING_SETTINGS = {
	dampingRatio = 1,
	frequency = 3.5,
}

local ArrowNav = Roact.PureComponent:extend("ArrowNav")

ArrowNav.validateProps = not FFlagAvatarExperienceNewNavigationEnabledForAll and t.strictInterface({
	AnchorPoint = t.optional(t.Vector2),
	Position = t.optional(t.UDim2),
	Image = t.table,
	Visible = t.optional(t.union(t.boolean, t.table)),
	navDirection = t.optional(t.string), -- determine the direction of the navigation (Left / Right)
	onPressHoldInputBegan = t.optional(t.callback), -- Overrides default functionality for what to do on button press and hold began
	onPressHoldInputEnded = t.optional(t.callback), -- Overrides default functionality for what to do on button press and hold end

	--[[Contains information necessary for using the default functionality if not using
	onPressHoldInputBegan and onPressHoldInputEnded props for functionality]]
	defaultUseProps = t.optional(t.strictInterface({
		scrollingFrameRef = t.table, --(RoactRef) Reference to scrollingframe housing this component,
		categoryButtonRefs = t.table, --(table of RoactRefs) table of references to the button contents within the scrollingframe,
		buttonPadding = t.number, -- amount of padding between the buttons,
		updateCanvasPosition = t.callback, --(RoactBinding update function) Modifies binding in parent component to move scrollingframe,
	})),

	scrollingFrameRef = t.optional(t.table), -- (RoactRef) Reference to scrollingframe housing this component
	categoryButtonRefs = t.optional(t.table), -- (table(RoactRef)) table of references to the category buttons
	buttonPadding = t.optional(t.number), -- amount of padding between the buttons,
}) or t.strictInterface({
	AnchorPoint = t.optional(t.Vector2),
	Position = t.optional(t.UDim2),
	Image = t.table,
	Visible = t.optional(t.union(t.boolean, t.table)),
	navDirection = t.optional(t.string), -- determine the direction of the navigation (Left / Right)
	onPressHoldInputBegan = t.optional(t.callback), -- Overrides default functionality for button press and hold began
	onPressHoldInputEnded = t.optional(t.callback), -- Overrides default functionality button press and hold end

	--[[
		The following props are necessary for using the default functionality if not using
		onPressHoldInputBegan and onPressHoldInputEnded props for functionality
	--]]
	scrollingFrameRef = t.optional(t.table), -- (RoactRef) Reference to scrollingframe housing this component
	categoryButtonRefs = t.optional(t.table), -- (table(RoactRef)) table of references to the category buttons
	buttonPadding = t.optional(t.number), -- amount of padding between the buttons,
})

ArrowNav.defaultProps = {
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.new(0, 0, 0, 0),
	Visible = true,
}

function ArrowNav:init()
	self.holdConn = nil
	self.timeOfInputBegan = 0

	self.handleInputBegan = function(rbx, inputObject)
		local beganCallback = self.props.onPressHoldInputBegan or self.onPressHoldInputBegan
		beganCallback(inputObject, self.props.navDirection)
	end

	self.handleInputEnded = function(rbx, inputObject)
		local endCallBack = self.props.onPressHoldInputEnded or self.onPressHoldInputEnded
		endCallBack(inputObject, self.props.navDirection)
	end

	self.getNewCanvasPosition = function(xPos)
		local scrollingFrame = GetAENewNavigationEnabled() and self.props.scrollingFrameRef.current
			or self.props.defaultUseProps.scrollingFrameRef.current
		return scrollingFrame.CanvasPosition + Vector2.new(xPos, 0)
	end

	self.disconnectHoldConn = function()
		if self.holdConn == nil then
			return
		end
		self.holdConn:Disconnect()
		self.holdConn = nil
	end

	self.onPressHoldInputBegan = function(inputObj, navDirection)
		if inputObj.UserInputState ~= Enum.UserInputState.Begin then
			return
		end
		self.timeOfInputBegan = tick()
		self.disconnectHoldConn()
		self.holdConn = RunService.RenderStepped:connect(function(delta)
			local secondsPassed = (tick() - self.timeOfInputBegan)
			local leftDirection = GetAENewNavigationEnabled() and Constants.NavigationDirection.Left
				or Constants.NavigationDirection.IS_LEFT
			local direction = navDirection == leftDirection and -1 or 1
			local newCanvasPosition = self.getNewCanvasPosition(direction * SCROLL_CONSTANT * delta * secondsPassed^2)
			if GetAENewNavigationEnabled() then
				self.props.scrollingFrameRef.current.CanvasPosition = newCanvasPosition
			else
				self.props.defaultUseProps.updateCanvasPosition(newCanvasPosition)
			end
		end)
	end

	self.getClickDistance = function(navDirection)
		local scrollingFrame = GetAENewNavigationEnabled() and self.props.scrollingFrameRef.current
			or self.props.defaultUseProps.scrollingFrameRef.current
		local amountToLeft = scrollingFrame.CanvasPosition.X
		local amountToRight = (scrollingFrame.CanvasSize.X.Offset - scrollingFrame.AbsoluteSize.X) - amountToLeft

		local buttonPadding = (GetAENewNavigationEnabled() and self.props.buttonPadding
			or self.props.defaultUseProps.buttonPadding) or 0
		local buttonSizes = {}
		local categoryButtonRefs = GetAENewNavigationEnabled() and self.props.categoryButtonRefs
			or self.props.defaultUseProps.categoryButtonRefs
		for _, btnRef in ipairs(categoryButtonRefs) do
			if FFlagAXArrowNavFix then
				local btnSize = btnRef.current and btnRef.current.Size.X.Offset or 0
				table.insert(buttonSizes, btnSize)
			else
				table.insert(buttonSizes, btnRef.current.Size.X.Offset)
			end
		end
		local amountToJump = 0
		local leftDirection = GetAENewNavigationEnabled() and Constants.NavigationDirection.Left
			or Constants.NavigationDirection.IS_LEFT
		if navDirection == leftDirection then
			for _, btnSize in ipairs(buttonSizes) do
				if amountToJump + btnSize + buttonPadding < amountToLeft then
					amountToJump = amountToJump + btnSize + buttonPadding
				else
					break
				end
			end
			return amountToJump
		else
			for i = #buttonSizes, 1, -1 do
				if amountToJump + buttonSizes[i] + buttonPadding < amountToRight then
					amountToJump = amountToJump + buttonSizes[i] + buttonPadding
				else
					break
				end
			end
			return scrollingFrame.CanvasPosition.X + (amountToRight - amountToJump)
		end
	end

	self.onPressHoldInputEnded = function(inputObj, navDirection)
		if inputObj.UserInputState ~= Enum.UserInputState.End then
			return
		end
		local scrollingFrameRef = GetAENewNavigationEnabled() and self.props.scrollingFrameRef.current
			or self.props.defaultUseProps.scrollingFrameRef.current
		if tick() - self.timeOfInputBegan <= 0.5 then
			--reset motor in case of shift from Mouse/Keyboard input and updating canvasPosition with other input (ex: Touch)
			if self.motor then
				self.motor:destroy()
			end
			self:setMotor(scrollingFrameRef.CanvasPosition.X)
			self.motor:setGoal(Otter.spring(self.getClickDistance(navDirection), ANIMATION_SPRING_SETTINGS))
		else
			self.motor:setGoal(Otter.instant(scrollingFrameRef.CanvasPosition.X))
		end
		self.disconnectHoldConn()
	end
end

function ArrowNav:didMount()
	self:setMotor(0)
end

function ArrowNav:setMotor(initValue)
	self.motor = Otter.createSingleMotor(initValue)
	self.motor:onStep(function(newValue)
		if GetAENewNavigationEnabled() then
			self.props.scrollingFrameRef.current.CanvasPosition = Vector2.new(newValue, 0)
		else
			self.props.defaultUseProps.updateCanvasPosition(Vector2.new(newValue, 0))
		end
	end)
	self.motor:onComplete(function(newValue)
		if GetAENewNavigationEnabled() then
			self.props.scrollingFrameRef.current.CanvasPosition = Vector2.new(newValue, 0)
		else
			self.props.defaultUseProps.updateCanvasPosition(Vector2.new(newValue, 0))
		end
	end)
end

function ArrowNav:render()
	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme
		return Roact.createElement(ImageSetButton, {
			AnchorPoint = self.props.AnchorPoint,
			Position = self.props.Position,
			Image = self.props.Image,
			Visible = self.props.Visible,
			BackgroundTransparency = 1,
			ImageColor3 = theme.IconEmphasis.Color,
			Size = UDim2.fromOffset(ARROW_SIZE, ARROW_SIZE),
			[Roact.Event.InputBegan] = self.handleInputBegan,
			[Roact.Event.InputEnded] = self.handleInputEnded,
		})
	end)
end

function ArrowNav:willUnmount()
	self.disconnectHoldConn()
	if self.motor then
		self.motor:destroy()
		self.motor = nil
	end
end

return ArrowNav