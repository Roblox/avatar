-- This class represents a humanoid model with the instance hierarchy
-- described by the PedestalFolder type below.
-- Creating a DemoModel instance around it allows it to handle clicks
-- and manage the state of the avatar setup process for that model.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AvatarUtils = require(ReplicatedStorage:WaitForChild("AvatarUtils"))

local STATE_INIT = "init" -- Initial state when the model is ready to be set up
local STATE_INPROGRESS = "inprogress" -- State when avatar setup is in progress
local STATE_EQUIP = "equip" -- State when avatar setup has completed successfully and the avatar is ready to equip
local STATE_ERROR = "error" -- State when an error occurred during setup
local STATE_PUBLISH = "publish" -- State when the avatar is already equipped and clicking will publish

local DemoModel = {}
DemoModel.__index = DemoModel

type PedestalFolder = Folder & {
	Model: Model,
	Clicker: Folder & {
		ClickDetector: ClickDetector,
		SurfaceGui: SurfaceGui & {
			TextLabel: TextLabel,
			ProgressBar: Frame,
		},
	},
}

function DemoModel.new(pedestal: PedestalFolder, name: string?, onEquip: (demoModel: any) -> ())
	local self = {}
	setmetatable(self, DemoModel)

	self.name = name
	self.model = pedestal.Model
	self.onEquip = onEquip
	self.clickDetector = pedestal.Clicker.ClickDetector
	self.textLabel = pedestal.Clicker.SurfaceGui.TextLabel
	self.progressBar = pedestal.Clicker.SurfaceGui:FindFirstChild("ProgressBar")
	self.state = STATE_INIT
	self.generationId = nil :: string?
	self.connection = self.clickDetector.MouseClick:Connect(function(player)
		self:onClicked(player)
	end)

	self:setState(STATE_INIT)

	return self
end

function DemoModel:setText(text: string)
	self.textLabel.Text = text
end

function DemoModel:setProgress(progress: number)
	if not self.progressBar then
		return
	end
	progress = math.clamp(progress, 0, 1)
	self.progressBar.Size = UDim2.new(progress, 0, 1, 0)
end

-- Update the clickable text based on the current state
function DemoModel:updateText()
	if self.state == STATE_INIT then
		self:setText("Setup Avatar")
		self:setProgress(0)
	elseif self.state == STATE_INPROGRESS then
		self:setText("In progress...")
	elseif self.state == STATE_EQUIP then
		self:setText("Equip")
		self:setProgress(1)
	elseif self.state == STATE_PUBLISH then
		self:setText("Publish")
		self:setProgress(1)
	else
		self:setText("Error. Retry")
		self:setProgress(0)
	end
end

-- Set the state and update the text label accordingly
function DemoModel:setState(newState)
	self.state = newState
	self:updateText()
end

-- Invokes auto-setup and updates the state when it completes
function DemoModel:doAutoSetup(player: Player)
	self:setState(STATE_INPROGRESS)
	task.spawn(function()
		local success, errorMessage = pcall(function()
			self.generationId = AvatarUtils.setupAvatar(player, self.model, function(progressInfo: AvatarUtils.ProgressInfo)
				self:setProgress(progressInfo.Progress)
			end)
		end)

		if success then
			self:setState(STATE_EQUIP)
		else
			self:setState(STATE_ERROR)
			warn("AutoSetup failed:", errorMessage)
		end
	end)
end

-- Equip the auto-setup results for this model
function DemoModel:doEquip(player: Player)
	AvatarUtils.equipAvatarFromServer(player, self.generationId)
	self:setState(STATE_PUBLISH)
	self.onEquip(self)
end

-- Handle clicks on the model, based on the current state
function DemoModel:onClicked(player)
	if self.state == STATE_INIT or self.state == STATE_ERROR then
		self:doAutoSetup(player)

	elseif self.state == STATE_EQUIP then
		self:doEquip(player)

	elseif self.state == STATE_PUBLISH then
		AvatarUtils.publishAvatar(player, self.generationId)
	end
end

function DemoModel:destroy()
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end
end

function DemoModel:onUnequip()
	if self.state == STATE_PUBLISH then
		self:setState(STATE_EQUIP)
	end
end

return DemoModel
