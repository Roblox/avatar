--[[
	Creates a grid of kitbash mesh buttons. Used in the kitbash UI to select
	meshes to add to the item.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")

local Config = Modules:WaitForChild("Config")
local KitbashData = require(Config:WaitForChild("StickerData"))

local TileGrid = require(Components:WaitForChild("TileGrid"))

local KitbashGrid = {}

function KitbashGrid.createComponentFrame(kitbashData, kitbashTool, onAddPieceCallback)
	local tileInfos = {}

	for _, kitbashPiece: KitbashData.KitbashData in pairs(kitbashData.pieces) do
		local onClickCallback = function()
			local minScale = kitbashPiece.minScale
			local maxScale = kitbashPiece.maxScale
			kitbashTool:SelectPiece(kitbashPiece.name, minScale, maxScale)
			onAddPieceCallback()
		end

		local info = {
			iconId = kitbashPiece.thumbnail,
			callback = onClickCallback,
		}
		table.insert(tileInfos, info)
	end

	local grid = TileGrid.createComponentFrame(tileInfos)
	grid.Name = "KitbashGrid"

	return grid
end

return KitbashGrid
