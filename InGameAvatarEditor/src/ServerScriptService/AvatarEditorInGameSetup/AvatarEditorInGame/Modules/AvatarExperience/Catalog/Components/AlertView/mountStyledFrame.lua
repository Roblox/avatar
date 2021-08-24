local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)

local mockStyle = require(script.Parent.mockStyle)

return function(element, frame)
    if frame == nil then
        frame = Instance.new("Frame")
    end
    local tree = mockStyle(element)
    local handle = Roact.mount(tree, frame, "TestRoot")
    return frame, function()
        Roact.unmount(handle)
        frame:Destroy()
    end
end
