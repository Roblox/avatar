--[[
	Generic slider, used for sizing of paintbrush and spacing of stickers.
]]
local GuiService = game:GetService("GuiService")

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local SliderInternal = {}
SliderInternal.__index = SliderInternal

function SliderInternal:ConnectDragDetector()
	self.dragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomScale

	local topLeftInset = GuiService:GetInsetArea(Enum.ScreenInsets.None).Min

	self.dragDetector.DragStart:Connect(function(inputPos)
		local value = StyleUtils.GetMousePositionScaleOnComponent(self.sliderInput, inputPos + topLeftInset).X
		self:UpdateValue(value, false --[[isFinalInput]])
	end)
	self.dragDetector.DragContinue:Connect(function(inputPos)
		local value = StyleUtils.GetMousePositionScaleOnComponent(self.sliderInput, inputPos + topLeftInset).X
		self:UpdateValue(value, false --[[isFinalInput]])
	end)
	self.dragDetector.DragEnd:Connect(function(inputPos)
		local value = StyleUtils.GetMousePositionScaleOnComponent(self.sliderInput, inputPos + topLeftInset).X
		self:UpdateValue(value, true --[[isFinalInput]])
	end)
end

function SliderInternal:UpdateValue(value: number, isFinalInput: boolean)
	self.value = value

	self.sliderBarProgress.Size = UDim2.fromScale(value, 1)
	self.onValueChangedCallback(value, isFinalInput)
end

function SliderInternal.new(defaultValue: number, onValueChangedCallback: (number, boolean) -> ())
	local self = {}
	setmetatable(self, SliderInternal)

	self.value = defaultValue
	self.onValueChangedCallback = onValueChangedCallback

	-- Create & Update UI instances
	self.frame = Instance.new("Frame")
	self.frame.Name = "Slider"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.SliderFrame)

	-- Input area -- slightly bigger than the actual bar for user convenience
	self.sliderInput = Instance.new("TextButton")
	self.sliderInput.Name = "SliderInput"
	self.sliderInput.Parent = self.frame
	self.sliderInput.Text = ""
	StyleUtils.AddStyleTag(self.sliderInput, StyleConsts.tags.SliderInput)

	-- Add the ui drag detector for moving the handle
	self.dragDetector = Instance.new("UIDragDetector")
	self.dragDetector.Parent = self.sliderInput
	self:ConnectDragDetector()

	-- Bar background
	local sliderBar = Instance.new("Frame")
	sliderBar.Name = "SliderBar"
	sliderBar.Parent = self.frame
	StyleUtils.AddStyleTag(sliderBar, StyleConsts.tags.SliderBar)

	self.sliderBarProgress = Instance.new("Frame")
	self.sliderBarProgress.Name = "BarProgress"
	self.sliderBarProgress.Parent = sliderBar

	local sliderHandle = Instance.new("Frame")
	sliderHandle.Name = "SliderHandle"
	sliderHandle.Parent = self.sliderBarProgress
	StyleUtils.AddStyleTag(sliderHandle, StyleConsts.tags.SliderHandle)

	self:UpdateValue(self.value, true)

	return self
end

local SliderPublic = {}
function SliderPublic.createComponentFrame(defaultValue: number, onValueChangedCallback)
	local Slider = SliderInternal.new(defaultValue, onValueChangedCallback)

	return Slider.frame
end

return SliderPublic
