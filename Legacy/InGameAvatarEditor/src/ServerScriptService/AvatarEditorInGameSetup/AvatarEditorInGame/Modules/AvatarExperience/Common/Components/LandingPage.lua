
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Otter = require(Modules.Packages.Otter)
local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local AppPage = require(Modules.NotLApp.AppPage)
local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)
local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)
local RoactServices = require(Modules.Common.RoactServices)

local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local AvatarExperienceView = require(Modules.AvatarExperience.Common.Components.AvatarExperienceView)
local AvatarPageButton = require(Modules.AvatarExperience.Common.Components.Landing.AvatarPageButton)
local CatalogPageButton = require(Modules.AvatarExperience.Common.Components.Landing.CatalogPageButton)
local TopBar = require(Modules.LuaApp.Components.TopBar)

local AvatarSetCategoryAndSubcategory = require(Modules.AvatarExperience.AvatarEditor.Thunks.SetCategoryAndSubcategory)
local CatalogSetCategoryAndSubcategory = require(Modules.AvatarExperience.Catalog.Thunks.SetCategoryAndSubcategory)

local SpringAnimatedItem = UIBlox.Utility.SpringAnimatedItem

local ANIMATION_SPRING_SETTINGS = {
	dampingRatio = 0.8,
	frequency = 4,
}

local BUTTON_DELAY = 0.08
local TRANSITION_TIME = 0.2

local PORTRAIT_BUTTON_HEIGHT = 0.8
local PORTRAIT_BUTTON_PADDING = 52

local LANDSCAPE_BUTTON_HEIGHT = 0.5
local LANDSCAPE_BUTTON_PADDING = 48

local OTTER_FREQUENCY = 3

local AvatarExperienceLandingPage = Roact.PureComponent:extend("AvatarExperienceLandingPage")

local function mapValuesToPropsLeft(values)
	local padding = PORTRAIT_BUTTON_PADDING / 4

	return {
		Position = UDim2.new(0.5, -padding, values.yPosition, 0),
	}
end

local function mapValuesToPropsRight(values)
	local padding = PORTRAIT_BUTTON_PADDING / 4

	return {
		Position = UDim2.new(0.5, padding, values.yPosition, 0),
	}
end

function AvatarExperienceLandingPage:init()
	self.state = {
		buttonsOffscreen = false,
		buttonTransparencyModifier = 0,

		delayAvatar = false,
		delayCatalog = false,
	}

	self.showAvatarEditorCallback = function()
		self:setState({
			buttonsOffscreen = true,
			delayCatalog = true,
		})

		delay(BUTTON_DELAY, function()
			self:setState({
				delayCatalog = false,
			})
		end)

		if self.motor then
			self.motor:setGoal(Otter.spring(1), {
				frequency = OTTER_FREQUENCY,
			})
		end

		delay(TRANSITION_TIME, function()
			self.props.openAvatarEditorPage()
		end)
	end

	self.showCatalogCallback = function()
		self:setState({
			buttonsOffscreen = true,
			delayAvatar = true,
		})

		delay(BUTTON_DELAY, function()
			self:setState({
				delayAvatar = false,
			})
		end)

		if self.motor then
			self.motor:setGoal(Otter.spring(1), {
				frequency = OTTER_FREQUENCY,
			})
		end

		delay(TRANSITION_TIME, function()
			self.props.openCatalogPage()
		end)
	end

	self.transitionOnscreen = function()
		self:setState({
			buttonsOffscreen = false,
		})

		if self.motor then
			self.motor:setGoal(Otter.spring(0), {
				frequency = OTTER_FREQUENCY,
			})
		end
	end
end

function AvatarExperienceLandingPage:renderTopBar()
	return Roact.createElement(TopBar, {
		showNotifications = true,
		showCatalogButton = false,
		showBackButton = false,
		showSearch = false,
		textKey = "CommonUI.Features.Label.Avatar",
		transparentBackground = true,
	})
end

