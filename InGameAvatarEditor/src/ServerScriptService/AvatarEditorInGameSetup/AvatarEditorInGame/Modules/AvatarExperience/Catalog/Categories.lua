-- Tables describing each Category and Subcategory in the Catalog page

--[[
	Tables describing each Category and Subcategory in the Avatar Editor page

	RenderItemTiles: Describes if this pages renders standard UIBlox item tiles.
	RecommendationsType: Describes if we show recommendations based on this page type and what kind.
]]
local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local LayeredClothingEnabled = require(Modules.Config.LayeredClothingEnabled)

local OldCategories = require(Modules.AvatarExperience.Catalog.OldCategories)
local LCCategories = require(Modules.AvatarExperience.Catalog.LCCategories)

if LayeredClothingEnabled then
	return LCCategories
else
	return OldCategories
end

