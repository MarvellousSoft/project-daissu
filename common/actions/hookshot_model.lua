local GridHelper = require "common.map.grid_helper"

local Hookshot = {}

function whatIsPulledWhere(map, player, di, dj)
    local pi, pj = player.tile:getPosition()
    local tile, ti, tj = GridHelper.firstBlockedPos(map, pi, pj, di, dj)
    if tile ~= nil and tile:blocked() and tile.obj.tile_type ~= 'Player' then
        ti, tj = ti - di, tj - dj
        tile = tile:getCloseTile(map, -di, -dj)
    end
    if tile and tile:blocked() then
        return tile.obj, pi + di, pj + dj
    else
        return player, ti, tj
    end
end

Hookshot.whatIsPulledWhere = whatIsPulledWhere

function Hookshot.applyAction(map, player, di, dj)
    local obj, ni, nj = whatIsPulledWhere(map, player, di, dj)
    GridHelper.moveObject(map, obj.tile.i, obj.tile.j, ni, nj)
    if obj ~= player then
        obj.tile:applyDamage(1)
    end
end

return Hookshot
