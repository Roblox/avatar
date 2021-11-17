--[[
	Props:
		itemId (string)
		itemType (string)
]]
local Players = game:GetService("Players")
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)
local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)
local NavigateToRoute = require(Modules.NotLApp.Thunks.NavigateToRoute)
local AppPage = require(Modules.NotLApp.AppPage)
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local CatalogUtils = require(Modules.AvatarExperience.Catalog.CatalogUtils)
local GetAssetFavorite = require(Modules.AvatarExperience.Catalog.Thunks.GetAssetFavorite)
local SetAssetFavorite = require(Modules.AvatarExperience.Catalog.Thunks.SetAssetFavorite)
local GetBundleFavorite = require(Modules.AvatarExperience.Catalog.Thunks.GetBundleFavorite)
local SetBundleFavorite = require(Modules.AvatarExperience.Catalog.Thunks.SetBundleFavorite)
local ItemData = require(Modules.AvatarExperience.Common.Selectors.ItemData)

local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)
local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)
local CloseCentralOverlay = require(Modules.NotLApp.Thunks.CloseCentralOverlay)

local ContextualMenu = UIBlox.App.Menu.ContextualMenu
local MenuDirection = UIBlox.App.Menu.MenuDirection
local ModalBottomSheet = UIBlox.ModalBottomSheet
local Images = UIBlox.App.ImageSet.Images

local FAVORITE_ICON = Images["icons/actions/favoriteOff"]
local FAVORITED_ICON = Images["icons/actions/favoriteOn"]
local CUSTOMIZE_ICON = Images["icons/menu/customize"]

local ROBLOX_USER_ID = "1"
local BOTTOM_GAP = 76

local FFlagEnableAvatarExperienceLandingPage = false

local CatalogContextFrame = Roact.PureComponent:extend("CatalogContextFrame")

local function getIsFavorited(state, props)
	local isFavorited
	local itemId = props.itemId
	local itemType = props.itemType
	if itemType == CatalogConstants.ItemType.Asset then
		isFavorited = state.AvatarExperience.Catalog.AssetFavorites[itemId]
	elseif itemType == CatalogConstants.ItemType.Bundle then
		isFavorited = state.AvatarExperience.Catalog.BundleFavorites[itemId]
	end
	return isFavorited
end

local function getFavoritesFetchingState(state, props)
	local fetchingKey
	local itemId = props.itemId
	local itemType = props.itemType
	if itemType == CatalogConstants.ItemType.Asset then
		fetchingKey = CatalogConstants.SetFavoriteAssetKey
	elseif itemType == CatalogConstants.ItemType.Bundle then
		fetchingKey = CatalogConstants.SetFavoriteBundleKey
	end
	return PerformFetch.GetStatus(state, fetchingKey .. tostring(itemId))
end

function CatalogContextFrame:init()
	self.goToAvatarPage = function()
		if FFlagEnableAvatarExperienceLandingPage then
			self.props.navigateToRoute({
				{ name = AppPage.AvatarExperienceLandingPage },
				{ name = AppPage.AvatarEditor }
			})
		else
			self.props.navigateDown({ name = AppPage.AvatarEditor })
		end
		self.props.closePrompt()
	end

	self.favoriteItem = function()
		local isFavorited = self.props.isFavorited
		local isDisabled = isFavorited == nil or self.props.favoritesFetchingState == RetrievalStatus.Fetching
		if isDisabled then
			return
		end
		local itemId = self.props.itemId
		local itemType = self.props.itemType
		local userId = self.props.localUserId

		if itemType == CatalogConstants.ItemType.Asset then
			self.props.setAssetFavorite(userId, itemId, not isFavorited)
		elseif itemType == CatalogConstants.ItemType.Bundle then
			self.props.setBundleFavorite(userId, itemId, not isFavorited)
		end
	end
end

function CatalogContextFrame:didMount()
	local isFavorited = self.props.isFavorited
	if isFavorited == nil then
		local itemId = self.props.itemId
		local itemType = self.props.itemType
		local userId = self.props.localUserId

		if itemType == CatalogConstants.ItemType.Asset then
			self.props.getAssetFavorite(userId, itemId)
		elseif itemType == CatalogConstants.ItemType.Bundle then
			self.props.getBundleFavorite(userId, itemId)
		end
	end
end

