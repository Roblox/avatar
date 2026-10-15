--[[
	Manages a model's base textures, reserved layers, user layer groups, PBR maps,
	and region maps, compositing them into a final output texture.
]]
local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local ResolutionManager = require(Modules:WaitForChild("ResolutionManager"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local GroupInfo = require(TextureManipulation:WaitForChild("GroupInfo"))

local Config = Modules:WaitForChild("Config")
local BlanksData = require(Config:WaitForChild("BlanksData"))
local Constants = require(Config:WaitForChild("Constants"))
local RegionMaps = require(Config:WaitForChild("RegionMaps"))

type EditableImageSet = Constants.EditableImageSet
type SingleLayer = GroupInfo.SingleLayer
type TargetLayerInfo = GroupInfo.TargetLayerInfo

type LayerInfo = {
	originalTextureId: string,
	baseTexture: SingleLayer?, -- bottom layer, composited first
	baseAlphaMaskId: string?, -- black subtract mask with inverse base alpha
	preserveKitbashTextures: boolean?,
	normalMapId: string?,
	inputLayers: { SingleLayer }, -- reserved layers (fill, sticker)
	groupLayers: GroupInfo.GroupInfoClass, -- user layers, organized into groups
	outputEditableSetId: string,
	reservedBrushSetId: string?,
	-- Projection-space, preview-only guide images. These never belong to a group or layer.
	makeupGuideImagesByType: { [string]: EditableImage },
	showMakeupGuides: boolean,
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

local function DrawGuide(outputImage: EditableImage, guideImage: EditableImage)
	if guideImage.Size == outputImage.Size then
		outputImage:DrawImage(Vector2.zero, guideImage, Enum.ImageCombineType.BlendSourceOver)
		return
	end

	local scale = math.max(guideImage.Size.X / outputImage.Size.X, guideImage.Size.Y / outputImage.Size.Y)
	outputImage:DrawImageTransformed(
		outputImage.Size / 2,
		Vector2.new(1 / scale, 1 / scale),
		0,
		guideImage,
		{ CombineType = Enum.ImageCombineType.BlendSourceOver }
	)
end

local function GetActiveMakeupGuideImage(layerInfo: LayerInfo): EditableImage?
	if not layerInfo.showMakeupGuides then
		return nil
	end

	local activeGroup = layerInfo.groupLayers:GetActiveGroup()
	if not activeGroup then
		return nil
	end

	return layerInfo.makeupGuideImagesByType[activeGroup.makeupAssetType]
end

local function DoMergeDownLayers(layerInfo: LayerInfo, editableManager, hideBaseTexture: boolean?)
	-- Composite user-layer groups first
	layerInfo.groupLayers:DoMergeDownGroups()

	local outputImageSet = editableManager:GetEISet(layerInfo.outputEditableSetId)

	local colorOutputImage = outputImageSet.color
	local metalnessOutputImage = outputImageSet.metalness
	local roughnessOutputImage = outputImageSet.roughness

	-- Clear output
	if layerInfo.baseTexture then
		-- Overwrite every channel if base texture provided
		local baseImages = editableManager:GetEISet(layerInfo.baseTexture.imageSetId)
		for _, channel in Constants.CHANNEL_NAMES do
			outputImageSet[channel]:DrawImage(Vector2.new(0, 0), baseImages[channel], Enum.ImageCombineType.Overwrite)
		end
	else
		for _, channel in Constants.CHANNEL_NAMES do
			local image = outputImageSet[channel]
			image:DrawRectangle(Vector2.zero, image.Size, Color3.new(), 1, Enum.ImageCombineType.Overwrite)
		end
	end
	if hideBaseTexture then
		colorOutputImage:DrawRectangle(
			Vector2.zero,
			colorOutputImage.Size,
			Color3.new(),
			1,
			Enum.ImageCombineType.Overwrite
		)
	end

	if layerInfo.baseAlphaMaskId then
		local baseAlphaMask = editableManager:GetEI(layerInfo.baseAlphaMaskId)
		-- Composite color on an opaque base, then restore its authored alpha below.
		colorOutputImage:DrawRectangle(Vector2.zero, baseAlphaMask.Size, Color3.new(), 0, Enum.ImageCombineType.Add)
	end

	-- Reserved layers (fill, sticker): blend over the base
	for _, layer in layerInfo.inputLayers do
		local images = editableManager:GetEISet(layer.imageSetId)
		colorOutputImage:DrawImage(Vector2.new(0, 0), images.color, Enum.ImageCombineType.BlendSourceOver)
		metalnessOutputImage:DrawImage(Vector2.new(0, 0), images.metalness, Enum.ImageCombineType.BlendSourceOver)
		roughnessOutputImage:DrawImage(Vector2.new(0, 0), images.roughness, Enum.ImageCombineType.BlendSourceOver)
	end

	-- User-layer group composites (top): blend over
	for _, composite in layerInfo.groupLayers:GetComposites() do
		colorOutputImage:DrawImage(Vector2.new(0, 0), composite.color, Enum.ImageCombineType.BlendSourceOver)
		metalnessOutputImage:DrawImage(Vector2.new(0, 0), composite.metalness, Enum.ImageCombineType.BlendSourceOver)
		roughnessOutputImage:DrawImage(Vector2.new(0, 0), composite.roughness, Enum.ImageCombineType.BlendSourceOver)
	end

	if layerInfo.baseAlphaMaskId then
		local baseAlphaMask = editableManager:GetEI(layerInfo.baseAlphaMaskId)
		colorOutputImage:DrawImage(Vector2.zero, baseAlphaMask, Enum.ImageCombineType.Subtract)
	end

	-- Draw guide over texture if applicable
	local guideImage = GetActiveMakeupGuideImage(layerInfo)
	if guideImage then
		DrawGuide(colorOutputImage, guideImage)
	end

	if layerInfo.preserveKitbashTextures then
		local baseImages = editableManager:GetEISet(layerInfo.baseTexture.imageSetId)
		-- Preserve add-on color, alpha, and PBR while retaining edits to the base tile.
		for _, channel in Constants.CHANNEL_NAMES do
			local outputImage = outputImageSet[channel]
			local baseSize = outputImage.Size / Constants.ATLAS_GRID_SIZE
			local editedBase = outputImage:ReadPixelsBuffer(Vector2.zero, baseSize)
			outputImage:DrawImage(Vector2.zero, baseImages[channel], Enum.ImageCombineType.Overwrite)
			outputImage:WritePixelsBuffer(Vector2.zero, baseSize, editedBase)
		end
	end
end

local function MakeSingleLayer(name: string, imageSetId: string): SingleLayer
	return {
		name = name,
		isVisible = true,
		imageSetId = imageSetId,
	}
end

-- Creates a SurfaceAppearance from an image set and parents it to the mesh part.
local function BindSurfaceAppearance(
	meshPart: MeshPart,
	set: EditableImageSet,
	normalMap: EditableImage,
	transparent: boolean?
)
	local surfaceAppearance = AssetService:CreateSurfaceAppearanceAsync({
		ColorMap = Content.fromObject(set.color),
		MetalnessMap = Content.fromObject(set.metalness),
		RoughnessMap = Content.fromObject(set.roughness),
		NormalMap = Content.fromObject(normalMap),
	})
	if transparent then
		surfaceAppearance.AlphaMode = Enum.AlphaMode.Transparency
	end
	surfaceAppearance.Parent = meshPart
end

-- Display paint with the same transferred UVs used by the projection target.
local function BindMakeupOverlay(meshPart: MeshPart, set: EditableImageSet)
	local transfer = meshPart:FindFirstChild(Constants.MAKEUP_PROJECTION_TRANSFER_NAME, true)
	assert(transfer and transfer:IsA("WrapTextureTransfer"), "Missing makeup projection transfer")
	local previousDecal = transfer.Parent
	local decal = AssetService:CreateDecalAsync({
		TextureContent = Content.fromObject(set.color),
		MetalnessMapContent = Content.fromObject(set.metalness),
		RoughnessMapContent = Content.fromObject(set.roughness),
	})
	assert(decal, "Failed to create makeup editing Decal")
	decal.Name = "MakeupProjectionDecal"
	transfer.Parent = decal
	decal.Parent = meshPart
	if previousDecal then
		previousDecal:Destroy()
	end
	transfer:PrepareProjectionMeshDataAsync()
end

local function IsMakeupProjectionHead(meshPart: MeshPart): boolean
	local transfer = meshPart:FindFirstChild(Constants.MAKEUP_PROJECTION_TRANSFER_NAME, true)
	return transfer ~= nil and transfer:IsA("WrapTextureTransfer")
end

local function BindEditableOutput(
	meshPart: MeshPart,
	set: EditableImageSet,
	normalMap: EditableImage,
	isMakeupProjectionHead: boolean,
	transparent: boolean?
)
	if isMakeupProjectionHead then
		BindMakeupOverlay(meshPart, set)
	else
		BindSurfaceAppearance(meshPart, set, normalMap, transparent)
	end
end

function TextureInfo:GetPBRMapSize(): Vector2
	local size = Constants.PBR_MAP_CELL_SIZE
	if self.enableKitbashing then
		return Vector2.new(size.X * Constants.ATLAS_GRID_SIZE, size.Y * Constants.ATLAS_GRID_SIZE)
	end
	return size
end

-- Creates a PBR EditableImage at the PBR map size and tracks it for cleanup.
function TextureInfo:CreatePBRMap(fillColor: Color3?): EditableImage
	local editableImage = AssetService:CreateEditableImage({ Size = self:GetPBRMapSize() })
	if not editableImage then
		self:ThrowMemoryError()
	end
	if fillColor then
		editableImage:DrawRectangle(Vector2.zero, editableImage.Size, fillColor, 0, Enum.ImageCombineType.Overwrite)
	end
	table.insert(self.pendingEditableImages, editableImage)
	return editableImage
end

function TextureInfo:LoadMakeupAccessoryNormal(content: Content?): string?
	if not content or content == Content.none then
		return nil
	end

	local normalMap, normalMapId = self.editableManager:CreateEI(self:GetPBRMapSize(), nil, self.managerId)
	normalMap:DrawRectangle(
		Vector2.zero,
		normalMap.Size,
		Constants.PBR_DEFAULT_NORMAL_COLOR,
		0,
		Enum.ImageCombineType.Overwrite
	)
	local tileSize = if self.enableKitbashing then normalMap.Size / Constants.ATLAS_GRID_SIZE else normalMap.Size
	self.editableManager:UseTemporaryImage(content, function(source)
		normalMap:DrawImageTransformed(
			tileSize / 2,
			tileSize / source.Size,
			0,
			source,
			{ CombineType = Enum.ImageCombineType.Overwrite }
		)
	end)
	return normalMapId
end

-- Destroys a single EditableImage and stops tracking it for cleanup.
function TextureInfo:UntrackAndDestroyImage(editableImage: EditableImage)
	local pendingIndex = table.find(self.pendingEditableImages, editableImage)
	if pendingIndex then
		table.remove(self.pendingEditableImages, pendingIndex)
	end
	editableImage:Destroy()
end

function TextureInfo:CreateScaledEditableImage(
	imageContent,
	accommodateKitbash: boolean?,
	pixelateSampling: boolean?,
	targetSize: Vector2?
): EditableImage
	local originalImage = AssetService:CreateEditableImageAsync(imageContent)
	if not originalImage then
		self:ThrowMemoryError()
	end

	targetSize = targetSize or self.textureResolution
	if accommodateKitbash then
		targetSize = Vector2.new(
			math.floor(targetSize.X / Constants.ATLAS_GRID_SIZE),
			math.floor(targetSize.Y / Constants.ATLAS_GRID_SIZE)
		)
	end

	if originalImage.Size.X == targetSize.X and originalImage.Size.Y == targetSize.Y then
		return originalImage
	end

	local allocated, scaledImage = pcall(AssetService.CreateEditableImage, AssetService, { Size = targetSize })
	if not allocated or not scaledImage then
		originalImage:Destroy()
		if not allocated then
			error(scaledImage, 0)
		end
		self:ThrowMemoryError()
	end

	local scale = originalImage.Size.X / targetSize.X
	if originalImage.Size.Y / targetSize.Y > scale then
		scale = originalImage.Size.Y / targetSize.Y
	end

	local success, result = pcall(function()
		scaledImage:DrawImageTransformed(
			scaledImage.Size / 2,
			if self.isMakeupAccessory then targetSize / originalImage.Size else Vector2.new(1 / scale, 1 / scale),
			0,
			originalImage,
			{
				-- Accessory maps must retain their full UV coverage and authored alpha.
				CombineType = if self.isMakeupAccessory then Enum.ImageCombineType.Overwrite else nil,
				SamplingMode = if pixelateSampling then Enum.ResamplerMode.Pixelated else nil,
			}
		)
	end)
	originalImage:Destroy()
	if not success then
		scaledImage:Destroy()
		error(result, 0)
	end

	return scaledImage
end

function TextureInfo:CreateBaseTextureLayer(
	textureId: string,
	accommodateKitbash: boolean?,
	contents: { [string]: Content }
): (SingleLayer, Vector2, Vector2)
	local setId = self:CreateManagerScopedId("BaseTexture:" .. textureId)
	local targetSize = self.textureResolution
	local fullTextureSize = targetSize
	local pbrSize = self:GetPBRMapSize()
	if accommodateKitbash then
		targetSize = Vector2.new(
			math.floor(targetSize.X / Constants.ATLAS_GRID_SIZE),
			math.floor(targetSize.Y / Constants.ATLAS_GRID_SIZE)
		)
		fullTextureSize =
			Vector2.new(targetSize.X * Constants.ATLAS_GRID_SIZE, targetSize.Y * Constants.ATLAS_GRID_SIZE)
		pbrSize = pbrSize / Constants.ATLAS_GRID_SIZE
	end

	local baseImages =
		self.editableManager:CreateEISet(fullTextureSize, self:GetPBRMapSize(), true, setId, self.managerId)
	local hasNoBaseTexture = self.isMakeupAccessory and contents.color == Content.none
	if not self.alphaClearBase and (self.creationType ~= Constants.CREATION_TYPES.Makeup or hasNoBaseTexture) then
		baseImages.color:DrawRectangle(
			Vector2.zero,
			if hasNoBaseTexture then targetSize else fullTextureSize,
			Color3.fromRGB(255, 255, 255),
			0,
			Enum.ImageCombineType.Overwrite
		)
	end

	local success, result = pcall(function()
		for _, channel in Constants.CHANNEL_NAMES do
			local content = contents[channel]
			if not content or content == Content.none or (channel == "color" and self.alphaClearBase) then
				continue
			end
			local channelSize = if channel == "color" then targetSize else pbrSize
			self.editableManager:UseTemporaryImage(content, function(tempTextureImage)
				local scale = math.max(tempTextureImage.Size.X / channelSize.X, tempTextureImage.Size.Y / channelSize.Y)
				baseImages[channel]:DrawImageTransformed(
					channelSize / 2,
					if self.isMakeupAccessory
						then channelSize / tempTextureImage.Size
						else Vector2.new(1 / scale, 1 / scale),
					0,
					tempTextureImage,
					{
						CombineType = if self.isMakeupAccessory
							then Enum.ImageCombineType.Overwrite
							else Enum.ImageCombineType.BlendSourceOver,
					}
				)
			end)
		end
	end)
	if not success then
		self.editableManager:DestroyEISet(setId, self.managerId)
		error(result, 0)
	end

	local layerInfo = {
		name = "BaseTexture",
		isVisible = true,
		imageSetId = setId,
	}

	return layerInfo, fullTextureSize, targetSize
end

function TextureInfo:CreateManagerScopedId(str: string): string
	return self.managerId .. ":" .. str
end

function TextureInfo:SetupModelTextures(model: Model): ModelTextureInfo
	local newModelInfo: ModelTextureInfo = {}
	local isMakeup = self.creationType == Constants.CREATION_TYPES.Makeup

	local textureIdToLayerMap = {}

	-- Set up reserved sticker layers
	self.reservedStickerEditableImageMap = {}
	if not isMakeup then
		for slotIndex = 1, Constants.MAX_STICKER_LAYERS do
			local stickerLayerName = Constants.STICKER_LAYER_PREFIX .. slotIndex
			local _, setId = self.editableManager:CreateEISet(
				self.textureResolution,
				self:GetPBRMapSize(),
				--[[fillPBRDefaults = ]]
				false,
				stickerLayerName,
				self.managerId
			)
			self.reservedStickerEditableImageMap[stickerLayerName] = setId
		end
	end

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

		local isMakeupProjectionHead = IsMakeupProjectionHead(descendant)
		local surfaceAppearance = descendant:FindFirstChildWhichIsA("SurfaceAppearance")
		local colorContent = if self.isMakeupAccessory
			then descendant.TextureContent
			else Content.fromUri(descendant.TextureID)
		local metalnessContent, roughnessContent, normalContent
		if self.isMakeupAccessory and surfaceAppearance then
			if surfaceAppearance.ColorMapContent ~= Content.none then
				colorContent = surfaceAppearance.ColorMapContent
			end
			metalnessContent = surfaceAppearance.MetalnessMapContent
			roughnessContent = surfaceAppearance.RoughnessMapContent
			normalContent = surfaceAppearance.NormalMapContent
		end
		if surfaceAppearance and not isMakeupProjectionHead then
			surfaceAppearance:Destroy()
		end

		if not descendant.TextureID and not isMakeupProjectionHead then
			error(
				"Error setting up model: MeshPart "
					.. descendant:GetFullName()
					.. " has empty TextureID. TextureID should be set."
			)
		end

		local textureKey = if isMakeupProjectionHead or self.isMakeupAccessory then descendant else descendant.TextureID
		if textureIdToLayerMap[textureKey] then
			local existingLayerInfo = textureIdToLayerMap[textureKey]
			newModelInfo[descendant] = existingLayerInfo
			BindEditableOutput(
				descendant,
				self.editableManager:GetEISet(existingLayerInfo.outputEditableSetId),
				self.editableManager:GetEI(existingLayerInfo.normalMapId or self.defaultNormalMapId),
				isMakeupProjectionHead,
				self.isMakeupAccessory
			)

			continue
		end

		local accommodateKitbash = self.enableKitbashing and not isMakeupProjectionHead
		local fullTextureSize = self.textureResolution
		local originalTextureSize = fullTextureSize
		local baseTextureLayer: SingleLayer?
		local normalMapId: string?
		if not isMakeupProjectionHead then
			if self.isMakeupAccessory then
				normalMapId = self:LoadMakeupAccessoryNormal(normalContent)
			end
			baseTextureLayer, fullTextureSize, originalTextureSize =
				self:CreateBaseTextureLayer(descendant.TextureID, accommodateKitbash, {
					color = colorContent,
					metalness = metalnessContent,
					roughness = roughnessContent,
				})
		end

		local outputSet, outputSetId = self.editableManager:CreateEISet(
			fullTextureSize,
			self:GetPBRMapSize(),
			false,
			self:CreateManagerScopedId("Output:" .. descendant.TextureID),
			self.managerId
		)

		local reservedBrushSetId: string?
		local inputLayers: { SingleLayer } = {}
		if not isMakeup then
			_, reservedBrushSetId = self.editableManager:CreateEISet(
				fullTextureSize,
				self:GetPBRMapSize(),
				false,
				if isMakeupProjectionHead
					then self.editableManager:CreateId("ReservedBrush:Projection")
					else "ReservedBrush:" .. descendant.TextureID,
				self.managerId
			)
			-- The fabric fill layer's PBR maps are filled opaque so per-region reflectivity
			-- (TextureUtils.ApplyPBRToRegion writes RGB only) composites over the base on merge-down.
			local _, reservedFillSetId = self.editableManager:CreateEISet(
				fullTextureSize,
				self:GetPBRMapSize(),
				--[[fillPBRDefaults = ]]
				true,
				if isMakeupProjectionHead
					then self.editableManager:CreateId("ReservedFill:Projection")
					else "ReservedFill:" .. descendant.TextureID,
				self.managerId
			)
			table.insert(inputLayers, MakeSingleLayer(Constants.FABRIC_FILL_LAYER, reservedFillSetId))
		end

		local groupLayers = GroupInfo.new(self.editableManager, self.managerId, fullTextureSize, self:GetPBRMapSize())

		local baseAlphaMask, baseAlphaMaskId
		if baseTextureLayer and self.preserveBaseTextureAlpha then
			local baseImages = self.editableManager:GetEISet(baseTextureLayer.imageSetId)
			baseAlphaMask, baseAlphaMaskId = self.editableManager:CreateEI(
				originalTextureSize,
				self:CreateManagerScopedId("BaseAlphaMask:" .. descendant.TextureID),
				self.managerId
			)
			baseAlphaMask:DrawRectangle(
				Vector2.zero,
				originalTextureSize,
				Color3.new(),
				0,
				Enum.ImageCombineType.Overwrite
			)
			-- Subtracting the source from opaque black leaves inverse alpha and no RGB.
			baseAlphaMask:DrawImage(Vector2.zero, baseImages.color, Enum.ImageCombineType.Subtract)
		end

		local newLayerInfo: LayerInfo = {
			baseTexture = baseTextureLayer,
			baseAlphaMaskId = baseAlphaMaskId,
			preserveKitbashTextures = accommodateKitbash and self.isMakeupAccessory,
			normalMapId = normalMapId,
			-- Base texture is composited first; inputLayers holds reserved layers only.
			inputLayers = inputLayers,
			groupLayers = groupLayers,
			outputEditableSetId = outputSetId,
			originalTextureId = descendant.TextureID,
			reservedBrushSetId = reservedBrushSetId,
			makeupGuideImagesByType = {},
			showMakeupGuides = false,
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

		textureIdToLayerMap[textureKey] = newLayerInfo

		DoMergeDownLayers(newLayerInfo, self.editableManager)

		BindEditableOutput(
			descendant,
			outputSet,
			self.editableManager:GetEI(normalMapId or self.defaultNormalMapId),
			isMakeupProjectionHead,
			self.isMakeupAccessory
		)

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

-- Region maps retain only pixel buffers; their source and resized images are temporary.
function TextureInfo:ReadRegionBuffer(textureId: string): buffer
	local regionBuffer: buffer

	local function readRegionPixels(originalImage: EditableImage)
		local targetSize = self.textureResolution
		if self.enableKitbashing then
			-- Region buffers cover only the accessory's slot in the atlas.
			targetSize = Vector2.new(
				math.floor(targetSize.X / Constants.ATLAS_GRID_SIZE),
				math.floor(targetSize.Y / Constants.ATLAS_GRID_SIZE)
			)
		end

		if originalImage.Size == targetSize then
			regionBuffer = originalImage:ReadPixelsBuffer(Vector2.zero, originalImage.Size)
			return
		end

		self.editableManager:UseTemporaryImage(targetSize, function(scaledImage: EditableImage)
			local scale = math.max(originalImage.Size.X / targetSize.X, originalImage.Size.Y / targetSize.Y)
			scaledImage:DrawImageTransformed(
				targetSize / 2,
				if self.isMakeupAccessory then targetSize / originalImage.Size else Vector2.new(1 / scale, 1 / scale),
				0,
				originalImage,
				{
					CombineType = if self.isMakeupAccessory then Enum.ImageCombineType.Overwrite else nil,
					SamplingMode = Enum.ResamplerMode.Pixelated,
				}
			)

			regionBuffer = scaledImage:ReadPixelsBuffer(Vector2.zero, scaledImage.Size)
		end)
	end

	local success, result = pcall(function()
		self.editableManager:UseTemporaryImage(Content.fromUri(textureId), readRegionPixels)
	end)

	if not success then
		self:DestroyAllTrackedImages()
		error(result, 0)
	end
	return regionBuffer
end

function TextureInfo:GetAllRegionBuffers(sourceRegionMap: RegionMaps.RegionMap): { [string]: buffer }
	local allRegionBuffers = {}

	for _, region: RegionMaps.Region in pairs(sourceRegionMap) do
		if region.regionTextureId and allRegionBuffers[region.regionTextureId] == nil then
			allRegionBuffers[region.regionTextureId] = self:ReadRegionBuffer(region.regionTextureId)
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

function TextureInfo:SetupMeshPartToRegionMap(regionMap: RegionMaps.RegionMap)
	local allSubRegionBuffers = self:GetAllRegionBuffers(regionMap)

	local MeshPartToRegionMap = {}
	for meshPartName, regionData in pairs(regionMap) do
		if regionData.regionTextureId ~= nil then
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

-- Replay layer stores our checkpoint for undo/redo
function TextureInfo:GetReplayBuffer(): (
	Constants.BufferSet?,
	{ color: Vector2, metalness: Vector2, roughness: Vector2 }?
)
	return self.replayBuffers, self.replaySizes
end

function TextureInfo:SetReplayBuffer(
	bufs: Constants.BufferSet,
	sizes: { color: Vector2, metalness: Vector2, roughness: Vector2 }
): ()
	self.replayBuffers = bufs
	self.replaySizes = sizes
end

function TextureInfo:DestroyAllTrackedImages()
	self:ReleaseStickerSourceImage()

	self.stampSetId = nil

	for _, ei in ipairs(self.pendingEditableImages) do
		if ei then
			ei:Destroy()
		end
	end
	if self.modelTextureInfo then
		for _, layerInfo in pairs(self.modelTextureInfo) do
			layerInfo.groupLayers:DestroyAllTrackedImages()
		end
	end
	self.editableManager:DestroyTrackedImagesFor(self.managerId)

	self.pendingEditableImages = {}
end

function TextureInfo:ThrowMemoryError(context: string?)
	self:DestroyAllTrackedImages()
	-- Todo: migrate all other EI into memory manager and call its ThrowMemoryError instead of destroying all EIs here
	self.editableManager:ThrowMemoryError(context)
end

function TextureInfo.new(editableManager, model, blankData: BlanksData.BlankData)
	local self = setmetatable({}, TextureInfo)

	-- Capture the resolution before any image allocation can yield.
	self.textureResolution = blankData.textureResolution or ResolutionManager.GetCurrentResolution()
	self.pendingEditableImages = {}

	self.editableManager = editableManager
	self.managerId = editableManager:CreateId(model.Name)

	self.creationType = blankData.creationType
	self.individualPartsNames = blankData.individualPartsNames
	self.enableKitbashing = blankData.enableKitbashing
	self.isMakeupAccessory = blankData.isMakeupAccessory
	self.alphaClearBase = blankData.alphaClearBase
	self.preserveBaseTextureAlpha = blankData.preserveBaseTextureAlpha
	self.regionMap = self:SetupRegionMap(blankData)
	self.perMeshPartRegionMap = self:SetupMeshPartToRegionMap(blankData.regionMapIndividual)
	self.targetLayerInfo = { groupId = nil, layerId = Constants.BRUSH_LAYER } :: TargetLayerInfo

	-- The group whose layers are currently held as live EditableImages across all
	-- of this model's textures.
	self.activeGroupId = nil

	self.reservedStickerEditableImageMap = {} :: { [string]: string }
	local success, modelTextureInfo = pcall(function()
		self.defaultNormalMapId = "DefaultNormalMap"
		if not self.editableManager:IdExists(self.defaultNormalMapId) then
			local normalMap, _ =
				self.editableManager:CreateEI(Vector2.new(1, 1), self.defaultNormalMapId, self.managerId)
			normalMap:DrawRectangle(
				Vector2.zero,
				normalMap.Size,
				Constants.PBR_DEFAULT_NORMAL_COLOR,
				0,
				Enum.ImageCombineType.Overwrite
			)
		else
			self.editableManager:AddManager(self.defaultNormalMapId, self.managerId)
		end

		return self:SetupModelTextures(model)
	end)
	if not success then
		self:DestroyAllTrackedImages()
		error(modelTextureInfo, 0)
	end
	self.modelTextureInfo = modelTextureInfo

	self.stickerSourceImageId = nil
	self.stickerSourceTextureId = nil
	self.mirroredStickerImageId = nil
	self.mirroredStickerTextureId = nil
	self.stampSetId = nil

	return self
end

function TextureInfo:Destroy()
	self:ReleaseMirroredStickerImage()

	self.stampSetId = nil
	self.stickerSourceImageId = nil
	self.stickerSourceTextureId = nil
	self.reservedStickerEditableImageMap = {}

	for _, layerInfo in pairs(self.modelTextureInfo) do
		layerInfo.groupLayers:DestroyAllTrackedImages()
	end
	self.editableManager:DestroyTrackedImagesFor(self.managerId)
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

function TextureInfo:GetBaseLayer(meshPart): EditableImage?
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	if layerInfo.baseTexture then
		return self.editableManager:GetEISet(layerInfo.baseTexture.imageSetId).color
	end
	return nil
end

function TextureInfo:GetTextureSize(meshPart: MeshPart): Vector2
	local layerInfo = self.modelTextureInfo[meshPart]

	local fullTextureSize = self.editableManager:GetEISet(layerInfo.outputEditableSetId).color.Size

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
function TextureInfo:GetOrCreateLayer(
	meshPart,
	targetLayerInfo: TargetLayerInfo,
	insertAfterLayerName: string?
): (EditableImageSet?, boolean)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	local groupId = targetLayerInfo.groupId
	local layerName = targetLayerInfo.layerId

	if groupId then
		local imageSetId, wasCreated = layerInfo.groupLayers:GetOrCreateLayerInGroup(
			{ groupId = groupId, layerId = layerName },
			insertAfterLayerName
		)
		return if imageSetId then self.editableManager:GetEISet(imageSetId) else nil, wasCreated
	end

	for _, layer in layerInfo.inputLayers do
		if layer.name == layerName then
			return self.editableManager:GetEISet(layer.imageSetId), false
		end
	end

	local colorSize = self.editableManager:GetEISet(layerInfo.outputEditableSetId).color.Size

	local newLayerId: string
	local newLayerSet: EditableImageSet

	if layerName == Constants.BRUSH_LAYER and layerInfo.reservedBrushSetId then
		newLayerId = layerInfo.reservedBrushSetId
		newLayerSet = self.editableManager:GetEISet(newLayerId)
	elseif layerName == Constants.STAMP_LAYER then
		newLayerSet = self:GetOrCreateStampImageSet(colorSize)
		newLayerId = self.stampSetId
	elseif self.reservedStickerEditableImageMap[layerName] then
		newLayerId = self.reservedStickerEditableImageMap[layerName]
		newLayerSet = if self.editableManager.eiSetToImagesMap[newLayerId]
			then self.editableManager:GetEISet(newLayerId)
			else nil
		if not newLayerSet or newLayerSet.color.Size ~= colorSize then
			if newLayerSet then
				self.editableManager:DestroyEISet(newLayerId, self.managerId)
			end

			newLayerSet =
				self.editableManager:CreateEISet(colorSize, self:GetPBRMapSize(), false, newLayerId, self.managerId)
		end
	else
		error(
			"Layer name "
				.. layerName
				.. " is not a reserved layer for this creation. Use groupId to create a user layer."
		)
	end

	-- Higher indices draw on top, so inserting after a layer places the new one directly above it.
	local insertionIndex = #layerInfo.inputLayers + 1
	if insertAfterLayerName then
		for i, layer in layerInfo.inputLayers do
			if layer.name == insertAfterLayerName then
				insertionIndex = i + 1
				break
			end
		end
	end

	table.insert(layerInfo.inputLayers, insertionIndex, MakeSingleLayer(layerName, newLayerId))

	return newLayerSet, true
end

function TextureInfo:RemoveLayer(meshPart, targetLayerInfo: TargetLayerInfo, destroyEI: boolean?)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	local groupId = targetLayerInfo.groupId
	local layerName = targetLayerInfo.layerId

	if groupId then
		layerInfo.groupLayers:RemoveLayerFromGroup({ groupId = groupId, layerId = layerName })
		self:UpdateOutputColorMap(meshPart)
		return
	end

	local layerFound = false
	for i, layer in layerInfo.inputLayers do
		if layer.name == layerName then
			if destroyEI then
				self.editableManager:DestroyEISet(layer.imageSetId, self.managerId)
				if layer.imageSetId == self.stampSetId then
					self.stampSetId = nil
				end
			end
			table.remove(layerInfo.inputLayers, i)
			layerFound = true
			break
		end
	end

	if not layerFound then
		warn("Layer not found: " .. layerName)
		return
	end

	self:UpdateOutputColorMap(meshPart)
end

function TextureInfo:HasLayer(meshPart, targetLayerInfo: TargetLayerInfo): boolean
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	if not layerInfo then
		return false
	end

	local groupId = targetLayerInfo.groupId

	if groupId then
		return layerInfo.groupLayers:HasLayerInGroup(targetLayerInfo)
	end

	local layerName = targetLayerInfo.layerId

	for _, layer in layerInfo.inputLayers do
		if layer.name == layerName then
			return true
		end
	end

	return false
end

function TextureInfo:MoveLayerInGroup(meshPart, targetLayerInfo: TargetLayerInfo, direction: number)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	layerInfo.groupLayers:MoveLayerInGroup(targetLayerInfo, direction)

	self:UpdateOutputColorMap(meshPart)
end

function TextureInfo:SetLayerVisible(meshPart, targetLayerInfo: TargetLayerInfo, isVisible: boolean)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	layerInfo.groupLayers:SetLayerVisible(targetLayerInfo, isVisible)
	self:UpdateOutputColorMap(meshPart)
end

function TextureInfo:SetLayerOpacity(meshPart, targetLayerInfo: TargetLayerInfo, opacity: number)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	layerInfo.groupLayers:SetLayerOpacity(targetLayerInfo, opacity)
	self:UpdateOutputColorMap(meshPart)
end

function TextureInfo:CreateGroup(meshPart, groupId: string, makeupAssetType: string?)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	layerInfo.groupLayers:CreateGroup(groupId, makeupAssetType)
end

function TextureInfo:GetGroup(meshPart, groupId: string): GroupInfo.GroupInfo
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	return layerInfo.groupLayers:GetGroup(groupId)
end

function TextureInfo:DeleteGroup(meshPart, groupId: string)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	layerInfo.groupLayers:DeleteGroup(groupId)
	self:UpdateOutputColorMap(meshPart)
end

function TextureInfo:MoveGroup(meshPart, groupId: string, direction: number)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	layerInfo.groupLayers:MoveGroup(groupId, direction)

	self:UpdateOutputColorMap(meshPart)
end

function TextureInfo:SetGroupVisible(meshPart, groupId: string, isVisible: boolean)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	layerInfo.groupLayers:SetGroupVisible(groupId, isVisible)
	self:UpdateOutputColorMap(meshPart)
end

function TextureInfo:GetAllGroups(meshPart): GroupInfo.GroupInfoClass
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	return layerInfo.groupLayers:GetAllGroups()
end

function TextureInfo:SetGroupMaskLayers(
	meshPart: MeshPart,
	maskLayersByMakeupAssetType: { [string]: GroupInfo.MaskLayer }?
)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	layerInfo.groupLayers:SetMaskLayersByMakeupAssetType(maskLayersByMakeupAssetType)
	self:UpdateOutputColorMap(meshPart)
end

function TextureInfo:GetLayerThumbnailContent(meshPart: MeshPart, targetLayerInfo: TargetLayerInfo): Content?
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	return layerInfo.groupLayers:GetLayerThumbnailContent(targetLayerInfo)
end

function TextureInfo:UpdateOutputColorMap(meshPart)
	if self.editingCache and self.editingCache.suspended then
		return
	end
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	local hideBaseTexture = self.preserveBaseTextureAlpha == false and not layerInfo.showMakeupGuides
	DoMergeDownLayers(layerInfo, self.editableManager, hideBaseTexture)
end

function TextureInfo:GetOriginalTextureId(meshPart: MeshPart): string
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]

	return layerInfo.originalTextureId
end

function TextureInfo:GetOutputImageSet(meshPart: MeshPart): (EditableImageSet?, EditableImage?)
	local layerInfo = self.modelTextureInfo[meshPart]
	return if layerInfo then self.editableManager:GetEISet(layerInfo.outputEditableSetId) else nil,
		if layerInfo and layerInfo.normalMapId
			then self.editableManager:GetEI(layerInfo.normalMapId)
			else self.editableManager:GetEI(self.defaultNormalMapId)
end

-- Uses a display preview when available; otherwise returns the original output images.
function TextureInfo:GetDisplayOutputImageSet(meshPart: MeshPart): (EditableImageSet?, EditableImage?)
	local cache = self.editingCache and self.editingCache.outputPreviewCache
	local preview = cache and cache.outputs[meshPart]
	if preview then
		local layer = self.modelTextureInfo[meshPart]
		return preview.images, self.editableManager:GetEI(layer.normalMapId or self.defaultNormalMapId)
	end
	return self:GetOutputImageSet(meshPart)
end

-- Caches the last sticker source by ID; the manager owns its EditableImage.
function TextureInfo:GetOrCreateEditableImageByTextureId(textureId: string): EditableImage
	if self.stickerSourceTextureId == textureId and self.stickerSourceImageId then
		return self.editableManager:GetEI(self.stickerSourceImageId)
	end

	self:ReleaseStickerSourceImage()

	local editableImage, imageId = self.editableManager:CreateEIFromContent(
		Content.fromUri(textureId),
		self.managerId .. ":StickerSource",
		self.managerId
	)
	self.stickerSourceImageId = imageId
	self.stickerSourceTextureId = textureId

	return editableImage
end

function TextureInfo:ReleaseStickerSourceImage()
	self:ReleaseMirroredStickerImage()
	if self.stickerSourceImageId then
		self.editableManager:DestroyEI(self.stickerSourceImageId, self.managerId)
		self.stickerSourceImageId = nil
	end
	self.stickerSourceTextureId = nil
end

function TextureInfo:ReleaseMirroredStickerImage()
	if self.mirroredStickerImageId then
		self.editableManager:DestroyEI(self.mirroredStickerImageId, self.managerId)
		self.mirroredStickerImageId = nil
	end
	self.mirroredStickerTextureId = nil
end

-- Cache a horizontal flip so moving or rotating a mirrored stamp does not recopy its pixels.
function TextureInfo:GetOrCreateMirroredStickerImage(textureId: string, stickerImage: EditableImage): EditableImage
	if self.mirroredStickerTextureId == textureId and self.mirroredStickerImageId then
		return self.editableManager:GetEI(self.mirroredStickerImageId)
	end
	self:ReleaseMirroredStickerImage()

	local size = stickerImage.Size
	local pendingImageId
	local success, mirroredImage, mirroredImageId = pcall(function()
		local image, imageId = self.editableManager:CreateEI(size, self.managerId .. ":MirroredStamp", self.managerId)
		pendingImageId = imageId
		image:DrawImageTransformed(size / 2, Vector2.new(-1, 1), 0, stickerImage, {
			CombineType = Enum.ImageCombineType.Overwrite,
			SamplingMode = Enum.ResamplerMode.Pixelated,
		})
		return image, imageId
	end)
	if not success then
		if pendingImageId then
			self.editableManager:DestroyEI(pendingImageId, self.managerId)
		end
		error(mirroredImage, 0)
	end

	self.mirroredStickerImageId = mirroredImageId
	self.mirroredStickerTextureId = textureId
	return mirroredImage
end

-- Lazily creates the stamp tool's working layer set at the requested size
function TextureInfo:GetOrCreateStampImageSet(size: Vector2): (EditableImageSet, boolean)
	if self.stampSetId then
		local stampSet = self.editableManager:GetEISet(self.stampSetId)
		if stampSet.color.Size == size then
			return stampSet, false --[[newly allocated?]]
		end
		self:ReleaseStampEditableImage()
	end

	local stampSet, stampSetId = self.editableManager:CreateEISet(
		size,
		Vector2.one, -- Stamps only draw color.
		false,
		self.managerId .. ":" .. Constants.STAMP_LAYER,
		self.managerId
	)

	self.stampSetId = stampSetId
	return stampSet, true --[[newly allocated?]]
end

-- Frees the stamp tool's working layer, freed whenever not stamping
function TextureInfo:ReleaseStampEditableImage()
	if self.stampSetId then
		self.editableManager:DestroyEISet(self.stampSetId, self.managerId)
		self.stampSetId = nil
	end
end

function TextureInfo:MeshPartsShareLayer(meshPart1: MeshPart, meshPart2: MeshPart): boolean
	local layerInfo1: LayerInfo = self.modelTextureInfo[meshPart1]
	local layerInfo2: LayerInfo = self.modelTextureInfo[meshPart2]

	return layerInfo1 == layerInfo2
end

function TextureInfo:GetTargetLayerInfo(): GroupInfo.TargetLayerInfo
	return self.targetLayerInfo
end

function TextureInfo:SetTargetLayerInfo(targetLayerInfo: GroupInfo.TargetLayerInfo)
	self.targetLayerInfo = targetLayerInfo
end

function TextureInfo:GetActiveGroupId(): string?
	return self.activeGroupId
end

-- Registers projection-space, preview-only guide images for this mesh part. The
-- active guide type is always derived from the currently selected group.
function TextureInfo:SetMakeupGuideImages(meshPart: MeshPart, guidesByType: { [string]: EditableImage })
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	layerInfo.makeupGuideImagesByType = guidesByType
	self:UpdateOutputColorMap(meshPart)
end

function TextureInfo:SetShowMakeupGuides(meshPart: MeshPart, showGuides: boolean)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	if layerInfo.showMakeupGuides == showGuides then
		return
	end
	layerInfo.showMakeupGuides = showGuides
	self:UpdateOutputColorMap(meshPart)
end

function TextureInfo:GetShowMakeupGuides(meshPart: MeshPart): boolean
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	return layerInfo.showMakeupGuides
end

function TextureInfo:GetActiveMakeupAssetType(meshPart: MeshPart): string?
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	local activeGroup = layerInfo.groupLayers:GetActiveGroup()
	return if activeGroup then activeGroup.makeupAssetType else nil
end

-- Recompose after a selection change
function TextureInfo:RefreshMakeupGuides(meshPart: MeshPart)
	local layerInfo: LayerInfo = self.modelTextureInfo[meshPart]
	if layerInfo.showMakeupGuides then
		self:UpdateOutputColorMap(meshPart)
	end
end

-- Marks groupId as the active group so that only its layers stay as live
-- EditableImages; every other group's layers are cached as runtime Content. Applies
-- across all of the model's textures (a logical group can span mesh parts that
-- share a texture). Pass nil to leave no group active.
function TextureInfo:SetActiveGroup(groupId: string?)
	self.activeGroupId = groupId

	for _, layerInfo in pairs(self:GetUniqueLayerMap()) do
		layerInfo.groupLayers:SetActiveGroup(groupId)
	end
end

export type TextureInfoClass = typeof(TextureInfo)

return TextureInfo
