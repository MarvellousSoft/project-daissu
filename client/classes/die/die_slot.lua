local ELEMENT = require "classes.primitives.element"
local Class   = require "common.extra_libs.hump.class"
local Vector  = require "common.extra_libs.hump.vector"

local funcs = {}

--CLASS DEFINITION--

local DieSlot = Class{
    __includes={ELEMENT}
}

function DieSlot:init(type, player_num)
    ELEMENT.init(self)
    self.die = nil --Which die is on this slot. nil if none.
    self.type = type --What type of slot this is
    self.player_num = player_num --From what player id this slot "belongs" to
end

--CLASS FUNCTIONS--

--Put a die in this slot, remove previous die and update position
function DieSlot:putDie(die, snap)
    assert(self.die == nil)
    self.die = die
    assert(die.slot == nil)
    self.die.slot = self

    --Create animation that moves die to this slot
    if self.view then
        self.view:centerDie(snap)
    end
end

function DieSlot:removeDie()
    self.die.slot = nil
    self.die = nil
end

function DieSlot:getDie()
    return self.die
end

function DieSlot:getPlayer()
    return self.player_num
end

return DieSlot
