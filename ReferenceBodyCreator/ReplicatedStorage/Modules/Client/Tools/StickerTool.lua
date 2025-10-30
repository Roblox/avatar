-- The sticker tool is used to add stickers to the shirt and move/rotate/scale/tile them.
-- Each sticker sits on its own layer. Every sticker layer can be tiled.
-- When the sticker is dragged, we cast a ray from the camera to the mouse pos. If the shirt is hit,
-- we convert the hit point into UV coords and draw the sticker at those coords on the 2d texture.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local ModelInfo = require(Modules:WaitForChild("ModelInfo"))

local Actions = require(Modules:WaitForChild("Actions"))

local Utils = require(Modules:WaitForChild("Utils"))

local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local StyleConsts = require(UI:WaitForChild("StyleConsts"))
local styleTokens = StyleConsts.styleTokens

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))

local Components = UI:WaitForChild("Components")
local EditHandle = require(Components:WaitForChild("EditHandle"))

local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local ImageEditActions = require(TextureManipulation:WaitForChild("ImageEditActions"))
local TextureInfo = require(TextureManipulation:WaitForChild("TextureInfo"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshInfo = require(MeshManipulation:WaitForChild("MeshInfo"))
local MeshUtils = require(MeshManipulation:WaitForChild("MeshUtils"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local HANDLE_GUI_NAME = "StickerHandleGui"

local StickerTool = {}
StickerTool.__index = StickerTool

type StickerData = {
	textureId: string,

	projectionDirection: Vector3,

	texturePosition: Vector2,
	rotation: number,
	scale: number,

	isTiled: boolean,
	tilePadding: number?,

	targetMeshPart: MeshPart,

	positionMarker: Part,
	positionMarkerOffset: CFrame,

	stickerLayerNumber: number,
}

function StickerTool.new(modelInfo: ModelInfo.ModelInfoClass, inputManager)
	local self = {}
	setmetatable(self, StickerTool)

	self.modelInfo = modelInfo
	self.inputManager = inputManager

	self.currentlySelectedSticker = 0

	self.isDraggingSticker = false
	self.isRotatingSticker = false
	self.isScalingSticker = false
	self.lastStickerAction = nil

	self.selectedRegionName = nil

	self.UseProjectionSticker = Utils.GetIsProjectionActivated()

	-- AppliedStickers contains info about all the stickers that are currently applied to the body.
	-- Position, rotation, scale, tile padding, etc.
	self.appliedStickers = modelInfo:GetAppliedStickers() :: { StickerData }
	self.stickerCounter = #self.appliedStickers

	self.connections = {}

	self:RefreshHandleUI()

	-- Whenever the player rotates/moves the model, we need to update the screen location of UI handles.
	for _, meshPart in modelInfo:GetMeshParts() do
		local connection = meshPart:GetPropertyChangedSignal("Position"):Connect(function()
			local selectedSticker = self.appliedStickers[self.currentlySelectedSticker]
			if selectedSticker ~= nil then
				self:RefreshMarkerPosition(selectedSticker)
			end
		end)
		table.insert(self.connections, connection)
	end

	self:Disable()

	return self
end

local function GetRayPlaneIntersection(rayStart, rayDirection, planePoint, planeNormal)
	local denom = planeNormal:Dot(rayDirection)
	if math.abs(denom) > 0.0001 then -- your favorite epsilon
		local t = (planePoint - rayStart):Dot(planeNormal) / denom
		if t >= 0 then
			return true, rayStart + rayDirection * t
		end
	end
	return false, 0
end

local function RotateVectorAroundAxis(v, angleDegrees, axis)
	local angleRadians = math.rad(angleDegrees)
	return CFrame.fromAxisAngle(axis, angleRadians):VectorToWorldSpace(v)
end

function StickerTool:ConnectHandlesToStyle(style)
	style:LinkGui(self.inputGui)
end

function StickerTool:RefreshMarkerPosition(stickerData: StickerData?)
	if stickerData then
		stickerData.positionMarker.CFrame =
			stickerData.targetMeshPart.CFrame:ToWorldSpace(stickerData.positionMarkerOffset)

		local directionIndicator = stickerData.positionMarker:FindFirstChild("StickerDirectionMarker")
		if directionIndicator then
			directionIndicator.Position =
				stickerData.positionMarker.Position + stickerData.projectionDirection
		end

		self:RefreshHandleUI()
	end
end

function StickerTool:MoveStickerBetweenParts(stickerData: StickerData, newTargetMeshPart: MeshPart)
	local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()

	local oldMeshPart = stickerData.targetMeshPart
	stickerData.targetMeshPart = newTargetMeshPart

	if textureInfo:MeshPartsShareLayer(oldMeshPart, newTargetMeshPart) then
		return
	end

	local removeStickerActionMetadata: ImageEditActions.RemoveStickerActionMetadata = {
		targetMeshPartName = oldMeshPart.Name,
		stickerLayerNumber = stickerData.stickerLayerNumber,
	}

	local removeStickerAction = Actions.CreateNewAction(Actions.ActionTypes.RemoveSticker, removeStickerActionMetadata)
	Actions.ExecuteAction(self.modelInfo, removeStickerAction)

	textureInfo:UpdateOutputColorMap(oldMeshPart)

	SendActionToServerEvent:FireServer(removeStickerAction)
end

function StickerTool:SetupHandles()
	local handleGui = Instance.new("ScreenGui")
	handleGui.Name = HANDLE_GUI_NAME
	handleGui.Parent = PlayerGui
	self.inputGui = handleGui
	handleGui.Enabled = false

	self.UIHandles = EditHandle.new()

	local moveHandle = self.UIHandles.moveHandle
	moveHandle.Parent = handleGui
	-- These are already children of the moveHandle
	local rotateHandle = self.UIHandles.rotateHandle
	local scaleHandle = self.UIHandles.scaleHandle

	local moveHandleInputBegan = moveHandle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if self.isRotatingSticker or self.isScalingSticker then
				return
			end
			if self.inputManager:TryGrabLock(self) == false then
				return
			end

			self.isDraggingSticker = true
		end
	end)
	table.insert(self.connections, moveHandleInputBegan)

	local inputChanged = UserInputService.InputChanged:Connect(function(input)
		if
			(input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
			and self.isDraggingSticker
		then
			-- Raycast to mouse pos and set sticker location
			local ray = workspace.CurrentCamera:ScreenPointToRay(input.Position.X, input.Position.Y, 1)

			local selectedSticker: StickerData? = self.appliedStickers[self.currentlySelectedSticker]
			if not selectedSticker then
				return
			end

			local meshPart = selectedSticker.targetMeshPart

			local meshInfo: MeshInfo.MeshInfoClass = self.modelInfo:GetMeshInfo()

			local raycastResult: MeshUtils.EditableMeshRaycastResult? =
				MeshUtils.RaycastAll(ray, meshInfo:GetEditableMeshMap(), meshInfo:GetScaleFactorMap())
			if raycastResult == nil then
				-- This can happen while dragging a sticker if the mouse is no longer over a meshpart
				return
			end

			if raycastResult.meshPart ~= meshPart then
				self:MoveStickerBetweenParts(selectedSticker, raycastResult.meshPart)
			end

			-- Calculate marker pos and normal
			selectedSticker.positionMarker.CFrame = MeshUtils.EditableMeshRaycastToCFrame(
				raycastResult.editableMesh,
				raycastResult.meshPart,
				raycastResult.point,
				raycastResult.triangleId,
				raycastResult.scaleFactor
			)
			selectedSticker.positionMarkerOffset = meshPart.CFrame:ToObjectSpace(selectedSticker.positionMarker.CFrame)

			local directionIndicator = selectedSticker.positionMarker:FindFirstChild("StickerDirectionMarker")
			if directionIndicator then
				directionIndicator.Position =
					selectedSticker.positionMarker.Position + selectedSticker.projectionDirection
			end

			local uvCoord = MeshUtils.GetTextureCoordinate(
				raycastResult.editableMesh,
				raycastResult.triangleId,
				raycastResult.barycentricCoordinate
			)

			local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()

			local textureCoord = uvCoord * textureInfo:GetTextureSize(meshPart)
			selectedSticker.texturePosition = textureCoord
			self:RefreshHandleUI()
			self:RedrawSticker(selectedSticker, false)
		end
	end)
	table.insert(self.connections, inputChanged)

	local rotateHandleInputBeganConnection = rotateHandle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if self.isDraggingSticker or self.isScalingSticker then
				return
			end
			if self.inputManager:TryGrabLock(self) == false then
				return
			end

			self.isRotatingSticker = true
		end
	end)
	table.insert(self.connections, rotateHandleInputBeganConnection)

	local rotateInputChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if
			(input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
			and self.isRotatingSticker
		then
			local selectedSticker: StickerData? = self.appliedStickers[self.currentlySelectedSticker]
			if not selectedSticker then
				return
			end

			-- Project mouse onto plane
			local rayOrigin = workspace.CurrentCamera.CFrame.Position
			local ray = workspace.CurrentCamera:ScreenPointToRay(input.Position.X, input.Position.Y, 1)
			local planePoint = selectedSticker.positionMarker.Position
			local planeNormal = selectedSticker.positionMarker.CFrame.LookVector
			planeNormal = planeNormal.Unit
			local _isIntersecting, intersection =
				GetRayPlaneIntersection(rayOrigin, ray.Direction, planePoint, planeNormal)

			local vectorDiff = intersection - planePoint
			vectorDiff = vectorDiff.Unit
			local upVector = RotateVectorAroundAxis(
				selectedSticker.positionMarker.CFrame.UpVector,
				selectedSticker.rotation,
				planeNormal
			)
			local upDot = upVector:Dot(vectorDiff)
			local cross = upVector:Cross(vectorDiff)

			local angle = math.atan2(cross:Dot(planeNormal), upDot)

			-- Account for difference between up vector and the rotation handle
			angle = math.deg(angle) + (90 - styleTokens.RotateHandlePosDegrees)
			selectedSticker.rotation = math.abs((selectedSticker.rotation + angle) % 360) * -1

			self:RefreshHandleUI()
			self:RedrawSticker(selectedSticker, false)
		end
	end)
	table.insert(self.connections, rotateInputChangedConnection)

	local inputChangedConnection = UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if self.isRotatingSticker or self.isDraggingSticker or self.isScalingSticker then
				if self.lastStickerAction ~= nil then
					SendActionToServerEvent:FireServer(self.lastStickerAction)
				end
			end
			self.isRotatingSticker = false
			self.isDraggingSticker = false
			self.isScalingSticker = false
			self.lastStickerAction = nil
		end
	end)
	table.insert(self.connections, inputChangedConnection)

	-- When we drag a scale handle, resize the sticker
	local scaleInputBeganConnection = scaleHandle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if self.isRotatingSticker or self.isDraggingSticker then
				return
			end
			if self.inputManager:TryGrabLock(self) == false then
				return
			end

			self.isScalingSticker = true
			self.mouseDownPos = input.Position
		end
	end)
	table.insert(self.connections, scaleInputBeganConnection)

	local scaleInputChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if
			(input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
			and self.isScalingSticker
		then
			local selectedSticker: StickerData? = self.appliedStickers[self.currentlySelectedSticker]
			if not selectedSticker then
				return
			end

			-- Project mouse onto plane
			local rayOrigin = workspace.CurrentCamera.CFrame.Position
			local ray = workspace.CurrentCamera:ScreenPointToRay(input.Position.X, input.Position.Y, 1)
			local planePoint = selectedSticker.positionMarker.Position
			local planeNormal = selectedSticker.positionMarker.CFrame.LookVector
			local isIntersecting, intersection =
				GetRayPlaneIntersection(rayOrigin, ray.Direction, planePoint, planeNormal)
			if isIntersecting then
				-- Get distance from position marker to ray intersection and use that to decide sticker size
				local vectorDiff = intersection - planePoint
				local rightVector = RotateVectorAroundAxis(
					selectedSticker.positionMarker.CFrame.RightVector,
					selectedSticker.rotation,
					planeNormal
				)
				local upVector = RotateVectorAroundAxis(
					selectedSticker.positionMarker.CFrame.UpVector,
					selectedSticker.rotation,
					planeNormal
				)
				local rightProjection = vectorDiff:Dot(rightVector) * rightVector
				local upProjection = vectorDiff:Dot(rightVector) * upVector
				local scale = math.max(rightProjection.Magnitude, upProjection.Magnitude) / 0.3
				scale = math.max(scale, 0.1) -- We need some minimum scale so that stickers don't tile infinitely (which causes a crash)
				selectedSticker.scale = scale
				self:RefreshHandleUI()
				self:RedrawSticker(selectedSticker, false)
			end
		end
	end)
	table.insert(self.connections, scaleInputChangedConnection)

	local cameraChangedConnection = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
		self:RefreshHandleUI()
	end)

	table.insert(self.connections, cameraChangedConnection)
