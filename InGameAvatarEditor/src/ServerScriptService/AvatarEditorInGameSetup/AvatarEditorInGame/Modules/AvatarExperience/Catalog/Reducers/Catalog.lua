local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local BundleFavorites = require(Modules.AvatarExperience.Catalog.Reducers.BundleFavorites)
local AssetFavorites = require(Modules.AvatarExperience.Catalog.Reducers.AssetFavorites)
local Categories = require(Modules.AvatarExperience.Catalog.Reducers.Categories)
local MarketplaceFee = require(Modules.AvatarExperience.Catalog.Reducers.MarketplaceFee)
local Sell = require(Modules.AvatarExperience.Catalog.Reducers.Sell)
local SortsContents = require(Modules.AvatarExperience.Catalog.Reducers.SortsContents)
local FullView = require(Modules.AvatarExperience.Catalog.Reducers.FullView)
local UIFullView = require(Modules.AvatarExperience.Catalog.Reducers.UIFullView)
local UserAssets = require(Modules.AvatarExperience.Catalog.Reducers.UserAssets)
local ResellerCursor = require(Modules.AvatarExperience.Catalog.Reducers.ResellerCursor)
local SortAndFilters = require(Modules.AvatarExperience.Catalog.Reducers.SortAndFilters)

return function(state, action)
	state = state or {}
	return {
		AssetFavorites = AssetFavorites(state.AssetFavorites, action),
		BundleFavorites = BundleFavorites(state.BundleFavorites, action),
		Categories = Categories(state.Categories, action),
		FullView = FullView(state.FullView, action),
		UIFullView = UIFullView(state.UIFullView, action),
		MarketplaceFee = MarketplaceFee(state.MarketplaceFee, action),
		Sell = Sell(state.Sell, action),
		SortsContents = SortsContents(state.SortsContents, action),
		ResellerCursor = ResellerCursor(state.ResellerCursor, action),
		UserAssets = UserAssets(state.UserAssets, action),
		SortAndFilters = SortAndFilters(state.SortAndFilters, action),
	}
end