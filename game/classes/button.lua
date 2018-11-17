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
    self.image = IMG.button
    self.iw = w/self.image:getWidth()
    self.ih = w/self.image:getHeight()

    self:setText(text)

    self.func = func

    self.text_color = Color.black()
    self.text_y_offset = 5

end

function Button:setText(text)
    --Get correct font size based on button size
    local i = 40
    repeat
        self.font = Font.get("regular", i)
        i = i - 1
    until self.font:getWidth(text) <= self.w - 2*self.w_gap and
          self.font:getHeight(text) <= self.h - 2*self.h_gap
    self.text = text
end

--CLASS FUNCTIONS--

function Button:draw()
    local lg = love.graphics

    --Draw bg
    Color.set(Color.white())
    lg.draw(self.image, self.pos.x, self.pos.y, nil, self.iw, self.ih)

    --Draw text aligned to center of button
    Color.set(self.text_color)
    local font = self.font
    local tw = font:getWidth(self.text)
    local th = font:getHeight(self.text)
    Font.set(font)
    lg.print(self.text,
             self.pos.x + self.w/2 - tw/2,
             self.pos.y + self.h/2 - th/2 + self.text_y_offset)
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
