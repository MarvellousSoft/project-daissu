local Class      = require "common.extra_libs.hump.class"
local Archetypes = require "common.archetypes"
local Util       = require "common.util"
local log        = require "common.extra_libs.log"

local PlayerData = Class {}

function PlayerData:init(archetype, seed)
    self.rng = Util.getRNG(seed)
    self.bag = Archetypes.getBaseBag(archetype)
    self.grave = {}
    self.mat = {}
    -- maximum size of mat
    self.mat_max = 6
    self:shuffleBag()
    self.rerolls_available = 0
end

function PlayerData:shuffleBag()
    Util.shuffle(self.bag, self.rng)
end

function PlayerData:shuffleGraveIntoBag()
    assert(self.bag[1] == nil)
    self.bag = self.grave
    self.grave = {}
    self:shuffleBag()
end

-- Grabs count dice from the players bag
-- Yields each grabbed die, BEFORE rolling them.
function PlayerData:grab(count)
    for i = 1, count do
        if #self.mat == self.mat_max then return end
        if self.bag[1] == nil then
            self:shuffleGraveIntoBag()
        end
        local die = table.remove(self.bag)
        table.insert(self.mat, die)
        coroutine.yield(die)
        die:roll(self.rng)
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
    die:roll(self.rng)
end

function PlayerData:sendDieToGrave(die)
    local found = false
    for i, die_ in ipairs(self.mat) do
        if die_ == die then
            table.remove(self.mat, i)
            found = true
            break
        end
    end
    assert(found)
    table.insert(self.grave, die)
end

-- Returns the dice with id id from your mat, or nil
function PlayerData:getByIdFromMat(id)
    return Util.any(self.mat, function(d) return d.id == id end)
end

return PlayerData
