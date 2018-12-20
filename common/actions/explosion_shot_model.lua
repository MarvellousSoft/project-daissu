local GridHelper = require "common.map.grid_helper"

local ExplosionShot = {}

function ExplosionShot.applyAction(map, player, di, dj)
    local pi, pj = player.tile:getPosition()
    local _, ti, tj = GridHelper.firstBlockedPos(map, pi, pj, di, dj)
    for di = -1, 1, 1 do
        for dj = -1, 1, 1 do
            tile = map:get(ti + di, tj + dj)
            if tile then
                local damage = (di == 0 and dj == 0) and 2 or 1
                tile:applyDamage(damage)
            end
        end
    end
end

return ExplosionShot
