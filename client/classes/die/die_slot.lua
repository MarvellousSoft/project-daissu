local ELEMENT = require "classes.primitives.element"
local Class   = require "common.extra_libs.hump.class"
local Vector  = require "common.extra_libs.hump.vector"

local funcs = {}

--CLASS DEFINITION--

local DieSlot = Class{
    __includes={ELEMENT}
}

function DieSlot:init(type)
    ELEMENT.init(self)
    self.die = nil --Which die is on this slot. nil if none.
    self.type = type --What type of slot this is
end

--CLASS FUNCTIONS--

--Put a die in this slot, remove previous die and update position
function DieSlot:putDie(die)
    if self.die then self:removeDie() end
    self.die = die
    assert(die.slot == nil)
    self.die.slot = self
    local die_view = self.die.view

    --Create animation that moves die to this slot
    die_view.is_moving = true
    local tpos = Vector(0,0)
    tpos.x = self.view.pos.x + self.view.margin
    tpos.y = self.view.pos.y + self.view.margin
    local d = die_view.pos:dist(tpos)/die_view.move_speed
    die_view:removeTimer("moving")
    die_view:addTimer("moving", MAIN_TIMER, "tween", d, die_view.pos,
                     {x = tpos.x, y = tpos.y}, 'out-quad',
                     function ()
                         die_view.is_moving = false
                     end
    )
end

function DieSlot:removeDie()
    self.die.slot = nil
    self.die = nil
end

function DieSlot:getDie()
    return self.die
end

return DieSlot
