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

local Server = require "classes.net.server"
local Client = require "classes.net.client"

local state = {}

--LOCAL VARIABLES--

local switch --If gamestate should change to another one
local _number_turns

--LOCAL FUNCTIONS--

local die


--STATE FUNCTIONS--

function state:enter(prev, local_player)
    Background():register("BG", nil, "background")
    print('Starting game with local_player', local_player)

    if local_player == 1 then -- this is server
        print('SERVER INIT')
        Server.start()
        Client.start('localhost')
    else
        print('CLIENT INIT')
        Client.start(arg[3])
    end

    local match = Match(5, 5, Vector(0, 0), 72, WIN_W, WIN_H, {{2, 2, local_player == 1 and 'local' or 'remote'}, {4, 4, local_player == 2 and 'local' or 'remote'}})
    match:start()

    --Create some example dice
    DieView(Die({"long walk", "long walk", "long walk", "walk"}, 1), 50, 30, Color.green()):register("L2", "die_view")
    DieView(Die({"long walk", "long walk", "long walk", "walk"}, 1), 120, 30, Color.green()):register("L2", "die_view")
    DieView(Die({"shoot","shoot","explosion shot"}, 1), 190, 30, Color.red()):register("L2", "die_view")
    DieView(Die({"shove", "shove", "walk", "long walk"}, 1), 260, 30, Color.yellow()):register("L2", "die_view")

    --Create some example dice
    DieView(Die({"walk", "run and hit", "long walk"}, 2), 950, 30, Color.green(), 2):register("L2", "die_view")
    DieView(Die({"walk", "run and hit", "long walk"}, 2), 1020, 30, Color.green(), 2):register("L2", "die_view")
    DieView(Die({"strong punch", "strong punch", "run and hit"}, 2), 1090, 30, Color.red(), 2):register("L2", "die_view")
    DieView(Die({"roundhouse", "hookshot"}, 2), 1160, 30, Color.yellow(), 2):register("L2", "die_view")
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
