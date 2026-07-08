local Constants = {}

Constants.EDIT_MODE_NONE = 0
Constants.EDIT_MODE_MESH = 1
Constants.EDIT_MODE_PAINT = 2
Constants.EDIT_MODE_CHOOSING_PART = 3

Constants.STATE_PAINTING = 1
Constants.STATE_ERASING = 2

-- Max Sticker Layers for the whole model
Constants.MAX_STICKER_LAYERS = 3

Constants.MAX_BRUSH_SIZE = 50
Constants.MIN_BRUSH_SIZE = 1.5

Constants.SCALE_DRAG_SENSITIVITY = 0.02

Constants.MIN_STICKER_PADDING = 0
Constants.MAX_STICKER_PADDING = 100

Constants.DEFAULT_TILED_STICKER_SCALE = 0.5
Constants.ACCESSORY_STICKER_SCALE = 0.5

Constants.WIDGET_TYPE_SPHERE = "Sphere"
Constants.WIDGET_TYPE_CYLINDER = "Cylinder"
Constants.WIDGET_TYPE_MUSCLE = "Muscle"
Constants.WIDGET_TYPE_GROW_SHRINK = "GrowShrink"
Constants.WIDGET_TYPE_AXIS_STRETCH = "AxisStretch"

Constants.CONTROL_TYPE_LINE = "Line"
Constants.CONTROL_TYPE_PLANE = "Plane"

Constants.BRUSH_LAYER = "BrushLayer"
Constants.FABRIC_FILL_LAYER = "FabricFillLayer"
Constants.STICKER_LAYER_PREFIX = "StickerLayer"

Constants.FAILED_TO_CREATE_EI_MSG = "Failed to create editable image."
Constants.FIX_MESH_IMAGE_SETTINGS_MSG = "Go to the Security Tab in Game Settings to enable this API."

Constants.TEXTURE_RESOLUTION_STEPS = {
	Vector2.new(1024, 1024),
	Vector2.new(512, 512),
	Vector2.new(256, 256),
	Vector2.new(128, 128),
}

Constants.DEFAULT_KITBASH_MIN_SCALE = 0.5
Constants.DEFAULT_KITBASH_MAX_SCALE = 2
Constants.ATLAS_GRID_SIZE = 2
Constants.ATLAS_MAX_KITBASH_PIECES = (Constants.ATLAS_GRID_SIZE * Constants.ATLAS_GRID_SIZE) - 1

-- Single logical metalness/roughness/normal cell before optional 2×2 atlas expansion (accessories).
Constants.PBR_MAP_CELL_SIZE = Vector2.new(256, 256)

-- Default packed PBR colors for new editable images (non-metallic, fully rough, flat normal).
Constants.PBR_DEFAULT_METAL_COLOR = Color3.fromRGB(0, 0, 0)
Constants.PBR_DEFAULT_ROUGH_COLOR = Color3.fromRGB(255, 255, 255)
Constants.PBR_DEFAULT_NORMAL_COLOR = Color3.fromRGB(127, 127, 255)

-- Packed colors when applying fully reflective / metallic + smooth roughness to a region.
Constants.PBR_REFLECTIVE_METAL_COLOR = Color3.fromRGB(255, 255, 255)
Constants.PBR_REFLECTIVE_ROUGH_COLOR = Color3.fromRGB(0, 0, 0)

-- Define UV offsets based on the atlas we've created for kitbashing
local function GenerateAtlasSlots(gridSize)
	local slots = {}
	local slotSize = 1.0 / gridSize
	local slotIndex = 1

	for row = 0, gridSize - 1 do
		for col = 0, gridSize - 1 do
			if row == 0 and col == 0 then
				-- Skip top-left (0,0) - reserved for base texture
				continue
			end

			slots[slotIndex] = {
				uOffset = col * slotSize,
				vOffset = row * slotSize,
				uCenter = (col + 0.5) * slotSize,
				vCenter = (row + 0.5) * slotSize,
			}
			slotIndex = slotIndex + 1
		end
	end

	return slots
end
Constants.ATLAS_SLOTS = GenerateAtlasSlots(Constants.ATLAS_GRID_SIZE)

Constants.CREATION_TYPES = {
	Body = "Body",
	Accessory = "Accessory",
}

-- Unified token map per universe.
-- Each universe maps to:
--   body = <token for full body publish>
--   accessories = { [Enum.AvatarAssetType] = <token> }
Constants.TOKENS = {
	[6812969780] = {
		body = "6703e42c-6c3f-42fb-8b35-206c345c9a9f",
		accessories = {
			[Enum.AvatarAssetType.TShirtAccessory] = "80a08bd7-1ec1-46e5-a4d4-fd41ea284f91",
			[Enum.AvatarAssetType.Hat] = "5b074565-de68-4618-a6bc-b1bb3b58f3b9",
		},
	},

	[5113694998] = {
		body = "fd0639ed-595e-42a9-bdd4-8944840c8f52",
		accessories = {},
	},

	[8668915667] = {
		body = "fa957a59-1ae2-4cec-b07d-ab63e71d6662",
		accessories = {
			[Enum.AvatarAssetType.TShirtAccessory] = "b581e120-b70e-4a18-8144-5232d9c25cb0",
			[Enum.AvatarAssetType.Hat] = "c78292a2-3355-49af-a6de-9c1c1dc27d0d",
		},
	},
}

Constants.ADJUSTABLE_RIGID_ACCESSORIES = {
	[Enum.AvatarAssetType.Hat] = true,
	[Enum.AvatarAssetType.FaceAccessory] = true,
	[Enum.AvatarAssetType.BackAccessory] = true,
}

Constants.ROBUX_ICON = utf8.char(0xE002)

Constants.RESET_EDITS_TITLE_STRING = "Reset all edits?"
Constants.RESET_EDITS_BODY_STRING = "This will remove all edits you made to your asset."

Constants.EDITOR_SWITCH_TITLE_STRING = "Are you sure?"
Constants.EDITOR_SWITCH_BODY_STRING = "If you start a new creation, your changes won't be saved."

Constants.ACCESSORY_ADJUSTMENT_TITLE_STRING = "Accessory Fit May Vary"
Constants.ACCESSORY_ADJUSTMENT_BODY_STRING = "The accessory may not fit perfectly in the preview. You can adjust the fit using the Accessory Adjustment tool after purchase."

Constants.COUNTER_STRINGS = {
	Sticker = "Stickers Applied",
	Kitbash = "Add-Ons Applied"
}

return Constants
