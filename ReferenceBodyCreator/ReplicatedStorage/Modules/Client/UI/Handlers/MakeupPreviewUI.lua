--[[
	Creates the UI panel used for switching between heads for makeup editing; different
	from the preview UI screen used for previewing clothing on bodies.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local ActionUtils = require(Modules:WaitForChild("ActionUtils"))

local Config = Modules:WaitForChild("Config")
local Constants = require(Config:WaitForChild("Constants"))
local MakeupHeads = require(Config:WaitForChild("MakeupHeads"))

local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local MakeupProjectionUtils = require(MeshManipulation:WaitForChild("MakeupProjectionUtils"))
local MakeupHeadAccessories =
	require(Modules:WaitForChild("Client"):WaitForChild("Tools"):WaitForChild("MakeupHeadAccessories"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SendActionToServerEvent = Remotes:WaitForChild("SendActionToServerEvent")

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))
local MakeupHeadSwapModalUI = require(script.Parent:WaitForChild("MakeupHeadSwapModalUI"))
local Components = UI:WaitForChild("Components")
local Chip = require(Components:WaitForChild("Chip"))
local Panel = require(Components:WaitForChild("Panel"))
local SwatchBar = require(Components:WaitForChild("SwatchBar"))
local TileGrid = require(Components:WaitForChild("TileGrid"))
local ToolFrame = require(Components:WaitForChild("ToolFrame"))

local MakeupPreviewUI = {}
MakeupPreviewUI.__index = MakeupPreviewUI

function MakeupPreviewUI:CreateAvatarPicker()
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	character:WaitForChild("Head")
	local tileInfos = {}
	self.headIds = {}
	for _, option in MakeupHeads.Options do
		local source = MakeupHeads.GetSourceHead(option.id, self.defaultHead, character)
		if not source then
			warn("[MakeupHeadSwapper] Head unavailable or missing a WrapTarget: " .. option.id)
			continue
		end
		local preview = MakeupProjectionUtils.CreateHeadPreview(source)
		if option.includeHair then
			local accessories = MakeupHeadAccessories.new(preview.PrimaryPart)
			accessories:Refresh(source, true --[[hairOnly]])
		end
		table.insert(self.headIds, option.id)
		table.insert(tileInfos, {
			previewInstance = preview,
			viewportOptions = if option.includeHair then { preserveAnchoring = true } else nil,
			callback = function()
				self:SwapHead(option.id)
			end,
		})
	end
	local tileGrid = TileGrid.createComponentFrame(tileInfos)
	for _, info in tileInfos do
		info.previewInstance:Destroy()
	end
	return tileGrid
end

function MakeupPreviewUI:UpdateHeadSelection()
	local selectedIndex = table.find(self.headIds, self.selectedHeadId)
	for _, tile in self.headGrid:GetChildren() do
		if tile:IsA("Frame") then
			StyleUtils.SetStyleTag(tile, StyleConsts.tags.MiniBaseTileSelected, tile.LayoutOrder == selectedIndex)
		end
	end
end

function MakeupPreviewUI:RefreshHeadAccessories(sourceHead: MeshPart?)
	local option = MakeupHeads.GetOption(self.selectedHeadId)
	local includesHair = self.editingPlayer or (option and option.includeHair) == true
	self.previewTools.Visible = includesHair
	self.hideAccessoriesToggle:GetFrame().Visible = self.editingPlayer
	self.hideHairToggle:GetFrame().Visible = includesHair
	self.headAccessories:SetHidden(
		self.editingPlayer and self.hideAccessoriesToggle.isActive,
		includesHair and self.hideHairToggle.isActive
	)
	self.headAccessories:Refresh(if includesHair then sourceHead else nil, not self.editingPlayer --[[hairOnly]])
end

function MakeupPreviewUI.new(onClosePanelCallback, modelInfo, onHeadChanged, canSwap, style)
	local self = setmetatable({}, MakeupPreviewUI)
	self.modelInfo = modelInfo
	self.head = modelInfo:GetMeshPartByName("Head")
	assert(self.head, "Missing editing head")
	self.transfer = self.head:FindFirstChild(Constants.MAKEUP_PROJECTION_TRANSFER_NAME, true)
	assert(self.transfer and self.transfer:IsA("WrapTextureTransfer"), "Missing makeup projection transfer")
	self.defaultHead = modelInfo:GetMakeupDefaultHead()
	self.onHeadChanged = onHeadChanged
	self.canSwap = canSwap
	self.selectedHeadId = modelInfo:GetMakeupHeadId()
	self.editingPlayer = self.selectedHeadId == MakeupHeads.PlayerId
	self.swapping = false
	-- Projection preparation can yield past UI destruction; ignore completion in that case.
	self.destroyed = false
	self.headSwapModal = MakeupHeadSwapModalUI.new(style)
	self.headAccessories = MakeupHeadAccessories.new(self.head)

	-- Create buttons for swapping heads
	self.headGrid = self:CreateAvatarPicker()
	self:UpdateHeadSelection()

	self.accessoryChipFrame = Instance.new("Frame")
	self.accessoryChipFrame.Name = "AccessoryVisibilityChips"
	StyleUtils.AddStyleTag(self.accessoryChipFrame, StyleConsts.tags.ChipFrame)
	self.hideAccessoriesToggle = Chip.new("Hide Accessories", function(hidden)
		self.headAccessories:SetHidden(hidden, self.hideHairToggle.isActive)
	end, false)
	self.hideHairToggle = Chip.new("Hide Hair", function(hidden)
		self.headAccessories:SetHidden(self.editingPlayer and self.hideAccessoriesToggle.isActive, hidden)
	end, false)
	self.hideAccessoriesToggle:GetFrame().Parent = self.accessoryChipFrame
	self.hideAccessoriesToggle:GetFrame().LayoutOrder = 1
	self.hideHairToggle:GetFrame().Parent = self.accessoryChipFrame
	self.hideHairToggle:GetFrame().LayoutOrder = 2
	self.previewTools = ToolFrame.createComponentFrame(self.accessoryChipFrame, "Preview Tools")
	self:RefreshHeadAccessories(
		MakeupHeads.GetSourceHead(self.selectedHeadId, self.defaultHead, Players.LocalPlayer.Character)
	)

	-- Create skin tone swatch bar
	local onSelectSwatchColor = function(color: Color3)
		if not self.swapping and not self.editingPlayer then
			self.head.Color = color
			self.modelInfo:SetMakeupHeadColor(self.selectedHeadId, color)
			if self.selectedHeadId == MakeupHeads.DefaultId then
				self.defaultHead.Color = color
			end
		end
	end
	local swatchBar = SwatchBar.createComponentFrame(onSelectSwatchColor, nil, nil, nil, Constants.PREVIEW_SKIN_TONES)
	self.swatchTool = ToolFrame.createComponentFrame(swatchBar, "Skin Tone")
	self.swatchTool.Visible = not self.editingPlayer
	self.panel = Panel.createComponentFrame(
		"Avatars",
		onClosePanelCallback,
		nil,
		{ self.headGrid, self.previewTools, self.swatchTool }
	)
	self.panel.Name = "MakeupPreviewPanel"
	self:Close()
	return self
end

function MakeupPreviewUI:SwapHead(headId: string, isConfirmed: boolean?)
	if self.destroyed or self.swapping or self.selectedHeadId == headId or not MakeupHeads.GetOption(headId) then
		return
	end
	if not self.canSwap() then
		warn("Finish the current gesture before switching heads.")
		return
	end
	local usePlayer = headId == MakeupHeads.PlayerId
	if headId ~= MakeupHeads.DefaultId and not isConfirmed then
		self.headSwapModal:Open(function()
			self:SwapHead(headId, true --[[isConfirmed]])
		end)
		return
	end
	self.swapping = true
	self.modelInfo:SetMakeupHeadSwapInProgress(true)

	-- Apply the selected head, keeping a copy for rollback, then prepare projection data.
	local previousHead
	local sourceCopy
	local source
	local changedGeometry = false
	local success, message = pcall(function()
		source = MakeupHeads.GetSourceHead(headId, self.defaultHead, Players.LocalPlayer.Character)
		assert(source, "The selected head is unavailable or does not support makeup transfer")
		sourceCopy = MakeupProjectionUtils.CloneHead(source)
		if not usePlayer then
			sourceCopy.Color = self.modelInfo:GetMakeupHeadColor(headId) or source.Color
		end
		previousHead = MakeupProjectionUtils.CloneHead(self.head)
		changedGeometry = true
		MakeupProjectionUtils.ApplyHead(self.head, sourceCopy)
		self.transfer:PrepareProjectionMeshDataAsync()
	end)

	-- Restore the previous head if the swap fails after geometry starts changing.
	local restored = true
	if not success and changedGeometry and not self.destroyed then
		restored = pcall(function()
			MakeupProjectionUtils.ApplyHead(self.head, previousHead)
			self.transfer:PrepareProjectionMeshDataAsync()
		end)
	end

	-- Clean up temporary heads, even if the UI was destroyed while preparation yielded.
	if previousHead then
		previousHead:Destroy()
	end
	if sourceCopy then
		sourceCopy:Destroy()
	end
	if self.destroyed then
		return
	end

	-- Keep painting blocked if restoring the previous head failed.
	self.swapping = false
	self.modelInfo:SetMakeupHeadSwapInProgress(not restored)

	-- On success, update the selection and notify the server and editor.
	if success then
		self.selectedHeadId = headId
		self.editingPlayer = usePlayer
		self.modelInfo:SetMakeupHeadId(headId)
		self:UpdateHeadSelection()
		self:RefreshHeadAccessories(source)
		self.modelInfo:GetMeshInfo():GetModelMeshInfo()[self.head].scaleFactor = self.head.MeshSize / self.head.Size
		SendActionToServerEvent:FireServer(ActionUtils.CreateNewAction(ActionUtils.ActionTypes.SetMakeupHead, {
			headId = headId,
		}))
		self.onHeadChanged()
		self.swatchTool.Visible = not usePlayer
	else
		if not restored then
			warn("Could not restore the editing head. Reopen the editor before painting.")
		end
		warn("[MakeupHeadSwapper] " .. tostring(message))
	end
end

function MakeupPreviewUI:Open()
	self.panel.Visible = true
end

function MakeupPreviewUI:Close()
	self.headSwapModal:Close()
	self.panel.Visible = false
end

function MakeupPreviewUI:Destroy()
	self.destroyed = true
	self.headAccessories:Destroy()
	self.headSwapModal:Destroy()
	self.panel:Destroy()
end

return MakeupPreviewUI
