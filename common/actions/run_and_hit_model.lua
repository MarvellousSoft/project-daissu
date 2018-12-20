local GridHelper = require "common.map.grid_helper"

local RunAndHit = {}

function RunAndHit.applyAction(map, player, di, dj)
    local pi, pj = player.tile:getPosition()
    local tile = map:get(pi + di, pj + dj)
    if tile and not tile:blocked() then
        GridHelper.moveObject(map, pi, pj, pi + di, pj + dj)
        tile = map:get(pi + 2 * di, pj + 2 * dj)
        if tile then tile:applyDamage(3) end
    end
end

return RunAndHit
