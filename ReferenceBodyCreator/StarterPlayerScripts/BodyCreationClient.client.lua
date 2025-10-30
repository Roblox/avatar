-- CreationManager is the main module for the body creation demo.
-- It is responsible for setting up the model, layers, tools, and UI.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local ResolutionManager = require(Modules:WaitForChild("ResolutionManager"))

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local SwitchEditorsModalUI = require(UI:WaitForChild("SwitchEditorsModalUI"))
local Style = require(UI:WaitForChild("Style"))
local BaseUI = require(UI:WaitForChild("BaseUI"))
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

local Actions = require(Modules:WaitForChild("Actions"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local AccessoryUtils = require(MeshManipulation:WaitForChild("AccessoryUtils"))
local AttachmentUtils = require(MeshManipulation:WaitForChild("AttachmentUtils"))
local MeshInfo = require(MeshManipulation:WaitForChild("MeshInfo"))
local MeshEditActions = require(MeshManipulation:WaitForChild("MeshEditActions"))

-- Tools
local Tools = Client:WaitForChild("Tools")
local FabricTool = require(Tools:WaitForChild("FabricTool"))
local StickerTool = require(Tools:WaitForChild("StickerTool"))
local BrushTool = require(Tools:WaitForChild("BrushTool"))
local KitbashTool = require(Tools:WaitForChild("KitbashTool"))
local PreviewTool = require(Tools:WaitForChild("PreviewTool"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local BuyRemoteEvent = Remotes:WaitForChild("OnPlayerClickedBuy")
local PlayerClickedHumanoidEvent = Remotes:WaitForChild("OnPlayerClickedHumanoid")
local InitializeServerModelEvent = Remotes:WaitForChild("InitializeServerModelEvent")
local ResetPlayerModelServerEvent = Remotes:WaitForChild("ResetPlayerModelServer")
local ResetCompleteEvent = Remotes:WaitForChild("ResetCompleteEvent")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")

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

function CreationManager.new(modelInfo: ModelInfo.ModelInfoClass)
	local self = {}
	setmetatable(self, CreationManager)

	GetPlayerControls():Disable()

	self.cameraResetPos = workspace.CurrentCamera.CFrame.Position

	self.modelInfo = modelInfo

	-- Setup camera controls
	self.cameraManager = CameraManager.new(modelInfo)
	self.modelDisplay = ModelDisplay.new(modelInfo)
	self.inputManager = InputManager.new(self.cameraManager, self.modelDisplay)

	-- Hide loading screen now that model + textures are finished loading
	local loadingScreen = getLoadingScreen()
	loadingScreen.Visible = false

	self.brushTool = BrushTool.new(self.modelInfo, self.inputManager)

	self.fabricTool = FabricTool.new(self.modelInfo)

	self.stickerTool = StickerTool.new(self.modelInfo, self.inputManager)

	self.kitbashTool = KitbashTool.new(self.modelInfo, self.inputManager, self.modelDisplay)

	if modelInfo:GetCreationType() == Constants.CREATION_TYPES.Accessory then
		self.previewTool = PreviewTool.new(self.modelInfo, self.cameraManager, self.modelDisplay)
	end

	self.baseUI = BaseUI.new(
		self,
		modelInfo,
		self.fabricTool,
		self.stickerTool,
		self.brushTool,
		self.kitbashTool,
		self.previewTool
	)

	self.meshEditingWidgetManager =
		MeshEditingWidgetManager.new(self.modelInfo, self.modelDisplay, self.inputManager, self.cameraManager)

	-- Enable virtual cursor on console when entering edit mode
	if GuiService:IsTenFootInterface() then
		GamepadService:EnableGamepadCursor(nil)
	end

	local screenGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

	if not self.screenSizeChangedConn then
		self.screenSizeChangedConn = screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			self.isMobile = Utils.getIsMobile(screenGui)
		end)
	end
	self.isMobile = Utils.getIsMobile(screenGui)

	return self
end

local lastEditedModelInfo = nil

local function DestroyLastModel()
	if lastEditedModelInfo then
		ResetPlayerModelServerEvent:FireServer()
		ResetCompleteEvent.OnClientEvent:Wait() -- Wait for server confirmation
		lastEditedModelInfo:Destroy()
		lastEditedModelInfo = nil
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
	if DEBUG_PREVIEW_AVATAR_LOCALLY then
		PreviewAvatarLocally(self.modelInfo)
	end

	self.modelDisplay:Destroy()
	self.inputManager:Destroy()
	self.cameraManager:Destroy()

	self.brushTool:Destroy()
	self.fabricTool:Destroy()
	self.stickerTool:Destroy()
	if self.previewTool then
		self.previewTool:Destroy()
	end

	self.meshEditingWidgetManager:Destroy()
	self.kitbashTool:Destroy()

	self.baseUI:Destroy()
	if self.screenSizeChangedConn then
		self.screenSizeChangedConn:Disconnect()
		self.screenSizeChangedConn = nil
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

	if GuiService:IsTenFootInterface() then
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

function CreationManager:ResetCamera()
	self.cameraManager:ResetCamera(true --[[useTween]])
end

function CreationManager:PanToLeft()
	self.cameraManager:PanToLeft(self.isMobile)
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
	self.meshEditingWidgetManager:HideWidgets()

	local updateDeformedEditableMeshesActionMetadata: MeshEditActions.UpdateDeformedEditableMeshesMetadata = {}

	local updateDeformedEditableMeshesAction = Actions.CreateNewAction(
		Actions.ActionTypes.UpdateDeformedEditableMeshes,
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

	local model = SetupClientModel(blankData)

	local currentResolutionIndex = ResolutionManager.GetCurrentIndex()
	InitializeServerModelEvent:FireServer(blankData.name, currentResolutionIndex)

	return ModelInfo.new(model, blankData)
end

local function OpenSwitchEditorsModal(blankData)
	local style = Style.new()

	local onBuyCallback = function()
		BuyRemoteEvent:FireServer()
		style:Destroy()
	end

	local onContinueCallback = function()
		lastEditedModelInfo = InitModelFromBlankData(blankData)
		UpdateCameraForEditMode(lastEditedModelInfo)
		CreationManager.new(lastEditedModelInfo)
		style:Destroy()
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
	CreationManager.new(lastEditedModelInfo)
end

local debounceEnterModel = false

local function EnterCreationModeInitial(modelName)
	if debounceEnterModel then
		return
	end
	debounceEnterModel = true

	local loadingScreen = getLoadingScreen()

	-- Reset resolution at the start of each creation attempt
	ResolutionManager.ResetResolution()

	local maxAttempts = #Constants.TEXTURE_RESOLUTION_STEPS
	local attempts = 0
	local success = false

	while attempts < maxAttempts and not success do
		attempts = attempts + 1

		local result, err = pcall(function()
			EnterCreationMode(modelName)
		end)

		if result then
			success = true
		else
			warn(err)
			-- Check if error was due to memory constraints
			if string.find(err, Constants.FAILED_TO_CREATE_EI_MSG) then
				if attempts < maxAttempts then
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
			else
				-- If error was not related to memory, don't retry
				Message.CreateMessageGui("Unexpected error.")
				break
			end
		end
	end

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
