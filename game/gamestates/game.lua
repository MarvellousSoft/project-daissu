local Color   = require "classes.color.color"
local Die     = require "classes.die.die"
local DieView = require "classes.die.die_view"
local DieArea = require "classes.die_area"

--MODULE FOR THE GAMESTATE: GAME--
local Class = require "extra_libs.hump.class"
local Vector = require "extra_libs.hump.vector"
local Util = require "util"
local Draw = require "draw"
local Drawable = require "classes.primitives.drawable"
local Match = require "classes.match"
local TurnSlots = require "classes.turn_slots"
local TurnSlotsView = require "classes.turn_slots_view"

local state = {}

--LOCAL VARIABLES--

local switch --If gamestate should change to another one

--LOCAL FUNCTIONS--

local die

local match

local turn_slots

--STATE FUNCTIONS--

function state:enter()
    match = Match(8, 8, Vector(500, 100), 50)
    match:addController(2, 2)
    match:addController(6, 6)
    match:start()

    local turn_slots_obj = TurnSlots(5)
    turn_slots = TurnSlotsView(turn_slots_obj, Vector(100, 660), 500, 100)

    --Create some example dice
    Die{"turn","blurn","churn","hurn","surn"}:setId("my_die")
    DieView(Util.findId("my_die"), 100, 100, Color.orange()):register("L2", "die_view")
    DieView(Die{"turn","turn","churn","hurn","surn"}, 200, 100, Color.red()):register("L2", "die_view")

    --Create some example dieslots
    DieArea(30, 250):register("L1", "die_area")
end

function state:leave()

    Util.destroyAll("force")

end


function state:update(dt)

    if switch == "menu" then
        --Gamestate.switch(GS.MENU)
    end

    Util.destroyAll()

end

function state:draw()

    turn_slots:draw()

    match:draw()

    Draw.allTables()

end

function state:keypressed(key, scancode, isrepeat)
    if key == "r" then
        Util.findId("my_die"):roll()
    end
    if key == 't' then
        match:playTurn({{"clock"}, {"walk"}}, {1, 2})
    end
end

function state:mousemoved(...)
    local dies = Util.findSubtype("die_view")
    if dies then
        for die_view in pairs(dies) do
            die_view:mousemoved(...)
        end
    end
end

function state:mousepressed(...)
    local dies = Util.findSubtype("die_view")
    if dies then
        for die_view in pairs(dies) do
            die_view:mousepressed(...)
        end
    end
end

function state:mousereleased(...)
    local dies = Util.findSubtype("die_view")
    if dies then
        for die_view in pairs(dies) do
            die_view:mousereleased(...)
        end
    end
end

--Return state functions
return state
