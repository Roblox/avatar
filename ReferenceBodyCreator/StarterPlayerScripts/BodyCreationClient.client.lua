-- CreationManager is the main module for the body creation demo.
-- It is responsible for setting up the model, layers, tools, and UI.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local ResolutionManager = require(Modules:WaitForChild("ResolutionManager"))
local EditableManager = require(Modules:WaitForChild("EditableManager"))

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")

local Style = UI:WaitForChild("Style")
local StyleSheet = require(Style:WaitForChild("StyleSheet"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Handlers = UI:WaitForChild("Handlers")
local SwitchEditorsModalUI = require(Handlers:WaitForChild("SwitchEditorsModalUI"))
local BaseUI = require(Handlers:WaitForChild("BaseUI"))
local Message = require(UI:WaitForChild("Message"))
local MeshEditingWidgetManager = require(Client:WaitForChild("MeshEditingWidgetManager"))

local ModelDisplay = require(Client:WaitForChild("ModelDisplay"))
local InputManager = require(Client:WaitForChild("InputManager"))
local CameraManager = require(Client:WaitForChild("CameraManager"))

local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

local Utils = require(Modules:WaitForChild("Utils"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local BlanksData = require(Config:WaitForChild("BlanksData"))
local MakeupHeads = require(Config:WaitForChild("MakeupHeads"))

local Actions = require(Modules:WaitForChild("Actions"))
local ActionUtils = require(Modules:WaitForChild("ActionUtils"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local AccessoryUtils = require(MeshManipulation:WaitForChild("AccessoryUtils"))
local AttachmentUtils = require(MeshManipulation:WaitForChild("AttachmentUtils"))
local MakeupProjectionUtils = require(MeshManipulation:WaitForChild("MakeupProjectionUtils"))
local MeshInfo = require(MeshManipulation:WaitForChild("MeshInfo"))
local MeshEditActions = require(MeshManipulation:WaitForChild("MeshEditActions"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local GroupInfo = require(TextureManipulation:WaitForChild("GroupInfo"))

-- Tools
local Tools = Client:WaitForChild("Tools")
local FabricTool = require(Tools:WaitForChild("FabricTool"))
local StickerTool = require(Tools:WaitForChild("StickerTool"))
local StampTool = require(Tools:WaitForChild("StampTool"))
local BrushTool = require(Tools:WaitForChild("BrushTool"))
local KitbashTool = require(Tools:WaitForChild("KitbashTool"))
local PreviewTool = require(Tools:WaitForChild("PreviewTool"))
local PreviewAccessoryTool = require(Tools:WaitForChild("PreviewAccessoryTool"))
local LayerTool = require(Tools:WaitForChild("LayerTool"))
local HistoryTool = require(Tools:WaitForChild("HistoryTool"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local BuyRemoteEvent = Remotes:WaitForChild("OnPlayerClickedBuy")
local PlayerClickedHumanoidEvent = Remotes:WaitForChild("OnPlayerClickedHumanoid")
local InitializeServerModelEvent = Remotes:WaitForChild("InitializeServerModelEvent")
local ResetPlayerModelServerEvent = Remotes:WaitForChild("ResetPlayerModelServer")
local ResetCompleteEvent = Remotes:WaitForChild("ResetCompleteEvent")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")
local GetCreationPriceFunction = Remotes:WaitForChild("GetCreationPriceFunction")

local LocalPlayer = Players.LocalPlayer

-- Set to true to have the avatar previewed locally in the game world after exiting edit mode
-- This is useful for debugging things like animations with the scaled avatar
local DEBUG_PREVIEW_AVATAR_LOCALLY = false

local CreationManager = {}
CreationManager.__index = CreationManager

local function GetAverageMeshPartPosition(model: Model): Vector3
	local averageMeshPartPosition = Vector3.zero
	local numMeshParts = 0
	for _, child in pairs(model:GetDescendants()) do
		if child:IsA("MeshPart") then
			averageMeshPartPosition = averageMeshPartPosition + child.Position
			numMeshParts = numMeshParts + 1
		end
	end

	averageMeshPartPosition = averageMeshPartPosition / numMeshParts
	return averageMeshPartPosition
end

local function UpdateCameraForEditMode(modelInfo: ModelInfo.ModelInfoClass)
	modelInfo:InitializeMeshPartPositions()
	local averageMeshPartPosition = GetAverageMeshPartPosition(modelInfo:GetModel())

	local camera = workspace.CurrentCamera

	local cameraPosition = averageMeshPartPosition + (Vector3.new(0, 0, 1) * 10)
	local targetPosition = averageMeshPartPosition

	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = 35
	camera.CFrame = CFrame.lookAt(cameraPosition, targetPosition)
end

local function getLoadingScreen()
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	return PlayerGui:WaitForChild("ScreenGui"):WaitForChild("LoadingScreen")
end

local function SetupClientModel(blankData: BlanksData.BlankData): Model
	-- Create loading screen while model is loading
	local loadingScreen = getLoadingScreen()
	loadingScreen.Visible = true

	local newModel: Model = blankData.sourceModel:Clone()
	if blankData.creationType == Constants.CREATION_TYPES.Makeup then
		MakeupProjectionUtils.SetupHead(newModel)
	end
	newModel.Parent = workspace

	if blankData.creationType == Constants.CREATION_TYPES.Body then
		AttachmentUtils.BuildRigFromAttachments(newModel)
		AccessoryUtils.ReapplyLayeredClothing(newModel)
	end

	return newModel
end

local function GetPlayerControls()
	local playerModule = require(LocalPlayer.PlayerScripts.PlayerModule) :: any
	return playerModule:GetControls()
end

function CreationManager.new(modelInfo: ModelInfo.ModelInfoClass, editableManager)
	local self = {}
	setmetatable(self, CreationManager)

	GetPlayerControls():Disable()

	self.cameraResetPos = workspace.CurrentCamera.CFrame.Position

	self.modelInfo = modelInfo
	self.editableManager = editableManager
	self.historyTool = HistoryTool.new(modelInfo)

	-- Setup camera controls
	self.modelDisplay = ModelDisplay.new(modelInfo)
	self.cameraManager = CameraManager.new(modelInfo)
	self.inputManager = InputManager.new(self.cameraManager, self.modelDisplay)

	-- Hide loading screen now that model + textures are finished loading
	local loadingScreen = getLoadingScreen()
	loadingScreen.Visible = false

	self.brushTool = BrushTool.new(self.modelInfo, self.inputManager, self.historyTool)

	if modelInfo:GetCreationType() ~= Constants.CREATION_TYPES.Makeup then
		self.fabricTool = FabricTool.new(self.modelInfo)
		self.stickerTool = StickerTool.new(self.modelInfo, self.inputManager)
	end

	self.kitbashTool = KitbashTool.new(self.modelInfo, self.inputManager, self.modelDisplay, self.historyTool)

	if modelInfo:GetCreationType() == Constants.CREATION_TYPES.Accessory then
		self.previewTool = PreviewTool.new(self.modelInfo, self.cameraManager, self.modelDisplay)
	end

	if modelInfo:GetCreationType() == Constants.CREATION_TYPES.Makeup then
		self.stampTool = StampTool.new(self.modelInfo, self.inputManager, self.historyTool, function()
			self.baseUI.StampBakeModalUI:Open()
		end)
		self.layerTool = LayerTool.new(self.modelInfo, self.modelInfo:GetMeshParts()[1].Name, self.historyTool)
		self.historyTool:setSelectLayerCallback(function(layerInfo: GroupInfo.TargetLayerInfo)
			self.baseUI:SelectLayer(layerInfo)
		end)
	end

	if modelInfo:GetCreationType() == Constants.CREATION_TYPES.Makeup then
		self.accessoryTextureTools = {}
		self.previewAccessoryTool = PreviewAccessoryTool.new(self.modelInfo, self.editableManager, function(category)
			self:DestroyAccessoryTextureTools(category)
		end)
		if self.previewAccessoryTool then
			self.previewAccessoryTool.beforeContextSwitch = function()
				local tools = self.activeAccessoryTextureTools or self
				tools.brushTool:Disable()
				tools.stampTool:Disable()
				tools.kitbashTool:Disable()
			end
		end
	end

	self.baseUI = BaseUI.new(
		self,
		self.fabricTool,
		self.stickerTool,
		self.stampTool,
		self.brushTool,
		self.kitbashTool,
		self.previewTool,
		self.layerTool
	)

	self.meshEditingWidgetManager =
		MeshEditingWidgetManager.new(self.modelInfo, self.modelDisplay, self.inputManager, self.cameraManager)

	-- Enable virtual cursor on console when entering edit mode
	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		GamepadService:EnableGamepadCursor(nil)
	end

	self.inputTypeChangedConn = UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			GamepadService:EnableGamepadCursor(nil)
		else
			GamepadService:DisableGamepadCursor(nil)
		end
	end)

	local screenGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

	if not self.screenSizeChangedConn then
		self.screenSizeChangedConn = screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			self.isMobile = StyleUtils.GetIsMobile(screenGui)
		end)
	end
	self.isMobile = StyleUtils.GetIsMobile(screenGui)

	if modelInfo:GetCreationType() == Constants.CREATION_TYPES.Makeup then
		-- Apply the player's head once per model, preserving their choice when reopening the editor.
		if not modelInfo.makeupHeadInitialized then
			modelInfo.makeupHeadInitialized = true
			if MakeupHeads.GetSourceHead(MakeupHeads.PlayerId, nil, LocalPlayer.Character) then
				self.baseUI.EditingUI.makeupPreviewToolUI:SwapHead(MakeupHeads.PlayerId, true --[[isConfirmed]])
				if self.baseUI.EditingUI.makeupPreviewToolUI.destroyed then
					return self
				end
			end
		end
		self.baseUI.EditingUI:OpenLayerPanel()
	end

	return self
end

local lastEditedModelInfo = nil
local lastEditableManager = nil

local function DownresCreationWrapper(creationFunction)
	-- Reset resolution at the start of each creation attempt
	ResolutionManager.ResetResolution()

	local maxAttempts = #Constants.TEXTURE_RESOLUTION_STEPS
	local attempts = 0
	local success = false

	while attempts < maxAttempts and not success do
		attempts = attempts + 1

		local result, err = pcall(function()
			creationFunction()
		end)

		if result then
			success = true
		else
			warn(err)
			-- Check if error was due to memory constraints
			if string.find(err, Constants.FAILED_TO_CREATE_EI_MSG) then
				if attempts < maxAttempts then
					warn(
						"Attempting to step down resolution and retry setup. Attempt "
							.. attempts
							.. " of "
							.. maxAttempts
					)
					-- Step down resolution for the subsequent setup attempt
					ResolutionManager.StepDownResolution()

					-- Reset model on the server to free up action queue and memory
					ResetPlayerModelServerEvent:FireServer()
					-- Wait for the reset to complete so we do not attempt to spin up creation before resetting completes
					ResetCompleteEvent.OnClientEvent:Wait()
				else
					-- If all attempts failed, show error message
					Message.CreateMessageGui("Setup failed, out of Memory.")
				end
			-- Check if error was due to incorrect game settings
			elseif string.find(err, Constants.FIX_MESH_IMAGE_SETTINGS_MSG) then
				Message.CreateMessageGui(
					"EditableImage and EditableMesh are not accessible. Go to the Security Tab in Game Settings to enable this API."
				)
			else
				-- If error was not related to memory, don't retry
				Message.CreateMessageGui("Unexpected error.")
				break
			end
		end
	end
end

local function DestroyLastModel()
	if lastEditedModelInfo then
		ResetPlayerModelServerEvent:FireServer()
		ResetCompleteEvent.OnClientEvent:Wait() -- Wait for server confirmation
		lastEditedModelInfo:Destroy()
		lastEditedModelInfo = nil
	end
	if lastEditableManager then
		lastEditableManager:Destroy()
		lastEditableManager = nil
	end
end

local function FixUpMultipleFolders(humanoidDescription: HumanoidDescription)
	for _, child in humanoidDescription:GetChildren() do
		if not child:isA("BodyPartDescription") then
			continue
		end

		local bodyPartDescription: BodyPartDescription = child
		if bodyPartDescription.BodyPart == Enum.BodyPart.Head then
			continue
		end

		local bodyPart = bodyPartDescription.Instance

		local newFolder = Instance.new("Folder")
		newFolder.Name = bodyPart.Name

		local r15ArtistIntent = Instance.new("Folder")
		r15ArtistIntent.Name = "R15ArtistIntent"

		for _, child in pairs(bodyPart:GetChildren()) do
			child.Parent = r15ArtistIntent
		end

		r15ArtistIntent.Parent = newFolder

		local r6 = Instance.new("Folder")
		r6.Name = "R6"
		r6.Parent = newFolder

		newFolder.Parent = bodyPart.Parent

		bodyPartDescription.Instance = newFolder
	end
end

local function UnAnchorModel(model: Model)
	for _, child in pairs(model:GetDescendants()) do
		if child:IsA("BasePart") then
			child.Anchored = false

			if child.Parent:IsA("Accessory") then
				child.Name = "Handle"
			end
		end
	end
end

local function PreviewAvatarLocally(modelInfo: ModelInfo.ModelInfoClass)
	local model = modelInfo:GetModel():Clone()
	local humanoidDescription = model:FindFirstChildWhichIsA("HumanoidDescription")

	FixUpMultipleFolders(humanoidDescription)

	local humanoidModel = Players:CreateHumanoidModelFromDescription(humanoidDescription, Enum.HumanoidRigType.R15)
	humanoidModel.Name = "TestCharacter"

	UnAnchorModel(humanoidModel)

	local currentCharacter = LocalPlayer.Character
	humanoidModel:SetPrimaryPartCFrame(currentCharacter:GetPrimaryPartCFrame())
	currentCharacter.Parent = nil

	humanoidModel.Parent = workspace

	LocalPlayer.Character = humanoidModel

	local animate = humanoidModel:FindFirstChild("Animate")
	animate.Enabled = false
	task.wait()
	animate.Enabled = true
end

function CreationManager:Quit()
	self:FinishAccessoryTextureEditing()
	if self.previewAccessoryTool then
		local contextReady = self.previewAccessoryTool:SetEditingCategory(nil)
		if not contextReady then
			-- Reset and purchase callers still proceed, so a failed restore must not leave the editor alive.
			warn("Could not restore makeup editing images while quitting; continuing editor cleanup.")
		end
	end

	if DEBUG_PREVIEW_AVATAR_LOCALLY then
		PreviewAvatarLocally(self.modelInfo)
	end

	self.modelDisplay:Destroy()
	self.inputManager:Destroy()
	self.cameraManager:Destroy()

	self.brushTool:Destroy()
	if self.fabricTool then
		self.fabricTool:Destroy()
	end
	if self.stickerTool then
		self.stickerTool:Destroy()
	end
	if self.stampTool then
		self.stampTool:Destroy()
	end
	if self.previewTool then
		self.previewTool:Destroy()
	end
	if self.previewAccessoryTool then
		self.previewAccessoryTool:Destroy()
	end

	self.meshEditingWidgetManager:Destroy()
	self.kitbashTool:Destroy()

	self.baseUI:Destroy()
	if self.screenSizeChangedConn then
		self.screenSizeChangedConn:Disconnect()
		self.screenSizeChangedConn = nil
	end
	if self.inputTypeChangedConn then
		self.inputTypeChangedConn:Disconnect()
		self.inputTypeChangedConn = nil
	end

	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	local characterRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		workspace.CurrentCamera.CameraSubject = humanoid
		workspace.CurrentCamera.FieldOfView = 70
		workspace.CurrentCamera.CFrame = CFrame.lookAt(self.cameraResetPos, characterRoot.CFrame.Position)
	end

	GetPlayerControls():Enable()

	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		-- Disable virtual cursor on console when leaving edit mode
		GamepadService:DisableGamepadCursor(nil)
	end
end

function CreationManager:SetEditMode(editMode)
	self.editMode = editMode
end

function CreationManager:GetEditMode()
	return self.editMode
end

function CreationManager:ExitEditMode()
	self:SetEditMode(Constants.EDIT_MODE_NONE)
	self.modelDisplay:OnExitedEditMode()
end

function CreationManager:Undo()
	if self.modelInfo:GetMakeupHeadSwapInProgress() then
		return
	end
	local layerTool = self.baseUI.EditingUI.layerTool
	local historyTool = if layerTool then layerTool.historyTool else self.historyTool
	if historyTool:getUndoCount() > 0 then
		historyTool:undo()
		local undoAction = ActionUtils.CreateNewAction(ActionUtils.ActionTypes.Undo, {}, historyTool.currentModelInfo)
		SendActionToServerEvent:FireServer(undoAction)
	end
end

function CreationManager:Redo()
	if self.modelInfo:GetMakeupHeadSwapInProgress() then
		return
	end
	local layerTool = self.baseUI.EditingUI.layerTool
	local historyTool = if layerTool then layerTool.historyTool else self.historyTool
	if historyTool:getRedoCount() > 0 then
		historyTool:redo()
		local redoAction = ActionUtils.CreateNewAction(ActionUtils.ActionTypes.Redo, {}, historyTool.currentModelInfo)
		SendActionToServerEvent:FireServer(redoAction)
	end
end

function CreationManager:ResetCamera()
	self.modelDisplay:SetCameraFacingYaw(0)
	self.cameraManager:ResetCamera(true --[[useTween]])
end

function CreationManager:FocusCameraOnMakeupAssetType(makeupAssetType: string?, useTween: boolean, panForPanel: boolean)
	self.modelDisplay:ResetCameraRotation()
	local cameraFacingYaw = self.cameraManager:FocusOnMakeupAssetType(makeupAssetType, useTween, panForPanel)
	self.modelDisplay:SetCameraFacingYaw(cameraFacingYaw)
end

local function getPartsCenter(parts: { BasePart }): Vector3
	local center = Vector3.zero
	for _, part in parts do
		center += part.Position
	end
	return center / #parts
end

-- Resolves the owning model's layer tool, even outside isolation.
-- Restores its editing context and may yield. Non-selection callers must restore the UI's active context afterward.
function CreationManager:GetLayerToolForGroup(groupId: string?)
	if not self.previewAccessoryTool then
		return self.layerTool
	end

	for category, selection in self.previewAccessoryTool.selections do
		if selection.group.name == groupId then
			local contextReady = self.previewAccessoryTool:SetEditingCategory(category)
			assert(contextReady, "Could not restore accessory editing images")
			local tools = self.accessoryTextureTools[category]
			if not tools then
				local modelInfo = selection.editModelInfo
				local historyTool = HistoryTool.new(modelInfo)
				historyTool:setSelectLayerCallback(function(layerInfo)
					self.baseUI:SelectLayer(layerInfo)
				end)
				tools = {
					historyTool = historyTool,
					layerTool = LayerTool.new(modelInfo, modelInfo:GetMeshParts()[1].Name, historyTool),
				}
				self.accessoryTextureTools[category] = tools
			end
			return tools.layerTool
		end
	end
	local contextReady = self.previewAccessoryTool:SetEditingCategory(nil)
	assert(contextReady, "Could not restore makeup decal editing images")
	return self.layerTool
end

-- Disposes of cached tools and history for a removed accessory.
function CreationManager:DestroyAccessoryTextureTools(category: string)
	local tools = self.accessoryTextureTools[category]
	if tools then
		if self.baseUI and self.baseUI.EditingUI.layerTool == tools.layerTool then
			self.baseUI.EditingUI.layerTool = self.layerTool
			self.baseUI.TopBarUI:SetHistoryTool(self.layerTool.historyTool)
		end
		if tools == self.activeAccessoryTextureTools then
			self:FinishAccessoryTextureEditing()
		end
		if tools.brushTool then
			tools.brushTool:Destroy()
			tools.stampTool:Destroy()
			tools.kitbashTool:Destroy()
		end
		tools.historyTool:clear()
		self.accessoryTextureTools[category] = nil
	end
end

-- Activates the accessory's editing tools and frames its isolated model.
function CreationManager:ShowAccessoryInIsolation(category: string): boolean
	local selection = self.previewAccessoryTool and self.previewAccessoryTool.selections[category]
	if not selection then
		return false
	end
	local layerTool = self:GetLayerToolForGroup(selection.group.name)
	local target = layerTool:GetTargetLayerInfo()
	if target.groupId ~= selection.group.name then
		return false
	end
	self:FocusCameraOnMakeupAssetType(category, true, true)
	local parts = self.previewAccessoryTool:ShowIsolated(category)
	if not parts or #parts == 0 then
		self.previewAccessoryTool:ShowOnHead()
		return false
	end

	local tools = self.accessoryTextureTools[category]
	local modelInfo = selection.editModelInfo
	modelInfo:GetMeshInfo():UpdateDeformedEditableMeshes()
	if not tools.brushTool then
		tools.brushTool = BrushTool.new(modelInfo, self.inputManager, tools.historyTool)
		tools.stampTool = StampTool.new(modelInfo, self.inputManager, tools.historyTool, function()
			self.baseUI.StampBakeModalUI:Open()
		end)
		tools.stampTool:ConnectHandlesToStyle(self.baseUI.style)
		tools.kitbashTool = KitbashTool.new(modelInfo, self.inputManager, self.modelDisplay, tools.historyTool)
		tools.kitbashTool:ConnectHandlesToStyle(self.baseUI.style)
	end
	-- The isolated accessory's tools; nil while the head's tools are active.
	self.activeAccessoryTextureTools = tools
	self.modelDisplay:SetTemporaryModel(modelInfo)
	self.baseUI.EditingUI:SetTextureTools(tools.brushTool, tools.stampTool)
	self.baseUI.EditingUI:SetKitbashTool(tools.kitbashTool)
	local cameraFacingYaw = self.cameraManager:FocusCameraOnParts(parts, getPartsCenter(parts), true)
	self.modelDisplay:SetCameraFacingYaw(cameraFacingYaw)
	return true
end

-- Restores head editing while retaining accessory tools and edits.
function CreationManager:FinishAccessoryTextureEditing()
	local tools = self.activeAccessoryTextureTools
	if tools then
		tools.brushTool:Disable()
		tools.stampTool:Disable()
		tools.kitbashTool:Disable()
		self.activeAccessoryTextureTools = nil
		self.modelDisplay:RestoreTemporaryModel()
		self.baseUI.EditingUI:SetTextureTools(self.brushTool, self.stampTool)
		self.baseUI.EditingUI:SetKitbashTool(self.kitbashTool)
	end
	if self.previewAccessoryTool then
		self.previewAccessoryTool:ShowOnHead()
	end
	if tools then
		self:ResetCamera()
	end
end

function CreationManager:PanToLeft()
	if self.previewAccessoryTool then
		local isolatedParts = self.previewAccessoryTool:GetIsolatedParts()
		if isolatedParts and #isolatedParts > 0 then
			local cameraFacingYaw =
				self.cameraManager:FocusCameraOnParts(isolatedParts, getPartsCenter(isolatedParts), true)
			self.modelDisplay:SetCameraFacingYaw(cameraFacingYaw)
			return
		end
	end
	local cameraFacingYaw = self.cameraManager:PanToLeft(self.isMobile)
	self.modelDisplay:SetCameraFacingYaw(cameraFacingYaw)
end

-- Returns the names of the widget control groups, sorted alphabetically
function CreationManager:GetWidgetGroupNames()
	local names = {}
	local widgetInfo = self.modelInfo.meshInfo.widgetInfo

	for name, _info in widgetInfo do
		table.insert(names, name)
	end

	table.sort(names)

	return names
end

function CreationManager:ShowMeshEditControls(controlGroupName)
	self.modelDisplay:ResetModel()
	self.meshEditingWidgetManager:SetupWidgets(controlGroupName)
end

function CreationManager:HideMeshEditControls()
	if not self.meshEditingWidgetManager:IsShowingWidgets() then
		return
	end
	self.meshEditingWidgetManager:HideWidgets()

	local updateDeformedEditableMeshesActionMetadata: MeshEditActions.UpdateDeformedEditableMeshesMetadata = {}

	local updateDeformedEditableMeshesAction = ActionUtils.CreateNewAction(
		ActionUtils.ActionTypes.UpdateDeformedEditableMeshes,
		updateDeformedEditableMeshesActionMetadata
	)

	Actions.ExecuteAction(self.modelInfo, updateDeformedEditableMeshesAction)

	SendActionToServerEvent:FireServer(updateDeformedEditableMeshesAction)
end

function CreationManager:IsShowingMeshEditControls()
	return self.meshEditingWidgetManager:IsShowingWidgets()
end

function CreationManager:GetInputManager()
	return self.inputManager
end

function CreationManager:GetCreationType()
	return self.modelInfo:GetCreationType()
end

local function InitModelFromBlankData(blankData: BlanksData.BlankData)
	-- Editing a different model, so destroy any existing modelInfo
	DestroyLastModel()
	lastEditableManager = EditableManager.new()

	local currentResolutionIndex = ResolutionManager.GetCurrentIndex()
	blankData = table.clone(blankData)
	blankData.textureResolution = Constants.TEXTURE_RESOLUTION_STEPS[currentResolutionIndex]
	local model = SetupClientModel(blankData)

	InitializeServerModelEvent:FireServer(blankData.name, currentResolutionIndex)

	local creationPrice = 0
	local makeupItemPrices = {}
	if blankData.creationType == Constants.CREATION_TYPES.Makeup then
		local makeupAssetTypes = {}
		local makeupTokens = {}
		for _, makeupAssetType in Constants.MAKEUP_ASSET_TYPES do
			local avatarAssetType = Constants.MAKEUP_ASSET_TYPE_TO_AVATAR_ASSET_TYPE[makeupAssetType]
			local token = Utils.getMakeupToken(game.GameId, avatarAssetType)
			if token then
				table.insert(makeupAssetTypes, makeupAssetType)
				table.insert(makeupTokens, token)
			end
		end

		-- Fetch every makeup item's price with one token-details request on the server.
		local prices = GetCreationPriceFunction:InvokeServer(makeupTokens)
		for index, makeupAssetType in makeupAssetTypes do
			makeupItemPrices[makeupAssetType] = prices[index] or 0
		end
	else
		-- Fetch price from token on the server to display on the client.
		local token = Utils.getToken(game.GameId, blankData.avatarAssetType)
		creationPrice = GetCreationPriceFunction:InvokeServer(token)
	end

	local success, result = pcall(function()
		return ModelInfo.new(lastEditableManager, model, blankData, creationPrice, makeupItemPrices)
	end)
	if not success then
		lastEditableManager:Destroy()
		lastEditableManager = nil
		error(result, 0)
	end

	return result
end

local function OpenSwitchEditorsModal(blankData)
	local style = StyleSheet.new()

	local onBuyCallback = function()
		BuyRemoteEvent:FireServer()
		style:Destroy()
	end

	local onContinueCallback = function()
		DownresCreationWrapper(function()
			lastEditedModelInfo = InitModelFromBlankData(blankData)
			UpdateCameraForEditMode(lastEditedModelInfo)
			CreationManager.new(lastEditedModelInfo, lastEditableManager)
			style:Destroy()
		end)
	end

	local onCancelCallback = function()
		style:Destroy()
	end

	local creationPrice = lastEditedModelInfo:GetCreationPrice()

	SwitchEditorsModalUI.new(style, creationPrice, onBuyCallback, onContinueCallback, onCancelCallback)
end

-- Creates a new CreationManager instance for the given model name
-- and sets up the camera view for edit mode.
--
-- If the model name matches the previously edited model, the existing
-- modelInfo is reused (maintaining all previous edits).
-- Otherwise, a new modelInfo is created from the blank data.
local function EnterCreationMode(modelName)
	-- Reset resolution at the start of each creation attempt
	DownresCreationWrapper(function()
		local blankData = Utils.GetBlankDataByName(modelName)
		if not blankData then
			warn("No blank data found for model name: " .. modelName)
			return
		end

		if not lastEditedModelInfo then
			lastEditedModelInfo = InitModelFromBlankData(blankData)
		elseif lastEditedModelInfo:GetBlankName() ~= modelName then
			OpenSwitchEditorsModal(blankData)
			return
		end

		UpdateCameraForEditMode(lastEditedModelInfo)

		CreationManager.new(lastEditedModelInfo, lastEditableManager)
	end)
end

local debounceEnterModel = false

local function EnterCreationModeInitial(modelName)
	if debounceEnterModel then
		return
	end
	debounceEnterModel = true

	local loadingScreen = getLoadingScreen()

	EnterCreationMode(modelName)

	loadingScreen.Visible = false

	task.wait(3)
	debounceEnterModel = false
end

PlayerClickedHumanoidEvent.OnClientEvent:Connect(EnterCreationModeInitial)

function CreationManager:ResetModelInfo()
	local loadingScreen = getLoadingScreen()
	loadingScreen.Visible = true

	self:Quit()
	if not lastEditedModelInfo then
		warn("No model info to reset")
		return
	end
	local modelName = lastEditedModelInfo:GetBlankName()
	DestroyLastModel()
	EnterCreationMode(modelName)
end

-- Bake the in-progress stamp; invoked by the stamp bake modal's "Merge Stamp" button.
function CreationManager:BakeStamp()
	local stampTool = self.baseUI.EditingUI.stampTool
	if stampTool then
		stampTool:CommitStamp()
	end
end

-- Drop any pending bake request; invoked by the stamp bake modal's "Cancel Stamp" button.
function CreationManager:CancelStampBake()
	local stampTool = self.baseUI.EditingUI.stampTool
	if stampTool then
		stampTool:CancelPendingBake()
	end
end
