local ELEMENT = require "classes.primitives.element"
local Class   = require "extra_libs.hump.class"

local funcs = {}

--CLASS DEFINITION--

local Die = Class{
    __includes={ELEMENT}
}

function Die:init(sides)
    ELEMENT.init(self)
    self.num_sides = #sides --Number of sides this die has
    self.sides = sides --Array of strings contaning what every side has
    self.current_side = 1
end

--CLASS FUNCTIONS--

--Returns current face-up side
function Die:getCurrent()
    return self.sides[self.current_side]
end

--Randomize current up side and returns the result
function Die:roll()
    self.current_side = love.math.random(1,self.num_sides)
    return self:getCurrent()
end

--UTILITY FUNCTIONS--
function funcs.new(sides)
    return Die(sides)
end

return funcs
