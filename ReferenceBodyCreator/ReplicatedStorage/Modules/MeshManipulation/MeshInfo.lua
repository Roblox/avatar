local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Config = Modules:WaitForChild("Config")
local BlanksData = require(Config:WaitForChild("BlanksData"))
local Constants = require(Config:WaitForChild("Constants"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MeshUtils = require(MeshManipulation:WaitForChild("MeshUtils"))
local MeshTypes = require(MeshManipulation:WaitForChild("MeshTypes"))

export type CageInfo = {
	cageEditableMesh: EditableMesh,
	wrapDeformer: WrapDeformer,

	deformedEditableMeshDirty: boolean,
	deformedEditableMesh: EditableMesh,

	-- Map of vertex id to initial vertex position
	initialVertexPositionsMap: {
		[number]: Vector3,
	},

	initialSize: Vector3,
}

export type MeshInfo = {
	meshPart: MeshPart,

	-- If the mesh part is deformable (has a wrap deformer), cageInfo will exist
	cageInfo: CageInfo?,

	-- If the mesh part is rigid (no wrap deformer), editableMesh will exist
	editableMesh: EditableMesh?,

	initialCFrame: CFrame,

	-- Scale of the editable mesh from MeshPart size
	scaleFactor: Vector3,
}

type ModelMeshInfo = {
	[MeshPart]: MeshInfo,
}

local function SetupBodyPart(meshPart: MeshPart, wrapTarget: WrapTarget): MeshInfo
	-- Create an EditableMesh from the MeshPart
	local wrapDeformer = meshPart:FindFirstChildWhichIsA("WrapDeformer")
	if not wrapDeformer then
		wrapDeformer = Instance.new("WrapDeformer")
		wrapDeformer.Parent = meshPart
	end

	local cageEditableMesh: EditableMesh =
		AssetService:CreateEditableMeshAsync(Content.fromUri(wrapTarget.CageMeshId), {
			FixedSize = true,
		})
	wrapDeformer:SetCageMeshContent(Content.fromObject(cageEditableMesh))

	local editableMesh: EditableMesh = wrapDeformer:CreateEditableMeshAsync()

	local initialCageVertexPositions = MeshUtils.GetVertexPositionsMap(cageEditableMesh)
	local min, max = MeshUtils.GetVertexBounds(initialCageVertexPositions)
	local initialCageSize = max - min

	local initialVertexPositions = MeshUtils.GetVertexPositions(editableMesh)
	local scaleFactor = MeshUtils.GetScaleFactor(meshPart, initialVertexPositions)

	local meshInfo: MeshInfo = {
		meshPart = meshPart,

		cageInfo = {
			cageEditableMesh = cageEditableMesh,
			wrapDeformer = wrapDeformer,

			-- Map of vertex id to initial vertex position
			initialVertexPositionsMap = initialCageVertexPositions,
			initialSize = initialCageSize,

			deformedEditableMeshDirty = false,
			deformedEditableMesh = editableMesh,
		},

		initialCFrame = meshPart.CFrame,
		scaleFactor = scaleFactor,
	}

	return meshInfo
end

local function SetupRigidMesh(meshPart: MeshPart): MeshInfo
	local editableMesh = AssetService:CreateEditableMeshAsync(Content.fromUri(meshPart.MeshId), {
		FixedSize = true,
	})
	local newMeshPart = AssetService:CreateMeshPartAsync(Content.fromObject(editableMesh))

	newMeshPart.Size = meshPart.Size
	newMeshPart.CFrame = meshPart.CFrame
	newMeshPart.TextureContent = meshPart.TextureContent
	meshPart:ApplyMesh(newMeshPart)

	local initialVertexPositions = MeshUtils.GetVertexPositions(editableMesh)
	local scaleFactor = MeshUtils.GetScaleFactor(meshPart, initialVertexPositions)

	local meshInfo: MeshInfo = {
		meshPart = meshPart,
		editableMesh = editableMesh,
		initialCFrame = meshPart.CFrame,
		scaleFactor = scaleFactor,
	}

	return meshInfo
end

local function SetupModelMeshes(model: Model): ModelMeshInfo
	local newModelInfo: ModelMeshInfo = {}

	for _, descendant in model:GetDescendants() do
		if not descendant:IsA("MeshPart") then
			continue
		end

		if descendant.Name == "PrimaryPart" then
			continue
		end

		local wrapTarget = descendant:FindFirstChildOfClass("WrapTarget")
		if wrapTarget then
			newModelInfo[descendant] = SetupBodyPart(descendant, wrapTarget)
		else
			newModelInfo[descendant] = SetupRigidMesh(descendant)
		end
	end

	return newModelInfo
end

export type LineWidgetControl = {
	view: string,
	controlType: "Line",
	meshPart: MeshPart,

	controlP1: Vector3,
	controlP2: Vector3,

	startLinearProgress: number,
	linearProgress: number,
}

export type PlaneWidgetControl = {
	view: string,
	controlType: "Plane",
	meshPart: MeshPart,

	controlP1: Vector3,
	controlP2: Vector3,
	controlP3: Vector3,
	controlP4: Vector3,

	normal: Vector3,
}

export type WidgetControl = LineWidgetControl | PlaneWidgetControl

export type WidgetData = {
	name: string,
	widgetType: string,

	startPosition: Vector3,
	position: Vector3,
	radius: number,
	isSymmetrical: boolean,

	meshPart: MeshPart,

	mirroredPointName: string?,
	mirroredWidget: WidgetData?,

	-- If this widget is a mirrored copy of another widget
	isMirror: boolean?,

	deformsPartNames: { string },

	axisStart: Ray?,
	axisEnd: Vector3?,

	meshSpaceAxisStart: Ray?,
	meshSpaceAxisEnd: Vector3?,

	controls: { WidgetControl },
	activeControl: WidgetControl?,
}

export type ControlGroup = {
	name: string,

	widgets: {
		[string]: WidgetData,
	},
}

export type WidgetControlGroupMap = {
	[string]: ControlGroup,
}

local function BuildWidgetControl(
	controlFolder: Folder,
	controlMeshPart: MeshPart,
	controlPoint: Part,
	worldMeshPart: MeshPart,
	startPosition: Vector3
): WidgetControl
	local controlTypeValue = controlFolder:FindFirstChild("ControlType") -- StringValue
	local controlType = controlTypeValue.Value

	if controlType == Constants.CONTROL_TYPE_LINE then
		local p1 = controlFolder:FindFirstChild("P1")
		local p2 = controlFolder:FindFirstChild("P2")

		local control: LineWidgetControl = {
			view = controlFolder.Name,
			controlType = Constants.CONTROL_TYPE_LINE,
			meshPart = worldMeshPart,

			controlP1 = controlMeshPart.CFrame:PointToObjectSpace(p1.CFrame.Position),
			controlP2 = controlMeshPart.CFrame:PointToObjectSpace(p2.CFrame.Position),

			startLinearProgress = 0,
			linearProgress = 0,
		}

		-- Record the "starting progress" so that we can compare it to the current progress.
		-- EG: The widget starts at 50% along the line, and the user can move it to 0% or 100% along the line to shrink or stretch the mesh.
		-- Or, the widget starts at 0% and the user can move it to 100% to stretch the mesh.
		local lineDirection = (control.controlP2 - control.controlP1)
		control.startLinearProgress = (startPosition - control.controlP1).Magnitude / lineDirection.Magnitude
		control.linearProgress = control.startLinearProgress

		return control
	elseif controlType == Constants.CONTROL_TYPE_PLANE then
		local p1 = controlFolder:FindFirstChild("P1")
		local p2 = controlFolder:FindFirstChild("P2")
		local p3 = controlFolder:FindFirstChild("P3")
		local p4 = controlFolder:FindFirstChild("P4")

		local normalObj = controlFolder:FindFirstChild("Normal")

		local control: PlaneWidgetControl = {
			view = controlFolder.Name,
			controlType = Constants.CONTROL_TYPE_PLANE,
			meshPart = worldMeshPart,

			controlP1 = controlMeshPart.CFrame:PointToObjectSpace(p1.CFrame.Position),
			controlP2 = controlMeshPart.CFrame:PointToObjectSpace(p2.CFrame.Position),
			controlP3 = controlMeshPart.CFrame:PointToObjectSpace(p3.CFrame.Position),
			controlP4 = controlMeshPart.CFrame:PointToObjectSpace(p4.CFrame.Position),

			normal = (normalObj.CFrame.Position - controlPoint.CFrame.Position).Unit,
		}

		return control
	end

	error("Invalid control type " .. controlType)
end

local function GetControlPointValue(controlPoint: Part, valueName: string, defaultValue: any)
	local value = controlPoint:FindFirstChild(valueName)
	if value == nil then
		return defaultValue
	end

	return value.Value
end

local function BuildWidgetData(
	controlMeshPart: MeshPart,
	controlPoint: Part,
	worldMeshPart: MeshPart,
	modelMeshInfo: ModelMeshInfo
): WidgetData
	-- There is no existing widget for this control point. Let's set one up.
	local objectSpaceCFrame = controlMeshPart.CFrame:ToObjectSpace(controlPoint.CFrame)

	local widgetData: WidgetData = {
		name = controlPoint.Name,
		widgetType = GetControlPointValue(controlPoint, "WidgetType", Constants.WIDGET_TYPE_SPHERE),

		startPosition = objectSpaceCFrame.Position,
		position = objectSpaceCFrame.Position,
		radius = GetControlPointValue(controlPoint, "Radius", 1),
		isSymmetrical = GetControlPointValue(controlPoint, "IsSymmetrical", false),

		meshPart = worldMeshPart,

		mirroredPointName = GetControlPointValue(controlPoint, "MirroredPoint", nil),
		mirroredWidget = nil,

		deformsPartNames = { worldMeshPart.Name },

		axisStart = nil,
		axisEnd = nil,

		meshSpaceAxisStart = nil,
		meshSpaceAxisEnd = nil,

		controls = {},
	}

	local deformsAdditionalPartsFolder = controlPoint:FindFirstChild("DeformsAdditionalParts")
	if deformsAdditionalPartsFolder ~= nil then
		for _, child in pairs(deformsAdditionalPartsFolder:GetChildren()) do
			if child:IsA("StringValue") then
				widgetData.deformsPartNames[#widgetData.deformsPartNames + 1] = child.Value
			end
		end
	end

	-- Some widgets define an axis in addition to an origin point
	local rayObject = controlPoint:FindFirstChild("Axis")
	local axisEndObject = controlPoint:FindFirstChild("AxisEnd")
	if rayObject ~= nil then
		local objectSpaceRayCFrame = controlMeshPart.CFrame:ToObjectSpace(rayObject.CFrame)
		widgetData.axisStart = Ray.new(objectSpaceRayCFrame.Position, objectSpaceRayCFrame.lookVector)
		if axisEndObject ~= nil then
			widgetData.axisEnd = controlMeshPart.CFrame:ToObjectSpace(axisEndObject.CFrame).Position
		end
	end

	-- Widgets can have different controls for different views
	-- EG: A chin control might be only draggable along the y-axis in front view, and along the x-axis in side view
	for _, controlChild in pairs(controlPoint:GetChildren()) do
		if not controlChild:IsA("Folder") then
			continue
		end

		local control =
			BuildWidgetControl(controlChild, controlMeshPart, controlPoint, worldMeshPart, widgetData.startPosition)
		table.insert(widgetData.controls, control)
	end

	-- Calculate the dynamic mesh space axis for the widget
	-- This is useful later on when deforming vertices
	local meshInfo: MeshInfo = modelMeshInfo[widgetData.meshPart]
	if
		widgetData.widgetType == Constants.WIDGET_TYPE_CYLINDER
		or widgetData.widgetType == Constants.WIDGET_TYPE_AXIS_STRETCH
	then
		assert(widgetData.axisStart ~= nil, "Cylinder and AxisStretch widgets must have an axis defined")
		assert(meshInfo.cageInfo, "CageInfo must exist for deformable mesh parts")

		widgetData.meshSpaceAxisStart = Ray.new(
			MeshUtils.LocalSpaceToEditableMeshSpace(
				widgetData.axisStart.Origin,
				worldMeshPart,
				meshInfo.cageInfo.initialVertexPositionsMap
			),
			widgetData.axisStart.Direction
		)
	elseif widgetData.widgetType == Constants.WIDGET_TYPE_MUSCLE then
		assert(widgetData.axisStart ~= nil, "Muscle widgets must have an axis defined")
		assert(meshInfo.cageInfo, "CageInfo must exist for deformable mesh parts")

		widgetData.meshSpaceAxisStart = Ray.new(
			MeshUtils.LocalSpaceToEditableMeshSpace(
				widgetData.axisStart.Origin,
				worldMeshPart,
				meshInfo.cageInfo.initialVertexPositionsMap
			),
			widgetData.axisStart.Direction
		)
		widgetData.meshSpaceAxisEnd = MeshUtils.LocalSpaceToEditableMeshSpace(
			widgetData.axisEnd,
			worldMeshPart,
			meshInfo.cageInfo.initialVertexPositionsMap
		)
	end

	return widgetData
end

local function CreateMirroredControls(currentControls: { WidgetControl }, targetMeshPart: MeshPart): { WidgetControl }
	local mirroredControls: { WidgetControl } = {}

	for _, widgetControl: WidgetControl in pairs(currentControls) do
		local mirroredWidgetControl = {}
		mirroredWidgetControl.view = widgetControl.view
		mirroredWidgetControl.controlType = widgetControl.controlType
		mirroredWidgetControl.meshPart = targetMeshPart
		mirroredWidgetControl.controlP1 = widgetControl.controlP1 * Vector3.new(-1, 1, 1)
		mirroredWidgetControl.controlP2 = widgetControl.controlP2 * Vector3.new(-1, 1, 1)

		if widgetControl.controlType == "Line" then
			mirroredWidgetControl.startLinearProgress = widgetControl.startLinearProgress
			mirroredWidgetControl.linearProgress = widgetControl.linearProgress
		elseif widgetControl.controlType == "Plane" then
			mirroredWidgetControl.controlP3 = widgetControl.controlP3 * Vector3.new(-1, 1, 1)
			mirroredWidgetControl.controlP4 = widgetControl.controlP4 * Vector3.new(-1, 1, 1)
			mirroredWidgetControl.normal = widgetControl.normal * Vector3.new(-1, 1, 1)
		end

		table.insert(mirroredControls, mirroredWidgetControl)
	end

	return mirroredControls
end

local function MirrorWidgetAxisProperties(
	mirroredWidget: WidgetData,
	widgetData: WidgetData,
	modelMeshInfo: ModelMeshInfo
)
	mirroredWidget.widgetType = widgetData.widgetType
	if widgetData.axisStart ~= nil then
		local rayOrigin = widgetData.axisStart.Origin * Vector3.new(-1, 1, 1)
		local rayDirection = widgetData.axisStart.Direction * Vector3.new(-1, 1, 1)
		mirroredWidget.axisStart = Ray.new(rayOrigin, rayDirection)

		if widgetData.axisEnd ~= nil then
			mirroredWidget.axisEnd = widgetData.axisEnd * Vector3.new(-1, 1, 1)
		end

		local meshInfo: MeshInfo = modelMeshInfo[mirroredWidget.meshPart]
		if
			mirroredWidget.widgetType == Constants.WIDGET_TYPE_CYLINDER
			or mirroredWidget.widgetType == Constants.WIDGET_TYPE_AXIS_STRETCH
		then
			assert(mirroredWidget.axisStart ~= nil, "Cylinder and AxisStretch widgets must have an axis defined")
			assert(meshInfo.cageInfo, "CageInfo must exist for deformable mesh parts")

			mirroredWidget.meshSpaceAxisStart = Ray.new(
				MeshUtils.LocalSpaceToEditableMeshSpace(
					mirroredWidget.axisStart.Origin,
					mirroredWidget.meshPart,
					meshInfo.cageInfo.initialVertexPositionsMap
				),
				mirroredWidget.axisStart.Direction
			)
		elseif mirroredWidget.widgetType == Constants.WIDGET_TYPE_MUSCLE then
			assert(mirroredWidget.axisStart ~= nil, "Muscle widgets must have an axis defined")
			assert(mirroredWidget.axisEnd ~= nil, "Muscle widgets must have an axis defined")
			assert(meshInfo.cageInfo, "CageInfo must exist for deformable mesh parts")

			mirroredWidget.meshSpaceAxisStart = Ray.new(
				MeshUtils.LocalSpaceToEditableMeshSpace(
					mirroredWidget.axisStart.Origin,
					mirroredWidget.meshPart,
					meshInfo.cageInfo.initialVertexPositionsMap
				),
				mirroredWidget.axisStart.Direction
			)
			mirroredWidget.meshSpaceAxisEnd = MeshUtils.LocalSpaceToEditableMeshSpace(
				mirroredWidget.axisEnd,
				mirroredWidget.meshPart,
				meshInfo.cageInfo.initialVertexPositionsMap
			)
		end
	end
end

-- Returns a bool indicating whether the mirrored widget was created
local function GetMirroredWidget(controlGroup: ControlGroup, widgetData: WidgetData): (WidgetData, boolean)
	if widgetData.mirroredPointName and controlGroup.widgets[widgetData.mirroredPointName] then
		return controlGroup.widgets[widgetData.mirroredPointName], false
	end

	-- Virtual mirrored widget needs to be created
	local virtualWidget: WidgetData = {
		name = widgetData.name .. "_Mirrored",
		widgetType = widgetData.widgetType,

		startPosition = widgetData.startPosition * Vector3.new(-1, 1, 1),
		position = widgetData.position * Vector3.new(-1, 1, 1),
		radius = widgetData.radius,
		isSymmetrical = widgetData.isSymmetrical,

		meshPart = widgetData.meshPart,

		isMirror = true,

		deformsPartNames = widgetData.deformsPartNames,

		axisStart = widgetData.axisStart,
		axisEnd = widgetData.axisEnd,

		controls = {},
	}

	return virtualWidget, true
end

local function LinkMirroredWidgets(controlGroup: ControlGroup, modelMeshInfo: ModelMeshInfo)
	-- Loop over all widgets and link those that are mirrors of each other.
	-- EG: A left lower arm widget should have a reference to the corresponding right lower arm widget,
	-- so that when we move one, the other one automatically moves.
	local newVirtualWidgets = {}

	for _, widgetData: WidgetData in pairs(controlGroup.widgets) do
		if not widgetData.isSymmetrical then
			continue
		end

		if widgetData.isMirror then
			continue
		end

		local mirroredWidget: WidgetData, wasCreated = GetMirroredWidget(controlGroup, widgetData)

		widgetData.mirroredWidget = mirroredWidget
		mirroredWidget.mirroredWidget = widgetData

		mirroredWidget.isMirror = true

		mirroredWidget.startPosition = widgetData.startPosition * Vector3.new(-1, 1, 1)
		mirroredWidget.position = widgetData.position * Vector3.new(-1, 1, 1)

		mirroredWidget.widgetType = widgetData.widgetType

		-- Mirrored widgets should have identical types/parameters.
		-- If this widget has additional info (like a cylinder axis) we should copy that across to the mirrored widget.
		MirrorWidgetAxisProperties(mirroredWidget, widgetData, modelMeshInfo)

		mirroredWidget.controls = CreateMirroredControls(widgetData.controls, mirroredWidget.meshPart)

		if wasCreated then
			newVirtualWidgets[mirroredWidget.name] = mirroredWidget
		end
	end

	-- Add the new virtual widgets to the control group
	for _, widgetData: WidgetData in pairs(newVirtualWidgets) do
		controlGroup.widgets[widgetData.name] = widgetData
	end
end

local function BuildControlGroup(model, controlGroupFolder: Folder, modelMeshInfo: ModelMeshInfo): ControlGroup
	local controlGroup: ControlGroup = {
		name = controlGroupFolder.Name,
		widgets = {},
	}

	for _, child in pairs(controlGroupFolder:GetChildren()) do
		if child:IsA("MeshPart") == false then
			error("Invalid child of mesh edit control group!")
		end
		local meshPartName = child.Name

		local worldMeshPart = model:FindFirstChild(meshPartName, true)
		if worldMeshPart == nil then
			error("Could not find in-world meshpart " .. meshPartName .. " for mesh edit controls!")
		end

		for _, controlPoint in pairs(child:GetChildren()) do
			if controlPoint:IsA("Part") == false then
				continue
			end

			local widgetData = BuildWidgetData(child, controlPoint, worldMeshPart, modelMeshInfo)
			controlGroup.widgets[controlPoint.Name] = widgetData
		end
	end

	LinkMirroredWidgets(controlGroup, modelMeshInfo)

	return controlGroup
end

local function BuildWidgetInfo(model, meshEditControlGroups, modelMeshInfo: ModelMeshInfo): WidgetControlGroupMap
	local widgetControlGroupMap: WidgetControlGroupMap = {}

	for _, controlGroup in meshEditControlGroups:GetChildren() do
		widgetControlGroupMap[controlGroup.Name] = BuildControlGroup(model, controlGroup, modelMeshInfo)
	end

	return widgetControlGroupMap
end

local function UpdateMeshScaleFactor(meshInfo: MeshInfo, meshPart: MeshPart)
	local vertexPositions
	if meshInfo.cageInfo then
		vertexPositions = MeshUtils.GetVertexPositions(meshInfo.cageInfo.deformedEditableMesh)
	else
		assert(
			meshInfo.editableMesh ~= nil,
			"EditableMesh or Deformed Mesh not found for meshPart " .. meshPart.Name
		)
		vertexPositions = MeshUtils.GetVertexPositions(meshInfo.editableMesh :: EditableMesh)
	end
	meshInfo.scaleFactor = MeshUtils.GetScaleFactor(meshPart, vertexPositions)
end

local MeshInfo = {}
MeshInfo.__index = MeshInfo

function MeshInfo.new(model, blankData: BlanksData.BlankData)
	local self = setmetatable({}, MeshInfo)

	self.modelMeshInfo = SetupModelMeshes(model)

	self.widgetInfo = BuildWidgetInfo(model, blankData.meshEditControlGroups, self.modelMeshInfo)

	return self
end

function MeshInfo:Destroy()
	for _, meshInfo: MeshInfo in pairs(self.modelMeshInfo) do
		if meshInfo.cageInfo then
			meshInfo.cageInfo.cageEditableMesh:Destroy()
			meshInfo.cageInfo.deformedEditableMesh:Destroy()
		elseif meshInfo.editableMesh then
			meshInfo.editableMesh:Destroy()
		end
	end
end

function MeshInfo:GetModelMeshInfo(): ModelMeshInfo
	return self.modelMeshInfo
end

function MeshInfo:GetDeformedEditableMesh(meshPart: MeshPart): EditableMesh
	local meshInfo: MeshInfo = self.modelMeshInfo[meshPart]
	if not meshInfo then
		error("MeshInfo not found for meshPart " .. meshPart.Name)
	end

	assert(meshInfo.cageInfo, "CageInfo must exist for deformable meshPart " .. meshPart.Name)

	if meshInfo.cageInfo.deformedEditableMeshDirty then
		meshInfo.cageInfo.deformedEditableMesh = (
			meshInfo.cageInfo.wrapDeformer:CreateEditableMeshAsync() :: EditableMesh
		)
		UpdateMeshScaleFactor(meshInfo, meshPart)
		meshInfo.cageInfo.deformedEditableMeshDirty = false
	end

	return meshInfo.cageInfo.deformedEditableMesh
end

function MeshInfo:GetEditableMesh(meshPart: MeshPart): EditableMesh
	local meshInfo: MeshInfo = self.modelMeshInfo[meshPart]
	if not meshInfo then
		error("MeshInfo not found for meshPart " .. meshPart.Name)
	end

	if meshInfo.cageInfo then
		if meshInfo.cageInfo.deformedEditableMeshDirty then
			meshInfo.cageInfo.deformedEditableMesh = (
				meshInfo.cageInfo.wrapDeformer:CreateEditableMeshAsync() :: EditableMesh
			)
			UpdateMeshScaleFactor(meshInfo, meshPart)
			meshInfo.cageInfo.deformedEditableMeshDirty = false
		end
		return meshInfo.cageInfo.deformedEditableMesh
	else
		assert(meshInfo.editableMesh ~= nil, "EditableMesh or Deformed Mesh not found for meshPart " .. meshPart.Name)
		return meshInfo.editableMesh
	end
end

function MeshInfo:HasMeshPartByName(meshPartName: string): boolean
	for meshPart, _ in pairs(self.modelMeshInfo) do
		if meshPart.Name == meshPartName then
			return true
		end
	end
	return false
end

function MeshInfo:GetMeshInfoByName(meshPartName: string): MeshInfo
	for meshPart, meshInfo: MeshInfo in pairs(self.modelMeshInfo) do
		if meshPart.Name == meshPartName then
			return meshInfo
		end
	end

	error("MeshInfo not found for meshPart " .. meshPartName)
end

function MeshInfo:MarkMeshPartDirty(meshPart: MeshPart)
	local meshInfo: MeshInfo = self.modelMeshInfo[meshPart]
	if not meshInfo then
		error("MeshInfo not found for meshPart " .. meshPart.Name)
	end

	assert(meshInfo.cageInfo, "CageInfo must exist for deformable mesh parts")

	meshInfo.cageInfo.deformedEditableMeshDirty = true
end

function MeshInfo:UpdateDeformedEditableMeshes()
	for meshPart, meshInfo: MeshInfo in pairs(self.modelMeshInfo) do
		if not meshInfo.cageInfo then
			continue
		end

		if meshInfo.cageInfo.deformedEditableMeshDirty then
			meshInfo.cageInfo.deformedEditableMesh = (
				meshInfo.cageInfo.wrapDeformer:CreateEditableMeshAsync() :: EditableMesh
			)
			UpdateMeshScaleFactor(meshInfo, meshPart)
			meshInfo.cageInfo.deformedEditableMeshDirty = false
		end
	end
end

function MeshInfo:GetScaleFactorMap(): MeshTypes.ScaleFactorMap
	local scaleFactorMap: MeshTypes.ScaleFactorMap = {}

	for meshPart, meshInfo: MeshInfo in pairs(self.modelMeshInfo) do
		scaleFactorMap[meshPart] = meshInfo.scaleFactor
	end

	return scaleFactorMap
end

function MeshInfo:GetEditableMeshMap(): MeshTypes.EditableMeshMap
	local editableMeshMap: MeshTypes.EditableMeshMap = {}

	for meshPart, meshInfo: MeshInfo in pairs(self.modelMeshInfo) do
		if meshInfo.cageInfo then
			editableMeshMap[meshPart] = meshInfo.cageInfo.deformedEditableMesh
		else
			assert(
				meshInfo.editableMesh ~= nil,
				"EditableMesh or Deformed Mesh not found for meshPart " .. meshPart.Name
			)
			editableMeshMap[meshPart] = meshInfo.editableMesh
		end
	end

	return editableMeshMap
end

function MeshInfo:GetControlGroup(controlGroupName: string): ControlGroup
	local controlGroup = self.widgetInfo[controlGroupName]
	if controlGroup == nil then
		error("Control group " .. controlGroupName .. " not found")
	end

	return controlGroup
end

function MeshInfo:HasWidgetByName(widgetName: string): boolean
	for _, controlGroup in pairs(self.widgetInfo) do
		if controlGroup.widgets[widgetName] then
			return true
		end
	end

	return false
end

function MeshInfo:GetWidgetByName(widgetName): WidgetData
	for _, controlGroup in pairs(self.widgetInfo) do
		local widget = controlGroup.widgets[widgetName]
		if widget then
			return widget
		end
	end

	error("Widget " .. widgetName .. " not found")
end

function MeshInfo:GetAllWidgets(): { [string]: WidgetData }
	local widgets = {}
	for _, controlGroup in pairs(self.widgetInfo) do
		for _, widget in pairs(controlGroup.widgets) do
			widgets[widget.name] = widget
		end
	end

	return widgets
end

export type MeshInfoClass = typeof(MeshInfo)

return MeshInfo
