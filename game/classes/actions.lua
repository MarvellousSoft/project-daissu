local Vec = require "extra_libs.hump.vector-light"
local Timer = require "extra_libs.hump.timer"
--UTILITY FUNCTIONS FOR ACTION

local icons = {
    clock  = love.graphics.newImage("assets/images/icons/clock.png"),
    counter = love.graphics.newImage("assets/images/icons/counter.png"),
    walk = love.graphics.newImage("assets/images/icons/walk.png"),
    shoot = love.graphics.newImage("assets/images/icons/shoot.png"),
    no_icon = love.graphics.newImage("assets/images/icons/no-icon.png")
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
    shoot = require "classes.actions.shoot_forward"
}

local dir = {
    [0] = {-1, 0},
    [1] = {0, 1},
    [2] = {1, 0},
    [3] = {0, -1}
}

function Actions.executeAction(match, action, controller, callback)
    if helpers[action] and helpers[action].needInput() then
        error "not supported"
    else
        Actions.showAction(action, controller, callback)
    end
end

function Actions.showAction(action, controller, callback)
    local c = controller
    local apply = function()
        c.player:resetAnimation()
        Actions.applyAction(action, c)
        if callback then callback() end
    end
    if action == 'clock' then
        Timer.tween(1, c.player, {d_dir = 1}, 'in-out-quad', apply)
    elseif action == 'counter' then
        Timer.tween(1, c.player, {d_dir = -1}, 'in-out-quad', apply)
    elseif helpers[action] then
        helpers[action].showAction(c, apply)
    else
        error("Unknown action " .. action)
    end
end

function Actions.applyAction(action, controller)
    local c = controller
    if action == 'clock' then
        c.player:rotate(1)
    elseif action == 'counter' then
        c.player:rotate(-1)
    elseif helpers[action] then
        helpers[action].applyAction(c)
    else
        error("Unknown action " .. action)
    end
end

return Actions
