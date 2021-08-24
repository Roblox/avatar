local Modules = game:GetService("Players").LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

local LocaleTables = script.Parent.Locales
local LocalizationContext = require(script.Parent.LocalizationContext)
local Signal = require(Modules.Common.Signal)

local function loadTables(locale)
	local relevantLanguages = LocalizationContext.getRelevantLanguages(locale)
	local translations = {}
	for _,language in ipairs(relevantLanguages) do
		local languageTable = LocaleTables:FindFirstChild(language)
		if languageTable then
			translations[language] = require(languageTable)
		end
	end
	return translations
end

local Localization = {}
Localization.__index = Localization

function Localization.new(locale)

	local self = {
		locale = locale,
		changed = Signal.new(),
	}
	setmetatable(self, {
		__index = Localization,
	})

	local translations = loadTables(locale)
	self.localizationContext = LocalizationContext.new(translations)
	return self
end

function Localization.mock()
	-- when running tests, use a mock object to get off the ground quickly
	return Localization.new("en-us")
end

function Localization:SetLocale(locale)
	self.locale = locale
	local translations = loadTables(locale)
	self.localizationContext:addTranslations(translations)
	self.changed:fire()
end

function Localization:GetLocale()
	return self.locale
end

function Localization:Format(key, arguments)
	if not key then
		error("ERROR: NO STRING FOR KEY")
	end

	local string = self.localizationContext:getString(self.locale, key, arguments)
	return string
end

return Localization