local Modules = script:FindFirstAncestorOfClass("ScreenGui").Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local RoactRodux = require(Modules.Packages.RoactRodux)
local RoactFitComponents = require(Modules.Packages.RoactFitComponents)

local withStyle = UIBlox.Style.withStyle
local SpringAnimatedItem = UIBlox.Utility.SpringAnimatedItem

local InputType = require(Modules.Setup.InputType)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local CategoryButton = require(Modules.AvatarExperience.Common.Components.NavBar.CategoryButton)
local GradientFrame = require(Modules.AvatarExperience.Common.Components.NavBar.GradientFrame)
local ArrowFrame = require(Modules.AvatarExperience.Common.Components.NavBar.ArrowFrame)
local NavHighlight = require(Modules.AvatarExperience.Common.Components.NavBar.NavHighlight)

local GetFFlagAvatarExperienceNavMouseSupport =
	function() return true end

local SubNavigation = Roact.PureComponent:extend("SubNavigation")

local BUTTON_PADDING = 15
local SIDE_PADDING = 10

local ANIMATION_SPRING_SETTINGS = {
	dampingRatio = 1,
	frequency = 3.5,
}

local function animatedFrameMapValuesToProps(values)
	return {
		Size = UDim2.new(1, 0, 0, values.height)
	}
end

function SubNavigation:init()
	self.gradientFrameRef = Roact.createRef()
	self.scrollingFrameRef = Roact.createRef()
	self.categoryButtonRefs = {}

	self.canvasPosition, self.updateCanvasPosition = Roact.createBinding(Vector2.new(0, 0))
	self.arrowLeftVisible, self.updateArrowLeftVisible = Roact.createBinding(false)
	self.arrowRightVisible, self.updateArrowRightVisible = Roact.createBinding(false)

	self.onCanvasPositionChange = function(rbx)
		self.checkShowGradient(rbx)
		--Update canvasPosition binding to avoid canvasPosition reset/jitter when
		--switching between touch & Mouse/Keyboard inputs
		self.updateCanvasPosition(rbx.CanvasPosition)
	end

	self.checkShowGradient = function(rbx)
		local gradientFrame = self.gradientFrameRef.current
		if not gradientFrame then
			return
		end

		local showGradient, showLeft, showRight = AvatarExperienceUtils.shouldShowGradientForScrollingFrame(rbx)
		gradientFrame.Visible = showGradient

		local left = gradientFrame:FindFirstChild("Left")
		local right = gradientFrame:FindFirstChild("Right")

		if left and right then
			left.Visible = showLeft
			right.Visible = showRight
		end

		if GetFFlagAvatarExperienceNavMouseSupport() and self.props.lastInputGroup == InputType.MouseAndKeyboard then
			self.updateArrowLeftVisible(showLeft)
			self.updateArrowRightVisible(showRight)
		end
	end

	self.onNavFrameSizeChanged = function(rbx)
		if self.scrollingFrameRef.current then
			self.scrollingFrameRef.current.CanvasSize = UDim2.new(0, rbx.AbsoluteSize.X, 1, 0)
		end
	end
end

function SubNavigation:getCategoryButtonRef(categoryIndex)
	if not self.categoryButtonRefs[categoryIndex] then
		self.categoryButtonRefs[categoryIndex] = Roact.createRef()
	end

	return self.categoryButtonRefs[categoryIndex]
end

function SubNavigation:didUpdate(oldProps)
	if GetFFlagAvatarExperienceNavMouseSupport() then
		--handle change in input to/from Mouse and Keyboard
		local oldInputMK = oldProps.lastInputGroup == InputType.MouseAndKeyboard
		local newInputMK = self.props.lastInputGroup == InputType.MouseAndKeyboard
		if oldInputMK ~= newInputMK then
			if newInputMK then --switching to Mouse and Keyboard
				local _, showLeft, showRight = AvatarExperienceUtils.shouldShowGradientForScrollingFrame(self.scrollingFrameRef.current)
				self.updateArrowLeftVisible(showLeft)
				self.updateArrowRightVisible(showRight)
			else --switching to other input (ex: Touch)
				self.updateArrowLeftVisible(false)
				self.updateArrowRightVisible(false)
			end
		end
	end
	self.props.update(oldProps, self.scrollingFrameRef)
