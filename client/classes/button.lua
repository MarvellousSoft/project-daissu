local DRAWABLE    = require "classes.primitives.drawable"
local Class       = require "common.extra_libs.hump.class"
local DieSlot     = require "classes.die.die_slot"
local DieSlotView = require "classes.die.die_slot_view"
local Color       = require "classes.color.color"
local Font        = require "font"
local i18n        = require "i18n"

local funcs = {}

--CLASS DEFINITION--

local Button = Class{
    __includes={DRAWABLE}
}

function Button:init(x, y, w, h, text_label, func)
    DRAWABLE.init(self, x, y, Color.purple())

    self.w = w
    self.h = h
    self.w_gap = 7
    self.h_gap = 2
    self.image = IMG.button
    self.image_pressed = IMG.button_pressed
    self.image_locked = IMG.button_locked
    self.iw = w/self.image:getWidth()
    self.ih = h/self.image:getHeight()

    self.text = "dummy_text"
    self:setText(text_label)

    self.func = func

    self.locked = false

    self.mouse_over = false
    self.hover_color = Color.new(230,230,230)

    self.pressed_down = false

    self.text_color = Color.black()
    self.text_y_offset = -1.5

end

function Button:setText(text_label)
    local text = i18n("ui/button/"..text_label)
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
    if self.mouse_over then
        Color.set(self.hover_color)
    else
        Color.set(Color.white())
    end
    local image
    if self.locked then
        image = self.image_locked
    elseif self.pressed_down then
        image = self.image_pressed
    else
        image = self.image
    end
    lg.draw(image, self.pos.x, self.pos.y, nil, self.iw, self.ih)

    --Draw text aligned to center of button
    Color.set(self.text_color)
    local font = self.font
    local tw = font:getWidth(self.text)
    local th = font:getHeight(self.text)
    local offset
    if self.pressed_down then
        offset = -self.text_y_offset*self.ih
    else
        offset = self.text_y_offset*self.ih
    end
    Font.set(font)
    lg.print(self.text,
             self.pos.x + self.w/2 - tw/2,
             self.pos.y + self.h/2 - th/2 + offset)
end

function Button:mousepressed(x, y, button)
    if self.locked then return end
    if self:collidesPoint(x,y) then
        self.pressed_down = true
    end
end

function Button:mousereleased(x, y, button)
    if self.locked then return end
    if self.pressed_down and self:collidesPoint(x,y) then
        self.func()
    end
    self.pressed_down = false
end

function Button:mousemoved(x, y, dx, dy)
    if self.locked then return end
    if self:collidesPoint(x,y) then
        self.mouse_over = true
    else
        self.mouse_over = false
    end
end

--COLLISION FUNCTIONS--

--Checks if given point(x,y) collides with this button
function Button:collidesPoint(x,y)
    local s = self
    return x >= s.pos.x and x <= s.pos.x + s.w and
           y >= s.pos.y and y <= s.pos.y + s.h
end

function Button:lock()
    self.locked = true
    self.mouse_over = false
end

function Button:unlock()
    self.locked = false
end

return Button
