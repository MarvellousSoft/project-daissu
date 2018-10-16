local Class = require "extra_libs.hump.class"
local Font  = require "font"

--[[
    This is a player drawn in the map
]]
local Player = Class {}

function Player:init(color)
    -- 0 = up, 1 = right, 2 = down, 3 = left
    self.dir = 0
    self.health = 5
    self:resetAnimation()
    self.image = IMG["player_"..color]

    self.font = Font.get("regular", 25)
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
    --Centralize player image
    local ix = x + size/2 - self.image:getWidth()/2
    local iy = y + size/2 - self.image:getHeight()/2
    --Apply movement
    ix, iy = ix + self.dx * size, iy + self.dy * size
    x, y = x + self.dx * size, y + self.dy * size

    --Draw player image
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.image, ix, iy)

    --Draw health
    local text = '' .. self.health
    local fw = self.font:getWidth(text)
    local fh = self.font:getHeight(text)
    Font.set(self.font)
    love.graphics.setColor(255, 0, 0)
    love.graphics.print(text, x + size/2 - fw/2, y + size/2 - fh/2)

end

return Player
