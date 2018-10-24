local Vector = require "extra_libs.hump.vector"
local Vec = require "extra_libs.hump.vector-light"
local Timer = require "extra_libs.hump.timer"
local Util = require "util"
local GridHelper = require "classes.map.grid_helper"
local FadingText = require "classes.fading_text"

local Roundhouse = {}

function Roundhouse.showAction(controller, callback)
    local pi, pj = controller:getPosition()
    local map_view = controller.map.view
    for di = -1, 1, 1 do
        for dj = -1, 1, 1 do
            if (di ~= 0 or dj ~= 0) and controller.map:get(pi + di, pj + dj) then
                FadingText(map_view.pos + Vector(pj + dj - 1, pi + di - 1) * map_view.cell_size, "-1", 1)
            end
        end
    end
    Timer.after(1, function()
        Roundhouse.applyAction(controller)
        controller.player:resetAnimation()
        if callback then callback() end
    end)
end

function Roundhouse.applyAction(controller)
    local pi, pj = controller:getPosition()
    for di = -1, 1, 1 do
        for dj = -1, 1, 1 do
            if di ~= 0 or dj ~= 0 then
                tile = controller.map:get(pi + di, pj + dj)
                if tile then
                    tile:applyDamage(1)
                end
            end
        end
    end
end

return Roundhouse
