local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Symbol = require(Modules.Common.Symbol)

return {
    Hidden = Symbol.named("Hidden"),
    Closed = Symbol.named("Closed"),
    Brief = Symbol.named("Brief"),
    Full = Symbol.named("Full"),
    Extended = Symbol.named("Extended"),
}