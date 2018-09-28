local Class = require "extra_libs.hump.class"

--[[
    This is a player drawn in the map
]]
local Player = Class {}

function Player:init()
    -- 0 = up, 1 = right, 2 = down, 3 = left
    self.dir = 0
end

function Player:rotate(dir)
    self.dir = (self.dir + dir + 4) % 4
end

function Player:drawOnGrid(x, y, size)
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle('fill', x + size / 2, y + size / 2, size * .4)
    love.graphics.setColor(0, 255, 0)
    love.graphics.push()
    love.graphics.translate(x + size / 2, y + size / 2)
    love.graphics.rotate(self.dir * math.pi / 2)
    love.graphics.circle('fill', 0, -size / 4, size * .15)
    love.graphics.pop()

end

return Player
