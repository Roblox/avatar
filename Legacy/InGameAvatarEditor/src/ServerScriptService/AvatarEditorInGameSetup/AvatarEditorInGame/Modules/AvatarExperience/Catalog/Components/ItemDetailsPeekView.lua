local Modules = script:FindFirstAncestorOfClass("ScreenGui").Modules
local GuiService = game:GetService("GuiService")

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)
local Images = UIBlox.App.ImageSet.Images
local UIBloxImageSetButton = UIBlox.Core.ImageSet.Button
local UIBloxImageSetLabel = UIBlox.Core.ImageSet.Label

local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local BuyActionBar = require(Modules.AvatarExperience.Catalog.Components.ActionBar.BuyActionBar)
local CatalogUtils = require(Modules.AvatarExperience.Catalog.CatalogUtils)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local InputType = require(Modules.Setup.InputType)
local ItemDetailsContainer = require(Modules.AvatarExperience.Catalog.Components.ItemDetails.ItemDetailsContainer)
local PeekViewTopBar = require(Modules.AvatarExperience.Catalog.Components.PeekViewTopBar)


local ToastType = require(Modules.NotLApp.Enum.ToastType)

local AppPage = require(Modules.NotLApp.AppPage)

local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)
local PeekView = require(Modules.NotLApp.PeekView)
local PeekViewState = require(Modules.NotLApp.PeekViewState)
local withStyle = UIBlox.Style.withStyle

local ShimmerPanel = UIBlox.Loading.ShimmerPanel
local UIBloxImages = UIBlox.App.ImageSet.Images
local UIBloxIconSize = UIBlox.App.Constant.IconSize
local PremiumIconSmall = UIBloxImages["icons/status/premium_small"]

local FFlagAvatarExperiencePeekHeaderUpdate
	= true

local ClearSelectedItem = require(Modules.AvatarExperience.Common.Actions.ClearSelectedItem)

local CloseAllItemDetails = require(Modules.AvatarExperience.Catalog.Thunks.CloseAllItemDetails)

local ItemDataSelector = require(Modules.AvatarExperience.Common.Selectors.ItemData)
local SetCurrentToastMessage = require(Modules.NotLApp.Actions.SetCurrentToastMessage)
local SetItemDetailsExpanded = require(Modules.AvatarExperience.Common.Actions.SetItemDetailsExpanded)

--local PremiumBar = require(Modules.AvatarExperience.Catalog.Components.ActionBar.PremiumBar)

local TOP_BAR_VISIBILITY_PERCENT = 0.8
local CLOSE_BUTTON_VISIBILITY_PERCENT = 0.95

local ACTION_FRAME_PADDING = 20
local ACTION_BAR_HEADER_PADDING = 5
local ACTION_BAR_PADDING = 24
local PEEK_HEADER_HEIGHT = 25
local CLOSE_BUTTON_SIZE = 36
local CLOSE_BUTTON_PADDING_H = 15
local CLOSE_BUTTON_PADDING_V = 4
local CLOSE_BUTTON_IMAGE = Images["icons/navigation/close"]

local INVALID_ITEM_TOAST = {
	toastMessage = "Feature.Avatar.Message.InvalidItem",
	isLocalized = false,
	toastType = ToastType.InformationMessage,
}

local IS_CONSOLE = GuiService:IsTenFootInterface()

local ItemDetailsPeekView = Roact.PureComponent:extend("ItemDetailsPeekView")

