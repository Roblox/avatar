local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local ResolutionManager = require(Modules:WaitForChild("ResolutionManager"))

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
	reservedBrushEditableImage: EditableImage,
	reservedFillEditableImage: EditableImage,
	metalnessEI: EditableImage,
	roughnessEI: EditableImage,
	normalEI: EditableImage,
	kitbashAtlasInfo: {
		originalTextureSize: Vector2,
		atlasSize: Vector2,
		accessoryUOffset: number,
		accessoryUScale: number,
		kitbashUOffset: number,
		kitbashUScale: number,
	}?,
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

function TextureInfo:SetupPBRTexture(size: Vector2, color: Color3)
	local accommodateKitbash = self.creationType == Constants.CREATION_TYPES.Accessory
	local eiSize = if accommodateKitbash then Vector2.new(size.X * Constants.ATLAS_GRID_SIZE, size.Y * Constants.ATLAS_GRID_SIZE) else size

	local pbrEI = AssetService:CreateEditableImage({ Size = eiSize })
	if not pbrEI then
		self:ThrowMemoryError()
		return
	end
	pbrEI:DrawRectangle(
		Vector2.new(0, 0),
		eiSize,
		color,
		0,
		Enum.ImageCombineType.Overwrite
	)

	return pbrEI
end

function TextureInfo:CreateScaledEditableImage(
	imageContent,
	accommodateKitbash: boolean?,
	pixelateSampling: boolean?
): EditableImage
	local originalImage = AssetService:CreateEditableImageAsync(imageContent)
	if not originalImage then
		self:ThrowMemoryError()
	end

	local targetSize = ResolutionManager.GetCurrentResolution()
	if accommodateKitbash then
		targetSize = Vector2.new(
			math.floor(targetSize.X / Constants.ATLAS_GRID_SIZE),
			math.floor(targetSize.Y / Constants.ATLAS_GRID_SIZE)
		)
	end

	if originalImage.Size.X == targetSize.X and originalImage.Size.Y == targetSize.Y then
		return originalImage
	end

	local scaledImage = AssetService:CreateEditableImage({
		Size = targetSize,
	})
	if not scaledImage then
		originalImage:Destroy()
		self:ThrowMemoryError()
	end

	local scale = originalImage.Size.X / targetSize.X
	if originalImage.Size.Y / targetSize.Y > scale then
		scale = originalImage.Size.Y / targetSize.Y
	end

	scaledImage:DrawImageTransformed(
		Vector2.new(scaledImage.Size.X / 2, scaledImage.Size.Y / 2),
		Vector2.new(1 / scale, 1 / scale),
		0,
		originalImage,
		if pixelateSampling
			then
				-- e.g. Region textures need to remain pixelated when scaled up or
				-- down to preserve color mapping
				{ SamplingMode = Enum.ResamplerMode.Pixelated }
			else nil
	)
	originalImage:Destroy()

	return scaledImage
end

