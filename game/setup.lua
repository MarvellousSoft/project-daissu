local Font = require "font"

--MODULE FOR SETUP STUFF--

local Camera = require "extra_libs.hump.camera"
local Timer = require "extra_libs.hump.timer"

local setup = {}

--------------------
--SETUP FUNCTIONS
--------------------

--Set game's global variables, random seed, window configuration and anything else needed
function setup.config()

    --RANDOM SEED--
    love.math.setRandomSeed( os.time() )

    --TIMERS--
    MAIN_TIMER = Timer.new()  --General Timer

    --GLOBAL VARIABLES--
    DEBUG = true --DEBUG mode status

    WIN_W = 1366 --The original width of your game. Work with this value when using res_manager multiple resolutions support
    WIN_H = 768  --The original height of your game. Work with this value when using res_manager multiple resolutions support

    --INITIALIZING TABLES--
    --Drawing Tables
    DRAW_TABLE = {
        BG       = {}, --Background (bottom layer, first to draw)
        L1       = {}, --Layer 1
        L2       = {}, --Layer 2
        L2upper  = {}, --Above layer 2
        GUI      = {}  --Graphic User Interface (top layer, last to draw)
    }
    --Other Tables
    SUBTP_TABLE = {} --Table with tables for each subtype (for fast lookup)
    ID_TABLE = {} --Table with elements with Ids (for fast lookup)

    --CAMERA--
    CAM = Camera(WIN_W/2, WIN_H/2) --Set camera position to center of screen

    --FONTS--
    Font.new("regular", "assets/fonts/fira-mono-regular.ttf")

    --IMAGES--
    IMG = { --Table containing all the images
    }

    --AUDIO--
    SFX = { --Table containing all the sound fx
    }

    BGM = { --Table containing all the background music tracks
    }

    --SHADERS--
        --

end

--Return functions
return setup
