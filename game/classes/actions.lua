local Vec = require "extra_libs.hump.vector-light"
local Timer = require "extra_libs.hump.timer"
--UTILITY FUNCTIONS FOR ACTION

local icons = {
    clock  = love.graphics.newImage("assets/images/icons/clock.png"),
    counter = love.graphics.newImage("assets/images/icons/counter.png"),
    walk = love.graphics.newImage("assets/images/icons/walk.png"),
    shoot = love.graphics.newImage("assets/images/icons/shoot.png"),
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
    walk = require "classes.actions.walk",
    shoot = require "classes.actions.shoot_forward",
    roundhouse = require "classes.actions.roundhouse",
    explosion_shot = require "classes.actions.explosion_shot",
    ['strong punch'] = require "classes.actions.strong_punch",
    ['run and hit'] = require "classes.actions.run_and_hit",
    shove = require "classes.actions.shove",
}

function Actions.executeAction(match, action, controller, callback)
    if helpers[action] and helpers[action].getInputHandler then
        match.action_input_handler = helpers[action].getInputHandler(controller, callback)
    elseif helpers[action] then
        helpers[action].showAction(controller, callback)
    else
        error("Unknown action " .. action)
    end
end

return Actions
