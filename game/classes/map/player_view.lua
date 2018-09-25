local Class = require "extra_libs.hump.class"
local View = require "classes.primitives.view"

local PlayerView = Class {
    __includes = {View}
}

function PlayerView:drawOnGrid(x, y, size)
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle('fill', x + size / 2, y + size / 2, size / 2)
end

return PlayerView
