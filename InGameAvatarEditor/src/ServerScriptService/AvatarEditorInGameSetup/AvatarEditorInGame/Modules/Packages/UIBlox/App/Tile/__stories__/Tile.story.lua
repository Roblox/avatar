-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\Tile.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TileRoot = script.Parent.Parent
local App = TileRoot.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)

local Tile = require(TileRoot.BaseTile.Tile)
local Images = require(UIBlox.App.ImageSet.Images)

local TileStoryContainer = Roact.PureComponent:extend("TileStoryContainer")

local PADDING = 20
local FOOTER_HEIGHT = 50
local NAME_HEIGHT = 20

local function createFooter()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, FOOTER_HEIGHT),
	}, {
		TextLabel = Roact.createElement("TextLabel", {
			Text = "Your custom footer goes here.",
			Size = UDim2.new(1, 0, 1, 0),
		})
	})
end

function TileStoryContainer:init()
	self.state = {
		image = nil,
		longerLoadImage = nil,
		name = nil,
		subtitle = nil,
	}
end

function TileStoryContainer:didMount()
	-- Simulate component load
	spawn(function()
		wait(2.0)
		self:setState({
			image = "rbxassetid://924320031",
			name = "Item Name",
			subitle = "Item Subtitle",
		})
		wait(2.0)
		self:setState({
			longerLoadImage = "rbxassetid://924320031",
		})
	end)
end

function TileStoryContainer:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 20),
			PaddingTop = UDim.new(0, 20),
		}),

		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 20),
		}),

		FullItemTileContainer = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 0,
			Size = UDim2.new(0, 200, 0, 200 + NAME_HEIGHT + PADDING + FOOTER_HEIGHT),
		}, {
			FullItemTile = Roact.createElement(Tile, {
				footer = createFooter(),
				name = self.state.name,
				subtitle = self.state.subtitle,
				onActivated = function() end,
				hasRoundedCorners = false,
				thumbnail = self.state.image,
			}),
		}),

		SubtitlelessItemTileContainer = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.new(0, 200, 0, 200 + NAME_HEIGHT + PADDING + FOOTER_HEIGHT),
		}, {
			FullItemTile = Roact.createElement(Tile, {
				footer = createFooter(),
				name = self.state.name,
				subtitle = "",
				onActivated = function() end,
				hasRoundedCorners = false,
				thumbnail = self.state.image,
			}),
		}),

		LongerLoadItemTileContainer = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.new(0, 200, 0, 200 + NAME_HEIGHT + PADDING+ FOOTER_HEIGHT),
		}, {
			ThumbnailLongerLoadItemTile = Roact.createElement(Tile, {
				footer = createFooter(),
				name = self.state.name,
				onActivated = function() end,
				hasRoundedCorners = false,
				thumbnail = self.state.longerLoadImage,
			}),
		}),

		FooterlessItemTileContainer = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 200, 0, 200 + NAME_HEIGHT),
			LayoutOrder = 2,
		}, {
			FooterlessItemTile = Roact.createElement(Tile, {
				name = self.state.name,
				subtitle = self.state.subtitle,
				onActivated = function() end,
				hasRoundedCorners = false,
				thumbnail = self.state.image,
			}),
		}),

		OverriddenImageTileContainer = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 200, 0, 200 + NAME_HEIGHT),
			LayoutOrder = 3,
		}, {
			OverriddenImagesetTile = Roact.createElement(Tile, {
				name = self.state.name,
				onActivated = function() end,
				hasRoundedCorners = false,
				thumbnail = self.state.image,
				thumbnailSize = UDim2.new(0, 100, 0, 100),
				thumbnailTransparency = 0.5,
			}),
		}),

		ImagesetTileContainer = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 200, 0, 200 + NAME_HEIGHT),
			LayoutOrder = 4,
		}, {
			ImagesetTile = Roact.createElement(Tile, {
				name = "",
				onActivated = function() end,
				thumbnail = Images["icons/status/item/owned"],
				thumbnailSize = UDim2.new(0, 25, 0, 25),
			}),
		}),
	})
end

return function(target)
	local styleProvider = Roact.createElement(StoryView, {}, {
		Roact.createElement(TileStoryContainer)
	})

	local handle = Roact.mount(styleProvider, target, "TileStoryContainer")
	return function()
		Roact.unmount(handle)
	end
end