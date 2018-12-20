local GridHelper = require "common.map.grid_helper"

local Shove = {}

function Shove.applyAction(map, player, di, dj)
    local tile = player.tile:getCloseTile(map, di, dj)
    if not tile then return end
    tile:applyDamage(1)
    if tile.obj then
        GridHelper.pushObject(map, tile.i, tile.j, di, dj, 2)
    end
end

return Shove
