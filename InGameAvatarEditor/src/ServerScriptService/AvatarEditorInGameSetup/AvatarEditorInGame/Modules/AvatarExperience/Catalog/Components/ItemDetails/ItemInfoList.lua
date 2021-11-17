local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)

local ItemInfoRow = require(Modules.AvatarExperience.Catalog.Components.ItemDetails.ItemInfoRow)
local NavigateDown = require(Modules.NotLApp.Thunks.NavigateDown)

local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle
local withLocalization = require(Modules.Packages.Localization.withLocalization)

local ROW_HEIGHT = 53
local HORIZONTAL_PADDING = 0

local ItemInfoList = Roact.PureComponent:extend("ItemInfoList")

ItemInfoList.defaultProps = {
	LayoutOrder = 0,
	creatorId = nil,
	creatorText = "",
	genreText = "",
	typeText = "",
	showAllDividers = false,
}

function ItemInfoList:makeItemInfoListData(localizedCategoryType)
	local creatorText = self.props.creatorText
	local genreText = self.props.genreText

	self.ItemInfoListData = {}
	table.insert(self.ItemInfoListData, {
		infoName = "Feature.Catalog.Label.Filter.Creator",
		infoData = creatorText,
	})
	table.insert(self.ItemInfoListData, {
		infoName = "Feature.Catalog.Label.CategoryType",
		infoData = localizedCategoryType or "",
	})
	table.insert(self.ItemInfoListData, {
		infoName = "Feature.Catalog.Label.Filter.Genre",
		infoData = genreText,
	})
end

function ItemInfoList:renderStylized(localized)
	local itemType = self.props.itemType

	local categoryType
	if itemType == CatalogConstants.ItemType.Asset and localized.category and localized.subType then
		categoryType = localized.category .. " | " .. localized.subType
	elseif itemType == CatalogConstants.ItemType.Bundle then
		categoryType = localized.bundle
	end

	self:makeItemInfoListData(categoryType)

	local renderFuntion = function(stylePalette)
		local theme = stylePalette.Theme
		local layoutOrder = self.props.LayoutOrder
		local showAllDividers = self.props.showAllDividers
		local listContents = {}

		listContents["Layout"] = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
		})

		local rowCount = 0
		for i, item in ipairs(self.ItemInfoListData) do
			rowCount = rowCount + 1
			local hasDivider = showAllDividers or (i < #self.ItemInfoListData)
			listContents["InfoRow" .. i] = Roact.createElement(ItemInfoRow, {
				horizontalPadding = HORIZONTAL_PADDING,
				infoName = item.infoName,
				infoData = item.infoData,
				onActivate = item.onActivate,
				LayoutOrder = rowCount,
				Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
			})
			if hasDivider then
				rowCount = rowCount + 1
				listContents["Divider" .. i] = Roact.createElement("Frame", {
					BackgroundColor3 = theme.Divider.Color,
					BackgroundTransparency = theme.Divider.Transparency,
					BorderSizePixel = 0,
					LayoutOrder = rowCount,
					Size = UDim2.new(1, -HORIZONTAL_PADDING, 0, 1),
				})
			end
		end

		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			LayoutOrder = layoutOrder,
			Size = UDim2.new(1, -HORIZONTAL_PADDING, 0, ROW_HEIGHT * #self.ItemInfoListData),
		}, listContents)
	end

	return withStyle(renderFuntion)
end

function ItemInfoList:render()
	local itemType = self.props.itemType
	local itemSubType = self.props.itemSubType

	local categoryString
	local itemSubTypeString
	if itemType == CatalogConstants.ItemType.Asset then
		local category = AvatarExperienceConstants.AssetTypeIdToCategory[itemSubType]
		categoryString = AvatarExperienceConstants.AssetCategoriesLocalized[category]
		itemSubTypeString = AvatarExperienceConstants.AssetTypeLocalized[itemSubType]
	end

	return withLocalization({
		bundle = "Feature.Catalog.Label.Bundle",
		category = categoryString,
		subType = itemSubTypeString,
	})(function(localized)
		return self:renderStylized(localized)
	end)
end


return RoactRodux.UNSTABLE_connect2(
	nil,
	function (dispatch)
		return {
			navigateDown = function(page)
				dispatch(NavigateDown(page))
			end,
		}
	end
)(ItemInfoList)
