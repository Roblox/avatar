local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local StatusCodes = require(Modules.Http.StatusCodes)

local NO_CONNECTION_ERROR_STRING = "Feature.Toast.NetworkingError.UnableToConnect"
local TIME_OUT_STRING = "Feature.Toast.NetworkingError.Timeout"
local DEFAULT_STRING = "Feature.Toast.NetworkingError.SomethingIsWrong"

local STATUS_CODE_TO_STRING = {
	[StatusCodes.BAD_REQUEST] = "Feature.Toast.NetworkingError.SomethingIsWrong",
	[StatusCodes.UNAUTHORIZED] = "Feature.Toast.NetworkingError.Unauthorized",
	[StatusCodes.FORBIDDEN] = "Feature.Toast.NetworkingError.Forbidden",
	[StatusCodes.NOT_FOUND] = "Feature.Toast.NetworkingError.NotFound",
	[StatusCodes.REQUEST_TIMEOUT] = "Feature.Toast.NetworkingError.Timeout",
	[StatusCodes.TOO_MANY_REQUESTS] = "Feature.Toast.NetworkingError.TooManyRequests",
	[StatusCodes.INTERNAL_SERVER_ERROR] = "Feature.Toast.NetworkingError.SomethingIsWrong",
	[StatusCodes.NOT_IMPLEMENTED] = "Feature.Toast.NetworkingError.SomethingIsWrong",
	[StatusCodes.BAD_GATEWAY] = "Feature.Toast.NetworkingError.SomethingIsWrong",
	[StatusCodes.SERVICE_UNAVAILABLE] = "Feature.Toast.NetworkingError.ServiceUnavailable",
	[StatusCodes.GATEWAY_TIMEOUT] = "Feature.Toast.NetworkingError.Timeout",
}

--[[
	returns a localization key that gets displayed to the user when a network
	request has failed.
	Inputs:
		httpError -- user data type. (Enum.HttpError.*)
		statusCode -- number.
]]
local function getLocalizedToastStringFromHttpError(httpError, statusCode)
	if httpError == nil or type(httpError) ~= "userdata" then
		print(httpError)
		error("getLocalizedToastStringFromHttpError: Must have a valid httpError!")
	end

	if statusCode ~= nil and type(statusCode) ~= "number" then
		error("getLocalizedToastStringFromHttpError: statusCode must be a number!")
	end

	if httpError == Enum.HttpError.DnsResolve or httpError == Enum.HttpError.ConnectFail or
		httpError == Enum.HttpError.NetFail or httpError == Enum.HttpError.SslConnectFail then
		return NO_CONNECTION_ERROR_STRING
	elseif httpError == Enum.HttpError.TimedOut then
		return TIME_OUT_STRING
	-- We shouldn't report any errors if the network request is canceled.
	elseif httpError == Enum.HttpError.Aborted then
		return nil
	elseif httpError == Enum.HttpError.OK and statusCode ~= nil and STATUS_CODE_TO_STRING[statusCode] ~= nil then
		return STATUS_CODE_TO_STRING[statusCode]
	end

	return DEFAULT_STRING
end

return getLocalizedToastStringFromHttpError