--[[
	Text button in the shape of a pill. Clicking toggles it.
    When inactive, the background is dark and the text is white.
	When active, the background is white and the text is dark.

	If an optional sideChipAsset (and sideChipCallback) is supplied, an oval icon
	button pokes out to the right of the chip when the main chip is active.
]]

local UI = script.Parent.Parent
local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))
local IconButton = require(script.Parent:WaitForChild("IconButton"))

local Chip = {}
Chip.__index = Chip

function Chip:GetFrame()
	return self.container or self.textbutton
end

-- Sets the main chip's active visual state without firing the callback. Use to reflect
-- externally-owned state (e.g. a shared tool setting) into the chip.
function Chip:SetActive(isActive: boolean)
	self.isActive = isActive
	StyleUtils.SetStyleTag(self.textbutton, StyleConsts.tags.ChipActive, isActive)

	if self.sideChip then
		self.sideChip.Visible = isActive
	end
end

-- Sets the side chip's active visual state without firing the callback.
function Chip:SetSideChipActive(active: boolean)
	self.sideChipActive = active
	if self.sideChip then
		StyleUtils.SetStyleTag(self.sideChip, StyleConsts.tags.SideChipActive, active)
	end
end

function Chip:Toggle()
	self:SetActive(not self.isActive)
	self.callback(self.isActive)
end

function Chip:ToggleSideChip()
	self:SetSideChipActive(not self.sideChipActive)
	if self.sideChipCallback then
		self.sideChipCallback(self.sideChipActive)
	end
end

function Chip.new(
	text: string,
	callback: (isActive: boolean?) -> (),
	startActive: boolean?,
	sideChipAsset: string?,
	sideChipCallback: ((isActive: boolean?) -> ())?
)
	local self = {}
	setmetatable(self, Chip)

	self.isActive = startActive
	self.callback = callback

	self.textbutton = Instance.new("TextButton")
	self.textbutton.Name = "Chip"
	self.textbutton.Text = text
	StyleUtils.AddStyleTag(self.textbutton, StyleConsts.tags.Chip)
	if self.isActive then
		StyleUtils.AddStyleTag(self.textbutton, StyleConsts.tags.ChipActive)
	end

	self.textbutton.Activated:Connect(function()
		self:Toggle()
	end)

	if sideChipAsset then
		self.sideChipCallback = sideChipCallback
		-- Start the side chip active whenever the main chip starts active, so a default-on
		-- mirror chip also shows its guide as on.
		self.sideChipActive = self.isActive == true

		self.container = Instance.new("Frame")
		self.container.Name = "ChipWithSideChip"
		StyleUtils.AddStyleTag(self.container, StyleConsts.tags.SideChipContainer)

		self.textbutton.LayoutOrder = 1
		self.textbutton.ZIndex = 2
		self.textbutton.Parent = self.container

		local sideChip = IconButton.createComponentFrame(sideChipAsset, function()
			self:ToggleSideChip()
		end)
		sideChip.Name = "SideChip"
		sideChip.LayoutOrder = 2
		sideChip.ZIndex = 1
		sideChip.Visible = self.isActive == true -- only shown while the main chip is active
		StyleUtils.AddStyleTag(sideChip, StyleConsts.tags.SideChip)
		StyleUtils.SetStyleTag(sideChip, StyleConsts.tags.SideChipActive, self.sideChipActive)
		sideChip.Parent = self.container
		self.sideChip = sideChip
	end

	return self
end

return Chip
