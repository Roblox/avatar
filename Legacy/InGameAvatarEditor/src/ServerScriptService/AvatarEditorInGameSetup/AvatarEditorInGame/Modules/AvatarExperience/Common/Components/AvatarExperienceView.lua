local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local AppPage = require(Modules.NotLApp.AppPage)
local Constants = require(Modules.NotLApp.Constants)
local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)
local getSafeAreaSize = require(Modules.NotLApp.getSafeAreaSize)
local getScreenBottomInset = require(Modules.NotLApp.getScreenBottomInset)
local SpringAnimatedItem = UIBlox.Utility.SpringAnimatedItem
local withStyle = UIBlox.Style.withStyle

local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local FullViewButton = require(Modules.AvatarExperience.Common.Components.FullViewButton)

local FFlagAvatarCatalogCloseSearchWhenAvatarIsTapped = true

local ANIMATION_SPRING_SETTINGS = {
	dampingRatio = 1,
	frequency = 3.5,
}

local AvatarExperienceView = Roact.PureComponent:extend("AvatarExperienceView")

AvatarExperienceView.defaultProps = {
	bottomBarEnabled = false,
	isDisabled = false,
}

local function mapValuesToProps(values)
	return {
		Size = UDim2.new(0, values.width, 0, values.height),
	}
end

function AvatarExperienceView:init()
	self.state = {
		sceneShowing = true,
		isVerticallyOffscreen = false,
	}

	self.navItemsFrameRef = Roact.createRef()
	self.sceneFrameRef = Roact.createRef()

	self.onTransitionComplete = function()
		local currentPage = self.props.currentPage
		local isPortrait = self.props.isPortrait
		local isFullView = self.props.isFullView
		local isUIFullView = self.props.isUIFullView
		local sceneShowing = self.state.sceneShowing

		if isUIFullView and isPortrait and sceneShowing then
			self:setState({
				sceneShowing = false,
			})
		end

		if not isPortrait and isFullView and currentPage == AppPage.AvatarExperienceLandingPage then
			self:setState({
				isVerticallyOffscreen = true,
			})
		else
			self:setState({
				isVerticallyOffscreen = false,
			})
		end
	end

	self.onSceneResized = function(rbx)
		local navItemsFrame = self.navItemsFrameRef.current
		if not navItemsFrame then
			return
		end

		local currentPage = self.props.currentPage
		local isDisabled = self.props.isDisabled
		local isPortrait = self.props.isPortrait
		local screenSize = self.props.screenSize
		local topBarHeight = self.props.topBarHeight
		local landscapeVerticalMovement = self.state.isVerticallyOffscreen or
			currentPage == AppPage.AvatarExperienceLandingPage

		if isPortrait then
			navItemsFrame.Position = UDim2.new(0, 0, 0, rbx.AbsoluteSize.Y + topBarHeight)
			navItemsFrame.Size = UDim2.new(1, 0, 1, -rbx.AbsoluteSize.Y - topBarHeight)
		else
			local navItemsWidth = navItemsFrame.AbsoluteSize.X
			local spaceAvailable = screenSize.X - rbx.AbsoluteSize.X
			local xPosition = 0
			if spaceAvailable < navItemsWidth then
				xPosition = spaceAvailable - navItemsWidth
			end

			local desiredNavWidth = isDisabled and 1 or AvatarExperienceConstants.LandscapeNavWidth

			if landscapeVerticalMovement then
				navItemsFrame.Position = UDim2.new(0, 0, 0, screenSize.Y * (-xPosition / navItemsWidth))
			else
				navItemsFrame.Position = UDim2.new(0, xPosition, 0, 0)
			end
			navItemsFrame.Size = UDim2.new(desiredNavWidth, 0, 1, 0)
		end
	end
end

function AvatarExperienceView:instantResize()
	local sceneFrame = self.sceneFrameRef.current
	if not sceneFrame then
		return
	end

	local height, width = self:calculateSceneSize()
	sceneFrame.Size = UDim2.new(0, width, 0, height)

	self.onSceneResized(sceneFrame)
end

function AvatarExperienceView:calculateSceneSize()
	local bottomBarEnabled = self.props.bottomBarEnabled
	local globalGuiInset = self.props.globalGuiInset
	local isDisabled = self.props.isDisabled
	local isFullView = self.props.isFullView
	local isPortrait = self.props.isPortrait
	local isUIFullView = self.props.isUIFullView
	local screenSize = self.props.screenSize
	local topBarHeight = self.props.topBarHeight
	local isLandingPage = false

	--[[
		Catalog does not have the UniversalBottomBar. This means globalGuiInset.bottom is different
		between Editor and Catalog. The navigational components should be the same height, so we
		manually calculate the bottom inset and include the bottom bar height.
	]]
	local bottomInset = getScreenBottomInset()
	local totalBottomBarHeight = Constants.BOTTOM_BAR_SIZE + bottomInset
	local safeAreaHeight = screenSize.Y - globalGuiInset.top - totalBottomBarHeight

	local bottomBarHeightOffset = bottomBarEnabled and totalBottomBarHeight or bottomInset
	local topBarHeightOffset = isPortrait and topBarHeight or 0

	local landscapeSceneHeight = screenSize.Y - bottomBarHeightOffset
	local landscapeSceneWidth = screenSize.X * AvatarExperienceConstants.LandscapeSceneWidth

	local portraitSceneHeight = safeAreaHeight * AvatarExperienceConstants.PortraitSceneHeight
	if isLandingPage then
		portraitSceneHeight = safeAreaHeight * AvatarExperienceConstants.LandingPagePortraitSceneHeight
	end

	local height = isPortrait and portraitSceneHeight or landscapeSceneHeight
	local width = isPortrait and screenSize.X or landscapeSceneWidth

	if isUIFullView and isPortrait then
		height = 0
	elseif isFullView then
		width = screenSize.X
		height = screenSize.Y - bottomBarHeightOffset - topBarHeightOffset
	end

	if isDisabled then
		height = 0
		width = 0
	end

	return height, width
