local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local AccessoryUtils = require(MeshManipulation:WaitForChild("AccessoryUtils"))

local AttachmentUtils = {}

function AttachmentUtils.AddOriginalPositions(model: Model)
	for _, attachment in pairs(model:GetDescendants()) do
		if attachment:IsA("Attachment") then
			local originalPositionValue = Instance.new("Vector3Value")
			originalPositionValue.Name = "OriginalPosition"
			originalPositionValue.Value = attachment.Position
			originalPositionValue.Parent = attachment
		end
	end
end

function AttachmentUtils.RevertToOriginalPositions(model: Model)
	for _, attachment in pairs(model:GetDescendants()) do
		if attachment:IsA("Attachment") then
			local originalPositionValue = attachment:FindFirstChild("OriginalPosition")
			if originalPositionValue then
				attachment.Position = originalPositionValue.Value
				originalPositionValue:Destroy()
			end
		end
	end
end

function AttachmentUtils.UpdateAccessoryAttachmentsPositions(model: Model)
	for _, attachment in pairs(model:GetDescendants()) do
		if not attachment:IsA("Attachment") then
			continue
		end

		if attachment.Name:find("RigAttachment") then
			continue
		end

		local originalPositionValue = attachment:FindFirstChild("OriginalPosition")
		local originalPosition = originalPositionValue.Value

		local wrapDeformer = attachment.Parent:FindFirstChildWhichIsA("WrapDeformer")
		if not wrapDeformer then
			continue
		end

		local deformedPosition = wrapDeformer:GetDeformedCFrameAsync(CFrame.new(originalPosition)).Position
		attachment.Position = deformedPosition
	end
end

function AttachmentUtils.MoveAccessoriesToAttachmentPoints(model: Model)
	local accessories: { AccessoryUtils.AccessoryInfo } = AccessoryUtils.GatherAccessories(model)

	for _, accessoryInfo: AccessoryUtils.AccessoryInfo in pairs(accessories) do
		local matchingAttachment = accessoryInfo.attachedPartAttachment
		local attachment = accessoryInfo.attachment
		accessoryInfo.handle.CFrame = matchingAttachment.Parent.CFrame
			* matchingAttachment.CFrame
			* attachment.CFrame:Inverse()
	end
end

local function buildJoint(parentAttachment, partForJointAttachment)
	local jointName = parentAttachment.Name:gsub("RigAttachment", "")
	local motor = Instance.new("Motor6D")
	motor.Name = jointName

	motor.Part0 = parentAttachment.Parent
	motor.Part1 = partForJointAttachment.Parent

	motor.C0 = parentAttachment.CFrame
	motor.C1 = partForJointAttachment.CFrame

	motor.Parent = partForJointAttachment.Parent
end

local function gatherSiblings(part)
	local siblings = {}

	local searchLocations = {}
	table.insert(searchLocations, part.Parent)
	for _, child in part.Parent:GetChildren() do
		if child:IsA("Folder") then
			table.insert(searchLocations, child)
		end
	end

	if part.Parent:IsA("Folder") and part.Parent.Parent then
		table.insert(searchLocations, part.Parent.Parent)
		for _, child in part.Parent.Parent:GetChildren() do
			if child:IsA("Folder") and child ~= part.Parent then
				table.insert(searchLocations, child)
			end
		end
	end

	for _, searchLocation in searchLocations do
		for _, child in searchLocation:GetChildren() do
			if child ~= part and child:IsA("BasePart") then
				table.insert(siblings, child)
			end
		end
	end

	return siblings
end

-- Builds the R15 rig from the attachments in the parts
-- Call this with nil, HumanoidRootPart
function buildRigFromAttachmentsInternal(last, part)	
	for _, attachment in pairs(part:GetChildren()) do
		if attachment:IsA("Attachment") and string.find(attachment.Name, "RigAttachment") then
			for _, sibling in gatherSiblings(part) do
				if sibling ~= part and sibling ~= last then
					local matchingAttachment = sibling:FindFirstChild(attachment.Name)
					if matchingAttachment then
						sibling.Anchored = false 

						buildJoint(attachment, matchingAttachment)
						-- Continue the recursive tree traversal building joints
						buildRigFromAttachmentsInternal(part, matchingAttachment.Parent)
					end
				end
			end
		end
	end
end

function AttachmentUtils.BuildRigFromAttachments(model: Model)
	local torso = model:FindFirstChild("Torso")
	assert(torso, "Model does not have a Torso Folder")
	local lowerTorso = torso:FindFirstChild("LowerTorso")
	assert(lowerTorso, "Model does not have a LowerTorso")

	buildRigFromAttachmentsInternal(nil, lowerTorso)
end

return AttachmentUtils
