local Server = require "server"
local MatchManager = require "match_manager"
local WaitRoom = require "wait_room"
local log = require "common.extra_libs.log"

function love.load()
    -- We don't want the server to crash, let's just log errors
    assert = function(cond, ...)
        if not cond then
            if select('#', ...) > 0 then log.fatal(...) end
            log.fatal(debug.traceback('Assertion Failed.', 2))
        end
    end
    error = function(...)
        if select('#', ...) > 0 then log.fatal(...) end
        log.fatal(debug.traceback('Error.', 2))
    end
    --
    log.outfile = "server.log"
    Server.init()
    MatchManager.init()
    WaitRoom.init()
end

function love.update(dt)
    Server.update()
end
