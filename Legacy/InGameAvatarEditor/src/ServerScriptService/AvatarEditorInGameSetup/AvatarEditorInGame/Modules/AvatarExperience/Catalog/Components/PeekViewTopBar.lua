local UserInputService = game:GetService("UserInputService")

local Modules = script:FindFirstAncestorOfClass("ScreenGui").Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local AppPage = require(Modules.NotLApp.AppPage)
local Images = UIBlox.App.ImageSet.Images
local withStyle = UIBlox.Style.withStyle
local ImageSetLabel = UIBlox.Core.ImageSet.Label

local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)

local InputType = require(Modules.Setup.InputType)

local FFlagAvatarExperiencePeekHeaderUpdate = true

local NAVIGATION_BUTTON_LEFT_PADDING = 15
local NAVIGATION_BUTTON_SIZE = 36
local NAVIGATION_ICON_SIZE = 36

local CLOSE_BUTTON_IMAGE = Images["icons/navigation/close"]
local BACK_BUTTON_IMAGE = Images["icons/navigation/pushBack"]

local TEXT_BUTTON_POSY_MOBILE = 0
local TEXT_BUTTON_POSY_DESKTOP = 0.5
local PeekViewTopBar = Roact.PureComponent:extend("PeekViewTopBar")


function PeekViewTopBar:render()
	local statusBarHeight = self.props.statusBarHeight
	local topBarHeight = self.props.topBarHeight
	local showCloseIcon = self.props.showCloseIcon
	local navigateBackOp = self.props.navigateBack
	
	local textButtonPosY = TEXT_BUTTON_POSY_MOBILE
	if self.props.lastInputGroup == InputType.MouseAndKeyboard then
		textButtonPosY = TEXT_BUTTON_POSY_DESKTOP
	end

	return withStyle(function(stylePalette)
		return Roact.createElement("Frame", {
			Active = true,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, topBarHeight),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
		}, {
			TouchFriendlyNavigationButton = Roact.createElement("TextButton", {
				AnchorPoint = Vector2.new(0, textButtonPosY),
				Position = UDim2.new(0, NAVIGATION_BUTTON_LEFT_PADDING, textButtonPosY, statusBarHeight),
				Size = UDim2.new(0, NAVIGATION_BUTTON_SIZE, 0, NAVIGATION_BUTTON_SIZE),
				BackgroundTransparency = 1,
				Text = "",
				[Roact.Event.Activated] = navigateBackOp,
			}, {
				CloseButton = showCloseIcon and Roact.createElement(ImageSetLabel, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, NAVIGATION_ICON_SIZE, 0, NAVIGATION_ICON_SIZE),
					Image = CLOSE_BUTTON_IMAGE,
					ImageColor3 = Color3.new(1, 1, 1),
				}),
				BackButton = not showCloseIcon and Roact.createElement(ImageSetLabel, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, NAVIGATION_ICON_SIZE, 0, NAVIGATION_ICON_SIZE),
					Image = BACK_BUTTON_IMAGE,
					ImageColor3 = Color3.new(1, 1, 1),
				}),
			}),
		})
	end)
end

local function selectShowCloseIcon(history)
	local currentRoute = history[#history]
	local numberOfItemDetailsPages = 0
	for index = 1, #currentRoute do
		if currentRoute[index].name == AppPage.ItemDetails then
			numberOfItemDetailsPages = numberOfItemDetailsPages + 1
			if numberOfItemDetailsPages > 1 then
				break
			end
		end
	end
	-- Show the close icon if there are 1 or fewer pages, to accommodate
	-- the case where the current page is not yet part of the route history.
	return numberOfItemDetailsPages <= 1
end

local function mapStateToProps(state)
	return {
		platform = state.Platform,
		topBarHeight = 36, --state.TopBar.topBarHeight,
		statusBarHeight = 0,
		showCloseIcon = selectShowCloseIcon(state.Navigation.history),
		lastInputGroup = state.LastInputType.lastInputGroup,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		navigateBack = function()
			--return dispatch(NavigateBack())
			return dispatch(NavigateDown({ name = AppPage.Catalog }))
		end,

		navigateBackUp = function()
			--return dispatch(NavigateBackUp())
			return dispatch(NavigateDown({ name = AppPage.Catalog }))
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(PeekViewTopBar)
