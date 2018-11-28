local Font = require "font"

--MODULE FOR SETUP STUFF--

local Camera = require "common.extra_libs.hump.camera"
local Timer = require "common.extra_libs.hump.timer"

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
        L0       = {}, --Layer 0
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
    local new = love.graphics.newImage
    local path = "assets/images/"
    IMG = { --Table containing all the images
        --TILES
        maptile_regular = new(path.."tiles/maptile1.png"),
        maptile_broken = new(path.."tiles/maptile2.png"),
        --UI
        mat = new(path.."UI/mat.png"),
        turn_slots_orange = new(path.."UI/turn_slots_orange.png"),
        turn_slots_purple = new(path.."UI/turn_slots_purple.png"),
        starting_player_purple = new(path.."UI/starting_player_purple.png"),
        starting_player_orange = new(path.."UI/starting_player_orange.png"),
        die_slot_free = new(path.."UI/die_slot_free.png"),
        die_slot_over = new(path.."UI/die_slot_over.png"),
        die_slot_occupied = new(path.."UI/die_slot_occupied.png"),
        die_slot_wrong = new(path.."UI/die_slot_wrong.png"),
        next_action_purple = new(path.."UI/current_action_purple.png"),
        next_action_orange = new(path.."UI/current_action_orange.png"),
        next_action_grey = new(path.."UI/current_action_grey.png"),
        button = new(path.."UI/button.png"),
        --CHARACTERS
        player_orange  = new(path.."characters/player1.png"),
        player_purple = new(path.."characters/player2.png"),
        --OTHER IMAGES
        background = new(path.."background.png")

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
