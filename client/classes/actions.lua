local i18n  = require "i18n"
local icons = require("assets").images.icons
--UTILITY FUNCTIONS FOR ACTION

local icons = {
    clock              = icons.clock,
    counter            = icons.counter,
    walk               = icons.sprint,
    ['long walk']      = icons.run,
    shoot              = icons.shoot,
    roundhouse         = icons['high-kick'],
    ['explosion shot'] = icons['spiky-explosion'],
    ['strong punch']   = icons['punch-blast'],
    ['run and hit']    = icons['running-ninja'],
    hookshot           = icons['meat-hook'],
    shove              = icons.push,
    no_icon            = icons['no-icon'],
}

local Actions = {}

--Returns icon for given action
function Actions.actionImage(action)
    if icons[action] then
        return icons[action]
    else
        return icons["no_icon"]
    end
end

local helpers = {
    walk               = (require "classes.actions.walk")(1),
    shoot              = require "classes.actions.shoot",
    roundhouse         = require "classes.actions.roundhouse",
    ['explosion shot'] = require "classes.actions.explosion_shot",
    ['strong punch']   = require "classes.actions.strong_punch",
    ['run and hit']    = require "classes.actions.run_and_hit",
    shove              = require "classes.actions.shove",
    ['long walk']      = (require "classes.actions.walk")(2),
    hookshot           = require "classes.actions.hookshot",
}

function Actions.init()
    for name, obj in pairs(helpers) do
        local base = 'actions/' .. name
        obj.getName = function() return i18n(base .. "/name") end
        obj.getDescription = function() return  i18n(base .. "/desc") end
        obj.getFlavor = function() return i18n(base .. "/flavor") end
    end
end

function Actions.getAction(action_name)
    if not helpers[action_name] then
        error('Unknown action ' .. tostring(action_name))
    end
    return helpers[action_name]
end

function Actions.waitForInput(match, action, controller, callback)
    local helper = Actions.getAction(action)
    if helper.getInputHandler then
        controller:waitForInput(match, helper.getInputHandler(controller), callback)
    else
        -- no input
        callback()
    end
end

function Actions.executeAction(match, action, controller, callback)
    if helpers[action] and helpers[action].getInputHandler then
        controller:waitForInput(match, helpers[action].getInputHandler(controller, callback))
    elseif helpers[action] then
        helpers[action].showAction(controller, callback)
    else
        error("Unknown action " .. action)
    end
end

return Actions
