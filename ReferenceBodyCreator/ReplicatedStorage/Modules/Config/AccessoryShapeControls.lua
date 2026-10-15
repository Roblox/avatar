-- Add, reorder, or tune brow/lash controls here. See ReferenceBodyCreator/SLIDER_CONTROLS.md.
-- Values use deformation units (e.g. 1 = original scale), not percentages.
-- steps counts selectable values, including both ends of the range.

local DEFAULT_STEPS = 5 -- Two below neutral, neutral, and two above.

export type Bounds = {
	minimum: Vector3,
	maximum: Vector3,
	center: Vector3,
	size: Vector3,
	selectionMinimum: Vector3,
	selectionSize: Vector3,
	browSplitX: number?,
	leftBrowCenterY: number?,
	rightBrowCenterY: number?,
	leftBrowMinimumX: number?,
	leftBrowMaximumX: number?,
	rightBrowMinimumX: number?,
	rightBrowMaximumX: number?,
}

export type Deform = (
	position: Vector3,
	value: number,
	bounds: Bounds,
	originalPosition: Vector3,
	referencePosition: Vector3?
) -> Vector3

export type Control = {
	id: string,
	label: string,
	decreaseLabel: string?,
	increaseLabel: string?,
	min: number,
	max: number,
	default: number,
	deform: Deform,
	steps: number?,
	outerStepScale: number?,
	minMovement: number?,
	neutral: number?,
	enabled: boolean?,
}

export type Override = {
	label: string?,
	decreaseLabel: string?,
	increaseLabel: string?,
	min: number?,
	max: number?,
	default: number?,
	deform: Deform?,
	steps: number?,
	outerStepScale: number?,
	minMovement: number?,
	neutral: number?,
	enabled: boolean?,
}

export type Definition = Control & {
	categoryOverrides: { [string]: Override }?,
	templateOverrides: { [string]: Override }?,
}

-- Axes and bounds are in the original accessory mesh's local coordinates.
local function scaleAxis(axis: Vector3): Deform
	return function(position, value, bounds)
		if value == 1 then
			return position
		end
		local scaled = bounds.center + (position - bounds.center) * value
		return position * (Vector3.one - axis) + scaled * axis
	end
end

local function translateAxis(axis: Vector3): Deform
	return function(position, value, _bounds)
		return position + axis * value
	end
end

local BROW_TAIL_CENTER = Vector3.new(1, 0.5, 0.5)
local BROW_TAIL_RADIUS = Vector3.new(0.3, 1, 1)
local BROW_TAIL_PULL = Vector3.new(0.2, 0, 0)

-- Pull both outer tails with a soft falloff measured in the original cage bounds.
local function browLength(position: Vector3, value: number, bounds: Bounds, originalPosition: Vector3): Vector3
	if value == 1 then
		return position
	end
	local size = bounds.selectionSize
	local relative = originalPosition - bounds.selectionMinimum
	local point = Vector3.new(
		if size.X > 0 then relative.X / size.X else 0.5,
		if size.Y > 0 then relative.Y / size.Y else 0.5,
		if size.Z > 0 then relative.Z / size.Z else 0.5
	)
	local side = if point.X < 0.5 then -1 else 1
	local sample = Vector3.new(0.5 + math.abs(point.X - 0.5), point.Y, point.Z)
	local distance = ((sample - BROW_TAIL_CENTER) / BROW_TAIL_RADIUS).Magnitude
	local weight = math.clamp(1 - distance, 0, 1)
	weight = weight * weight * (3 - 2 * weight)
	local offset = BROW_TAIL_PULL * Vector3.new(side, 1, 1) * weight
	return position + offset * math.max(size.X, size.Y, size.Z) * (value - 1)
end

-- Extend along the original inner-to-outer cage offset so thickness cannot amplify length.
local function lashLength(
	position: Vector3,
	value: number,
	_bounds: Bounds,
	originalPosition: Vector3,
	referencePosition: Vector3?
): Vector3
	if value == 1 or not referencePosition then
		return position
	end
	return position + (originalPosition - referencePosition) * (value - 1)
end

