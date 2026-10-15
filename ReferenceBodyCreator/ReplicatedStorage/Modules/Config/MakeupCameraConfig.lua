local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

-- Makeup framing is expressed relative to the displayed Head MeshPart so the
-- presets continue to work if the source head is resized. FocusOffset values
-- are fractions of the head's size in its local X/Y/Z axes. BoundsScale is the
-- fraction of the head bounds that should fit in the viewport.
local FACE_PRESET = {
	FocusOffset = Vector3.zero,
	BoundsScale = Vector2.new(1, 1),
	DistanceScale = 0.9,
}

local EYES_PRESET = {
	FocusOffset = Vector3.new(0, 0.14, 0),
	BoundsScale = Vector2.new(0.85, 0.38),
	DistanceScale = 1.08,
}

local LIPS_PRESET = {
	FocusOffset = Vector3.new(0, -0.2, 0),
	BoundsScale = Vector2.new(0.5, 0.3),
	DistanceScale = 1.08,
}

return {
	FieldOfView = 35,
	MinDistance = 0.75,
	-- Horizontal screen offset while a tool panel is open.
	PanelPanViewportScale = 0.2,
	IsolatedAccessoryPreset = {
		BoundsScale = Vector2.new(1.85, 1.25),
		DistanceScale = 1.08,
		PanelPanViewportScale = 0.17,
	},

	DefaultPreset = FACE_PRESET,
	Presets = {
		[Constants.MAKEUP_ASSET_TYPES.Face] = FACE_PRESET,
		[Constants.MAKEUP_ASSET_TYPES.Eyes] = EYES_PRESET,
		[Constants.MAKEUP_ASSET_TYPES.Lips] = LIPS_PRESET,
		[Constants.MAKEUP_ASSET_TYPES.Eyebrows] = EYES_PRESET,
		[Constants.MAKEUP_ASSET_TYPES.Eyelashes] = EYES_PRESET,
	},
}