function TextureInfo:SetupModelTextures(model: Model): ModelTextureInfo
	local newModelInfo: ModelTextureInfo = {}

	local textureIdToLayerMap = {}

	for _, descendant in model:GetDescendants() do
		if not descendant:IsA("MeshPart") then
			continue
		end

		if descendant.Name == "PrimaryPart" then
			continue
		end

		-- Only include parts of the model that we want to edit.
		if not self.individualPartsNames[descendant.Name] then
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
			local surfaceAppearance = AssetService:CreateSurfaceAppearanceAsync({
				ColorMap = Content.fromObject(textureIdToLayerMap[descendant.TextureID].outputEditableImage),
				MetalnessMap = Content.fromObject(textureIdToLayerMap[descendant.TextureID].metalnessEI),
				RoughnessMap = Content.fromObject(textureIdToLayerMap[descendant.TextureID].roughnessEI),
				NormalMap = Content.fromObject(textureIdToLayerMap[descendant.TextureID].normalEI)
			})
			surfaceAppearance.Parent = descendant

			continue
		end

		local accommodateKitbash = self.enableKitbashing

		local baseTexture = self:CreateScaledEditableImage(Content.fromUri(descendant.TextureID), accommodateKitbash)
		if not baseTexture then
			self:ThrowMemoryError()
		end
		table.insert(self.pendingEditableImages, baseTexture)
		local baseTextureLayer: SingleLayer = {
			name = "BaseTexture",
			editableImage = baseTexture,
		}
		local originalTextureSize = baseTexture.Size

		-- If this creation supports kitbashing, set up the texture atlas.
		-- The texture atlas is a 2x2 grid where the target creation accessory's
		-- texture occupies the top left of the atlas. Whereas the rest of the atlas
		-- grid entries are saved for textures of kitbash pieces to be attached
		local fullTextureSize = originalTextureSize
		if accommodateKitbash then
			fullTextureSize = Vector2.new(
				originalTextureSize.X * Constants.ATLAS_GRID_SIZE,
				originalTextureSize.Y * Constants.ATLAS_GRID_SIZE
			)
			local kitbashAtlas = AssetService:CreateEditableImage({
				Size = fullTextureSize,
			})
			if not kitbashAtlas then
				self:ThrowMemoryError()
			end
			table.insert(self.pendingEditableImages, kitbashAtlas)

			-- Fill canvas so there are no transparent pixels in Surface Appearance maps
			kitbashAtlas:DrawRectangle(
				Vector2.new(0, 0),
				fullTextureSize,
				Color3.fromRGB(255, 255, 255),
				0,
				Enum.ImageCombineType.Overwrite
			)
			kitbashAtlas:DrawImage(Vector2.new(0, 0), baseTexture, Enum.ImageCombineType.BlendSourceOver)

			baseTextureLayer.editableImage = kitbashAtlas

			baseTexture:Destroy()
		else
			local newBaseTexture = AssetService:CreateEditableImage({
				Size = fullTextureSize,
			})
			-- Fill canvas so there are no transparent pixels in Surface Appearance maps
			newBaseTexture:DrawRectangle(
				Vector2.new(0, 0),
				fullTextureSize,
				Color3.fromRGB(255, 255, 255),
				0,
				Enum.ImageCombineType.Overwrite
			)
			newBaseTexture:DrawImage(Vector2.new(0, 0), baseTexture, Enum.ImageCombineType.BlendSourceOver)
			baseTextureLayer.editableImage = newBaseTexture
			baseTexture:Destroy()
		end

		local outputTexture = AssetService:CreateEditableImage({
			Size = fullTextureSize,
		})
		if not outputTexture then
			self:ThrowMemoryError()
		end
		table.insert(self.pendingEditableImages, outputTexture)

		local brushLayerEI = AssetService:CreateEditableImage({ Size = fullTextureSize })
		if not brushLayerEI then
			self:ThrowMemoryError()
		end
		table.insert(self.pendingEditableImages, brushLayerEI)

		local fillLayerEI = AssetService:CreateEditableImage({ Size = fullTextureSize })
		if not fillLayerEI then
			self:ThrowMemoryError()
		end
		table.insert(self.pendingEditableImages, fillLayerEI)

		local metalnessEI = self:SetupPBRTexture(Constants.PBR_MAP_CELL_SIZE, Constants.PBR_DEFAULT_METAL_COLOR)
		local roughnessEI =
			self:SetupPBRTexture(Constants.PBR_MAP_CELL_SIZE, Constants.PBR_DEFAULT_ROUGH_COLOR)
		local normalEI =
			self:SetupPBRTexture(Constants.PBR_MAP_CELL_SIZE, Constants.PBR_DEFAULT_NORMAL_COLOR)

		table.insert(self.pendingEditableImages, metalnessEI)
		table.insert(self.pendingEditableImages, roughnessEI)
		table.insert(self.pendingEditableImages, normalEI)

		local newLayerInfo: LayerInfo = {
			inputLayers = {
				baseTextureLayer,
				{
					name = Constants.FABRIC_FILL_LAYER,
					editableImage = fillLayerEI,
				},
			},
			outputEditableImage = outputTexture,
			originalTextureId = descendant.TextureID,
			reservedBrushEditableImage = brushLayerEI,
			reservedFillEditableImage = fillLayerEI,
			metalnessEI = metalnessEI,
			roughnessEI = roughnessEI,
			normalEI = normalEI,
			kitbashAtlasInfo = if accommodateKitbash
				then {
					originalTextureSize = fullTextureSize,
					atlasSize = fullTextureSize,
					accessoryUOffset = 0.0,
					accessoryUScale = 1.0 / Constants.ATLAS_GRID_SIZE,
					kitbashUOffset = 1.0 / Constants.ATLAS_GRID_SIZE,
					kitbashUScale = 1.0 / Constants.ATLAS_GRID_SIZE,
				}
				else nil,
		}

		textureIdToLayerMap[descendant.TextureID] = newLayerInfo

		DoMergeDownLayers(newLayerInfo)

		local surfaceAppearance = AssetService:CreateSurfaceAppearanceAsync({
			ColorMap = Content.fromObject(outputTexture),
			MetalnessMap = Content.fromObject(metalnessEI),
			RoughnessMap = Content.fromObject(roughnessEI),
			NormalMap = Content.fromObject(normalEI)
		})
		surfaceAppearance.Parent = descendant

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

