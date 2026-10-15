--[[
	Shared visual guide for the mirror plane, used by tools that support mirroring
	(BrushTool and StickerTool).
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local MirrorGuide = {}
MirrorGuide.__index = MirrorGuide

local GUIDE_TRANSPARENCY = 0.8
local GUIDE_THICKNESS = 0.005
local GUIDE_PADDING = 0.2 -- studs to pad the bounding box

export type MirrorGuideClass = typeof(setmetatable({}, MirrorGuide))

function MirrorGuide.new(modelInfo: ModelInfo.ModelInfoClass)
	local self = setmetatable({}, MirrorGuide)
	self.modelInfo = modelInfo
	self.part = nil :: Part?
	self.visible = false
	return self
end

function MirrorGuide:EnsurePart()
	if not self.part then
		local part = Instance.new("Part")
		part.Name = "MirrorGuide"
		part.Anchored = true

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Color = Color3.fromRGB(255, 255, 255)
		part.Material = Enum.Material.Neon
		part.Transparency = GUIDE_TRANSPARENCY
		self.part = part
	end

	-- Parent to the edited model so it rides along with SetPrimaryPartCFrame moves/rotations
	self.part.Parent = self.modelInfo:GetModel()
end

-- Resizes and repositions the guide to match the model's current bounding box. Movement is handled
-- by parenting to the model, so this only needs to run when the guide is shown or the plane changes.
function MirrorGuide:Update()
	if not self.visible or not self.part then
		return
	end

	local model = self.modelInfo:GetModel()
	local head = if self.modelInfo:GetCreationType() == Constants.CREATION_TYPES.Makeup
		then self.modelInfo:GetMeshPartByName("Head")
		else nil
	local boundingBoxCFrame, boundingBoxSize
	if head then
		-- Worn hair and accessories must not change the makeup editing bounds.
		boundingBoxCFrame, boundingBoxSize = head.CFrame, head.Size
	else
		-- Detach while measuring so the guide doesn't inflate the model's own bounding box.
		self.part.Parent = nil
		boundingBoxCFrame, boundingBoxSize = model:GetBoundingBox()
		self.part.Parent = model
	end

	local extents = boundingBoxSize + Vector3.new(0, GUIDE_PADDING, GUIDE_PADDING)
	self.part.Size = Vector3.new(GUIDE_THICKNESS, extents.Y, extents.Z)
	self.part.CFrame = boundingBoxCFrame
	self.part.Transparency = GUIDE_TRANSPARENCY
end

function MirrorGuide:SetVisible(visible: boolean)
	if visible == self.visible then
		return
	end

	self.visible = visible
	if visible then
		self:EnsurePart()
		self:Update()
	elseif self.part then
		-- Detach while hidden so it can't perturb the model's bounding box / camera framing.
		self.part.Parent = nil
	end
end

function MirrorGuide:Destroy()
	if self.part then
		self.part:Destroy()
		self.part = nil
	end
	self.visible = false
end

return MirrorGuide