function ItemDetailsPeekView:init()
	self.contentFrameRef = Roact.createRef()
	self.actionBarContainerRef = Roact.createRef()
	self.actionBarHeaderRef = Roact.createRef()
	self.backButtonRef = Roact.createRef()
	self.closeButtonPosition, self.updateCloseButtonPosition = Roact.createBinding(UDim2.new(0, 0, 0, 0))
	self.closeButtonVisible, self.updateCloseButtonVisible = Roact.createBinding(false)
	self.topBarNavVisible, self.updateTopBarNavVisible = Roact.createBinding(false)

	local mountAsFullView = self.props.mountAsFullView

	self.state = {
		peekViewState = mountAsFullView and PeekViewState.Full or PeekViewState.Hidden,
	}

	local initalBriefViewPercent = mountAsFullView and 1 or 0
	self.briefViewPercentBinding, self.updateBriefViewPercentBinding = Roact.createBinding(initalBriefViewPercent)

	self.scrollingEnabledBinding = self.briefViewPercentBinding:map(function(percentage)
		return percentage == 1
	end)


	self.peekViewStateChanged = function(viewState, prevViewState)
		self:setState({
			peekViewState = viewState,
		})

		if viewState == PeekViewState.Closed or viewState == PeekViewState.Hidden then
			self.props.clearSelectedItem()
			self.props.closeAllItemDetails()
		end
	end

	self.briefToFullTransitionPercent = function(percentage)
		if FFlagAvatarExperiencePeekHeaderUpdate then
			if percentage > TOP_BAR_VISIBILITY_PERCENT then
				self.updateTopBarNavVisible(true)
			else
				self.updateTopBarNavVisible(false)
			end
			if percentage > CLOSE_BUTTON_VISIBILITY_PERCENT then
				self.updateCloseButtonVisible(false)
			else
				self.updateCloseButtonVisible(true)
			end
		end

		self.updateBriefViewPercentBinding(percentage)
	end

	self.closeBriefView = function()
		self.props.clearSelectedItem()
		self.props.closeAllItemDetails()
	end

	self.peekHeaderPositionYChange = function(scrollY)
		local isPortrait = self.props.deviceOrientation == DeviceOrientationMode.Portrait
		local peekViewPosScale = not isPortrait and AvatarExperienceConstants.LandscapeNavWidth or 0
		local yOffset = -(math.floor(scrollY + 0.5) + CLOSE_BUTTON_SIZE/2 + CLOSE_BUTTON_PADDING_V)
		self.updateCloseButtonPosition(UDim2.new(peekViewPosScale, CLOSE_BUTTON_PADDING_H, 1, yOffset))
	end

	self.getBriefViewHeight = function()
		local itemInfo = self.props.itemInfo
		--local isPlayerPremium = self.props.playerMembership == Enum.MembershipType.Premium
		--local hasPremiumBenefit = CatalogUtils.HasPremiumBenefits(itemInfo)
		--local isPremiumExclusive = CatalogUtils.IsPremiumExclusive(itemInfo)

		local gamepadBottomBarHeight = 0
		local actionBarHeight = CatalogConstants.ActionBar.ActionBarHeight
			+ CatalogConstants.ActionBar.ActionBarGradientHeight + gamepadBottomBarHeight

		--[[
		if hasPremiumBenefit then
			actionBarHeight = actionBarHeight + PremiumBar:getPremiumBarHeight(isPremiumExclusive, isPlayerPremium)
		end
		--]]
		return actionBarHeight + ACTION_FRAME_PADDING
	end

	self.onItemInvalid = function()
		if self.isMounted then
			self.closeBriefView()
			self.props.setCurrentToastMessage(INVALID_ITEM_TOAST)
		end
	end

	self.onOverlayClosed = function()
		if self.props.currentPage.name == AppPage.ItemDetails then
			self.focusController.captureFocus()
		end
	end

	self.onFocusChanged = function(focused)
		self:setState({
			focused = focused,
		})
	end
end

function ItemDetailsPeekView:renderActionBar(stylePalette, actionBarContainerHeight)
	local itemId = self.props.itemId
	local itemType = self.props.itemType
	local itemInfo = self.props.itemInfo

	local theme = stylePalette.Theme
	local font = stylePalette.Font
	local headerTextSize = font.BaseSize * font.Header1.RelativeSize
	local hasPremiumBenefit = false and CatalogUtils.HasPremiumBenefits(itemInfo)

	local headerText = itemInfo and itemInfo.name
	local nameTextSize = headerTextSize
	local nameTextFont = font.Header1.Font
	local premiumIconSize = UIBloxIconSize.Small
	if hasPremiumBenefit then
		headerText = CatalogUtils.GetWrappedTextWithIcon(headerText, nameTextSize, nameTextFont, premiumIconSize,
			CatalogConstants.PremiumIconPadding)
	end

	local frameComponent = "Frame"

	return {
		ActionBarContainer = Roact.createElement(frameComponent, {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, actionBarContainerHeight),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 3,
			[Roact.Ref] = self.actionBarContainerRef,
			NextSelectionUp = self.contentFrameRef,
		}, {
			ActionBar = Roact.createElement(BuyActionBar, {
				showMorePage = true,
				itemId = itemId,
				itemType = itemType,

				headerPadding = ACTION_BAR_PADDING,
				leftPadding = ACTION_FRAME_PADDING,
				bottomPadding = ACTION_FRAME_PADDING,
				rightPadding = ACTION_FRAME_PADDING,
				ZIndex = 1,
			}),

			ActionBarHeader = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -ACTION_BAR_PADDING*2, 0, headerTextSize),
				Position = UDim2.new(0, ACTION_BAR_PADDING, 0, ACTION_BAR_HEADER_PADDING),
				ZIndex = 2,

				[Roact.Ref] = self.actionBarHeaderRef,
			}, {
				PremiumIcon = hasPremiumBenefit and Roact.createElement(UIBloxImageSetLabel, {
					Position = UDim2.new(0, 0, 0, 4),
					Size = UDim2.new(0, UIBloxIconSize.Small, 0, UIBloxIconSize.Small),
					ScaleType = Enum.ScaleType.Fit,
					Image = PremiumIconSmall,
					ImageColor3 = theme.IconEmphasis.Color,
					ImageTransparency = theme.IconEmphasis.Transparency,
					BackgroundTransparency = 1,
				}) or nil,
				NameLabel = headerText and Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					Font = nameTextFont,
					Size = UDim2.new(1, 0, 0, headerTextSize),
					Text = headerText,
					TextSize = nameTextSize,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.TextEmphasis.Color,
					TextTruncate = Enum.TextTruncate.AtEnd,
				}) or Roact.createElement(ShimmerPanel, {
					Size = UDim2.new(1, 0, 0, nameTextSize)
				}),
			})
		}),
	}
