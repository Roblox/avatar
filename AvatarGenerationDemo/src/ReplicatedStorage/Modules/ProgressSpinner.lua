local RunService = game:GetService("RunService")

local ROTATION_SPEED = 250

local ProgressSpinner = {}
ProgressSpinner.__index = ProgressSpinner

function ProgressSpinner.new(parent, layoutOrder)
	local self = {}
	setmetatable(self, ProgressSpinner)

	self.frame = Instance.new("Frame")
	self.frame.Name = "ProgressSpinnerFrame"
	self.frame.Size = UDim2.fromOffset(32, 32)
	self.frame.BackgroundTransparency = 1
	self.frame.LayoutOrder = layoutOrder
	self.frame.Visible = false
	self.frame.Parent = parent

	self.spinner = Instance.new("ImageLabel")
	self.spinner.Name = "ProgressSpinner"
	self.spinner.Size = UDim2.fromScale(1, 1)
	self.spinner.BackgroundTransparency = 1
	self.spinner.Image = "rbxassetid://18440711348"
	self.spinner.Parent = self.frame

	return self
end

function ProgressSpinner:Show()
	self.frame.Visible = true
	self:Disconnect()
	self.connection = RunService.RenderStepped:Connect(function(step)
		self.spinner.Rotation = self.spinner.Rotation + step * ROTATION_SPEED
	end)
end

function ProgressSpinner:Hide()
	self.frame.Visible = false
	self:Disconnect()
end

function ProgressSpinner:Disconnect()
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
end

return ProgressSpinner
