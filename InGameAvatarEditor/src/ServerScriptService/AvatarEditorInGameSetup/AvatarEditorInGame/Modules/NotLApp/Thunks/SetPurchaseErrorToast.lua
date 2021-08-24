local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ToastType = require(Modules.NotLApp.Enum.ToastType)
local SetCurrentToastMessage = require(Modules.NotLApp.Actions.SetCurrentToastMessage)
local getPurchaseErrorTypeFromErrorResponse = require(Modules.NotLApp.getPurchaseErrorTypeFromErrorResponse)
local PurchaseErrorLocalizationKeys = require(Modules.NotLApp.PurchaseErrorLocalizationKeys)

return function(data)
	return function(store)
		local purchaseErrorType = getPurchaseErrorTypeFromErrorResponse(data)
		local toastMessage = PurchaseErrorLocalizationKeys[purchaseErrorType]

		store:dispatch(SetCurrentToastMessage({
			toastType = ToastType.PurchaseMessage,
			toastMessage = toastMessage,
		}))
	end
end