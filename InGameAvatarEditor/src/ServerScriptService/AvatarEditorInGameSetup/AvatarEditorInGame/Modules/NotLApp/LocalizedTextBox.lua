local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Cryo = require(Modules.Packages.Cryo)
local Roact = require(Modules.Packages.Roact)
local withLocalization = require(Modules.Packages.Localization.withLocalization)

return function(props)
	return withLocalization({
		localizedText = props.PlaceholderText,
	})(function(localized)
		return Roact.createElement("TextBox", Cryo.Dictionary.join(props, {
			PlaceholderText = localized.localizedText,
		}))
	end)
end
