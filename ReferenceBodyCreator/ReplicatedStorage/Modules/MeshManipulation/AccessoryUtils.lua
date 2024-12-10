local AccessoryUtils = {}

export type AccessoryInfo = {
	accessory: Accessory,
	attachment: Attachment,
	handle: MeshPart,

	attachedPart: BasePart,
	attachedPartAttachment: Attachment,
}

local function GetMatchingAttachment(attachmentName, attachments)
	for _, attachment in pairs(attachments) do
		if attachment.Name == attachmentName then
			return attachment
		end
	end

	return nil
end

function AccessoryUtils.GatherAccessories(model: Model): { AccessoryInfo }
	local accessories: { AccessoryInfo } = {}

	local nonAccessoryAttachments = {}
	for _, attachment in pairs(model:GetDescendants()) do
		if not attachment:IsA("Attachment") then
			continue
		end

		if not attachment:FindFirstAncestorWhichIsA("Accessory") then
			table.insert(nonAccessoryAttachments, attachment)
		end
	end

	for _, accessory in pairs(model:GetDescendants()) do
		if not accessory:IsA("Accessory") then
			continue
		end

		local handle = accessory:FindFirstChildWhichIsA("MeshPart")
		if not handle then
			continue
		end

		local attachment = handle:FindFirstChildWhichIsA("Attachment")
		if not attachment then
			continue
		end

		local matchingAttachment = GetMatchingAttachment(attachment.Name, nonAccessoryAttachments)
		if not matchingAttachment then
			continue
		end

		local accessoryInfo: AccessoryInfo = {
			accessory = accessory,
			attachment = attachment,
			handle = handle,

			attachedPart = matchingAttachment.Parent,
			attachedPartAttachment = matchingAttachment,
		}

		table.insert(accessories, accessoryInfo)
	end

	return accessories
end

function AccessoryUtils.ResizeAccessoriesForDisplay(model)
	local accessories: { AccessoryInfo } = AccessoryUtils.GatherAccessories(model)

	for _, accessoryInfo: AccessoryInfo in pairs(accessories) do
		local attachedPart = accessoryInfo.attachedPart

		local avatarPartScaleType = attachedPart:FindFirstChild("AvatarPartScaleType")
		if not avatarPartScaleType then
			continue
		end

		local scaleMultiplier = Vector3.new(1, 1, 1)
		if avatarPartScaleType.Value == "ProportionsNormal" then
			scaleMultiplier = Vector3.new(0.625, 0.625, 0.625)
		elseif avatarPartScaleType.Value == "ProportionsSlender" then
			scaleMultiplier = Vector3.new(0.59467172622681, 0.625, 0.59467172622681)
		else
			continue
		end

		local originalSizeValue = accessoryInfo.handle:FindFirstChild("OriginalSize")
		if not originalSizeValue then
			originalSizeValue = Instance.new("Vector3Value")
			originalSizeValue.Name = "OriginalSize"
			originalSizeValue.Parent = accessoryInfo.handle
			originalSizeValue.Value = accessoryInfo.handle.Size
		end

		accessoryInfo.handle.Size = originalSizeValue.Value * scaleMultiplier
	end
end

function AccessoryUtils.AddOriginalSizes(model)
	for _, accessory in pairs(model:GetDescendants()) do
		if not accessory:IsA("Accessory") then
			continue
		end

		local handle = accessory:FindFirstChildWhichIsA("MeshPart")
		if not handle then
			continue
		end

		local originalSizeValue = Instance.new("Vector3Value")
		originalSizeValue.Name = "OriginalSize"
		originalSizeValue.Value = handle.Size
		originalSizeValue.Parent = handle
	end
end

function AccessoryUtils.RevertToOriginalSizes(model)
	for _, accessory in pairs(model:GetDescendants()) do
		if not accessory:IsA("Accessory") then
			continue
		end

		local handle = accessory:FindFirstChildWhichIsA("MeshPart")
		if not handle then
			continue
		end

		local originalSizeValue = handle:FindFirstChild("OriginalSize")
		if not originalSizeValue then
			continue
		end

		handle.Size = originalSizeValue.Value
		originalSizeValue:Destroy()
	end
end

return AccessoryUtils
