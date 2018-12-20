local Class  = require "common.extra_libs.hump.class"
local Server = require "server"
local log    = require "common.extra_libs.log"
local Match  = require "match"

local MatchManager = {}

-- Map: Client -> Match
local match_map = {}

local function assertMatch(client)
    if match_map[client] == nil then
        log.warn('Client not on any match.')
        Server.kick(client)
    end
    return match_map[client] ~= nil
end

local function safeCall(client, f)
    local ok, err = pcall(f)
    if not ok then
        log.warn(err)
        Server.kick(client)
    end
end

function MatchManager.init()

    local actions_locked_schema = { 'array', 'number' }
    Server.on('actions locked', function(data, client)
        if not Server.checkSchema(client, actions_locked_schema, data) or not assertMatch(client) then return end
        safeCall(client, function()
            match_map[client]:actionsLocked(client, data)
        end)
    end)

    local action_input_schema = { 'number', 'number' }
    Server.on('action input', function(data, client)
        if not Server.checkSchema(client, action_input_schema, data) or not assertMatch(client) then return end
        safeCall(client, function()
            match_map[client]:actionInput(client, data)
        end)
    end)

    local reroll_schema = 'number'
    Server.on('reroll', function(data, client)
        if not Server.checkSchema(client, reroll_schema, data) or not assertMatch(client) then return end
        safeCall(client, function()
            match_map[client]:reroll(client, data)
        end)
    end)
end

function MatchManager.startMatch(cl_list)
    local m = Match(cl_list)
    for _, cl in ipairs(cl_list) do
        match_map[cl.client] = m
    end
end

return MatchManager
