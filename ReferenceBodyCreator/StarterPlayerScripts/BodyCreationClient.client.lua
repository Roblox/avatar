-- CreationManager is the main module for the body creation demo.
-- It is responsible for setting up the model, layers, tools, and UI.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local BaseUI = require(UI:WaitForChild("BaseUI"))
local MeshEditingWidgetManager = require(Client:WaitForChild("MeshEditingWidgetManager"))

local ModelDisplay = require(Client:WaitForChild("ModelDisplay"))
local InputManager = require(Client:WaitForChild("InputManager"))
local CameraManager = require(Client:WaitForChild("CameraManager"))

local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

local Utils = require(Modules:WaitForChild("Utils"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local BlanksData = require(Config:WaitForChild("BlanksData"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshInfo = require(MeshManipulation:WaitForChild("MeshInfo"))

-- Tools
local Tools = Client:WaitForChild("Tools")
local FabricTool = require(Tools:WaitForChild("FabricTool"))
local StickerTool = require(Tools:WaitForChild("StickerTool"))
local BrushTool = require(Tools:WaitForChild("BrushTool"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local PlayerClickedHumanoidEvent = Remotes:WaitForChild("OnPlayerClickedHumanoid")
local InitializeServerModelEvent = Remotes:WaitForChild("InitializeServerModelEvent")
local ResetPlayerModelServerEvent = Remotes:WaitForChild("ResetPlayerModelServer")

local LocalPlayer = Players.LocalPlayer

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

local function SetupClientModel(blankData: BlanksData.BlankData): Model
	-- Create loading screen while model is loading
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local loadingScreen = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("LoadingScreen")
	loadingScreen.Visible = true

	local newModel: Model = blankData.sourceModel:Clone()
	newModel.Parent = workspace

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
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local loadingScreen = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("LoadingScreen")
	loadingScreen.Visible = false

	self.brushTool = BrushTool.new(self.modelInfo, self.inputManager)

	self.fabricTool = FabricTool.new(self.modelInfo)

	self.stickerTool = StickerTool.new(self.modelInfo, self.inputManager)

	self.baseUI = BaseUI.new(self, self.fabricTool, self.stickerTool, self.brushTool)

	self.meshEditingWidgetManager =
		MeshEditingWidgetManager.new(self.modelInfo, self.modelDisplay, self.inputManager, self.cameraManager)

	return self
end

local lastEditedModelInfo = nil

local function DestroyLastModel()
	if lastEditedModelInfo then
		ResetPlayerModelServerEvent:FireServer()
		lastEditedModelInfo:Destroy()
		lastEditedModelInfo = nil
	end
end

function CreationManager:Quit()
	self.modelDisplay:Destroy()
	self.inputManager:Destroy()
	self.cameraManager:Destroy()

	self.brushTool:Destroy()
	self.fabricTool:Destroy()
	self.stickerTool:Destroy()

	self.meshEditingWidgetManager:Destroy()

	self.baseUI:Destroy()

	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	local characterRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		workspace.CurrentCamera.CameraSubject = humanoid
		workspace.CurrentCamera.FieldOfView = 70
		workspace.CurrentCamera.CFrame = CFrame.lookAt(self.cameraResetPos, characterRoot.CFrame.Position)
	end

	GetPlayerControls():Enable()
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

function CreationManager:PanToRight()
	self.cameraManager:PanToRight()
end

function CreationManager:ShowMeshEditControls(controlGroupName)
	self.modelDisplay:ResetModel()
	self.meshEditingWidgetManager:SetupWidgets(controlGroupName)
end

function CreationManager:HideMeshEditControls()
	self.meshEditingWidgetManager:HideWidgets()

	-- Deform any dirty mesh parts
	local meshInfo: MeshInfo.MeshInfoClass = self.modelInfo:GetMeshInfo()
	meshInfo:UpdateDeformedEditableMeshes()
end

function CreationManager:IsShowingMeshEditControls()
	return self.meshEditingWidgetManager:IsShowingWidgets()
end

function CreationManager:GetInputManager()
	return self.inputManager
end

local function InitModelFromBlankData(blankData: BlanksData.BlankData)
	-- Editing a different model, so destroy any existing modelInfo
	DestroyLastModel()

	local model = SetupClientModel(blankData)
	local modelConfig: ModelInfo.ModelConfig = {
		resizeAccessoriesForDisplay = true,
	}

	InitializeServerModelEvent:FireServer(blankData.name)

	return ModelInfo.new(model, blankData, modelConfig)
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

	if not lastEditedModelInfo or lastEditedModelInfo:GetBlankName() ~= modelName then
		lastEditedModelInfo = InitModelFromBlankData(blankData)
	end

	UpdateCameraForEditMode(lastEditedModelInfo)
	CreationManager.new(lastEditedModelInfo)
end

PlayerClickedHumanoidEvent.OnClientEvent:Connect(EnterCreationMode)

function CreationManager:ResetModelInfo()
	self:Quit()
	if not lastEditedModelInfo then
		warn("No model info to reset")
		return
	end
	local modelName = lastEditedModelInfo:GetBlankName()
	DestroyLastModel()
	EnterCreationMode(modelName)
end
