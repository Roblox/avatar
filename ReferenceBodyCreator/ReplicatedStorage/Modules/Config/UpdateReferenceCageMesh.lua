-- Script to update template reference cage mesh for copied upload
-- Preq: CreateAssetAsync Lua API Beta Feature Enabled

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if game.CreatorType == Enum.CreatorType.Group and game.CreatorId == 3529469 then
	print("If you've just republished this experience from Roblox Resources, re-open the place to run this script")
	return
end

local TShirtWrapLayer = ReplicatedStorage.Blanks.TShirtModel.ShirtAccessory.Shirt.TShirt_VNeck_001

local referenceCageEditableMesh = AssetService:CreateEditableMeshAsync(TShirtWrapLayer.ReferenceMeshContent)

local result, id = AssetService:CreateAssetAsync(referenceCageEditableMesh, Enum.AssetType.Mesh, {
	Name = "Reference Cage",
	CreatorId = game.CreatorId,
	CreatorType = if game.CreatorType == Enum.CreatorType.Group then Enum.AssetCreatorType.Group else Enum.AssetCreatorType.User,
})

-- Wait so that the Mesh is ready to be downloaded at this point
task.wait(1)

TShirtWrapLayer.ReferenceMeshContent = Content.fromAssetId(id)

print("Successfully updated reference cage mesh: " .. id)