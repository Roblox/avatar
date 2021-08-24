local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)
local SecondaryButton = UIBlox.App.Button.SecondaryButton
local withStyle = UIBlox.Style.withStyle
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)

local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)

local FitChildren = require(Modules.NotLApp.FitChildren)
local Categories = require(Modules.AvatarExperience.AvatarEditor.Categories)

local FitTextLabel = require(Modules.NotLApp.FitTextLabel)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)
local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)
local NavigateSameLevel = require(Modules.NotLApp.Thunks.NavigateSameLevel)
local AppPage = require(Modules.NotLApp.AppPage)

local LoadableGridView = require(Modules.AvatarExperience.Common.Components.LoadableGridView)
local GetRecommendedItems = require(Modules.AvatarExperience.AvatarEditor.Thunks.GetRecommendedItems)
local RecommendedItemCard = require(Modules.AvatarExperience.AvatarEditor.Components.RecommendedItemCard)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local SetCategoryAndSubcategory = require(Modules.AvatarExperience.Catalog.Thunks.SetCategoryAndSubcategory)

local CATALOG_TEXT = "CommonUI.Features.Label.Catalog"
local SHOP_TEXT = "Feature.Avatar.Action.Shop"
local SHOP_FOR_MORE_TEXT = "Feature.Avatar.Action.ShopForMore"
local YOU_MAY_ALSO_LIKE_TEXT = "Feature.Catalog.Label.Recommendations"

local GetFFlagLuaAppCatalogToShopText = function() return true end
local FFlagEnableAvatarExperienceLandingPage = false

local RecommendedItems = Roact.PureComponent:extend("RecommendedItems")

local function getRecommendedKey(page)
	if page.RecommendationsType == AvatarEditorConstants.RecommendationsType.Asset then
		return page.AssetTypeId
	elseif page.RecommendationsType == AvatarEditorConstants.RecommendationsType.BodyParts then
		return AvatarEditorConstants.RecommendationsType.BodyParts
	elseif page.RecommendationsType == AvatarEditorConstants.RecommendationsType.AvatarAnimations then
		return AvatarEditorConstants.RecommendationsType.AvatarAnimations
	else
		return AvatarEditorConstants.RecommendationsType.None
	end
end

function RecommendedItems:init()
	self.onActivated = function()
		local navigationHistory = self.props.navigationHistory
		local page = self.props.page

		self.props.setCatalogIndicies(page)

		if FFlagEnableAvatarExperienceLandingPage then
			self.props.navigateSameLevel(navigationHistory, AppPage.Catalog)
		else
			self.props.navigateDown({
				name = AppPage.Catalog,
				extraProps = {
					titleKey = GetFFlagLuaAppCatalogToShopText() and SHOP_TEXT or CATALOG_TEXT,
				},
			})
		end
	end

	self.getRecommendedItems = function()
		if self.props.page.RecommendationsType == AvatarEditorConstants.RecommendationsType.None then
			return
		end

		local assetTypeId = self.props.page.AssetTypeId
		self.props.getRecommendedItems(assetTypeId)
	end
end

function RecommendedItems:didUpdate(prevProps)
	local dataStatus = self.props.dataStatus
	local appPage = self.props.appPage

	if appPage == AppPage.AvatarEditor and dataStatus == RetrievalStatus.NotStarted then
		self.getRecommendedItems()
	end
end

