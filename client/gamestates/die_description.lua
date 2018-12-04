--MODULE FOR THE GAMESTATE: DIE DESCRIPTION--
local Gamestate      = require "common.extra_libs.hump.gamestate"
local Util           = require "util"
local Draw           = require "draw"
local BlackScreen    = require "classes.blackscreen"
local DieFaces       = require "classes.die.die_faces"

local state = {}

--LOCAL VARIABLES--

local switch --If gamestate should change to another one

--LOCAL FUNCTIONS--

--STATE FUNCTIONS--

local _blackscreen
local _diefaces

function state:enter(prev, die)
    switch = false
    _blackscreen = BlackScreen()
    _blackscreen:register("L3lower")
    _diefaces = DieFaces(die)
    _diefaces:register("L3")
end

function state:leave()
    _blackscreen:kill()
    _diefaces:kill()
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
    if not _diefaces:mousepressed(...) then
        switch = "game"
    end
end

function state:mousereleased(...)

end

--Return state functions
return state
