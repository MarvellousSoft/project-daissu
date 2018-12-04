--MODULE FOR THE GAMESTATE: GAME--
local Vector      = require "common.extra_libs.hump.vector"
local Gamestate   = require "common.extra_libs.hump.gamestate"
local Util        = require "util"
local Draw        = require "draw"
local BlackScreen = require "classes.blackscreen"

local state = {}

--LOCAL VARIABLES--

local switch --If gamestate should change to another one

--LOCAL FUNCTIONS--

--STATE FUNCTIONS--

local _blackscreen

function state:enter(prev, die, current_side)
    switch = false
    _blackscreen = BlackScreen()
    _blackscreen:register("L3lower")
    --DieDescription(die, current_side):register("L3", nil, "die_description")
end

function state:leave()

    _blackscreen:kill()

end


function state:update(dt)
    if switch == "game" then
        Gamestate.pop()
    end

    Util.updateTimers(dt)

    Util.updateDrawTable(dt)

    Util.destroyAll()
end

function state:draw()

    Draw.allTables()

end

function state:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        switch = "game"
    end
end

function state:mousemoved(...)

end

function state:mousepressed(...)
    switch = "game"
end

function state:mousereleased(...)

end

--Return state functions
return state
