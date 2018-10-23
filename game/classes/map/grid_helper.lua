local Util = require "util"

local GridHelper = {}

local abs = math.abs
local sign = Util.sign

function GridHelper.onSameRowOrColumn(i, j, ni, nj)
    return (i ~= ni or j ~= nj) and (i == ni or j == nj)
end

function GridHelper.isDirection(di, dj)
    di, dj = abs(di), abs(dj)
    return (di ~= 0 or dj ~= 0) and (di == 0 or dj == 0)
end

function GridHelper.directionFromTiles(i, j, ni, nj)
    return sign(ni - i), sign(nj - j)
end

-- Applies callback on tiles in the given direction. If the callback returns false it stops.
function GridHelper.applyCallbackOnDirection(i, j, di, dj, map, callback)
    assert(GridHelper.isDirection(di, dj))
    i, j = i + di, j + dj
    local tile = map:get(i, j)
    while true do
        if not callback(tile, i, j) or tile == nil then return end
        i, j = i + di, j + dj
        tile = map:get(i, j)
    end
end

function GridHelper.manhattanDistance(i, j, ni, nj)
    return abs(ni - i) + abs(nj - j)
end

function GridHelper.movePlayer(controller, i, j)
    local c = controller
    local map = c.map
    local tile = map:get(c.i, c.j)
    assert(tile and tile.obj ~= nil)
    tile:setObj(nil)
    local new_tile = map:get(i, j)
    assert(new_tile and not new_tile:blocked())
    new_tile:setObj(c.player)
    c.i, c.j = i, j
end

return GridHelper
