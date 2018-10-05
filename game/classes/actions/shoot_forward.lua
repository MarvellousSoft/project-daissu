local Class = require "extra_libs.hump.class"
local Vec = require "extra_libs.hump.vector-light"

local ShootForward = {}

function ShootForward.showAction(controller, callback)
    print('pew pew')
    if callback then callback() end
end

local dir = {
    [0] = {-1, 0},
    [1] = {0, 1},
    [2] = {1, 0},
    [3] = {0, -1}
}

function ShootForward.applyAction(controller)
    local c = controller
    local i, j = Vec.add(c.i, c.j, unpack(dir[c.player.dir]))
    local tile = c.map:get(i, j)
    while tile do
        tile:applyDamage(1)
        if tile:blocked() then break end
        i, j = Vec.add(i, j, unpack(dir[c.player.dir]))
        tile = c.map:get(i, j)
    end
end

return ShootForward
