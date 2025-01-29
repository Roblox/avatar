local Constants = {}

Constants.EDIT_MODE_NONE = 0
Constants.EDIT_MODE_MESH = 1
Constants.EDIT_MODE_PAINT = 2
Constants.EDIT_MODE_CHOOSING_PART = 3

-- Max Sticker Layers for the whole model
Constants.MAX_STICKER_LAYERS = 3

Constants.MAX_BRUSH_SIZE = 50
Constants.MIN_BRUSH_SIZE = 5

Constants.WIDGET_TYPE_SPHERE = "Sphere"
Constants.WIDGET_TYPE_CYLINDER = "Cylinder"
Constants.WIDGET_TYPE_MUSCLE = "Muscle"
Constants.WIDGET_TYPE_GROW_SHRINK = "GrowShrink"
Constants.WIDGET_TYPE_AXIS_STRETCH = "AxisStretch"

Constants.CONTROL_TYPE_LINE = "Line"
Constants.CONTROL_TYPE_PLANE = "Plane"

Constants.BRUSH_LAYER = "BrushLayer"
Constants.STICKER_LAYER_PREFIX = "StickerLayer"

Constants.FAILED_TO_CREATE_EI_MSG = "Failed to create editable image."

return Constants
