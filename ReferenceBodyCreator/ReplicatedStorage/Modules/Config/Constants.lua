local Constants = {}

Constants.EDIT_MODE_NONE = 0
Constants.EDIT_MODE_MESH = 1
Constants.EDIT_MODE_PAINT = 2
Constants.EDIT_MODE_CHOOSING_PART = 3

Constants.STATE_PAINTING = 1
Constants.STATE_ERASING = 2
Constants.STATE_BLENDING = 3

-- Max Sticker Layers for the whole model
Constants.MAX_STICKER_LAYERS = 3
Constants.MAX_LAYERS_PER_GROUP = 3
Constants.MAX_GROUPS = 5

Constants.DEFAULT_IMAGE_BRUSH_STAMP_SPACING_FACTOR = 0.1
Constants.IMAGE_BRUSH_TEXTURE_SIZE = 64
Constants.BRUSH_TO_PEN_SIZE = 0.01
Constants.DRAW_POSITION_BATCH_SIZE = 30
Constants.MAX_BRUSH_STAMPS_PER_SEGMENT = 32

Constants.STICKER_FADE_ANGLE = 45

Constants.SCALE_DRAG_SENSITIVITY = 0.007
Constants.MIN_STICKER_SCALE = 0.1
Constants.MIN_STAMP_SCALE = 0.025
Constants.MAX_STICKER_SCALE_MULTIPLIER = 4
Constants.MAX_STAMP_SCALE_MULTIPLIER = 2

Constants.MIN_STICKER_PADDING = 0
Constants.MAX_STICKER_PADDING = 100

Constants.DEFAULT_TILED_STICKER_SCALE = 0.5
Constants.ACCESSORY_STICKER_SCALE = 0.5
Constants.MAKEUP_STICKER_SCALE = 0.25
Constants.MAKEUP_ACCESSORY_STAMP_SCALE = 0.05

Constants.PREVIEW_SKIN_TONES = {
	Color3.fromHex("#3E352A"),
	Color3.fromHex("#3D2E24"),
	Color3.fromHex("#5E4035"),
	Color3.fromHex("#74573E"),
	Color3.fromHex("#AE7966"),
	Color3.fromHex("#CC8E69"),
	Color3.fromHex("#D3A783"),
	Color3.fromHex("#E8BAAA"),
	Color3.fromHex("#EDD5B4"),
	Color3.fromRGB(163, 162, 165), -- Default gray
}

Constants.THUMBNAIL_EI_MAX_SIZE = 64

-- world-space footprint radius (in studs) of a scale=1 sticker,
Constants.STICKER_HANDLE_WORLD_RADIUS = 0.5
-- world-space footprint radius (in studs) of a scale=1 kitbash,
Constants.KITBASH_HANDLE_WORLD_RADIUS_FACTOR = 0.5
-- Scale catalog limits separately from the minimum and starting sizes.
Constants.MAKEUP_KITBASH_SCALE = 0.325
Constants.MAKEUP_KITBASH_MIN_SCALE = 0.35
Constants.MAKEUP_KITBASH_DEFAULT_SCALE = 0.5

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
Constants.STAMP_LAYER = "StampLayer"
-- The stamp layer will always be layer 0 (compared to the 1,2,3 of the sticker layers)
Constants.STAMP_LAYER_NUMBER = 0

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

Constants.CHANNEL_NAMES = { "color", "metalness", "roughness" }
export type EditableImageSet = {
	color: EditableImage,
	metalness: EditableImage,
	roughness: EditableImage,
}
export type BufferSet = {
	color: buffer,
	metalness: buffer,
	roughness: buffer,
}
export type ContentSet = {
	color: Content,
	metalness: Content,
	roughness: Content,
}

Constants.MAX_PAINTING_DISTANCE = 100

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
	Makeup = "Makeup",
}

Constants.MAKEUP_PROJECTION_TRANSFER_NAME = "MakeupProjectionTransfer"

-- Makeup asset types a layer group can represent, chosen from the "Add Makeup
-- Item" menu on each category section's dropdown.
Constants.MAKEUP_ASSET_TYPES = {
	Face = "Face",
	Eyes = "Eyes",
	Lips = "Lips",
	Eyebrows = "Eyebrows",
	Eyelashes = "Eyelashes",
}

-- Decal-based makeup types that share authored cage-space masks and guides.
Constants.MAKEUP_DECAL_ASSET_TYPES = {
	Constants.MAKEUP_ASSET_TYPES.Face,
	Constants.MAKEUP_ASSET_TYPES.Eyes,
	Constants.MAKEUP_ASSET_TYPES.Lips,
}

Constants.MAKEUP_ACCESSORY_ASSET_TYPES = {
	[Constants.MAKEUP_ASSET_TYPES.Eyebrows] = true,
	[Constants.MAKEUP_ASSET_TYPES.Eyelashes] = true,
}

Constants.MAKEUP_ASSET_TYPE_TO_AVATAR_ASSET_TYPE = {
	[Constants.MAKEUP_ASSET_TYPES.Face] = Enum.AvatarAssetType.FaceMakeup,
	[Constants.MAKEUP_ASSET_TYPES.Eyes] = Enum.AvatarAssetType.EyeMakeup,
	[Constants.MAKEUP_ASSET_TYPES.Lips] = Enum.AvatarAssetType.LipMakeup,
	[Constants.MAKEUP_ASSET_TYPES.Eyebrows] = Enum.AvatarAssetType.EyebrowAccessory,
	[Constants.MAKEUP_ASSET_TYPES.Eyelashes] = Enum.AvatarAssetType.EyelashAccessory,
}

