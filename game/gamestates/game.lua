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
local Background = require "classes.background"
local Match = require "classes.match.match"
local Actions = require "classes.actions"

local state = {}

--LOCAL VARIABLES--

local switch --If gamestate should change to another one

--LOCAL FUNCTIONS--

local die


--STATE FUNCTIONS--

function state:enter()
    Background():register("BG", nil, "background")

    local match = Match(5, 5, Vector(0, 0), 72, WIN_W, WIN_H, {{2, 2}, {4, 4}})
    match:start()

    --Create some example dice
    DieView(Die({"shove","strong punch","strong punch","walk","walk","walk"}, 1), 50, 30, Color.red()):register("L2", "die_view")
    DieView(Die({"run and hit","run and hit","run and hit","walk","walk","walk"}, 1), 120, 30, Color.red()):register("L2", "die_view")
    DieView(Die({"counter","counter","counter","clock","clock","clock"}, 1), 190, 30, Color.blue()):register("L2", "die_view")
    DieView(Die({"counter","counter","counter","clock","clock","clock"}, 1), 260, 30, Color.blue()):register("L2", "die_view")
    DieView(Die({"walk","counter","clock","shoot","shoot", "walk"}, 1), 330, 30, Color.new(86, 239, 182)):register("L2", "die_view")

    --Create some example dice
    DieView(Die({"shoot","shoot","shoot","walk","walk","walk"}, 2), 950, 30, Color.red(), 2):register("L2", "die_view")
    DieView(Die({"shoot","shoot","shoot","walk","walk","walk"}, 2), 1020, 30, Color.red(), 2):register("L2", "die_view")
    DieView(Die({"counter","counter","counter","clock","clock","clock"}, 2), 1090, 30, Color.blue(), 2):register("L2", "die_view")
    DieView(Die({"counter","counter","counter","clock","clock","clock"}, 2), 1160, 30, Color.blue(), 2):register("L2", "die_view")
    DieView(Die({"walk","counter","clock","shoot","shoot", "walk"}, 2), 1230, 30, Color.new(86, 239, 182), 2):register("L2", "die_view")
end

function state:leave()

    Util.destroyAll("force")

end


function state:update(dt)

    if switch == "menu" then
        --Gamestate.switch(GS.MENU)
    end


    Util.updateTimers(dt)

    Util.updateDrawTable(dt)

    Util.destroyAll()

end

function state:draw()

    Draw.allTables()

end

function state:keypressed(key, scancode, isrepeat)
    local match = Util.findId("match")

    if key == "r" then
        Util.findId("my_die"):roll()
    end
    if key == 't' then
        match:playTurn()
    end
    if key == '1' then
        match:toggleHide(1)
    end
    if key == '2' then
        match:toggleHide(2)
    end
    if key == 'a' then
        local action = io.read()
        local match = Util.findId('match')
        Actions.executeAction(match, action, match.controllers[1], function() print('done custom action') end)
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
    local match = Util.findId("match")
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
