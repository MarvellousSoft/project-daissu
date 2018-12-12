--MODULE FOR THE GAMESTATE: GAME--
local Vector     = require "common.extra_libs.hump.vector"
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

function state:enter(prev, game_info, char_type)
    my_id = game_info.local_id

    Background():register("BG", nil, "background")

    local player_info = {}
    for i = 1, game_info.player_count do
        table.insert(player_info, my_id == i and 'local' or 'remote')
    end

    match = Match(5, 5, Vector(0, 0), 72, WIN_W, WIN_H, player_info, my_id, char_type)
    match:start()
    MAIN_TIMER:after(1, function() match:startNewTurn() end)
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
