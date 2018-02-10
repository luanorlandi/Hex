language = {}

require "file/languages/cs"
require "file/languages/de"
require "file/languages/el"
require "file/languages/en"
require "file/languages/es"
require "file/languages/fr"
require "file/languages/hu"
require "file/languages/it"
require "file/languages/pt"
require "file/languages/ro"
require "file/languages/ru"
require "file/languages/uk"
require "file/languages/nl"
require "file/languages/tr"
require "file/languages/sv"
require "file/languages/id"

function readLanguageFile()
	local path = locateSaveLocation()

	-- probably a unexpected host (like html)
	if path == nil then
		return nil
	end

	local file = io.open(path .. "/language.lua", "r")
	local lang = nil

	if file ~= nil then
		lang = file:read()
		io.close(file)
	end

    return lang
end

function writeLanguageFile(lang)
	local path = locateSaveLocation()

	-- probably a unexpected host (like html)
	if path == nil then
		return nil
	end

	local file = io.open(path .. "/language.lua", "w")

	if file ~= nil then
		file:write(lang)
		io.close(file)
	end
end

function changeLanguage(lang)
    if language[lang] ~= nil then
        strings = language[lang]
        strings.url = "https://github.com/luanorlandi/Swift-Space-Battle"
    end
end

-- set current language
-- try to find a language saved in a file, then by OS, then use default
strings = language[readLanguageFile()] or
    language[MOAIEnvironment.languageCode] or
    language["en"]

strings.url = "https://github.com/luanorlandi/Hex"
