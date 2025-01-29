local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Config = Modules:WaitForChild("Config")
local BlanksData = require(Config:WaitForChild("BlanksData"))
local Constants = require(Config:WaitForChild("Constants"))
local RegionMaps = require(Config:WaitForChild("RegionMaps"))

type SingleLayer = {
	name: string,
	editableImage: EditableImage,
}

type LayerInfo = {
	originalTextureId: string,
	inputLayers: { SingleLayer },
	outputEditableImage: EditableImage,
	reservedBrushEditableImage : EditableImage
}

type ModelTextureInfo = {
	[MeshPart]: LayerInfo,
}

local TextureInfo = {}
TextureInfo.__index = TextureInfo

local function DoMergeDownLayers(layerInfo: LayerInfo)
	local outputImage = layerInfo.outputEditableImage

	for i, layer: SingleLayer in layerInfo.inputLayers do
		if i == 1 then
			outputImage:DrawImage(Vector2.new(0, 0), layer.editableImage, Enum.ImageCombineType.Overwrite)
		else
			outputImage:DrawImage(Vector2.new(0, 0), layer.editableImage, Enum.ImageCombineType.BlendSourceOver)
		end
	end
end

local function SetupModelTextures(model: Model): ModelTextureInfo
	local newModelInfo: ModelTextureInfo = {}

	local textureIdToLayerMap = {}

	for _, descendant in model:GetDescendants() do
		if not descendant:IsA("MeshPart") then
			continue
		end

		if descendant.Name == "PrimaryPart" then
			continue
		end

		local surfaceAppearance = descendant:FindFirstChildWhichIsA("SurfaceAppearance")
		if surfaceAppearance then
			surfaceAppearance:Destroy()
		end

		if not descendant.TextureID then
			error(
				"Error setting up model: MeshPart "
					.. descendant:GetFullName()
					.. " has empty TextureID. TextureID should be set."
			)
		end

		if textureIdToLayerMap[descendant.TextureID] then
			newModelInfo[descendant] = textureIdToLayerMap[descendant.TextureID]
			descendant.TextureContent =
				Content.fromObject(textureIdToLayerMap[descendant.TextureID].outputEditableImage)
			continue
		end

		local baseTexture = AssetService:CreateEditableImageAsync(Content.fromUri(descendant.TextureID))
		if not baseTexture then
			error(Constants.FAILED_TO_CREATE_EI_MSG)
		end

		local baseTextureLayer: SingleLayer = {
			name = "BaseTexture",
			editableImage = baseTexture,
		}

		local outputTexture = AssetService:CreateEditableImage({
			Size = baseTexture.Size,
		})
		if not outputTexture then
			error(Constants.FAILED_TO_CREATE_EI_MSG)
		end

		local brushLayerEI = AssetService:CreateEditableImage({ Size = baseTexture.Size })
		if not brushLayerEI then
			error(Constants.FAILED_TO_CREATE_EI_MSG)
		end

		local newLayerInfo: LayerInfo = {
			inputLayers = { baseTextureLayer },
			outputEditableImage = outputTexture,
			originalTextureId = descendant.TextureID,
			reservedBrushEditableImage = brushLayerEI
		}

		textureIdToLayerMap[descendant.TextureID] = newLayerInfo

		DoMergeDownLayers(newLayerInfo)

		descendant.TextureContent = Content.fromObject(outputTexture)

		newModelInfo[descendant] = newLayerInfo
	end

	return newModelInfo
end

export type Region = {
	name: string,
	meshPartNames: { string },

	-- Some regions share a texture, these regions have a texture which maps which part of the texture to use for each mesh part.
	regionBuffer: buffer?,
	-- This is the color on the editableImage that represents the region.
	regionColor: RegionMaps.ColorUInt8?,
}

export type RegionMap = { [string]: Region }

