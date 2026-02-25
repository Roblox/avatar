local StyleRoot = script.Parent
local UIBloxRoot = StyleRoot.Parent
local Roact = require(UIBloxRoot.Parent.Roact)
local StyleConsumer = require(StyleRoot.StyleConsumer)

local UIBloxConfig = require(UIBloxRoot.UIBloxConfig)
local useNewContext = UIBloxConfig.useNewContext

if useNewContext then
	-- Since our style consumer object receives the whole update-able container,
	-- we need to send only the contained style value through to the
	-- renderCallback provided
	return function(renderCallback)
		assert(type(renderCallback) == "function", "Expect renderCallback to be a function.")
		return Roact.createElement(StyleConsumer, {
			render = function(styleContainer)
				return renderCallback(styleContainer.style)
			end,
		})
	end
end

--[[
	This is a utility function that will wrap StyleConsumer.
	`renderCallback` will be invoked with the current style. It should return a Roact element.
]]
return function(renderCallback)
	assert(type(renderCallback) == "function", "Expect renderCallback to be a function.")
	return Roact.createElement(StyleConsumer, { render = renderCallback })
end