end

function ItemDetailsPeekView:render()
	local deviceOrientation = self.props.deviceOrientation
	local fullView = self.props.fullView
	local itemId = self.props.itemId
	local itemType = self.props.itemType
	local mountAnimation = self.props.mountAnimation
	local mountAsFullView = self.props.mountAsFullView
	local topBarHeight = self.props.topBarHeight
	local detail = self.props.detail
	--local itemDetailsPeekViewState = self.props.itemDetailsPeekViewState

	local isMouseAndKeyboard = self.props.lastInputGroup == InputType.MouseAndKeyboard

	if not itemId then
		return
	end

	local peekViewState = self.state.peekViewState
	local showTopBar = peekViewState == PeekViewState.Full or peekViewState == PeekViewState.Extended
	if FFlagAvatarExperiencePeekHeaderUpdate and isMouseAndKeyboard then
		showTopBar = true
	end
	local showCloseButton = FFlagAvatarExperiencePeekHeaderUpdate and isMouseAndKeyboard
	local isPortrait = deviceOrientation == DeviceOrientationMode.Portrait

	local peekViewPosition  = UDim2.new(0, 0, 0, topBarHeight)
	local peekViewSize = UDim2.new(1, 0, 1, -topBarHeight)
	if not isPortrait then
		peekViewPosition = UDim2.new(AvatarExperienceConstants.LandscapeNavWidth, 0, 0, topBarHeight)
		peekViewSize = UDim2.new(AvatarExperienceConstants.LandscapeSceneWidth, 0, 1, -topBarHeight)
	end

	local briefViewHeight = self.getBriefViewHeight()
	local isScrollingEnabled = self.scrollingEnabledBinding

	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		local overlayTransparency = self.briefViewPercentBinding:map(function(percentage)
			local overlayOpacity = 1 - theme.Overlay.Transparency
			return 1 - (overlayOpacity * percentage)
		end)

		local frameComponent = "Frame"

		return Roact.createElement(frameComponent, {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Visible = not fullView,
			NextSelectionLeft = self.props.resultsListRef,
		}, {
			Overlay = Roact.createElement("Frame", {
				BackgroundTransparency = overlayTransparency,
				BackgroundColor3 = theme.Overlay.Color,
				BorderSizePixel = 0,
				Position = UDim2.new(peekViewPosition.X.Scale, 0, 0, 0),
				Size = UDim2.new(peekViewSize.X.Scale, peekViewSize.X.Offset,
					peekViewSize.Y.Scale, peekViewSize.Y.Offset + topBarHeight),
				ZIndex = 1,
			}),

			TopBarContainer = showTopBar and Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.new(peekViewPosition.X.Scale, 0, 0, 0),
				Size = UDim2.new(peekViewSize.X.Scale, peekViewSize.X.Offset, 0, topBarHeight),
				ZIndex = 2,
				Visible = (not FFlagAvatarExperiencePeekHeaderUpdate) or self.topBarNavVisible,
			}, {
				TopBar = Roact.createElement(PeekViewTopBar, {
					[Roact.Ref] = self.backButtonRef,
					NextSelectionDown = self.contentFrameRef,
				}),
			}),

			CloseButton = showCloseButton and Roact.createElement(UIBloxImageSetButton, {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = self.closeButtonPosition,
				Size = UDim2.new(0, CLOSE_BUTTON_SIZE, 0, CLOSE_BUTTON_SIZE),
				Image = CLOSE_BUTTON_IMAGE,
				ImageColor3 = theme.SystemPrimaryDefault.Color,
				Visible = self.closeButtonVisible,
				[Roact.Event.Activated] = self.closeBriefView,

			}),

			PeekViewContainer = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				Position = peekViewPosition,
				Size = peekViewSize,
				ZIndex = 2,
			}, {
				PeekView = Roact.createElement(PeekView, {
					briefViewContentHeight = UDim.new(0, briefViewHeight),
					viewStateChanged = self.peekViewStateChanged,
					mountAnimation = mountAnimation,
					mountAsFullView = mountAsFullView,
					canDragFullViewToBrief = true,
					showDraggerInClosedState = false,
					returnToFullView = true,

					bottomDockedContainerHeight = briefViewHeight,
					bottomDockedContainerContent = self:renderActionBar(stylePalette, briefViewHeight),

					backgroundColor3 = theme.BackgroundDefault.Color,
					backgroundTransparency = theme.BackgroundUIDefault.Transparency,
					briefToFullTransitionPercent = self.briefToFullTransitionPercent,
					peekHeaderClose = false,
					peekHeaderPositionYChange = self.peekHeaderPositionYChange,
					isScrollingEnabled = not (FFlagAvatarExperiencePeekHeaderUpdate and isMouseAndKeyboard) or isScrollingEnabled,
					contentFrameRef = self.contentFrameRef,
					--peekViewState = self.props.itemDetailsPeekViewState,
				}, {
					ItemDetails = itemId and Roact.createElement(ItemDetailsContainer, {
							actionBarHeaderRef = self.actionBarHeaderRef,

							itemId = itemId,
							itemType = itemType,
							detail = detail,
							onItemInvalid = self.onItemInvalid,
							resultsListRef = self.props.resultsListRef,
							itemDetailsPeekViewRefs = self.props.itemDetailsPeekViewRefs,
							NextSelectionDown = self.actionBarContainerRef,
							NextSelectionUp = self.backButtonRef,
						})
				})
			}),
		})
	end)
