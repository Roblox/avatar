--[[
	Creates a grid of sticker buttons. Used in the sticker and pattern sticker
	UIs.
	For the pattern UI, we change styling based on selection.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")

local Config = Modules:WaitForChild("Config")
local StickerData = require(Config:WaitForChild("StickerData"))

local TileGrid = require(Components:WaitForChild("TileGrid"))

local StickerGrid = {}

function StickerGrid.createComponentFrame(stickerData, stickerTool, onAddStickerCallback, isPatterned)
	local tileInfos = {}

	for _, sticker: StickerData.StickerData in pairs(stickerData) do
		local onClickCallback = function()
			stickerTool:ApplySticker(sticker.textureId)
			onAddStickerCallback()
			if isPatterned then
				stickerTool:SetPatterned(true)
			end
		end

		local info = {
			iconId = sticker.textureId,
			callback = onClickCallback,
		}
		table.insert(tileInfos, info)
	end

	local grid = TileGrid.createComponentFrame(tileInfos)
	grid.Name = "StickerGrid"

	return grid
end

return StickerGrid