function AvatarExperienceLandingPage:render()
	local buttonsOffscreen = self.state.buttonsOffscreen
	local delayAvatar = self.state.delayAvatar
	local delayCatalog = self.state.delayCatalog
	local deviceOrientation = self.props.deviceOrientation

	local isPortrait = deviceOrientation == DeviceOrientationMode.Portrait

	local buttonHeight = isPortrait and PORTRAIT_BUTTON_HEIGHT or LANDSCAPE_BUTTON_HEIGHT
	local buttonPadding = isPortrait and PORTRAIT_BUTTON_PADDING or LANDSCAPE_BUTTON_PADDING
	local verticalPadding = (1 - buttonHeight) / 2

	return Roact.createElement(AvatarExperienceView, {
		topBar = self:renderTopBar(),
		bottomBarEnabled = true,
		isFullView = false,
		isUIFullView = false,
		isLandingPage = true,
	}, {
		Buttons = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
		}, {
			LeftFrame = Roact.createElement(SpringAnimatedItem.AnimatedFrame, {
				regularProps = {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					Size = UDim2.new(0.5, -buttonPadding * 3 / 4, buttonHeight, 0),
				},

				animatedValues = {
					xPosition = (buttonsOffscreen and not delayAvatar) and 0 or 0.5,
					yPosition = (buttonsOffscreen and not delayAvatar) and 1.5 - verticalPadding or 0.5,
				},

				mapValuesToProps = mapValuesToPropsLeft,
				springOptions = ANIMATION_SPRING_SETTINGS,
			}, {
				AvatarPageButton = Roact.createElement(AvatarPageButton, {
					onActivated = self.showAvatarEditorCallback,
					transparencyModifier = self.state.buttonTransparencyModifier,
				}),
			}),

			RightFrame = Roact.createElement(SpringAnimatedItem.AnimatedFrame, {
				regularProps = {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					Size = UDim2.new(0.5, -buttonPadding * 3 / 4, buttonHeight, 0),
				},

				animatedValues = {
					xPosition = (buttonsOffscreen and not delayCatalog) and 1 or 0.5,
					yPosition = (buttonsOffscreen and not delayCatalog) and 1.5 - verticalPadding or 0.5,
				},

				mapValuesToProps = mapValuesToPropsRight,
				springOptions = ANIMATION_SPRING_SETTINGS,
			}, {
				CatalogPageButton = Roact.createElement(CatalogPageButton, {
					onActivated = self.showCatalogCallback,
					transparencyModifier = self.state.buttonTransparencyModifier,
				}),
			}),
		}),
	})
end

function AvatarExperienceLandingPage:didMount()
	self.motor = Otter.createSingleMotor(self.state.buttonTransparencyModifier)
	self.motor:onStep(function(newTransparency)
		self:setState({
			buttonTransparencyModifier = newTransparency,
		})
	end)
end

function AvatarExperienceLandingPage:willUnmount()
	if self.motor then
		self.motor:destroy()
	end
end

function AvatarExperienceLandingPage:didUpdate(oldProps)
	local avatarCategory = self.props.avatarCategory
	local avatarSubcategory = self.props.avatarSubcategory
	local catalogCategory = self.props.catalogCategory
	local catalogSubcategory = self.props.catalogSubcategory
	local page = self.props.page
	local oldPage = oldProps.page

	if page == AppPage.AvatarExperienceLandingPage then
		if avatarCategory ~= 1 or avatarSubcategory ~= 1 then
			self.props.resetAvatarCategories()
		elseif catalogCategory ~= 1 or catalogSubcategory ~= 1 then
			self.props.resetCatalogCategories()
		end

		if oldPage ~= page then
			self.transitionOnscreen()
		end
	end
end

local function mapStateToProps(state)
	return {
		avatarCategory = state.AvatarExperience.AvatarEditor.Categories.category,
		avatarSubcategory = state.AvatarExperience.AvatarEditor.Categories.subcategory,
		catalogCategory = state.AvatarExperience.Catalog.Categories.category,
		catalogSubcategory = state.AvatarExperience.Catalog.Categories.subcategory,
		deviceOrientation = state.DeviceOrientation,
		page = AvatarExperienceUtils.getCurrentPage(state),
		topBarHeight = state.TopBar.topBarHeight,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		openAvatarEditorPage = function()
			return dispatch(NavigateDown({ name = AppPage.AvatarEditor }))
		end,

		openCatalogPage = function()
			return dispatch(NavigateDown({ name = AppPage.Catalog }))
		end,

		resetAvatarCategories = function()
			dispatch(AvatarSetCategoryAndSubcategory(1, nil))
		end,

		resetCatalogCategories = function()
			dispatch(CatalogSetCategoryAndSubcategory(1, nil))
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(AvatarExperienceLandingPage)
