local Color   = require "classes.color.color"
local Die     = require "classes.die.die"
local DieView = require "classes.die.die_view"
local DiceArea = require "classes.dice_area"

--MODULE FOR THE GAMESTATE: GAME--
local Class = require "extra_libs.hump.class"
local Vector = require "extra_libs.hump.vector"
local Util = require "util"
local Draw = require "draw"
local Drawable = require "classes.primitives.drawable"
local Match = require "classes.match"

local state = {}

--LOCAL VARIABLES--

local switch --If gamestate should change to another one

--LOCAL FUNCTIONS--

local die

local match

--STATE FUNCTIONS--

function state:enter()
    match = Match(8, 8, Vector(0, 0), 60, WIN_W, WIN_H, {{2, 2}, {6, 6}})
    match:start()

    --Create some example dice
    DieView(Die{"shoot","shoot","shoot","walk","walk","walk"}, 50, 30, Color.red()):register("L2", "die_view")
    DieView(Die{"shoot","shoot","shoot","walk","walk","walk"}, 120, 30, Color.red()):register("L2", "die_view")
    DieView(Die{"counter","counter","counter","clock","clock","clock"}, 190, 30, Color.blue()):register("L2", "die_view")
    DieView(Die{"counter","counter","counter","clock","clock","clock"}, 260, 30, Color.blue()):register("L2", "die_view")
    DieView(Die{"walk","counter","clock","shoot","shoot", "walk"}, 330, 30, Color.green()):register("L2", "die_view")

    --Create some example dice
    DieView(Die{"shoot","shoot","shoot","walk","walk","walk"}, 950, 30, Color.red()):register("L2", "die_view")
    DieView(Die{"shoot","shoot","shoot","walk","walk","walk"}, 1020, 30, Color.red()):register("L2", "die_view")
    DieView(Die{"counter","counter","counter","clock","clock","clock"}, 1090, 30, Color.blue()):register("L2", "die_view")
    DieView(Die{"counter","counter","counter","clock","clock","clock"}, 1160, 30, Color.blue()):register("L2", "die_view")
    DieView(Die{"walk","counter","clock","shoot","shoot", "walk"}, 1230, 30, Color.green()):register("L2", "die_view")
end

function state:leave()

    Util.destroyAll("force")

end


function state:update(dt)

    if switch == "menu" then
        --Gamestate.switch(GS.MENU)
    end
    MAIN_TIMER:update(dt)

    Util.destroyAll()

end

function state:draw()

    match:draw()

    Draw.allTables()

end

function state:keypressed(key, scancode, isrepeat)
    if key == "r" then
        Util.findId("my_die"):roll()
    end
    if key == 't' then
        match:playTurn()
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
    match:mousepressed(...)
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
