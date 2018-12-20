local Class = require "common.extra_libs.hump.class"
local Timer = require "common.extra_libs.hump.timer"
local Vec = require "common.extra_libs.hump.vector-light"
local GridHelper = require "common.map.grid_helper"
local ActionInputHandler = require "classes.actions.action_input_handler"

local function WalkCreator(distance)
    local Walk = {}

    function Walk.showAction(controller, callback, i, j)
        local tile = controller.map:get(i, j)
        local fun = function()
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

    function Walk.getInputHandler(controller)
        local pi, pj = controller:getPosition()
        return ActionInputHandler {
            accept = function(self, i, j)
                return not Vec.eq(i, j, pi, pj) and GridHelper.manhattanDistance(i, j, pi, pj) <= distance and not controller.map:get(i, j):blocked()
            end,
        }
    end

    if distance ~= 1 and distance ~= 2 then
        error('Please create description for walk ', distance)
    end

    return Walk
end

return WalkCreator
