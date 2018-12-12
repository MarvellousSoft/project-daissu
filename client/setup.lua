local Font = require "font"

--MODULE FOR SETUP STUFF--

local Camera = require "common.extra_libs.hump.camera"
local Timer = require "common.extra_libs.hump.timer"
local I18nSetup = require "i18n.setup"
local Actions = require "classes.actions"

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
        L3lower  = {}, --Below layer 3
        L3       = {}, --Layer 3
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
        turn_slot = new(path.."UI/turn_slot.png"),
        slot_number = new(path.."UI/slot_number.png"),
        starting_player = new(path.."UI/starting_player.png"),
        die_slot_free = new(path.."UI/die_slot_free.png"),
        die_slot_over = new(path.."UI/die_slot_over.png"),
        die_slot_occupied = new(path.."UI/die_slot_occupied.png"),
        die_slot_wrong = new(path.."UI/die_slot_wrong.png"),
        next_action = new(path.."UI/current_action.png"),
        button = new(path.."UI/button.png"),
        button_pressed = new(path.."UI/button_pressed.png"),
        button_locked = new(path.."UI/button_locked.png"),
        die_info = new(path.."UI/die_info.png"),
        --CHARACTERS
        player = new(path.."characters/player.png"),
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

    --OTHER--
    I18nSetup.init()
    Actions.init() -- After i18n init
end

--Return functions
return setup
