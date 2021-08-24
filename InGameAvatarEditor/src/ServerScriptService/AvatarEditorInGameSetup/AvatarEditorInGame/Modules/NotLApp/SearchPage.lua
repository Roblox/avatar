local Players = game:GetService("Players")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local UIBlox = require(Modules.Packages.UIBlox)
local withStyle = UIBlox.Style.withStyle

local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local Constants = require(Modules.NotLApp.Constants)

local CatalogSearch = require(Modules.AvatarExperience.Catalog.Components.Search.CatalogSearch)

local CatalogPageEnabled = true

local ComponentMap = {
	[Constants.SearchTypes.Catalog] = CatalogSearch,
	-- [Constants.SearchTypes.Library] = LibrarySearch,
}

local SearchPage = Roact.PureComponent:extend("SearchPage")

SearchPage.defaultProps = {
	searchType = Constants.SearchTypes.Games,
}

function SearchPage:render()
	local topBarHeight = self.props.topBarHeight
	local searchUuid = self.props.searchUuid
	local searchType = self.props.searchType
	local searchParameters = self.props.searchParameters

	return withStyle(function(style)
		local backgroundTransparency = style.Theme.BackgroundDefault.Transparency
		if searchType == Constants.SearchTypes.Catalog then
			backgroundTransparency = 1
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		},{
			SearchPage = Roact.createElement("Frame", {
				BackgroundColor3 = style.Theme.BackgroundDefault.Color,
				BackgroundTransparency = backgroundTransparency,
				Position = UDim2.new(0, 0, 0, topBarHeight),
				Size = UDim2.new(1, 0, 1, -topBarHeight),
			}, {
				Roact.createElement(ComponentMap[searchType], {
					searchUuid = searchUuid,
					searchParameters = searchParameters,
				})
			})
		})
	end)

end

SearchPage = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			topBarHeight = 0, --state.TopBar.topBarHeight,
			searchParameters = state.SearchesParameters[props.searchUuid],
			searchType = CatalogPageEnabled and state.SearchesTypes[props.searchUuid] or nil,
		}
	end
)(SearchPage)

return SearchPage
