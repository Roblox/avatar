local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local SetCategoryAndSubcategory = require(Modules.AvatarExperience.AvatarEditor.Actions.SetCategoryAndSubcategory)
local SetCurrentToastMessage = require(Modules.NotLApp.Actions.SetCurrentToastMessage)
local Utils = require(Modules.AvatarExperience.Common.Utils)
local ToastType = require(Modules.NotLApp.Enum.ToastType)
local Constants = require(Modules.AvatarExperience.Common.Constants)

local Categories = require(Modules.AvatarExperience.AvatarEditor.Categories)
local AvatarExperienceConstants = require(Modules.AvatarExperience.Common.Constants)

local R6_ANIMATION_ERROR = "Feature.Avatar.Message.R6AnimationError"
local R6_EMOTES_ERROR = "Feature.Avatar.Message.R6EmotesError"
local R6_BODYSCALES_ERROR = "Feature.Avatar.Message.R6BodyScaleError"

local function getUserId(state)
	if state.LocalUserId then
		return state.LocalUserId
	end
	if state.RobloxUser and state.RobloxUser.rbxuid then
		return tostring(state.RobloxUser.rbxuid)
	end
	return nil
end

local function createToast(text)
	return {
		toastMessage = text,
		isLocalized = false,
		toastType = ToastType.InformationMessage,
	}
end

return function(category, subcategory)
	return function(store)
		store:dispatch(SetCategoryAndSubcategory(category, subcategory))

		local state = store:getState()
		local avatarType = state.AvatarExperience.AvatarEditor.Character.AvatarType
		local pageType = Utils.getPageFromState(state).PageType

		if avatarType == Constants.AvatarType.R6 then
			if pageType == Constants.PageType.Animation then
				store:dispatch(SetCurrentToastMessage(createToast(R6_ANIMATION_ERROR)))
			elseif pageType == Constants.PageType.Emotes then
				store:dispatch(SetCurrentToastMessage(createToast(R6_EMOTES_ERROR)))
			elseif pageType == Constants.PageType.BodyStyle then
				store:dispatch(SetCurrentToastMessage(createToast(R6_BODYSCALES_ERROR)))
			end
		end
	end
end
