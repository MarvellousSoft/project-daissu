local log = require "common.extra_libs.log"

local Util = {}

-- maps a vector through a function
function Util.map(vec, func)
    local new = {}
    for i, value in ipairs(vec) do
        new[i] = func(value)
    end
    return new
end

-- returns any element of vec that returns a truthy value for f, otherwise nil
function Util.any(vec, func)
    for _, value in ipairs(vec) do
        if func(value) then
            return value
        end
    end
    return nil
end

function Util.assertNonNil(x)
    assert(x ~= nil)
    return x
end

-- Sign of a number
function Util.sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

-- Is the point in the rectangle?
-- The point is given by two numbers
-- The rectangle may be given by four numbers of by a table
function Util.pointInRect(_x, _y, x, y, w, h)
    if not y then x, y, w, h = x.pos.x, x.pos.y, x.w, x.h end
    return not (_x < x or _x > x + w or _y < y or _y > y + h)
end

local function handleCoroutineYield(ok, ...)
    if not ok then
        log.fatal(...)
        error(debug.traceback(co))
    end
    return ...
end

-- Works like coroutine.wrap but handles errors better (full stack trace)
function Util.wrap(f)
    local co = coroutine.create(f)
    return function(...)
        return handleCoroutineYield(coroutine.resume(co, ...))
    end
end

-- Wrap f in a coroutine and call it continuosly
-- until it is dead (no arguments)
function Util.exhaust(f)
    local co = coroutine.create(f)
    repeat
        handleCoroutineYield(coroutine.resume(co))
    until coroutine.status(co) == 'dead'
end

-- shuffles array with option RNG
function Util.shuffle(vec, rng)
    rng = rng or love.math.random
    local n = #vec
    for i = 1, n do
        local j = rng(i, n)
        vec[i], vec[j] = vec[j], vec[i]
    end
end

-- Get a function that works like math.random
-- But without "outside interference"
function Util.getRNG(seed)
    local rng = love.math.newRandomGenerator(seed)
    return function(...) return rng:random(...) end
end

return Util
