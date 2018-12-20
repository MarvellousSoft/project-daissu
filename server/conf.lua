function love.conf(t)
    -- We don't need GUI
    -- Just using love to have luajit and luaenet configured properly
    t.window = false

    t.modules.audio = false              -- Enable the audio module (boolean)
    t.modules.event = false              -- Enable the event module (boolean)
    t.modules.graphics = false           -- Enable the graphics module (boolean)
    t.modules.image = false              -- Enable the image module (boolean)
    t.modules.joystick = false           -- Enable the joystick module (boolean)
    t.modules.keyboard = false           -- Enable the keyboard module (boolean)
    t.modules.math = true                -- Enable the math module (boolean)
    t.modules.mouse = false              -- Enable the mouse module (boolean)
    t.modules.physics = false            -- Enable the physics module (boolean)
    t.modules.sound = false              -- Enable the sound module (boolean)
    t.modules.system = false             -- Enable the system module (boolean)
    t.modules.timer = true              -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
    t.modules.touch = false              -- Enable the touch module (boolean)
    t.modules.video = false              -- Enable the video module (boolean)
    t.modules.window = false             -- Enable the window module (boolean)
    t.modules.thread = false             -- Enable the thread module (boolean)
end
