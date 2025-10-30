local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local ResolutionManager = {}

-- Private variable for current resolution index
local currentResolutionIndex = 1

-- Function to get current resolution
function ResolutionManager.GetCurrentResolution()
	return Constants.TEXTURE_RESOLUTION_STEPS[currentResolutionIndex]
end

-- Function to get current resolution index
function ResolutionManager.GetCurrentIndex()
	return currentResolutionIndex
end

-- Function to step down resolution
function ResolutionManager.StepDownResolution()
	currentResolutionIndex = math.min(currentResolutionIndex + 1, #Constants.TEXTURE_RESOLUTION_STEPS)
	return ResolutionManager.GetCurrentResolution()
end

-- Function to reset resolution to default
function ResolutionManager.ResetResolution()
	currentResolutionIndex = 1
	return ResolutionManager.GetCurrentResolution()
end

-- Function to set resolution from index
function ResolutionManager.SetResolutionIndex(index)
	if index >= 1 and index <= #Constants.TEXTURE_RESOLUTION_STEPS then
		currentResolutionIndex = index
		return true
	end
	return false
end

return ResolutionManager
