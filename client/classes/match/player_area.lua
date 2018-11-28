local Class = require "common.extra_libs.hump.class"
local Vector = require "common.extra_libs.hump.vector"
local DieHelper = require "classes.die.helper"
local TurnSlots = require "classes.turn_slots.turn_slots"
local TurnSlotsView = require "classes.turn_slots.turn_slots_view"
local Mat = require "classes.match.mat"
local Archetypes = require "classes.archetypes"
local DieView = require "classes.die.die_view"
local Color = require "classes.color.color"

local PlayerArea = Class {}

function PlayerArea:init(pos, w, h, match, color, archetype)
    local map = match.map_view
    local columns = map:getObj().columns
    local rows = map:getObj().rows
    local map_h = map.cell_size * rows
    local map_w = map.cell_size * columns
    -- Taking margins into account
    local d_h = DieHelper.getDieDimensions() + 6
    local t_slots_pos = Vector(pos.x + 5, pos.y + h - d_h - 40)
    local t_slot_w = w - 10
    local t_slot_h = d_h + 30
    self.turn_slots = TurnSlotsView(TurnSlots(6, match.local_id), t_slots_pos, t_slot_w, t_slot_h, color)

    self.mat = Mat(8, Vector(pos.x + 5, pos.y), w - 10, h - t_slot_h - 20, local_id)

    self.match = match

    self.dice = {}
    for i, die in ipairs(Archetypes.getBaseBag(archetype, match.local_id)) do
        table.insert(self.dice, DieView(die, 0, 0, Color.green()))
        self.mat.slots[i]:getObj():putDie(self.dice[i]:getObj(), true)
    end

    self.picked_die = nil
end

function PlayerArea:draw()
    local start_p = self.match:startingPlayer()
    self.mat:draw()
    self.turn_slots:draw(start_p == self.match.local_id, 'left')

    for i, die in ipairs(self.dice) do
        if die ~= self.picked_die then
            die:draw()
        end
    end

    if self.picked_die then
        self.picked_die:draw()
    end
end

function PlayerArea:update(dt)
    for i, die in ipairs(self.dice) do
        die:update(dt)
    end
end

function PlayerArea:mousemoved(x, y, dx, dy)
    if self.picked_die then
        self.picked_die.pos.x = self.picked_die.pos.x + dx
        self.picked_die.pos.y = self.picked_die.pos.y + dy
    end
end

function PlayerArea:mousepressed(x, y, but)
    if but ~= 1 or self.picked_die then return end
    for i, die in ipairs(self.dice) do
        if not die.is_moving and die:collidesPoint(x, y) then
            self.picked_die = die
            die:handlePick(self)
            return
        end
    end
end

-- Iterator throught the DieSlotView in mat a turn_slots
function PlayerArea:allSlots()
    local da, tl = self.mat.slots, self.turn_slots:getObj().slots
    local da_n = #da
    local i = 0
    return function()
        i = i + 1
        if i > da_n then
            return tl[i - da_n] and tl[i - da_n].view
        else
            return da[i]
        end
    end
end

function PlayerArea:mousereleased(x, y, but)
    if self.picked_die and but == 1 then
        local die = self.picked_die
        self.picked_die = nil
        die:handleUnpick(self)
    end
end

return PlayerArea
