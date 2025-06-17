-- Server-side initialization

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local DemoModel = require(ReplicatedStorage:WaitForChild("DemoModel"))

local lastEquippedDemoModel = nil

-- Callback used to switch the last equipped DemoModel's action back to Equip
-- when a different avatar model is equipped.
local function onDemoModelEquip(equippedModel)
	if lastEquippedDemoModel and lastEquippedDemoModel ~= equippedModel then
		-- If there was a previously equipped model, invoke onUnequip on it
		lastEquippedDemoModel:onUnequip()
	end
	lastEquippedDemoModel = equippedModel
end

-- Create DemoModel instances for each pedestal in the Workspace.
-- They will connect to the ClickDetector and handle clicks
-- (which will also keep the DemoModel instances alive).
for _, pedestal in Workspace.Pedestals:GetChildren() do
	DemoModel.new(pedestal, pedestal.Name, onDemoModelEquip)
end
