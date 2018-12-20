local i18n  = require "i18n"
--UTILITY FUNCTIONS FOR ACTION

local icons = {
    clock  = love.graphics.newImage("assets/images/icons/clock.png"),
    counter = love.graphics.newImage("assets/images/icons/counter.png"),
    walk = love.graphics.newImage("assets/images/icons/sprint.png"),
    ['long walk'] = love.graphics.newImage("assets/images/icons/run.png"),
    shoot = love.graphics.newImage("assets/images/icons/shoot.png"),
    roundhouse = love.graphics.newImage("assets/images/icons/high-kick.png"),
    ['explosion shot'] = love.graphics.newImage("assets/images/icons/spiky-explosion.png"),
    ['strong punch'] = love.graphics.newImage("assets/images/icons/punch-blast.png"),
    ['run and hit'] = love.graphics.newImage("assets/images/icons/running-ninja.png"),
    hookshot = love.graphics.newImage("assets/images/icons/meat-hook.png"),
    shove = love.graphics.newImage("assets/images/icons/push.png"),
    no_icon = love.graphics.newImage("assets/images/icons/no-icon.png"),
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
    walk = (require "classes.actions.walk")(1),
    shoot = require "classes.actions.shoot",
    roundhouse = require "classes.actions.roundhouse",
    ['explosion shot'] = require "classes.actions.explosion_shot",
    ['strong punch'] = require "classes.actions.strong_punch",
    ['run and hit'] = require "classes.actions.run_and_hit",
    shove = require "classes.actions.shove",
    ['long walk'] = (require "classes.actions.walk")(2),
    hookshot = require "classes.actions.hookshot",
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
