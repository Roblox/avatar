local Root = script.Parent.Parent
local Roact = require(Root.Roact)
local ArgCheck = require(Root.ArgCheck)
local LocalizationConsumer = require(Root.Localization.LocalizationConsumer)

local function withLocalization(stringsToBeLocalized)
	ArgCheck.isType(stringsToBeLocalized, "table", "stringsToBeLocalized passed to withLocalization()")

	return function(render)
		ArgCheck.isType(render, "function", "render passed to withLocalization()")

		return Roact.createElement(LocalizationConsumer, {
			render = render,
			stringsToBeLocalized = stringsToBeLocalized,
		})
	end
end

return withLocalization