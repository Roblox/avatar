local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)
local Cryo = require(Modules.Packages.Cryo)
local Logging = require(Modules.Packages.Logging)

local AvatarEditorCategories = require(Modules.AvatarExperience.AvatarEditor.Categories)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local CatalogCategories = require(Modules.AvatarExperience.Catalog.Categories)
local GetFFlagAvatarEditorUpdateCamera = function() return true end
local AppPage = require(Modules.NotLApp.AppPage)
local memoize = require(Modules.Common.memoize)

local FFlagAvatarEditorTweenMinimizeButton = true

local GRADIENT_THRESHOLD = 20

local OTHER_PAGE = {
	PageType = AvatarExperienceConstants.PageType.Other,
	RecommendationsType = AvatarEditorConstants.RecommendationsType.None,
}

local AvatarExperienceUtils = {}

AvatarExperienceUtils.GetCategoryInfo = memoize(function(categories, categoryIndex, subcategoryIndex)
	local categoryInfo = categories[categoryIndex]

	if categoryInfo.Subcategories then
		local subcategoryInfo = categoryInfo.Subcategories[subcategoryIndex]
		if subcategoryInfo then
			return Cryo.Dictionary.join(categoryInfo, subcategoryInfo)
		end
	end

	-- Emotes doesn't use standard sub-categories
	-- Construct a unique CategoryInfo table based on the slot that is currently being edited
	if categoryInfo.PageType == AvatarExperienceConstants.PageType.Emotes then
		return Cryo.Dictionary.join(categoryInfo, {
			EmoteSlot = subcategoryIndex,
		})
	end

	return categoryInfo
end)

local function getCatalogCardFooterHeight(width)
	if width < 100 then
		return 30
	elseif width < 148 then
		return 36
	else
		return 42
	end
end

local CatalogItemTileHeightGetter = memoize(function(fontHeight)
	return function(width)
		local itemImageHeight = width
		local titleHeight = AvatarExperienceConstants.ItemTileTitleMaxLines * fontHeight
		local paddingHeight = AvatarExperienceConstants.ItemTilePadding * 2 -- padding for top and bottom
		local footerHeight = getCatalogCardFooterHeight(width)

		return itemImageHeight + titleHeight + paddingHeight + footerHeight
	end
end)

local BundleItemTileHeightGetter = memoize(function(fontHeight)
	return function(width)
		local imageHeight = width
		local titleHeight = AvatarExperienceConstants.ItemTileTitleMaxLines * fontHeight
		local paddingHeight = AvatarExperienceConstants.ItemTilePadding
		return imageHeight + titleHeight + paddingHeight
	end
end)

local function squareItemHeightGetter(width)
	return width
end

function AvatarExperienceUtils.GridItemHeightGetter(itemType, ...)
	if itemType == AvatarExperienceConstants.ItemType.AvatarEditorTile then
		return squareItemHeightGetter
	elseif itemType == AvatarExperienceConstants.ItemType.BodyColorButton then
		return squareItemHeightGetter
	elseif itemType == AvatarExperienceConstants.ItemType.BundleItemTile then
		return BundleItemTileHeightGetter(...)
	elseif itemType == AvatarExperienceConstants.ItemType.CatalogItemTile then
		return CatalogItemTileHeightGetter(...)
	end

	warn("Unknown itemType " ..tostring(itemType).. " in AvatarExperienceUtils.GridItemHeightGetter")
	return squareItemHeightGetter
end