-- Unified token map per universe.
-- Each universe maps to:
--   body = <token for full body publish>
--   accessories = { [Enum.AvatarAssetType] = <token> }
--   makeup = { [Enum.AvatarAssetType] = <token for makeup item> }
Constants.TOKENS = {
	[6812969780] = {
		body = "6703e42c-6c3f-42fb-8b35-206c345c9a9f",
		accessories = {
			[Enum.AvatarAssetType.TShirtAccessory] = "80a08bd7-1ec1-46e5-a4d4-fd41ea284f91",
			[Enum.AvatarAssetType.Hat] = "5b074565-de68-4618-a6bc-b1bb3b58f3b9",
		},
		makeup = {},
	},

	[5113694998] = {
		body = "fd0639ed-595e-42a9-bdd4-8944840c8f52",
		accessories = {},
		makeup = {},
	},

	[8668915667] = {
		body = "fa957a59-1ae2-4cec-b07d-ab63e71d6662",
		accessories = {
			[Enum.AvatarAssetType.TShirtAccessory] = "b581e120-b70e-4a18-8144-5232d9c25cb0",
			[Enum.AvatarAssetType.Hat] = "c78292a2-3355-49af-a6de-9c1c1dc27d0d",
		},
		makeup = {
			[Enum.AvatarAssetType.FaceMakeup] = "8dd5b193-dc5e-4046-a19f-edde8222f14e",
			[Enum.AvatarAssetType.EyeMakeup] = "173d4fe6-f10f-4883-8321-8a9a9e950bb4",
			[Enum.AvatarAssetType.LipMakeup] = "70ef6de7-2df0-41b3-a1d9-4f8f21be6b57",
			[Enum.AvatarAssetType.EyebrowAccessory] = "b85151e6-0b26-4aa8-837a-e311086fcef1",
			[Enum.AvatarAssetType.EyelashAccessory] = "b40173aa-8e08-4795-a043-6433b9613a1e",
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
Constants.ACCESSORY_ADJUSTMENT_BODY_STRING =
	"The accessory may not fit perfectly in the preview. You can adjust the fit using the Accessory Adjustment tool after purchase."

Constants.MAKEUP_GROUP_POOLS = {
	Decals = "Decals",
	Eyebrows = "Eyebrows",
	Eyelashes = "Eyelashes",
}
Constants.MAKEUP_ASSET_TYPE_TO_POOL = {
	[Constants.MAKEUP_ASSET_TYPES.Face] = Constants.MAKEUP_GROUP_POOLS.Decals,
	[Constants.MAKEUP_ASSET_TYPES.Eyes] = Constants.MAKEUP_GROUP_POOLS.Decals,
	[Constants.MAKEUP_ASSET_TYPES.Lips] = Constants.MAKEUP_GROUP_POOLS.Decals,
	[Constants.MAKEUP_ASSET_TYPES.Eyebrows] = Constants.MAKEUP_GROUP_POOLS.Eyebrows,
	[Constants.MAKEUP_ASSET_TYPES.Eyelashes] = Constants.MAKEUP_GROUP_POOLS.Eyelashes,
}
Constants.MAKEUP_POOL_GROUP_LIMITS = {
	[Constants.MAKEUP_GROUP_POOLS.Decals] = 3,
	[Constants.MAKEUP_GROUP_POOLS.Eyebrows] = 1,
	[Constants.MAKEUP_GROUP_POOLS.Eyelashes] = 1,
}

Constants.ADD_MAKEUP_ITEM_TITLE = "Add Makeup Item"
Constants.ADD_MAKEUP_ITEM_FOOTER = "Pay when checkout"
Constants.MAKEUP_HEAD_SWAP_TITLE_STRING = "Switch avatar head?"
Constants.MAKEUP_HEAD_SWAP_BODY_STRING = "Makeup will carry over, but may look different on the new head. You can always switch back."

Constants.STAMP_BAKE_TITLE_STRING = "Merge stamp into layer?"
Constants.STAMP_BAKE_BODY_STRING =
	"This stamp will become part of the layer. You won't be able to move, rotate, or resize it on its own afterward."

-- Copy for the two makeup category sections in the Layer Tool panel. Each has a
-- section title (top row, next to the "+" trigger) and empty-state card copy.
Constants.MAKEUP_SELECTION_SECTIONS = {
	Decals = {
		sectionTitle = "Makeup Items",
		cardTitle = "Make an item to get started.",
		cardSubtitle = "Create up to 3 makeup items",
		buttonText = "Add a Makeup Item",
	},
	BrowsLashes = {
		sectionTitle = "Eyebrows and Eyelashes",
		cardTitle = "Make an eye item to get started",
		cardSubtitle = "You can add 1 Eyelashes and 1 Eyebrows",
		buttonText = "Add Eyebrows and Eyelashes",
	},
}

Constants.COUNTER_STRINGS = {
	Sticker = "Stickers Applied",
	Kitbash = "Add-Ons Applied",
}

return Constants
