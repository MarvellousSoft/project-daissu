local Class = require "common.extra_libs.hump.class"
local DRAWABLE = require "classes.primitives.drawable"
local assets = require "assets"

local Background = Class{
    __includes = {DRAWABLE},
    init = function(self)
        self.image = assets.images.background
        self.sx = WIN_W/self.image:getWidth()
        self.sy = WIN_H/self.image:getHeight()

        self.tp = "background"
    end
}

function Background:draw()
    love.graphics.setColor(255,255,255)
    love.graphics.draw(self.image, 0, 0, nil, self.sx, self.sy)
end

return Background
