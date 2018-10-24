local Util = require "util"

local GridHelper = {}

local abs = math.abs
local sign = Util.sign

function GridHelper.onSameRowOrColumn(i, j, ni, nj)
    return (i ~= ni or j ~= nj) and (i == ni or j == nj)
end

function GridHelper.isDirection(di, dj)
    di, dj = abs(di), abs(dj)
    return (di == 0 or dj == 0) and (di == 1 or dj == 1)
end

function GridHelper.isInside(i, j, map)
    return map:get(i,j) ~= nil
end

--Get first blocked position going in a direction.
--IMPORTANT: if it hits map bounderies, it will return the last valid position
function GridHelper.firstBlockedPos(map, i, j, di, dj)
    assert(GridHelper.isInside(i, j, map))
    assert(GridHelper.isDirection(di, dj))
    i, j = i + di, j + dj
    local tile
    while true do
        tile = map:get(i, j)
        if not tile or tile:blocked() then
            break
        end
        i, j = i + di, j + dj
    end
    --Go back one tile if it hits the wall
    if tile == nil then
        i, j = i - di, j - dj
    end
    return tile, i, j
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

function GridHelper.maximumAxisDistance(i, j, ni, nj)
    return math.max(abs(ni - i), abs(nj - j))
end

-- Moves object currently at (i, j) to (ni, nj) in map
function GridHelper.moveObject(map, i, j, ni, nj)
    local tile = map:get(i, j)
    assert(tile and tile.obj ~= nil)
    local obj = tile.obj
    tile:setObj(nil)
    local new_tile = map:get(ni, nj)
    assert(new_tile and not new_tile:blocked())
    new_tile:setObj(obj)
end

return GridHelper
