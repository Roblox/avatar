--[[
	Generic slider, used for sizing of paintbrush and spacing of stickers.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))

local SliderInternal = {}
SliderInternal.__index = SliderInternal

function SliderInternal:HandleInput(input: InputObject)
	if input.UserInputType == Enum.UserInputType.MouseMovement and self.isDragging ~= true then
		-- User is just moving mouse, but hasn't yet clicked on the slider
		return
	end

	if self.inputManager:TryGrabLock(self) == false then
		return
	end

	if Utils.isValidDraggingInput(input) then
		self.isDragging = true
		local value = Utils.getMousePositionScaleOnComponent(self.sliderInput, input.Position).X
		self:UpdateValue(value, false --[[isFinalInput]])
	end
end

function SliderInternal:HandleInputEnd(input: InputObject)
	if
		-- Make sure we're dragging, and that the ended input is relevant
		self.isDragging ~= true
		or input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
	then
		return
	end

	self.isDragging = false
	local value = Utils.getMousePositionScaleOnComponent(self.sliderInput, input.Position).X
	self:UpdateValue(value, true --[[isFinalInput]])
end

function SliderInternal:UpdateValue(value: number, isFinalInput: boolean)
	self.value = value

	self.sliderBarProgress.Size = UDim2.fromScale(value, 1)
	self.onValueChangedCallback(value, isFinalInput)
end

function SliderInternal.new(inputManager, defaultValue: number, onValueChangedCallback: (number, boolean) -> ())
	local self = {}
	setmetatable(self, SliderInternal)

	-- Since this is a draggable component, an input manager is used to prevent
	-- input from affecting other components if the cursor leaves the component
	-- while dragging.
	self.inputManager = inputManager

	self.value = defaultValue
	self.onValueChangedCallback = onValueChangedCallback
	self.isDragging = false

	-- Create & Update UI instances
	self.frame = Instance.new("Frame")
	self.frame.Name = "Slider"
	Utils.AddStyleTag(self.frame, StyleConsts.tags.SliderFrame)

	-- Input area -- slightly bigger than the actual bar for user convenience
	self.sliderInput = Instance.new("TextButton")
	self.sliderInput.Name = "SliderInput"
	self.sliderInput.Parent = self.frame
	self.sliderInput.Text = ""
	Utils.AddStyleTag(self.sliderInput, StyleConsts.tags.SliderInput)

	-- Bar background
	local sliderBar = Instance.new("Frame")
	sliderBar.Name = "SliderBar"
	sliderBar.Parent = self.frame
	Utils.AddStyleTag(sliderBar, StyleConsts.tags.SliderBar)

	self.sliderBarProgress = Instance.new("Frame")
	self.sliderBarProgress.Name = "BarProgress"
	self.sliderBarProgress.Parent = sliderBar

	local sliderHandle = Instance.new("Frame")
	sliderHandle.Name = "SliderHandle"
	sliderHandle.Parent = self.sliderBarProgress
	Utils.AddStyleTag(sliderHandle, StyleConsts.tags.SliderHandle)

	self:UpdateValue(self.value, true)

	-- Connect input
	self.sliderInput.InputBegan:Connect(function(input)
		self:HandleInput(input)
	end)
	self.sliderInput.InputChanged:Connect(function(input)
		self:HandleInput(input)
	end)
	self.sliderInput.InputEnded:Connect(function(input)
		self:HandleInputEnd(input)
	end)

	return self
end

local SliderPublic = {}
function SliderPublic.createComponentFrame(inputManager, defaultValue: number, onValueChangedCallback)
	local Slider = SliderInternal.new(inputManager, defaultValue, onValueChangedCallback)

	return Slider.frame
end

return SliderPublic
