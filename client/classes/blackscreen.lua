local Color     = require "classes.color.color"
local Class     = require "common.extra_libs.hump.class"
local Gamestate = require "common.extra_libs.hump.gamestate"
local ELEMENT   = require "classes.primitives.element"

local BlackScreen = Class{
    __includes = {ELEMENT},
    init = function(self)
        ELEMENT.init(self)

        self.alpha = 0
        self.speed = 500 --How fast to fadein/fadeout
        local target_a = 220
        self:addTimer("enter", MAIN_TIMER, "tween", target_a/self.speed, self, {alpha = target_a}, "out-quad")

        self.closing = false --If this blackscreen is fading out

        self.tp = "blackscreen"
    end
}

function BlackScreen:draw()
    love.graphics.setColor(0,0,0,self.alpha)
    love.graphics.rectangle("fill", 0, 0, WIN_W, WIN_H)
end

function BlackScreen:kill()
    if self.closing then return end
    self.closing = true
    self:removeTimer("enter", MAIN_TIMER)
    self:addTimer("closing", MAIN_TIMER, "tween", self.alpha/self.speed, self, {alpha = 0}, 'out-quad',
                  function()
                      self:destroy()
                  end)
end

return BlackScreen
