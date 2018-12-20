local Color     = require "classes.color.color"
local Font      = require "font"
local Class     = require "common.extra_libs.hump.class"
local DRAWABLE  = require "classes.primitives.drawable"

local HoverText = Class{
    __includes = {DRAWABLE},
    init = function(self, x, y, w, h, text, font_size)
        DRAWABLE.init(self, x, y, Color.new(0,0,0,210))

        self.w = w
        self.h = h

        self.h_margin = 4
        self.v_margin = 2

        --Hover effect
        self.magnitude = 3 --How many pixels to hover around the origin
        self.speed = 4 --How fast to hover

        self.text = text
        self.font = Font.get("regular", font_size)
        self.font:setFilter("linear", "linear")
        self.text_color = Color.white()

        self.tp = "hover_text"
    end
}

function HoverText:draw()
    local g = love.graphics
    local offset = math.sin(self.speed*love.timer.getTime())*self.magnitude

    Color.set(self.color)
    g.rectangle("fill", self.pos.x, self.pos.y + offset, self.w, self.h, 3)

    Font.set(self.font)
    Color.set(self.text_color)
    g.print(self.text, self.pos.x + self.h_margin, self.pos.y + self.v_margin + offset)
end

return HoverText
