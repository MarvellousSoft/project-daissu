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
    self.slot = nil
end

--CLASS FUNCTIONS--

--Returns current face-up side action
function Die:getCurrent()
    return self.sides[self.current_side]
end

--Returns number of current face-up side
function Die:getCurrentNum()
    return self.current_side
end

--Returns array of actions on each side
function Die:getSides()
    return self.sides
end

--Returns number of sides
function Die:getNumSides()
    return self.num_sides
end

--Randomize current up side and returns the result
function Die:roll()
    self.current_side = love.math.random(1,self.num_sides)
    self.view:rollAnimation()
    return self:getCurrent()
end

return Die
