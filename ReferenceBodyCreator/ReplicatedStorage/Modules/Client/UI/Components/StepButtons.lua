-- Decrease/increase buttons for stepping through a normalized 0–1 range.

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))
local TextButton = require(script.Parent:WaitForChild("TextButton"))

local STEP_ROUNDING_EPSILON = 1e-6

local StepButtons = {}
StepButtons.__index = StepButtons

function StepButtons:UpdateButtons()
	for button, canStep in { [self.minusButton] = self.value > 0, [self.plusButton] = self.value < 1 } do
		local enabled = self.isEnabled and canStep
		StyleUtils.SetStyleTag(button, StyleConsts.tags.StepButtonDisabled, not enabled)
	end
end

function StepButtons:Step(direction: number)
	if not self.isEnabled then
		return
	end
	-- Also handles saved values between stops without skipping the nearest stop.
	local currentStep = self.value * self.intervalCount
	local nextStep = if direction > 0
		then math.floor(currentStep + STEP_ROUNDING_EPSILON) + 1
		else math.ceil(currentStep - STEP_ROUNDING_EPSILON) - 1
	local value = math.clamp(nextStep, 0, self.intervalCount) / self.intervalCount
	if value == self.value then
		warn(`StepButtons:Step({direction}) did not change value {self.value}`)
		return
	end
	self.value = value
	self:UpdateButtons()
	self.onValueChangedCallback(value)
end

function StepButtons:SetEnabled(isEnabled: boolean)
	self.isEnabled = isEnabled
	self:UpdateButtons()
end

function StepButtons.new(
	defaultValue: number,
	onValueChangedCallback: (number) -> (),
	steps: number,
	decreaseLabel: string,
	increaseLabel: string
)
	local self = setmetatable({}, StepButtons)
	-- steps counts selectable values, so five steps span four intervals from 0 to 1.
	self.intervalCount = steps - 1
	self.value = defaultValue
	self.isEnabled = true
	self.onValueChangedCallback = onValueChangedCallback
	self.frame = Instance.new("Frame")
	self.frame.Name = "StepButtons"
	StyleUtils.AddStyleTag(self.frame, StyleConsts.tags.StepButtons)

	self.minusButton = TextButton.createComponentFrame({
		text = decreaseLabel,
		callback = function()
			self:Step(-1)
		end,
	})
	self.plusButton = TextButton.createComponentFrame({
		text = increaseLabel,
		callback = function()
			self:Step(1)
		end,
	})
	self.minusButton.Name = "Decrease"
	self.minusButton.LayoutOrder = 1
	self.minusButton.Parent = self.frame

	self.plusButton.Name = "Increase"
	self.plusButton.LayoutOrder = 2
	self.plusButton.Parent = self.frame

	self:UpdateButtons()
	return self
end

function StepButtons:GetFrame()
	return self.frame
end

return StepButtons
