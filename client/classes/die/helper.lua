--Some auxiliary functions regarding die

local f = {}

function f.getDimensions()
    return 50, 50
end

function f.getUnderside()
    local w, h = f.getDimensions()
    return h/6
end

function f.getDieSlotMargin()
    return 8
end


return f
