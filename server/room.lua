local Class = require "common.extra_libs.hump.class"

local Room = Class {}

function Room:init()
    self.players = {}
end

function Room:addPlayer(p)
    if self.players[p] ~= nil then return end
    self.players[p] = 'not ready'
end

function Room:remPlayer(p)
    if self.players[p] == nil then return end
    self.players[p] = nil
    for ps in pairs(self.players) do
        self.players[ps] = 'not ready'
    end
end

function Room:playerReady(p, is_ready)
    if self.players[p] == nil then return false end
    self.players[p] = is_ready and 'ready' or 'not ready'
    if not is_ready then return false end
    for _, state in pairs(self.players) do
        if state ~= 'ready' then
            return false
        end
    end
    return true
end

function Room:playerNotReady(p)
    if self.players[p] == nil or self.players[p] == 'not ready' then return end
    self.players[p] = 'not ready'
end

function Room:empty()
    return next(self.players) == nil
end

function Room:atLeastTwoPlayers()
    return next(self.players, next(self.players)) ~= nil
end

function Room:getData(name)
    local cl_list = {}
    for cl, state in pairs(self.players) do
        table.insert(cl_list, {
            id = cl:getConnectId(),
            ready = (state == 'ready')
        })
    end
    return {
        name = name,
        clients = cl_list
    }
end

return Room
