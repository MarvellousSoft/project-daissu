local Class = require "common.extra_libs.hump.class"
local log   = require "common.extra_libs.log"

local Room = Class {}

function Room:init()
    self.players = {}
end

function Room:addPlayer(p)
    if self.players[p] ~= nil then return end
    self.players[p] = {
        ready = false,
        archetype = 'melee' --default
    }
end

function Room:remPlayer(p)
    if self.players[p] == nil then return end
    self.players[p] = nil
    for _, player in pairs(self.players) do
        player.ready = false
    end
end

function Room:updatePlayer(p, info)
    if self.players[p] == nil then
        log.warn('Trying to update missing player')
        return false
    end
    self.players[p] = info
    if not info.ready then return false end
    for _, info in pairs(self.players) do
        if not info.ready then
            return false
        end
    end
    return true
end

function Room:empty()
    return next(self.players) == nil
end

function Room:atLeastTwoPlayers()
    return next(self.players, next(self.players)) ~= nil
end

function Room:getData(name)
    local cl_list = {}
    for cl, info in pairs(self.players) do
        table.insert(cl_list, {
            id = cl:getConnectId(),
            ready = info.ready,
            archetype = info.archetype
        })
    end
    return {
        name = name,
        clients = cl_list
    }
end

return Room
