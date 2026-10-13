-- The brush tool handles painting freeform brush strokes on EditableImages.
-- There is only one paint layer per meshpart.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Brushes = Modules:WaitForChild("Brushes")
local BrushInfo = require(Brushes:WaitForChild("BrushInfo"))
local ImageProjectionBrush = require(Brushes:WaitForChild("ImageProjectionBrush"))

local ModelInfo = require(Modules:WaitForChild("ModelInfo"))
local Actions = require(Modules:WaitForChild("Actions"))
local ActionUtils = require(Modules:WaitForChild("ActionUtils"))
local HistoryTool = require(Modules:WaitForChild("Client"):WaitForChild("Tools"):WaitForChild("HistoryTool"))
local HistoryEditActions =
	require(Modules:WaitForChild("Client"):WaitForChild("Tools"):WaitForChild("HistoryEditActions"))
local MirrorGuide = require(Modules:WaitForChild("Client"):WaitForChild("Tools"):WaitForChild("MirrorGuide"))

local InputUtils = require(Modules:WaitForChild("Client"):WaitForChild("InputUtils"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local ImageEditActions = require(TextureManipulation:WaitForChild("ImageEditActions"))
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshUtils = require(MeshManipulation:WaitForChild("MeshUtils"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local BrushData = require(Config:WaitForChild("BrushData"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")

local BrushTool = {}
BrushTool.__index = BrushTool

local VIRTUAL_CURSOR_UPDATES_PER_SECOND = 10

function BrushTool.new(modelInfo: ModelInfo.ModelInfoClass, inputManager, historyTool: HistoryTool.HistoryTool?)
	local self = {}
	setmetatable(self, BrushTool)

	self.modelInfo = modelInfo
	self.inputManager = inputManager
	self.historyTool = historyTool
	self.brushRegistry = modelInfo:GetBrushRegistry()

	-- Brush sizes will be updated by slider callback during init
	self.currentBrushSize = 1
	self.currentEraserSize = 1
	self.currentBlendSize = 1

	self.currentBrushColor = Color3.new(1, 1, 1)
	self.currentBrushTransparency = 0
	self.currentEraserTransparency = 0
	self.isReflectiveMode = false

	self.mirrorGuide = MirrorGuide.new(modelInfo)
	self.showMirrorGuide = true

	self.touchPoints = {}

	self.currentState = Constants.STATE_PAINTING
	self.projectionbrush = nil -- the ImageProjectionBrush instance that we use

	-- the current brush that we give to the projectionbrush
	self.selectedBrush = self.brushRegistry:GetBrush(BrushTool.GetDefaultBrush(Constants.STATE_PAINTING))

	self.mostRecentBrushByType = {
		[Constants.STATE_PAINTING] = BrushTool.GetDefaultBrush(Constants.STATE_PAINTING),
		[Constants.STATE_ERASING] = BrushTool.GetDefaultBrush(Constants.STATE_ERASING),
		[Constants.STATE_BLENDING] = BrushTool.GetDefaultBrush(Constants.STATE_BLENDING),
	}

	-- Mirror plane shared across brush modes (painting/erasing/blending), stored relative to the model so
	-- it follows object movement and rotation. On by default.
	self.mirrorPlane = CFrame.identity

	self.connections = {}
	self.lastVirtualCursorUpdate = 0

	self:SetupMeshDraw()

	-- Disable for now; we don't want to capture inputs until the user has selected the brush tool
	self:Disable()

	return self
end

-- Copies user settings when switching editing targets.
function BrushTool:CopySettingsFrom(previousBrush)
	self.currentBrushSize = previousBrush.currentBrushSize
	self.currentEraserSize = previousBrush.currentEraserSize
	self.currentBlendSize = previousBrush.currentBlendSize
	self.currentBrushTransparency = previousBrush.currentBrushTransparency
	self.currentEraserTransparency = previousBrush.currentEraserTransparency
	self.isReflectiveMode = previousBrush.isReflectiveMode
	self.mirrorPlane = previousBrush.mirrorPlane
	self.showMirrorGuide = previousBrush.showMirrorGuide
	self.mostRecentBrushByType = table.clone(previousBrush.mostRecentBrushByType)
end

function BrushTool.GetDefaultBrush(brushType)
	local brushTypeData
	if brushType == Constants.STATE_PAINTING then
		brushTypeData = BrushData.PaintBrushData
	elseif brushType == Constants.STATE_ERASING then
		brushTypeData = BrushData.EraserBrushData
	else
		brushTypeData = BrushData.BlendBrushData
	end
	local sortedBrushData = BrushData.GetSortedBrushData(brushTypeData)
	return sortedBrushData[1].brushId
end

function BrushTool:setBrush(brushId)
	self.selectedBrush = self.brushRegistry:GetBrush(brushId)
	self.currentState = BrushInfo.ResolveSettings(self.selectedBrush:getSettings()).brushType
	self.mostRecentBrushByType[self.currentState] = brushId
end

function BrushTool:getMostRecentBrushByType(brushType)
	return self.brushRegistry:GetBrush(self.mostRecentBrushByType[brushType])
end

function BrushTool:SetStatePainting()
	self:setBrush(self.mostRecentBrushByType[Constants.STATE_PAINTING])
	self:UpdateMirrorGuideVisibility()
end

function BrushTool:SetStateErasing()
	self:setBrush(self.mostRecentBrushByType[Constants.STATE_ERASING])
	self:UpdateMirrorGuideVisibility()
end

function BrushTool:SetStateBlending()
	self:setBrush(self.mostRecentBrushByType[Constants.STATE_BLENDING])
	self:UpdateMirrorGuideVisibility()
end

function BrushTool:OnBrushSizeChanged(newSize, isFinalInput, brushState)
	if brushState == Constants.STATE_PAINTING then
		self.currentBrushSize = newSize
	elseif brushState == Constants.STATE_ERASING then
		self.currentEraserSize = newSize
	elseif brushState == Constants.STATE_BLENDING then
		self.currentBlendSize = newSize
	end
end

function BrushTool:OnBrushOpacityChanged(newOpacity)
	local newTransparency = 1 - newOpacity

	if self.currentState == Constants.STATE_PAINTING then
		self.currentBrushTransparency = newTransparency
	elseif self.currentState == Constants.STATE_ERASING then
		self.currentEraserTransparency = newTransparency
	end
end

function BrushTool:GetBrushSize()
	return self.currentBrushSize
end

function BrushTool:GetEraserSize()
	return self.currentEraserSize
end

function BrushTool:GetActiveSize()
	if self.currentState == Constants.STATE_ERASING then
		return self.currentEraserSize
	elseif self.currentState == Constants.STATE_BLENDING then
		return self.currentBlendSize
	end

	return self.currentBrushSize
end

function BrushTool:GetActiveTransparency()
	if self.currentState == Constants.STATE_ERASING then
		return self.currentEraserTransparency
	end

	return self.currentBrushTransparency
end

function BrushTool:OnColorChanged(newColor)
	self.currentBrushColor = newColor
end

function BrushTool:SetIsReflective(isReflectiveMode)
	self.isReflectiveMode = isReflectiveMode
end

function BrushTool:GetMirrorPlane(): CFrame?
	return if self.mirrorPlane then self.modelInfo:GetModel():GetPivot():ToWorldSpace(self.mirrorPlane) else nil
end

function BrushTool:SetMirrorPlane(mirrorPlane: CFrame?)
	local modelPivot = self.modelInfo:GetModel():GetPivot()
	self.mirrorPlane = if mirrorPlane then modelPivot:ToObjectSpace(mirrorPlane) else nil

	if self.projectionBrush then
		self.projectionBrush:SetMirrorPlane(self:GetMirrorPlane())
	end

	self:UpdateMirrorGuideVisibility()
end

function BrushTool:IsMirrorEnabled(): boolean
	return self.mirrorPlane ~= nil
end

function BrushTool:IsMirrorGuideEnabled(): boolean
	return self.showMirrorGuide
end

function BrushTool:Enable()
	self.brushInputGui.Enabled = true
	self:UpdateMirrorGuideVisibility()
end

function BrushTool:Disable()
	self.brushInputGui.Enabled = false
	self:UpdateMirrorGuideVisibility()
	if self.projectionBrush then
		self.projectionBrush:PenUp(Vector2.zero)
		self.projectionBrush:Destroy()
		self.projectionBrush = nil
	end
end

function BrushTool:SetMirrorGuideVisible(isVisible: boolean)
	self.showMirrorGuide = isVisible
	self:UpdateMirrorGuideVisibility()
end

function BrushTool:UpdateMirrorGuideVisibility()
	self.mirrorGuide:SetVisible(self.brushInputGui.Enabled and self.showMirrorGuide and self:GetMirrorPlane() ~= nil)
end

function BrushTool:ClearAll()
	local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()

	local targetLayerInfo = textureInfo:GetTargetLayerInfo()
	for _, meshPart in self.modelInfo:GetMeshParts() do
		if textureInfo:HasLayer(meshPart, targetLayerInfo) then
			local clearBrushActionMetadata: ImageEditActions.ClearBrushActionMetadata = {
				targetMeshPartName = meshPart.Name,
			}

			local action = ActionUtils.CreateNewAction(
				ActionUtils.ActionTypes.ClearBrush,
				clearBrushActionMetadata,
				self.modelInfo
			)

			Actions.ExecuteAction(self.modelInfo, action, nil, self.historyTool)
			SendActionToServerEvent:FireServer(action)

			textureInfo:UpdateOutputColorMap(meshPart)
		end
	end
end

function BrushTool:CreateNewBrush(meshPart)
	local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
	local targetLayerInfo = textureInfo:GetTargetLayerInfo()

	local brushLayers, _wasCreated = textureInfo:GetOrCreateLayer(meshPart, targetLayerInfo)

	if self.projectionBrush then
		self.projectionBrush:Destroy()
	end

	self.projectionBrush = ImageProjectionBrush.new(brushLayers, textureInfo)
	self.projectionBrush:SetBrush(self.selectedBrush)
	self.projectionBrush:SetCommitBatchCallback(function(imageProjectionBrushActionMetadata)
		local brushAction = ActionUtils.CreateNewAction(
			ActionUtils.ActionTypes.ImageProjectionBrush,
			imageProjectionBrushActionMetadata,
			self.modelInfo
		)

		if self.projectionBrush:GetRequireLocalExecute() then
			Actions.ExecuteAction(self.modelInfo, brushAction)

			local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
			textureInfo:UpdateOutputColorMap(self.lastDrawnMeshPart)
		end

		SendActionToServerEvent:FireServer(brushAction)
	end)

	-- Use the same full-stroke action for local and server history.
	self.projectionBrush:SetCommitStrokeCallback(function(strokeActionMetadata, preEditBuffer)
		-- send the action to the server to add in its history
		local serverStrokeAction = ActionUtils.CreateNewAction(
			ActionUtils.ActionTypes.ImageProjectionStrokeCompleted,
			strokeActionMetadata,
			self.modelInfo
		)
		SendActionToServerEvent:FireServer(serverStrokeAction)

		local clientStrokeAction =
			ActionUtils.CreateNewAction(ActionUtils.ActionTypes.ImageProjectionBrush, strokeActionMetadata)
		-- we need the normal action type to replay on the client side, metadata is identical
		if self.historyTool then
			self.historyTool:addUndoAction(meshPart.Name, targetLayerInfo, clientStrokeAction, preEditBuffer)
		end
	end)

	self.projectionBrush:SetSize(self:GetActiveSize())
	self.projectionBrush:SetTransparency(self:GetActiveTransparency())
	self.projectionBrush:SetCurrentMeshPart(meshPart)
	self.projectionBrush:SetAllMeshPart(self.modelInfo:GetMeshInfo():GetProjectionTargetMap())
	self.projectionBrush:SetIsReflective(self.isReflectiveMode)
	self.projectionBrush:SetMirrorPlane(self:GetMirrorPlane())

	-- brushes own color
	self.selectedBrush:setColor(self.currentBrushColor)
end

-- Returns: A) Did we hit the larger bounding box? B) The closest hit point along the raycast.
function BrushTool:CastRayFromCamera(inputPosition): (boolean, MeshUtils.EditableMeshRaycastResult?)
	if self.modelInfo:GetMakeupHeadSwapInProgress() then
		return false, nil
	end
	local camera = game.Workspace.CurrentCamera
	if not camera then
		return false, nil
	end

	local ray = camera:ScreenPointToRay(inputPosition.X, inputPosition.Y)
	local head = self.modelInfo:GetMeshPartByName("Head")
	if head and self.modelInfo:GetMeshInfo():GetProjectionTarget(head):IsA("WrapTextureTransfer") then
		local result = MeshUtils.RaycastMeshPart(ray, head)
		if result then
			return true,
				{
					point = head.CFrame:PointToObjectSpace(result.Position),
					meshPart = head,
					scaleFactor = self.modelInfo:GetMeshInfo():GetScaleFactorMap()[head],
				}
		end

		return false, nil
	end

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

		local didHitModel, raycastResult: MeshUtils.EditableMeshRaycastResult? =
			self:CastRayFromCamera(InputUtils.getInputPosition(input))
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

		local textureCoord = Vector2.zero
		if raycastResult.editableMesh then
			local editableMeshMap = self.modelInfo:GetMeshInfo():GetEditableMeshMap()
			local hitEditableMesh = editableMeshMap[raycastResult.meshPart]

			textureCoord = MeshUtils.GetTextureCoordinate(
				hitEditableMesh,
				raycastResult.triangleId,
				raycastResult.barycentricCoordinate
			)
		end

		local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
		local textureSize = textureInfo:GetTextureSize(raycastResult.meshPart)

		local drawX = textureCoord.X * textureSize.X
		local drawY = textureCoord.Y * textureSize.Y

		local drawPosition = Vector2.new(math.floor(drawX), math.floor(drawY))

		if
			not self.projectionBrush
			or (
				self.lastDrawnMeshPart ~= raycastResult.meshPart
				and not textureInfo:MeshPartsShareLayer(self.lastDrawnMeshPart, raycastResult.meshPart)
			)
		then
			self:CreateNewBrush(raycastResult.meshPart)
		end

		self.lastDrawnMeshPart = raycastResult.meshPart
		self.projectionBrush:SetMirrorPlane(self:GetMirrorPlane())

		local drawInfo: BrushInfo.DrawInfo = {
			textureDrawPosition = drawPosition,
			cameraCFrame = game.Workspace.CurrentCamera.CFrame,
			castedPoint = raycastResult.meshPart.CFrame:PointToWorldSpace(raycastResult.point),
			isVirtualCursorMovement = false,
		}
		self.projectionBrush:PenDown(drawInfo)

		textureInfo:UpdateOutputColorMap(raycastResult.meshPart)
	end)

	self.connections["inputChanged"] = UserInputService.InputChanged:Connect(function(input, _gameProcessedEvent)
		if not penDown or not self.projectionBrush or not self.brushInputGui.Enabled then
			return
		end

		local isVirtualCursorMovement = InputUtils.isVirtualCursor(input.UserInputType)
			and input.KeyCode == Enum.KeyCode.Thumbstick1

		if not isVirtualCursorMovement then
			-- An active stroke owns the input lock, including while moving over UI.
			if
				input.UserInputType ~= Enum.UserInputType.MouseMovement
				and input.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end
		end

		if input.UserInputType == Enum.UserInputType.Touch then
			-- If we're not tracking this touch input, ignore it
			local isValidTouchInput = false
			for _, touchInput in pairs(self.touchPoints) do
				if input == touchInput then
					isValidTouchInput = true
					break
				end
			end

			if isValidTouchInput ~= true then
				return
			end
		end

		local inputPosition = InputUtils.getInputPosition(input)
		if isVirtualCursorMovement then
			local ticks = tick()
			-- Throttle virtual cursor movement events to improve performance
			if ticks - self.lastVirtualCursorUpdate < (1 / VIRTUAL_CURSOR_UPDATES_PER_SECOND) then
				return
			end
			self.lastVirtualCursorUpdate = ticks
		end
		self:HandleInputChanged(inputPosition, isVirtualCursorMovement)
	end)

	self.connections["inputEnded"] = UserInputService.InputEnded:Connect(function(input, _gameProcessedEvent)
		local usingVirtualCursor = InputUtils.isVirtualCursor(input.UserInputType)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
			and (not usingVirtualCursor or input.KeyCode ~= Enum.KeyCode.ButtonA)
		then
			return
		end

		if input.UserInputType == Enum.UserInputType.Touch and not table.find(self.touchPoints, input) then
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

		if self.projectionBrush then
			self.projectionBrush:PenUp(Vector2.new())
			self.projectionBrush:Destroy()
			self.projectionBrush = nil
		end
	end)
end

function BrushTool:HandleInputChanged(inputPosition: Vector2, isVirtualCursorMovement: boolean)
	local didHitModel, raycastResult: MeshUtils.EditableMeshRaycastResult? = self:CastRayFromCamera(inputPosition)
	if not didHitModel or not raycastResult then
		self.projectionBrush:PenUp()
		return
	end

	local textureCoord = Vector2.zero
	if raycastResult.editableMesh then
		textureCoord = MeshUtils.GetTextureCoordinate(
			raycastResult.editableMesh,
			raycastResult.triangleId,
			raycastResult.barycentricCoordinate
		)
	end

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
		self.projectionBrush:PenUp()
		self:CreateNewBrush(raycastResult.meshPart)

		self.projectionBrush:PenDown(drawInfo)
	else
		self.projectionBrush:MovePen(drawInfo)
	end

	self.lastDrawnMeshPart = raycastResult.meshPart

	textureInfo:UpdateOutputColorMap(raycastResult.meshPart)
end

function BrushTool:Destroy()
	self.brushInputGui:Destroy()

	if self.projectionBrush then
		self.projectionBrush:Destroy()
	end

	self.mirrorGuide:Destroy()

	for _, connection in self.connections do
		connection:Disconnect()
	end
end

return BrushTool
