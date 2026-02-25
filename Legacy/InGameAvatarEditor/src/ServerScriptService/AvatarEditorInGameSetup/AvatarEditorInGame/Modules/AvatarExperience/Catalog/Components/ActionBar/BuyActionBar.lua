--[[
	Props:
		itemId (string)
		itemType (string)
		leftPadding = optional (int)
		rightPadding = optional (int)
		bottomPadding = optional (int)
		showMoreButton = optional (bool)
		ZIndex = optional (int)
]]
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local RoactRodux = require(Modules.Packages.RoactRodux)
local RoactServices = require(Modules.Common.RoactServices)
local RoactLocalization = require(Modules.Services.RoactLocalization)

local AppPage = require(Modules.NotLApp.AppPage)
local withLocalization = require(Modules.Packages.Localization.withLocalization)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)
local withStyle = UIBlox.Style.withStyle
local NumberLocalization = require(Modules.Packages.Localization.NumberLocalization)

local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local ActionBar = require(Modules.AvatarExperience.Catalog.Components.ActionBar.ActionBar)
local ItemData = require(Modules.AvatarExperience.Common.Selectors.ItemData)
local CatalogUtils = require(Modules.AvatarExperience.Catalog.CatalogUtils)

local SetCurrentToastMessage = require(Modules.NotLApp.Actions.SetCurrentToastMessage)
local SetCentralOverlay = require(Modules.NotLApp.Actions.SetCentralOverlay)
local CloseCentralOverlay = require(Modules.NotLApp.Thunks.CloseCentralOverlay)

local ClearSelectedItem = require(Modules.AvatarExperience.Common.Actions.ClearSelectedItem)
local CloseAllItemDetails = require(Modules.AvatarExperience.Catalog.Thunks.CloseAllItemDetails)
local SetAssetOwned = require(Modules.AvatarExperience.Common.Actions.SetAssetOwned)
local SetBundleOwned = require(Modules.AvatarExperience.Common.Actions.SetBundleOwned)

local OverlayType = require(Modules.NotLApp.Enum.OverlayType)
local ToastType = require(Modules.NotLApp.Enum.ToastType)

local Images = UIBlox.App.ImageSet.Images

local FFlagAvatarEditorUpdateRecommendations = function() return true end
local GetFFlagPeekPreviewMenuClose = function() return true end

local CUSTOMIZE_ICON = Images["icons/menu/avatar_on"]
local ROBUX_ICON = Images["icons/common/robux"]
local NOTPURCHASABLE_ICON = Images["icons/actions/block"]
local ICON_SIZE = 30
local ICON_PADDING = 5

local NO_RESELLERS_TOAST = {
	toastMessage = "Feature.Catalog.LabelNoResellers",
	toastSubMessage = "Feature.Catalog.Label.NoSellersWarning",
	isLocalized = false,
	toastType = ToastType.SuccessConfirmation,
}

local DISABLED_TOAST = {
	toastMessage = "Feature.Catalog.Heading.NotForSale",
	toastSubMessage = "Feature.Catalog.Label.NoLongerAvailable",
	isLocalized = false,
	toastType = ToastType.SuccessConfirmation,
}

local ALREADY_ACQUIRED_TOAST = {
	toastMessage = "Feature.Avatar.Message.AlreadyAcquired",
	isLocalized = false,
	toastType = ToastType.InformationMessage,
}

local BuyActionBar = Roact.PureComponent:extend("BuyActionBar")

BuyActionBar.defaultProps = {
	bottomPadding = 0,
	showMoreButton = true,
}

function BuyActionBar:init()
	self.openPurchasePrompt = function()
		local itemInfo = self.props.itemInfo
		local itemId = self.props.itemId
		local itemType = self.props.itemType

		if not itemInfo then
			return
		end

		self.props.openPurchasePrompt(itemId, itemType)
	end

	self.goToAvatarPage = function()
		local parentPage = self.props.parentPage
		local itemInfo = self.props.itemInfo
		local itemType = self.props.itemType
		local itemSubType
		if itemType == CatalogConstants.ItemType.Asset then
			itemSubType = itemInfo.assetType
		elseif itemType == CatalogConstants.ItemType.Bundle then
			itemSubType = itemInfo.bundleType
		end
		local currentPage = self.props.currentPage

		if FFlagAvatarEditorUpdateRecommendations() and parentPage == AppPage.AvatarEditor then
			self.props.setCurrentToastMessage(ALREADY_ACQUIRED_TOAST)
		else
			self.props.openAvatarPagePrompt(itemType, itemSubType, { currentPage })
		end
	end

	self.openCatalogContextMenu = function()
		local currentPage = self.props.currentPage
		local itemId = self.props.itemId
		local itemType = self.props.itemType
		self.props.openCatalogContextMenu(itemId, itemType, { currentPage })
	end

	self.closeCatalogContextMenu = function()
		if GetFFlagPeekPreviewMenuClose() then
			self.props.closeCatalogContextMenu()
		end
	end

	self.clickDisabledButton = function()
		local itemInfo = self.props.itemInfo
		local userAsset = self.props.userAsset
		local isResellable = CatalogUtils.IsResellable(itemInfo)
		local hasNoResellers = (isResellable and userAsset == nil)

		if hasNoResellers then
			self.props.setCurrentToastMessage(NO_RESELLERS_TOAST)
		else
			self.props.setCurrentToastMessage(DISABLED_TOAST)
		end
	end
end

