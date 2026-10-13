-- Shared head choices for the makeup picker and server-side action validation.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MakeupHeads = {}

MakeupHeads.DefaultId = "Default"
MakeupHeads.PlayerId = "Player"
MakeupHeads.Options = {
	{ id = MakeupHeads.PlayerId },
	{ id = MakeupHeads.DefaultId },
	{ id = "Roxy", previewModelName = "Roxy", includeHair = true },
	{ id = "Andi", previewModelName = "Andi", includeHair = true },
	{ id = "Blocky", previewModelName = "Blocky" },
}

function MakeupHeads.GetOption(headId: string)
	for _, option in MakeupHeads.Options do
		if option.id == headId then
			return option
		end
	end
	return nil
end

-- Resolve trusted source instances locally; clients only send the selected ID.
function MakeupHeads.GetSourceHead(headId: string, defaultHead: MeshPart?, character: Model?): MeshPart?
	local option = MakeupHeads.GetOption(headId)
	if not option then
		return nil
	end
	local head
	if headId == MakeupHeads.DefaultId then
		head = defaultHead
	elseif headId == MakeupHeads.PlayerId then
		head = character and character:FindFirstChild("Head")
	else
		local previewModels = ReplicatedStorage:FindFirstChild("PreviewModels")
		local model = previewModels and previewModels:FindFirstChild(option.previewModelName)
		head = model and model:FindFirstChild("Head")
	end
	if head and head:IsA("MeshPart") and head:FindFirstChildOfClass("WrapTarget") then
		return head
	end
	return nil
end

return MakeupHeads
