local Class  = require "common.extra_libs.hump.class"
local Color  = require "classes.color.color"
local Font   = require "font"
local View   = require "classes.primitives.view"
local assets = require "assets"

local PlayerView = Class {
    __includes = View
}

function PlayerView:init(model, color)
    View.init(self, model)
    self:resetAnimation()
    self.color = color
    self.image = assets.images.characters.player

    self.font = Font.get("regular", 25)
end

function PlayerView:resetAnimation()
    -- Used to show movement of the player
    self.dx, self.dy = 0, 0
end

function PlayerView:drawOnGrid(x, y, size)
    --Centralize player image
    local ix = x + size/2 - self.image:getWidth()/2
    local iy = y + size/2 - self.image:getHeight()/2
    --Apply movement
    ix, iy = ix + self.dx * size, iy + self.dy * size
    x, y = x + self.dx * size, y + self.dy * size

    --Draw player image
    Color.set(self.color)
    love.graphics.draw(self.image, ix, iy)

    --Draw health
    local text = '' .. self.model.health
    local fw = self.font:getWidth(text)
    local fh = self.font:getHeight(text)
    Font.set(self.font)
    love.graphics.setColor(255, 0, 0)
    love.graphics.print(text, x + size/2 - fw/2, y + size/2 - fh/2)
end

return PlayerView
