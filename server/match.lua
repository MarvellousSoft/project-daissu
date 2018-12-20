local Class  = require "common.extra_libs.hump.class"
local Util   = require "common.util"
--local Logic  = require "common.match.board_logic"
local Server = require "server"

local Match = Class {}

function Match:init(cl_list)
    --self.logic = Logic(5, 5, #cl_list)
    Util.shuffle(cl_list)
    self.cl_list = Util.map(cl_list, function(c) return c.client end)
    local archetypes = Util.map(cl_list, function(c) return c.info.archetype end)
    -- Map: Client -> index
    self.reverse_map = {}
    for i, cl in ipairs(self.cl_list) do
        self.reverse_map[cl] = i
        cl:send('start game', {
            local_id = i,
            player_count = #cl_list,
            archetypes = archetypes
        })
    end
    self.actions = {}
    self.lock_count = 0
end

function Match:getInputForAction(data)
    if data == nil then
        self.turn_co = nil
        self.waiting_for_input = nil
        return nil
    end
    if data.action == 'none' then return self:getInputForAction(self.turn_co()) end
    local helper = Actions.getAction(data.action)
    if helper.getInputHandler then
        self.waiting_for_input = data.player
    else
        return self:getInputForAction(data)
    end
end

function Match:actionLocked(client, actions)
    local i = self.reverse_map[client]
    if not i --[[or self.logic.state ~= 'choosing actions']] or self.actions[i] then
        return Server.kick(client)
    end
    self.lock_count = self.lock_count + 1
    self.actions[i] = actions
    if self.lock_count == #self.cl_list then
        local actions = self.actions
        self.lock_count = 0
        self.actions = {}
        for i, cl in ipairs(self.cl_list) do
            cl:send('turn ready', actions)
        end
        --self.turn_co = Util.wrap(function() self.logic:playTurnFromActions(actions) end)
        --self:getInputForAction(self.turn_co())
    end
end

function Match:actionInput(client, data)
    local i = self.reverse_map[client]
    if not i --[[or self.logic.state ~= 'playing turn' or self.waiting_for_input ~= i]] then
        return Server.kick(client)
    end
    for i, cl in ipairs(self.cl_list) do
        if cl ~= client then
            cl:send('action input', data)
        end
    end
    self.waiting_for_input = nil
    -- continue turn
    --self:getInputForAction(self.turn_co())
end

return Match
