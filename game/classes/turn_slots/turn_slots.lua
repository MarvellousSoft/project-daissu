local Class = require "extra_libs.hump.class"
local DieSlot = require "classes.die.die_slot"

local TurnSlots = Class {}

-- n: How many slots there are
function TurnSlots:init(n)
    self.slots = {}
    for i = 1, n do
        self.slots[i] = DieSlot("turn")
    end
end

function TurnSlots:getSlot(i)
    return self.slots[i] 
end

return TurnSlots
