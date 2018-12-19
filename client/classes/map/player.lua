local Class  = require "common.extra_libs.hump.class"

--[[
    This is a player drawn in the map
]]
local Player = Class {}

function Player:init()
    self.health = 5

    self.tile_type = 'Player'
end

function Player:applyDamage(dmg)
    self.health = self.health - dmg
end

return Player
