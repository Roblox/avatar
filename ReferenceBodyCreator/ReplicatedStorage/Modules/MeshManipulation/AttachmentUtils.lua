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

return AttachmentUtils
