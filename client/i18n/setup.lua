local i18n = require "i18n"
local translations = require "i18n.translations"

local setup = {}

function setup.init()
    i18n.load(translations.getTranslations())

    i18n.setLocale('en')

    i18n.setFallbackLocale('en')
end

return setup