end

function AvatarExperienceView:renderSceneFrame()
	local isDisabled = self.props.isDisabled
	local isPortrait = self.props.isPortrait
	local topBarHeight = self.props.topBarHeight

	local height, width = self:calculateSceneSize()

	local sceneShowing = self.state.sceneShowing or not isPortrait
	if isDisabled then
		sceneShowing = false
	end

	return Roact.createElement(SpringAnimatedItem.AnimatedFrame, {
		regularProps = {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,

			Position = UDim2.new(1, 0, 0, isPortrait and topBarHeight or 0),

			[Roact.Change.AbsoluteSize] = self.onSceneResized,
			[Roact.Event.AncestryChanged] = self.onSceneResized,

			[Roact.Ref] = self.sceneFrameRef,
		},

		animatedValues = {
			height = height,
			width = width
		},

		mapValuesToProps = mapValuesToProps,
		springOptions = ANIMATION_SPRING_SETTINGS,

		onComplete = self.onTransitionComplete,
	})
end

function AvatarExperienceView:renderWithStyle(stylePalette)
	local theme = stylePalette.Theme

	local bottomBarEnabled = self.props.bottomBarEnabled
	local globalGuiInset = self.props.globalGuiInset
	local isPortrait = self.props.isPortrait
	local screenSize = self.props.screenSize
	local topBarHeight = self.props.topBarHeight

	local safeAreaSize = getSafeAreaSize(screenSize, globalGuiInset)
	safeAreaSize = UDim2.new(safeAreaSize.X.Scale, safeAreaSize.X.Offset,
		safeAreaSize.Y.Scale, safeAreaSize.Y.Offset)

	local needsBottomInsetBackground = not bottomBarEnabled and globalGuiInset.bottom > 0
	local sceneHeight = self:calculateSceneSize()

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, globalGuiInset.left, 0, globalGuiInset.top),
		Size = safeAreaSize,
	}, {
		TopBar = isPortrait and self.props.topBar,

		ItemsFrame = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			ZIndex = (FFlagAvatarCatalogCloseSearchWhenAvatarIsTapped and not isPortrait) and 2 or nil,

			[Roact.Ref] = self.navItemsFrameRef,
		}, {
			TopBar = not isPortrait and self.props.topBar,

			Items = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, 0, 1, isPortrait and 0 or -topBarHeight),
				ZIndex = 2,

				[Roact.Children] = self.props[Roact.Children],
			})
		}),

		SceneFrame = self:renderSceneFrame(),

		FullViewButton = true and Roact.createElement(FullViewButton, {
			sceneHeight = sceneHeight,
			isUIFullView = self.props.isUIFullView,
			isFullView = self.props.isFullView,
			changeViewFunction = self.props.changeViewFunction,
		}),

		-- Used for coloring bars on certain phones (like iPhone X) since the bottom bar BG is removed for Catalog
		BottomInsetBackground = needsBottomInsetBackground and Roact.createElement("Frame", {
			BackgroundColor3 = theme.BackgroundDefault.Color,
			BackgroundTransparency = theme.BackgroundDefault.Transparency,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, globalGuiInset.bottom),
			ZIndex = FFlagAvatarCatalogCloseSearchWhenAvatarIsTapped and 3 or  2,
		}),
	})
end

function AvatarExperienceView:render()
	return withStyle(function(stylePalette)
		return self:renderWithStyle(stylePalette)
	end)
end

function AvatarExperienceView:didUpdate(oldProps)
	local isUIFullView = self.props.isUIFullView
	local sceneShowing = self.state.sceneShowing
	if not isUIFullView and not sceneShowing then
		self:setState({
			sceneShowing = true,
		})
	end

	local oldIsPortrait = oldProps.isPortrait
	local isPortrait = self.props.isPortrait

	if isPortrait ~= oldIsPortrait then
		if isPortrait and isUIFullView then
			self:setState({
				sceneShowing = false,
			})
		elseif not oldIsPortrait and isUIFullView then
			self:setState({
				sceneShowing = true,
			})
		end

		self:instantResize()
	end

	local isDisabled = self.props.isDisabled
	if isDisabled then
		self:instantResize()
	end

	local screenSize = self.props.screenSize
	local prevScreenSize = oldProps.screenSize
	if screenSize ~= prevScreenSize then
		self:instantResize()
	end
end

function AvatarExperienceView:didMount()
	self:instantResize()
end

local function mapStateToProps(state, props)
	local deviceOrientation = state.DeviceOrientation
	local isPortrait = deviceOrientation == DeviceOrientationMode.Portrait

	return {
		currentPage = AvatarExperienceUtils.getCurrentPage(state),
		globalGuiInset = state.GlobalGuiInset,
		isPortrait = isPortrait,
		screenSize = state.ScreenSize,
		topBarHeight = 36,--props.topBar and state.TopBar.topBarHeight or 0,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, nil)(AvatarExperienceView)
