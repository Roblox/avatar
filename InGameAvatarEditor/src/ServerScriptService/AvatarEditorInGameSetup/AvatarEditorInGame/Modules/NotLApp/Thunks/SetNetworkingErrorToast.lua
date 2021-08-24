local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local ToastType = require(Modules.NotLApp.Enum.ToastType)
local getLocalizedToastStringFromHttpError = require(Modules.NotLApp.getLocalizedToastStringFromHttpError)
local SetCurrentToastMessage = require(Modules.NotLApp.Actions.SetCurrentToastMessage)

return function(err)
	return function(store)
		local toastMessage = getLocalizedToastStringFromHttpError(err.HttpError, err.StatusCode)
		if toastMessage ~= nil then
			store:dispatch(SetCurrentToastMessage({
				toastType = ToastType.NetworkingError,
				toastMessage = toastMessage,
			}))
		end
	end
end