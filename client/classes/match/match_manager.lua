local ELEMENT       = require "classes.primitives.element"
local Class         = require "common.extra_libs.hump.class"
local Vector        = require "common.extra_libs.hump.vector"
local Util          = require "common.util"
local MapView       = require "classes.map.map_view"
local Controller    = require "classes.map.controller"
local DieHelper     = require "classes.die.helper"
local TurnSlots     = require "classes.turn_slots.turn_slots"
local TurnSlotsView = require "classes.turn_slots.turn_slots_view"
local Actions       = require "classes.actions"
local Die           = require "common.die.die"
local DieView       = require "classes.die.die_view"
local Color         = require "classes.color.color"
local PlayerArea    = require "classes.match.player_area"
local ActionList    = require "classes.match.action_list"
local Button        = require "classes.button"
local ScrollWindow  = require "classes.ui.scroll_window"
local PlayerInfo    = require "classes.match.player_info"
local BoardLogic    = require "common.match.board_logic"
local PlayerView    = require "classes.map.player_view"
local log           = require "common.extra_libs.log"

local Client = require "classes.net.client"

local MatchManager = Class {
    __includes = {ELEMENT},
}

function MatchManager:init(rows, columns, pos, cell_size, w, h, game_info)
    -- Data used from game_info
    local local_id = game_info.local_id
    local player_count = game_info.player_count
    local archetypes = game_info.archetypes
    local seed = game_info.seed
    ---
    ELEMENT.init(self)
    self:register("L0", nil, "match")
    self.logic = BoardLogic(rows, columns, player_count)
    self.state = self.logic.state
    self.pos = pos
    self.w, self.h = w, h
    self.local_id = local_id
    self.controllers = {}
    self.turn_slots = {}
    self.players_info = {}

    self.colors = {  --Colors for each player
        Color.new(133, 255, 86), --Chartoise green
        Color.new(86, 195, 255), --Blue sky
        Color.new(255, 104, 197),--Taffy pink
        Color.new(255, 182, 86), --Orange
        Color.new(201, 86, 255), --Purple
    }

    local margin = 25

    local map_w = cell_size * columns
    local map_h = cell_size * rows

    local pi_h = 120 --Player info height
    local pi_w = (w - map_w)/2 - 2*margin --Player info width

    local map_pos = pos + Vector((w - map_w) / 2, margin + pi_h + margin)
    self.map_view = MapView(self.logic.map, map_pos, cell_size)

    local ts_w = pi_w
    local ts_h = 90 --Turn slot height

    local pa_pos = Vector(margin, map_pos.y)
    local pa_w, pa_h = pi_w, map_h

    self.player_area = PlayerArea(pa_pos, pa_w, pa_h, self, self.colors[local_id], archetypes[local_id], seed)

    self.action_list_window = nil

    local opponents_x = w - pi_w - margin
    local gap_1 = 5  --Between info and its slot
    local gap_2 = 27 --Between slots and next player info
    local dy = pi_h + ts_h + gap_1 + gap_2
    local original_y = margin
    local y = original_y
    for i = 1, player_count do
        local c = self.colors[i]
        PlayerView(self.logic.players[i], c)
        self.controllers[i] = Controller(self.logic.map, self.logic.players[i].view, i == local_id and 'local' or 'remote')
        if i == local_id then
            self.players_info[i] = PlayerInfo(margin, original_y, ts_w, pi_h, i, archetypes[i])
            self.turn_slots[i] = self.player_area.turn_slots.view
        else
            self.players_info[i] = PlayerInfo(opponents_x, y, ts_w, pi_h, i, archetypes[i])
            self.turn_slots[i] = TurnSlotsView(TurnSlots(6, i), Vector(opponents_x, y + pi_h + gap_1), ts_w, ts_h, c)
            y = y + dy
            self.turn_slots[i]:setAlpha(0)
        end
    end

    --Creating object for opponents turn slots (to put inside scroll window)
    local obj = {
        match = self,
        w = ts_w,
        h = y - original_y,
        x = opponents_x,
        y = original_y,
        bg_color = Color.new(0,0,0,180),
        draw = function(self)
            Color.set(self.bg_color)
            love.graphics.rectangle("fill", self.x, self.y, self.w + 10, self.h)
            for i,ts in ipairs(self.match.turn_slots) do
                if i ~= self.match.local_id then
                    ts:draw()
                end
            end
            for i, pi in ipairs(self.match.players_info) do
                if i ~= self.match.local_id then
                    pi:draw()
                end
            end
        end
    }
    self.opponents_turn_slots = ScrollWindow(obj, opponents_x, original_y, WIN_W - opponents_x, WIN_H - 200)

    self.active_slot = false --Which slot is being played at the moment
    self.next_active_slot = false --Which slot will be played next

    self.action_input_handler = nil

    local gap = 30 --Gap between player area and lock button
    local bw, bh = 120, 65
    local bx = margin + ts_w/2 - bw/2
    local by = pa_pos.y + pa_h + gap
    self.lock_button = Button(bx, by, bw, bh, "lock", function()
        self:playTurn(self.local_id, function()
            MAIN_TIMER:after(1.5, function()
                self.player_area:deactivatePlayerSlots()
                self:startNewTurn()
            end)
        end)
        self.lock_button:lock()
    end)
    self.lock_button:lock()

end

function MatchManager:draw()
    --Draw grid
    self.map_view:draw(self)

    --Draw Player info
    self.players_info[self.local_id]:draw()

    --Draw Player area
    self.player_area:draw(start_p)

    --Draw opponents turn slots
    self.opponents_turn_slots:draw()

    --Draw lock button
    self.lock_button:draw()

    --Draw Action List
    if self.action_list_window then
        self.action_list_window:draw()
    end

