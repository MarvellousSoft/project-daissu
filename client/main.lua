--HUMP MODULES
local Gamestate = require "common.extra_libs.hump.gamestate"
local Timer = require "common.extra_libs.hump.timer"

--OUR MODULES
local Setup = require "setup"
local ResManager = require "res_manager"

--GAMESTATES
GS = {
    GAME      = require "gamestates.game", --Game Gamestate
    CONN_MENU = require "gamestates.connection_menu",
    DIE_DESC  = require "gamestates.die_description"
}

-- Networking
local Client = require "classes.net.client"

------------------
--LÖVE FUNCTIONS--
------------------

function love.load()

    Setup.config() --Configure your game

    Gamestate.registerEvents() --Overwrites love callbacks to call Gamestate as well

    --[[
        Setup support for multiple resolutions. ResManager.init() Must be called after Gamestate.registerEvents()
        so it will properly call the draw function applying translations.
    ]]
    ResManager.init()

    Gamestate.switch(GS.CONN_MENU)
    --Gamestate.switch(GS.GAME, tonumber(arg[2])) --Jump to the inicial state

end

function love.update(dt)
    Timer.update(dt)
    Client.update(dt)
end

function love.quit()
    Client.quit()
end

local default_err_handler = love.errhand
function love.errhand(...)
    Client.quit()
    default_err_handler(...)
end
