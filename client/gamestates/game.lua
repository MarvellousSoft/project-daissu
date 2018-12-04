--MODULE FOR THE GAMESTATE: GAME--
local Vector     = require "common.extra_libs.hump.vector"
local Gamestate  = require "common.extra_libs.hump.gamestate"
local Util       = require "util"
local Draw       = require "draw"
local Drawable   = require "classes.primitives.drawable"
local Background = require "classes.background"
local Match      = require "classes.match.match"
local Actions    = require "classes.actions"
local Client     = require "classes.net.client"

local state = {}

--LOCAL VARIABLES--

local switch --If gamestate should change to another one

--STATE FUNCTIONS--

local my_id
local match

function state:enter(prev, local_player, char_type)
    my_id = local_player

    Background():register("BG", nil, "background")

    match = Match(5, 5, Vector(0, 0), 72, WIN_W, WIN_H, {{2, 2, local_player == 1 and 'local' or 'remote'}, {4, 4, local_player == 2 and 'local' or 'remote'}}, my_id, char_type)
    match:start()
    MAIN_TIMER:after(1, function() match:startTurn() end)
end

function state:leave()

    Util.destroyAll("force")

end


function state:update(dt)
    match:update(dt)

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
    if key == "o" then
        Gamestate.push(GS.DIE_DESC)
    end
    if key == 't' then
        match:playTurn(my_id, function()
            MAIN_TIMER:after(1.5, function()
                match:startTurn()
            end)
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
