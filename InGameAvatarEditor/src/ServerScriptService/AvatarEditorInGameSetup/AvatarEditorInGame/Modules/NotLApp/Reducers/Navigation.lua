local Players = game:GetService("Players")
local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Rodux = require(Modules.Packages.Rodux)
local Cryo = require(Modules.Packages.Cryo)
local TableUtilities = require(Modules.Common.TableUtilities)
local mutedError = require(Modules.NotLApp.mutedError)
local ApplyNavigateToRoute = require(Modules.NotLApp.Actions.ApplyNavigateToRoute)
local ApplyNavigateBack = require(Modules.NotLApp.Actions.ApplyNavigateBack)
local ApplyResetNavigationHistory = require(Modules.NotLApp.Actions.ApplyResetNavigationHistory)
local ApplyNavigateBackUp = require(Modules.NotLApp.Actions.ApplyNavigateBackUp)
local ApplySetNavigationLocked = require(Modules.NotLApp.Actions.ApplySetNavigationLocked)
local SetBackNavigationDisabled = require(Modules.NotLApp.Actions.SetBackNavigationDisabled)
local ApplyRoactNavigationHistory = require(Modules.NotLApp.Actions.ApplyRoactNavigationHistory)
local Constants = require(Modules.NotLApp.Constants)

local AppPage = require(Modules.NotLApp.AppPage)

-- NOTE: Keep synced with copy in ResetNavigationHistory.lua.
local function getDefaultRoute()
	return { { name = AppPage.AvatarEditor } }
end

return Rodux.createReducer({
	history = { getDefaultRoute() },
	lockNavigationActions = false,
	backNavigationDisableCounter = 0
}, {
	[ApplyNavigateToRoute.name] = function(state, action)
		if not action.bypassNavigationLock and state.lockNavigationActions then
			return state
		end

		local newState = Cryo.Dictionary.join(state, {
			history = #action.route == 1 and
				{ action.route } or
				Cryo.List.join(state.history, { action.route }),
			lockNavigationActions = true,
		})

		return newState
	end,
	[ApplyNavigateBack.name] = function(state, action)
		if not action.bypassNavigationLock and state.lockNavigationActions then
			return state
		end

		if state.backNavigationDisableCounter > 0 then
			return state
		end

		local newState = state
		if #state.history > 1 then
			newState = Cryo.Dictionary.join(state, {
				history = Cryo.List.removeIndex(state.history, #state.history),
				lockNavigationActions = true,
			})
		end

		return newState
	end,
	[ApplyNavigateBackUp.name] = function(state, action)
		if not action.bypassNavigationLock and state.lockNavigationActions then
			return state
		end

		local newState = state

		if #state.history > 1 then
			local currentRoute = state.history[#state.history]
			local upperRoute = Cryo.List.removeIndex(currentRoute, #currentRoute)

			local upperRouteIndex = nil
			for index = #state.history - 1, 1, -1 do
				local route = state.history[index]

				if TableUtilities.DeepEqual(route, upperRoute, true) then
					upperRouteIndex = index
					break
				end
			end

			if upperRouteIndex == nil then
				mutedError("Cannot find the correct route to BackUp to! current route history: ",
					TableUtilities.RecursiveToString(state.history))

				-- If this happens just remove the last item in the history (so a NavigateBack)
				upperRouteIndex = #state.history - 1
			end

			newState = Cryo.Dictionary.join(state, {
				history = Cryo.List.removeRange(state.history, upperRouteIndex + 1, #state.history),
				lockNavigationActions = true,
			})
		end

		return newState
	end,
	[ApplyResetNavigationHistory.name] = function(state, action)
		return Cryo.Dictionary.join(state, {
			history = action.history or { action.route or getDefaultRoute() },
			lockNavigationActions = true,
			backNavigationDisableCounter = 0,
		})
	end,
	[ApplyRoactNavigationHistory.name] = function(state, action)
		-- TODO: Remove with GetFFlagLuaAppUseRoactNavigation.
		-- Build new history from RN nav state graph under the assumption that there is only one top-level stack.
		local rnStack = action.navigationState
		if not rnStack or not rnStack.routes or not rnStack.index then
			mutedError("Roact Navigation state is not complete in action: ",
				TableUtilities.RecursiveToString(action))
			return state
		end

		local newHistory = {}
		for i=1,rnStack.index do
			local rnRoute = rnStack.routes[i]
			if rnRoute.routeName == Constants.TempRnSwitchNavigatorName then
				-- Special handling of switch navigator to get inner route info.
				rnRoute = rnRoute.routes[rnRoute.index]
			end

			local navRoute = Cryo.Dictionary.join({
				name = rnRoute.routeName,
				rnKey = rnRoute.key,
			}, rnRoute.params or {})

			table.insert(newHistory, Cryo.List.join(newHistory[i-1] or {}, { navRoute }))
		end

		if #newHistory == 0 then
			mutedError("RN computed history is empty for action: ",
				TableUtilities.RecursiveToString(action))
			newHistory = { getDefaultRoute() }
		end

		return Cryo.Dictionary.join(state, {
			history = newHistory,
		})
	end,
	[ApplySetNavigationLocked.name] = function(state, action)
		if state.lockNavigationActions == action.locked then
			return state
		end

		local newState = Cryo.Dictionary.join(state, {
			lockNavigationActions = action.locked or false,
		})

		return newState
	end,
	[SetBackNavigationDisabled.name] = function(state, action)
		local backNavigationDisableCounter = action.disabled and
			state.backNavigationDisableCounter + 1 or
			math.max(state.backNavigationDisableCounter - 1, 0)

		return Cryo.Dictionary.join(state, {
			backNavigationDisableCounter = backNavigationDisableCounter
		})
	end,
})
