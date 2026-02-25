local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local withStyle = UIBlox.Style.withStyle

local ExternalEventConnection = UIBlox.Utility.ExternalEventConnection
local ImageSetLabel = UIBlox.Core.ImageSet.Label

local RETRY_SPINNER_IMAGE = "LuaApp/icons/icon_retry_white"

local Spinner = Roact.PureComponent:extend("Spinner")

Spinner.defaultProps = {
	Size = UDim2.new(0, 20, 0, 20),
	spinSpeed = 540,
}

function Spinner:init()
	self.renderSteppedCallback = function(dt)
		local isSpinning = self.props.isSpinning
		local spinSpeed = self.props.spinSpeed

		if isSpinning and self.ref.current then
			self.ref.current.Rotation = self.ref.current.Rotation + spinSpeed * dt
		end
	end
end

function Spinner:render()
	local size = self.props.Size
	local position = self.props.Position
	local anchorPoint = self.props.AnchorPoint
	local imageColor3 = self.props.ImageColor3
	local imageTransparency = self.props.ImageTransparency
	local isSpinning = self.props.isSpinning

	self.ref = self.props[Roact.Ref] or self.ref or Roact.createRef()

	return withStyle(function(style)
		return Roact.createElement(ImageSetLabel, {
			Size = size,
			Position = position,
			AnchorPoint = anchorPoint,
			BackgroundTransparency = 1,
			Image = RETRY_SPINNER_IMAGE,
			ImageColor3 = imageColor3 or style.Theme.SystemPrimaryDefault.Color,
			ImageTransparency = imageTransparency or style.Theme.SystemPrimaryDefault.Transparency,
			[Roact.Ref] = self.ref,
		}, {
			renderStepped = isSpinning and Roact.createElement(ExternalEventConnection, {
				event = RunService.renderStepped,
				callback = self.renderSteppedCallback,
			}),
		})
	end)
end

return Spinner