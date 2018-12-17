local Class = require "common.extra_libs.hump.class"
local Server = require "server"

local Match = Class {}

function Match:init(cl_list)
    self.cl_list = cl_list
    for i, cl in ipairs(self.cl_list) do
        cl:send('start game', {
            local_id = i,
            player_count = #cl_list
        })
    end
    self.actions = {}
    self.lock_count = 0
end

function Match:actionLocked(i, actions)
    self.lock_count = self.lock_count + 1
    self.actions[i] = actions
    if self.lock_count == #self.cl_list then
        for i, cl in ipairs(self.cl_list) do
            cl:send('turn ready', self.actions)
        end
        self.lock_count = 0
        self.actions = {}
    end
end

function Match:actionInput(data, client)
    for i, cl in ipairs(self.cl_list) do
        if cl ~= client then
            cl:send('action input', data)
        end
    end
end

local MatchManager = {}

local match_map = {}

function MatchManager.init()
    local actions_locked_schema = {
        i = 'number',
        actions = {'array', 'string'}
    }
    Server.on('actions locked', function(data, client)
        if not Server.checkSchema(client, actions_locked_schema, data) then return end
        assert(match_map[client] ~= nil)
        match_map[client]:actionLocked(data.i, data.actions)
    end)

    local action_input_schema = { 'number', 'number' }
    Server.on('action input', function(data, client)
        if not Server.checkSchema(client, action_input_schema, data) then return end
        assert(match_map[client] ~= nil)
        match_map[client]:actionInput(data, client)
    end)
end

function MatchManager.startMatch(cl_list)
    local m = Match(cl_list)
    for _, cl in ipairs(cl_list) do
        match_map[cl] = m
    end
end

return MatchManager
