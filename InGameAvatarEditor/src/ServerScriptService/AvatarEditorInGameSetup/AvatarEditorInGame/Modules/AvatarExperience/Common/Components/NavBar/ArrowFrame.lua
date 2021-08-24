local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local t = require(Modules.Packages.t)

local ArrowNav = require(Modules.AvatarExperience.Common.Components.NavBar.ArrowNav)
local Constants = require(Modules.AvatarExperience.Common.Constants)
local Images = UIBlox.App.ImageSet.Images

local ARROW_LEFT_ICON = Images["icons/actions/cycleLeft"]
local ARROW_RIGHT_ICON = Images["icons/actions/cycleRight"]
local ARROW_SIZE = 36
local ARROW_PADDING = 6

local GetAENewNavigationEnabled = function() return false end
local FFlagAvatarExperienceNewNavigationEnabledForAll
	= false

local ArrowFrame = Roact.PureComponent:extend("ArrowFrame")

ArrowFrame.validateProps = not FFlagAvatarExperienceNewNavigationEnabledForAll and t.strictInterface({
	ZIndex = t.optional(t.number), -- Used to set the zindex of the entire component
	isVisibleLeft = t.optional(t.union(t.boolean, t.table)), --(boolean/RoactBinding) Determines whether the left Arrow button is visible
	isVisibleRight = t.optional(t.union(t.boolean, t.table)), --(boolean/RoactBinding) Determines whether the left Arrow button is visible
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

	scrollingFrameRef = t.optional(t.table), --(RoactRef) Reference to scrollingframe housing this component,
	categoryButtonRefs = t.optional(t.table), --(table of RoactRefs) table of references to the button contents within the scrollingframe,
	buttonPadding = t.optional(t.number), -- amount of padding between the buttons,

}) or t.strictInterface ({
	ZIndex = t.optional(t.number), -- Used to set the zindex of the entire component

	-- Booleans/RoactBindings to determine the visibility of the left and right arrows
	isVisibleLeft = t.optional(t.union(t.boolean, t.table)),
	isVisibleRight = t.optional(t.union(t.boolean, t.table)),

	onPressHoldInputBegan = t.optional(t.callback), -- Overrides default functionality for button press and hold began
	onPressHoldInputEnded = t.optional(t.callback), -- Overrides default functionality for button press and hold end

	--[[
		The following props are necessary for using the default functionality if not using
		onPressHoldInputBegan and onPressHoldInputEnded props for functionality
	--]]
	scrollingFrameRef = t.optional(t.table), --(RoactRef) Reference to scrollingframe housing this component,
	categoryButtonRefs = t.optional(t.table), --(table(RoactRef)) table of references to the category buttons,
	buttonPadding = t.optional(t.number), -- amount of padding between the buttons,
})

ArrowFrame.defaultProps = {
	ZIndex = 1,
	isVisibleRight = true,
	isVisibleLeft = true,
}

function ArrowFrame:init()
	self.state = {
		isHovered = false,
	}

	self.onMouseEnter = function()
		self:setState({
			isHovered = true,
		})
	end

	self.onMouseLeave = function()
		self:setState({
			isHovered = false,
		})
	end
end

function ArrowFrame:render()
	local isVisibleLeft = self.props.isVisibleLeft
	local isVisibleRight = self.props.isVisibleRight
	local defaultUseProps = self.props.defaultUseProps
	local onPressHoldInputBegan = self.props.onPressHoldInputBegan
	local onPressHoldInputEnded = self.props.onPressHoldInputEnded

	local scrollingFrameRef = self.props.scrollingFrameRef
	local categoryButtonRefs = self.props.categoryButtonRefs
	local buttonPadding = self.props.buttonPadding

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = self.props.ZIndex,
		[Roact.Event.MouseEnter] = self.onMouseEnter,
		[Roact.Event.MouseLeave] = self.onMouseLeave,
	}, {
		ArrowLeft = Roact.createElement(ArrowNav, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, -ARROW_PADDING, 0.5, 0),
			Image = ARROW_LEFT_ICON,
			Visible = self.state.isHovered and isVisibleLeft,
			navDirection = GetAENewNavigationEnabled() and Constants.NavigationDirection.Left
				or Constants.NavigationDirection.IS_LEFT,
			defaultUseProps = not GetAENewNavigationEnabled() and defaultUseProps or nil,
			onPressHoldInputBegan = onPressHoldInputBegan,
			onPressHoldInputEnded = onPressHoldInputEnded,
			-- The following are the default use props
			scrollingFrameRef = GetAENewNavigationEnabled() and scrollingFrameRef or nil,
			categoryButtonRefs = GetAENewNavigationEnabled() and categoryButtonRefs or nil,
			buttonPadding = GetAENewNavigationEnabled() and buttonPadding or nil,
		}),

		ArrowRight = Roact.createElement(ArrowNav, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(1, -ARROW_SIZE + ARROW_PADDING, 0.5, 0),
			Image = ARROW_RIGHT_ICON,
			Visible = self.state.isHovered and isVisibleRight,
			navDirection = GetAENewNavigationEnabled() and Constants.NavigationDirection.RIGHT
				or Constants.NavigationDirection.IS_RIGHT,
			defaultUseProps = not GetAENewNavigationEnabled() and defaultUseProps or nil,
			onPressHoldInputBegan = onPressHoldInputBegan,
			onPressHoldInputEnded = onPressHoldInputEnded,
			-- The following are the default use props
			scrollingFrameRef = GetAENewNavigationEnabled() and scrollingFrameRef or nil,
			categoryButtonRefs = GetAENewNavigationEnabled() and categoryButtonRefs or nil,
			buttonPadding = GetAENewNavigationEnabled() and buttonPadding or nil,
		})
	})
end

return ArrowFrame