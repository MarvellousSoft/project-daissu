local ELEMENT = require "classes.primitives.element"
local Class = require "extra_libs.hump.class"
local Vector = require "extra_libs.hump.vector"
local Util = require "util"
local Map = require "classes.map.map"
local MapView = require "classes.map.map_view"
local Controller = require "classes.map.controller"
local DieHelper = require "classes.die.helper"
local TurnSlots = require "classes.turn_slots.turn_slots"
local TurnSlotsView = require "classes.turn_slots.turn_slots_view"
local DiceArea = require "classes.dice_area"
local Actions = require "classes.actions"

local Match = Class {
    __includes = {ELEMENT}
}

function Match:init(rows, columns, pos, cell_size, w, h, players_info)
    ELEMENT.init(self)
    self.state = 'not started'
    self.pos = pos
    self.w, self.h = w, h
    local map = Map(rows, columns)
    self.map_view = MapView(map, pos + Vector((w - cell_size * columns) / 2,
                           (h - cell_size * rows) / 2), cell_size)
    self.controllers = {}
    self.turn_slots = {}
    self.dice_areas = {}

    -- Assuming two players for now
    assert(#players_info == 2)
    self.controllers[1] = Controller(map, "orange", unpack(players_info[1]))
    self.controllers[2] = Controller(map, "purple",unpack(players_info[2]))
    local d_w, d_h = DieHelper.getDieDimensions()
    -- Taking margins into account
    d_h = d_h + 6
    local t_slots_y = pos.y + h - d_h - 40
    local t_slot_w = (w - 20) / 2
    local t_slot_h = d_h + 30
    self.turn_slots[1] = TurnSlotsView(TurnSlots(6), Vector(pos.x + 5, t_slots_y),
                                       t_slot_w, t_slot_h, "orange")
    self.turn_slots[2] = TurnSlotsView(TurnSlots(6), Vector(pos.x + w / 2 + 5, t_slots_y),
                                       t_slot_w, t_slot_h, "purple")

    local dice_area_w_gap = 35
    local dice_area_h_gap = 35
    local dice_area_h = h - 260 - (d_h + 20)
    local dice_area_w = (w - cell_size * columns) / 2 - 2*dice_area_w_gap
    local dice_area_y = t_slots_y - dice_area_h_gap - dice_area_h
    self.dice_areas[1] = DiceArea(8, Vector(dice_area_w_gap, 220), dice_area_w, dice_area_h)
    self.dice_areas[2] = DiceArea(6, Vector(w - dice_area_w - dice_area_w_gap, 220), dice_area_w, dice_area_h)

    self.hide_player = {}
    self.hide_player[1] = false
    self.hide_player[2] = false

    self.number_of_turns = 1

    self.active_slot = false --Which slot is being played at the moment

    self.action_input_handler = nil

    self:register("L0", nil, "match")
end

function Match:draw()
    --Draw grid
    self.map_view:draw(self)

    --Draw dice area
    for i, dice_area in ipairs(self.dice_areas) do
        if not self.hide_player[i] then
            dice_area:draw()
        end
    end

    --Draw turn slots
    local start_p = self:startingPlayer()
    for i, turn_slots in ipairs(self.turn_slots) do
        if not self.hide_player[i] then
            turn_slots:draw((self.state ~= 'playing turn' and start_p == i), i == 1 and 'right' or 'left')
        end
    end

    --Draw which is the current action
    if self.active_slot then
        local player_i, action_i = self:getCurrentActiveSlot()
        self.turn_slots[player_i]:drawCurrentAction(action_i)
    end

end

function Match:start()
    assert(self.state == 'not started')
    self.state = 'waiting for turn'
end

-- This recursively plays each action in a turn
local function playTurnRec(self, player_actions, order, player_i, action_i, size, callback)
    local p_i = order[player_i]
    -- All actions have been played
    if action_i > size then
        callback()
        self.active_slot = false
        self.number_of_turns = self.number_of_turns + 1
        return
    end
    -- All actions of this index have been played
    if p_i == nil then return playTurnRec(self, player_actions, order, 1, action_i + 1, size, callback) end

    self.active_slot = {p_i, action_i}

    local action = player_actions[p_i][action_i]
    print('Action ' .. action_i .. ' for Player ' .. p_i .. ' = ' .. action)
    if action ~= 'none' then
        Actions.executeAction(self, action, self.controllers[p_i], function()
            playTurnRec(self, player_actions, order, player_i + 1, action_i, size, callback)
        end)
    else
        return playTurnRec(self, player_actions, order, player_i + 1, action_i, size, callback)
    end
end

-- player_actions is a list of lists, the i-th with the actions of the i-th player
-- order is a list with the order of the players
function Match:playTurnFromActions(player_actions, order)
    assert(#player_actions == #self.controllers)
    assert(self.state == 'waiting for turn')
    self.state = 'playing turn'
    Match:createOpponentDice(player_actions)
    local size = math.max(unpack(Util.map(player_actions, function(list) return #list end)))
    playTurnRec(self, player_actions, order, 1, 1, size, function()
        self.state = 'waiting for turn'
    end)
end

function Match:toggleHide(player)
    self.hide_player[player] = not self.hide_player[player]
    local dice_area = self.dice_areas[player]
    for i, die in ipairs(dice_area:getDice()) do
        die.view.invisible = not die.view.invisible
    end
    local turn_slot_view = self.turn_slots[player]
    for i, die in ipairs(turn_slot_view:getDice()) do
        die.view.invisible = not die.view.invisible
    end
end

function Match:playTurn()
    local invert = self:startingPlayer() == 2
    local actions = {}
    local order = {}
    for i, turn_slots in ipairs(self.turn_slots) do
        actions[i] = {}
        for j, die_slot in ipairs(turn_slots:getObj().slots) do
            actions[i][j] = die_slot.die and die_slot.die:getCurrent() or 'none'
        end
        if invert then
            order[i] = #self.turn_slots - i + 1
        else
            order[i] = i
        end
    end
    self:playTurnFromActions(actions, order)
end

--Get first available slot from a player's turn slots, if any
function Match:getAvailableTurnSlot(player)
    local turn_slot_view = self.turn_slots[player]
    for i, slot in ipairs(turn_slot_view:getObj().slots) do
        if not slot:getDie() then
            return slot
        end
    end

    return nil
end

--Get first available slot from a player's dice area, if any
function Match:getAvailableDiceAreaSlot(player)
    local dice_area = self.dice_areas[player]
    for i, slot_view in ipairs(dice_area.die_slots) do
        local slot = slot_view:getObj()
        if not slot:getDie() then
            return slot
        end
    end

    return nil
end

--Return which slot has an active action being processed, if any
function Match:getCurrentActiveSlot()
    if self.active_slot then
        return unpack(self.active_slot)
    else
        return false
    end
end

function Match:startingPlayer()
    if self.number_of_turns%2 == 1 then
        return 1
    else
        return 2
    end
end

function Match:mousepressed(x, y, but, ...)
    for i, dice_area in ipairs(self.dice_areas) do
        dice_area:mousepressed(x, y, but, ...)
    end
    if but ~= 1 then return end
    local i, j = self.map_view:getTileOnPosition(Vector(x, y))
    if i and self.action_input_handler and self.action_input_handler:accept(i, j) then
        self.action_input_handler:finish(i, j)
        self.action_input_handler = nil
    end
end

--Iterate for all other players and create dice for their corresponding actions
function Match:createOpponentDice(player_actions)
    for i, actions in ipairs(player_actions) do
        if self.controllers[i].source == 'remote' then
            for j, action in ipairs(actions) do
                if action ~= "none" then
                    local diev = DieView(Die({action}, 1), 50, 30, Color.green()):register("L2", "die_view")
                    local die = diev:getObj()
                    local slot = self.turn_slots[i]:getObj():getSlot()
                    slot:putDie(die)
                end
            end
        end
    end
end

return Match
