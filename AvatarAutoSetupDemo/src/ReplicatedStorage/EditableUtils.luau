-- Utility functions for converting assets to editable formats

local AssetService = game:GetService("AssetService")

local EditableUtils = {}

-- Updates the content of a MeshPart to be an EditableMesh
local function convertToEditableMesh(meshPart: MeshPart)
	if meshPart.MeshContent and meshPart.MeshContent.SourceType == Enum.ContentSourceType.Uri then
		local mesh = AssetService:CreateEditableMeshAsync(meshPart.MeshContent)
		local content = Content.fromObject(mesh)
		local success, output = pcall(function()
			return AssetService:CreateMeshPartAsync(content)
		end)
		if not success then
			return
		end
		local newMesh = output
		success, output = pcall(function()
			meshPart:ApplyMesh(newMesh)
		end)
		if not success then
			warn("Failed to apply mesh:", output)
		end
	end
end

-- Converts texture Content to an EditableImage Content if it isn't already
local function convertToEditableImageContent(content: Content): Content?
	if not content then
		return nil
	end

	if content.SourceType == Enum.ContentSourceType.Uri then
		return Content.fromObject(AssetService:CreateEditableImageAsync(content))
	elseif content.SourceType == Enum.ContentSourceType.Object then
		return content
	else
		return nil
	end
end

-- Converts all MeshParts and SurfaceAppearances in the given root Instance to editable formats.
-- For now, the SurfaceAppearance is removed and its ColorMapContent is converted to EditableImage
-- TextureContent on the MeshPart parent.
function EditableUtils.convertAllToEditables(root: Instance)
	for _, instance in root:GetDescendants() do
		if instance:IsA("MeshPart") then
			convertToEditableMesh(instance)
			if instance.TextureContent and instance.TextureContent.SourceType == Enum.ContentSourceType.Uri then
				instance.TextureContent = convertToEditableImageContent(instance.TextureContent)
			end
		elseif instance:IsA("SurfaceAppearance") then
			if instance.Parent:IsA("MeshPart") then
				if instance.ColorMapContent and instance.ColorMapContent.SourceType ~= Enum.ContentSourceType.None then
					instance.Parent.TextureContent = convertToEditableImageContent(instance.ColorMapContent)
				end
			else
				warn("SurfaceAppearance parent is not a MeshPart:", instance.Parent.ClassName, instance.Parent)
			end
			instance:Destroy()
		end
	end
end

return EditableUtils
