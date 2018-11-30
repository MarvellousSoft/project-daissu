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

    self.bag_pos = pos + Vector(30, 30)
    self.grave_pos = pos + Vector(w - 30, 30)

    self.match = match

    self.bag = Archetypes.getBaseBag(archetype, match.local_id)
    self.dice_views = {}
    self.grave = {}

    self.extra_views = {}

    self:shuffleBag()

    self.picked_die = nil
end

function PlayerArea:shuffleBag()
    local bag = self.bag
    local n = #bag
    for i = 1, n do
        local j = love.math.random(i, n)
        bag[i], bag[j] = bag[j], bag[i]
    end
end

-- In the future, this should probably have an animation,
-- and thus receive a callback to call when it ends
function PlayerArea:shuffleGraveIntoBag()
    assert(self.bag[1] == nil)
    for i, die in ipairs(self.grave) do
        table.insert(self.bag, die)
    end
    self.grave = {}
    self:shuffleBag()
end

function PlayerArea:grab(count)
    for i = 1, count do
        if self.bag[1] == nil then
            self:shuffleGraveIntoBag()
        end
        local slot = self:getAvailableMatSlot()
        if slot == nil then return end
        local die = table.remove(self.bag)
        if die == nil then return end
        local die_view = DieView(die, 0, 0, die.color or Color.new(180,180,180))
        die_view.pos = self.bag_pos:clone()
        die_view.sx, die_view.sy = 0.1, 0.1
        die:roll()
        table.insert(self.dice_views, die_view)
        slot:putDie(die, false)
    end
end

function PlayerArea:draw()
    local start_p = self.match:startingPlayer()
    self.mat:draw()
    self.turn_slots.view:draw(start_p == self.match.local_id, 'left')

    for view in pairs(self.extra_views) do
        view:draw()
    end

    for i, die in ipairs(self.dice_views) do
        if die ~= self.picked_die then
            die:draw()
        end
    end

    if self.picked_die then
        self.picked_die:draw()
    end
end

function PlayerArea:update(dt)
    for i, die in ipairs(self.dice_views) do
        die:update(dt)
    end
    for view in pairs(self.extra_views) do
        view:update(dt)
    end
end

function PlayerArea:mousemoved(x, y, dx, dy)
    if self.picked_die and self.match.state == 'choosing actions' then
        self.picked_die.pos.x = self.picked_die.pos.x + dx
        self.picked_die.pos.y = self.picked_die.pos.y + dy
    end
end

function PlayerArea:mousepressed(x, y, but)
    if not self.picked_die and self.match.state == 'choosing actions' then
        for i, die in ipairs(self.dice_views) do
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

function PlayerArea:destroyPlayedDice()
    local all_dice = {}
    for i, die_view in ipairs(self.dice_views) do
        all_dice[die_view:getObj()] = true
    end
    for i, slot in ipairs(self.turn_slots.slots) do
        if slot:getDie() then
            local die = slot:getDie()
            all_dice[die] = nil -- removing
            self.extra_views[die.view] = true
            die.view:slideTo(self.grave_pos, false)
            MAIN_TIMER:tween(0.4, die.view, {sx = 0.01, sy = 0.01}, 'out-quad', function()
                self.extra_views[die.view] = nil
                die.view:setObj(nil)
            end)
            slot:removeDie()
            table.insert(self.grave, die)
        end
    end
    self.dice_views = {}
    for die in pairs(all_dice) do
        table.insert(self.dice_views, die.view)
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
    if self.picked_die and but == 1 and self.match.state == 'choosing actions' then
        local die = self.picked_die
        self.picked_die = nil
        die:handleUnpick(self)
    end
end

return PlayerArea
