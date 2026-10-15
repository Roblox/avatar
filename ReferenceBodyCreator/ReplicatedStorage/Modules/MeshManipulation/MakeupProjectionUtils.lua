--[[
	Sets up WTT-based makeup projection and provides shared head-swapping helpers
	for the client and server, preserving the editing decal when the head changes.
]]

local AssetService = game:GetService("AssetService")
local AvatarCreationService = game:GetService("AvatarCreationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Constants = require(Modules:WaitForChild("Config"):WaitForChild("Constants"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local TextureUtils = require(TextureManipulation:WaitForChild("TextureUtils"))

local MakeupProjectionUtils = {}

-- Fits authored face-tile masks and guides (U [3, 4], V [0, 1]) to the editing
-- WTT's UV bounds. Keeping these in projection space also supports head swaps.
function MakeupProjectionUtils.CreateTransferredRegionImage(
	source: EditableImage,
	transfer: WrapTextureTransfer
): EditableImage
	local uvMin = transfer.UVMinBound
	local uvMax = transfer.UVMaxBound
	local uvSize = uvMax - uvMin
	assert(uvSize.X > 0 and uvSize.Y > 0, "Makeup projection requires finite, increasing UV bounds")
	assert(uvSize.X < math.huge and uvSize.Y < math.huge, "Makeup projection requires finite UV bounds")
	local flipPivot = math.floor(uvMin.Y) + math.ceil(uvMax.Y)
	local imageUvMin = Vector2.new(uvMin.X, flipPivot - uvMax.Y)
	-- Makeup masks use the face tile at U [3, 4]; full-UV assets would use [0, 1].
	local regionCenter = Vector2.new(3.5, 0.5)
	local output = AssetService:CreateEditableImage({ Size = source.Size })
	assert(output, "Failed to allocate transferred makeup region image")
	TextureUtils.Clear(output)
	-- Position is the face-tile center in output pixels; scale fits its unit UV tile to the WTT bounds.
	output:DrawImageTransformed(
		(regionCenter - imageUvMin) / uvSize * output.Size,
		Vector2.one / uvSize,
		0,
		source,
		{ CombineType = Enum.ImageCombineType.Overwrite }
	)
	return output
end

-- Identifies the editing decal by its named projection WTT.
local function IsProjectionDecal(instance: Instance): boolean
	return instance:IsA("Decal") and instance:FindFirstChild(Constants.MAKEUP_PROJECTION_TRANSFER_NAME) ~= nil
end

-- Selects head-specific children to replace during a swap, excluding the editing decal.
local function IsHeadContent(instance: Instance): boolean
	return instance:IsA("WrapTarget")
		or instance:IsA("SurfaceAppearance")
		or instance:IsA("Attachment")
		or instance:IsA("FaceControls")
		or (instance:IsA("Decal") and not IsProjectionDecal(instance))
end

-- Copies a head without joints, constraints, facial animation controls, or decals (including worn makeup).
function MakeupProjectionUtils.CloneHead(head: MeshPart): MeshPart
	local wasArchivable = head.Archivable
	head.Archivable = true
	local success, copy = pcall(function()
		return head:Clone()
	end)
	head.Archivable = wasArchivable
	assert(success and copy, "Could not copy the head: " .. tostring(copy))
	for _, descendant in copy:GetDescendants() do
		if
			descendant:IsA("JointInstance")
			or descendant:IsA("Constraint")
			or descendant:IsA("FaceControls")
			or descendant:IsA("Decal")
		then
			descendant:Destroy()
		end
	end
	return copy
end

-- Avatar compositing blends texture alpha over Head.Color. Without a sibling
-- Humanoid, a standalone head exposes color from transparent texels.
local function EnsureHeadCompositing(model: Instance)
	assert(model:IsA("Model"), "The preview head must be a direct child of a Model")
	if model:FindFirstChildOfClass("Humanoid") then
		return
	end
	local humanoid = Instance.new("Humanoid")
	humanoid.RigType = Enum.HumanoidRigType.R15
	humanoid.EvaluateStateMachine = false
	humanoid.RequiresNeck = false
	humanoid.AutoRotate = false
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.Parent = model
end

function MakeupProjectionUtils.CreateHeadPreview(head: MeshPart): Model
	local copy = MakeupProjectionUtils.CloneHead(head)
	copy.PivotOffset = CFrame.identity
	local model = Instance.new("Model")
	model.Name = "HeadPreview"
	copy.Parent = model
	model.PrimaryPart = copy
	EnsureHeadCompositing(model)
	return model
end

-- Replaces the head's geometry and appearance while preserving its editing decal and WTT.
function MakeupProjectionUtils.ApplyHead(head: MeshPart, source: MeshPart)
	assert(source:FindFirstChildOfClass("WrapTarget"), "The selected head has no WrapTarget")
	head:ApplyMesh(source)
	head.Size = source.Size
	head.Color = source.Color
	head.Material = source.Material
	head.MaterialVariant = source.MaterialVariant
	head.Reflectance = source.Reflectance
	for _, child in head:GetChildren() do
		if IsHeadContent(child) then
			child:Destroy()
		end
	end
	for _, child in source:GetChildren() do
		if IsHeadContent(child) then
			child:Clone().Parent = head
		end
	end
end

-- Adds the editing decal and WTT using the reference head's cage and makeup UV bounds.
function MakeupProjectionUtils.SetupHead(model: Model)
	local head = model:FindFirstChild("Head", true)
	assert(head and head:IsA("MeshPart"), "Makeup reference model is missing its Head MeshPart")
	local wrapTarget = head:FindFirstChildOfClass("WrapTarget")
	assert(wrapTarget, "Makeup reference head is missing its WrapTarget")
	EnsureHeadCompositing(head.Parent)

	local validationRules = AvatarCreationService:GetValidationRules()
	local makeupRules = validationRules and validationRules.MakeupRules
	local wrapBounds = makeupRules and makeupRules.WrapTextureTransferUVBounds
	assert(wrapBounds, "Makeup validation rules are missing WrapTextureTransferUVBounds")

	local projectionDecal = Instance.new("Decal")
	projectionDecal.Name = "MakeupProjectionDecal"
	projectionDecal.Transparency = 1
	projectionDecal.Parent = head
	local projectionTransfer = Instance.new("WrapTextureTransfer")
	projectionTransfer.Name = Constants.MAKEUP_PROJECTION_TRANSFER_NAME
	projectionTransfer.ReferenceCageMeshContent = Content.fromUri(wrapTarget.CageMeshId)
	projectionTransfer.UVMinBound = wrapBounds.MinBound
	projectionTransfer.UVMaxBound = wrapBounds.MaxBound
	projectionTransfer.Parent = projectionDecal
end

return MakeupProjectionUtils
