local PurchaseErrors = require(script.parent.Enum.PurchaseErrors)

local function doHash(title, showDivId)
	return tostring(title) .. '.' .. tostring(showDivId)
end

local TitleAndShowDivIdToError = {
	-- TODO: handle price changed (MOBLUAPP-1012)
	[doHash(nil, "PriceChangedView")] = PurchaseErrors.UnknownFailure,
	-- TODO: handle insufficient membership (MOBLUAPP-1032)
	[doHash("Membership Level Too Low", "TransactionFailureView")] = PurchaseErrors.UnknownFailure,
	[doHash("Purchases are Currently Disabled", "TransactionFailureView")] = PurchaseErrors.PurchaseDisabled,
	[doHash("Item Not For Sale", "TransactionFailureView")] = PurchaseErrors.NotForSale,
	[doHash("Age Restricted Item", "TransactionFailureView")] = PurchaseErrors.Under13,
	[doHash("Item Owned", "TransactionFailureView")] = PurchaseErrors.AlreadyOwn,
	[doHash("Too Many Purchases", "TransactionFailureView")] = PurchaseErrors.TooManyPurchases,
	[doHash("Invalid Parameter", "TransactionFailureView")] = PurchaseErrors.InvalidRequest,
	[doHash("Unauthorized", "TransactionFailureView")] = PurchaseErrors.Unauthorized,
}

local function getErrorTypeFromTitleAndShowDivId(title, showDivId)
	return TitleAndShowDivIdToError[doHash(title, showDivId)]
end

local function getPurchaseErrorTypeFromErrorResponse(err)
	assert(err ~= nil and type(err) == "table", "err must be a valid table!")

	local title = err.title
	local showDivId = err.showDivId
	local shortfallPrice = err.shortfallPrice

	if (showDivId == "TransactionFailureView" or showDivId == "InsufficientFundsView") and
		shortfallPrice ~= nil and shortfallPrice > 0 then
		return PurchaseErrors.NotEnoughRobux
	else
		local errorType = getErrorTypeFromTitleAndShowDivId(title, showDivId)

		return errorType or PurchaseErrors.UnknownFailure
	end
end

return getPurchaseErrorTypeFromErrorResponse