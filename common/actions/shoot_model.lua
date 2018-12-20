local GridHelper = require "common.map.grid_helper"

local Shoot = {}

function Shoot.applyAction(map, player, di, dj)
    local pi, pj = player.tile:getPosition()
    GridHelper.applyCallbackOnDirection(pi, pj, di, dj, map, function(tile)
        if tile ~= nil then tile:applyDamage(1) end
        return tile ~= nil and not tile:blocked()
    end)
end

return Shoot