end

local function isPeekViewExpanded(props, state)
	local viewState = state.peekViewState
	if viewState == PeekViewState.Full or viewState == PeekViewState.Extended then
		return true
	end

	return false
end

function ItemDetailsPeekView:didUpdate(prevProps, prevState)
	local currentPage = self.props.currentPage

	if self.props.peekViewShowing then
		local isPeekViewExpanded = isPeekViewExpanded(self.props, self.state)
		if self.props.itemDetailsExpanded ~= isPeekViewExpanded then
			self.props.setItemDetailsExpanded(isPeekViewExpanded)
		end
	elseif prevProps.peekViewShowing and currentPage.name ~= AppPage.ItemDetails then
		if self.props.itemDetailsExpanded then
			self.props.setItemDetailsExpanded(false)
		end
	end
end

function ItemDetailsPeekView:didMount()
	if FFlagAvatarExperiencePeekHeaderUpdate and not self.props.mountAnimation then
		--set initial position of close button in case there is no mountAnimation
		self.peekHeaderPositionYChange(self.getBriefViewHeight() + PEEK_HEADER_HEIGHT)
	end
	if self.props.peekViewShowing then
		local isPeekViewExpanded = isPeekViewExpanded(self.props, self.state)
		if self.props.itemDetailsExpanded ~= isPeekViewExpanded then
			self.props.setItemDetailsExpanded(isPeekViewExpanded)
		end
	end
	self.isMounted = true
end

function ItemDetailsPeekView:willUnmount()
	if self.props.peekViewShowing and self.props.itemDetailsExpanded then
		self.props.setItemDetailsExpanded(false)
	end
	self.isMounted = false
end

local function getTopPageFromHistory(routeHistory)
	local route = routeHistory[#routeHistory]
	return route[#route]
end

local function mapStateToProps(state, props)
	local itemId = props.itemId
	local itemType = props.itemType
	local itemInfo = ItemDataSelector(state.AvatarExperience.Common, itemId, itemType)

	local currentPage = getTopPageFromHistory(state.Navigation.history)
	local detail = props.detail

	return {
		currentPage = currentPage,
		currentRoute = state.Navigation.history[#state.Navigation.history],
		deviceOrientation = state.DeviceOrientation,
		fullView = AvatarExperienceUtils.getFullViewFromState(state),
		itemInfo = itemInfo,
		peekViewShowing = currentPage.detail == detail,
		topBarHeight = 36,
		selectedItem = state.AvatarExperience.AvatarScene.TryOn.SelectedItem,
		itemDetailsExpanded = state.AvatarExperience.Common.ItemDetailsExpanded,
		--playerMembership = state.Users[state.LocalUserId]
		--	and state.Users[state.LocalUserId].membership
		--	or Enum.MembershipType.None,
		lastInputGroup = state.LastInputType.lastInputGroup,
		--itemDetailsPeekViewState = state.AvatarExperience.Catalog.ItemDetailsPeekView.viewState,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		clearSelectedItem = function()
			dispatch(ClearSelectedItem())
		end,

		closeAllItemDetails = function()
			dispatch(CloseAllItemDetails())
		end,

		setItemDetailsExpanded = function(itemDetailsExpanded)
			dispatch(SetItemDetailsExpanded(itemDetailsExpanded))
		end,

		setCurrentToastMessage = function(message)
			dispatch(SetCurrentToastMessage(message))
		end,
	}
end

ItemDetailsPeekView = RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(ItemDetailsPeekView)

return ItemDetailsPeekView
