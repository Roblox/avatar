--[[
	Static data describing each brush: display metadata plus the texture assets
	used to stamp with (textureId) and to preview in the UI (previewImageId).
	Add scatter = {} for a glitter image brush.
	Brushes adding files must be added to BrushRegistry; brushes using images
	(ImageBrush, GlitterImageBrush) only need to be added here.
]]

local BrushData = {}

BrushData.PaintBrushData = {
	BaseBrush = {
		brushId = "BaseBrush",
		name = "Hard",
		previewImageId = "rbxassetid://92649422860360",
		layoutOrder = 1,
		minSize = 0.5,
		maxSize = 18.5,
		defaultSize = 3,
	},
	SoftBrush = {
		brushId = "SoftBrush",
		name = "Soft",
		previewImageId = "rbxassetid://92144204614870",
		textureId = "rbxassetid://87871960790070",
		layoutOrder = 2,
		settings = { opacityScale = 0.2 },
		minSize = 1,
		maxSize = 28.5,
		defaultSize = 12.5,
	},
	GlitterBrush = {
		brushId = "GlitterBrush",
		name = "Glitter",
		previewImageId = "rbxassetid://76805872457787",
		layoutOrder = 3,
		minSize = 1,
		maxSize = 26,
		defaultSize = 4.5,
	},
	ArrowBrush = {
		brushId = "ArrowBrush",
		name = "Arrow",
		previewImageId = "rbxassetid://112953247691494",
		textureId = "rbxassetid://83429800569868",
		layoutOrder = 4,
		settings = { stampOnPenDown = false, stampSpacingFactor = 0.6 },
		minSize = 1,
		maxSize = 18.5,
		defaultSize = 10,
	},
	StarGlitterBrush = {
		brushId = "StarGlitterBrush",
		name = "Glitter Stars",
		previewImageId = "rbxassetid://101948870792018",
		textureId = "rbxassetid://115011139658457",
		layoutOrder = 5,
		settings = { stampSpacingFactor = 0.8 },
		scatter = { minStampScale = 0.2, maxStampScale = 0.5 },
		minSize = 3,
		maxSize = 15,
		defaultSize = 7,
	},
	HairBrush = {
		brushId = "HairBrush",
		name = "Hair",
		previewImageId = "rbxassetid://97231230416467",
		textureId = "rbxassetid://115485310235472",
		layoutOrder = 6,
		settings = { stampOnPenDown = false, stampSpacingFactor = 0.6 },
		minSize = 3,
		maxSize = 10,
		defaultSize = 5,
	},
	HatchBrush = {
		brushId = "HatchBrush",
		name = "Hatch",
		previewImageId = "rbxassetid://80976814662436",
		textureId = "rbxassetid://124882695825840",
		layoutOrder = 7,
		settings = { stampSpacingFactor = 0.5 },
		scatter = {
			-- Only randomize rotation
			stampCount = 1,
			minStampScale = 1,
			maxStampScale = 1,
			hueVariation = 0,
			saturationVariation = 0,
			valueVariation = 0,
			opacityVariation = 0,
			rotationVariation = 180,
		},
		minSize = 3,
		maxSize = 15,
		defaultSize = 7,
	},
	StippleBrush = {
		brushId = "StippleBrush",
		name = "Stipple",
		previewImageId = "rbxassetid://108100474685593",
		textureId = "rbxassetid://127355714203485",
		layoutOrder = 8,
		settings = { stampSpacingFactor = 0.3 },
		scatter = {
			-- Only randomize rotation
			stampCount = 1,
			minStampScale = 1,
			maxStampScale = 1,
			hueVariation = 0,
			saturationVariation = 0,
			valueVariation = 0,
			opacityVariation = 0,
			rotationVariation = 180,
		},
		minSize = 3,
		maxSize = 15,
		defaultSize = 7,
	},
	SpeckleBrush = {
		brushId = "SpeckleBrush",
		name = "Speckle",
		previewImageId = "rbxassetid://70376601473215",
		textureId = "rbxassetid://129842392374483",
		layoutOrder = 9,
		settings = { stampSpacingFactor = 0.6 },
		scatter = {
			-- Only randomize rotation, size
			stampCount = 1,
			minStampScale = .4,
			maxStampScale = 1,
			hueVariation = 0,
			saturationVariation = 0,
			valueVariation = 0,
			opacityVariation = 0,
			rotationVariation = 180,
		},
		minSize = 3,
		maxSize = 15,
		defaultSize = 7,
	},
	FlicksBrush = {
		brushId = "FlicksBrush",
		name = "Flicks",
		previewImageId = "rbxassetid://96162247145212",
		textureId = "rbxassetid://127553872837110",
		layoutOrder = 10,
		settings = { stampSpacingFactor = 0.8 },
		scatter = {
			-- Only randomize rotation, size
			stampCount = 1,
			minStampScale = .1,
			maxStampScale = 1,
			hueVariation = 0,
			saturationVariation = 0,
			valueVariation = 0,
			opacityVariation = 0,
			rotationVariation = 180,
		},
		minSize = 3,
		maxSize = 15,
		defaultSize = 7,
	},
	GrungeBrush = {
		brushId = "GrungeBrush",
		name = "Grunge",
		previewImageId = "rbxassetid://133624720152061",
		textureId = "rbxassetid://125565590286943",
		layoutOrder = 11,
		settings = { stampSpacingFactor = 0.4 },
		scatter = {
			-- Only randomize rotation, size
			stampCount = 1,
			minStampScale = .6,
			maxStampScale = 1,
			hueVariation = 0,
			saturationVariation = 0,
			valueVariation = 0,
			opacityVariation = 0,
			rotationVariation = 180,
		},
		minSize = 3,
		maxSize = 15,
		defaultSize = 7,
	},
}

