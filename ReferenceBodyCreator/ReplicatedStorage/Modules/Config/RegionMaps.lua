export type ColorUInt8 = {
	r: number,
	g: number,
	b: number,
}

export type Region = {
	name: string,
	meshPartNames: { string },

	-- Some regions share a texture, these regions have a texture which maps which part of the texture to use for each mesh part.
	regionTextureId: string?,
	-- This is the color on the texture that represents the region.
	regionColor: ColorUInt8?,
}

local ROBOT_REGIONMAP_SUBPARTS_TEXTURE = "rbxassetid://125433198694119"
local ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE = "rbxassetid://137458227705708"

local SHIRT_REGIONMAP_TEXTURE = "rbxassetid://121897484607583"

local HAT_REGIONMAP_TEXTURE = "rbxassetid://73042169298476"

export type RegionMap = { [string]: Region }

local RegionMaps: { [string]: RegionMap } = {}

RegionMaps.RobotSubParts = {
	["Hair"] = {
		name = "Hair",
		meshPartNames = { "Hair" },
	},
	["LeftArm"] = {
		name = "LeftArm",
		meshPartNames = { "LeftHand", "LeftLowerArm", "LeftUpperArm" },

		regionTextureId = ROBOT_REGIONMAP_SUBPARTS_TEXTURE,
		regionColor = {
			r = 255,
			g = 0,
			b = 0,
		},
	},
	["RightArm"] = {
		name = "RightArm",
		meshPartNames = { "RightHand", "RightLowerArm", "RightUpperArm" },

		regionTextureId = ROBOT_REGIONMAP_SUBPARTS_TEXTURE,
		regionColor = {
			r = 0,
			g = 255,
			b = 0,
		},
	},
	["LeftLeg"] = {
		name = "LeftLeg",
		meshPartNames = { "LeftFoot", "LeftLowerLeg", "LeftUpperLeg" },

		regionTextureId = ROBOT_REGIONMAP_SUBPARTS_TEXTURE,
		regionColor = {
			r = 0,
			g = 0,
			b = 255,
		},
	},
	["RightLeg"] = {
		name = "RightLeg",
		meshPartNames = { "RightFoot", "RightLowerLeg", "RightUpperLeg" },

		regionTextureId = ROBOT_REGIONMAP_SUBPARTS_TEXTURE,
		regionColor = {
			r = 255,
			g = 255,
			b = 0,
		},
	},
	["Torso"] = {
		name = "Torso",
		meshPartNames = { "UpperTorso", "LowerTorso" },

		regionTextureId = ROBOT_REGIONMAP_SUBPARTS_TEXTURE,
		regionColor = {
			r = 255,
			g = 0,
			b = 255,
		},
	},
	["Head"] = {
		name = "Head",
		meshPartNames = { "Head" },

		regionTextureId = ROBOT_REGIONMAP_SUBPARTS_TEXTURE,
		regionColor = {
			r = 0,
			g = 255,
			b = 255,
		},
	},
}

