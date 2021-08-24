local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local TweenService = game:GetService("TweenService")

local DeviceOrientationMode = require(Modules.NotLApp.DeviceOrientationMode)
local AppPage = require(Modules.NotLApp.AppPage)
local AvatarExperienceUtils = require(Modules.AvatarExperience.Common.Utils)
local Constants = require(Modules.AvatarExperience.Common.Constants)
local CatalogConstants = require(Modules.AvatarExperience.Catalog.CatalogConstants)
local CatalogCategories = require(Modules.AvatarExperience.Catalog.Categories)
local AvatarEditorCategories = require(Modules.AvatarExperience.AvatarEditor.Categories)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)

local GetFFlagAvatarExperienceFlattenCameraPerspective = function() return true end

local CameraTween = nil
if GetFFlagAvatarExperienceFlattenCameraPerspective() then
	CameraTween = require(Modules.AvatarExperience.Common.Services.CameraTween)
end

local FFlagLuaAppEnableAERedesign = function() return true end
local FFlagAvatarEditorUpdateCamera = function() return true end
local IsLuaCatalogPageEnabled = true
local FFlagAvatarEditorAttachmentCameraFocus = true
local FFlagLuaCatalogRedirectOwnedBundleToCorrectCategory = true

local CameraManager = {}
CameraManager.__index = CameraManager

local STANDARD_TOP_BAR_HEIGHT = 64
local EXTRA_ZOOM_PORTRAIT = 34
local EXTRA_ZOOM_LANDSCAPE = 15
local FOV = 50
local CONSOLE = "Console"
local ANIMATION_ZOOM_DECREASE = 5

local ThemeInfo = {
	[DeviceOrientationMode.Portrait] = {
		cameraCenterScreenPosition = UDim2.new(0, 0, -0.5, 40),
		cameraDefaultPosition = Vector3.new(19.24339867, 4.52802134 + 10000, 0.594265997),

		landingPageCameraCenterScreenPosition = UDim2.new(0, 0, -0.4, 40),
		landingPageScalarConstant = 5.5,

		scalarConstant = 3.9,
		extentScalar = 2.5,
		zoomRadius = function(zoomRadius)
			return zoomRadius
		end,
		adjustCameraCenterPosition = function(cameraCenterScreenPosition, topBarHeight)
			return cameraCenterScreenPosition - UDim2.new(0, 0, 0, STANDARD_TOP_BAR_HEIGHT - topBarHeight)
		end,
	},

	[DeviceOrientationMode.Landscape] = {
		cameraCenterScreenPosition = UDim2.new(AvatarExperienceConstants.LandscapeNavWidth, 0, 0, 10),
		cameraDefaultPosition = Vector3.new(9.24339867, 3.52802134 + 10000, 0.594265997),
		scalarConstant = 3.9,
		extentScalar = 2,
		zoomRadius = function(zoomRadius)
			return zoomRadius
		end,
		adjustCameraCenterPosition = function(cameraCenterScreenPosition, topBarHeight)
			return cameraCenterScreenPosition - UDim2.new(0, 0, 0, STANDARD_TOP_BAR_HEIGHT - topBarHeight)
		end,
	},

	[CONSOLE] = {
		cameraCenterScreenPosition = UDim2.new(0, 0, 0, 0),
		cameraDefaultPosition = Vector3.new(11.4540, 4.4313 + 10000, -24.0810),
		scalarConstant = 4.9,
		extentScalar = 2,
		zoomRadius = function(zoomRadius)
			return math.min(7, zoomRadius)
		end,
		adjustCameraCenterPosition = function(cameraCenterScreenPosition, topBarHeight)
			return cameraCenterScreenPosition
		end,
	}
}

local function getAvatarType(state)
	if FFlagLuaAppEnableAERedesign() then
		return state.AvatarExperience.AvatarEditor.Character.AvatarType
	else
		return state.AEAppReducer.AECharacter.AEAvatarType
	end
end

function CameraManager.new(store)
	local self = {}
	setmetatable(self, CameraManager)

	self.store = store
	self.connections = {}

	local camera = game.Workspace.CurrentCamera
	self.camera = camera

	self.tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)

	return self
end

local function playCameraTween(self, targetCFrame)
	CameraTween.new(self.camera, targetCFrame, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut):play()
end