local function browThickness(position: Vector3, value: number, bounds: Bounds): Vector3
	if value == 1 then
		return position
	end
	local centerY = if position.X < (bounds.browSplitX or bounds.center.X)
		then bounds.leftBrowCenterY
		else bounds.rightBrowCenterY
	centerY = centerY or bounds.center.Y
	return Vector3.new(position.X, centerY + (position.Y - centerY) * value, position.Z)
end

local BROW_ARCH_PEAK = 0.65 -- From the inner end (0) to the outer tail (1).

-- Move vertical columns together to change the arch without changing thickness.
local function browHeight(position: Vector3, value: number, bounds: Bounds, originalPosition: Vector3): Vector3
	if value == 0 then
		return position
	end
	local split = bounds.browSplitX or bounds.center.X
	local isLeft = originalPosition.X < split
	local minimum = if isLeft then bounds.leftBrowMinimumX else bounds.rightBrowMinimumX
	local maximum = if isLeft then bounds.leftBrowMaximumX else bounds.rightBrowMaximumX
	if not minimum or not maximum or maximum <= minimum then
		return position
	end
	local t = math.clamp((originalPosition.X - minimum) / (maximum - minimum), 0, 1)
	if isLeft then
		t = 1 - t
	end
	local weight = if t < BROW_ARCH_PEAK then t / BROW_ARCH_PEAK else (1 - t) / (1 - BROW_ARCH_PEAK)
	weight = weight * weight * (3 - 2 * weight)
	return position + Vector3.yAxis * (value * weight)
end

local LASH_CURVE_DIRECTION_FADE = 0.2

local function smoothSign(value: number, fadeDistance: number): number
	local weight = math.clamp(math.abs(value) / fadeDistance, 0, 1)
	return math.sign(value) * weight * weight * (3 - 2 * weight)
end

-- Determine direction at rest, then rotate the current extension around its cage anchor.
local function lashCurve(
	position: Vector3,
	value: number,
	_bounds: Bounds,
	originalPosition: Vector3,
	referencePosition: Vector3?
): Vector3
	if value == 0 or not referencePosition then
		return position
	end
	local extension = originalPosition - referencePosition
	local fadeDistance = extension.Magnitude * LASH_CURVE_DIRECTION_FADE
	if fadeDistance == 0 then
		return position
	end
	local facing = -smoothSign(extension.Z, fadeDistance)
	local side = smoothSign(extension.Y, fadeDistance)
	local rotation = CFrame.fromAxisAngle(Vector3.xAxis, math.rad(-value) * facing * side)
	return referencePosition + rotation:VectorToWorldSpace(position - referencePosition)
end

local AccessoryShapeControls = {}

-- Wide base range; minMovement softens the first step to just above the cage cutoff.
AccessoryShapeControls.BrowThickness = { min = 0, max = 2, minMovement = 0.0101 }
local browSettings = AccessoryShapeControls.BrowThickness

