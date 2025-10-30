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

		if handle:FindFirstChildWhichIsA("WrapLayer") then
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

local function findMatchingAttachment(character: Model, attachmentName: string)
	for _, child in character:GetDescendants() do
		if child:IsA("Attachment") and child.Name == attachmentName then
			if not child:FindFirstAncestorOfClass("Accessory") then
				return child
			end
		end
	end
	return nil
end

local function equipLayeredAccessory(character: Model, layeredAccessory: Accessory)
	local accessoryAttachment = layeredAccessory:FindFirstChildWhichIsA("Attachment", true)

	local attachment = findMatchingAttachment(character, accessoryAttachment.Name)
	local attachmentPart = attachment.Parent
	local wrapTarget = attachmentPart:FindFirstChildWhichIsA("WrapTarget")

	local itemPart = layeredAccessory:FindFirstChildWhichIsA("BasePart", true)
	local wrapLayer = itemPart:FindFirstChildWhichIsA("WrapLayer", true)
	local handle = itemPart

	local worldaFromWrap = wrapTarget.ImportOriginWorld
	local wrapFromWorldb = wrapLayer.ImportOriginWorld:Inverse()
	local worldaFromWorldb = worldaFromWrap * wrapFromWorldb
	local worldb = wrapLayer.Parent.CFrame
	handle.CFrame = (worldaFromWorldb * worldb)

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = attachmentPart
	weld.Parent = handle

	itemPart.Anchored = false
	layeredAccessory.Parent = character
end

function AccessoryUtils.ReapplyLayeredClothing(model: Model)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("WrapLayer") then
			local handle = descendant.Parent

			for _, child in handle:GetChildren() do
				if child:IsA("Weld") then
					child:Destroy()
				end
			end

			local accessory = handle.Parent

			equipLayeredAccessory(model, accessory)
		end
	end
end

return AccessoryUtils
