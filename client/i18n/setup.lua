local i18n = require "i18n"
local translations = require "i18n.translations"

local setup = {}

function setup.init()
    i18n.load(translations)

    i18n.setLocale('pt')

    i18n.setFallbackLocale('en')
end

return setup