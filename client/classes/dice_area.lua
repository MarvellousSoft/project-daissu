local DRAWABLE    = require "classes.primitives.drawable"
local Class       = require "common.extra_libs.hump.class"
local Vector      = require "common.extra_libs.hump.vector"
local DieSlot     = require "classes.die.die_slot"
local DieSlotView = require "classes.die.die_slot_view"
local Button      = require "classes.button"
local Color       = require "classes.color.color"

local funcs = {}

--CLASS DEFINITION--

local DiceArea = Class{
    __includes={DRAWABLE}
}

function DiceArea:init(dice_n, pos, w, h, player_num)
    DRAWABLE.init(self, pos.x, pos.y, Color.purple())
    self.w = w
    self.h = h

    local dw, dh = DieSlotView.getSize()
    local mid = pos + Vector(w / 2, h / 2)
    self.slots = {}
    for i = 1, dice_n do
        local v = Vector.fromPolar((i - 1) * 2 * math.pi / dice_n, math.min(w, h) / 2 - math.min(dw, dh) / 2 - 40)
        self.slots[i] = DieSlotView(DieSlot("dice_area", player_num), mid + v - Vector(dw / 2, dh / 2))
        self.slots[i]:setSubtype("die_slot_view")
    end

    self.image = IMG.dice_area
    self.img_sx = self.w/self.image:getWidth()
    self.img_sy = self.h/self.image:getHeight()
end

--CLASS FUNCTIONS--

function DiceArea:draw()
    --Draw bg shadow
    Color.set(Color.black())
    local off = 8
    love.graphics.draw(self.image, self.pos.x+off, self.pos.y+off, nil,
                       self.img_sx, self.img_sy)

    --Draw bg
    Color.set(Color.white())
    love.graphics.draw(self.image, self.pos.x, self.pos.y, nil,
                       self.img_sx, self.img_sy)

    --Draw slot
    for _, die_slot in ipairs(self.slots) do
        die_slot:draw()
    end
end

--Return all dices that are in a die slot in this area
function DiceArea:getDice()
    local t = {}
    for _, die_slot_view in ipairs(self.slots) do
        if die_slot_view:getObj():getDie() then
            table.insert(t, die_slot_view:getObj():getDie())
        end
    end

    return t
end

return DiceArea
