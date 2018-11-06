--Some auxiliary functions regarding die

local f = {}

function f.getDieDimensions()
    return 50, 50
end

function f.getDieUnderside()
    local w, h = f.getDieDimensions()
    return h/6
end

function f.getDieSlotMargin()
    return 8
end


return f
