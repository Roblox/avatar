local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)
local UIBlox = require(Modules.Packages.UIBlox)

local ItemData = require(Modules.AvatarExperience.Common.Selectors.ItemData)
local CatalogUtils = require(Modules.AvatarExperience.Catalog.CatalogUtils)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)

local ItemTile = UIBlox.Tile.ItemTile

local THUMBNAIL_SIZE = CatalogConstants.ThumbnailSize["150"]


local BaseItemCard = Roact.PureComponent:extend("BaseItemCard")

function BaseItemCard:render()
	local itemData = self.props.itemData
	local itemId = self.props.itemId
	local itemType = self.props.itemType

	local thumbnail
	if itemData then
		local thumbType = CatalogUtils.GetRbxThumbType(itemType)
		thumbnail = CatalogUtils.MakeRbxThumbUrl(thumbType, itemId, THUMBNAIL_SIZE, THUMBNAIL_SIZE)
	end

	return Roact.createElement(ItemTile, {
		footer = self.props.footer,
		LayoutOrder = self.props.layoutOrder,
		onActivated = self.props.onActivated,
		name = itemData and itemData.name,
		thumbnail = thumbnail,
	})
end

local function mapStateToProps(state, props)
	return {
		itemData = ItemData(state.AvatarExperience.Common, props.itemId, props.itemType),
	}
end

BaseItemCard = RoactRodux.UNSTABLE_connect2(mapStateToProps)(BaseItemCard)

return BaseItemCard