function CameraManager:start()
	local storeChangedConnection = self.store.changed:connect(function(state, oldState)
		self:update(state, oldState)
	end)
	self.connections[#self.connections + 1] = storeChangedConnection

	self.camera.CameraType = Enum.CameraType.Scriptable
	-- TODO AVBURST-1630 - Remove FOV adjustments (put in place file) when removing the old Avatar Editor scene.
	self.camera.FieldOfView = 50

	local currentCharacter = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter
	if not currentCharacter then
		return
	end

	local state = self.store:getState()
	local page = self:getPage()
	self:handleCameraChange(page, state, true)
end

function CameraManager:stop()
	for _, connection in ipairs(self.connections) do
		connection:disconnect()
	end
	self.connections = {}
end

function CameraManager:getFullView(state)
	state = state or self.store:getState()
	return AvatarExperienceUtils.getFullViewFromState(state)
end

function CameraManager:getPage(state)
	state = state or self.store:getState()

	if FFlagAvatarEditorUpdateCamera() then
		local parentPage = AvatarExperienceUtils.getParentPage(state)
		if parentPage == AppPage.AvatarEditor then
			local categoryIndex = state.AvatarExperience.AvatarEditor.Categories.category
			local subcategoryIndex = state.AvatarExperience.AvatarEditor.Categories.subcategory
			return AvatarExperienceUtils.GetCategoryInfo(AvatarEditorCategories, categoryIndex, subcategoryIndex)
		elseif parentPage == AppPage.Catalog then
			local categoryIndex = state.AvatarExperience.Catalog.Categories.category
			local subcategoryIndex = state.AvatarExperience.Catalog.Categories.subcategory
			return AvatarExperienceUtils.GetCategoryInfo(CatalogCategories, categoryIndex, subcategoryIndex)
		else
			return AvatarExperienceUtils.getPageFromState(state)
		end
	else
		return AvatarExperienceUtils.getPageFromState(state)
	end
end

function CameraManager:getTopBarHeight(state)
	state = state or self.store:getState()

	if AvatarExperienceUtils.getCurrentPage(state).name == AppPage.SearchPage then
		return 0
	end
	
	local topBarHeight = state.TopBar and state.TopBar.topBarHeight or 36
	
	return topBarHeight
end

function CameraManager:update(state, oldState)
	local currentCharacter = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter
	if not currentCharacter then
		return
	end

	local currentFullView = self:getFullView(state)
	local oldFullView = self:getFullView(oldState)

	local avatarType = getAvatarType(state)

	local newPage = self:getPage(state)
	if not newPage then
		return
	end

	local oldPage = self:getPage(oldState)

	local characterModelVersion = state.AvatarExperience.AvatarScene.Character.CharacterModelVersion
	local prevCharacterModelVersion = oldState.AvatarExperience.AvatarScene.Character.CharacterModelVersion
	local tryOnCharacterModelVersion = IsLuaCatalogPageEnabled
		and state.AvatarExperience.AvatarScene.Character.TryOnCharacterModelVersion or nil
	local prevTryOnCharacterModelVersion = IsLuaCatalogPageEnabled
		and oldState.AvatarExperience.AvatarScene.Character.TryOnCharacterModelVersion or nil
	local newCharacterModelVersion = characterModelVersion ~= prevCharacterModelVersion
		or tryOnCharacterModelVersion ~= prevTryOnCharacterModelVersion
	local newCharacter = state.AvatarExperience.AvatarScene.Character.CurrentCharacter
	local oldCharacter = oldState.AvatarExperience.AvatarScene.Character.CurrentCharacter

	local topBarHeight = self:getTopBarHeight(state)
	local oldTopBarHeight = self:getTopBarHeight(oldState)

	local instantChange = false
	if state.DeviceOrientation ~= oldState.DeviceOrientation then
		instantChange = true
	end

	if newCharacter ~= oldCharacter then
		self:handleCameraChange(newPage, state, instantChange)
		return
	end

	if currentFullView ~= oldFullView or topBarHeight ~= oldTopBarHeight then
		if currentFullView then
			self:playTweenFullView()
			return
		else
			self:handleCameraChange(newPage, state)
			return
		end
	elseif currentFullView and state.DeviceOrientation ~= oldState.DeviceOrientation then
		self:playTweenFullView()
		return
	end

	-- Tween the camera on tab change to focus on the relevant character part
	if newPage ~= oldPage or instantChange then
		self:handleCameraChange(newPage, state, instantChange)
		return
	end

	local focusGroups = Constants.AvatarTypeFocusGroups[avatarType]
	local focusParts = focusGroups[newPage.CameraFocus]

	if not focusParts and newCharacterModelVersion then
		self:handleCameraChange(newPage, state, false)
		return
	end
end

function CameraManager:playTweenFullView()
	local character = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter

	-- These vector positions were found to be appropriate full view locations.
	local cameraPosition = Vector3.new(9.00380135, (character:GetExtentsSize() / 2).Y + 10000, 0.2)
	local cameraLookAt = Vector3.new(-3.29430342, (character:GetExtentsSize() / 2).Y + 10000, 0.134697497)
	local newCFrame = CFrame.new(cameraPosition, cameraLookAt)

	if GetFFlagAvatarExperienceFlattenCameraPerspective() then
		playCameraTween(self, newCFrame)
	else
		local newFullViewTween = TweenService:Create(self.camera, self.tweenInfo, {
			CFrame = newCFrame
		})
		newFullViewTween:Play()
	end
end

function CameraManager:handleCameraChange(page, state, instant)
	local avatarType = getAvatarType(state)
	local character = state.AvatarExperience.AvatarScene.Character.CurrentCharacter
	local deviceOrientation = state.DeviceOrientation or CONSOLE
	local isLandingPage = page == AppPage.AvatarExperienceLandingPage

	local fullView = self:getFullView(state)
	if fullView then
		return
	end

	local focusGroups
	if FFlagAvatarEditorAttachmentCameraFocus then
		focusGroups = Constants.AvatarTypeFocusGroups[avatarType]
	else
		focusGroups = Constants.AvatarTypeFocusGroupsOld[avatarType]
	end
	local focusParts = focusGroups[page.CameraFocus]

	local parts
	if FFlagAvatarEditorAttachmentCameraFocus then
		parts = focusParts or { {Part = "HumanoidRootPart"} }
	else
		parts = focusParts or { "HumanoidRootPart" }
	end
	local focusPoint = self:getFocusPoint(parts)
	local position = ThemeInfo[deviceOrientation].cameraDefaultPosition

	if not focusParts then
		local extentsY = (character:GetExtentsSize() / ThemeInfo[deviceOrientation].extentScalar).Y
		if extentsY > 5 then
			extentsY = 5
		end
		focusPoint = Vector3.new(focusPoint.X, extentsY + 10000, focusPoint.Z)
	end

	position = Vector3.new(position.X, focusPoint.Y, position.Z)

	local zoomRadius = page.CameraZoomRadius or 0
	zoomRadius = ThemeInfo[deviceOrientation].zoomRadius(zoomRadius)

	-- Zoom out if the character is too tall to fit the current view.
	if not page.CameraZoomRadius then
		local scalarConstant = isLandingPage and ThemeInfo[deviceOrientation].landingPageScalarConstant
			or ThemeInfo[deviceOrientation].scalarConstant
		local scalar = (focusPoint.Y - 10000) / scalarConstant

		if deviceOrientation == DeviceOrientationMode.Portrait then
			zoomRadius = (zoomRadius + EXTRA_ZOOM_PORTRAIT) * scalar
		else
			zoomRadius = (zoomRadius + EXTRA_ZOOM_LANDSCAPE) * scalar
		end
	end

	local tryOnItem = state.AvatarExperience.AvatarScene.TryOn.SelectedItem

	local isAnimationBundleNew = FFlagLuaCatalogRedirectOwnedBundleToCorrectCategory
		and tryOnItem.itemSubType == AvatarExperienceConstants.BundleType.AvatarAnimations
	local isAnimationBundleOld = not FFlagLuaCatalogRedirectOwnedBundleToCorrectCategory
		and tryOnItem.itemSubType == CatalogConstants.BundleType.AvatarAnimations
	local isAnimationBundle = isAnimationBundleNew or isAnimationBundleOld

	if page.PageType == AvatarExperienceConstants.PageType.Animation
		or (FFlagAvatarEditorUpdateCamera() and page.PageType == AvatarExperienceConstants.PageType.Emotes)
		or isAnimationBundle
	then
		zoomRadius = zoomRadius + ANIMATION_ZOOM_DECREASE
	end

	if zoomRadius > 0 then
		local toCamera = (position - focusPoint)
		toCamera = Vector3.new(toCamera.x, 0, toCamera.z).unit
		position = focusPoint + zoomRadius * toCamera
	end

	self:tweenCameraIntoPlace(position, focusPoint, instant)
end

if FFlagAvatarEditorAttachmentCameraFocus then
	function CameraManager:getFocusPoint(focusPartInfo)
		local numParts = #focusPartInfo

		-- Focus on the torso if there is nothing specific to focus on.
		if numParts == 0 then
			return Constants.DefaultRigPosition
		end

		local sumOfPartPositions = Vector3.new()

		for _, partInfo in next, focusPartInfo do
			if partInfo.Attachment then
				local attachmentPosition = self:getAttachmentPosition(partInfo.Part, partInfo.Attachment)
				if attachmentPosition == nil then
					attachmentPosition = self:getPartPosition(partInfo.Part).p
				end
				sumOfPartPositions = sumOfPartPositions + attachmentPosition.p
			else
				sumOfPartPositions = sumOfPartPositions + self:getPartPosition(partInfo.Part).p
			end
		end

		return sumOfPartPositions / numParts
	end
else
	function CameraManager:getFocusPoint(partNames)
		local numParts = #partNames

		-- Focus on the torso if there is nothing specific to focus on.
		if numParts == 0 then
			return Constants.DefaultRigPosition
		end

		local sumOfPartPositions = Vector3.new()

		for _, partName in next, partNames do
			sumOfPartPositions = sumOfPartPositions + self:getPartPosition(partName).p
		end

		return sumOfPartPositions / numParts
	end

end

function CameraManager:getPartPosition(partName)
	local character = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter

	if character and character:FindFirstChild(partName) then
		return character[partName].cFrame
	else
		return CFrame.new(Constants.DefaultRigPosition)
	end
end

local function flattenProjection(camera, xScreenPositionOffset, orthoNormalizedProjection)
	local screenCenter = camera.ViewportSize/2
	local desiredCenter = screenCenter + Vector2.new(xScreenPositionOffset*(camera.ViewportSize.X/2), 0)
	local savedCFrame = camera.CFrame
	camera.CFrame = orthoNormalizedProjection
	local centerRay = camera:ViewportPointToRay(desiredCenter.x, desiredCenter.y)
	local pos = camera.CFrame.p
	local rightVector = camera.CFrame.rightVector
	local upVector = camera.CFrame.upVector
	camera.CFrame = savedCFrame
	local lookVectorOrtho = rightVector:Cross(upVector).unit
	local lookVectorSkewed = -centerRay.Direction.unit
	local cosineOfSkewAngle = lookVectorOrtho:Dot(lookVectorSkewed)
	return CFrame.fromMatrix(pos, rightVector, upVector, lookVectorSkewed*cosineOfSkewAngle)
end

function CameraManager:getAttachmentPosition(partName, attachmentName)
	local character = self.store:getState().AvatarExperience.AvatarScene.Character.CurrentCharacter

	if character and character:FindFirstChild(partName) then
		local part = character[partName]
		local attachment = part:FindFirstChild(attachmentName)
		if attachment then
			return part.CFrame * attachment.CFrame
		end
	end
end

function CameraManager:tweenCameraIntoPlace(position, focusPoint, instant)
	local deviceOrientation = self.store:getState().DeviceOrientation or CONSOLE
	local page = self:getPage(self.store:getState())
	local topBarHeight = self:getTopBarHeight()

	local isLandingPage = page == AppPage.AvatarExperienceLandingPage

	local cameraCenterScreenPosition = isLandingPage and ThemeInfo[deviceOrientation].landingPageCameraCenterScreenPosition
		or ThemeInfo[deviceOrientation].cameraCenterScreenPosition
	cameraCenterScreenPosition =
		ThemeInfo[deviceOrientation].adjustCameraCenterPosition(cameraCenterScreenPosition, topBarHeight)

	local screenSize = self.camera.ViewportSize
	local screenWidth = screenSize.X
	local screenHeight = screenSize.Y

	local fy = 0.5 * FOV * math.pi / 180.0 -- half vertical field of view (in radians)
	local fx = math.atan( math.tan(fy) * screenWidth / screenHeight ) -- half horizontal field of view (in radians)


	local xScreenPositionOffset = nil
	local anglesX = nil
	if GetFFlagAvatarExperienceFlattenCameraPerspective() then
		xScreenPositionOffset = cameraCenterScreenPosition.X.Scale + 2.0 * cameraCenterScreenPosition.X.Offset / screenWidth
		anglesX = math.atan( math.tan(fx) * xScreenPositionOffset)
	else
		anglesX = math.atan( math.tan(fx)
			* (cameraCenterScreenPosition.X.Scale + 2.0 * cameraCenterScreenPosition.X.Offset / screenWidth))
	end

	local anglesY = math.atan( math.tan(fy)
		* (cameraCenterScreenPosition.Y.Scale + 2.0 * cameraCenterScreenPosition.Y.Offset / screenHeight))

	local targetCFrame
		= CFrame.new(position)
		* CFrame.new(Vector3.new(), focusPoint - position)
		* CFrame.Angles(anglesY, anglesX, 0)
	
	if GetFFlagAvatarExperienceFlattenCameraPerspective() then
		targetCFrame = flattenProjection(self.camera, xScreenPositionOffset, targetCFrame)
	end
	
	if instant then
		self.camera.CFrame = targetCFrame
	else
		if GetFFlagAvatarExperienceFlattenCameraPerspective() then
			playCameraTween(self, targetCFrame)
		else
			local cameraGoals = {
				CFrame = targetCFrame;
			}
			TweenService:Create(self.camera, self.tweenInfo, cameraGoals):Play()
		end
	end
end

function CameraManager:onDestroy()
end

return CameraManager