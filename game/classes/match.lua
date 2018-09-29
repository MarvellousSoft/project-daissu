local Class = require "extra_libs.hump.class"
local Vector = require "extra_libs.hump.vector"
local Util = require "util"
local Map = require "classes.map.map"
local MapView = require "classes.map.map_view"
local Controller = require "classes.map.controller"

local Match = Class {}

function Match:init(rows, columns, pos, cell_size)
    self.state = 'not started'
    self.pos = pos
    local map = Map(rows, columns)
    self.map_view = MapView(map, pos + Vector(0, 20), cell_size)
    self.controllers = {}
end

function Match:addController(i, j)
    assert(self.state == 'not started')
    table.insert(self.controllers, Controller(self.map_view.obj, i, j))
end

function Match:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Status: " .. self.state, self.pos.x, self.pos.y)
    self.map_view:draw()
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
