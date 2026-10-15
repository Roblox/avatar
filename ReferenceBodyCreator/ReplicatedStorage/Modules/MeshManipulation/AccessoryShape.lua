-- Shared client/server state and cage deformation for configured brow/lash sliders.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local AccessoryShapeControls = require(Modules:WaitForChild("Config"):WaitForChild("AccessoryShapeControls"))
local MeshUtils = require(script.Parent:WaitForChild("MeshUtils"))

local AccessoryShape = {}
AccessoryShape.__index = AccessoryShape

local function applyControl(
	control: AccessoryShapeControls.Control,
	value: number,
	positions: { [number]: Vector3 },
	bounds: AccessoryShapeControls.Bounds,
	originalPositions: { [number]: Vector3 },
	referencePositions: { [number]: Vector3 }
)
	local neutral = control.neutral or control.default
	local minMovement = control.minMovement or 0
	if control.steps and control.outerStepScale then
		local delta = value - neutral
		local firstStep = (control.max - control.min) / (control.steps - 1)
		local distance = math.abs(delta)
		if distance > firstStep then
			value = neutral + math.sign(delta) * (firstStep + (distance - firstStep) * control.outerStepScale)
		end
	end
	if minMovement == 0 or value == neutral then
		for vertexId, position in positions do
			positions[vertexId] =
				control.deform(position, value, bounds, originalPositions[vertexId], referencePositions[vertexId])
		end
		return
	end

	local referenceValue = if value < neutral then control.min else control.max
	if control.steps then
		referenceValue = neutral + math.sign(value - neutral) * (control.max - control.min) / (control.steps - 1)
	end
	local neutralPositions = {}
	local maxMovement, referenceMovement = 0, 0
	for vertexId, position in positions do
		local originalPosition = originalPositions[vertexId]
		local referencePosition = referencePositions[vertexId]
		local neutralPosition = control.deform(position, neutral, bounds, originalPosition, referencePosition)
		local updatedPosition = control.deform(position, value, bounds, originalPosition, referencePosition)
		local samplePosition = control.deform(position, referenceValue, bounds, originalPosition, referencePosition)
		neutralPositions[vertexId] = neutralPosition
		positions[vertexId] = updatedPosition
		maxMovement = math.max(maxMovement, (updatedPosition - neutralPosition).Magnitude)
		referenceMovement = math.max(referenceMovement, (samplePosition - neutralPosition).Magnitude)
	end

	local gain = 1
	if control.steps then
		-- Fit the first step to the cutoff, scaling the entire response together so
		-- outerStepScale still controls the relative size of later steps. Only soften.
		if referenceMovement > minMovement then
			gain = minMovement / referenceMovement
		end
	elseif maxMovement > 0 and maxMovement < referenceMovement then
		-- Continuous sliders retain their original boost off neutral.
		-- Preserve authored endpoints even when they cannot clear the cutoff.
		local minimum = math.min(minMovement, referenceMovement)
		local progress = maxMovement / referenceMovement
		gain = (minimum + (referenceMovement - minimum) * progress) / maxMovement
	end
	if gain ~= 1 then
		for vertexId, position in positions do
			local neutralPosition = neutralPositions[vertexId]
			positions[vertexId] = neutralPosition + (position - neutralPosition) * gain
		end
	end
end

