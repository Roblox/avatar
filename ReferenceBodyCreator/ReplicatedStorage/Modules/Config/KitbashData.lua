local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KitbashData = {}

export type KitbashData = {
	sourcePart: MeshPart,
	minScale: number?,
	maxScale: number?,
}

local accessoryOverrides = {
	Button = {
		minScale = 1,
		maxScale = 4,
	},
	Spike = {
		minScale = 1,
		maxScale = 3,
	},
	PurpleGemstone = {
		maxScale = 4,
	},
}

function KitbashData.GetPlacementRotation(sourcePart: MeshPart?): CFrame
	local rotation = sourcePart and sourcePart:GetAttribute("KitbashRotation")
	if typeof(rotation) == "Vector3" then
		return CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
	end
	return CFrame.identity
end

function KitbashData.GetPieces(isMakeup: boolean): { KitbashData }
	local root = ReplicatedStorage:FindFirstChild("KitbashPieces")
	if not root then
		return {}
	end
	local folders = { root }
	local category = root:FindFirstChild(if isMakeup then "Makeup" else "Accessories")
	if category and category:IsA("Folder") then
		table.insert(folders, category)
	end

	local pieces = {}
	for _, folder in folders do
		for _, sourcePart in folder:GetChildren() do
			if sourcePart:IsA("MeshPart") then
				local overrides = if isMakeup then nil else accessoryOverrides[sourcePart.Name]
				table.insert(pieces, {
					sourcePart = sourcePart,
					minScale = overrides and overrides.minScale,
					maxScale = overrides and overrides.maxScale,
				})
			end
		end
	end
	table.sort(pieces, function(a, b)
		local aOrder, bOrder = a.sourcePart:GetAttribute("CatalogOrder"), b.sourcePart:GetAttribute("CatalogOrder")
		aOrder = if typeof(aOrder) == "number" then aOrder else math.huge
		bOrder = if typeof(bOrder) == "number" then bOrder else math.huge
		return if aOrder == bOrder then a.sourcePart.Name < b.sourcePart.Name else aOrder < bOrder
	end)
	return pieces
end

return KitbashData
