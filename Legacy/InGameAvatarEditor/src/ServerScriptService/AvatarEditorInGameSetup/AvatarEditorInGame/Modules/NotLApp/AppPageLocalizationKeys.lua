local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local AppPageProperties = require(Modules.NotLApp.AppPageProperties)

local result = {}
for key, value in pairs(AppPageProperties) do
	result[key] = value.nameLocalizationKey
end

return result
