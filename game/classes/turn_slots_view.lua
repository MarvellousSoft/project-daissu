local Class = require "extra_libs.hump.class"
local View = require "classes.primitives.view"
local DieSlotView = require "classes.die.die_slot_view"
local DieHelper = require "classes.die.helper"

local TurnSlotsView = Class {
    __includes = {View}
}

function TurnSlotsView:init(obj, pos, w, h)
    View.init(self, obj)
    local slots_n = #obj.slots
    local d_w, d_h = DieHelper.getDieDimensions()
    -- Accounting for margin in DieSlots
    d_w = d_w + 6
    for i, slot in ipairs(obj.slots) do
        DieSlotView(slot, 10 + pos.x + (i - 1) * (w - 20 - d_w) / (slots_n - 1), pos.y + (h - d_h) / 2)
    end
    self.pos = pos
    self.w, self.h = w, h
end

function TurnSlotsView:draw()
    love.graphics.setColor(200, 20, 20)
    love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.w, self.h)
    for i, slot in ipairs(self:getObj().slots) do
        slot.view:draw()
    end
end

return TurnSlotsView
