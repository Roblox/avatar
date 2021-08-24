local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages
local UIBlox = Packages.UIBlox
local Roact = require(Packages.Roact)
local Cryo = require(Packages.Cryo)
local PlayerTile = require(UIBlox.App.Tile.PlayerTile.PlayerTile)
local withStyle = require(UIBlox.Core.Style.withStyle)
local Images = require(UIBlox.App.ImageSet.Images)

local PlayerTileStory = Roact.PureComponent:extend("PlayerTileStory")

function PlayerTileStory:init()
	self.state = {
		tiles = {
			{
				image = nil,
				name = nil,
				username = nil,
				tileSize = UDim2.new(0, 150, 0, 150),
				buttons = {},
				relevancyInfo = {}
			},
			{
				image = nil,
				name = nil,
				username = nil,
				tileSize = UDim2.new(0, 150, 0, 150),
				buttons = {},
				relevancyInfo = {}
			},
			{
				image = nil,
				name = nil,
				username = nil,
				tileSize = UDim2.new(0, 150, 0, 150),
				buttons = {},
				relevancyInfo = {}
			},
			{
				image = nil,
				name = nil,
				username = nil,
				tileSize = UDim2.new(0, 150, 0, 150),
				buttons = {},
				relevancyInfo = {}
			},
			{
				image = nil,
				name = nil,
				username = nil,
				tileSize = UDim2.new(0, 150, 0, 150),
				buttons = {},
				relevancyInfo = {}
			}
		}
	}
end

function PlayerTileStory:didMount()
	-- Simulate component load
	spawn(function()
		wait(2.0)
		self:setState({
			tiles = {
				{
					image = "rbxthumb://type=Avatar&id=693018&w=150&h=150",
					title = "DisplayName",
					subtitle = "@username",
					tileSize = UDim2.new(0, 150, 0, 150),
					onActivated = function()
						print("Tile Pressed")
					end,
					buttons = {
						{
							icon = Images["icons/actions/friends/friendAdd"],
							onActivated = function()
								print("Button Pressed")
							end
						},
					},
					relevancyInfo = {
						text = "5 mutual friends",
						icon = Images["icons/status/player/friend"]
					}
				},
				{
					image = "rbxthumb://type=Avatar&id=693018&w=150&h=150",
					title = "DisplayName",
					subtitle = "@username",
					tileSize = UDim2.new(0, 150, 0, 150),
					onActivated = function()
						print("Tile Pressed")
					end,
					buttons = {
						{
							icon = Images["icons/actions/reject"],
							onActivated = function()
								print("Button Pressed")
							end,
							isSecondary = true,
						},
						{
							icon = Images["icons/actions/friends/friendAdd"],
							onActivated = function()
								print("Button Pressed")
							end
						},

					},
					relevancyInfo = {
						text = "You are following",
						icon = Images["icons/status/player/following"]
					}
				},
				{
					image = "rbxthumb://type=Avatar&id=693018&w=150&h=150",
					title = "DisplayName",
					subtitle = "@username",
					tileSize = UDim2.new(0, 150, 0, 150),
					onActivated = function()
						print("Tile Pressed")
					end,
					buttons = {
						{
							icon = Images["icons/actions/friends/friendpending"],
							onActivated = function()
								print("Button Pressed")
							end,
							isSecondary = true
						},
					},
					relevancyInfo = {
						text = "Adopt Me",
						icon = Images["icons/common/play"],
						onActivated = function()
							print("Relevancy Info Pressed")
						end
					}
				},
				{
					image = "rbxthumb://type=Avatar&id=693018&w=150&h=150",
					title = "LONGNAMEMWMWMWMWMWMWMWMW",
					subtitle = "@LONGNAMEMWMWMWMWMWMWMWMW",
					tileSize = UDim2.new(0, 150, 0, 150),
					onActivated = function()
						print("Tile Pressed")
					end,
					buttons = {},
					relevancyInfo = {
						text = "Relevancy info is two lines max",
						icon = Images["icons/placeholder/placeholderOn"]
					}
				},
				{
					image = "rbxthumb://type=Avatar&id=693018&w=150&h=150",
					title = "DisplayName",
					subtitle = "@username",
					tileSize = UDim2.new(0, 150, 0, 150),
					onActivated = function()
						print("Tile Pressed")
					end,
					buttons = {},
					relevancyInfo = {}
				},
			}
		})
	end)
end

function PlayerTileStory:render()
	local playerTiles = self.state.tiles
	local tiles = Cryo.List.map(playerTiles, function(tile)
		return Roact.createElement(PlayerTile, {
			title = tile.title,
			subtitle = tile.subtitle,
			onActivated = tile.onActivated,
			thumbnail = tile.image,
			tileSize = tile.tileSize,
			buttons = tile.buttons,
			relevancyInfo = tile.relevancyInfo,
		})
	end)
	table.insert(tiles, Roact.createElement("UIPadding", {
		PaddingLeft = UDim.new(0, 20),
		PaddingTop = UDim.new(0, 20),
	}))
	table.insert(tiles, Roact.createElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 20),
	}))

	return withStyle(function()
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, tiles)
    end)
end

return {
	name = "Player Tile",
	summary = "",
	controls = {
	},
	story = PlayerTileStory,
}
