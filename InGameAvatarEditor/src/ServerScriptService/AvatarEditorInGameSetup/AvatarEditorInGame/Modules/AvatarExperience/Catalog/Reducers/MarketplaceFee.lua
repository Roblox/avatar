local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Cryo = require(Modules.Packages.Cryo)
local MarketplaceFeeInfo = require(Modules.AvatarExperience.Common.Models.MarketplaceFeeInfo)

local Rodux = require(Modules.Packages.Rodux)

local SetMarketplaceFee = require(Modules.AvatarExperience.Catalog.Actions.SetMarketplaceFee)

local default = {}

return Rodux.createReducer(default, {
	[SetMarketplaceFee.name] = function(state, action)
		local newData = MarketplaceFeeInfo.fromGetResaleTaxRate(action.marketplaceFeeInfo)
		return Cryo.Dictionary.join(state, newData)
    end,
})