local function GetAllRegionBuffers(sourceRegionMap: RegionMaps.RegionMap): { [string]: buffer }
	local allRegionBuffers = {}

	for _, region: RegionMaps.Region in pairs(sourceRegionMap) do
		if region.regionTextureId then
			if allRegionBuffers[region.regionTextureId] then
				continue
			end

			if allRegionBuffers[region.regionTextureId] == nil then
				local editableImage: EditableImage =
					AssetService:CreateEditableImageAsync(Content.fromUri(region.regionTextureId))
				if not editableImage then
					error(Constants.FAILED_TO_CREATE_EI_MSG)
				end
				allRegionBuffers[region.regionTextureId] =
					editableImage:ReadPixelsBuffer(Vector2.zero, editableImage.Size)
				editableImage:Destroy()
			end
		end
	end

	return allRegionBuffers
end

local function SetupRegionMap(blankData: BlanksData.BlankData): RegionMap
	if not blankData.regionMapSubParts then
		return {}
	end

	local newRegionMap: RegionMap = {}

	local allRegionBuffers = GetAllRegionBuffers(blankData.regionMapSubParts)

	for regionName, sourceRegion: RegionMaps.Region in pairs(blankData.regionMapSubParts) do
		local newRegion: Region = {
			name = regionName,
			meshPartNames = sourceRegion.meshPartNames,
			regionBuffer = allRegionBuffers[sourceRegion.regionTextureId],
			regionColor = sourceRegion.regionColor,
		}

		newRegionMap[regionName] = newRegion
	end

	return newRegionMap
end

local function SetupMeshPartToRegionMap(regionMap: RegionMap)
	local allSubRegionBuffers = {}

	local MeshPartToRegionMap = {}
	for meshPartName, regionData in pairs(regionMap) do
		if regionData.regionTextureId ~= nil then
			if allSubRegionBuffers[regionData.regionTextureId] == nil then
				local editableImage: EditableImage =
					AssetService:CreateEditableImageAsync(Content.fromUri(regionData.regionTextureId))
				if not editableImage then
					error(Constants.FAILED_TO_CREATE_EI_MSG)
				end
				allSubRegionBuffers[regionData.regionTextureId] =
					editableImage:ReadPixelsBuffer(Vector2.zero, editableImage.Size)
				editableImage:Destroy()
			end

			local newRegion: Region = {
				name = meshPartName,
				meshPartNames = meshPartName,
				regionBuffer = allSubRegionBuffers[regionData.regionTextureId],
				regionColor = regionData.regionColor,
			}

			MeshPartToRegionMap[meshPartName] = newRegion
		end
	end
	return MeshPartToRegionMap
end

function TextureInfo.new(model, blankData: BlanksData.BlankData)
	local self = setmetatable({}, TextureInfo)

	self.regionMap = SetupRegionMap(blankData)
	self.perMeshPartRegionMap = SetupMeshPartToRegionMap(blankData.regionMapIndividual)

	self.reservedStickerEditableImageMap = {}
	for i=1,Constants.MAX_STICKER_LAYERS do
		local stickerLayerName = Constants.STICKER_LAYER_PREFIX..i
		-- TODO: don't hardcode the size
		local stickerEI = AssetService:CreateEditableImage({Size = Vector2.new(1024,1024)})
		if not stickerEI then
			error(Constants.FAILED_TO_CREATE_EI_MSG)
		end
		self.reservedStickerEditableImageMap[stickerLayerName] = stickerEI
	end

	self.modelTextureInfo = SetupModelTextures(model)

	self.lastCreatedEditableImage = nil
	self.lastCreatedEditableImageTextureId = nil

	return self
end

function TextureInfo:Destroy()
	for _, layerInfo in pairs(self.modelTextureInfo) do
		for _, layer in layerInfo.inputLayers do
			layer.editableImage:Destroy()
		end
		layerInfo.reservedBrushEditableImage:Destroy()
		layerInfo.outputEditableImage:Destroy()
	end

	if self.lastCreatedEditableImage then
		self.lastCreatedEditableImage:Destroy()
	end
	for _, reservedStickerEI in pairs(self.reservedStickerEditableImageMap) do
		reservedStickerEI:Destroy()
	end
end

function TextureInfo:HasRegion(regionName: string): boolean
	return self.regionMap[regionName] ~= nil
end

function TextureInfo:GetRegion(regionName: string): Region
	return self.regionMap[regionName]
