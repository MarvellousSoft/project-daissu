local DRAWABLE = require "classes.primitives.drawable"
local Color = require "classes.color.color"
local Font  = require "font"
local Class = require "extra_libs.hump.class"

local funcs = {}

--CLASS DEFINITION--

local DieView = Class{
    __includes={DRAWABLE}
}

function DieView:init(die, x, y, color)
    DRAWABLE.init(self, x, y, color, nil,nil,nil)

    self.die = die --Die this view is drawing

    self.w = 50
    self.h = 50
    self.font = Font.get("regular", 30)
end

--CLASS FUNCTIONS--

function DieView:draw()
    Color.set(self.color)
    love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)

    Color.set(Color.white())
    love.graphics.print(self.die:getCurrent(), self.pos.x, self.pos.y)
end

--UTILITY FUNCTIONS--
function funcs.new(die,x,y,color)
    local d = DieView(die,x,y,color)
    d:addElement("L1", "die_view")
    return d
end

return funcs
