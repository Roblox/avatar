local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Assets = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Assets
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local ParticleEffectManager = require(Modules.AvatarExperience.Common.Managers.ParticleEffectManager)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local AppPage = require(Modules.NotLApp.AppPage)
-- local FetchTheme = require(Modules.LuaApp.Thunks.FetchTheme)

local GetFFlagAvatarExperienceImproveBackgroundTransition = function() return true end
local GetFFlagAvatarExperienceImproveBackgroundTiming = function() return true end
local GetFFlagAvatarExperienceUseInternalBackgroundAsset = function() return true end
local FFlagEnableAvatarExperienceLandingPage = false

local BackgroundSceneManager = {}
BackgroundSceneManager.__index = BackgroundSceneManager

local HIGH_QUALITY_EMITTER_RATE = 20
local LOW_QUALITY_EMITTER_RATE = 160

local NewSceneInformation = {
	Lighting = {
		Brightness = 2,
		ColorShift_Bottom = Color3.fromRGB(232, 255, 146),
		ColorShift_Top = Color3.fromRGB(85, 136, 167),
		OutdoorAmbient = Color3.fromRGB(0, 0, 0),
		Ambient = Color3.fromRGB(170, 170, 170),
		ClockTime = 12,
		GeographicLatitude = 41.733,
		TimeOfDay = "12:00:00",
		FogColor = Color3.fromRGB(45, 46, 49),
		FogEnd = 92,
		FogStart = 20,
		Sky = {
			CelestialBodiesShown = true,
			SkyboxAssetId = "rbxassetid://3576947212", -- Dark Theme Default
			StarCount = 3000,
		},
	},
	Bloom = {
		Intensity = 0.3,
		Size = 12,
		Threshold = 0.95,
	},
	ColorCorrection = {
		Brightness = 0,
		Contrast = 0,
		Saturation = 0,
	},
}

local ThemeInformation = {
	LightTheme = {
		BackPanelTextureColor = Color3.fromRGB(213, 213, 213),
		CloudsTextureColor = Color3.fromRGB(222, 222, 222),
		LargerShapesTextureColor = Color3.fromRGB(222, 222, 222),
		BasePlateColor = Color3.fromRGB(213, 213, 213),
		CharacterSpotLightBrightness = 6,
		FogColor = Color3.fromRGB(213, 213, 213),
		SkyboxTexture = "rbxassetid://3576283885",
		SkyboxAssetLocation = "rbxasset://textures/AvatarEditorImages/LightPixel.png",
		ParticleEmitterColorCatalogToAE = ColorSequence.new(Color3.fromRGB(171, 169, 161), Color3.fromRGB(158, 135, 120)),
		ParticleEmitterColorAEToCatalog = ColorSequence.new(Color3.fromRGB(158, 135, 120), Color3.fromRGB(171, 169, 161)),
	},
	DarkTheme = {
		BackPanelTextureColor = Color3.fromRGB(66, 63, 65),
		CloudsTextureColor = Color3.fromRGB(90, 91, 98),
		LargerShapesTextureColor = Color3.fromRGB(90, 91, 98),
		BasePlateColor = Color3.fromRGB(66, 63, 65),
		CharacterSpotLightBrightness = 15,
		FogColor = Color3.fromRGB(45, 46, 49),
		SkyboxTexture = "rbxassetid://3576947212",
		SkyboxAssetLocation = "rbxasset://textures/AvatarEditorImages/DarkPixel.png",
		ParticleEmitterColorCatalogToAE = ColorSequence.new(Color3.fromRGB(79, 75, 79), Color3.fromRGB(51, 49, 52)),
		ParticleEmitterColorAEToCatalog = ColorSequence.new(Color3.fromRGB(51, 49, 52), Color3.fromRGB(79, 75, 79)),
	},
}

local ModelInformation = {
	AvatarEditor = {
		TextureWallTransparency = 1,
		LargerShapesPosition = Vector3.new(-62.898, 6.97, -8.815),
		CloudsPosition = Vector3.new(-90, 20, 0),
	},
	Catalog = {
		TextureWallTransparency = 0,
		LargerShapesPosition = Vector3.new(-62.898, -12.3, -8.815),
		CloudsPosition = Vector3.new(-90, 80, 0),
	},
}

