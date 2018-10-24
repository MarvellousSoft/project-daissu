local Class = require "extra_libs.hump.class"
local Timer = require "extra_libs.hump.timer"
local Vec = require "extra_libs.hump.vector-light"
local Util = require "util"
local GridHelper = require "classes.map.grid_helper"
local ActionInputHandler = require "classes.actions.action_input_handler"

local Walk = {}

function Walk.showAction(controller, callback, i, j)
    local tile = controller.map:get(i, j)
    local fun = function()
        Walk.applyAction(controller, i, j)
        controller.player:resetAnimation()
        if callback then callback() end
    end
    if tile and not tile:blocked() then
        local pi, pj = controller:getPosition()
        Timer.tween(1, controller.player, {dx = j - pj, dy = i - pi}, 'in-out-quad', fun)
    else
        fun()
    end
end

function Walk.applyAction(controller, i, j)
    local pi, pj = controller:getPosition()
    GridHelper.moveObject(controller.map, pi, pj, i, j)
end

function Walk.getInputHandler(controller, callback)
    local pi, pj = controller:getPosition()
    return ActionInputHandler {
        accept = function(self, i, j)
            return GridHelper.manhattanDistance(i, j, pi, pj) == 1
        end,
        finish = function(self, i, j)
            Walk.showAction(controller, callback, i, j)
        end,
    }
end

return Walk
