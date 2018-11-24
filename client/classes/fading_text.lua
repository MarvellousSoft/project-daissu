local Class = require "common.extra_libs.hump.class"
local Element = require "classes.primitives.element"
local Timer = require "common.extra_libs.hump.timer"
local Font = require "font"

local FadingText = Class {
    __includes = {Element}
}

function FadingText:draw()
    Font.set('regular', 20)
    love.graphics.setColor(200, 20, 20, self.alpha)
    love.graphics.print(self.text, self.pos.x, self.pos.y)
end

function FadingText:init(pos, text, time)
    self.pos = pos
    self.text = text
    self.alpha = 255
    Timer.tween(time, self, {alpha = 0}, 'in-linear', function() self:kill() end)
    self:register('L1')
end

return FadingText
