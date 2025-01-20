local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules
local Roact = require(Modules.Common.Roact)

return function(props)
	local providers = props.providers or {}
	local children = props[Roact.Children]

	local treeRoot = { PageWrapper = Roact.createElement("Folder", {}, children) }

	-- Create tree of providers with first in list as outer-most element
	for i = #providers, 1, -1 do
		local provider = providers[i]
		treeRoot = {
			ProviderChildren = Roact.createElement(provider.class, provider.props, treeRoot)
		}
	end

	return Roact.oneChild(treeRoot)
end