local function updateModelInfo(baseplate, newBaselatePosition)
	local offset = newBaselatePosition - baseplate.Position

	ModelInformation.AvatarEditor.LargerShapesPosition = ModelInformation.AvatarEditor.LargerShapesPosition + offset
	ModelInformation.AvatarEditor.CloudsPosition = ModelInformation.AvatarEditor.CloudsPosition + offset
	ModelInformation.Catalog.LargerShapesPosition = ModelInformation.Catalog.LargerShapesPosition + offset
	ModelInformation.Catalog.CloudsPosition = ModelInformation.Catalog.CloudsPosition + offset
end

function BackgroundSceneManager.new(store)
	local self = {}
	setmetatable(self, BackgroundSceneManager)
	self.connections = {}

	self.store = store

	self.newBackgroundScene = Assets.AvatarSceneNew
	self.newBackgroundScene.PrimaryPart = self.newBackgroundScene.Baseplate
	updateModelInfo(self.newBackgroundScene.Baseplate, Vector3.new(0, -10 + 10000, 0))
	self.newBackgroundScene:SetPrimaryPartCFrame(CFrame.new(0, -10 + 10000, 0))

	self.ParticleEffectManager = ParticleEffectManager.new(store)

	self.backPanelTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0)
	self.backgroundTweenInfoAppear = TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0)
	self.backgroundTweenInfoDisappear = TweenInfo.new(.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.In, 0, false, 0)
	self.backPanelAppearGoals = { Transparency = ModelInformation.Catalog.TextureWallTransparency }
	self.backPanelDisappearGoals = { Transparency = ModelInformation.AvatarEditor.TextureWallTransparency }
	self.newBackgroundScene.BackPanel.Transparency = ModelInformation.AvatarEditor.TextureWallTransparency

	self.appearTween = TweenService:Create(self.newBackgroundScene.BackPanel.TextureWall,
		self.backPanelTweenInfo, self.backPanelAppearGoals)
	self.disappearTween = TweenService:Create(self.newBackgroundScene.BackPanel.TextureWall,
		self.backPanelTweenInfo, self.backPanelDisappearGoals)
	self.appearTween2 = TweenService:Create(self.newBackgroundScene.BackPanel.TextureFloor,
		self.backPanelTweenInfo, self.backPanelAppearGoals)
	self.disappearTween2 = TweenService:Create(self.newBackgroundScene.BackPanel.TextureFloor,
		self.backPanelTweenInfo, self.backPanelDisappearGoals)

	self.largerShapesAppearTween = TweenService:Create(self.newBackgroundScene.LargerShapes,
		self.backgroundTweenInfoAppear, {Position = ModelInformation.AvatarEditor.LargerShapesPosition})
	self.largerShapesDisappearTween = TweenService:Create(self.newBackgroundScene.LargerShapes,
		self.backgroundTweenInfoDisappear, {Position = ModelInformation.Catalog.LargerShapesPosition})
	self.cloudsAppearTween = TweenService:Create(self.newBackgroundScene.Clouds,
		self.backgroundTweenInfoAppear, {Position = ModelInformation.AvatarEditor.CloudsPosition})
	self.cloudsDisappearTween = TweenService:Create(self.newBackgroundScene.Clouds,
		self.backgroundTweenInfoDisappear, {Position = ModelInformation.Catalog.CloudsPosition})

	--local themeName = "dark"
	--self:updateTheme(string.lower(themeName))

	return self
end