end

function StickerTool:RefreshHandleUI()
	if self.UIHandles == nil then
		self:SetupHandles()
	end

	local handleGui = PlayerGui:FindFirstChild(HANDLE_GUI_NAME)
	if self.currentlySelectedSticker == 0 then
		-- There's no sticker selected; we should hide all ui handles.
		handleGui.Enabled = false
		return
	else
		handleGui.Enabled = true
	end

	-- Reposition handles
	local selectedSticker: StickerData = self.appliedStickers[self.currentlySelectedSticker]
	local stickerPos3d = selectedSticker.positionMarker.Position
	local camera = workspace.CurrentCamera

	local moveHandlePos = camera:WorldToScreenPoint(stickerPos3d)

	self.UIHandles:Refresh(moveHandlePos, selectedSticker.scale, selectedSticker.rotation)
end

local function GetAverageMeshPartPosition(meshParts: { MeshPart }): Vector3
	local averageMeshPartPosition = Vector3.zero
	local numMeshes = 0
	for _, meshPart in meshParts do
		averageMeshPartPosition = averageMeshPartPosition + meshPart.Position
		numMeshes = numMeshes + 1
	end
	averageMeshPartPosition = averageMeshPartPosition / numMeshes

	return averageMeshPartPosition
end

local function GetClosestMeshPart(modelInfo: ModelInfo.ModelInfoClass): (MeshPart, EditableMesh, number)
	-- Raycast towards the center of the model. Place the sticker at a neighboring vertex.
	local closestVertex = nil
	local editableMesh: EditableMesh = nil
	local meshPart = nil

	local meshInfo: MeshInfo.MeshInfoClass = modelInfo:GetMeshInfo()

	local averageMeshPartPosition = GetAverageMeshPartPosition(modelInfo:GetMeshParts())

	local rayOrigin = workspace.CurrentCamera.CFrame.Position
	local rayTarget = averageMeshPartPosition + Vector3.FromAxis(Enum.Axis.Y)
	local rayDirection = rayTarget - rayOrigin
	local raycastResult: MeshUtils.EditableMeshRaycastResult? = MeshUtils.RaycastAll(
		Ray.new(rayOrigin, rayDirection),
		meshInfo:GetEditableMeshMap(),
		meshInfo:GetScaleFactorMap()
	)
	if raycastResult == nil then
		-- Get the closest vertex of the body part. This is more reliable than raycasting since some meshes are concave and raycast may pass through them.
		for mappedMeshPart, mappedEditableMesh in pairs(meshInfo:GetEditableMeshMap()) do
			editableMesh = mappedEditableMesh
			meshPart = mappedMeshPart
			closestVertex = mappedEditableMesh:FindClosestVertex(workspace.CurrentCamera.CFrame.Position)
		end
	else
		editableMesh = raycastResult.editableMesh
		meshPart = raycastResult.meshPart
		closestVertex = editableMesh:FindClosestVertex(raycastResult.point)
	end

	return meshPart, editableMesh, closestVertex