end

function TextureInfo:GetMeshPartRegion(meshPartName: string): Region
	return self.perMeshPartRegionMap[meshPartName]
end

export type UniqueLayerMap = { [MeshPart]: { LayerInfo } }

function TextureInfo:GetUniqueLayerMap(): UniqueLayerMap
	local seenLayers = {}

	local uniqueLayerMap: UniqueLayerMap = {}

	for meshPart, layerInfo in pairs(self.modelTextureInfo) do
		if seenLayers[layerInfo] then
			continue
		end
		seenLayers[layerInfo] = true
		uniqueLayerMap[meshPart] = layerInfo
	end

	return uniqueLayerMap
end

function TextureInfo:GetUniqueLayerMapForMeshPartNames(meshPartNames: { string }): UniqueLayerMap
	local seenLayers = {}

	local uniqueLayerMap: UniqueLayerMap = {}

	for meshPart, layerInfo in pairs(self.modelTextureInfo) do
		if seenLayers[layerInfo] then
			continue
		end

		for _, meshPartName in pairs(meshPartNames) do
			if meshPart.Name == meshPartName then
				seenLayers[layerInfo] = true
				uniqueLayerMap[meshPart] = layerInfo
				break
			end
		end
	end

	return uniqueLayerMap
end

function TextureInfo:GetBaseLayer(meshPart): EditableImage
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	return layerInfo.inputLayers[1].editableImage
end

function TextureInfo:GetTextureSize(meshPart): Vector2
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	return layerInfo.outputEditableImage.Size
end

-- Returns the layer and a boolean indicating if the layer was created
function TextureInfo:GetOrCreateLayer(meshPart, layerName: string): (EditableImage, boolean)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	for _, layer in layerInfo.inputLayers do
		if layer.name == layerName then
			return layer.editableImage, false
		end
	end

	local newLayer
	if layerName == Constants.BRUSH_LAYER then
		newLayer = layerInfo.reservedBrushEditableImage
	else
		newLayer = self.reservedStickerEditableImageMap[layerName]
	end

	table.insert(layerInfo.inputLayers, {
		name = layerName,
		editableImage = newLayer,
	})

	return newLayer, true
end

function TextureInfo:RemoveLayer(meshPart, layerName: string)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	for i, layer in layerInfo.inputLayers do
		if layer.name == layerName then
			table.remove(layerInfo.inputLayers, i)
			break
		end
	end
end

function TextureInfo:HasLayer(meshPart, layerName: string): boolean
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	for _, layer in layerInfo.inputLayers do
		if layer.name == layerName then
			return true
		end
	end

	return false
end

function TextureInfo:UpdateOutputColorMap(meshPart)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	DoMergeDownLayers(layerInfo)
end

function TextureInfo:GetOriginalTextureId(meshPart: MeshPart): string
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	return layerInfo.originalTextureId
end

function TextureInfo:GetOutputTextureByName(meshPartName: string): EditableImage?
	for meshPart, layerInfo in pairs(self.modelTextureInfo) do
		if meshPart.Name == meshPartName then
			return layerInfo.outputEditableImage
		end
	end

	return nil
end

-- Creates a new EditableImage from the textureId and returns it
-- We cache the last created EditableImage so if the same textureId is requested again, we return the cached EditableImage
function TextureInfo:GetOrCreateEditableImageByTextureId(textureId: string): EditableImage
	if self.lastCreatedEditableImageTextureId == textureId then
		return self.lastCreatedEditableImage
	end

	local editableImage = AssetService:CreateEditableImageAsync(Content.fromUri(textureId))
	self.lastCreatedEditableImage = editableImage
	self.lastCreatedEditableImageTextureId = textureId

	return editableImage
end

function TextureInfo:MeshPartsShareLayer(meshPart1: MeshPart, meshPart2: MeshPart): boolean
	local layerInfo1: LayerInfo = self.modelTextureInfo[meshPart1]
	local layerInfo2: LayerInfo = self.modelTextureInfo[meshPart2]

	return layerInfo1 == layerInfo2
end

export type TextureInfoClass = typeof(TextureInfo)

return TextureInfo
