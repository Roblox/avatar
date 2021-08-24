local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)

local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local BaseItemCard = require(Modules.AvatarExperience.Catalog.Components.ItemsList.BaseItemCard)
local LoadableGridView = require(Modules.AvatarExperience.Common.Components.LoadableGridView)

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local BundlesItemsGrid = Roact.PureComponent:extend("BundlesItemsGrid")

function BundlesItemsGrid:init()
	self.renderItemTile = function(entry)
		return Roact.createElement(BaseItemCard, {
			itemId = entry.id,
			itemType = entry.type,
			onActivated = function() end,
		})
	end
end

function BundlesItemsGrid:render()
	local bundleItemsList = self.props.bundleItemsList
	local layoutOrder = self.props.LayoutOrder

	local assetItemsList
	if bundleItemsList then
		assetItemsList = {}
		for _,includedItem in pairs(bundleItemsList) do
			if includedItem.type == CatalogConstants.ItemType.Asset then
				table.insert(assetItemsList, includedItem)
			end
		end
	end

	return withStyle(function(stylePalette)
		local font = stylePalette.Font
		local titleFontHeight = font.BaseSize * font.Header2.RelativeSize

		local itemType = AvatarExperienceConstants.ItemType.BundleItemTile
		local getItemHeightFunc = AvatarExperienceUtils.GridItemHeightGetter(itemType, titleFontHeight)

		return Roact.createElement(LoadableGridView, {
			renderItem = self.renderItemTile,
			getItemHeight = getItemHeightFunc,
			items = assetItemsList,
			LayoutOrder = layoutOrder,
			numItemsExpected = CatalogConstants.bundleIncludedItemsCount,
		})
	end)
end

BundlesItemsGrid = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		local itemId = tostring(props.itemId)
		local itemInfo = state.AvatarExperience.Common.Bundles[itemId]
		return {
			bundleItemsList = itemInfo and itemInfo.items,
		}
	end
)(BundlesItemsGrid)

return BundlesItemsGrid