function TextureInfo:GetAllRegionBuffers(sourceRegionMap: RegionMaps.RegionMap): { [string]: buffer }
	local allRegionBuffers = {}

	for _, region: RegionMaps.Region in pairs(sourceRegionMap) do
		if region.regionTextureId then
			if allRegionBuffers[region.regionTextureId] then
				continue
			end

			if allRegionBuffers[region.regionTextureId] == nil then
				local editableImage: EditableImage =
					self:CreateScaledEditableImage(Content.fromUri(region.regionTextureId), self.enableKitbashing, true)
				if not editableImage then
					self:ThrowMemoryError()
				end

				-- Resize the region texture if needed by drawing transformed
				-- onto a new EditableImage of the correct size
				local targetSize = ResolutionManager.GetCurrentResolution()
				if self.enableKitbashing then
					-- Accessories with kitbash atlases need region buffer to
					-- be the size of only the texture slot, not the full atlas.
					targetSize = Vector2.new(
						math.floor(targetSize.X / Constants.ATLAS_GRID_SIZE),
						math.floor(targetSize.Y / Constants.ATLAS_GRID_SIZE)
					)
				end

				allRegionBuffers[region.regionTextureId] =
					editableImage:ReadPixelsBuffer(Vector2.zero, editableImage.Size)
				editableImage:Destroy()
			end
		end
	end

	return allRegionBuffers
end

function TextureInfo:SetupRegionMap(blankData: BlanksData.BlankData): RegionMap
	if not blankData.regionMapSubParts then
		return {}
	end

	local newRegionMap: RegionMap = {}

	local allRegionBuffers = self:GetAllRegionBuffers(blankData.regionMapSubParts)

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

function TextureInfo:SetupMeshPartToRegionMap(regionMap: RegionMap)
	local allSubRegionBuffers = {}

	local MeshPartToRegionMap = {}
	for meshPartName, regionData in pairs(regionMap) do
		if regionData.regionTextureId ~= nil then
			if allSubRegionBuffers[regionData.regionTextureId] == nil then
				local editableImage: EditableImage = self:CreateScaledEditableImage(
					Content.fromUri(regionData.regionTextureId),
					self.enableKitbashing,
					true
				)
				if not editableImage then
					self:ThrowMemoryError()
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

function TextureInfo:SetupMemorySafeEditableImage()
	local safeEI = AssetService:CreateEditableImage({ Size = ResolutionManager.GetCurrentResolution() })
	if not safeEI then
		self:ThrowMemoryError()
	end

	return safeEI
end

function TextureInfo:GetMemorySafeEditableImage(textureId, size)
	-- Destroy previously stored scratch EI before replacing it
	if self.memorySafeEditableImage then
		self.memorySafeEditableImage:Destroy()
		self.memorySafeEditableImage = nil
	end

	local editableImage
	if textureId then
		editableImage = self:CreateScaledEditableImage(Content.fromUri(textureId))
	else
		editableImage = AssetService:CreateEditableImage({
			Size = size
		})
	end

	if not editableImage then
		self:ThrowMemoryError()
	end
	self.memorySafeEditableImage = editableImage

	return editableImage
end

function TextureInfo:DestroyAllTrackedImages()
	if self.memorySafeEditableImage then
		self.memorySafeEditableImage:Destroy()
		self.memorySafeEditableImage = nil
	end

	for _, ei in ipairs(self.pendingEditableImages) do
		if ei then
			ei:Destroy()
		end
	end
	self.pendingEditableImages = {}
end

function TextureInfo:ThrowMemoryError()
	if self.memorySafeEditableImage then
		self.memorySafeEditableImage:Destroy()
		self.memorySafeEditableImage = nil
	end

	self:DestroyAllTrackedImages()
	error(Constants.FAILED_TO_CREATE_EI_MSG)
end

