local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Signal = require(Modules.Common.Signal)

return {
	ReloadPage = Signal.new(),
	ReportMutedError = Signal.new(),
}