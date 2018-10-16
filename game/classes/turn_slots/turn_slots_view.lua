local Class = require "extra_libs.hump.class"
local Vector = require "extra_libs.hump.vector"
local View = require "classes.primitives.view"
local DieSlotView = require "classes.die.die_slot_view"
local DieHelper = require "classes.die.helper"

local TurnSlotsView = Class {
    __includes = {View}
}

function TurnSlotsView:init(obj, pos, w, h, color)
    View.init(self, obj)
    local slots_n = #obj.slots
    local d_w, d_h = DieHelper.getDieDimensions()

    -- Accounting for margin in DieSlots
    d_w = d_w + 2*DieHelper.getDieSlotMargin()
    d_h = d_h + 2*DieHelper.getDieSlotMargin()

    for i, slot in ipairs(obj.slots) do
        local view = DieSlotView(slot, Vector(10 + pos.x + (i - 1) * (w - 20 - d_w) / (slots_n - 1), pos.y + (h - d_h)/2))
        view:setSubtype("die_slot_view")
    end
    self.pos = pos
    self.w, self.h = w, h
    self.image = IMG["turn_slots_"..color]
    self.iw = self.w/self.image:getWidth()
    self.ih = self.h/self.image:getHeight()

end

function TurnSlotsView:draw()
    --Draw turn slots background
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(self.image, self.pos.x, self.pos.y, nil,
                       self.iw, self.ih)

    --Draw each slot
    for i, slot in ipairs(self:getObj().slots) do
        slot.view:draw()
    end
end

--Return all dice in its slots
function TurnSlotsView:getDice()
    local t = {}
    for i, slot in ipairs(self:getObj().slots) do
        if slot:getDie() then
            table.insert(t,slot:getDie())
        end
    end
    return t
end

return TurnSlotsView