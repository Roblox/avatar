--[[
	MakeupGuideManager loads the authored cage-space region guides and fits them
	to the editing WTT's UV bounds. Guides are only for editing
	convenience: they are transient overlays, never as uploadable layers.
]]

local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local MakeupProjectionUtils = require(Modules:WaitForChild("MeshManipulation"):WaitForChild("MakeupProjectionUtils"))

local HEAD_PART_NAME = "Head"

local GUIDE_ASSET_IDS: { [string]: string } = {
	[Constants.MAKEUP_ASSET_TYPES.Face] = "rbxassetid://97074796080001",
	[Constants.MAKEUP_ASSET_TYPES.Eyes] = "rbxassetid://76063788745016",
	[Constants.MAKEUP_ASSET_TYPES.Lips] = "rbxassetid://92080138105208",
}

local MakeupGuideManager = {}
MakeupGuideManager.__index = MakeupGuideManager

function MakeupGuideManager.new(modelInfo)
	local self = setmetatable({}, MakeupGuideManager)
	self.modelInfo = modelInfo
	-- Baked guides are cached as Content so they don't consume memory when not in use.
	self.cachedGuideContentByType = {}
	self.activeGuideImage = nil
	self.activeGuideContent = nil
	self.prebaked = false
	return self
end

function MakeupGuideManager:GetHeadPart(): MeshPart?
	return self.modelInfo:GetMeshPartByName(HEAD_PART_NAME)
end

function MakeupGuideManager:ReleaseActiveGuide()
	if not self.activeGuideImage then
		return
	end

	local headPart = self:GetHeadPart()
	if headPart then
		-- Remove the guide from TextureInfo before destroying its EditableImage.
		self.modelInfo:GetTextureInfo():SetMakeupGuideImages(headPart, {})
	end
	self.activeGuideImage:Destroy()
	self.activeGuideImage = nil
	self.activeGuideContent = nil
end

-- Rehydrates only the guide for the selected compatible group. The selected
-- makeup type is always queried from TextureInfo, never stored by this manager.
function MakeupGuideManager:RefreshActiveGuide()
	local headPart = self:GetHeadPart()
	if not headPart then
		return
	end

	local textureInfo = self.modelInfo:GetTextureInfo()
	if not textureInfo:GetShowMakeupGuides(headPart) then
		self:ReleaseActiveGuide()
		return
	end

	local makeupAssetType = textureInfo:GetActiveMakeupAssetType(headPart)
	local cachedContent = makeupAssetType and self.cachedGuideContentByType[makeupAssetType]
	if not cachedContent then
		self:ReleaseActiveGuide()
		textureInfo:RefreshMakeupGuides(headPart)
		return
	end

	if self.activeGuideImage and self.activeGuideContent == cachedContent then
		textureInfo:RefreshMakeupGuides(headPart)
		return
	end

	self:ReleaseActiveGuide()
	local guideImage = AssetService:CreateEditableImageAsync(cachedContent)
	if not guideImage then
		warn("[MakeupGuideManager] Failed to rehydrate " .. makeupAssetType .. " guide.")
		return
	end

	self.activeGuideImage = guideImage
	self.activeGuideContent = cachedContent
	textureInfo:SetMakeupGuideImages(headPart, { [makeupAssetType] = guideImage })
end

function MakeupGuideManager:SetVisible(isVisible: boolean)
	local headPart = self:GetHeadPart()
	if not headPart then
		return
	end

	self.modelInfo:GetTextureInfo():SetShowMakeupGuides(headPart, isVisible)
	if isVisible then
		self:RefreshActiveGuide()
	else
		self:ReleaseActiveGuide()
	end
end

-- Caches the decal-region guide images in projection texture space once.
function MakeupGuideManager:PrebakeAll()
	if self.prebaked then
		return
	end
	self.prebaked = true

	local headPart = self.modelInfo:GetMeshPartByName(HEAD_PART_NAME)
	if not headPart then
		warn("[MakeupGuideManager] No Head MeshPart found; makeup guides disabled.")
		return
	end

	local projectionTarget = self.modelInfo:GetMeshInfo():GetProjectionTarget(headPart)
	assert(projectionTarget:IsA("WrapTextureTransfer"), "Missing makeup projection transfer")

	for _, makeupAssetType in Constants.MAKEUP_DECAL_ASSET_TYPES do
		if not GUIDE_ASSET_IDS[makeupAssetType] then
			warn("[MakeupGuideManager] Missing guide asset ID for " .. makeupAssetType)
			continue
		end

		local sourceGuide: EditableImage?
		local sourceOk, sourceGuideOrError = pcall(function()
			return AssetService:CreateEditableImageAsync(Content.fromUri(GUIDE_ASSET_IDS[makeupAssetType]))
		end)

		if not sourceOk or not sourceGuideOrError then
			warn(
				("[MakeupGuideManager] %s guide failed to load; skipping it. %s"):format(
					makeupAssetType,
					tostring(sourceGuideOrError)
				)
			)
		else
			sourceGuide = sourceGuideOrError
			local targetOk, targetGuideOrError = pcall(function()
				return MakeupProjectionUtils.CreateTransferredRegionImage(sourceGuide, projectionTarget)
			end)

			if targetOk and targetGuideOrError then
				local targetGuide = targetGuideOrError
				local result, content = AssetService:CreateDataModelContentAsync(Content.fromObject(targetGuide))
				targetGuide:Destroy()
				if result == Enum.CreateContentResult.Success then
					self.cachedGuideContentByType[makeupAssetType] = content
				else
					warn(
						("[MakeupGuideManager] %s guide failed to cache; skipping it. %s"):format(
							makeupAssetType,
							tostring(result)
						)
					)
				end
			else
				warn(
					("[MakeupGuideManager] %s guide bake failed; skipping it. %s"):format(
						makeupAssetType,
						tostring(targetGuideOrError)
					)
				)
			end
			if sourceGuide then
				sourceGuide:Destroy()
				sourceGuide = nil
			end
		end

		task.wait()
	end

	-- Register an empty live-guide map. Guides rehydrate lazily from cached Content.
	self.modelInfo:GetTextureInfo():SetMakeupGuideImages(headPart, {})
end

function MakeupGuideManager:Destroy()
	if self.activeGuideImage then
		self.activeGuideImage:Destroy()
		self.activeGuideImage = nil
	end
	self.activeGuideContent = nil
	table.clear(self.cachedGuideContentByType)
end

export type MakeupGuideManagerClass = typeof(MakeupGuideManager)

return MakeupGuideManager
