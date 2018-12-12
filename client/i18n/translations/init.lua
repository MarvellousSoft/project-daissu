local init = {}

function init.getTranslations()
    local all_translations = {}

    -- Getting all translation files from this directory
    local files = love.filesystem.getDirectoryItems('i18n/translations')
    for _, file in ipairs(files) do
        if #file > 4 and file:sub(-4) == '.lua' and file ~= 'init.lua' then
            file = file:sub(1, -5)
            local tr = require("i18n.translations." .. file)
            for lang, tab in pairs(tr) do
                all_translations[lang] = all_translations[lang] or {}
                for key, translation in pairs(tab) do
                    key = file .. '/' .. key
                    if all_translations[lang][key] ~= nil then
                        error('Translation for ' .. key .. ' on language ' .. lang .. ' is duplicated!')
                    end
                    all_translations[lang][key] = translation
                end
            end
        end
    end

    return all_translations
end

return init