local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local Roact = require(Modules.Common.Roact)
local mutedError = require(Modules.NotLApp.mutedError)

local RetrievalStatus = require(Modules.NotLApp.Enum.RetrievalStatus)
local EmptyStatePage = require(Modules.NotLApp.EmptyStatePage)
local LoadingBarWithTheme = require(Modules.NotLApp.LoadingBarWithTheme)
local RetryButton = require(Modules.NotLApp.RetryButton)

local COMPONENT_LOADING_STATE = {
	LOADING = "loading",
	FAILED = "failed",
	LOADED = "loaded"
}

local LoadingStateWrapper = Roact.PureComponent:extend("LoadingStateWrapper")

LoadingStateWrapper.StateMappingStyle = {
	AllowReloadAfterLoaded = "AllowReloadAfterLoaded",
	LockStateAfterLoaded = "LockStateAfterLoaded",
}

LoadingStateWrapper.RenderOnFailedStyle = {
	EmptyStatePage = "EmptyStatePage",
	RetryButton = "RetryButton",
}

LoadingStateWrapper.defaultProps = {
	stateMappingStyle = LoadingStateWrapper.StateMappingStyle.LockStateAfterLoaded,
	renderOnFailed = LoadingStateWrapper.RenderOnFailedStyle.RetryButton,
}

local StateTransitionLoading = {
	[RetrievalStatus.NotStarted] = COMPONENT_LOADING_STATE.LOADING,
	[RetrievalStatus.Fetching] = COMPONENT_LOADING_STATE.LOADING,
	[RetrievalStatus.Done] = COMPONENT_LOADING_STATE.LOADED,
	[RetrievalStatus.Failed] = COMPONENT_LOADING_STATE.FAILED,
}
local StateTransitionFailed = {
	[RetrievalStatus.NotStarted] = nil,
	[RetrievalStatus.Fetching] = COMPONENT_LOADING_STATE.FAILED,
	[RetrievalStatus.Done] = COMPONENT_LOADING_STATE.LOADED,
	[RetrievalStatus.Failed] = COMPONENT_LOADING_STATE.FAILED,
}
local StateTransitionLoadedLocked = {
	[RetrievalStatus.NotStarted] = nil,
	[RetrievalStatus.Fetching] = COMPONENT_LOADING_STATE.LOADED,
	[RetrievalStatus.Done] = COMPONENT_LOADING_STATE.LOADED,
	[RetrievalStatus.Failed] = COMPONENT_LOADING_STATE.LOADED,
}
local StateTransitionLoadedAllowReload = {
	[RetrievalStatus.NotStarted] = nil,
	[RetrievalStatus.Fetching] = COMPONENT_LOADING_STATE.LOADING,
	[RetrievalStatus.Done] = COMPONENT_LOADING_STATE.LOADED,
	[RetrievalStatus.Failed] = COMPONENT_LOADING_STATE.FAILED,
}

local StateTransitionTableLockedAfterLoaded = {
	[COMPONENT_LOADING_STATE.LOADING] = StateTransitionLoading,
	[COMPONENT_LOADING_STATE.FAILED] = StateTransitionFailed,
	[COMPONENT_LOADING_STATE.LOADED] = StateTransitionLoadedLocked,
}

local StateTransitionTableAllowReloadAfterLoaded = {
	[COMPONENT_LOADING_STATE.LOADING] = StateTransitionLoading,
	[COMPONENT_LOADING_STATE.FAILED] = StateTransitionFailed,
	[COMPONENT_LOADING_STATE.LOADED] = StateTransitionLoadedAllowReload,
}

function LoadingStateWrapper:init()
	self.state = {
		stateMappingStyle = self.props.stateMappingStyle,
		loadingState = self:getNewLoadingState(self.props.stateMappingStyle, COMPONENT_LOADING_STATE.LOADING),
	}
end

function LoadingStateWrapper:getNewLoadingState(stateMappingStyle, currentState)
	local debugName = self.props.debugName or "NameNotProvided"
	local newDataStatus = self.props.dataStatus
	stateMappingStyle = stateMappingStyle or self.state.stateMappingStyle
	currentState = currentState or self.state.loadingState

	local newState = nil

	if stateMappingStyle == LoadingStateWrapper.StateMappingStyle.AllowReloadAfterLoaded then
		newState = StateTransitionTableAllowReloadAfterLoaded[currentState][newDataStatus]
	elseif stateMappingStyle == LoadingStateWrapper.StateMappingStyle.LockStateAfterLoaded then
		newState = StateTransitionTableLockedAfterLoaded[currentState][newDataStatus]
	else
		error("unsupported stateMappingStyle: ", stateMappingStyle)
	end

	if newState == nil then
		mutedError(string.format("invalid state transition from component: %s! currentState: %s, newDataStatus: %s",
			debugName, tostring(currentState), tostring(newDataStatus)))

		newState = currentState
	end

	return newState
end

function LoadingStateWrapper:render()
	local loadingState = self.state.loadingState
	local onRetry = self.props.onRetry
	local renderOnLoading = self.props.renderOnLoading
	local renderOnFailed = self.props.renderOnFailed
	local renderOnLoaded = self.props.renderOnLoaded

	if loadingState == COMPONENT_LOADING_STATE.LOADING then
		if renderOnLoading then
			return renderOnLoading()
		else
			return Roact.createElement(LoadingBarWithTheme)
		end
	elseif loadingState == COMPONENT_LOADING_STATE.FAILED then
		if type(renderOnFailed) == "function" then
			return renderOnFailed()
		elseif renderOnFailed == LoadingStateWrapper.RenderOnFailedStyle.EmptyStatePage then
			return Roact.createElement(EmptyStatePage, {
				onRetry = onRetry,
			})
		elseif renderOnFailed == LoadingStateWrapper.RenderOnFailedStyle.RetryButton then
			return Roact.createElement(RetryButton, {
				onRetry = onRetry,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
			})
		else
			error("unsupported renderOnFailed: ", renderOnFailed)
			return nil
		end
	else
		return renderOnLoaded()
	end
end

function LoadingStateWrapper:didUpdate(prevProps)
	if prevProps.stateMappingStyle ~= self.props.stateMappingStyle then
		warn("Changing stateMappingStyle after init is not supported! This change will not take effect")
	end

	if prevProps.dataStatus ~= self.props.dataStatus then
		local newLoadingState = self:getNewLoadingState()

		if newLoadingState ~= self.state.loadingState then
			self:setState({
				loadingState = newLoadingState
			})
		end
	end
end


return LoadingStateWrapper