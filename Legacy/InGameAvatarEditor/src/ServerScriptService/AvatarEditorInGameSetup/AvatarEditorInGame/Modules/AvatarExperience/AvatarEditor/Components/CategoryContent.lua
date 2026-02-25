local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local AppPage = require(Modules.NotLApp.AppPage)
local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)
local RoactServices = require(Modules.Common.RoactServices)
local withStyle = UIBlox.Style.withStyle

local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local Categories = require(Modules.AvatarExperience.AvatarEditor.Categories)

local BodyColorsFrame = require(Modules.AvatarExperience.AvatarEditor.Components.BodyColorsFrame)
local EmotesPage = require(Modules.AvatarExperience.AvatarEditor.Components.EmotesPage)
local ItemsList = require(Modules.AvatarExperience.AvatarEditor.Components.ItemsList)
local ScalesPage = require(Modules.AvatarExperience.AvatarEditor.Components.ScalesPage)

local ToggleUIFullView = require(Modules.AvatarExperience.AvatarEditor.Thunks.ToggleUIFullView)

local CategoryContent = Roact.PureComponent:extend("CategoryContent")

function CategoryContent:init()
	self.connections = {}
	self.state = {
		enableNavigation = true,
	}

	self.isTouched = false
	self.ref = Roact.createRef()
	self.isUnmounted = false

	self.lockNavigationCallback = function()
		self:setState({
			enableNavigation = false,
		})
	end

	self.toggleUIFullView = function()
		self.props.toggleUIFullView()
	end

	self.unlockNavigationCallback = function()
		if self.isUnmounted then
			return
		end
		
		self:setState({
			enableNavigation = true,
		})
	end
end

function CategoryContent:renderWithStyle(stylePalette)
	local theme = stylePalette.Theme

	local categoryInfo = self.props.categoryInfo
	local isUIFullView = self.props.isUIFullView
	local isPortrait = self.props.deviceOrientation == DeviceOrientationMode.Portrait

	local listSize = self.props.size or UDim2.new(1, 0, 1, 0)

	local toRender
	if categoryInfo.PageType == AvatarExperienceConstants.PageType.Emotes then
		toRender = Roact.createElement(EmotesPage, {
			enableNavigation = self.state.enableNavigation,
			lockNavigationCallback = self.lockNavigationCallback,
			unlockNavigationCallback = self.unlockNavigationCallback,
			categoryInfo = categoryInfo,
		})

	elseif categoryInfo.PageType == AvatarExperienceConstants.PageType.BodyStyle then
		toRender = Roact.createElement(ScalesPage, {
			enableNavigation = self.state.enableNavigation,
			lockNavigationCallback = self.lockNavigationCallback,
			unlockNavigationCallback = self.unlockNavigationCallback,
		})

	elseif categoryInfo.PageType == AvatarExperienceConstants.PageType.BodyColors then
		toRender = Roact.createElement(BodyColorsFrame, {
			Size = listSize,
		})

	elseif categoryInfo.RenderItemTiles then
		toRender = Roact.createElement(ItemsList)
	end

	return Roact.createElement("Frame", {
		Active = true,
		Size = listSize,
		BorderSizePixel = 0,
		BackgroundColor3 = theme.BackgroundDefault.Color,
		BackgroundTransparency = theme.BackgroundDefault.Transparency,
		LayoutOrder = self.props.LayoutOrder,

		[Roact.Ref] = self.props.ref or self.ref,
	}, {
		PageContent = toRender,
	})
end

function CategoryContent:render()
	return withStyle(function(stylePalette)
		return self:renderWithStyle(stylePalette)
	end)
end

function CategoryContent:willUnmount()
	self:disconnectListeners()
	
	self.isUnmounted = true
end

function CategoryContent:disconnectListeners()
	for _, connection in ipairs(self.connections) do
		connection:disconnect()
	end

	self.connections = {}
	self.isTouched = false
end

function CategoryContent:didUpdate(previousProps, previousState)
	local newAppPage = self.props.appPage
	local oldAppPage = previousProps.appPage

	if newAppPage == AppPage.AvatarEditor and newAppPage ~= oldAppPage then
		local touchMovedConnection = UserInputService.TouchMoved:Connect(function(...) self:onTouchMoved(...) end)
		local touchSwipeConnection = UserInputService.TouchSwipe:Connect(function(...) self:onTouchSwipe(...) end)
		self.connections[#self.connections + 1] = touchMovedConnection
		self.connections[#self.connections + 1] = touchSwipeConnection
	elseif oldAppPage == AppPage.AvatarEditor and newAppPage ~= AppPage.AvatarEditor and newAppPage ~= oldAppPage then
		self:disconnectListeners()
	end
end

function CategoryContent:onTouchMoved(touch, gameProcessedEvent)
	self.isTouched = false

	local listFrame = self.props.ref and self.props.ref.current or self.ref.current
	if not listFrame or not self.state.enableNavigation then
		return
	end

	local absolutePosition = listFrame.AbsolutePosition
	local absoluteSize = listFrame.AbsoluteSize

	local farCorner = Vector2.new(absolutePosition.X + absoluteSize.X, absolutePosition.Y + absoluteSize.Y)

	if touch.Position.X > listFrame.AbsolutePosition.X and
		touch.Position.Y > listFrame.AbsolutePosition.Y and
		touch.Position.X < farCorner.X and
		touch.Position.Y < farCorner.Y then

		self.isTouched = true
	end
end

function CategoryContent:onTouchSwipe(direction, numberOfTouches, gameProcessedEvent)
	if not numberOfTouches == 1 then
		return
	end

	if not self.isTouched or not self.state.enableNavigation then
		return
	end

	if direction == Enum.SwipeDirection.Right then
		if self.props.navigateLeft then
			self.props.navigateLeft()
		end
	elseif direction == Enum.SwipeDirection.Left then
		if self.props.navigateRight then
			self.props.navigateRight()
		end
	end
end

local function mapStateToProps(state, props)
	local categoryIndex = state.AvatarExperience.AvatarEditor.Categories.category
	local subcategoryIndex = state.AvatarExperience.AvatarEditor.Categories.subcategory

	return {
		appPage = AvatarExperienceUtils.getCurrentPage(state),
		categoryInfo = AvatarExperienceUtils.GetCategoryInfo(Categories, categoryIndex, subcategoryIndex),

		deviceOrientation = state.DeviceOrientation,
		screenSize = state.ScreenSize,
		isUIFullView = state.AvatarExperience.AvatarEditor.UIFullView,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		toggleUIFullView = function()
			dispatch(ToggleUIFullView())
		end
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(CategoryContent)
