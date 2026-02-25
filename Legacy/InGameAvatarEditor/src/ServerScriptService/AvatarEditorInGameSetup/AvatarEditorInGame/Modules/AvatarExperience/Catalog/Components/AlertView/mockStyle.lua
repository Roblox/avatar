local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules


local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)
local DarkTheme = require(Modules.Common.DarkTheme)
local Gotham = require(Modules.Common.Gotham)

return function(element)
    return Roact.createElement(UIBlox.Style.Provider, {
        style = {
            Theme = DarkTheme,
            Font = Gotham,
        },
    }, {
        TestElement = element,
    })
end
