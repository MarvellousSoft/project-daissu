local Class      = require "common.extra_libs.hump.class"
local Archetypes = require "classes.archetypes"

local PlayerData = Class {}

function PlayerData:init(archetype)
    self.bag = Archetypes.getBaseBag(archetype)
    self.grave = {}
    self.mat = {}
    -- maximum size of mat
    self.mat_max = 6
    self:shuffleBag()
    self.rerolls_available = 0
end

function PlayerData:shuffleBag()
    local bag = self.bag
    local n = #bag
    for i = 1, n do
        local j = love.math.random(i, n)
        bag[i], bag[j] = bag[j], bag[i]
    end
    self.rerolls_available = 0
end

function PlayerData:shuffleGraveIntoBag()
    assert(self.bag[1] == nil)
    for i, die in ipairs(self.grave) do
        table.insert(self.bag, die)
    end
    self.grave = {}
    self:shuffleBag()
end

function PlayerData:grab(count)
    for i = 1, count do
        if #self.mat == self.mat_max then return end
        if self.bag[1] == nil then
            self:shuffleGraveIntoBag()
        end
        local die = table.remove(self.bag)
        table.insert(self.mat, die)
        coroutine.yield(die)
        die:roll()
    end
end

function PlayerData:refillRerolls()
    self.rerolls_available = 2
end

function PlayerData:getRerolls()
    return self.rerolls_available
end

function PlayerData:reroll(die)
    assert(self.rerolls_available > 0)
    self.rerolls_available = self.rerolls_available - 1
    die:roll()
end

function PlayerData:sendDieToGrave(die)
    for i, die_ in ipairs(self.mat) do
        if die_ == die then
            table.remove(self.mat, i)
            break
        end
    end
    table.insert(self.grave, die)
end

return PlayerData
