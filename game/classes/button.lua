local DRAWABLE    = require "classes.primitives.drawable"
local Class       = require "extra_libs.hump.class"
local DieSlot     = require "classes.die.die_slot"
local DieSlotView = require "classes.die.die_slot_view"
local Color       = require "classes.color.color"
local Font        = require "font"

local funcs = {}

--CLASS DEFINITION--

local Button = Class{
    __includes={DRAWABLE}
}

function Button:init(x, y, w, h, text, func)
    DRAWABLE.init(self, x, y, Color.purple())

    self.w = w
    self.h = h
    self.w_gap = 5
    self.h_gap = 2
    self.text = text

    --Get correct font size based on button size
    i = 40
    repeat
        self.font = Font.get("regular", i)
    until self.font:getWidth(self.text) <= w + 2*self.w_gap and
          self.font:getHeight(self.text) <= h + 2*self.h_gap

    self.func = func

    self.bg_color = Color.white()
    self.bg_outline_color = Color.black()
    self.text_color = Color.black()

end

--CLASS FUNCTIONS--

function Button:draw()
    local lg = love.graphics

    --Draw bg
    Color.set(self.bg_color)
    lg.rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)
    Color.set(self.bg_outline_color)
    lg.rectangle("line", self.pos.x, self.pos.y, self.w, self.h)

    --Draw text aligned to center of button
    Color.set(self.text_color)
    local font = self.font
    local tw = font:getWidth(self.text)
    local th = font:getHeight(self.text)
    Font.set(font)
    lg.print(self.text, self.pos.x + self.w/2 - tw/2, self.pos.y + self.h/2 - th/2)
end

function Button:mousepressed(x, y, button)
    if self:collidesPoint(x,y) then
        self.func()
    end
end

--COLLISION FUNCTIONS--

--Checks if given point(x,y) collides with this button
function Button:collidesPoint(x,y)
    local s = self
    return x >= s.pos.x and x <= s.pos.x + s.w and
           y >= s.pos.y and y <= s.pos.y + s.h
end

return Button
