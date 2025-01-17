local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Actions = require(Modules:WaitForChild("Actions"))
local ModelInfo = require(Modules:WaitForChild("ModelInfo"))
local Utils = require(Modules:WaitForChild("Utils"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshInfo = require(MeshManipulation:WaitForChild("MeshInfo"))
local MeshEditActions = require(MeshManipulation:WaitForChild("MeshEditActions"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")

local MeshEditingWidgetManager = {}
MeshEditingWidgetManager.__index = MeshEditingWidgetManager

type WidgetController = {
	widgetData: MeshInfo.WidgetData,

	widgetUI: ImageButton,

	isActive: boolean,
	controlUIMap: {
		[MeshInfo.WidgetControl]: { GuiObject },
	},
}

function MeshEditingWidgetManager.new(modelInfo: ModelInfo.ModelInfoClass, modelDisplay, inputManager, cameraManager)
	local self = {}
	setmetatable(self, MeshEditingWidgetManager)

	self.modelInfo = modelInfo
	self.modelDisplay = modelDisplay
	self.inputManager = inputManager
	self.cameraManager = cameraManager

	self.surfaceGuiPart = Instance.new("Part")
	self.surfaceGuiPart.Parent = workspace
	self.surfaceGuiPart.Transparency = 1
	self.surfaceGuiPart.Anchored = true

	local camera = workspace.CurrentCamera

	self.surfaceGui = Instance.new("SurfaceGui")
	self.surfaceGui.Name = "MeshEditingControls"
	self.surfaceGui.ResetOnSpawn = false
	self.surfaceGui.Adornee = self.surfaceGuiPart
	self.surfaceGui.CanvasSize = camera.ViewportSize
	self.surfaceGui.AlwaysOnTop = true
	self.surfaceGui.Parent = PlayerGui
	-- Ensure part is anchored and the SurfaceGui is on the desired face
	local surfaceGuiConnection = RunService.RenderStepped:Connect(function()
		local model = self.modelDisplay:GetModel()
		local cameraCFrame = camera:GetRenderCFrame()
		local distance = (cameraCFrame.Position - model.PrimaryPart.Position).Magnitude
			- math.max(model:GetExtentsSize().X, model:GetExtentsSize().Z) / 2
		local viewportSize = camera.ViewportSize
		local fov = math.rad(camera.FieldOfView)
		local aspect = viewportSize.X / viewportSize.Y
		camera.HeadLocked = true

		-- Calculate the size needed to fill the screen at 'distance'
		local height = 2 * distance * math.tan(fov / 2)
		local width = height * aspect

		self.surfaceGuiPart.Size = Vector3.new(width, height, 0.1)
		self.surfaceGui.CanvasSize = camera.ViewportSize

		-- Position the part
		local newCFrame = cameraCFrame * CFrame.new(0, 0, -distance)
		-- Make the part face the camera
		self.surfaceGuiPart.CFrame = CFrame.lookAt(newCFrame.Position, cameraCFrame.Position + cameraCFrame.LookVector)
	end)

	-- Add widgets to the player's UI so they can drag UI elements around to modify meshes
	self.widgets = {} :: { [string]: WidgetController }
	self.draggingWidget = nil
	self.lastWidgetAction = nil
	self.widgetUnderMouse = nil

	self.connections = {}

	table.insert(self.connections, surfaceGuiConnection)

	self.connections["inputChanged"] = UserInputService.InputChanged:Connect(function(input)
		if
			self.draggingWidget ~= nil
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
				or (Utils.isVirtualCursor(input.UserInputType) and input.KeyCode == Enum.KeyCode.Thumbstick1)
			)
		then
			self:DragWidget(self.draggingWidget, input)
		end
	end)

	self.connections["inputEnded"] = UserInputService.InputEnded:Connect(function(_input)
		if self.draggingWidget then
			if self.lastWidgetAction then
				SendActionToServerEvent:FireServer(self.lastWidgetAction)
				self.lastWidgetAction = nil
			end

			self.draggingWidget = nil

			local updateAttachmentsPositionsActionMetadata: MeshEditActions.UpdateAttachmentsPositionsActionMetadata =
				{}

			local updateWidgetPositionAction = Actions.CreateNewAction(
				Actions.ActionTypes.UpdateAttachmentsPositions,
				updateAttachmentsPositionsActionMetadata
			)

			Actions.ExecuteAction(self.modelInfo, updateWidgetPositionAction)

			SendActionToServerEvent:FireServer(updateWidgetPositionAction)
		end
	end)

	return self
end

local function CreateWidgetUI(widgetData: MeshInfo.WidgetData, surfaceGui: SurfaceGui)
	local widget = Instance.new("ImageButton")
	widget.Size = UDim2.fromOffset(30, 30)
	widget.AnchorPoint = Vector2.new(0.5, 0.5)
	widget.Transparency = 0.5
	widget.Image = "rbxassetid://14841616292"
	widget.BackgroundTransparency = 1
	widget.ImageColor3 = Color3.fromHex("262626")
	widget.ImageTransparency = 0.5
	widget.Name = widgetData.name
	widget.Parent = surfaceGui

	local circle = Instance.new("ImageLabel")
	circle.Size = UDim2.fromOffset(20, 20)
	circle.AnchorPoint = Vector2.new(0.5, 0.5)
	circle.Transparency = 0.2
	circle.Image = "rbxassetid://14841616292"
	circle.BackgroundTransparency = 1
	circle.ImageTransparency = 0.1
	circle.Name = "Circle"
	circle.Position = UDim2.fromScale(0.5, 0.5)
	circle.Parent = widget

	local controlUIMap = {}

	for _, control: MeshInfo.WidgetControl in widgetData.controls do
		if control.controlType == "Line" then
			local lineFrame = Instance.new("Frame")
			lineFrame.BorderSizePixel = 0
			lineFrame.BackgroundColor3 = Color3.new(1, 1, 1)
			lineFrame.BackgroundTransparency = 0.8
			lineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
			lineFrame.Name = "LineControl" .. control.view
			lineFrame.ZIndex = 0

			lineFrame.Parent = widget.Parent

			controlUIMap[control] = { lineFrame }
		elseif control.controlType == "Plane" then
			local controlUI = {}
			for _i = 1, 4 do
				local lineFrame = Instance.new("Frame")
				lineFrame.BorderSizePixel = 0
				lineFrame.BackgroundColor3 = Color3.new(1, 1, 1)
				lineFrame.BackgroundTransparency = 0.8
				lineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
				lineFrame.Name = "PlaneControl" .. control.view
				lineFrame.ZIndex = 0

				lineFrame.Parent = widget.Parent
				controlUI[#controlUI + 1] = lineFrame
			end

			controlUIMap[control] = controlUI
		end
	end

	return widget, controlUIMap
end

function MeshEditingWidgetManager:BindRenderStepped()
	if self.connections["stepped"] then
		return
	end

	-- Every frame, position each widget in the correct place
	self.connections["stepped"] = RunService.Stepped:Connect(function(_currentTime, _deltaTime)
		for _, widgetController: WidgetController in pairs(self.widgets) do
			if self.draggingWidget == nil then
				if self:IsWidgetVisibleInView(widgetController, self.modelDisplay:GetCurrentView()) then
					widgetController.widgetUI.Visible = true
					local initialCFrame = widgetController.widgetData.meshPart.CFrame
					local widgetPos = initialCFrame:PointToWorldSpace(widgetController.widgetData.position)
					local vector, _onScreen = workspace.CurrentCamera:WorldToScreenPoint(widgetPos)
					local guiInset = GuiService:GetGuiInset()
					widgetController.widgetUI.Position = UDim2.fromOffset(vector.X, vector.Y + guiInset.Y)
					widgetController.widgetUI.Visible = widgetController.isActive

					local widgetCircle = widgetController.widgetUI:FindFirstChild("Circle")
					widgetCircle.ImageColor3 = Color3.new(1, 1, 1)
					widgetController.widgetUI.ImageTransparency = 0.5
				else
					widgetController.widgetUI.Visible = false
				end
			else
				if widgetController == self.draggingWidget then
					widgetController.widgetUI.Visible = true
					local initialCFrame = widgetController.widgetData.meshPart.CFrame
					local widgetPos = initialCFrame:PointToWorldSpace(widgetController.widgetData.position)
					local vector, _onScreen = workspace.CurrentCamera:WorldToScreenPoint(widgetPos)
					local guiInset = GuiService:GetGuiInset()
					widgetController.widgetUI.Position = UDim2.fromOffset(vector.X, vector.Y + guiInset.Y)

					local widgetCircle = widgetController.widgetUI:FindFirstChild("Circle")
					widgetCircle.ImageColor3 = Color3.fromHex("3C64FA")
					widgetController.widgetUI.ImageTransparency = 1
				else
					local widgetCircle = widgetController.widgetUI:FindFirstChild("Circle")
					widgetCircle.ImageColor3 = Color3.new(1, 1, 1)
					widgetController.widgetUI.ImageTransparency = 0.5
					widgetController.widgetUI.Visible = false
				end
			end

			-- Render control boundaries (axes, planes, etc) for the dragged widget so the user knows where the min and max are
			for _, control: MeshInfo.WidgetControl in pairs(widgetController.widgetData.controls) do
				local controlUI = widgetController.controlUIMap[control]

				if widgetController ~= self.draggingWidget or control.view ~= self.modelDisplay:GetCurrentView() then
					if controlUI then
						for _, uiElement in pairs(controlUI) do
							uiElement.Visible = false
						end
					end

					continue
				end

				for _, uiElement in pairs(controlUI) do
					uiElement.Visible = true
				end
				if control.controlType == "Line" then
					local p1 = control.controlP1
					local p2 = control.controlP2
					local lineLength = (p1 - p2).Magnitude
					local frame = controlUI[1]

					local ray = Ray.new(p1, (p2 - p1).Unit)
					-- Snap this point onto the line
					local closestPointOnRay = ray:ClosestPoint(widgetController.widgetData.position)

					-- If this is off the end of the ray, snap it to the end of the ray
					local distance = (ray.Origin - closestPointOnRay).Magnitude
					if distance > lineLength then
						closestPointOnRay = ray.Origin + ray.Direction * lineLength
					end

					-- Move the line to the control point
					local diff = widgetController.widgetData.position - closestPointOnRay
					p1 = p1 + diff
					p2 = p2 + diff

					-- Convert object-space coords to world space
					local initialCFrame = widgetController.widgetData.meshPart.CFrame
					p1 = initialCFrame:PointToWorldSpace(p1)
					p2 = initialCFrame:PointToWorldSpace(p2)

					-- Draw the line between the two points
					local screenP1 = workspace.CurrentCamera:WorldToScreenPoint(p1)
					local screenP2 = workspace.CurrentCamera:WorldToScreenPoint(p2)
					self:DrawLineBetweenPoints(frame, screenP1, screenP2)
				elseif control.controlType == "Plane" then
					local planeControl = control :: MeshInfo.PlaneWidgetControl

					local initialCFrame = widgetController.widgetData.meshPart.CFrame
					local p1 = initialCFrame:PointToWorldSpace(planeControl.controlP1)
					local p2 = initialCFrame:PointToWorldSpace(planeControl.controlP2)
					local p3 = initialCFrame:PointToWorldSpace(planeControl.controlP3)
					local p4 = initialCFrame:PointToWorldSpace(planeControl.controlP4)

					local planeBoundingLines = controlUI

					local screenP1 = workspace.CurrentCamera:WorldToScreenPoint(p1)
					local screenP2 = workspace.CurrentCamera:WorldToScreenPoint(p2)
					local screenP3 = workspace.CurrentCamera:WorldToScreenPoint(p3)
					local screenP4 = workspace.CurrentCamera:WorldToScreenPoint(p4)

					self:DrawLineBetweenPoints(planeBoundingLines[1], screenP1, screenP2)
					self:DrawLineBetweenPoints(planeBoundingLines[2], screenP2, screenP3)
					self:DrawLineBetweenPoints(planeBoundingLines[3], screenP3, screenP4)
					self:DrawLineBetweenPoints(planeBoundingLines[4], screenP4, screenP1)
				end
			end
		end
	end)
end

-- Details for the widgets are stored in the MeshEditControlGroups folder in ReplicatedStorage.
-- They are represented as parts to make the bounds easier to visualize.
-- This function sets up the widgets for a given control group (face, head, or body).
function MeshEditingWidgetManager:SetupWidgets(controlGroupName)
	-- Hide any existing mesh edit controls
	for _, widgetController: WidgetController in self.widgets do
		widgetController.isActive = false
	end

	local meshInfo: MeshInfo.MeshInfoClass = self.modelInfo:GetMeshInfo()

	local controlGroup: MeshInfo.ControlGroup = meshInfo:GetControlGroup(controlGroupName)

	local affectedMeshParts = {}

	for widgetName, widgetData: MeshInfo.WidgetData in controlGroup.widgets do
		local widgetController: WidgetController? = self.widgets[widgetName]
		if widgetController then
			table.insert(affectedMeshParts, widgetController.widgetData.meshPart)
			widgetController.isActive = true
			continue
		end

		if widgetData.isMirror then
			continue
		end

		local widget, controlUIMap = CreateWidgetUI(widgetData, self.surfaceGui)

		widgetController = {
			widgetData = widgetData,
			isActive = true,

			widgetUI = widget,

			controlUIMap = controlUIMap,
		}

		widget.MouseButton1Down:Connect(function()
			if self.inputManager:TryGrabLock(self) == false then
				return
			end

			self.draggingWidget = widgetController
		end)

		widget.MouseEnter:Connect(function()
			self.widgetUnderMouse = widget
		end)

		widget.MouseLeave:Connect(function()
			if self.widgetUnderMouse == widget then
				self.widgetUnderMouse = nil
			end
		end)

		self.widgets[widgetName] = widgetController

		table.insert(affectedMeshParts, widgetData.meshPart)
	end

	-- Calculate the "center" of the affected mesh parts
	local focusPoint = Vector3.zero
	for _, meshPart in pairs(affectedMeshParts) do
		focusPoint = focusPoint + meshPart.CFrame.Position
	end
	focusPoint = focusPoint / #affectedMeshParts

	self.cameraManager:FocusCameraOnParts(affectedMeshParts, focusPoint)

	self:BindRenderStepped()
end

function MeshEditingWidgetManager:IsWidgetVisibleInView(widgetController: WidgetController, viewName)
	for _, control in widgetController.widgetData.controls do
		if control.view == viewName then
			return true
		end
	end

	return false
end

function MeshEditingWidgetManager:DrawLineBetweenPoints(frame, p1, p2)
	local guiInset = GuiService:GetGuiInset()
	local screenDiff = p1 - p2
	local screenMidpoint = (p1 + p2) / 2
	frame.Position = UDim2.fromOffset(screenMidpoint.X, screenMidpoint.Y + guiInset.Y)
	frame.Rotation = math.atan2(screenDiff.Y, screenDiff.X) * (180 / math.pi)
	frame.Size = UDim2.fromOffset((screenDiff.X ^ 2 + screenDiff.Y ^ 2) ^ 0.5, 2)
end

function MeshEditingWidgetManager:OnWidgetMoved(widgetData: MeshInfo.WidgetData, newPosition: Vector3)
	local updateWidgetPositionActionMetadata: MeshEditActions.UpdateWidgetPositionActionMetadata = {
		widgetName = widgetData.name,
		newPosition = newPosition,
	}

	local widgetControl = self:GetActiveControlForWidget(widgetData)
	if widgetControl ~= nil and widgetControl.controlType == "Line" then
		-- Calculate how far the widget has moved along the line
		local lineDirection = (widgetControl.controlP2 - widgetControl.controlP1)
		local closestLinePoint =
			Utils.GetClosestPointOn3dLineSegment(widgetData.position, widgetControl.controlP1, widgetControl.controlP2)
		local controlLinearProgress = (closestLinePoint - widgetControl.controlP1).Magnitude / lineDirection.Magnitude

		updateWidgetPositionActionMetadata.newLinearProgress = controlLinearProgress

		local activeControlIndex = nil
		for i, control in pairs(widgetData.controls) do
			if control == widgetControl then
				activeControlIndex = i
				break
			end
		end

		updateWidgetPositionActionMetadata.newActiveControl = activeControlIndex
	end

	local updateWidgetPositionAction =
		Actions.CreateNewAction(Actions.ActionTypes.UpdateWidgetPosition, updateWidgetPositionActionMetadata)

	Actions.ExecuteAction(self.modelInfo, updateWidgetPositionAction)

	self.lastWidgetAction = updateWidgetPositionAction
end

function MeshEditingWidgetManager:GetWidgetDataForPart(partName: string): WidgetController?
	for _, widgetController: WidgetController in pairs(self.widgets) do
		if widgetController.widgetData.meshPart.Name == partName then
			return widgetController
		end
	end

	return nil
end

function MeshEditingWidgetManager:GetActiveControlForWidget(widgetData: MeshInfo.WidgetData): MeshInfo.WidgetControl
	local currentView = self.modelDisplay:GetCurrentView()
	local outOfViewControl = nil
	for _, control in pairs(widgetData.controls) do
		if control.view == currentView then
			return control
		end

		outOfViewControl = control
	end

	return outOfViewControl
end

local function SnapWorldPointToControl(point: Vector3, control: MeshInfo.WidgetControl)
	if control.controlType == "Line" then
		-- Setup a world-space ray to represent this line
		local objectSpaceP1 = control.controlP1
		local objectSpaceP2 = control.controlP2
		local initialCFrame = control.meshPart.CFrame --self.initialCFrames[control.meshPart.Name]
		local worldP1 = initialCFrame:PointToWorldSpace(objectSpaceP1)
		local worldP2 = initialCFrame:PointToWorldSpace(objectSpaceP2)
		local worldRay = Ray.new(worldP1, (worldP2 - worldP1).Unit)
		local lineLength = (worldP2 - worldP1).Magnitude

		-- Snap this point onto the line
		local closestPointOnRay = worldRay:ClosestPoint(point)

		-- If this is off the end of the ray, snap it to the end of the ray
		local distance = (worldRay.Origin - closestPointOnRay).Magnitude
		if distance > lineLength then
			closestPointOnRay = worldRay.Origin + worldRay.Direction * lineLength
		end

		return closestPointOnRay
	elseif control.controlType == "Plane" then
		-- Convert the plane to world-space
		local planeControl = control :: MeshInfo.PlaneWidgetControl

		local objectSpaceNormal = planeControl.normal
		local initialCFrame = control.meshPart.CFrame --self.initialCFrames[control.meshPart.Name]
		local worldSpaceNormal = initialCFrame:VectorToWorldSpace(objectSpaceNormal)

		local polygonVerts = {
			initialCFrame:PointToWorldSpace(planeControl.controlP1),
			initialCFrame:PointToWorldSpace(planeControl.controlP2),
			initialCFrame:PointToWorldSpace(planeControl.controlP3),
			initialCFrame:PointToWorldSpace(planeControl.controlP4),
		}

		-- Calculate the nearest point in the control area
		local closestPoint = Utils.GetClosestPointIn3dPolygon(worldSpaceNormal, point, polygonVerts)

		return closestPoint
	end

	return point
end

function MeshEditingWidgetManager:DragWidget(widgetController: WidgetController, input)
	local position = input.Position
	if self.prevMousePos ~= Vector2.zero then
		local mouseHitPoint = LocalPlayer:GetMouse().Hit.Position
		local direction = (mouseHitPoint - workspace.CurrentCamera.CFrame.Position).Unit
		local widgetWorldPos =
			widgetController.widgetData.meshPart.CFrame:PointToWorldSpace(widgetController.widgetData.position)
		local depth = (workspace.CurrentCamera.CFrame.Position - widgetWorldPos).Magnitude
		local worldPoint = workspace.CurrentCamera.CFrame.Position + direction * depth

		-- If this widget has control constraints (eg: it must adhere to a line), then apply those constraints now
		local activeControl = self:GetActiveControlForWidget(widgetController.widgetData)
		if activeControl then
			local snappedPoint = SnapWorldPointToControl(worldPoint, activeControl)
			worldPoint = snappedPoint
		end

		local newPosition = widgetController.widgetData.meshPart.CFrame:PointToObjectSpace(worldPoint)

		self:OnWidgetMoved(widgetController.widgetData, newPosition)
	end

	self.prevMousePos = position
end

function MeshEditingWidgetManager:IsShowingWidgets()
	for _, widgetController: WidgetController in pairs(self.widgets) do
		if widgetController.isActive == true then
			return true
		end
	end

	return false
end

function MeshEditingWidgetManager:HideWidgets()
	for _, widgetController: WidgetController in pairs(self.widgets) do
		widgetController.isActive = false
	end
end

function MeshEditingWidgetManager:Destroy()
	self.surfaceGuiPart:Destroy()

	for _, connection in self.connections do
		connection:Disconnect()
	end
end

return MeshEditingWidgetManager
