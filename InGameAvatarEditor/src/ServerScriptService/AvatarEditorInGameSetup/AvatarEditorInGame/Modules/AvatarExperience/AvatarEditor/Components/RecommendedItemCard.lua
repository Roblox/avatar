local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local RoactRodux = require(Modules.Packages.RoactRodux)

local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local AvatarEditorConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local ItemData = require(Modules.AvatarExperience.Common.Selectors.ItemData)
local CatalogItemCard = require(Modules.AvatarExperience.Catalog.Components.ItemsList.CatalogItemCard)
local PerformFetch = require(Modules.NotLApp.Thunks.PerformFetch)
local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)
local ClearSelectedItem = require(Modules.AvatarExperience.Common.Actions.ClearSelectedItem)

local FFlagAvatarEditorUpdateRecommendations = function() return true end

local RecommendedItemCard = Roact.PureComponent:extend("RecommendedItemCard")

-- Refresh the recommended items list when an asset was purchased from the Avatar Editor.
function RecommendedItemCard:didUpdate(prevProps)
	local getRecommendedItems = self.props.getRecommendedItems
	local clearSelectedItem = self.props.clearSelectedItem

	if prevProps.purchasingStatus == RetrievalStatus.Fetching and self.props.purchasingStatus == RetrievalStatus.Done then
		getRecommendedItems()
		clearSelectedItem()
	end
end

function RecommendedItemCard:didMount()
	if not FFlagAvatarEditorUpdateRecommendations() then
		self.props.getRecommendedItems()
	end
end

function RecommendedItemCard:render()
	local itemId = self.props.itemId
	local itemType = self.props.itemType
	local index = self.props.index

	return Roact.createElement(CatalogItemCard, {
		itemId = itemId,
		itemType = itemType,
		index = index,
	})
end

local function mapStateToProps(state, props)
	local itemData = ItemData(state.AvatarExperience.Common, props.itemId, props.itemType)
	local productId = itemData and itemData.product and tostring(itemData.product.id) or ""

	return {
		purchasingStatus = PerformFetch.GetStatus(state, CatalogConstants.PurchaseProductKey ..productId)
	}
end

local function mapDispatchToProps(dispatch)
	return {
		clearSelectedItem = function()
			dispatch(ClearSelectedItem())
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(RecommendedItemCard)
