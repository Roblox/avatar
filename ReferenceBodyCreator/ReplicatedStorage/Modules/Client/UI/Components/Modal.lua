--[[
	Generic modal with a title, body, and at least one button. The left most
	button has contrasting style.
]]

local GamepadService = game:GetService("GamepadService")
local UserInputService = game:GetService("UserInputService")

local UI = script.Parent.Parent

local Style = UI:WaitForChild("Style")
local StyleConsts = require(Style:WaitForChild("StyleConsts"))
local StyleUtils = require(Style:WaitForChild("StyleUtils"))

local Components = UI:WaitForChild("Components")
local TextButton = require(Components:WaitForChild("TextButton"))

local Modal = {}

function Modal.createComponentFrame(titleString: string, bodyString: string, buttonInfos: { TextButton.ButtonInfo })
	local modalFrame = Instance.new("Frame")
	modalFrame.Name = "ModalFrame"

	-- Most styling is done via StyleSheets -- see UI/Style.lua
	StyleUtils.AddStyleTag(modalFrame, StyleConsts.tags.ModalFrame)

	-- Text
	local textFrame = Instance.new("Frame")
	textFrame.Name = "TextContainer"
	textFrame.LayoutOrder = 1
	StyleUtils.AddStyleTag(textFrame, StyleConsts.tags.ModalTextFrame)
	textFrame.Parent = modalFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "TitleText"
	title.Text = titleString
	title.Parent = textFrame
	title.LayoutOrder = 1
	StyleUtils.AddStyleTag(title, StyleConsts.tags.ModalTitle)

	-- Body
	local body = Instance.new("TextLabel")
	body.Name = "BodyText"
	body.Text = bodyString
	body.Parent = textFrame
	body.LayoutOrder = 2
	StyleUtils.AddStyleTag(body, StyleConsts.tags.ModalBody)

	-- Buttons
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = "ButtonContainer"
	StyleUtils.AddStyleTag(buttonFrame, StyleConsts.tags.ButtonFrame)
	buttonFrame.Parent = modalFrame
	buttonFrame.LayoutOrder = 2

	for i, buttonInfo in buttonInfos do
		local button = TextButton.createComponentFrame(buttonInfo)
		button.Parent = buttonFrame
		button.LayoutOrder = i
		if i == 1 then
			-- First button is emphasized
			StyleUtils.AddStyleTag(button, StyleConsts.tags.EmphasisButton)
		end
	end

	-- Modal size is based on number of buttons.
	if #buttonInfos <= 2 then
		modalFrame.Size = StyleConsts.styleTokens.ModalTwoButtonSize
	else
		modalFrame.Size = StyleConsts.styleTokens.ModalThreeButtonSize
	end

	-- Enable virtual cursor on console to interact with modal
	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		GamepadService:EnableGamepadCursor(nil)
	end

	return modalFrame
end

return Modal
