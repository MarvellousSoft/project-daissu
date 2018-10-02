local Class = require "extra_libs.hump.class"
local Vector = require "extra_libs.hump.vector"
local Util = require "util"
local Map = require "classes.map.map"
local MapView = require "classes.map.map_view"
local Controller = require "classes.map.controller"
local DieHelper = require "classes.die.helper"
local TurnSlots = require "classes.turn_slots"
local TurnSlotsView = require "classes.turn_slots_view"

local Match = Class {}

function Match:init(rows, columns, pos, cell_size, w, h, players_positions)
    self.state = 'not started'
    self.pos = pos
    self.w, self.h = w, h
    local map = Map(rows, columns)
    self.map_view = MapView(map, pos + Vector((w - cell_size * columns) / 2, 120), cell_size)
    self.controllers = {}
    self.turn_slots = {}
    -- Assuming two players for now
    assert(#players_positions == 2)
    self.controllers[1] = Controller(map, unpack(players_positions[1]))
    self.controllers[2] = Controller(map, unpack(players_positions[2]))
    local d_w, d_h = DieHelper.getDieDimensions()
    -- Taking margins into account
    d_h = d_h + 6
    self.turn_slots[1] = TurnSlotsView(TurnSlots(6), Vector(pos.x + 5, pos.y + h - d_h - 25), (w - 20) / 2, d_h + 20)
    self.turn_slots[2] = TurnSlotsView(TurnSlots(6), Vector(pos.x + w / 2 + 5, pos.y + h - d_h - 25), (w - 20) / 2, d_h + 20)
end

function Match:draw()
    self.map_view:draw()
    for i, turn_slots in ipairs(self.turn_slots) do
        turn_slots:draw()
    end
end

function Match:start()
    assert(self.state == 'not started')
    self.state = 'waiting for turn'
end

-- This recursively playes each action in a turn
local function playTurnRec(self, player_actions, order, player_i, action_i, size, callback)
    local p_i = order[player_i]
    -- All actions have been played
    if action_i > size then
        callback()
        return
    end
    -- All actions of this index have been played
    if p_i == nil then return playTurnRec(self, player_actions, order, 1, action_i + 1, size, callback) end

    local action = player_actions[p_i][action_i]
    print('Action ' .. action_i .. ' for Player ' .. p_i .. ' = ' .. (action or 'null'))
    if action ~= nil then
        self.controllers[p_i]:showAction(action, function()
            playTurnRec(self, player_actions, order, player_i + 1, action_i, size, callback)
        end)
    else
        return playTurnRec(self, player_actions, order, player_i + 1, action_i, size, callback)
    end
end

-- player_actions is a list of lists, the i-th with the actions of the i-th player
-- order is a list with the order of the players
function Match:playTurn(player_actions, order)
    assert(#player_actions == #self.controllers)
    assert(self.state == 'waiting for turn')
    self.state = 'playing turn'
    local size = math.max(unpack(Util.map(player_actions, function(list) return #list end)))
    playTurnRec(self, player_actions, order, 1, 1, size, function()
        self.state = 'waiting for turn'
    end)
end

return Match