function TextureInfo.new(model, blankData: BlanksData.BlankData)
	local self = setmetatable({}, TextureInfo)

	self.pendingEditableImages = {}

	self.creationType = blankData.creationType
	self.individualPartsNames = blankData.individualPartsNames
	self.enableKitbashing = blankData.enableKitbashing
	self.regionMap = self:SetupRegionMap(blankData)
	self.perMeshPartRegionMap = self:SetupMeshPartToRegionMap(blankData.regionMapIndividual)

	self.reservedStickerEditableImageMap = {}
	for i = 1, Constants.MAX_STICKER_LAYERS do
		local stickerLayerName = Constants.STICKER_LAYER_PREFIX .. i
		local stickerEI = AssetService:CreateEditableImage({ Size = ResolutionManager.GetCurrentResolution() })
		if not stickerEI then
			self:ThrowMemoryError()
		end
		table.insert(self.pendingEditableImages, stickerEI)
		self.reservedStickerEditableImageMap[stickerLayerName] = stickerEI
	end

	self.modelTextureInfo = self:SetupModelTextures(model)

	self.lastCreatedEditableImage = nil
	self.lastCreatedEditableImageTextureId = nil
	self.memorySafeEditableImage = self:SetupMemorySafeEditableImage()

	return self
end

function TextureInfo:Destroy()
	for _, layerInfo in pairs(self.modelTextureInfo) do
		for _, layer in layerInfo.inputLayers do
			layer.editableImage:Destroy()
		end
		layerInfo.reservedBrushEditableImage:Destroy()
		layerInfo.reservedFillEditableImage:Destroy()
		layerInfo.outputEditableImage:Destroy()

		layerInfo.metalnessEI:Destroy()
		layerInfo.roughnessEI:Destroy()
		layerInfo.normalEI:Destroy()
	end

	if self.lastCreatedEditableImage then
		self.lastCreatedEditableImage:Destroy()
	end
	for _, reservedStickerEI in pairs(self.reservedStickerEditableImageMap) do
		reservedStickerEI:Destroy()
	end
	if self.memorySafeEditableImage then
		self.memorySafeEditableImage:Destroy()
		self.memorySafeEditableImage = nil
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

function TextureInfo:GetMetalnessMap(meshPart): EditableImage
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	return layerInfo.metalnessEI
end

function TextureInfo:GetRoughnessMap(meshPart): EditableImage
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	return layerInfo.roughnessEI
end

function TextureInfo:GetNormalMap(meshPart): EditableImage
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	return layerInfo.normalEI
end

function TextureInfo:GetBaseLayer(meshPart): EditableImage
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	return layerInfo.inputLayers[1].editableImage
end

function TextureInfo:GetTextureSize(meshPart: MeshPart): Vector2
	local layerInfo = self.modelTextureInfo[meshPart]

	local fullTextureSize = layerInfo.outputEditableImage.Size

	-- For accessories with kitbash atlas, brushes should only draw in the accessory slot
	if layerInfo.kitbashAtlasInfo then
		return Vector2.new(
			math.floor(fullTextureSize.X / Constants.ATLAS_GRID_SIZE),
			math.floor(fullTextureSize.Y / Constants.ATLAS_GRID_SIZE)
		)
	end

	return fullTextureSize
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
	elseif layerName == Constants.FABRIC_FILL_LAYER then
		newLayer = layerInfo.reservedFillEditableImage
	else
		newLayer = self.reservedStickerEditableImageMap[layerName]
		if newLayer.Size ~= layerInfo.outputEditableImage.Size then
			newLayer:Destroy()
			newLayer = AssetService:CreateEditableImage({ Size = layerInfo.outputEditableImage.Size })
			assert(newLayer, "Budget should be sufficient to create sticker layer")
			self.reservedStickerEditableImageMap[layerName] = newLayer
			table.insert(self.pendingEditableImages, newLayer)
		end
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

	if not layerInfo then
		return false
	end

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

	-- Replace the last created EditableImage with the new one
	if self.lastCreatedEditableImage then
		self.lastCreatedEditableImage:Destroy()
		self.lastCreatedEditableImage = nil
	end

	self.lastCreatedEditableImageTextureId = textureId

	local editableImage = AssetService:CreateEditableImageAsync(Content.fromUri(textureId))
	if not editableImage then
		error("Failed to create EditableImage for textureId: " .. textureId)
	end
	self.lastCreatedEditableImage = editableImage

	return editableImage
end

function TextureInfo:MeshPartsShareLayer(meshPart1: MeshPart, meshPart2: MeshPart): boolean
	local layerInfo1: LayerInfo = self.modelTextureInfo[meshPart1]
	local layerInfo2: LayerInfo = self.modelTextureInfo[meshPart2]

	return layerInfo1 == layerInfo2
end

export type TextureInfoClass = typeof(TextureInfo)

return TextureInfo
