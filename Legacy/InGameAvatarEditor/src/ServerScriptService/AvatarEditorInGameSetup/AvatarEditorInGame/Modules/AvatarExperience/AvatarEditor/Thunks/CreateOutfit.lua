local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local AvatarEditorService = game:GetService("AvatarEditorService")

local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local PerformFetch = require(Modules.Common.PerformFetch)
local Promise = require(Modules.Packages.Promise)
local AvatarExperienceConstants = require(Modules.AvatarExperience.AvatarEditor.Constants)
local SetCurrentToastMessage = require(Modules.NotLApp.Actions.SetCurrentToastMessage)
local ToastType = require(Modules.NotLApp.Enum.ToastType)

local runPromptCallbackInQueue = require(Modules.Util.runPromptCallbackInQueue)

local FFlagShowMaxOutfitsErrorToast = true

local MAX_OUTFITS_ERROR_CODE = 1
local INVALID_NAME_ERROR_CODE = 4

local INVALID_NAME_TOAST = {
	toastMessage = "Feature.Avatar.Message.InvalidName",
	isLocalized = false,
	toastType = ToastType.InformationMessage,
}

local MAX_OUTFITS_TOAST = {
	toastMessage = "Feature.Avatar.Message.ReachedMaxOutfits",
	isLocalized = false,
	toastType = ToastType.InformationMessage,
}

local function keyMapper()
	return AvatarExperienceConstants.CreateOutfitKey
end

return function(name)
	return function(store)
		local state = store:getState()
		local currentAssets = state.AvatarExperience.AvatarEditor.Character.EquippedAssets
		local assetIds = {}

		for _, assetType in pairs(currentAssets) do
			for _, asset in pairs(assetType) do
				assetIds[#assetIds + 1] = asset
			end
		end

		local characterRoot = game.Workspace.CharacterRoot
		local humanoidDescription
		local avatarType
		if characterRoot:FindFirstChild("CharacterR15") then
			avatarType = Enum.HumanoidRigType.R15
			humanoidDescription = characterRoot.CharacterR15.Humanoid:GetAppliedDescription()
		else
			avatarType = Enum.HumanoidRigType.R6
			humanoidDescription = characterRoot.CharacterR6.Humanoid:GetAppliedDescription()
		end

		return PerformFetch.Single(keyMapper(), function(store)
			return Promise.new(function(resolve, reject)

				coroutine.wrap(function()
					local function createOufitCallback()
						AvatarEditorService:PromptCreateOutfit(humanoidDescription, avatarType)

						local result = AvatarEditorService.PromptCreateOutfitCompleted:Wait()

						if result == Enum.AvatarPromptResult.Success then
							resolve()
						else
							reject()
						end

					end

					runPromptCallbackInQueue(createOufitCallback)
				end)()
			end)
		end)(store)
	end
end
