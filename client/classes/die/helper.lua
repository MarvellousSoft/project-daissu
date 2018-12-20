local Color = require "classes.color.color"
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

local default_color_for_types = {
    attack   = Color.red(),
    movement = Color.green(),
    utility  = Color.yellow(),
    fake     = Color.new(150, 150, 150)
}

function f.getTypeColor(type)
    return default_color_for_types[type]
end

return f
