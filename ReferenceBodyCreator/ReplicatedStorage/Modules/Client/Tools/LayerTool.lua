-- Client tool for managing texture layers on a target mesh part.
-- Currently only supports a single mesh part.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local ModelInfo = require(Modules:WaitForChild("ModelInfo"))
local Actions = require(Modules:WaitForChild("Actions"))
local ActionUtils = require(Modules:WaitForChild("ActionUtils"))
local TextureManipulation = Modules:WaitForChild("TextureManipulation")
local GroupInfo = require(TextureManipulation:WaitForChild("GroupInfo")) -- For type definitions
local LayerEditActions = require(TextureManipulation:WaitForChild("LayerEditActions"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")

local LayerTool = {}
LayerTool.__index = LayerTool

function LayerTool.new(modelInfo: ModelInfo.ModelInfoClass, targetMeshPartName: string, historyTool: any?)
	local self = {}
	setmetatable(self, LayerTool)

	self.modelInfo = modelInfo
	self.targetMeshPartName = targetMeshPartName
	self.historyTool = historyTool

	return self
end

function LayerTool:AddGroup(groupId: string, makeupAssetType: string?)
	local textureInfo = self.modelInfo:GetTextureInfo()

	local addGroupActionMetadata: LayerEditActions.AddGroupActionMetaData = {
		groupId = groupId,
		targetMeshPartName = self.targetMeshPartName,
		makeupAssetType = makeupAssetType,
	}
	local addGroupAction =
		ActionUtils.CreateNewAction(ActionUtils.ActionTypes.AddGroup, addGroupActionMetadata, self.modelInfo)

	if Actions.ExecuteAction(self.modelInfo, addGroupAction) then
		SendActionToServerEvent:FireServer(addGroupAction)
	end

	return textureInfo:GetGroup(self.modelInfo:GetMeshPartByName(self.targetMeshPartName), groupId)
end

function LayerTool:AddLayerToGroup(targetLayerInfo: GroupInfo.TargetLayerInfo)
	local textureInfo = self.modelInfo:GetTextureInfo()

	local addLayerActionMetadata: LayerEditActions.AddLayerActionMetaData = {
		targetLayerInfo = targetLayerInfo,
		targetMeshPartName = self.targetMeshPartName,
	}

	local addLayerAction =
		ActionUtils.CreateNewAction(ActionUtils.ActionTypes.AddLayer, addLayerActionMetadata, self.modelInfo)

	if Actions.ExecuteAction(self.modelInfo, addLayerAction) then
		SendActionToServerEvent:FireServer(addLayerAction)
	end

	-- Return newly created layer.
	local targetMeshPart = self.modelInfo:GetMeshPartByName(self.targetMeshPartName)
	textureInfo:GetOrCreateLayer(targetMeshPart, targetLayerInfo)
	return {
		thumbnailContent = textureInfo:GetLayerThumbnailContent(targetMeshPart, targetLayerInfo),
		isVisible = true,
		opacity = 1,
		onOpacityChangedCallback = function(opacity: number, isFinalInput: boolean)
			self:ChangeOpacity(targetLayerInfo, opacity, isFinalInput)
		end,
	}
end

-- Returns the currently targeted layer ({ groupId, layerId }).
function LayerTool:GetTargetLayerInfo(): GroupInfo.TargetLayerInfo
	return self.modelInfo:GetTextureInfo():GetTargetLayerInfo()
end

-- Returns the GroupInfo for the given group id (holds name/makeupAssetType).
function LayerTool:GetGroup(groupId: string): GroupInfo.GroupInfo
	local meshPart = self.modelInfo:GetMeshPartByName(self.targetMeshPartName)
	return self.modelInfo:GetTextureInfo():GetGroup(meshPart, groupId)
end

function LayerTool:GetActiveGroup(): GroupInfo.GroupInfo?
	local activeGroupId = self.modelInfo:GetTextureInfo():GetActiveGroupId()
	return if activeGroupId then self:GetGroup(activeGroupId) else nil
end

function LayerTool:SetShowMakeupGuides(showGuides: boolean)
	local makeupGuideManager = self.modelInfo:GetMakeupGuideManager()
	if makeupGuideManager then
		makeupGuideManager:SetVisible(showGuides)
		return
	end

	local textureInfo = self.modelInfo:GetTextureInfo()
	local meshPart = self.modelInfo:GetMeshPartByName(self.targetMeshPartName)
	textureInfo:SetShowMakeupGuides(meshPart, showGuides)
end

-- Refresh guides, e.g. when switching groups.
function LayerTool:RefreshMakeupGuides()
	local makeupGuideManager = self.modelInfo:GetMakeupGuideManager()
	if makeupGuideManager then
		makeupGuideManager:RefreshActiveGuide()
		return
	end

	local textureInfo = self.modelInfo:GetTextureInfo()
	local meshPart = self.modelInfo:GetMeshPartByName(self.targetMeshPartName)
	textureInfo:RefreshMakeupGuides(meshPart)
end

-- Called when setting up the UI again after already initializing layers
-- previously.
function LayerTool:GetExistingGroupInfos()
	local textureInfo = self.modelInfo:GetTextureInfo()
	local meshPart = self.modelInfo:GetMeshPartByName(self.targetMeshPartName)
	local groups = textureInfo:GetAllGroups(meshPart)
	-- Ensure every layer has displayable thumbnail content before the UI consumes
	-- these groups. Cached groups stay cached; this only creates their masked
	-- static thumbnails when needed.
	for _, group in groups do
		for _, layer in group.inputLayers do
			textureInfo:GetLayerThumbnailContent(meshPart, { groupId = group.name, layerId = layer.name })
		end
	end

	return groups
end

function LayerTool:ChangeOpacity(targetLayerInfo: GroupInfo.TargetLayerInfo, opacity: number, isFinalInput: boolean)
	local actionMetadata: LayerEditActions.SetLayerOpacityActionMetaData = {
		targetLayerInfo = targetLayerInfo,
		targetMeshPartName = self.targetMeshPartName,
		opacity = opacity,
	}
	local action = ActionUtils.CreateNewAction(ActionUtils.ActionTypes.SetLayerOpacity, actionMetadata, self.modelInfo)

	if Actions.ExecuteAction(self.modelInfo, action) and isFinalInput then
		SendActionToServerEvent:FireServer(action)
	end
end

function LayerTool:SetLayerVisible(targetLayerInfo: GroupInfo.TargetLayerInfo, isVisible: boolean)
	local actionMetadata: LayerEditActions.SetLayerVisibilityActionMetaData = {
		targetLayerInfo = targetLayerInfo,
		targetMeshPartName = self.targetMeshPartName,
		isVisible = isVisible,
	}
	local action =
		ActionUtils.CreateNewAction(ActionUtils.ActionTypes.SetLayerVisibility, actionMetadata, self.modelInfo)

	if Actions.ExecuteAction(self.modelInfo, action) then
		SendActionToServerEvent:FireServer(action)
	end
end

function LayerTool:SetGroupVisible(groupId: string, isVisible: boolean)
	local actionMetadata: LayerEditActions.SetGroupVisibilityActionMetaData = {
		groupId = groupId,
		targetMeshPartName = self.targetMeshPartName,
		isVisible = isVisible,
	}
	local action =
		ActionUtils.CreateNewAction(ActionUtils.ActionTypes.SetGroupVisibility, actionMetadata, self.modelInfo)

	if Actions.ExecuteAction(self.modelInfo, action) then
		SendActionToServerEvent:FireServer(action)
	end
end

function LayerTool:DeleteLayerFromGroup(targetLayerInfo: GroupInfo.TargetLayerInfo)
	local deleteLayerActionMetadata: LayerEditActions.DeleteLayerActionMetaData = {
		targetLayerInfo = targetLayerInfo,
		targetMeshPartName = self.targetMeshPartName,
	}

	local deleteLayerAction =
		ActionUtils.CreateNewAction(ActionUtils.ActionTypes.DeleteLayer, deleteLayerActionMetadata, self.modelInfo)

	if Actions.ExecuteAction(self.modelInfo, deleteLayerAction, nil, self.historyTool) then
		SendActionToServerEvent:FireServer(deleteLayerAction)
	end
end

function LayerTool:DeleteGroup(groupId: string)
	local deleteGroupActionMetadata: LayerEditActions.DeleteGroupActionMetaData = {
		groupId = groupId,
		targetMeshPartName = self.targetMeshPartName,
	}

	local deleteGroupAction =
		ActionUtils.CreateNewAction(ActionUtils.ActionTypes.DeleteGroup, deleteGroupActionMetadata, self.modelInfo)

	if Actions.ExecuteAction(self.modelInfo, deleteGroupAction, nil, self.historyTool) then
		SendActionToServerEvent:FireServer(deleteGroupAction)
	end
end

function LayerTool:MoveGroup(groupId: string, direction: number)
	local moveGroupActionMetadata: LayerEditActions.MoveGroupActionMetaData = {
		groupId = groupId,
		direction = direction,
		targetMeshPartName = self.targetMeshPartName,
	}

	local moveGroupAction =
		ActionUtils.CreateNewAction(ActionUtils.ActionTypes.MoveGroup, moveGroupActionMetadata, self.modelInfo)

	if Actions.ExecuteAction(self.modelInfo, moveGroupAction) then
		SendActionToServerEvent:FireServer(moveGroupAction)
	end
end

function LayerTool:SelectGroup(groupId: string)
	local setTargetGroupActionMetadata: LayerEditActions.SetTargetGroupActionMetaData = {
		groupId = groupId,
		targetMeshPartName = self.targetMeshPartName,
	}

	local setTargetGroupAction = ActionUtils.CreateNewAction(
		ActionUtils.ActionTypes.SetTargetGroup,
		setTargetGroupActionMetadata,
		self.modelInfo
	)

	if Actions.ExecuteAction(self.modelInfo, setTargetGroupAction) then
		SendActionToServerEvent:FireServer(setTargetGroupAction)
	end
end

function LayerTool:SelectLayerInGroup(targetLayerInfo: GroupInfo.TargetLayerInfo)
	-- Route properly to groupless layers
	if not targetLayerInfo.groupId then
		local textureInfo = self.modelInfo:GetTextureInfo()
		textureInfo:SetActiveGroup(nil)
		textureInfo:SetTargetLayerInfo(targetLayerInfo)
		return
	end

	local setTargetLayerActionMetadata: LayerEditActions.SetTargetLayerActionMetaData = {
		targetLayerInfo = targetLayerInfo,
		targetMeshPartName = self.targetMeshPartName,
	}

	local setTargetLayerAction = ActionUtils.CreateNewAction(
		ActionUtils.ActionTypes.SetTargetLayer,
		setTargetLayerActionMetadata,
		self.modelInfo
	)

	if Actions.ExecuteAction(self.modelInfo, setTargetLayerAction) then
		SendActionToServerEvent:FireServer(setTargetLayerAction)
	end
end

function LayerTool:MoveLayerInGroup(targetLayerInfo: GroupInfo.TargetLayerInfo, direction: number)
	local moveLayerActionMetadata: LayerEditActions.MoveLayerActionMetaData = {
		targetLayerInfo = targetLayerInfo,
		direction = direction,
		targetMeshPartName = self.targetMeshPartName,
	}

	local moveLayerAction =
		ActionUtils.CreateNewAction(ActionUtils.ActionTypes.MoveLayer, moveLayerActionMetadata, self.modelInfo)

	if Actions.ExecuteAction(self.modelInfo, moveLayerAction) then
		SendActionToServerEvent:FireServer(moveLayerAction)
	end
end

return LayerTool
