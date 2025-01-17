-- The brush tool handles painting freeform brush strokes on EditableImages.
-- There is only one paint layer per meshpart.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Modules = ReplicatedStorage:WaitForChild("Modules")

local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

local Actions = require(Modules:WaitForChild("Actions"))

local Utils = require(Modules:WaitForChild("Utils"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local ImageEditActions = require(TextureManipulation:WaitForChild("ImageEditActions"))
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshUtils = require(MeshManipulation:WaitForChild("MeshUtils"))

local Brushes = Modules:WaitForChild("Brushes")
local BrushInfo = require(Brushes:WaitForChild("BrushInfo"))
local ProjectionBrush = require(Brushes:WaitForChild("ProjectionBrush"))
local LinearBrush = require(Brushes:WaitForChild("LinearBrush"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")

local BrushTool = {}
BrushTool.__index = BrushTool

local STATE_PAINTING = 1
local STATE_ERASING = 2

local VIRTUAL_CURSOR_UPDATES_PER_SECOND = 10

function BrushTool.new(modelInfo: ModelInfo.ModelInfoClass, inputManager)
	local self = {}
	setmetatable(self, BrushTool)

	self.modelInfo = modelInfo
	self.inputManager = inputManager

	self.currentBrushSize = 10
	self.currentBrushColor = Color3.new(1, 1, 1)
	self.currentEraserSize = 5

	self.touchPoints = {}

	self.currentState = STATE_PAINTING
	self.currentBrush = nil

	self.UseProjectionBrush = Utils.GetIsProjectionActivated()

	self.connections = {}
	self.lastVirtualCursorUpdate = 0

	self:SetupMeshDraw()

	-- Disable for now; we don't want to capture inputs until the user has selected the brush tool
	self:Disable()

	return self
end

function BrushTool:SetStatePainting()
	self.currentState = STATE_PAINTING
end

function BrushTool:SetStateErasing()
	self.currentState = STATE_ERASING
end

function BrushTool:OnBrushSizeChanged(newSize)
	if self.currentState == STATE_PAINTING then
		self.currentBrushSize = newSize
	elseif self.currentState == STATE_ERASING then
		self.currentEraserSize = newSize
	end
end

function BrushTool:OnEraserSizeChanged(newSize)
	self.currentEraserSize = newSize
end

function BrushTool:GetBrushSize()
	return self.currentBrushSize
end

function BrushTool:GetEraserSize()
	return self.currentEraserSize
end

function BrushTool:GetActiveSize()
	if self.currentState == STATE_ERASING then
		return self.currentEraserSize
	end

	return self.currentBrushSize
end

function BrushTool:OnColorChanged(newColor)
	self.currentBrushColor = newColor
end

function BrushTool:Enable()
	self.brushInputGui.Enabled = true
end

function BrushTool:Disable()
	self.brushInputGui.Enabled = false
end

function BrushTool:ClearAll()
	local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()

	for _, meshPart in self.modelInfo:GetMeshParts() do
		if textureInfo:HasLayer(meshPart, Constants.BRUSH_LAYER) then
			local clearBrushActionMetadata: ImageEditActions.ClearBrushActionMetadata = {
				targetMeshPartName = meshPart.Name,
			}

			local action = Actions.CreateNewAction(Actions.ActionTypes.ClearBrush, clearBrushActionMetadata)

			Actions.ExecuteAction(self.modelInfo, action)
			SendActionToServerEvent:FireServer(action)

			textureInfo:UpdateOutputColorMap(meshPart)
		end
	end
end

function BrushTool:CreateNewBrush(meshPart)
	local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
	local brushLayer, _wasCreated = textureInfo:GetOrCreateLayer(meshPart, Constants.BRUSH_LAYER)

	if self.currentBrush then
		self.currentBrush:Destroy()
	end

	self.currentBrush = nil

	if self.UseProjectionBrush then
		self.currentBrush = ProjectionBrush.new(brushLayer, textureInfo)
		self.currentBrush:SetCommitBrushStrokeCallback(
			function(projectionBrushActionMetadata: ImageEditActions.ProjectionBrushActionMetadata)
				local brushAction =
					Actions.CreateNewAction(Actions.ActionTypes.ProjectionBrush, projectionBrushActionMetadata)

				if self.currentBrush:GetRequireLocalExecute() then
					Actions.ExecuteAction(self.modelInfo, brushAction)

					local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
					textureInfo:UpdateOutputColorMap(self.lastDrawnMeshPart)
				end

				SendActionToServerEvent:FireServer(brushAction)
			end
		)
	else
		self.currentBrush = LinearBrush.new(brushLayer, textureInfo)
		self.currentBrush:SetCommitBrushStrokeCallback(function(linearBrushActionMetadata: ImageEditActions.LinearBrushActionMetadata)

			local brushAction = Actions.CreateNewAction(Actions.ActionTypes.LinearBrush, linearBrushActionMetadata)

			if self.currentBrush:GetRequireLocalExecute() then
				Actions.ExecuteAction(self.modelInfo, brushAction)

				local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
				textureInfo:UpdateOutputColorMap(self.lastDrawnMeshPart)
			end

			SendActionToServerEvent:FireServer(brushAction)
		end)
	end

	local currentColor = self.currentState == STATE_ERASING and Color3.new( 0, 0, 0) or self.currentBrushColor
	local currentTransparency = self.currentState == STATE_ERASING and 1.0 or 0.0
	local currentColorBlendType = self.currentState == STATE_ERASING and Enum.ImageCombineType.Multiply or Enum.ImageCombineType.BlendSourceOver
	local currentAlphaBlendType = self.currentState == STATE_ERASING and Enum.ImageAlphaType.LockCanvasColor or Enum.ImageAlphaType.Default
	self.currentBrush:SetColor(currentColor)
	self.currentBrush:SetSize(self:GetActiveSize())
	self.currentBrush:SetTransparency(currentTransparency)
	self.currentBrush:SetCurrentMeshPart(meshPart)
	self.currentBrush:SetColorBlendType(currentColorBlendType)
	self.currentBrush:SetAlphaBlendType(currentAlphaBlendType)
	self.currentBrush:SetAllMeshPart(self.modelInfo:GetMeshInfo():GetEditableMeshMap())
end

-- Returns: A) Did we hit the larger bounding box? B) The closest hit point along the raycast.
function BrushTool:CastRayFromCamera(inputPosition): (boolean, MeshUtils.EditableMeshRaycastResult?)
	local camera = game.Workspace.CurrentCamera
	if not camera then
		return false, nil
	end

	local ray = camera:ScreenPointToRay(inputPosition.X, inputPosition.Y)

	-- Now, raycast against the meshparts to determine the closest hit point.
	local meshInfo = self.modelInfo:GetMeshInfo()
	local closestRaycastResult: MeshUtils.EditableMeshRaycastResult? =
		MeshUtils.RaycastAll(ray, meshInfo:GetEditableMeshMap(), meshInfo:GetScaleFactorMap())

	if closestRaycastResult ~= nil and closestRaycastResult.triangleId then
		return true, closestRaycastResult
	end
	return false, nil
end

-- Handle user input. There is a bounding box input capture element that sits over the screen
-- Note that input is only captured by BrushTool when we are in the brush tool mode.
function BrushTool:SetupMeshDraw()
	local brushInputGui = Instance.new("ScreenGui")
	brushInputGui.Name = "BrushInputGui"
	brushInputGui.Parent = PlayerGui
	self.brushInputGui = brushInputGui

	local InputCapture = Instance.new("Frame")
	InputCapture.BackgroundTransparency = 1
	InputCapture.Size = UDim2.fromScale(1, 1)
	InputCapture.Parent = brushInputGui
	self.InputCapture = InputCapture

	local penDown = false

	self.connections["inputBegan"] = InputCapture.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end

		local didHitModel, raycastResult: MeshUtils.EditableMeshRaycastResult? = self:CastRayFromCamera(input.Position)
		if didHitModel == false or not raycastResult then
			return
		end

		-- If we're already drawing, we don't support multiple brush strokes at the same time.
		if #self.touchPoints > 0 then
			return
		end

		self.touchPoints[#self.touchPoints + 1] = input

		if self.inputManager:TryGrabLock(self) == false then
			return
		end

		penDown = true

		-- Convert Vector3 raycast hit into Vector2 UV coords

		local editableMeshMap = self.modelInfo:GetMeshInfo():GetEditableMeshMap()
		local hitEditableMesh = editableMeshMap[raycastResult.meshPart]

		local textureCoord = MeshUtils.GetTextureCoordinate(
			hitEditableMesh,
			raycastResult.triangleId,
			raycastResult.barycentricCoordinate
		)

		local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
		local textureSize = textureInfo:GetTextureSize(raycastResult.meshPart)

		local drawX = textureCoord.X * textureSize.X
		local drawY = textureCoord.Y * textureSize.Y

		local drawPosition = Vector2.new(math.floor(drawX), math.floor(drawY))

		if
			not self.currentBrush
			or (
				self.lastDrawnMeshPart ~= raycastResult.meshPart
				and not textureInfo:MeshPartsShareLayer(self.lastDrawnMeshPart, raycastResult.meshPart)
			)
		then
			self:CreateNewBrush(raycastResult.meshPart)
		end

		self.lastDrawnMeshPart = raycastResult.meshPart

		local drawInfo: BrushInfo.DrawInfo = {
			textureDrawPosition = drawPosition,
			cameraCFrame = game.Workspace.CurrentCamera.CFrame,
			castedPoint = raycastResult.meshPart.CFrame:PointToWorldSpace(raycastResult.point),
			isVirtualCursorMovement = false,
		}
		self.currentBrush:PenDown(drawInfo)

		textureInfo:UpdateOutputColorMap(raycastResult.meshPart)
	end)

	self.connections["inputChanged"] = UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
		if not penDown then
			return
		end

		local isVirtualCursorMovement = Utils.isVirtualCursor(input.UserInputType) and input.KeyCode == Enum.KeyCode.Thumbstick1

		if not isVirtualCursorMovement then
			if gameProcessedEvent then
				return
			end

			if
				input.UserInputType ~= Enum.UserInputType.MouseMovement
				and input.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end
		end

		if input.UserInputState == Enum.UserInputType.Touch then
			-- If we're not tracking this touch input, ignore it
			local isValidTouchInput = false
			for _, touchInput in pairs(self.touchPoints) do
				if input == touchInput then
					isValidTouchInput = true
					break
				end
			end

			if isValidTouchInput ~= true then
				self.currentBrush:PenUp()
				return
			end
		end

		local inputPosition = input.Position
		if isVirtualCursorMovement then
			local ticks = tick()
			-- Throttle virtual cursor movement events to improve performance
			if ticks - self.lastVirtualCursorUpdate < (1 / VIRTUAL_CURSOR_UPDATES_PER_SECOND) then
				return
			end
			self.lastVirtualCursorUpdate = ticks
			inputPosition = UserInputService:GetMouseLocation()
		end
		self:HandleInputChanged(inputPosition, isVirtualCursorMovement)
	end)

	self.connections["inputEnded"] = UserInputService.InputEnded:Connect(function(input, _gameProcessedEvent)
		local usingVirtualCursor = Utils.isVirtualCursor(input.UserInputType)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
			and (not usingVirtualCursor or input.KeyCode ~= Enum.KeyCode.ButtonA)
		then
			return
		end

		penDown = false

		if usingVirtualCursor then
			self.touchPoints = {}
		else
			for i, touchInput in pairs(self.touchPoints) do
				if touchInput == input then
					table.remove(self.touchPoints, i)
					break
				end
			end
		end

		if self.currentBrush then
			self.currentBrush:PenUp(Vector2.new())
			self.currentBrush:Destroy()
			self.currentBrush = nil
		end
	end)
end

function BrushTool:HandleInputChanged(inputPosition: Vector2, isVirtualCursorMovement: boolean)
	local didHitModel, raycastResult: MeshUtils.EditableMeshRaycastResult? = self:CastRayFromCamera(inputPosition)
	if not didHitModel or not raycastResult then
		self.currentBrush:PenUp()
		return
	end

	local textureCoord = MeshUtils.GetTextureCoordinate(
		raycastResult.editableMesh,
		raycastResult.triangleId,
		raycastResult.barycentricCoordinate
	)

	local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
	local textureSize = textureInfo:GetTextureSize(raycastResult.meshPart)
	local drawPosition = textureCoord * textureSize

	local drawInfo: BrushInfo.DrawInfo = {
		textureDrawPosition = drawPosition,
		cameraCFrame = game.Workspace.CurrentCamera.CFrame,
		castedPoint = raycastResult.meshPart.CFrame:PointToWorldSpace(raycastResult.point),
		isVirtualCursorMovement = isVirtualCursorMovement,
	}

	if
		self.lastDrawnMeshPart ~= raycastResult.meshPart
		and textureInfo:MeshPartsShareLayer(self.lastDrawnMeshPart, raycastResult.meshPart)
	then
		self.currentBrush:PenUp()
		self:CreateNewBrush(raycastResult.meshPart)

		self.currentBrush:PenDown(drawInfo)
	else
		self.currentBrush:MovePen(drawInfo)
	end

	self.lastDrawnMeshPart = raycastResult.meshPart

	textureInfo:UpdateOutputColorMap(raycastResult.meshPart)
end

function BrushTool:Destroy()
	self.brushInputGui:Destroy()

	if self.currentBrush then
		self.currentBrush:Destroy()
	end

	for _, connection in self.connections do
		connection:Disconnect()
	end
end

return BrushTool
