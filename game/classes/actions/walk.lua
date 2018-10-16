local Class = require "extra_libs.hump.class"
local Timer = require "extra_libs.hump.timer"
local Vec = require "extra_libs.hump.vector-light"
local Util = require "util"

local dir = {
    [0] = {-1, 0},
    [1] = {0, 1},
    [2] = {1, 0},
    [3] = {0, -1}
}

local Walk = {}

function Walk.showAction(controller, callback, i, j)
    local c = controller
    local tile = c.map:get(i, j)
    local fun = function()
        Walk.applyAction(c, i, j)
        c.player:resetAnimation()
        if callback then callback() end
    end
    if tile and not tile:blocked() then
        Timer.tween(1, c.player, {dx = j - c.j, dy = i - c.i}, 'in-out-quad', fun)
    else
        fun()
    end
end

function Walk.applyAction(controller, i, j)
    local c = controller
    local tile = c.map:get(i, j)
    if not tile or tile:blocked() then
        print("Movement is invalid")
    else
        c.map:get(c.i, c.j):setObj(nil)
        tile:setObj(c.player)
        c.i, c.j = i, j
    end
end

function Walk.getInputHandler(controller, callback)
    local c = controller
    return {
        accept = function(i, j)
            return Util.manhattanDistance(i, j, c.i, c.j) == 1
        end,
        finish = function(i, j)
            Walk.showAction(c, callback, i, j)
        end
    }
end

return Walk