function BuyActionBar:render()
	return withLocalization({
		freeText = "Feature.Catalog.LabelFree",
	})(function(localized)
		return withStyle(function(stylePalette)
			local ZIndex = self.props.ZIndex
			local leftPadding = self.props.leftPadding
			local rightPadding = self.props.rightPadding
			local bottomPadding = self.props.bottomPadding
			local showMoreButton = self.props.showMoreButton
			local itemInfo = self.props.itemInfo
			local localization = self.props.localization
			local userAsset = self.props.userAsset
			local userRobux = self.props.userRobux

			local isOwned = itemInfo and itemInfo.isOwned
			local isPurchasable = itemInfo and itemInfo.isPurchasable
			local priceInRobux = itemInfo and itemInfo.priceInRobux

			local canPurchaseMultiple = CatalogUtils.IsResellable(itemInfo)
			if canPurchaseMultiple then
				priceInRobux = itemInfo and (itemInfo.lowestPrice or itemInfo.priceInRobux)
			end

			local isResellable = CatalogUtils.IsResellable(itemInfo)
			local hasNoResellers = (isResellable and userAsset == nil)
			local isDisabled = (not isOwned and not isPurchasable)
				or hasNoResellers
				or (itemInfo and itemInfo.isForRent)

			local parsedPriceInRobux = priceInRobux and string.format("%.0f", priceInRobux)
			local priceText = priceInRobux and NumberLocalization.localize(parsedPriceInRobux, localization:GetLocale())
			local showIcon = true
			local onActivated = self.openPurchasePrompt
			local btnIcon = ROBUX_ICON

			if isDisabled then
				priceText = ""
				onActivated = self.clickDisabledButton
				btnIcon = NOTPURCHASABLE_ICON
			elseif isOwned and not canPurchaseMultiple then
				priceText = ""
				btnIcon = CUSTOMIZE_ICON
				onActivated = self.goToAvatarPage
			elseif priceInRobux == 0 then
				showIcon = false
				priceText = localized.freeText
			end

			local fetchingState = self.props.fetchingState
			local isLoading = fetchingState == RetrievalStatus.Fetching or
				fetchingState == RetrievalStatus.NotStarted

			local props = {
				buttonText = priceText,
				buttonIcon = showIcon and btnIcon or nil,
				buttonIconPadding = showIcon and ICON_PADDING or 0,
				buttonIconSize = showIcon and ICON_SIZE or 0,
				buttonIsDisabled = isDisabled,
				buttonIsLoading = isLoading,
				buttonColor = stylePalette.Theme.ContextualPrimaryDefault.Color,
				onActivated = onActivated,
			}

			return Roact.createElement(ActionBar, {
				ZIndex = ZIndex,
				leftPadding = leftPadding,
				rightPadding = rightPadding,
				bottomPadding = bottomPadding,
				showMoreButton = showMoreButton,
				buttonProps = props,
				onMoreButtonActivated = self.openCatalogContextMenu,
				onMoreButtonUnmount = self.closeCatalogContextMenu,
			})
		end)
	end)
end

BuyActionBar = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local localUserId = state.LocalUserId
		local itemInfo = ItemData(state.AvatarExperience.Common, props.itemId, props.itemType)
		local productId = itemInfo and itemInfo.product and itemInfo.product.id
		local resellerUserAssetIds = itemInfo and itemInfo.resellerUserAssetIds
		local currentRoute = state.Navigation.history[#state.Navigation.history]
		local lowestUserAssetId = resellerUserAssetIds and resellerUserAssetIds[1]
		return {
			currentPage = currentRoute[#currentRoute].name,
			parentPage = AvatarExperienceUtils.getParentPage(state),
			fetchingState = PerformFetch.GetStatus(state, CatalogUtils.GetItemDetailsKey(props.itemId, props.itemType)),
			itemInfo = itemInfo,
			userAsset = state.AvatarExperience.Catalog.UserAssets[lowestUserAssetId],
			productId = productId,
			userRobux = state.UserRobux[localUserId],
			localUserId = localUserId,
		}
	end,
	function(dispatch)
		return {
			openAvatarPagePrompt = function(itemType, itemSubType, pageFilter)
				dispatch(SetCentralOverlay(OverlayType.LeaveCatalogToAvatarPrompt, {
					itemType = itemType,
					itemSubType = itemSubType,
					pageFilter = pageFilter,
				}))
			end,
			openPurchasePrompt = function(itemId, itemType)
				MarketplaceService:PromptPurchase(
					Players.LocalPlayer,
					itemId,
					false
				)

				while true do
					local player, purchasedAssetId, isPurchased = MarketplaceService.PromptPurchaseFinished:Wait()

					if player == Players.LocalPlayer then
						if isPurchased and purchasedAssetId == itemId then
							if itemType == CatalogConstants.ItemType.Asset then
								dispatch(SetAssetOwned(itemId, true))
							else
								dispatch(SetBundleOwned(itemId, true))
							end

							local SUCCESS_TOAST = {
								toastMessage = "Feature.Catalog.Label.Purchased",
								isLocalized = false,
								toastType = ToastType.SuccessConfirmation,
							}

							dispatch(SetCurrentToastMessage(SUCCESS_TOAST))
							dispatch(ClearSelectedItem())
							dispatch(CloseAllItemDetails())
						end
						break
					end
				end
			end,
			openCatalogContextMenu = function(itemId, itemType, pageFilter)
				dispatch(SetCentralOverlay(OverlayType.CatalogContextMenu, {
					itemId = itemId,
					itemType = itemType,
					pageFilter = pageFilter,
				}))
			end,
			closeCatalogContextMenu = function()
				dispatch(CloseCentralOverlay())
			end,
			setCurrentToastMessage = function(toastInfo)
				dispatch(SetCurrentToastMessage(toastInfo))
			end,
		}
	end
)(BuyActionBar)

return RoactServices.connect({
	localization = RoactLocalization,
})(BuyActionBar)
