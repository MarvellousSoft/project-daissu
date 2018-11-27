local Class = require "common.extra_libs.hump.class"
local Vector = require "common.extra_libs.hump.vector"
local DieHelper = require "classes.die.helper"
local TurnSlots = require "classes.turn_slots.turn_slots"
local TurnSlotsView = require "classes.turn_slots.turn_slots_view"
local DiceArea = require "classes.dice_area"

local PlayerArea = Class {}

function PlayerArea:init(match, cell_size, color)
    local d_w, d_h = DieHelper.getDieDimensions()
    d_h = d_h + 6
    local t_slots_y = match.pos.y + match.h - d_h - 40
    local t_slot_w = (match.w - 20) / 2
    local t_slot_h = d_h + 30
    self.turn_slots = TurnSlotsView(TurnSlots(6, match.local_id), Vector(match.pos.x + 5, t_slots_y), t_slot_w, t_slot_h, color)

    local columns = match.map_view:getObj().columns
    local dice_area_w_gap = 35
    local dice_area_h_gap = 35
    local dice_area_h = match.h - 260 - (d_h + 20)
    local dice_area_w = (match.w - cell_size * columns) / 2 - 2 * dice_area_w_gap
    local dice_area_y = t_slots_y - dice_area_h_gap - dice_area_h
    self.dice_area = DiceArea(8, Vector(dice_area_w_gap, 220), dice_area_w, dice_area_h, local_id)

    self.match = match
end

function PlayerArea:draw()
    self.dice_area:draw()

    local start_p = self.match:startingPlayer()
    self.turn_slots:draw(start_p == self.match.local_id, 'left')
end

return PlayerArea
