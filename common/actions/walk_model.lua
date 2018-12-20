local GridHelper = require "common.map.grid_helper"

local function WalkModelCreator(distance)
    local Walk = {}

    function Walk.applyAction(map, player, i, j)
        local pi, pj = player.tile:getPosition()
        GridHelper.moveObject(map, pi, pj, i, j)
    end

    return Walk
end

return WalkModelCreator