RegionMaps.RobotIndividualParts = {
	["Hair"] = {
		name = "Hair",
		meshPartNames = { "Hair" },
	},
	["LeftHand"] = {
		name = "LeftHand",
		meshPartNames = { "LeftHand" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 255,
			g = 0,
			b = 0,
		},
	},
	["LeftLowerArm"] = {
		name = "LeftLowerArm",
		meshPartNames = { "LeftLowerArm" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 0,
			g = 255,
			b = 0,
		},
	},
	["LeftUpperArm"] = {
		name = "LeftUpperArm",
		meshPartNames = { "LeftUpperArm" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 0,
			g = 0,
			b = 255,
		},
	},
	["RightHand"] = {
		name = "RightHand",
		meshPartNames = { "RightHand" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 255,
			g = 255,
			b = 0,
		},
	},
	["RightLowerArm"] = {
		name = "RightLowerArm",
		meshPartNames = { "RightLowerArm" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 255,
			g = 0,
			b = 255,
		},
	},
	["RightUpperArm"] = {
		name = "RightUpperArm",
		meshPartNames = { "RightUpperArm" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 0,
			g = 255,
			b = 255,
		},
	},
	["Head"] = {
		name = "Head",
		meshPartNames = { "Head" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 255,
			g = 255,
			b = 255,
		},
	},
	["UpperTorso"] = {
		name = "UpperTorso",
		meshPartNames = { "UpperTorso" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 128,
			g = 128,
			b = 128,
		},
	},
	["LowerTorso"] = {
		name = "LowerTorso",
		meshPartNames = { "LowerTorso" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 64,
			g = 64,
			b = 64,
		},
	},
	["LeftFoot"] = {
		name = "LeftFoot",
		meshPartNames = { "LeftFoot" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 128,
			g = 0,
			b = 0,
		},
	},
	["LeftLowerLeg"] = {
		name = "LeftLowerLeg",
		meshPartNames = { "LeftLowerLeg" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 0,
			g = 128,
			b = 0,
		},
	},
	["LeftUpperLeg"] = {
		name = "LeftUpperLeg",
		meshPartNames = { "LeftUpperLeg" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 0,
			g = 0,
			b = 128,
		},
	},
	["RightFoot"] = {
		name = "RightFoot",
		meshPartNames = { "RightFoot" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 128,
			g = 128,
			b = 0,
		},
	},
	["RightLowerLeg"] = {
		name = "RightLowerLeg",
		meshPartNames = { "RightLowerLeg" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 128,
			g = 0,
			b = 128,
		},
	},
	["RightUpperLeg"] = {
		name = "RightUpperLeg",
		meshPartNames = { "RightUpperLeg" },

		regionTextureId = ROBOT_REGIONMAP_INDIVIDUAL_TEXTURE,
		regionColor = {
			r = 0,
			g = 128,
			b = 128,
		},
	},
}

RegionMaps.TShirtSubParts = {
	["Torso"] = {
		name = "Torso",
		meshPartNames = { "Shirt" },

		regionTextureId = SHIRT_REGIONMAP_TEXTURE,
		regionColor = {
			r = 255,
			g = 0,
			b = 0,
		},
	},
	["LeftArm"] = {
		name = "LeftArm",
		meshPartNames = { "Shirt" },

		regionTextureId = SHIRT_REGIONMAP_TEXTURE,
		regionColor = {
			r = 0,
			g = 0,
			b = 255,
		},
	},
	["RightArm"] = {
		name = "RightArm",
		meshPartNames = { "Shirt" },

		regionTextureId = SHIRT_REGIONMAP_TEXTURE,
		regionColor = {
			r = 0,
			g = 255,
			b = 0,
		},
	},
}
RegionMaps.TShirtIndividualParts = {
	["Shirt"] = {
		name = "Shirt",
		meshPartNames = { "Shirt" },
	},
}

RegionMaps.HatSubParts = {
	["Brim"] = {
		name = "Brim",
		meshPartNames = { "Hat" },

		regionTextureId = HAT_REGIONMAP_TEXTURE,
		regionColor = {
			r = 0,
			g = 0,
			b = 255,
		},
	},
	["Band"] = {
		name = "Band",
		meshPartNames = { "Hat" },

		regionTextureId = HAT_REGIONMAP_TEXTURE,
		regionColor = {
			r = 0,
			g = 255,
			b = 0,
		},
	},
	["Crown"] = {
		name = "Crown",
		meshPartNames = { "Hat" },

		regionTextureId = HAT_REGIONMAP_TEXTURE,
		regionColor = {
			r = 255,
			g = 0,
			b = 0,
		},
	},
}
RegionMaps.HatIndividualParts = {
	["Hat"] = {
		name = "Hat",
		meshPartNames = { "Hat" },
	}
}

return RegionMaps
