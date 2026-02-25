local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Packages.Roact)
local UIBlox = require(Modules.Packages.UIBlox)

local FitChildren = require(Modules.NotLApp.FitChildren)
local withStyle = UIBlox.Style.withStyle

local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)

local PillBar = Roact.PureComponent:extend("PillBar")
local FFlagUIGradientEnabled = settings():GetFFlag("UIGradientEnabled")

local GRADIENT_SIZE = 50

function PillBar:init()
    self.gradientFrameRef = Roact.createRef()
    self.scrollingFrameRef = Roact.createRef()
    self.categoryButtonRefs = {}

    self.state = {
        showLeftGradient = false,
        showRightGradient = false,
    }

    self.checkShowGradient = function(rbx)
        local showGradient, showLeft, showRight = AvatarExperienceUtils.shouldShowGradientForScrollingFrame(rbx)

        showLeft = showGradient and showLeft
        showRight = showGradient and showRight

        if self.state.showLeftGradient ~= showLeft or self.state.showRightGradient ~= showRight then
            self:setState({
                showLeftGradient = showLeft,
                showRightGradient = showRight,
            })
        end
    end

    self.onNavFrameSizeChanged = function(rbx)
        if self.scrollingFrameRef.current then
            self.scrollingFrameRef.current.CanvasSize = UDim2.new(0, rbx.AbsoluteSize.X, 1, 0)
        end
    end
end

local function renderGradient(theme, rotation)
    return FFlagUIGradientEnabled and Roact.createElement("UIGradient", {
        Rotation = rotation,
        Color = ColorSequence.new(theme.BackgroundDefault.Color),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.666, 1),
            NumberSequenceKeypoint.new(1, 1)
        }),
    })
end

function PillBar:render()
    local layoutOrder = self.props.layoutOrder

    return withStyle(function(stylePalette)
        local theme = stylePalette.Theme

        return Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.BackgroundDefault.Color,
            BackgroundTransparency = theme.BackgroundDefault.Transparency,
            BorderSizePixel = 0,
            LayoutOrder = layoutOrder,
        }, {
            Left = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, GRADIENT_SIZE, 1, 0),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                ZIndex = 2,
                Visible = self.state.showLeftGradient,
            }, {
                Gradient = renderGradient(theme, 0)
            }),
            Right = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.new(0, GRADIENT_SIZE, 1, 0),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                ZIndex = 2,
                Visible = self.state.showRightGradient,
            }, {
                Gradient = renderGradient(theme, 180)
            }),
            ScrollingList = Roact.createElement("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0),
                ScrollBarThickness = 0,
                BackgroundTransparency = 1,
                ZIndex = 1,

                ElasticBehavior = Enum.ElasticBehavior.Always,
                ScrollingDirection = Enum.ScrollingDirection.X,

                [Roact.Change.AbsoluteSize] = self.checkShowGradient,
                [Roact.Change.CanvasSize] = self.checkShowGradient,
                [Roact.Change.CanvasPosition] = self.checkShowGradient,

                [Roact.Ref] = self.scrollingFrameRef,
            }, {
                SubNavFrame = Roact.createElement(FitChildren.FitFrame, {
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundTransparency = 1,
                    fitFields = {
                        Size = FitChildren.FitAxis.Width,
                    },
                    [Roact.Change.AbsoluteSize] = self.onNavFrameSizeChanged,
                }, self.props[Roact.Children]),
            }),
        })
    end)
end

return PillBar