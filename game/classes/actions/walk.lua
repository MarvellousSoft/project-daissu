local Class = require "extra_libs.hump.class"
local Timer = require "extra_libs.hump.timer"
local Vec = require "extra_libs.hump.vector-light"

local dir = {
    [0] = {-1, 0},
    [1] = {0, 1},
    [2] = {1, 0},
    [3] = {0, -1}
}

local Walk = {}

function Walk.showAction(controller, callback)
    local c = controller
    local tile = c.map:get(Vec.add(c.i, c.j, unpack(dir[c.player.dir])))
    if tile and not tile:blocked() then
        Timer.tween(1, c.player, {dx = dir[c.player.dir][2], dy = dir[c.player.dir][1]}, 'in-out-quad', callback)
    else
        callback()
    end
end

function Walk.applyAction(controller)
    local c = controller
    local tile = c.map:get(Vec.add(c.i, c.j, unpack(dir[c.player.dir])))
    if not tile or tile:blocked() then
        print("Movement is invalid")
    else
        c.map:get(c.i, c.j):setObj(nil)
        tile:setObj(c.player)
        c.i, c.j = Vec.add(c.i, c.j, unpack(dir[c.player.dir]))
    end
end

function Walk.needInput()
    return false
end

return Walk