function BackgroundSceneManager:updateTheme(theme)
	self.theme = theme

	-- Currently defaults to light theme.
	local themeInfo = ThemeInformation.LightTheme
	if theme == "dark" then
		themeInfo = ThemeInformation.DarkTheme
	end

	for _, child in pairs(self.newBackgroundScene.BackPanel:GetChildren()) do
		child.Color3 = themeInfo.BackPanelTextureColor
	end

	for _, child in pairs(self.newBackgroundScene.Clouds:GetChildren()) do
		child.Color3 = themeInfo.CloudsTextureColor
	end

	for _, child in pairs(self.newBackgroundScene.LargerShapes:GetChildren()) do
		child.Color3 = themeInfo.LargerShapesTextureColor
	end

	self.newBackgroundScene.Baseplate.Color = themeInfo.BasePlateColor

	self.newBackgroundScene.CharacterSpotLight.SpotLight.Brightness = themeInfo.CharacterSpotLightBrightness

	local skyboxTexture = GetFFlagAvatarExperienceUseInternalBackgroundAsset() and themeInfo.SkyboxAssetLocation
		or themeInfo.SkyboxTexture

	if not Lighting:FindFirstChild("Sky") then
		Assets.Sky:Clone().Parent = Lighting
	end

	if not Lighting:FindFirstChild("Bloom") then
		Assets.Bloom:Clone().Parent = Lighting
	end

	if not Lighting:FindFirstChild("ColorCorrection") then
		Assets.ColorCorrection:Clone().Parent = Lighting
	end

	Lighting.FogColor = themeInfo.FogColor
	Lighting.Sky.SkyboxBk = skyboxTexture
	Lighting.Sky.SkyboxDn = skyboxTexture
	Lighting.Sky.SkyboxFt = skyboxTexture
	Lighting.Sky.SkyboxLf = skyboxTexture
	Lighting.Sky.SkyboxRt = skyboxTexture
	Lighting.Sky.SkyboxUp = skyboxTexture

	self.newBackgroundScene.AvatarEditorToCatalogPFX.BIGBOIS.Color = themeInfo.ParticleEmitterColorAEToCatalog
	self.newBackgroundScene.AvatarEditorToCatalogPFX.SmolBois.Color = themeInfo.ParticleEmitterColorAEToCatalog
	self.newBackgroundScene.CatalogToAvatarEditorPFX.BIGBOIS.Color = themeInfo.ParticleEmitterColorCatalogToAE
	self.newBackgroundScene.CatalogToAvatarEditorPFX.SmolBois.Color = themeInfo.ParticleEmitterColorCatalogToAE
end

function BackgroundSceneManager:recordOldLighting()
	self.oldLightingInfo = {}

	for key, _ in pairs(NewSceneInformation.Lighting) do
		if key ~= "Sky" then
			self.oldLightingInfo[key] = Lighting[key]
		end
	end
end

function BackgroundSceneManager:updateLighting()
	self:recordOldLighting()

	Lighting.Brightness = NewSceneInformation.Lighting.Brightness
	Lighting.ColorShift_Bottom = NewSceneInformation.Lighting.ColorShift_Bottom
	Lighting.ColorShift_Top = NewSceneInformation.Lighting.ColorShift_Top
	Lighting.OutdoorAmbient = NewSceneInformation.Lighting.OutdoorAmbient
	Lighting.Ambient = NewSceneInformation.Lighting.Ambient
	Lighting.ClockTime = NewSceneInformation.Lighting.ClockTime
	Lighting.GeographicLatitude = NewSceneInformation.Lighting.GeographicLatitude
	Lighting.TimeOfDay = NewSceneInformation.Lighting.TimeOfDay
	Lighting.FogEnd = NewSceneInformation.Lighting.FogEnd
	Lighting.FogStart = NewSceneInformation.Lighting.FogStart

	Lighting.Sky.CelestialBodiesShown = NewSceneInformation.Lighting.Sky.CelestialBodiesShown
	Lighting.Sky.StarCount = NewSceneInformation.Lighting.Sky.StarCount

	Lighting.Bloom.Intensity = NewSceneInformation.Bloom.Intensity
	Lighting.Bloom.Size = NewSceneInformation.Bloom.Size
	Lighting.Bloom.Threshold = NewSceneInformation.Bloom.Threshold

	Lighting.ColorCorrection.Brightness = NewSceneInformation.ColorCorrection.Brightness
	Lighting.ColorCorrection.Contrast = NewSceneInformation.ColorCorrection.Brightness
	Lighting.ColorCorrection.Saturation = NewSceneInformation.ColorCorrection.Brightness
end

