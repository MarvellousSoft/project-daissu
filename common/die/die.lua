local Class   = require "common.extra_libs.hump.class"

local funcs = {}

--CLASS DEFINITION--

local Die = Class {}

function Die:init(sides, type, id)
    self.num_sides = #sides --Number of sides this die has
    self.sides = sides --Array of strings contaning what every side has
    self.current_side = 1
    self.slot = nil
    self.type = type
    self.id = id
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

--Returns an action given its side number
function Die:getSide(number)
    return self.sides[number]
end

--Returns number of sides
function Die:getNumSides()
    return self.num_sides
end

function Die:getType()
    return self.type
end

--Randomize current up side and returns the result
function Die:roll(rng)
    rng = rng or love.math.random
    self.current_side = rng(1, self.num_sides)
    return self.current_side
end

return Die