end

function SubNavigation:render()
	local showArrowFrame = GetFFlagAvatarExperienceNavMouseSupport()
		and self.props.lastInputGroup == InputType.MouseAndKeyboard
	local showHighlight = true

	local layoutOrder = self.props.layoutOrder
	local navHeight = self.props.navHeight
	local categoryIndex = self.props.categoryIndex
	local subcategories = self.props.subcategories
	local subcategoryIndex = self.props.subcategoryIndex
	local selectSubcategory = self.props.selectSubcategory

	if not subcategories then
		navHeight = 0
	end

	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		local subNavFrameChildren = {}

		if subcategories then
			for subcatIndex, subcatInfo in ipairs(subcategories) do
				local isSelected = subcategoryIndex == subcatIndex
				subNavFrameChildren[subcatInfo.Name] = Roact.createElement(CategoryButton, {
					categoryTitle = subcatInfo.Title,
					layoutOrder = subcatIndex,
					isSelected = isSelected,
					ref = self:getCategoryButtonRef(subcatIndex),
					onActivate = function()
						selectSubcategory(categoryIndex, subcatIndex)
					end,
				})
			end
		end

		return Roact.createElement(SpringAnimatedItem.AnimatedFrame, {
			regularProps = {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, navHeight),
				BackgroundColor3 = theme.BackgroundContrast.Color,
				BackgroundTransparency = theme.BackgroundContrast.Transparency,
				BorderSizePixel = 0,
				LayoutOrder = layoutOrder,
			},
			animatedValues = {
				height = navHeight
			},
			mapValuesToProps = animatedFrameMapValuesToProps,
			springOptions = ANIMATION_SPRING_SETTINGS,
		}, {
			ScrollingList = Roact.createElement("ScrollingFrame", {
				Size = UDim2.new(1, 0, 1, 0),
				ScrollBarThickness = 0,
				BackgroundTransparency = 1,
				ZIndex = 2,
				CanvasPosition = GetFFlagAvatarExperienceNavMouseSupport() and self.canvasPosition or nil,
				ElasticBehavior = Enum.ElasticBehavior.Always,
				ScrollingDirection = Enum.ScrollingDirection.X,

				[Roact.Change.AbsoluteSize] = self.checkShowGradient,
				[Roact.Change.CanvasSize] = self.checkShowGradient,
				[Roact.Change.CanvasPosition] = GetFFlagAvatarExperienceNavMouseSupport() and self.onCanvasPositionChange
					or self.checkShowGradient,

				[Roact.Ref] = self.scrollingFrameRef,
			}, {
				SubNavFrame = Roact.createElement(RoactFitComponents.FitFrameHorizontal, {
					height = UDim.new(1, 0),
					contentPadding = UDim.new(0, BUTTON_PADDING),
					margin = RoactFitComponents.Rect.rectangle(SIDE_PADDING, 0),

					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,

					BackgroundTransparency = 1,

					[Roact.Change.AbsoluteSize] = self.onNavFrameSizeChanged,
				}, subNavFrameChildren),

				Highlight = showHighlight and Roact.createElement(NavHighlight, {
					categoryButtonRefs = self.categoryButtonRefs,
					scrollingFrameRef = self.scrollingFrameRef,
					selectedCategory = subcategoryIndex,
					categoryIndex = categoryIndex,
				}),
			}),

			GradientFrame = Roact.createElement(GradientFrame, {
				gradientStyle = theme.BackgroundMuted,
				navHeight = navHeight,
				ref = self.gradientFrameRef,
				ZIndex = 3,
			}),

			ArrowFrame = showArrowFrame and Roact.createElement(ArrowFrame, {
				isVisibleLeft = self.arrowLeftVisible,
				isVisibleRight = self.arrowRightVisible,
				defaultUseProps = {
					scrollingFrameRef = self.scrollingFrameRef,
					categoryButtonRefs = self.categoryButtonRefs,
					buttonPadding = BUTTON_PADDING,
					updateCanvasPosition = self.updateCanvasPosition,
				},
				ZIndex = 4,
			}),
		})
	end)
end

return RoactRodux.UNSTABLE_connect2(function(state, props)
	return {
		lastInputGroup = state.LastInputType.lastInputGroup,
	}
end, nil)(SubNavigation)