function AccessoryShape.new(
	meshInfo,
	affectedVertices: { [number]: boolean },
	category: string,
	templateName: string,
	referencePositions: { [number]: Vector3 }?
)
	local self = setmetatable({}, AccessoryShape)
	self.controls = AccessoryShapeControls.GetControls(category, templateName)
	self.controlsById = {}
	self.values = {} :: { [string]: number }
	self.affectedVertices = affectedVertices
	self.referencePositions = referencePositions or {}
	self.revision = 0
	self.isDeformed = false

	-- Use affected vertices at rest so thickness cannot change the brow tail selection.
	local selectionMinimum = Vector3.new(math.huge, math.huge, math.huge)
	local selectionMaximum = Vector3.new(-math.huge, -math.huge, -math.huge)
	local cageInfo = meshInfo.cageInfo
	for vertexId in affectedVertices do
		local position = cageInfo.cageOrigin:PointToWorldSpace(cageInfo.initialVertexPositionsMap[vertexId])
		selectionMinimum = selectionMinimum:Min(position)
		selectionMaximum = selectionMaximum:Max(position)
	end
	if next(affectedVertices) == nil then
		selectionMinimum, selectionMaximum = Vector3.zero, Vector3.zero
	end

	local positions = MeshUtils.GetVertexPositions(meshInfo.kitbashEditableMesh)
	local _, firstPosition = next(positions)
	local minimum = firstPosition or Vector3.zero
	local maximum = minimum
	for _, position in positions do
		minimum = minimum:Min(position)
		maximum = maximum:Max(position)
	end
	local center = (minimum + maximum) * 0.5
	self.bounds = {
		minimum = minimum,
		maximum = maximum,
		center = center,
		size = maximum - minimum,
		selectionMinimum = selectionMinimum,
		selectionSize = selectionMaximum - selectionMinimum,
	}
	if category == "Eyebrows" then
		self.bounds.browSplitX = center.X
		for _, side in { "left", "right" } do
			local bottom, top = math.huge, -math.huge
			local minimumX, maximumX = math.huge, -math.huge
			for _, position in positions do
				if (position.X < center.X) == (side == "left") then
					bottom = math.min(bottom, position.Y)
					top = math.max(top, position.Y)
					minimumX = math.min(minimumX, position.X)
					maximumX = math.max(maximumX, position.X)
				end
			end
			self.bounds[side .. "BrowCenterY"] = if bottom < math.huge then (bottom + top) / 2 else center.Y
			self.bounds[side .. "BrowMinimumX"] = if minimumX < math.huge then minimumX else center.X
			self.bounds[side .. "BrowMaximumX"] = if maximumX > -math.huge then maximumX else center.X
		end
	end
	for _, control in self.controls do
		self.controlsById[control.id] = control
		self.values[control.id] = control.default
	end
	-- Defaults may themselves deform the mesh; initialize identically on both sides.
	self:Apply(meshInfo)
	return self
end

function AccessoryShape:IsValidValue(controlId: string, value: number): boolean
	local control = self.controlsById[controlId]
	return control ~= nil and type(value) == "number" and value >= control.min and value <= control.max
end

function AccessoryShape:Apply(meshInfo)
	local cageInfo = meshInfo.cageInfo
	local originalPositions = {}
	local positions = {}
	for vertexId, initialPosition in cageInfo.initialVertexPositionsMap do
		if self.affectedVertices[vertexId] then
			local position = cageInfo.cageOrigin:PointToWorldSpace(initialPosition)
			originalPositions[vertexId] = position
			positions[vertexId] = position
		end
	end
	for _, control in self.controls do
		applyControl(
			control,
			self.values[control.id],
			positions,
			self.bounds,
			originalPositions,
			self.referencePositions
		)
	end

	self.isDeformed = false
	for vertexId, initialPosition in cageInfo.initialVertexPositionsMap do
		local updatedPosition = initialPosition
		local position = positions[vertexId]
		-- Preserve rest positions exactly, including when every control is neutral.
		if position and position ~= originalPositions[vertexId] then
			updatedPosition = cageInfo.cageOrigin:PointToObjectSpace(position)
			self.isDeformed = true
		end
		-- Unrelated cage vertices always stay at rest for UGC cage relevancy.
		cageInfo.cageEditableMesh:SetPosition(vertexId, updatedPosition)
	end
end

function AccessoryShape:SetValue(meshInfo, controlId: string, value: number): boolean
	if not self:IsValidValue(controlId, value) or self.values[controlId] == value then
		return false
	end
	self.values[controlId] = value
	self:Apply(meshInfo)
	self.revision += 1
	return true
end

export type AccessoryShape = typeof(setmetatable(
	{} :: {
		controls: { AccessoryShapeControls.Control },
		controlsById: { [string]: AccessoryShapeControls.Control },
		values: { [string]: number },
		affectedVertices: { [number]: boolean },
		referencePositions: { [number]: Vector3 },
		bounds: AccessoryShapeControls.Bounds,
		revision: number,
		isDeformed: boolean,
	},
	AccessoryShape
))

return AccessoryShape
