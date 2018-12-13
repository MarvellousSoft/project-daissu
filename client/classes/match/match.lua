local ELEMENT = require "classes.primitives.element"
local Class = require "common.extra_libs.hump.class"

local Vector = require "common.extra_libs.hump.vector"
local Util = require "util"
local Map = require "classes.map.map"
local MapView = require "classes.map.map_view"
local Controller = require "classes.map.controller"
local DieHelper = require "classes.die.helper"
local TurnSlots = require "classes.turn_slots.turn_slots"
local TurnSlotsView = require "classes.turn_slots.turn_slots_view"
local Actions = require "classes.actions"
local Die = require "classes.die.die"
local DieView = require "classes.die.die_view"
local Color = require "classes.color.color"
local PlayerArea = require "classes.match.player_area"
local ActionList = require "classes.match.action_list"
local Button = require "classes.button"
local ScrollWindow = require "classes.ui.scroll_window"

local Client = require "classes.net.client"

local Match = Class {
    __includes = {ELEMENT},
    starting_positions = {
        nil, -- 1 player
        {{2,2},{4,4}}, --2 players
        {{1,1},{3,3},{5,5}}, --3 players
        {{2,2},{4,4},{5,1},{1,5}}, --4 players
        {{1,1},{2,3},{3,5},{4,2},{5,4}}, --5 players
    }
}

function Match:init(rows, columns, pos, cell_size, w, h, players_info, local_id, archetype)
    ELEMENT.init(self)
    self.state = 'not started'
    self.pos = pos
    self.w, self.h = w, h
    self.local_id = local_id
    local map = Map(rows, columns)
    local map_w = cell_size * columns
    local map_h = cell_size * rows
    local map_pos = pos + Vector((w - map_w) / 2,(h - map_h) / 2)
    self.map_view = MapView(map, map_pos, cell_size)
    self.controllers = {}
    self.turn_slots = {}

    local n_players = #players_info
    assert(n_players > 1)
    assert(n_players <= 5)

    self.colors = {  --Colors for each player
        Color.new(133, 255, 86), --Chartoise green
        Color.new(86, 195, 255), --Blue sky
        Color.new(255, 104, 197),--Taffy pink
        Color.new(255, 182, 86), --Orange
        Color.new(201, 86, 255), --Purple
    }

    local player_info_h = 100
    local margin = 5
    local pa_pos = Vector(margin, player_info_h + margin)
    local pa_w, pa_h = map_pos.x - 2 * margin, map_pos.y + map_h - pa_pos.y
    self.player_area = PlayerArea(pa_pos, pa_w, pa_h, self, self.colors[local_id], archetype)

    self.action_list_window = nil

    local ts_w = pa_w - 10
    local ts_h, dy = 90, -90
    for i, info in ipairs(players_info) do
        local c = self.colors[i]
        local pi, pj = unpack(self.starting_positions[n_players][i])
        self.controllers[i] = Controller(map, c, pi, pj, info)
        if i == local_id then
            self.turn_slots[i] = self.player_area.turn_slots.view
        else
            self.turn_slots[i] = TurnSlotsView(TurnSlots(6, i), Vector(map_pos.x + map_w + 5, map_pos.y+map_h+ dy), ts_w, ts_h, c)
            dy = dy - 140
            self.turn_slots[i]:setAlpha(0)
        end
    end

    --Make opponents turn slots invisible
    self.number_of_turns = 1

    self.active_slot = false --Which slot is being played at the moment
    self.next_active_slot = false --Which slot will be played next

    self.action_input_handler = nil

    self.lock_button = Button(200, 580, 100, 100, "Lock", function()
        self:playTurn(self.local_id, function()
            MAIN_TIMER:after(1.5, function()
                self:startNewTurn()
            end)
        end)
        self.lock_button:lock()
    end)
    self.lock_button:lock()

    self:register("L0", nil, "match")
end

function Match:draw()
    --Draw grid
    self.map_view:draw(self)

    --Draw Player area
    self.player_area:draw(start_p)

    --Draw turn slots
    local start_p = self:startingPlayer()
    for i, turn_slots in ipairs(self.turn_slots) do
        if i ~= self.local_id then
            turn_slots:draw(start_p == i, i == self.local_id and 'right' or 'left')
        end
    end
    --Draw lock button
    self.lock_button:draw()

    --Draw Action List
    if self.action_list_window then
        self.action_list_window:draw()
    end

end

function Match:start()
    assert(self.state == 'not started')
    self.state = 'waiting for turn'
end

function Match:startNewTurn()
    assert(self.state == 'waiting for turn')
    self.state = 'choosing actions'
    self.lock_button:unlock()
    self.player_area:grab(2)
end

-- This recursively plays each action in a turn
local function playTurnRec(self, player_actions, order, player_i, action_i, size, callback)
    local p_i = order[player_i]
    -- All actions have been played
    if action_i > size then
        callback()
        self.active_slot = false
        self.next_active_slot = false
        self.number_of_turns = self.number_of_turns + 1
        return
    end
    -- All actions of this index have been played
    if p_i == nil then return playTurnRec(self, player_actions, order, 1, action_i + 1, size, callback) end

    --Set current active slot to draw indicator
    self.active_slot = {p_i, action_i}
    --Try to find next active slot, to help draw indicator
    self.next_active_slot = false
    local t_action_i = action_i
    local t_player_i = player_i + 1
    while t_action_i <= size do
        local t_pi = order[t_player_i]
        if t_pi == nil then
            t_player_i = 1
            t_action_i = t_action_i + 1
        else
            local action = player_actions[t_pi][t_action_i]
            if action ~= 'none' then
                self.next_active_slot = {t_pi, t_action_i}
                break
            else
                t_player_i = t_player_i + 1
            end
        end
    end

    local action = player_actions[p_i][action_i]
    print('Action ' .. action_i .. ' for Player ' .. p_i .. ' = ' .. action)
    if action ~= 'none' then
        Actions.executeAction(self, action, self.controllers[p_i], function()
            self.action_list_window.obj:bump()
            playTurnRec(self, player_actions, order, player_i + 1, action_i, size, callback)
        end)
    else
        self.action_list_window.obj:bump()
        return playTurnRec(self, player_actions, order, player_i + 1, action_i, size, callback)
    end
