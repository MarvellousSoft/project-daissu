local DRAWABLE    = require "classes.primitives.drawable"
local Class       = require "extra_libs.hump.class"
local Vector      = require "extra_libs.hump.vector"
local DieSlot     = require "classes.die.die_slot"
local DieSlotView = require "classes.die.die_slot_view"
local Button      = require "classes.button"
local Color       = require "classes.color.color"

local funcs = {}

--CLASS DEFINITION--

local DiceArea = Class{
    __includes={DRAWABLE}
}

function DiceArea:init(dice_n, pos, w, h)
    DRAWABLE.init(self, pos.x, pos.y, Color.purple())
    self.w = w
    self.h = h

    local dw, dh = DieSlotView.getSize()
    local mid = pos + Vector(w / 2, h / 2)
    self.die_slots = {}
    for i = 1, dice_n do
        local v = Vector.fromPolar((i - 1) * 2 * math.pi / dice_n, math.min(w, h) / 2 - math.min(dw, dh) / 2 - 40)
        self.die_slots[i] = DieSlotView(DieSlot("dice_area"), mid + v - Vector(dw / 2, dh / 2))
        self.die_slots[i]:setSubtype("die_slot_view")
    end

    self.image = IMG.dice_area
    self.img_sx = self.w/self.image:getWidth()
    self.img_sy = self.h/self.image:getHeight()

    --Create button for rolling dies
    local bw, bh = w / 4, h / 5
    local func = function()
        for _, die_slot_view in ipairs(self.die_slots) do
            local die = die_slot_view.obj.die
            if die then
                die:roll()
            end
        end
    end
    self.roll_button = Button(pos.x + w / 2 - bw / 2, pos.y + h / 2 - bh / 2, bw, bh, "roll", func)
end

--CLASS FUNCTIONS--

function DiceArea:draw()
    --Draw bg
    Color.set(Color.white())
    love.graphics.draw(self.image, self.pos.x, self.pos.y, nil,
                       self.img_sx, self.img_sy)

    --Draw slot
    for _, die_slot in ipairs(self.die_slots) do
        die_slot:draw()
    end

    --Draw Button
    self.roll_button:draw()
end

function DiceArea:mousepressed(...)
    self.roll_button:mousepressed(...)
end

--Return all dices that are in a die slot in this area
function DiceArea:getDice()
    local t = {}
    for _, die_slot_view in ipairs(self.die_slots) do
        if die_slot_view:getObj():getDie() then
            table.insert(t, die_slot_view:getObj():getDie())
        end
    end

    return t
end

return DiceArea