function RecommendedItems:render()
	local items = self.props.items
	local itemType = self.props.itemType

	return withStyle(function(stylePalette)
		return withLocalization({
			shopForMore = SHOP_FOR_MORE_TEXT,
			youMayAlsoLike = YOU_MAY_ALSO_LIKE_TEXT,
		})(function(localized)
			local layoutOrder = self.props.LayoutOrder
			local screenSize = self.props.screenSize
			local fontInfo = stylePalette.Font
			local theme = stylePalette.Theme
			local font = fontInfo.Header2.Font
			local fontSize = fontInfo.BaseSize * fontInfo.Header2.RelativeSize
			local linkTextColor = theme.TextEmphasis.Color

			local tileType = AvatarExperienceConstants.ItemType.CatalogItemTile
			local getItemHeightFunc = AvatarExperienceUtils.GridItemHeightGetter(tileType, fontSize)

			local shopForMoreButton = Roact.createElement(SecondaryButton, {
				layoutOrder = 3,
				size = UDim2.new(1, 0, 0, 48),
				text = localized.shopForMore,
				onActivated = self.onActivated,
			})

			return Roact.createElement(FitChildren.FitFrame, {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = theme.BackgroundUIContrast.Transparency,
				BackgroundColor3 = theme.BackgroundUIContrast.Color,
				BorderSizePixel = 0,
				LayoutOrder = layoutOrder,
				fitAxis = FitChildren.FitAxis.Height,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 15),
					PaddingRight = UDim.new(0, 15),
					PaddingTop = UDim.new(0, 24),
					PaddingBottom = UDim.new(0, 15),
				}),
				UIListLayout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, 10),
					FillDirection = Enum.FillDirection.Vertical,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
				}),
				YouMayAlsoLikeTextLabel = Roact.createElement(FitTextLabel, {
					Size = UDim2.new(0, 0, 0, 24),
					BackgroundTransparency = 1,
					Font = font,
					TextColor3 = theme.TextEmphasis.Color,
					Text = localized.youMayAlsoLike,
					TextSize = fontSize,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					LayoutOrder = 1,
					fitAxis = FitChildren.FitAxis.Width,
				}),
				GridView = Roact.createElement(LoadableGridView, {
					LayoutOrder = 2,
					items = items,
					numItemsExpected = AvatarEditorConstants.NumRecommendedItems,
					getItemHeight = getItemHeightFunc,
					windowHeight = screenSize.Y,
					renderItem = function(itemId, index)
						return Roact.createElement(RecommendedItemCard, {
							itemId = itemId,
							index = index,
							itemType = itemType,
							getRecommendedItems = self.getRecommendedItems,
						})
					end
				}),
				ShopForMoreButton = shopForMoreButton,
			})
		end)
	end)
end

local function mapStateToProps(state, props)
	local categoryIndex = state.AvatarExperience.AvatarEditor.Categories.category
	local subcategoryIndex = state.AvatarExperience.AvatarEditor.Categories.subcategory
	local page = AvatarExperienceUtils.GetCategoryInfo(Categories, categoryIndex, subcategoryIndex)
	local recommendedKey = getRecommendedKey(page)
	local itemType = (recommendedKey == AvatarEditorConstants.RecommendationsType.BodyParts
		or recommendedKey == AvatarEditorConstants.RecommendationsType.AvatarAnimations)
		and CatalogConstants.ItemType.Bundle or CatalogConstants.ItemType.Asset

	return {
		appPage = AvatarExperienceUtils.getCurrentPage(state),
		dataStatus = PerformFetch.GetStatus(state, AvatarExperienceConstants.RecommendedItemsKey ..tostring(recommendedKey)),
		screenSize = state.ScreenSize,
		page = page,
		items = state.AvatarExperience.AvatarEditor.RecommendedItems[recommendedKey] or {},
		itemType = itemType,
		navigationHistory = state.Navigation.history,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		getRecommendedItems = function(assetTypeId)
			dispatch(GetRecommendedItems(assetTypeId))
		end,
		navigateDown = function(page)
			dispatch(NavigateDown(page))
		end,
		navigateSameLevel = function(navigationHistory, page)
			return dispatch(NavigateSameLevel(navigationHistory, page))
		end,
		setCatalogIndicies = function(page)
			local categoryIndex = page.MatchingCatalogPage.CategoryIndex
			local subcategoryIndex = page.MatchingCatalogPage.SubcategoryIndex
			dispatch(SetCategoryAndSubcategory(categoryIndex, subcategoryIndex))
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(RecommendedItems)
