local Root = script.Parent.Parent
local LocalizationService = game:GetService("LocalizationService")

local Roact = require(Root.Roact)
local ExternalEventConnection = require(Root.RoactUtilities.ExternalEventConnection)

local ArgCheck = require(Root.ArgCheck)
local LocalizationKey = require(Root.Localization.LocalizationKey)

local LocalizationConsumer = Roact.Component:extend("LocalizationConsumer")

function LocalizationConsumer:init()
	local localization = self._context[LocalizationKey].localization

	if localization == nil then
		error("LocalizationConsumer must be below a LocalizationProvider.")
	end

	self.state = {
		locale = LocalizationService.RobloxLocaleId,
	}

	self.updateLocalization = function(newLocale)
		if newLocale ~= self.state.locale then
			self:setState({
				locale = newLocale
			})
		end
	end

	if true then
		self.connections = {
			localization.changed:connect(self.updateLocalization)
		}
	end
end

function LocalizationConsumer:willUnmount()
	if true then
		for _, connection in pairs(self.connections) do
			connection:disconnect()
		end
	end
end

function LocalizationConsumer:render()
	local localization = self._context[LocalizationKey].localization
	local render = self.props.render
	local stringsToBeLocalized = self.props.stringsToBeLocalized

	ArgCheck.isType(render, "function", "LocalizationConsumer.props.render")
	ArgCheck.isType(stringsToBeLocalized, "table", "LocalizationConsumer.props.stringsToBeLocalized")

	local localizedStrings = {}
	for stringName, stringInfo in pairs(stringsToBeLocalized) do
		if typeof(stringInfo) == "table" then
			if typeof(stringInfo[1]) == "string" then
				local success, result = pcall(function()
					return localization:Format(stringInfo[1], stringInfo)
				end)

				ArgCheck.isEqual(success, true, string.format(
					"LocalizationConsumer finding value for translation key[%s]: %s", stringName, stringInfo[1]))

				localizedStrings[stringName] = success and result or ""
			else
				error(string.format("%s[1] in stringsToBeLocalized must be a string, got %s instead",
					stringName, typeof(stringInfo[1])))
			end
		elseif typeof(stringInfo) == "string" then
			local success, result = pcall(function()
				return localization:Format(stringInfo)
			end)

			ArgCheck.isEqual(success, true, string.format(
				"LocalizationConsumer finding value for translation key[%s]: %s", stringName, stringInfo))

			localizedStrings[stringName] = success and result or ""
		else
			error(string.format("%s in stringsToBeLocalized must be a string or table, got %s instead",
				stringName, typeof(stringInfo)))
		end
	end

	return Roact.createElement(ExternalEventConnection, {
		event = LocalizationService:GetPropertyChangedSignal("RobloxLocaleId"),
		callback = self.updateLocalization,
	}, {
		Component = render(localizedStrings),
	})
end

return LocalizationConsumer
