local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local ExpandableTextArea = UIBlox.App.Text.ExpandableTextArea
local ShimmerPanel = UIBlox.Loading.ShimmerPanel
local withStyle = UIBlox.Style.withStyle

local TOP_PADDING = 30
local PADDING = 5

local GetFFlagLuaCatalogRefactorSpawns = function() return false end

local ItemDescription = Roact.PureComponent:extend("ItemDescription")

ItemDescription.defaultProps = {
	compactNumberOfLines = 3,
}

function ItemDescription:render()
	local descriptionText = self.props.descriptionText
	local position = self.props.Position
	local compactNumberOfLines = self.props.compactNumberOfLines
	local layoutOrder = self.props.LayoutOrder
	local width = self.props.width

	if descriptionText then
		return Roact.createElement(ExpandableTextArea, {
			LayoutOrder = layoutOrder,
			Position = position,
			Text = descriptionText,

			compactNumberOfLines = compactNumberOfLines,
			--width = not GetFFlagLuaCatalogRefactorSpawns() and UDim.new(0, width) or nil,
		})
	else
		return withStyle(function(stylePalette)
			local font = stylePalette.Font
			local textSize = font.BaseSize * font.Body.RelativeSize

			local shimmerHeight = compactNumberOfLines * textSize + PADDING
			local totalHeight = shimmerHeight + TOP_PADDING

			return Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = layoutOrder,
				Size = GetFFlagLuaCatalogRefactorSpawns() and UDim2.new(1, 0, 0, totalHeight) or UDim2.new(0, width, 0, totalHeight),
			}, {
				Roact.createElement(ShimmerPanel, {
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.new(0, 0, 1, 0),
					Size = UDim2.new(0, width, 0, shimmerHeight),
				})
			})
		end)
	end
end

return ItemDescription