BrushData.EraserBrushData = {
	BaseEraserBrush = {
		brushId = "BaseEraserBrush",
		name = "Eraser",
		previewImageId = "rbxassetid://108757848737494",
		layoutOrder = 1,
		minSize = 1,
		maxSize = 18.5,
		defaultSize = 10,
	},
	SoftEraserBrush = {
		brushId = "SoftEraserBrush",
		name = "Soft Eraser",
		previewImageId = "rbxassetid://106114611142323",
		textureId = "rbxassetid://87871960790070",
		layoutOrder = 2,
		minSize = 1,
		maxSize = 18.5,
		defaultSize = 10,
	},
}

BrushData.BlendBrushData = {
	BlurBrush = {
		brushId = "BlurBrush",
		name = "Blur",
		previewImageId = "rbxassetid://137539262368379",
		layoutOrder = 1,
		minSize = 0.5,
		maxSize = 9.25,
		defaultSize = 5,
	},
	SmudgeBrush = {
		brushId = "SmudgeBrush",
		name = "Smudge",
		previewImageId = "rbxassetid://79840180003003",
		layoutOrder = 2,
		minSize = 0.5,
		maxSize = 9.25,
		defaultSize = 5,
	},
	SpeckleBlendBrush = {
		brushId = "SpeckleBlendBrush",
		name = "Speckle",
		previewImageId = "rbxassetid://77748788243512",
		layoutOrder = 3,
		minSize = 0.5,
		maxSize = 9.25,
		defaultSize = 5,
	},
}

-- Special sizes for smaller eyebrows/eyelashes
-- Uses brush data sizes if not specified here
BrushData.MakeupAccessoryBrushSizes = {
	BaseBrush = { minSize = 0.1, maxSize = 9.25, defaultSize = 1.5 },
	SoftBrush = { minSize = 0.2, maxSize = 14.25, defaultSize = 6.25 },
	GlitterBrush = { minSize = 0.2, maxSize = 13, defaultSize = 2.25 },
	ArrowBrush = { minSize = 0.2, maxSize = 9.25, defaultSize = 5 },
	StarGlitterBrush = { minSize = 2, maxSize = 9.25, defaultSize = 5 },
	HairBrush = { minSize = 2, maxSize = 7, defaultSize = 3 },

	BaseEraserBrush = { minSize = 0.2, maxSize = 9.25, defaultSize = 5 },
	SoftEraserBrush = { minSize = 0.2, maxSize = 9.25, defaultSize = 5 },

	BlurBrush = { minSize = 0.2, maxSize = 9.25, defaultSize = 5 },
	SmudgeBrush = { minSize = 0.2, maxSize = 9.25, defaultSize = 5 },
	SpeckleBlendBrush = { minSize = 0.2, maxSize = 9.25, defaultSize = 5 },
}

function BrushData.GetSortedBrushData(brushData)
	local sorted = {}
	for _, entry in brushData do
		table.insert(sorted, entry)
	end
	table.sort(sorted, function(a, b)
		return a.layoutOrder < b.layoutOrder
	end)
	return sorted
end

return BrushData
