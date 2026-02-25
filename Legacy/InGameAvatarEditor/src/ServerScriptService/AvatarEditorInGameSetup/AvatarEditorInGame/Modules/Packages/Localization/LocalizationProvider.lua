local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local LocalizationKey = require(Modules.Packages.Localization.LocalizationKey)

local LocalizationProvider = Roact.Component:extend("LocalizationProvider")

function LocalizationProvider:init(props)
	local localization = props.localization
	self._context[LocalizationKey] = {
		localization = localization
	}
end

function LocalizationProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

return LocalizationProvider
