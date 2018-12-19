local Class         = require "common.extra_libs.hump.class"
local Vector        = require "common.extra_libs.hump.vector"
local Gamestate     = require "common.extra_libs.hump.gamestate"
local TurnSlots     = require "classes.turn_slots.turn_slots"
local TurnSlotsView = require "classes.turn_slots.turn_slots_view"
local Mat           = require "classes.match.mat"
local Archetypes    = require "classes.archetypes"
local DieView       = require "classes.die.die_view"
local Color         = require "classes.color.color"
local Fonts         = require "font"
local PlayerData    = require "classes.match.player_data"
local Util          = require "common.util"

local PlayerArea = Class {}

function PlayerArea:init(pos, w, h, match, color, archetype)
    local map = match.map_view
    local columns = map:getObj().columns
    local rows = map:getObj().rows
    local map_h = map.cell_size * rows
    local map_w = map.cell_size * columns
    -- Taking margins into account
    local t_slot_w, t_slot_h = w - 10, 90
    local t_slots_pos = Vector(pos.x, pos.y + h - t_slot_h)
    self.turn_slots = TurnSlots(6, match.local_id)
    TurnSlotsView(self.turn_slots, t_slots_pos, t_slot_w, t_slot_h, color)

    self.mat = Mat(self, 8, Vector(pos.x, pos.y), w - 10, h - t_slot_h - 20, local_id)

    self.match = match

    self.player_data = PlayerData(archetype)

    self.dice_views = {}
    self.extra_views = {}

    self.picked_die = nil
    self.picked_die_delta = nil
end

function PlayerArea:draw()
    local start_p = self.match.match:startingPlayer()
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

function PlayerArea:grab(count)
    local co = Util.wrap(function() self.player_data:grab(count) end)
    while true do
        local die = co()
        if not die then break end
        local slot = self:getAvailableMatSlot()
        assert(slot)
        local die_view = DieView(die, 0, 0)
        die_view.pos = self.mat:getBagPosition()
        die_view.sx, die_view.sy = 0.1, 0.1
        die_view:rollAnimation()
        table.insert(self.dice_views, die_view)
        slot:putDie(die, false)
    end
end

function PlayerArea:refillRerolls()
    self.player_data:refillRerolls()
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
    local ok_state = self.match.state == 'choosing actions'
    if self.picked_die and ok_state then
        self.picked_die.pos.x = x + self.picked_die_delta.x
        self.picked_die.pos.y = y + self.picked_die_delta.y
        self:updateSlotHighlight(self.picked_die)
    end
end

function PlayerArea:mousepressed(x, y, but)
    local ok_state = self.match.state == 'choosing actions'
    local ctrl = love.keyboard.isDown('lctrl', 'rctrl')
    if not self.picked_die then
        for i, die in ipairs(self.dice_views) do
            if die:canInteract() and die:collidesPoint(x, y) then
                if but == 3 or love.keyboard.isDown('lshift', 'rshift') then
                    Gamestate.push(GS.DIE_DESC, die)
                elseif but == 1 and ok_state and ctrl and self.player_data:getRerolls() > 0 then
                    die:rollAnimation()
                    self.player_data:reroll(die:getObj())
                elseif but == 1 and ok_state then
                    self.picked_die = die
                    self.picked_die_delta = die.pos - Vector(x, y)
                    die:handlePick(self)
                elseif but == 2 and ok_state then
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
            self.player_data:sendDieToGrave(die)
            all_dice[die] = nil -- removing
            self.extra_views[die.view] = true
            die.view:slideTo(self.mat:getGravepoolPosition(), false)
            MAIN_TIMER:tween(0.4, die.view, {sx = 0.01, sy = 0.01}, 'out-quad', function()
                self.extra_views[die.view] = nil
                die.view:setObj(nil)
            end)
            slot:removeDie()
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

--Looks at all die slots and checks if one is below given die
function PlayerArea:updateSlotHighlight(die)
    local best_col, best_slot = 0, nil
    for slot in self:allSlots() do
        slot.view.has_die_over = false
        local col = die:collidesRect(slot.view.pos.x, slot.view.pos.y, slot.view.w, slot.view.h)
        if col > best_col then
            best_col, best_slot = col, slot
        end
    end
    if best_col > 0 and best_slot ~= die:getObj().slot then
        best_slot.view.has_die_over = true
    end
end

function PlayerArea:actionsLocked()
    if self.picked_die then
        local die = self.picked_die
        self.picked_die = nil
        die:handleUnpick(self)
    end
end

function PlayerArea:mousereleased(x, y, but)
    local ok_state = self.match.state == 'choosing actions'
    if self.picked_die and but == 1 and ok_state then
        local die = self.picked_die
        self.picked_die = nil
        die:handleUnpick(self)
    end
end

return PlayerArea
