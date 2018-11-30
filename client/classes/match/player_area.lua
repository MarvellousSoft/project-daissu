local Class = require "common.extra_libs.hump.class"
local Vector = require "common.extra_libs.hump.vector"
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
    local t_slot_w, t_slot_h = w - 10, 90
    local t_slots_pos = Vector(pos.x + 5, pos.y + h - t_slot_h)
    self.turn_slots = TurnSlots(6, match.local_id)
    TurnSlotsView(self.turn_slots, t_slots_pos, t_slot_w, t_slot_h, color)

    self.mat = Mat(8, Vector(pos.x + 5, pos.y), w - 10, h - t_slot_h - 20, local_id)

    self.match = match

    self.dice = {}
    for i, die in ipairs(Archetypes.getBaseBag(archetype, match.local_id)) do
        table.insert(self.dice, DieView(die, 0, 0, die.color or Color.new(180,180,180)))
        self.mat.slots[i]:putDie(self.dice[i]:getObj(), true)
    end

    self.picked_die = nil
end

function PlayerArea:draw()
    local start_p = self.match:startingPlayer()
    self.mat:draw()
    self.turn_slots.view:draw(start_p == self.match.local_id, 'left')

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
    if self.picked_die and self.match.state ~= 'playing turn' then
        self.picked_die.pos.x = self.picked_die.pos.x + dx
        self.picked_die.pos.y = self.picked_die.pos.y + dy
    end
end

function PlayerArea:mousepressed(x, y, but)
    if not self.picked_die and self.match.state ~= 'playing turn' then
        for i, die in ipairs(self.dice) do
            if not die.is_moving and die:collidesPoint(x, y) then
                if but == 1 then
                    self.picked_die = die
                    die:handlePick(self)
                elseif but == 2 then
                    die:handleRightClick(self)
                end
                return
            end
        end
    end
end

function PlayerArea:getAvailableTurnSlot()
    for i, slot in ipairs(self.turn_slots.slots) do
        if not slot:getDie() then
            return slot
        end
    end
end

function PlayerArea:getAvailableMatSlot()
    for i, slot in ipairs(self.mat.slots) do
        if not slot:getDie() then
            return slot
        end
    end
end

-- Iterator throught the DieSlotView in mat a turn_slots
function PlayerArea:allSlots()
    local da, tl = self.mat.slots, self.turn_slots.slots
    local da_n = #da
    local i = 0
    return function()
        i = i + 1
        if i > da_n then
            return tl[i - da_n] and tl[i - da_n]
        else
            return da[i]
        end
    end
end

function PlayerArea:mousereleased(x, y, but)
    if self.picked_die and but == 1 and self.match.state ~= 'playing turn' then
        local die = self.picked_die
        self.picked_die = nil
        die:handleUnpick(self)
    end
end

return PlayerArea