end

local function CreatePositionMarker(newCFrame)
	-- Each sticker has a 3d object "marker" that is used to position widgets in world space.
	-- This marker is positioned at the center of the sticker and faces outward along
	-- the normal of the clothing mesh at the given position.
	local marker = Instance.new("Part")
	marker.Name = "StickerPositionMarker"
	marker.Anchored = true
	marker.CanCollide = false
	marker.CanTouch = false
	marker.CanQuery = false
	marker.Size = Vector3.new(0.1, 0.1, 0.1)
	marker.CFrame = newCFrame
	marker.Transparency = 1
	marker.Color = Color3.new(0, 1, 0)
	marker.Parent = workspace

	local directionMarker = Instance.new("Part")
	directionMarker.Name = "StickerDirectionMarker"
	directionMarker.Anchored = true
	directionMarker.CanCollide = false
	directionMarker.CanTouch = false
	directionMarker.CanQuery = false
	directionMarker.Size = Vector3.new(0.1, 0.1, 0.1)
	directionMarker.CFrame = newCFrame
	directionMarker.Transparency = 1
	directionMarker.Color = Color3.new(1, 0, 0)
	directionMarker.Parent = marker

	return marker
end

function StickerTool:ApplySticker(imageAssetId)
	if self.stickerCounter >= Constants.MAX_STICKER_LAYERS then
		return
	end

	local meshPart, editableMesh, closestVertex = GetClosestMeshPart(self.modelInfo)

	local closestVertexPos = editableMesh:GetPosition(closestVertex)
	local vertexPositions = MeshUtils.GetVertexPositions(editableMesh)
	local meshScaleFactor = MeshUtils.GetScaleFactor(meshPart, vertexPositions).X

	-- Calculate marker pos and normal
	local faceID, _pointOnMesh, baryCoord = editableMesh:FindClosestPointOnSurface(closestVertexPos)
	local vertexNormal = Vector3.zero

	local vertexNormals = editableMesh:GetFaceNormals(faceID)
	vertexNormal = (baryCoord.x * editableMesh:GetNormal(vertexNormals[1]))
		+ (baryCoord.y * editableMesh:GetNormal(vertexNormals[2]))
		+ (baryCoord.z * editableMesh:GetNormal(vertexNormals[3]))

	local objectSpaceVector = closestVertexPos / meshScaleFactor -- This is a vector in object space that is correctly scaled but may not be correctly rotated.

	local offset = meshPart.CFrame:VectorToWorldSpace(objectSpaceVector)
	local worldSpaceNormal = meshPart.CFrame:VectorToWorldSpace(vertexNormal)
	local newCFrame = CFrame.new(meshPart.Position + offset, meshPart.Position + offset + worldSpaceNormal)

	local uvCoord = Vector2.zero
	local faceUVs = editableMesh:GetFaceUVs(faceID)
	uvCoord = (baryCoord.x * editableMesh:GetUV(faceUVs[1]))
		+ (baryCoord.y * editableMesh:GetUV(faceUVs[2]))
		+ (baryCoord.z * editableMesh:GetUV(faceUVs[3]))

	local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()

	local marker = CreatePositionMarker(newCFrame)

	local stickerData: StickerData = {
		textureId = imageAssetId,
		projectionDirection = workspace.CurrentCamera.CFrame.LookVector,

		texturePosition = uvCoord * textureInfo:GetTextureSize(meshPart),
		rotation = 0,
		scale = 1,

		isTiled = false,
		tilePadding = 0,

		targetMeshPart = meshPart,

		positionMarker = marker,
		positionMarkerOffset = meshPart.CFrame:ToObjectSpace(marker.CFrame),

		stickerLayerNumber = 1 + self.stickerCounter,
	}

	self.stickerCounter = self.stickerCounter + 1

	self.appliedStickers[#self.appliedStickers + 1] = stickerData

	self:RedrawSticker(stickerData, true)

	self.currentlySelectedSticker = #self.appliedStickers

	self.inputGui.Enabled = true
	self:RefreshHandleUI()
end

-- This function will only rotate/scale the sticker if it needs to.
-- Otherwise (if the sticker is merely being moved), we use the cached version of the already-scaled/rotated sticker.
function StickerTool:RedrawSticker(stickerData: StickerData, shouldFireServer: boolean)
	if stickerData.isTiled then
		local tiledStickerActionMetadata: ImageEditActions.TiledStickerActionMetadata = {
			textureId = stickerData.textureId,
			targetMeshPartName = stickerData.targetMeshPart.Name,
			stickerLayerNumber = stickerData.stickerLayerNumber,

			texturePosition = stickerData.texturePosition,

			rotation = stickerData.rotation,
			scale = stickerData.scale,

			tilePadding = stickerData.tilePadding,

			regionName = self.selectedRegionName,
		}

		local tiledStickerAction = Actions.CreateNewAction(Actions.ActionTypes.TiledSticker, tiledStickerActionMetadata)

		Actions.ExecuteAction(self.modelInfo, tiledStickerAction)

		if shouldFireServer then
			SendActionToServerEvent:FireServer(tiledStickerAction)
		else
			self.lastStickerAction = tiledStickerAction
		end

		local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
		textureInfo:UpdateOutputColorMap(stickerData.targetMeshPart)
	elseif self.UseProjectionSticker then
		local drawTextureSet = {}
		local projectorCFrame = stickerData.positionMarker.CFrame
		local projectorBrushSize = Vector3.new(0.5, 0.5, 0.5) * stickerData.scale

		local meshPartsToUpdate: { MeshPart } = {}

		for _, meshPart in self.modelInfo:GetMeshParts() do
			local collisionTest = Utils.TestOBBCollision(meshPart, projectorCFrame, projectorBrushSize)
			if collisionTest == true then
				local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()

				local originalTextureId: string = textureInfo:GetOriginalTextureId(meshPart)
				local firstDraw = drawTextureSet[originalTextureId] == nil
				if firstDraw then
					table.insert(meshPartsToUpdate, meshPart)
				end

				drawTextureSet[originalTextureId] = true

				local projectedStickerActionMetadata: ImageEditActions.ProjectedStickerActionMetadata = {
					textureId = stickerData.textureId,
					targetMeshPartName = meshPart.Name,
					stickerLayerNumber = stickerData.stickerLayerNumber,
					clearTexture = firstDraw,

					rotation = math.rad(stickerData.rotation),
					scale = stickerData.scale,

					position = meshPart.CFrame:PointToObjectSpace(stickerData.positionMarker.CFrame.Position),
					direction = meshPart.CFrame:VectorToObjectSpace(stickerData.projectionDirection),
				}

				local projectedStickerAction =
					Actions.CreateNewAction(Actions.ActionTypes.ProjectedSticker, projectedStickerActionMetadata)

				Actions.ExecuteAction(self.modelInfo, projectedStickerAction)

				if shouldFireServer then
					SendActionToServerEvent:FireServer(projectedStickerAction)
				else
					self.lastStickerAction = projectedStickerAction
				end
			end
		end

		local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
		for _, meshPart in meshPartsToUpdate do
			textureInfo:UpdateOutputColorMap(meshPart)
		end
	else
		local stickerActionMetadata: ImageEditActions.StickerActionMetadata = {
			textureId = stickerData.textureId,
			targetMeshPartName = stickerData.targetMeshPart.Name,
			stickerLayerNumber = stickerData.stickerLayerNumber,

			position = stickerData.texturePosition,

			rotation = stickerData.rotation,
			scale = stickerData.scale,
		}

		local stickerAction = Actions.CreateNewAction(Actions.ActionTypes.Sticker, stickerActionMetadata)

		Actions.ExecuteAction(self.modelInfo, stickerAction)

		if shouldFireServer then
			SendActionToServerEvent:FireServer(stickerAction)
		else
			self.lastStickerAction = stickerAction
		end

		local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
		textureInfo:UpdateOutputColorMap(stickerData.targetMeshPart)
	end
end

function StickerTool:OnPatternPaddingChanged(newPadding, bIsFinalInput)
	local stickerData: StickerData? = self.appliedStickers[self.currentlySelectedSticker]

	if stickerData then
		stickerData.tilePadding = newPadding
		self:RedrawSticker(stickerData, bIsFinalInput)
	end
end

function StickerTool:DeleteCurrentSticker()
	local selectedSticker: StickerData? = self.appliedStickers[self.currentlySelectedSticker]
	if selectedSticker == nil then
		return
	end

	local removeStickerActionMetadata: ImageEditActions.RemoveStickerActionMetadata = {
		targetMeshPartName = selectedSticker.targetMeshPart.Name,
		stickerLayerNumber = selectedSticker.stickerLayerNumber,
	}

	local removeStickerAction = Actions.CreateNewAction(Actions.ActionTypes.RemoveSticker, removeStickerActionMetadata)
	Actions.ExecuteAction(self.modelInfo, removeStickerAction)

	local textureInfo: TextureInfo.TextureInfoClass = self.modelInfo:GetTextureInfo()
	textureInfo:UpdateOutputColorMap(selectedSticker.targetMeshPart)

	SendActionToServerEvent:FireServer(removeStickerAction)

	table.remove(self.appliedStickers, self.currentlySelectedSticker)

	self.currentlySelectedSticker = #self.appliedStickers
	self.stickerCounter = self.stickerCounter - 1
	self:RefreshHandleUI()
end

-- Returns whether or not the current sticker is tiled after toggling.
function StickerTool:SetPatterned(isPatterned)
	local selectedSticker: StickerData? = self.appliedStickers[self.currentlySelectedSticker]
	if selectedSticker == nil then
		return
	end

	selectedSticker.isTiled = isPatterned
	self:RedrawSticker(selectedSticker, true)
end

function StickerTool:SetSelectedRegion(regionName: string)
	if regionName and string.find(regionName, "Model") then
		self.selectedRegionName = nil
	end

	self.selectedRegionName = regionName

	self:SafelyRedrawSticker()
end

function StickerTool:SafelyRedrawSticker()
	local selectedSticker: StickerData? = self.appliedStickers[self.currentlySelectedSticker]
	if selectedSticker ~= nil then
		self:RedrawSticker(selectedSticker, true)
	end
end

-- Returns true if the currently selected sticker is patterned, false otherwise
function StickerTool:IsPatterned()
	local selectedSticker: StickerData? = self.appliedStickers[self.currentlySelectedSticker]
	if selectedSticker == nil then
		return false
	end

	return selectedSticker.isTiled
end

function StickerTool:HasAppliedStickers()
	return #self.appliedStickers > 0
end

function StickerTool:Enable()
	self.inputGui.Enabled = true
	if #self.appliedStickers > 0 then
		self.currentlySelectedSticker = #self.appliedStickers
	end
	self:RefreshHandleUI()
end

function StickerTool:Disable()
	self.inputGui.Enabled = false
	self.currentlySelectedSticker = 0
end

function StickerTool:Destroy()
	self.modelInfo:SaveAppliedStickers(self.appliedStickers)
	self.inputGui:Destroy()
	self.currentlySelectedSticker = 0

	for _, connection in self.connections do
		connection:Disconnect()
	end
	self.connections = {}
end

return StickerTool
