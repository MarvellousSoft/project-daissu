local Class = require "common.extra_libs.hump.class"
local Server = require "server"

local Match = Class {}

function Match:init(c1, c2)
    self.cl_list = {c1, c2}
    for i, cl in ipairs(self.cl_list) do
        cl:send('start game', i)
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
    Server.on('actions locked', function(data, client)
        assert(match_map[client] ~= nil)
        match_map[client]:actionLocked(data.i, data.actions)
    end)

    Server.on('action input', function(data, client)
        assert(match_map[client] ~= nil)
        match_map[client]:actionInput(data, client)
    end)
end

function MatchManager.startMatch(c1, c2)
    local m = Match(c1, c2)
    match_map[c1] = m
    match_map[c2] = m
end

return MatchManager
