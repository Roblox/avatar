--[[
     ,,,,,,,,,,,,,,,,,,,,,,, \   /
  / (  (  (  (  (  (  (  (  \( = =)
 <  (  (  (  (  (  (  (  (  / ( ^ )
  \ (__(__(__(__(__(__(__(__)   ~
    ^  ^  ^  ^  ^  ^  ^  ^  ^

MutedError
	Throws errors in Studio development and in unit tests;
	Otherwise reports the error through MutedErrorReporter.
	Use this if you think something might go wrong in Production environment,
	but you don't want the App to stop functioning when it happens.
]]

local function IsRunningInStudio()
	return game:GetService("RunService"):IsStudio()
end

return function(errorMessage)
	if type(errorMessage) ~= "string" then
		warn("mutedError: errorMessage should be a string!")

		local success, _ = pcall(function()
			-- Attempt to convert errorMessage to a string
			errorMessage = tostring(errorMessage)
		end)

		if not success then
			-- Report a generic "mutedError" if we can't convert the message to a string
			-- At least we could still use the call stack information.
			errorMessage = "mutedError"
		end
	end

	if IsRunningInStudio() or _G.__TESTEZ_RUNNING_TEST__ then
		error(errorMessage)
	end
end
