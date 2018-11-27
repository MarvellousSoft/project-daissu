local Class = require "common.extra_libs.hump.class"
local DieSlot = require "classes.die.die_slot"

local TurnSlots = Class {}

-- n: How many slots there are
function TurnSlots:init(n, player_num)
    self.slots = {}
    for i = 1, n do
        self.slots[i] = DieSlot("turn", player_num)
    end
end

--Return how many slots it has
function TurnSlots:getSize()
    return #self.slots
end

function TurnSlots:getSlot(i)
    return self.slots[i]
end

return TurnSlots
