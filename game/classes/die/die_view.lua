local DRAWABLE = require "classes.primitives.drawable"
local Color    = require "classes.color.color"
local Font     = require "font"
local Class    = require "extra_libs.hump.class"
local Action   = require "classes.action"

local funcs = {}

--CLASS DEFINITION--

local DieView = Class{
    __includes={DRAWABLE}
}

function DieView:init(die, x, y, color)
    DRAWABLE.init(self, x, y, color, nil,nil,nil)

    self.die = die --Die this view is drawing

    self.w = 50 --Width of die outline
    self.h = 50 --Height of die outline

    self.color_border = Color.new(self.color.r*1.2,self.color.g*1.2,self.color.b*1.2)

    --Loads up icon for every side
    self.side_images = {}
    for i,side in ipairs(die:getSides()) do
        self.side_images[i] = Action.actionImage(side)
    end
end

--CLASS FUNCTIONS--

function DieView:draw()
    local die = self.die
    local g = love.graphics
    --Draw die bg
    Color.set(self.color)
    g.rectangle("fill", self.pos.x, self.pos.y, self.w, self.h, 5, 5)
    g.setLineWidth(4)
    Color.set(self.color_border)
    g.rectangle("line", self.pos.x, self.pos.y, self.w, self.h, 5, 5)

    --Draw die text
    Color.set(Color.white())
    local icon = self.side_images[die:getCurrentNum()]
    g.draw(icon, self.pos.x, self.pos.y, nil, self.w/icon:getWidth(),self.h/icon:getHeight())
end

--UTILITY FUNCTIONS--

return DieView
