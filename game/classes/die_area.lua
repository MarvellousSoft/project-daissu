local DRAWABLE    = require "classes.primitives.drawable"
local Class       = require "extra_libs.hump.class"
local DieSlot     = require "classes.die.die_slot"
local DieSlotView = require "classes.die.die_slot_view"
local Color       = require "classes.color.color"

local funcs = {}

--CLASS DEFINITION--

local DieArea = Class{
    __includes={DRAWABLE}
}

function DieArea:init(x, y)
    DRAWABLE.init(self, x, y, Color.purple())
    local w, h = 400, 400
    self.w = w
    self.h = h

    local dw, dh = DieSlotView.getSize()

    --Create die slots inside this area
    local gap = 30
    self.die_slots = {
        DieSlotView(DieSlot(), x + w/2 - dw/2, y + gap),
        DieSlotView(DieSlot(), x + gap, y + h/3),
        DieSlotView(DieSlot(), x + gap, y + 2*h/3),
        DieSlotView(DieSlot(), x + w - gap - dw, y + h/3),
        DieSlotView(DieSlot(), x + w - gap - dw, y + 2*h/3),
        DieSlotView(DieSlot(), x + w/2 - dw/2, y + h - gap - dh),
    }

    --Put subtype to all slot
    for _, die_slot in ipairs(self.die_slots) do
        die_slot:setSubtype("die_slot_view")
    end
end

--CLASS FUNCTIONS--

function DieArea:draw()
    --Draw bg
    Color.set(self.color)
    love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)

    --Draw slot
    for _, die_slot in ipairs(self.die_slots) do
        die_slot:draw()
    end

end

return DieArea
