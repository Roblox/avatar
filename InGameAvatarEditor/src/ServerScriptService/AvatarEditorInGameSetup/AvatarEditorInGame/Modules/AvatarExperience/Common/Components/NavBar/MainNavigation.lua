local Modules = script:FindFirstAncestorOfClass("ScreenGui").Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local RoactRodux = require(Modules.Packages.RoactRodux)
local RoactFitComponents = require(Modules.Packages.RoactFitComponents)

local FitChildren = require(Modules.NotLApp.FitChildren)


local Images = UIBlox.App.ImageSet.Images

local withStyle = UIBlox.Style.withStyle
local ImageSetLabel = UIBlox.Core.ImageSet.Label

local InputType = require(Modules.Setup.InputType)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local CategoryButton = require(Modules.AvatarExperience.Common.Components.NavBar.CategoryButton)
local GradientFrame = require(Modules.AvatarExperience.Common.Components.NavBar.GradientFrame)
local ArrowFrame = require(Modules.AvatarExperience.Common.Components.NavBar.ArrowFrame)
local NavHighlight = require(Modules.AvatarExperience.Common.Components.NavBar.NavHighlight)

local GetFFlagAvatarExperienceNavMouseSupport =
	function() return true end

local BACKGROUND_CORNER_HEIGHT = 20

local BUTTON_FILL = Images["component_assets/circle_17"]

local MainNavigation = Roact.PureComponent:extend("MainNavigation")

MainNavigation.defaultProps = {
	showRoundedCorners = false,
}

function MainNavigation:init()
	self.gradientFrameRef = Roact.createRef()
	self.scrollingFrameRef = Roact.createRef()
	self.categoryButtonRefs = {}

	self.arrowLeftVisible, self.updateArrowLeftVisible = Roact.createBinding(false)
	self.arrowRightVisible, self.updateArrowRightVisible = Roact.createBinding(false)
	self.canvasPosition, self.updateCanvasPosition = Roact.createBinding(Vector2.new(0, 0))

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

		if GetFFlagAvatarExperienceNavMouseSupport() and
			self.props.lastInputGroup == InputType.MouseAndKeyboard then
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

function MainNavigation:getCategoryButtonRef(categoryIndex)
	if not self.categoryButtonRefs[categoryIndex] then
		self.categoryButtonRefs[categoryIndex] = Roact.createRef()
	end

	return self.categoryButtonRefs[categoryIndex]
end

function MainNavigation:didUpdate(oldProps)
	if GetFFlagAvatarExperienceNavMouseSupport() then
		-- handle change in input to/from Mouse and Keyboard
		local oldInputMK = oldProps.lastInputGroup == InputType.MouseAndKeyboard
		local newInputMK = self.props.lastInputGroup == InputType.MouseAndKeyboard
		if oldInputMK ~= newInputMK then
			if newInputMK then
				-- switching to Mouse and Keyboard
				local _, showLeft, showRight =
					AvatarExperienceUtils.shouldShowGradientForScrollingFrame(self.scrollingFrameRef.current)
				self.updateArrowLeftVisible(showLeft)
				self.updateArrowRightVisible(showRight)
			else
				-- switching to other input (ex: Touch)
				self.updateArrowLeftVisible(false)
				self.updateArrowRightVisible(false)
			end
		end
	end
end

function MainNavigation:render()
	local showArrowFrame = GetFFlagAvatarExperienceNavMouseSupport()
		and self.props.lastInputGroup == InputType.MouseAndKeyboard

	local layoutOrder = self.props.layoutOrder
	local navHeight = self.props.navHeight
	local categories = self.props.categories
	local zIndex = self.props.zIndex
	local categoryIndex = self.props.categoryIndex
	local selectCategory = self.props.selectCategory
	local subcategorySelected = self.props.subcategorySelected
	local showRoundedCorners = self.props.showRoundedCorners

	local showHighlight = true

	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		local navButtonsFrameChildren = {}

		for catIndex, catInfo in ipairs(categories) do
			local isSelected = categoryIndex == catIndex

			navButtonsFrameChildren[catInfo.Name] = Roact.createElement(CategoryButton, {
				categoryIndex = catIndex,
				categoryTitle = catInfo.Title,
				layoutOrder = catIndex,
				isSelected = isSelected,
				ref = self:getCategoryButtonRef(catIndex),
				onActivate = function()
					selectCategory(catIndex)
				end,
			})
		end

		return Roact.createElement("Frame", {
			ClipsDescendants = true,
			BackgroundTransparency = showRoundedCorners and 1 or theme.BackgroundDefault.Transparency,
			BackgroundColor3 = theme.BackgroundDefault.Color,
			BorderSizePixel = 0,
			LayoutOrder = layoutOrder,
			Size = UDim2.new(1, 0, 0, navHeight),
			ZIndex = zIndex,

			[Roact.Ref] = self.props[Roact.Ref],
			NextSelectionUp = self.props.NextSelectionUp,
			NextSelectionDown = self.props.NextSelectionDown,
		}, {
			Background = showRoundedCorners and Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 1,
			}, {
				Image = Roact.createElement(ImageSetLabel, {
					BackgroundTransparency = 1,
					ImageTransparency = theme.BackgroundDefault.Transparency,
					ImageColor3 = theme.BackgroundDefault.Color,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(9, 9, 9, 9),
					Image = BUTTON_FILL,

					Size = UDim2.new(1, 0, 1, BACKGROUND_CORNER_HEIGHT)
				}),
			}),

			ScrollingList = Roact.createElement("ScrollingFrame", {
				ClipsDescendants = false,
				Size = UDim2.new(1, 0, 1, 0),
				CanvasSize = UDim2.new(0, 0, 1, 0),
				CanvasPosition = GetFFlagAvatarExperienceNavMouseSupport() and self.canvasPosition or nil,
				ScrollBarThickness = 0,
				BackgroundTransparency = 1,
				ElasticBehavior = Enum.ElasticBehavior.Always,
				ScrollingDirection = Enum.ScrollingDirection.X,
				ZIndex = 2,

				[Roact.Change.AbsoluteSize] = self.checkShowGradient,
				[Roact.Change.CanvasSize] = self.checkShowGradient,
				[Roact.Change.CanvasPosition] = GetFFlagAvatarExperienceNavMouseSupport() and self.onCanvasPositionChange
					or self.checkShowGradient,

				[Roact.Ref] = self.scrollingFrameRef,
			}, {
				NavFrame = Roact.createElement(RoactFitComponents.FitFrameHorizontal, {
					height = UDim.new(1, 0),

					FillDirection = Enum.FillDirection.Horizontal,
					BackgroundTransparency = 1,

					[Roact.Change.AbsoluteSize] = self.onNavFrameSizeChanged,
				}, navButtonsFrameChildren),

				Highlight = showHighlight and
					Roact.createElement(NavHighlight, {
					categoryButtonRefs = self.categoryButtonRefs,
					scrollingFrameRef = self.scrollingFrameRef,
					selectedCategory = categoryIndex,
					useArrowHighlight = subcategorySelected,
				})
			}),

			GradientFrame = Roact.createElement(GradientFrame, {
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
					buttonPadding = 0,
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
end, nil)(MainNavigation)