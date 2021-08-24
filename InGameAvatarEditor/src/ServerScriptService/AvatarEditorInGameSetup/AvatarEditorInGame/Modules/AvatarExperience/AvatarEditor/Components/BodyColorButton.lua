local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Roact = require(Modules.Common.Roact)
local RoactRodux = require(Modules.Common.RoactRodux)

local UIBlox = require(Modules.Packages.UIBlox)

local Color = require(Modules.Common.Color)
local SetBodyColors = require(Modules.AvatarExperience.AvatarEditor.Actions.SetBodyColors)
local ImageSetLabel = UIBlox.Core.ImageSet.Label
local Images = UIBlox.App.ImageSet.Images

local withStyle = UIBlox.Style.withStyle

local BodyColor = Roact.PureComponent:extend("BodyColor")

local CHECKMARK_IMAGE = Images["icons/actions/selectOn"]

local CHECKMARK_SIZE = 30
local BORDER_SIZE = 2

-- Return the bodyColor value if all parts of the humanoid are using the same color, otherwise return nil
function BodyColor:getSameBodyColor()
	local bodyColors = self.props.bodyColors
	local bodyColor = nil

	for _, value in pairs(bodyColors) do
		if bodyColor == nil then
			bodyColor = value
		elseif bodyColor ~= value then
			return nil
		end
	end

	return bodyColor
end

function BodyColor:render()
	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		local setBodyColors = self.props.setBodyColors
		local brickId = self.props.brickId
		local brickColor = self.props.brickColor

		local currentBodyColor = self:getSameBodyColor()

		local equippedFrame = nil
		-- Determine if this color should have the "equipped" frame
		if currentBodyColor == brickId then
			equippedFrame = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.8, 0, 0.8, 0),
				BackgroundTransparency = theme.Overlay.Transparency,
				BackgroundColor3 = theme.Overlay.Color,
				BorderSizePixel = 0,
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0.5, 0),
				}),

				Checkmark = Roact.createElement(ImageSetLabel, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, CHECKMARK_SIZE, 0, CHECKMARK_SIZE),
					BackgroundTransparency = 1,
					Image = CHECKMARK_IMAGE,
					ImageColor3 = theme.ContextualPrimaryContent.Color,
					ImageTransparency = theme.ContextualPrimaryContent.Transparency,
				})
			})
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			BodyColor = Roact.createElement("TextButton", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 0,
				BackgroundColor3 = Color.Color3FromHex(brickColor),
				Text = "",
				BorderSizePixel = 0,
				AutoButtonColor = false,

				ZIndex = 2,

				-- Update the store when this color has been picked.
				[Roact.Event.Activated] = function(rbx)
					if currentBodyColor ~= brickId then
						local bodyColors = {
							["headColorId"] = brickId,
							["leftArmColorId"] = brickId,
							["leftLegColorId"] = brickId,
							["rightArmColorId"] = brickId,
							["rightLegColorId"] = brickId,
							["torsoColorId"] = brickId,
						}
						setBodyColors(bodyColors)
					end
				end
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0.5, 0),
				}),

				EquippedFrame = equippedFrame
			}),
			Border = Roact.createElement("Frame", {
				Size = UDim2.new(1, BORDER_SIZE, 1, BORDER_SIZE),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = theme.Divider.Color,
				BackgroundTransparency = theme.Divider.Transparency,
				BorderSizePixel = 0,
				ZIndex = 1,
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0.5, 0),
				}),
			})
		})
	end)
end

return RoactRodux.connect(
	function(state, props)
		return {
			bodyColors = state.AvatarExperience.AvatarEditor.Character.BodyColors,
		}
	end,
	function(dispatch)
		return {
			setBodyColors = function(bodyColors)
				dispatch(SetBodyColors(bodyColors))
			end,
		}
	end
)(BodyColor)
