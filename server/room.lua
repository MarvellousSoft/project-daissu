local Class = require "common.extra_libs.hump.class"

local Room = Class {}

function Room:init()
    self.players = {}
end

function Room:addPlayer(p)
    if self.players[p] ~= nil then return end
    self.players[p] = {
        status = 'not ready',
        archetype = 'melee' --default
    }
end

function Room:remPlayer(p)
    if self.players[p] == nil then return end
    self.players[p] = nil
    for _, player in pairs(self.players) do
        player.status = 'not ready'
    end
end

function Room:playerReady(p, is_ready)
    if self.players[p] == nil then return false end
    self.players[p].status = is_ready and 'ready' or 'not ready'
    if not is_ready then return false end
    for _, player in pairs(self.players) do
        if player.status ~= 'ready' then
            return false
        end
    end
    return true
end

function Room:playerNotReady(p)
    if self.players[p] == nil or self.players[p].status == 'not ready' then return end
    self.players[p].status = 'not ready'
end

function Room:empty()
    return next(self.players) == nil
end

function Room:atLeastTwoPlayers()
    return next(self.players, next(self.players)) ~= nil
end

function Room:getData(name)
    local cl_list = {}
    for cl, player in pairs(self.players) do
        table.insert(cl_list, {
            id = cl:getConnectId(),
            ready = (player.status == 'ready'),
            archetype = player.archetype
        })
    end
    return {
        name = name,
        clients = cl_list
    }
end

return Room
