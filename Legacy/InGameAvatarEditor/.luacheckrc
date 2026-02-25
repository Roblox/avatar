stds.roblox = {
	read_globals = {
		game = {
			other_fields = true,
		},

		-- Roblox globals
		"script",
		string = {
			fields = {
				split = {},
			},
		},

		math = {
			fields = {
				clamp = {},
			},
		},

		-- Extra functions
		"tick", "warn", "spawn", "delay",
		"wait", "settings", "UserSettings", "typeof",

		-- Types
		"Vector2", "Vector3",
		"Color3",
		"UDim", "UDim2",
		"Ray",
		"Rect",
		"CFrame",
		"Enum",
		"Instance",
		"TweenInfo",
		"Random",
		"NumberRange",
		"NumberSequence",
		"NumberSequenceKeypoint",
		"ColorSequence",
		"BrickColor",
	}
}

stds.testez = {
	read_globals = {
		"describe",
		"it", "itFOCUS", "itSKIP",
		"FOCUS", "SKIP", "HACK_NO_XPCALL",
		"expect",
	}
}

stds.rhodiumTests = {
	read_globals = {
		"Rhodium",
	}
}

ignore = {
	"212", -- unused arguments
	"421", -- shadowing local variable
	"422", -- shadowing argument
	"431", -- shadowing upvalue
	"432", -- shadowing upvalue argument
}

std = "lua51+roblox"

files["**/*.spec.lua"] = {
	std = "+testez",
	ignore = { "631" }, --Line is too long
}
