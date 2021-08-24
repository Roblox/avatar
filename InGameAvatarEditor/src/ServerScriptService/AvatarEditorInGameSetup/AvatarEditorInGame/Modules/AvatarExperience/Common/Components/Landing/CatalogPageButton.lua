local Players = game:GetService("Players")
local NotificationService = game:GetService("NotificationService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local CatalogUtils = require(Modules.AvatarExperience.Catalog.CatalogUtils)
local FetchCatalogPageData = require(Modules.AvatarExperience.Catalog.Thunks.FetchCatalogPageData)

local LoadableImage = UIBlox.Loading.LoadableImage
local PageButton = require(Modules.AvatarExperience.Common.Components.Landing.PageButton)
local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local ASSET_THUMBNAIL_TYPE = CatalogConstants.ThumbnailType.Asset
local ASSET_THUMBNAIL_SIZE = CatalogConstants.ThumbnailSize["420"]
local BUNDLE_THUMBNAIL_TYPE = CatalogConstants.ThumbnailType.BundleThumbnail
local BUNDLE_THUMBNAIL_SIZE = CatalogConstants.ThumbnailSize["420"]

local CATALOG_ICON = "icons/menu/shop_large"
local DEFAULT_CATEGORY = 1
local DEFAULT_SUBCATEGORY = 0

local DARK_BACKGROUND = "rbxasset://textures/AvatarEditorImages/Catalog.png"
local LIGHT_BACKGROUND = "rbxasset://textures/AvatarEditorImages/Catalog_LightTheme.png"

local CatalogPageButton = Roact.PureComponent:extend("CatalogPageButton")

CatalogPageButton.defaultProps = {
	transparencyModifier = 0,
}

local IMAGE_WIDTH_OFFSET = 0.05
local IMAGE_HEIGHT_OFFSET = 0.05

function CatalogPageButton:init()
	self.state = {
		style = "dark",
	}

	self.fetchInitialCatalogItems = function()
		local categoryIndex = DEFAULT_CATEGORY
		local subcategoryIndex = DEFAULT_SUBCATEGORY

		return self.props.fetchSortContents(categoryIndex, subcategoryIndex)
	end
end

function CatalogPageButton:render()
	local catalogItem = self.props.catalogItem
	local style = self.state.style
	local transparencyModifier = self.props.transparencyModifier

	local backgroundImage = LIGHT_BACKGROUND
	if style == "dark" then
		backgroundImage = DARK_BACKGROUND
	end

	local itemThumbnail
	if catalogItem then
		if catalogItem.type == CatalogConstants.ItemType.Bundle then
			itemThumbnail = CatalogUtils.MakeRbxThumbUrl(BUNDLE_THUMBNAIL_TYPE, catalogItem.id,
				BUNDLE_THUMBNAIL_SIZE, BUNDLE_THUMBNAIL_SIZE)
		else
			itemThumbnail = CatalogUtils.MakeRbxThumbUrl(ASSET_THUMBNAIL_TYPE, catalogItem.id,
				ASSET_THUMBNAIL_SIZE, ASSET_THUMBNAIL_SIZE)
		end
	end

	return withLocalization({
		catalogText = "Feature.Avatar.Action.Shop",
	})(function(localized)
		return Roact.createElement(PageButton, {
			Size = UDim2.new(1, 0, 1, 0),

			backgroundImage = backgroundImage,
			icon = CATALOG_ICON,
			text = localized.catalogText,
			transparencyModifier = transparencyModifier,

			onActivated = self.props.onActivated,
		}, {
			ThumbnailFrame = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(2.8, 0, 2.8, 0),
			}, {
				AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1,
					AspectType = Enum.AspectType.FitWithinMaxSize,
					DominantAxis = Enum.DominantAxis.Height,
				}),

				Image = Roact.createElement(LoadableImage, {
					BackgroundTransparency = 1,
					Image = itemThumbnail,
					ImageTransparency = transparencyModifier,
					Position = UDim2.new(IMAGE_WIDTH_OFFSET, 0, IMAGE_HEIGHT_OFFSET, 0),
					Size = UDim2.new(1, 0, 1, 0),
				}),
			}),
		})
	end)
end

function CatalogPageButton:checkFetchSortData()
	if self.props.catalogItem == nil and self.props.catalogDataStatus == RetrievalStatus.NotStarted then
		self.fetchInitialCatalogItems()
	end
end

function CatalogPageButton:didUpdate()
	self:checkFetchSortData()
end

function CatalogPageButton:didMount()
	--[[
	self.themeChangedConn = NotificationService:GetPropertyChangedSignal("SelectedTheme"):Connect(function()
		self:setState({
			style = "dark", -- string.lower(NotificationService.SelectedTheme),
		})
	end)
	--]]

	self:checkFetchSortData()
end

function CatalogPageButton:willUnmount()
	if self.themeChangedConn then
		self.themeChangedConn:Disconnect()
		self.themeChangedConn = nil
	end
end

local function mapStateToProps(state)
	local categoryInfo = state.AvatarExperience.Catalog.SortsContents[DEFAULT_CATEGORY]
	local subcategoryInfo = categoryInfo and categoryInfo[DEFAULT_SUBCATEGORY] or {}
	local sortEntries = subcategoryInfo.entries or {}
	local firstCatalogItem = sortEntries[1]

	return {
		catalogItem = firstCatalogItem,
		catalogDataStatus = CatalogUtils.GetSortDataStatus(state, DEFAULT_CATEGORY, DEFAULT_SUBCATEGORY)
	}
end

local function mapDispatchToProps(dispatch)
	return {
		fetchSortContents = function(categoryIndex, subcategoryIndex)
			return dispatch(FetchCatalogPageData(categoryIndex, subcategoryIndex,
				nil))
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(CatalogPageButton)
