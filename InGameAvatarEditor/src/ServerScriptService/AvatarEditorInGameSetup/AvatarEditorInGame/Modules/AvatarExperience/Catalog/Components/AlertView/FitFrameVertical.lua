local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local Immutable = require(Modules.Common.Immutable)

local FitFrameVertical = Roact.PureComponent:extend("FitFrameVertical")
FitFrameVertical.defaultProps = {
	AnchorPoint = Vector2.new(0,0),
	Position = UDim2.new(0, 0, 0, 0),
	width = UDim.new(0, 0),
	contentPadding = UDim.new(0, 0),
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	marginTop = 0,
	marginBottom = 0,
	marginLeft = 0,
	marginRight = 0,
}

function FitFrameVertical:init()
	self.layoutRef = Roact.createRef()
	self.frameRef = Roact.createRef()

	self.onResize = function()
		local currentLayout = self.layoutRef.current
		local currentFrame = self.frameRef.current
		if not currentFrame or not currentLayout then
			return
		end

		local width = self.props.width
		local absoluteContentSize = currentLayout.AbsoluteContentSize
		local fullHeight = absoluteContentSize.Y

		currentFrame.Size = UDim2.new(width, UDim.new(0, fullHeight + self.props.marginTop + self.props.marginBottom))
	end
end

function FitFrameVertical:render()
	local backgroundColor3 = self.props.BackgroundColor3
	local children = self.props[Roact.Children] or {}
	local width = self.props.width
	local horizontalAlignment = self.props.HorizontalAlignment
	local backgroundTransparency = self.props.BackgroundTransparency
	local contentPadding = self.props.contentPadding
	local layoutOrder = self.props.LayoutOrder
	local fillDirection = self.props.FillDirection
	local verticalAlignment = self.props.VerticalAlignment

	local fullHeight = 0
	if self.layoutRef.current then
		fullHeight = self.layoutRef.current.AbsoluteContentSize.Y
	end

	return Roact.createElement("Frame", {
		AnchorPoint = self.props.AnchorPoint,
		Position = self.props.Position,
		BackgroundColor3 = backgroundColor3,
		BackgroundTransparency = backgroundTransparency,
		Size = UDim2.new(width.Scale, width.Offset, 0, fullHeight),
		LayoutOrder = layoutOrder,
		[Roact.Ref] = self.frameRef,
		Visible = self.props.Visible,
		BorderSizePixel = 0,
	},
		Immutable.JoinDictionaries(children, {
			layout = Roact.createElement("UIListLayout", {
				Padding = contentPadding,
				FillDirection = fillDirection,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = horizontalAlignment,
				VerticalAlignment = verticalAlignment,
				[Roact.Ref] = self.layoutRef,
				[Roact.Change.AbsoluteContentSize] = self.onResize,
			}),
			padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, self.props.marginLeft),
				PaddingRight = UDim.new(0, self.props.marginRight),
				PaddingTop = UDim.new(0, self.props.marginTop),
				PaddingBottom = UDim.new(0, self.props.marginBottom),
			})
		})
	)
end

function FitFrameVertical:didMount()
	self.onResize()
end

function FitFrameVertical:didUpdate()
	self.onResize()
end

return FitFrameVertical