function CatalogContextFrame:renderLocalized(localized)
	local itemType = self.props.itemType
	local itemInfo = self.props.itemInfo
	local isFavorited = self.props.isFavorited
	local closePrompt = self.props.closePrompt
	local screenWidth = self.props.screenWidth
	local screenSize = self.props.screenSize
	local deviceOrientation = self.props.deviceOrientation
	local parentPage = self.props.parentPage
	local userHasMembership = self.props.userHasMembership

	local favoriteIcon = isFavorited and FAVORITED_ICON or FAVORITE_ICON
	local creatorId = itemInfo.creator and itemInfo.creator.id
	local isReportVisible = creatorId ~= ROBLOX_USER_ID
	local isResellable = CatalogUtils.IsResellable(itemInfo)

	local favoriteText = isFavorited and localized.unfavoriteLabel or localized.favoriteLabel
	local reportText = localized.reportLabel

	local contextualMenuButtons = {}

	if itemInfo.isOwned and parentPage ~= AppPage.AvatarEditor then
		table.insert(contextualMenuButtons,
		{
			icon = CUSTOMIZE_ICON,
			text = localized.customizeLabel,
			onActivated = self.goToAvatarPage,
		})
	end

	table.insert(contextualMenuButtons,
	{
		icon = favoriteIcon,
		text = favoriteText,
		onActivated = self.favoriteItem,
	})

	local isPortrait = deviceOrientation == DeviceOrientationMode.Portrait
	local navWidth = isPortrait and 0 or AvatarExperienceConstants.LandscapeNavWidth
	local sceneWidth = isPortrait and 1 or AvatarExperienceConstants.LandscapeSceneWidth

	if true then
		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.new(navWidth, 0, 0, 0),
			Size = UDim2.new(sceneWidth, 0, 1, 0),
		}, {
			ContextMenu = Roact.createElement(ContextualMenu, {
				buttonProps = contextualMenuButtons,

				open = true,
				menuDirection = MenuDirection.Up,
				openPositionY = UDim.new(1, -BOTTOM_GAP),

				closeBackgroundVisible = true,
				screenSize = screenSize,

				onDismiss = closePrompt,
			})
		})
	else
		return Roact.createElement(ModalBottomSheet, {
			bottomGap = BOTTOM_GAP,
			onDismiss = closePrompt,
			buttonModels = contextualMenuButtons,
			screenWidth = screenWidth,
			showImages = true,
			sheetContentXSize = UDim.new(sceneWidth, 0),
			sheetContentXPosition = UDim.new(navWidth, 0),
		})
	end
end

function CatalogContextFrame:render()
	if not self.props.itemInfo then
		return
	end
	return withLocalization({
		customizeLabel = "Feature.Catalog.Action.Customize",
		favoriteLabel = "Feature.Catalog.Action.Favorite",
		unfavoriteLabel = "Feature.Catalog.Action.RemoveFavorite",
		sellLabel = "Feature.Catalog.Action.Sell",
		reportLabel = "Feature.Catalog.Action.Report",
	})(function(localized)
		return self:renderLocalized(localized)
	end)
end

CatalogContextFrame = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local itemInfo = ItemData(state.AvatarExperience.Common, props.itemId, props.itemType)
		local userMembership = Players.LocalPlayer.MembershipType
		-- TODO: MOBLUAPP-1098 After router-side fix is done, please REMOVE currentRoute/currentPage.
		local currentRoute = state.Navigation.history[#state.Navigation.history]
		return {
			currentPage = currentRoute[#currentRoute].name,
			deviceOrientation = state.DeviceOrientation,
			parentPage = AvatarExperienceUtils.getParentPage(state),
			favoritesFetchingState = getFavoritesFetchingState(state, props),
			localUserId = state.LocalUserId,
			isFavorited = getIsFavorited(state, props),
			itemInfo = itemInfo,
			screenWidth = state.ScreenSize.X,
			screenSize = state.ScreenSize,
			userHasMembership = (userMembership ~= Enum.MembershipType.None),
		}
	end,
	function(dispatch)
		return {
			closePrompt = function()
				dispatch(CloseCentralOverlay())
			end,
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
			navigateToRoute = function(route)
				dispatch(NavigateToRoute(route))
			end,
			getAssetFavorite = function(userId, assetId)
				dispatch(GetAssetFavorite(userId, assetId))
			end,
			getBundleFavorite = function(userId, assetId)
				dispatch(GetBundleFavorite(userId, assetId))
			end,
			setAssetFavorite = function(userId, assetId, isFavorited)
				dispatch(SetAssetFavorite(userId, assetId, isFavorited))
			end,
			setBundleFavorite = function(userId, assetId, isFavorited)
				dispatch(SetBundleFavorite(userId, assetId, isFavorited))
			end,
		}
	end
)(CatalogContextFrame)

return CatalogContextFrame
