local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Action = require(Modules.Common.Action)
local ArgCheck = require(Modules.Common.ArgCheck)

return Action(script.Name, function(minPrice, maxPrice)
	ArgCheck.isType(minPrice, "number", "SetPriceRange expects minPrice")
	ArgCheck.isType(maxPrice, "number", "SetPriceRange expects maxPrice")

	return {
		priceRange = {
			minPrice = minPrice,
			maxPrice = maxPrice,
		}
	}
end)