local Class = require "extra_libs.hump.class"

--[[
    This is a player drawn in the map
]]
local Player = Class {}

function Player:drawOnGrid(x, y, size)
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle('fill', x + size / 2, y + size / 2, size * .4)
end

return Player
