--[[
	Model for an UserAsset
	{
		userAssetId = string,
		userId = name,
		userName = string,
		serialNumber = optional string,
		priceInRobux = optional int
	}
]]
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local MockId = require(Modules.NotLApp.MockId)

local UserAssetModel = {}

function UserAssetModel.mock()
	local self = {}

	self.userAssetId = tostring(MockId())
	self.userId = tostring(MockId())
	self.userName = ""
	self.serialNumber = tostring(MockId())
	self.priceInRobux = 0

	return self
end

function UserAssetModel.fromSellPageAndResellers(newData)
	local userAssetInfo = {}

	userAssetInfo.userAssetId = tostring(newData.userAssetId)
	if newData.seller then
		userAssetInfo.userId = tostring(newData.seller.id)
		userAssetInfo.userName = newData.seller.name
	end

	userAssetInfo.serialNumber = newData.serialNumber and tostring(newData.serialNumber) or nil
	userAssetInfo.priceInRobux = newData.price
	return userAssetInfo
end

function UserAssetModel.fromPriceInRobux(userAssetId, priceInRobux)
	local userAssetInfo = {}

	userAssetInfo.userAssetId = tostring(userAssetId)
	userAssetInfo.priceInRobux = priceInRobux

	return userAssetInfo
end

return UserAssetModel