end

-- player_actions is a list of lists, the i-th with the actions of the i-th player
-- order is a list with the order of the players
function Match:playTurnFromActions(player_actions, order, callback)
    assert(#player_actions == #self.controllers)
    assert(self.state == 'actions locked')
    self.state = 'playing turn'
    self:createOpponentDice(player_actions)
    local size = math.max(unpack(Util.map(player_actions, function(list) return #list end)))
    self:createActionList(player_actions, order, size)
    playTurnRec(self, player_actions, order, 1, 1, size, function()
        self.state = 'waiting for turn'
        self.player_area:destroyPlayedDice()
        self.action_list_window = nil
        self:removeOpponentDice()
        if callback then callback() end
    end)
end

function Match:playTurn(local_id, callback)
    assert(self.state == 'choosing actions')
    self.state = 'actions locked'
    local invert = self:startingPlayer() == 2
    local order = {}
    for i, turn_slots in ipairs(self.turn_slots) do
        if invert then
            order[i] = #self.controllers - i + 1
        else
            order[i] = i
        end
    end
    local actions = {}
    for i, die_slot in ipairs(self.turn_slots[local_id]:getObj().slots) do
        actions[i] = die_slot.die and die_slot.die:getCurrent() or 'none'
    end
    self.player_area:actionsLocked()
    Client.send('actions locked', {i = local_id, actions = actions})
    Client.listenOnce('turn ready', function(all_actions)
        self:playTurnFromActions(all_actions, order, callback)
    end)
end

function Match:startingPlayer()
    if self.number_of_turns%2 == 1 then
        return 1
    else
        return 2
    end
end

function Match:createActionList(player_actions, order, size)
    local action_list = {}
    local player_list = {}
    local p_i = 1
    local action_i = 1
    while action_i <= size do
        local player = order[p_i]
        if player == nil then
            p_i = 1
            action_i = action_i + 1
        else
            table.insert(action_list, player_actions[player][action_i])
            table.insert(player_list, player)
            p_i = p_i + 1
        end
    end
    self.action_list_window = ScrollWindow(ActionList(Vector(10, WIN_H - 80), action_list, player_list), WIN_W - 20, 80)
end

--Iterate for all other players and create dice for their corresponding actions
function Match:createOpponentDice(player_actions)
    MAIN_TIMER:script(function(wait)

        --Make opponents turn slots visible
        for i, ts in ipairs(self.turn_slots) do
            if i ~= self.local_id then
                ts:setVisible()
                wait(.3)
            end
        end

        wait(.1)

        --Create dummy dice
        for i, actions in ipairs(player_actions) do
            if self.controllers[i].source == 'remote' then
                for j, action in ipairs(actions) do
                    if action ~= "none" then
                        local slot = self.turn_slots[i]:getObj():getSlot(j)
                        local slotv = slot.view
                        local diev = DieView(Die({action}, i), slotv.pos.x, slotv.pos.y-50, Color.new(150,150,150))
                        diev:register("L2", "die_view")
                        diev:enter()
                        local die = diev:getObj()
                        slot:putDie(die)
                        wait(.1)
                    end
                end
            end
        end
    end)
end

function Match:removeOpponentDice()
    MAIN_TIMER:script(function(wait)
        for i, controller in ipairs(self.controllers) do
            if controller.source == "remote" then
                turn_slot = self.turn_slots[i]:getObj()
                for j = 1, turn_slot:getSize() do
                    local die_slot = turn_slot:getSlot(j)
                    local die = die_slot:getDie()
                    if die then
                        die.view:leave()
                        die_slot:removeDie()
                        wait(.1)
                    end
                end
            end
        end
        wait(.3)
        --Make opponents turn slots invisible
        for i, ts in ipairs(self.turn_slots) do
            if i ~= self.local_id then
                ts:setInvisible()
                wait(.3)
            end
        end
    end)
end

function Match:getLocalId()
    return self.local_id
end

function Match:getColors()
    return self.colors
end

function Match:update(dt)
    self.player_area:update(dt)
end

function Match:mousemoved(...)
    self.player_area:mousemoved(...)
    self.lock_button:mousemoved(...)
    if self.action_list_window then
        self.action_list_window:mousemoved(...)
    end
end

function Match:mousepressed(x, y, but, ...)
    self.player_area:mousepressed(x, y, but, ...)
    if self.action_list_window then
        self.action_list_window:mousepressed(x, y, but, ...)
    end
    for i, turnslot in ipairs(self.turn_slots) do
        if i ~= self.local_id then
            turnslot:mousepressed(x, y, but, ...)
        end
    end
    if but ~= 1 then return end
    self.lock_button:mousepressed(x, y, ...)
    local i, j = self.map_view:getTileOnPosition(Vector(x, y))
    if i and self.action_input_handler and self.action_input_handler:accept(i, j) then
        self.action_input_handler:finish(i, j)
        self.action_input_handler = nil
    end
end

function Match:mousereleased(x, y, but, ...)
    if but == 1 then
        self.lock_button:mousereleased(x, y, but)
    end
    self.player_area:mousereleased(x, y, but, ...)
    if self.action_list_window then
        self.action_list_window:mousereleased(x, y, but, ...)
    end
end

return Match
