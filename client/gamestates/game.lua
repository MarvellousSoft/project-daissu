local Color   = require "classes.color.color"
local Die     = require "classes.die.die"
local DieView = require "classes.die.die_view"

--MODULE FOR THE GAMESTATE: GAME--
local Class = require "common.extra_libs.hump.class"
local Vector = require "common.extra_libs.hump.vector"
local Util = require "util"
local Draw = require "draw"
local Drawable = require "classes.primitives.drawable"
local Background = require "classes.background"
local Match = require "classes.match.match"
local Actions = require "classes.actions"

local Client = require "classes.net.client"

local state = {}

--LOCAL VARIABLES--

local switch --If gamestate should change to another one
local _number_turns

--LOCAL FUNCTIONS--

local die


--STATE FUNCTIONS--

local my_id
local match

function state:enter(prev, local_player, char_type)
    my_id = local_player

    Background():register("BG", nil, "background")

    match = Match(5, 5, Vector(0, 0), 72, WIN_W, WIN_H, {{2, 2, local_player == 1 and 'local' or 'remote'}, {4, 4, local_player == 2 and 'local' or 'remote'}}, my_id, char_type)
    match:start()
    match:startTurn()
end

function state:leave()

    Util.destroyAll("force")

end


function state:update(dt)
    match:update(dt)

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
    if key == "r" then
        Util.findId("my_die"):roll()
    end
    if key == 't' then
        match:playTurn(my_id, function()
            match:startTurn()
        end)
    end
    if key == 'a' then
        local action = io.read()
        Actions.executeAction(match, action, match.controllers[1], function() print('done custom action') end)
    end
end

function state:mousemoved(...)
    match:mousemoved(...)
end

function state:mousepressed(...)
    match:mousepressed(...)
end

function state:mousereleased(...)
    match:mousereleased(...)
end

--Return state functions
return state
