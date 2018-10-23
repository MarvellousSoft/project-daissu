local Util = require "util"

local GridHelper = {}

local abs = math.abs

function GridHelper.onSameRowOrColumn(i, j, ni, nj)
    return (i ~= ni or j ~= nj) and (i == ni or j == nj)
end

function GridHelper.isDirection(di, dj)
    di, dj = abs(di), abs(dj)
    return (di ~= 0 or dj ~= 0) and (di == 0 or dj == 0)
end

function GridHelper.directionFromTiles(i, j, ni, nj)
    return Util.sign(ni - i), Util.sign(nj - j)
end

-- Applies callback on tiles in the given direction. If the callback returns false it stops.
function GridHelper.applyCallbackOnDirection(i, j, di, dj, map, callback)
    assert(GridHelper.isDirection(di, dj))
    i, j = i + di, j + dj
    local tile = map:get(i, j)
    while tile do
        if not callback(tile, i, j) then return end
        i, j = i + di, j + dj
        tile = map:get(i, j)
    end
end

function GridHelper.manhattanDistance(i, j, ni, nj)
    return abs(ni - i) + abs(nj - j)
end

return GridHelper
