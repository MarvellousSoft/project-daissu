local Server = require "server"
local MatchManager = require "match_manager"
local WaitRoom = require "wait_room"
local log = require "common.extra_libs.log"

function love.load()
    log.outfile = "server.log"
    Server.init()
    MatchManager.init()
    WaitRoom.init()
end

function love.update(dt)
    Server.update()
end