-- Order also determines how deformations compose: each receives the previous
-- control's result. Every edit starts again from the original cage, avoiding drift.
AccessoryShapeControls.Definitions = {
	{
		id = "thickness",
		label = "Thickness",
		decreaseLabel = "- Thinner",
		increaseLabel = "+ Thicker",
		min = 0,
		max = 2,
		default = 1,
		steps = DEFAULT_STEPS,
		outerStepScale = 0.75, -- Later steps move 75% as far as the first step from neutral.
		minMovement = 0.0101, -- Target first-step cage movement; never amplifies a smaller authored step.
		deform = scaleAxis(Vector3.yAxis),
		categoryOverrides = {
			Eyebrows = {
				min = browSettings.min,
				max = browSettings.max,
				deform = browThickness,
				minMovement = browSettings.minMovement,
				neutral = 1,
			},
		},
		-- Optional tuning, applied in this order:
		-- categoryOverrides = { Eyelashes = { min = 0.75, max = 1.25 } },
		-- templateOverrides = { Eyelashes_Large = { max = 1.1 } },
	},
	{
		id = "length",
		label = "Length",
		decreaseLabel = "- Shorter",
		increaseLabel = "+ Longer",
		min = 0,
		max = 2,
		default = 1,
		steps = DEFAULT_STEPS,
		outerStepScale = 0.75,
		minMovement = 0.0101,
		neutral = 1,
		deform = browLength,
		categoryOverrides = {
			Eyelashes = { deform = lashLength },
		},
	},
	{
		id = "height",
		label = "Height",
		decreaseLabel = "- Lower",
		increaseLabel = "+ Higher",
		min = -0.04, -- Arch displacement in mesh units.
		max = 0.04,
		default = 0,
		steps = DEFAULT_STEPS,
		outerStepScale = 0.75,
		minMovement = 0.0101,
		deform = browHeight,
		enabled = false,
		categoryOverrides = {
			Eyebrows = { enabled = true },
		},
	},
	{
		id = "curve",
		label = "Curve",
		decreaseLabel = "- Flatter",
		increaseLabel = "+ Rounder",
		min = -50, -- Rotation in degrees.
		max = 50,
		default = 0,
		steps = DEFAULT_STEPS,
		outerStepScale = 0.75,
		minMovement = 0.0101,
		deform = lashCurve,
		enabled = false,
		categoryOverrides = {
			Eyelashes = { enabled = true },
		},
	},
	-- Example width control: copy the entry above, change id/label, and use
	-- scaleAxis(Vector3.xAxis). For vertical offset use min = -0.1, max = 0.1,
	-- default = 0, deform = translateAxis(Vector3.yAxis).
	-- With steps, minMovement softens the first step to the target cage movement.
	-- Later steps scale down with it; outerStepScale controls their relative size.
	-- Use a base range whose first step already clears the cutoff; this only reduces it.
	-- Omit steps to use DEFAULT_STEPS.
	-- Use it for effects whose movement grows toward each endpoint (scale, offset, pulls).
	-- neutral defaults to default; set it explicitly if the initial value deforms.
	-- Compensation adds a small jump off neutral and preserves the endpoint shapes.
	-- Set minMovement = 0 in an override to disable it for that category/template.
} :: { Definition }

-- Reusable deformation helpers for additional controls.
AccessoryShapeControls.ScaleAxis = scaleAxis
AccessoryShapeControls.TranslateAxis = translateAxis

local function applyOverride(control, override: Override?)
	for key, value in override or {} do
		control[key] = value
	end
end

local function isFinite(value): boolean
	return type(value) == "number" and value > -math.huge and value < math.huge
end

local function validateControl(control: Control)
	assert(
		type(control.label) == "string" and type(control.deform) == "function",
		"Invalid shape control " .. control.id
	)
	assert(
		isFinite(control.min)
			and isFinite(control.max)
			and control.min < control.max
			and isFinite(control.default)
			and control.default >= control.min
			and control.default <= control.max,
		"Invalid range/default for shape control " .. control.id
	)
	assert(
		isFinite(control.steps) and control.steps >= 2 and control.steps % 1 == 0,
		"Invalid step count for shape control " .. control.id
	)
	assert(
		control.outerStepScale == nil
			or (isFinite(control.outerStepScale) and control.outerStepScale > 0 and control.outerStepScale <= 1),
		"Invalid outer step scale for shape control " .. control.id
	)
	assert(
		control.minMovement == nil or (isFinite(control.minMovement) and control.minMovement >= 0),
		"Invalid minimum movement for shape control " .. control.id
	)
	assert(
		control.neutral == nil
			or (isFinite(control.neutral) and control.neutral >= control.min and control.neutral <= control.max),
		"Invalid neutral value for shape control " .. control.id
	)
	if control.steps then
		local neutralStep = ((control.neutral or control.default) - control.min)
			/ (control.max - control.min)
			* (control.steps - 1)
		assert(math.abs(neutralStep - math.round(neutralStep)) < 1e-6, "Neutral must be a stop for " .. control.id)
	end
end

function AccessoryShapeControls.GetControls(category: string, templateName: string): { Control }
	local controls = {}
	local ids = {}
	for _, definition in AccessoryShapeControls.Definitions do
		local control = table.clone(definition)
		applyOverride(control, definition.categoryOverrides and definition.categoryOverrides[category])
		applyOverride(control, definition.templateOverrides and definition.templateOverrides[templateName])
		control.steps = control.steps or DEFAULT_STEPS
		assert(
			type(control.id) == "string" and control.id ~= "" and not ids[control.id],
			"Invalid/duplicate shape control id"
		)
		ids[control.id] = true
		if control.enabled == false then
			continue
		end
		validateControl(control)
		table.insert(controls, control)
	end
	return controls
end

return AccessoryShapeControls
