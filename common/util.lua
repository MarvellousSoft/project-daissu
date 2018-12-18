local util = {}

-- maps a vector through a function
function util.map(vec, func)
    local new = {}
    for i, value in ipairs(vec) do
        new[i] = func(value)
    end
    return new
end

function util.sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

function util.pointInRect(_x, _y, x, y, w, h)
    if not y then x, y, w, h = x.pos.x, x.pos.y, x.w, x.h end
    return not (_x < x or _x > x + w or _y < y or _y > y + h)
end

return util
