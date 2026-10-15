local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

export type DrawInfo = {
	textureDrawPosition: Vector2,
	cameraCFrame: CFrame,
	castedPoint: Vector3,
	isVirtualCursorMovement: boolean,
}

export type BrushSettings = {
	colorBlendType: Enum.ImageCombineType?, -- defaults to BlendSourceOver
	alphaBlendType: Enum.ImageAlphaType?, -- defaults to Default
	brushType: number?, --Constants.STATE_{ERASING | PAINTING | BLENDING}
	stampOnPenDown: boolean?, -- defaults to true, should turn off if you need a directional brush
	stampSpacingFactor: number?, -- defaults to Constants.DEFAULT_IMAGE_BRUSH_STAMP_SPACING_FACTOR
	opacityScale: number?,
}

-- BrushSettings with every field resolved to a concrete value.
export type ResolvedBrushSettings = {
	colorBlendType: Enum.ImageCombineType,
	alphaBlendType: Enum.ImageAlphaType,
	brushType: number,
	stampOnPenDown: boolean,
	stampSpacingFactor: number,
	opacityScale: number,
}

local BrushInfo = {}

-- Applies the default fallbacks for any unset brush setting.
function BrushInfo.ResolveSettings(settings: BrushSettings): ResolvedBrushSettings
	return {
		colorBlendType = settings.colorBlendType or Enum.ImageCombineType.BlendSourceOver,
		alphaBlendType = settings.alphaBlendType or Enum.ImageAlphaType.Default,
		brushType = settings.brushType or Constants.STATE_PAINTING,
		stampOnPenDown = if settings.stampOnPenDown == nil then true else settings.stampOnPenDown,
		stampSpacingFactor = settings.stampSpacingFactor or Constants.DEFAULT_IMAGE_BRUSH_STAMP_SPACING_FACTOR,
		opacityScale = settings.opacityScale or 1,
	}
end

return BrushInfo
