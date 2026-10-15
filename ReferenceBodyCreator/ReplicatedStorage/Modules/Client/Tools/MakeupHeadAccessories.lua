-- Client-only copies of avatar head accessories for the makeup preview.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local MeshManipulation = Modules:WaitForChild("MeshManipulation")
local AccessoryUtils = require(MeshManipulation:WaitForChild("AccessoryUtils"))

local MakeupHeadAccessories = {}
MakeupHeadAccessories.__index = MakeupHeadAccessories

local function isHeadAccessory(accessory: Accessory, head: BasePart): boolean
	local accessoryType = accessory.AccessoryType
	-- Omit worn makeup, even when it has an attachment or weld to the head.
	if accessoryType == Enum.AccessoryType.Eyebrow or accessoryType == Enum.AccessoryType.Eyelash then
		return false
	end
	local handle = accessory:FindFirstChild("Handle")
	if not handle or not handle:IsA("BasePart") then
		return false
	end
	-- Layered hair and face accessories may attach to the body, then wrap onto the head.
	if
		accessoryType == Enum.AccessoryType.Hat
		or accessoryType == Enum.AccessoryType.Hair
		or accessoryType == Enum.AccessoryType.Face
	then
		return true
	end
	for _, child in handle:GetChildren() do
		if child:IsA("JointInstance") and (child.Part0 == head or child.Part1 == head) then
			return true
		end
		if child:IsA("Attachment") then
			local matchingAttachment = head:FindFirstChild(child.Name)
			if matchingAttachment and matchingAttachment:IsA("Attachment") then
				return true
			end
		end
	end
	return false
end

function MakeupHeadAccessories.new(head: BasePart)
	return setmetatable({
		head = head,
		accessories = {},
		hideAccessories = false,
		hideHair = false,
	}, MakeupHeadAccessories)
end

function MakeupHeadAccessories:SetHidden(hideAccessories: boolean, hideHair: boolean)
	self.hideAccessories = hideAccessories
	self.hideHair = hideHair
	for _, accessory in self.accessories do
		local hidden = if accessory.AccessoryType == Enum.AccessoryType.Hair then hideHair else hideAccessories
		for _, descendant in accessory:GetDescendants() do
			if descendant:IsA("BasePart") or descendant:IsA("Decal") then
				descendant.LocalTransparencyModifier = if hidden then 1 else 0
			end
		end
	end
end

function MakeupHeadAccessories:Clear()
	for _, accessory in self.accessories do
		accessory:Destroy()
	end
	table.clear(self.accessories)
end

-- The source head and its accessories already share the avatar's size and fit.
-- Keep their relative transforms when moving them to the editing head.
function MakeupHeadAccessories:Refresh(sourceHead: BasePart?, hairOnly: boolean?)
	self:Clear()
	if not sourceHead or not sourceHead.Parent then
		return
	end
	local transform = self.head.CFrame * sourceHead.CFrame:Inverse()
	for _, source in sourceHead.Parent:GetChildren() do
		if
			not source:IsA("Accessory")
			or (hairOnly and source.AccessoryType ~= Enum.AccessoryType.Hair)
			or not isHeadAccessory(source, sourceHead)
		then
			continue
		end
		local wasArchivable = source.Archivable
		source.Archivable = true
		local copy = source:Clone()
		source.Archivable = wasArchivable
		local isLayered = copy:FindFirstChildWhichIsA("WrapLayer", true) ~= nil
		for _, descendant in copy:GetDescendants() do
			if
				descendant:IsA("JointInstance")
				or descendant:IsA("Constraint")
				or descendant:IsA("LuaSourceContainer")
			then
				descendant:Destroy()
			elseif descendant:IsA("BasePart") then
				-- ModelDisplay moves all parts together; previews must not affect painting raycasts.
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanTouch = false
				descendant.CanQuery = false
				if not isLayered then
					descendant.CFrame = transform * descendant.CFrame
				end
			end
		end
		if isLayered then
			local fitted, message = pcall(AccessoryUtils.EquipLayeredAccessoryOntoWrapTarget, self.head.Parent, copy)
			if not fitted then
				copy:Destroy()
				warn("Could not fit preview accessory " .. source.Name .. ": " .. tostring(message))
				continue
			end
		else
			copy.Parent = self.head.Parent
		end
		table.insert(self.accessories, copy)
	end
	self:SetHidden(self.hideAccessories, self.hideHair)
end

function MakeupHeadAccessories:Destroy()
	self:Clear()
end

return MakeupHeadAccessories
