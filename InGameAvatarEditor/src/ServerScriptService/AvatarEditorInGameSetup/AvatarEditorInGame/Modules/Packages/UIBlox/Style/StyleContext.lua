local Style = script.Parent
local UIBlox = Style.Parent

local Packages = UIBlox.Parent
local Roact = require(Packages.Roact)

return Roact.createContext(nil)