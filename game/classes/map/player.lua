local Class = require "extra_libs.hump.class"
local Font  = require "font"

--[[
    This is a player drawn in the map
]]
local Player = Class {}

function Player:init()
    -- 0 = up, 1 = right, 2 = down, 3 = left
    self.dir = 0
    self.health = 5
    self:resetAnimation()
end

function Player:resetAnimation()
    -- Used to show movement of the player
    self.dx, self.dy = 0, 0
    -- Used to show player rotating
    self.d_dir = 0
end

function Player:rotate(dir)
    self.dir = (self.dir + dir + 4) % 4
end

function Player:applyDamage(dmg)
    self.health = self.health - dmg
end

function Player:drawOnGrid(x, y, size)
    x, y = x + self.dx * size, y + self.dy * size
    local dir = self.dir + self.d_dir
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle('fill', x + size / 2, y + size / 2, size * .4)
    love.graphics.setColor(0, 255, 0)
    love.graphics.push()
    love.graphics.translate(x + size / 2, y + size / 2)
    love.graphics.rotate(dir * math.pi / 2)
    love.graphics.circle('fill', 0, -size / 4, size * .15)
    love.graphics.pop()
    love.graphics.setColor(0, 0, 0)
    Font.set("regular", 20)
    love.graphics.printf('' .. self.health, x, y + size / 2, size, 'center')

end

return Player