function BackgroundSceneManager:playParticleEmitters(newPage)
	if newPage == AppPage.AvatarEditor then
		coroutine.wrap(function()
			self.newBackgroundScene.CatalogToAvatarEditorPFX.BIGBOIS.Enabled = true
			self.newBackgroundScene.CatalogToAvatarEditorPFX.SmolBois.Enabled = true
			wait(1)
			self.newBackgroundScene.CatalogToAvatarEditorPFX.BIGBOIS.Enabled = false
			self.newBackgroundScene.CatalogToAvatarEditorPFX.SmolBois.Enabled = false
		end)()
	elseif newPage == AppPage.Catalog then
		coroutine.wrap(function()
			self.newBackgroundScene.AvatarEditorToCatalogPFX.BIGBOIS.Enabled = true
			self.newBackgroundScene.AvatarEditorToCatalogPFX.SmolBois.Enabled = true
			wait(1)
			self.newBackgroundScene.AvatarEditorToCatalogPFX.BIGBOIS.Enabled = false
			self.newBackgroundScene.AvatarEditorToCatalogPFX.SmolBois.Enabled = false
		end)()
	end
end

function BackgroundSceneManager:playTween(appPage)
	if appPage == AppPage.AvatarEditor then
		coroutine.wrap(function()
			self.disappearTween:Play()
			self.disappearTween2:Play()
			self:playParticleEmitters(AppPage.AvatarEditor)
			wait(0.2)
			if GetFFlagAvatarExperienceImproveBackgroundTiming() and
				AvatarExperienceUtils.getCurrentPage(self.store:getState()) ~= AppPage.AvatarEditor then
				return
			end
			self.largerShapesAppearTween:Play()
			wait(0.2)
			if GetFFlagAvatarExperienceImproveBackgroundTiming() and
				AvatarExperienceUtils.getCurrentPage(self.store:getState()) ~= AppPage.AvatarEditor then
				return
			end
			self.cloudsAppearTween:Play()
		end)()
	elseif appPage == AppPage.Catalog or appPage == AppPage.AvatarExperienceLandingPage then
		coroutine.wrap(function()
			if appPage ~= AppPage.AvatarExperienceLandingPage then
				self:playParticleEmitters(AppPage.Catalog)
			end
			self.largerShapesDisappearTween:Play()
			wait(0.2)
			if GetFFlagAvatarExperienceImproveBackgroundTiming() and
				AvatarExperienceUtils.getCurrentPage(self.store:getState()) ~= AppPage.Catalog then
				return
			end
			self.cloudsDisappearTween:Play()
			wait(0.1)
			if GetFFlagAvatarExperienceImproveBackgroundTiming() and
				AvatarExperienceUtils.getCurrentPage(self.store:getState()) ~= AppPage.Catalog then
				return
			end
			self.appearTween:Play()
			self.appearTween2:Play()
		end)()
	end
end

function BackgroundSceneManager:instantTransition(appPage)
	if appPage == AppPage.AvatarEditor then
		self.newBackgroundScene.BackPanel.TextureFloor.Transparency = ModelInformation.AvatarEditor.TextureWallTransparency
		self.newBackgroundScene.BackPanel.TextureWall.Transparency = ModelInformation.AvatarEditor.TextureWallTransparency
		self.newBackgroundScene.LargerShapes.Position = ModelInformation.AvatarEditor.LargerShapesPosition
		self.newBackgroundScene.Clouds.Position = ModelInformation.AvatarEditor.CloudsPosition
	elseif appPage == AppPage.Catalog then
		self.newBackgroundScene.BackPanel.TextureFloor.Transparency = ModelInformation.Catalog.TextureWallTransparency
		self.newBackgroundScene.BackPanel.TextureWall.Transparency = ModelInformation.Catalog.TextureWallTransparency
		self.newBackgroundScene.LargerShapes.Position = ModelInformation.Catalog.LargerShapesPosition
		self.newBackgroundScene.Clouds.Position = ModelInformation.Catalog.CloudsPosition
	end
end

