local Class  = require "common.extra_libs.hump.class"
local Util   = require "common.util"

local Match = Class {}

function Match:init(cl_list)
    Util.shuffle(cl_list)
    self.cl_list = Util.map(cl_list, function(c) return c.client end)
    local archetypes = Util.map(cl_list, function(c) return c.info.archetype end)
    for i, cl in ipairs(self.cl_list) do
        cl:send('start game', {
            local_id = i,
            player_count = #cl_list,
            archetypes = archetypes
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

return Match
