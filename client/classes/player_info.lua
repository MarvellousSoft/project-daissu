local Color     = require "classes.color.color"
local Class     = require "common.extra_libs.hump.class"
local ELEMENT   = require "classes.primitives.element"
local POS       = require "classes.primitives.pos"

local PlayerInfo = Class{
    __includes = {ELEMENT, POS},
    init = function(self, x, y, w, h, player_id, archetype)
        ELEMENT.init(self)

        POS.init(self, x, y)
        self.w, self.h = w, h

        local match = Util.findId("match")
        assert(match, "Couldn't access match")

        self.color = match:getPlayerColor(player_id)
        self.flip = match:getPlayerSource(player_id) == 'remote' --If its an opponent's info

        self.archetype = archetype

        self.tp = "player_info"
    end
}

function PlayerInfo:draw()
    Color.set("white")
    love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)
end

return PlayerInfo
