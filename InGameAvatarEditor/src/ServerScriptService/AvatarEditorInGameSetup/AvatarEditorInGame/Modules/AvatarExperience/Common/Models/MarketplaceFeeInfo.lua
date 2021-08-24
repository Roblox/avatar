--[[
	Model for the MarketplaceFee (e.g. Hat).
	{
		taxRate = number,
		minimumFee = number,
	}
]]
local MarketplaceFeeInfo = {}

function MarketplaceFeeInfo.mock()
	local self = {}

	self.taxRate = 0.3
	self.minimumFee = 1

	return self
end

function MarketplaceFeeInfo.fromGetResaleTaxRate(newData)
	local MarketplaceFeeInfo = {}

	MarketplaceFeeInfo.taxRate = newData.taxRate
	MarketplaceFeeInfo.minimumFee = newData.minimumFee

	return MarketplaceFeeInfo
end

return MarketplaceFeeInfo