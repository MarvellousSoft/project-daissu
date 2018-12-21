local Class      = require "common.extra_libs.hump.class"
local Archetypes = require "common.archetypes"

local EnemyData = Class {}

function EnemyData:init(archetype)
    self.bag_size = #Archetypes.getBaseBag(archetype)
    self.grave_size = 0
    self.mat_size = 0
    self.mat_max = 6
end

function EnemyData:shuffleGraveIntoBag()
    assert(self.bag_size == 0)
    self.bag_size = self.grave_size
    self.grave_size = 0
end

function EnemyData:grab(count)
    local grabbed = 0
    for i = 1, count do
        if self.mat_size == self.mat_max then return grabbed end
        if self.bag_size == 0 then self:shuffleGraveIntoBag() end
        self.bag_size = self.bag_size - 1
        self.mat_size = self.mat_size + 1
        grabbed = grabbed + 1
    end
    return grabbed
end

function EnemyData:sendDieToGrave()
    assert(self.mat_size > 0)
    self.mat_size = self.mat_size - 1
    self.grave_size = self.grave_size + 1
end

function EnemyData:getBagSize() return self.bag_size end
function EnemyData:getMatSize() return self.mat_size end
function EnemyData:getGraveSize() return self.grave_size end

return EnemyData