--[[
	Background transition should occur when navigating between the Avatar Editor
	and Catalog. Since some pages are actually overlays on top of Editor/Catalog,
	these should be taken into account.
]]
function BackgroundSceneManager:update(newState, oldState)
	local newPage = AvatarExperienceUtils.getCurrentPage(newState)
	local oldPage = AvatarExperienceUtils.getCurrentPage(oldState)
	local oldParentPage = AvatarExperienceUtils.getParentPage(oldState)
	local enableImprovedTransition = GetFFlagAvatarExperienceImproveBackgroundTransition() and
		((newPage == AppPage.AvatarEditor and (oldPage == AppPage.Catalog or oldParentPage == AppPage.Catalog))
		or (newPage == AppPage.Catalog and (oldPage == AppPage.AvatarEditor or oldParentPage == AppPage.AvatarEditor)))
	local oldFunctionality = not GetFFlagAvatarExperienceImproveBackgroundTransition() and
		(newPage == AppPage.AvatarEditor or newPage == AppPage.Catalog) and
		(oldPage == AppPage.AvatarEditor or oldPage == AppPage.Catalog)

	local isLandingPageTransition = FFlagEnableAvatarExperienceLandingPage and
		(newPage == AppPage.AvatarExperienceLandingPage or oldPage == AppPage.AvatarExperienceLandingPage)
	local isAvatarEditorTransition = newPage == AppPage.AvatarEditor or oldPage == AppPage.AvatarEditor
	local isCatalogPageTransition = newPage == AppPage.Catalog or oldPage == AppPage.Catalog

	local landingPageTransition = isLandingPageTransition and (isCatalogPageTransition or isAvatarEditorTransition)
	if newPage ~= oldPage then
		if oldFunctionality or enableImprovedTransition or landingPageTransition then
			self:playTween(newPage)
		else
			self:instantTransition(newPage)
		end
	end
end

function BackgroundSceneManager:start()
	local page = AvatarExperienceUtils.getCurrentPage(self.store:getState())
	local currentTheme = "dark" --string.lower(NotificationService.SelectedTheme)

	self:updateTheme(currentTheme)

	table.insert(self.connections, self.store.changed:connect(function(state, oldState)
		self:update(state, oldState)
	end))

	--[[
		-- TODO AVBURST-1686 Look into having a consistent App rendering quality level.
		App starts at Level01 quality level. When a user joins a game the quality level
		changes to whatever the game has. If the quality level increases, the particle
		emitter rate needs to change.
	]]
	local emitterRate = HIGH_QUALITY_EMITTER_RATE
	self.newBackgroundScene.BlobShadow.Decal.Transparency = 1

	local emitterRateOverride = 0

	if emitterRateOverride > 0 then
		emitterRate = emitterRateOverride
	end

	self.newBackgroundScene.AvatarEditorToCatalogPFX.BIGBOIS.Rate = emitterRate
	self.newBackgroundScene.AvatarEditorToCatalogPFX.SmolBois.Rate = emitterRate
	self.newBackgroundScene.CatalogToAvatarEditorPFX.BIGBOIS.Rate = emitterRate
	self.newBackgroundScene.CatalogToAvatarEditorPFX.SmolBois.Rate = emitterRate

	-- TODO AVBURST-1630 - Remove Lighting adjustments when removing the old Avatar Editor scene
	self:updateLighting()

	self.newBackgroundScene.Parent = game.Workspace

	if page == AppPage.AvatarEditor or page == AppPage.Catalog then
		self:instantTransition(page)
	end

	self.ParticleEffectManager:start()
end

function BackgroundSceneManager:resetLighting()
	local sky = Lighting:FindFirstChild("Sky")
	if sky then
		sky:Destroy()
	end

	local bloom = Lighting:FindFirstChild("Bloom")
	if bloom then
		bloom:Destroy()
	end

	local colorCorrection = Lighting:FindFirstChild("ColorCorrection")
	if colorCorrection then
		colorCorrection:Destroy()
	end

	if self.oldLightingInfo then
		for key, value in pairs(self.oldLightingInfo) do
			Lighting[key] = value
		end
		self.oldLightingInfo = nil
	end
end

function BackgroundSceneManager:stop()
	for _, connection in ipairs(self.connections) do
		connection:disconnect()
	end
	self.connections = {}
	self.newBackgroundScene.Parent = ReplicatedStorage
	self.ParticleEffectManager:stop()
	self:resetLighting()
end

function BackgroundSceneManager:onDestroy()
	self.ParticleEffectManager:onDestroy()
end

return BackgroundSceneManager
