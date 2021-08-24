local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Common.Roact)
local Immutable = require(Modules.Common.Immutable)
local Text = require(Modules.Common.Text)

local FitChildren = require(Modules.NotLApp.FitChildren)

local FitTextLabel = Roact.PureComponent:extend("FitTextLabel")

FitTextLabel.defaultProps = {
	fitAxis = FitChildren.FitAxis.Height,
	maxWidth = nil,
}

function FitTextLabel:init()
	self.onRef = function(rbx)
		self.ref = rbx
	end

	self.resize = function(rbx)
		local fitAxis = self.props.fitAxis
		local maxWidth = self.props.maxWidth

		-- Unlike the other fit components, FitTextLabel defaults to expanding only height, instead of
		-- expanding on both axis. This is because expanding on both is functionally the same as expanding
		-- on width only, because if a width isn't specified there's no way to know where to break the
		-- lines, so it'll end up entirely on one line anyway. And the common case of a resizable text field
		-- is to have a set width with an unknown number of lines depending on the length of the text.
		if fitAxis == FitChildren.FitAxis.Width or fitAxis == FitChildren.FitAxis.Both then
			local width = UDim.new(0, Text.GetTextWidth(rbx.Text, rbx.Font, rbx.TextSize))
			local height

			if maxWidth ~= nil and width.Offset > maxWidth then
				width = UDim.new(0, maxWidth)
				height = UDim.new(0, Text.GetTextHeight(rbx.Text, rbx.Font, rbx.TextSize, width.Offset))
			else
				height = fitAxis == FitChildren.FitAxis.Both
					and UDim.new(0, rbx.TextSize) or rbx.Size.Height
			end

			rbx.Size = UDim2.new(width, height)
		else
			local height = UDim.new(0, Text.GetTextHeight(rbx.Text, rbx.Font, rbx.TextSize,
				rbx.AbsoluteSize.X))
			rbx.Size = UDim2.new(rbx.Size.Width, height)
		end
	end
end

function FitTextLabel:render()
	local fitAxis = self.props.fitAxis or FitChildren.FitAxis.Height
	local frameProps = Immutable.RemoveFromDictionary(self.props, "fitAxis", "maxWidth")

	return Roact.createElement("TextLabel",
		Immutable.JoinDictionaries(frameProps, {
			[Roact.Ref] = self.onRef,
			[Roact.Change.Text] = self.resize,
			[Roact.Change.TextSize] = self.resize,
			[Roact.Change.AbsoluteSize] = (fitAxis == FitChildren.FitAxis.Height) and self.resize or nil,
		})
	)
end

function FitTextLabel:didMount()
	self.resize(self.ref)
end

return FitTextLabel