end

function MatchManager:start()
    self.logic:start()
    self.state = self.logic.state
end

function MatchManager:startNewTurn()
    self.logic:startNewTurn()
    self.state = self.logic.state
    self.lock_button:unlock()
    self.player_area:grab(2)
    self.player_area:refillRerolls()
end


-- This recursively plays each action in a turn
local function playTurnRec(self, co, callback, ...)
    local data = co(...)
    -- turn is over
    if data == nil then
        self.state = self.logic.state
        self:deactivateOpponentSlots()
        self.active_slot = false
        self.next_active_slot = false
        self.action_list_window = nil
        if callback then callback() end
        return
    elseif data.action ~= 'none' then
        Actions.waitForInput(self, data.action, self.controllers[data.player], function(...)
            local varargs_wrap = {...}
            Actions.getAction(data.action).showAction(self.controllers[data.player], function()
                self.action_list_window.obj:bump()
                playTurnRec(self, co, callback, unpack(varargs_wrap))
            end, ...)
        end)
    else
        self.action_list_window.obj:bump()
        playTurnRec(self, co, callback)
    end
end

-- player_actions is a list of lists, the i-th with the actions of the i-th player
function MatchManager:playTurnFromActions(player_actions, callback)
    assert(#player_actions == #self.controllers)
    assert(self.state == 'actions locked')
    self.state = 'playing turn'
    self:activateOpponentSlots(player_actions)
    local size = math.max(unpack(Util.map(player_actions, function(list) return #list end)))
    self:createActionList(player_actions, self.logic:getOrder(), size)

    local co = Util.wrap(self.logic.playTurnFromActions)
    playTurnRec(self, co, callback, self.logic, player_actions)
end

function MatchManager:playTurn(local_id, callback)
    assert(self.state == self.logic.state)
    self.state = 'actions locked'
    local actions = {}
    for i, die_slot in ipairs(self.turn_slots[local_id]:getModel().slots) do
        actions[i] = die_slot.die and die_slot.die.id or -1
    end
    self.player_area:actionsLocked()
    Client.send('actions locked', actions)
    Client.listenOnce('turn ready', function(all_actions)
        self:playTurnFromActions(all_actions, callback)
    end)
end

function MatchManager:createActionList(player_actions, order, size)
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
    local offset, margin = 5, 10
    local x, y = margin, WIN_H - 130
    self.action_list_window = ScrollWindow(ActionList(Vector(x, y), action_list, player_list, #action_list/size), x - offset, y - offset, WIN_W - 2*margin + 2*offset, 120)
end

--Iterate for all other players and create dice for their corresponding actions
function MatchManager:activateOpponentSlots(player_actions)
    MAIN_TIMER:script(function(wait)
        --Make opponents turn slots visible
        for i, ts in ipairs(self.turn_slots) do
            if i ~= self.local_id then
                ts:setVisible()
                wait(.3)
            end
        end

        wait(.1)

        --Set opponents slots with their proper actions
        for i, actions in ipairs(player_actions) do
            if self.controllers[i].source == 'remote' then
                for j, action in ipairs(actions) do
                    if action ~= "none" then
                        local slot = self.turn_slots[i]:getModel():getSlot(j)
                        slot.view:setAction(action, self.colors[i])
                        wait(.1)
                    end
                end
            end
        end
    end)
end

function MatchManager:deactivateOpponentSlots()
    MAIN_TIMER:script(function(wait)
        for i, controller in ipairs(self.controllers) do
            if controller.source == "remote" then
                turn_slot = self.turn_slots[i]:getModel()
                for j = 1, turn_slot:getSize() do
                    local die_slot = turn_slot:getSlot(j)
                    die_slot.view:setAction()
                    wait(.1)
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

function MatchManager:getLocalId()
    return self.local_id
end

function MatchManager:getColors()
    return self.colors
end

function MatchManager:update(dt)
    self.player_area:update(dt)
end

--Player Functions--

function MatchManager:getPlayerColor(id)
    return self.colors[id]
end

function MatchManager:getPlayerSource(id)
    return self.controllers[id]:getSource()
end

function MatchManager:getPlayerOrder(id)
    local order = self.logic:getOrder()
    for i = 1, #order do
        if order[i] == id then return i end
    end
    return error("Failed to find player order for player "..id)
end

function MatchManager:isChoosingActions()
    return self.state == 'choosing actions'
end

function MatchManager:isPlayingTurn()
    return self.state == 'playing turn'
end

--Mouse functions--

function MatchManager:mousemoved(...)
    self.player_area:mousemoved(...)
    self.lock_button:mousemoved(...)
    self.opponents_turn_slots:mousemoved(...)
    if self.action_list_window then
        self.action_list_window:mousemoved(...)
    end
end

function MatchManager:wheelmoved(...)
    self.opponents_turn_slots:wheelmoved(...)
    if self.action_list_window then
        self.action_list_window:wheelmoved(...)
    end
end

function MatchManager:mousepressed(x, y, but, ...)
    self.player_area:mousepressed(x, y, but, ...)
    self.opponents_turn_slots:mousepressed(x, y, but, ...)
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
        self.action_input_handler:chosen_input(i, j)
        self.action_input_handler = nil
    end
end

function MatchManager:mousereleased(x, y, but, ...)
    if but == 1 then
        self.lock_button:mousereleased(x, y, but)
    end
    self.opponents_turn_slots:mousereleased(x, y, but, ...)
    self.player_area:mousereleased(x, y, but, ...)
    if self.action_list_window then
        self.action_list_window:mousereleased(x, y, but, ...)
    end
end

return MatchManager
