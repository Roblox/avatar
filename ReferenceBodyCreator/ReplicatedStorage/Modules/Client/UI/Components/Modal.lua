--[[
	Generic modal with a title, body, and at least one button. The left most
	button has contrasting style.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Client = Modules:WaitForChild("Client")
local UI = Client:WaitForChild("UI")
local Components = UI:WaitForChild("Components")

local TextButton = require(Components:WaitForChild("TextButton"))

local Utils = require(Modules:WaitForChild("Utils"))
local StyleConsts = require(UI:WaitForChild("StyleConsts"))

local Modal = {}

function Modal.createComponentFrame(titleString: string, bodyString: string, buttonInfos: { TextButton.ButtonInfo })
	local modalFrame = Instance.new("Frame")
	modalFrame.Name = "ModalFrame"

	-- Most styling is done via StyleSheets -- see UI/Style.lua
	Utils.AddStyleTag(modalFrame, StyleConsts.tags.ModalFrame)

	-- Text
	local textFrame = Instance.new("Frame")
	textFrame.Name = "TextContainer"
	textFrame.LayoutOrder = 1
	Utils.AddStyleTag(textFrame, StyleConsts.tags.ModalTextFrame)
	textFrame.Parent = modalFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "TitleText"
	title.Text = titleString
	title.Parent = textFrame
	title.LayoutOrder = 1
	Utils.AddStyleTag(title, StyleConsts.tags.ModalTitle)

	-- Body
	local body = Instance.new("TextLabel")
	body.Name = "BodyText"
	body.Text = bodyString
	body.Parent = textFrame
	body.LayoutOrder = 2
	Utils.AddStyleTag(body, StyleConsts.tags.ModalBody)

	-- Buttons
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = "ButtonContainer"
	Utils.AddStyleTag(buttonFrame, StyleConsts.tags.ButtonFrame)
	buttonFrame.Parent = modalFrame
	buttonFrame.LayoutOrder = 2

	for i, buttonInfo in buttonInfos do
		local button = TextButton.createComponentFrame(buttonInfo)
		button.Parent = buttonFrame
		button.LayoutOrder = i
		if i == 1 then
			-- First button is emphasized
			Utils.AddStyleTag(button, StyleConsts.tags.EmphasisButton)
		end
	end

	-- Modal size is based on number of buttons.
	if #buttonInfos <= 2 then
		modalFrame.Size = StyleConsts.styleTokens.ModalTwoButtonSize
	else
		modalFrame.Size = StyleConsts.styleTokens.ModalThreeButtonSize
	end

	return modalFrame
end

return Modal
