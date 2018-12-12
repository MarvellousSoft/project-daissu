local i18n = require "i18n"
local Vec = require "common.extra_libs.hump.vector-light"
local Timer = require "common.extra_libs.hump.timer"
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
    shoot = require "classes.actions.shoot_forward",
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
        obj.name = i18n(base .. "/name")
        obj.desc = i18n(base .. "/desc")
        obj.flavor = i18n(base .. "/flavor")
    end
end

function Actions.getAction(action_name)
    return helpers[action_name]
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