function AvatarExperienceUtils.getParentPage(state)
	local routeHistory = state.Navigation.history
	local route = routeHistory[#routeHistory]

	for i = #route, 1, -1 do
		local page = route[i].name
		if page == AppPage.AvatarEditor or page == AppPage.Catalog or page == AppPage.SearchPage then
			return page
		end
	end

	return route[#route].name
end

function AvatarExperienceUtils.getCurrentPage(state)
	local routeHistory = state.Navigation.history
	local route = routeHistory[#routeHistory]
	return route[#route].name
end

function AvatarExperienceUtils.doubleTapToZoomEnabled(state)
	local page = AvatarExperienceUtils.getCurrentPage(state)
	if page == AppPage.ItemDetails then
		page = AvatarExperienceUtils.getParentPage(state)
	end

	if page == AppPage.AvatarEditor or page == AppPage.Catalog or page == AppPage.SearchPage then
		return true
	elseif page == AppPage.AvatarExperienceLandingPage then
		return false
	elseif page ~= AppPage.ItemDetails then
		Logging.warn("Unknown SceneType")
		return false
	end

	return false
end

function AvatarExperienceUtils.getFullViewFromState(state)
	local page = AvatarExperienceUtils.getCurrentPage(state)
	if page == AppPage.ItemDetails then
		page = AvatarExperienceUtils.getParentPage(state)
	end

	if page == AppPage.AvatarEditor then
		return state.AvatarExperience.AvatarEditor.FullView
	elseif page == AppPage.Catalog or page == AppPage.SearchPage then
		return state.AvatarExperience.Catalog.FullView
	elseif page == AppPage.AvatarExperienceLandingPage then
		return false
	elseif page ~= AppPage.ItemDetails then
		Logging.warn("Unknown SceneType")
		return false
	end

	return false
end

function AvatarExperienceUtils.getPageFromState(state)
	local page = AvatarExperienceUtils.getCurrentPage(state)

	if page == AppPage.AvatarEditor then
		local categoryIndex = state.AvatarExperience.AvatarEditor.Categories.category
		local subcategoryIndex = state.AvatarExperience.AvatarEditor.Categories.subcategory

		return AvatarExperienceUtils.GetCategoryInfo(AvatarEditorCategories, categoryIndex, subcategoryIndex)
	elseif page == AppPage.Catalog then
		local categoryIndex = state.AvatarExperience.Catalog.Categories.category
		local subcategoryIndex = state.AvatarExperience.Catalog.Categories.subcategory

		return AvatarExperienceUtils.GetCategoryInfo(CatalogCategories, categoryIndex, subcategoryIndex)
	elseif not GetFFlagAvatarEditorUpdateCamera() and page == AppPage.SearchPage then
		return page
	elseif not GetFFlagAvatarEditorUpdateCamera() and page == AppPage.ItemDetails then
		return page
	elseif page == AppPage.AvatarExperienceLandingPage then
		return page
	else
		if not true then
			Logging.warn("Unknown Page in AvatarExperienceUtils.getPageFromState")
		end
		return OTHER_PAGE
	end
end

local HumanoidDescriptionFullyQualifiedProperties = {
	"Torso",
	"RightArm",
	"LeftArm",
	"LeftLeg",
	"RightLeg",
}

function AvatarExperienceUtils.isFullyQualifiedCostume(humanoidDescription)
	for _, propertyName in ipairs(HumanoidDescriptionFullyQualifiedProperties) do
		if humanoidDescription[propertyName] == "" or humanoidDescription[propertyName] == 0 then
			return false
		end
	end
	return true
end

function AvatarExperienceUtils.shouldShowGradientForScrollingFrame(scrollingFrame)
	local absoluteSize = scrollingFrame.AbsoluteSize
	local canvasSize = scrollingFrame.CanvasSize
	local canvasPosition = scrollingFrame.CanvasPosition

	local shouldShowGradient = absoluteSize.X < canvasSize.X.Offset

	local showLeft = canvasPosition.X > GRADIENT_THRESHOLD
	local showRight = canvasPosition.X + absoluteSize.X < canvasSize.X.Offset - GRADIENT_THRESHOLD

	return shouldShowGradient, showLeft, showRight
end

function AvatarExperienceUtils.Round(num, roundToNearest)
	roundToNearest = roundToNearest or 1
	return math.floor((num + roundToNearest/2) / roundToNearest) * roundToNearest
end

function AvatarExperienceUtils.isFetchingDoneOrFailed(prevFetchingState, nextfetchingState)
	local isPrevFetchingDoneOrFailed = (prevFetchingState == RetrievalStatus.Done)
		or (prevFetchingState == RetrievalStatus.Failed)
	local isNextFetchingDoneOrFailed = (nextfetchingState == RetrievalStatus.Done)
		or (nextfetchingState == RetrievalStatus.Failed)
	return not isPrevFetchingDoneOrFailed and isNextFetchingDoneOrFailed
end

function AvatarExperienceUtils.getDeviceType()
	local platform = UserInputService:GetPlatform()

	if platform == Enum.Platform.Android then
		return AvatarExperienceConstants.DeviceType.Android
	elseif platform == Enum.Platform.IOS then
		return AvatarExperienceConstants.DeviceType.IOS
	else
		return AvatarExperienceConstants.DeviceType.Other
	end
end

function AvatarExperienceUtils.lerp(a, b, t)
	return (b - a) * t + a
end

return AvatarExperienceUtils
