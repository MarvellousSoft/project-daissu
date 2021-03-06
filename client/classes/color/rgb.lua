local Hsl = require "classes.color.hsl"
--MODULE FOR COLOR AND STUFF--

local Class = require "common.extra_libs.hump.class"

local rgb_funcs = {}

--Color object
RGB = Class{
    init = function(self, r, g, b, a)
        self.r     = r or 255 --Red
        self.g     = g or 255 --Green
        self.b     = b or 255 --Blue
        self.a     = a or 255 --Alpha

        self.tp = "RGB"
    end
}

------------------
--USEFUL FUNCTIONS
------------------
--Converts RGB to HSL. (input and output range: 0 - 255)
function rgb_funcs.convert(r, g, b, a)

    r = r/255
    g = g/255
    b = b/255

    local min = math.min(r,g,b)
    local max = math.max(r,g,b)

    --Get lightness in %
    local l = (min+max)/2
    local delta = max - min

    --Get saturation in %
    local s
    if delta == 0 then
        s = 0
    elseif 2 * l - 1 > 0 then
        s = delta / (1 - (2 * l - 1))
    else
        s = delta / (1 + (2 * l - 1))
    end

    --Get Hue in degrees
    local h = 0
    if r == max then
        h = (g-b)/(max-min)
    elseif g == max then
        h = 2.0 + (b-r)/(max-min)
    elseif b == max then
        h = 4.0 + (r-g)/(max-min)
    end
    h = h* 60 / 360

    --Convert them to the standard values
    return h * 255, s * 255, l * 255, a
end

--Return red, green and blue levels of given color c
function rgb_funcs.rgb(c) return c.r, c.g, c.b end

--Return red, green, blue and alpha levels of given color c
function rgb_funcs.rgba(c) return c.r, c.g, c.b, c.a end

--Return alpha level of given color c
function rgb_funcs.a(c) return c.a end

--Copy colors from a color c2 to a color c1
function rgb_funcs.copy(c1, c2)  c1.r, c1.g, c1.b, c1.a = c2.r, c2.g, c2.b, c2.a end

--Set the color used for drawing
function rgb_funcs.set(c)
    if type(c) == "string" then
        c = rgb_funcs[c]()
    end
    love.graphics.setColor(c.r, c.g, c.b, c.a)
end

--Set the color used for drawing, using given alpha
function rgb_funcs.setWithAlpha(c,alpha) love.graphics.setColor(c.r, c.g, c.b, alpha) end

--Set the color used for drawing using 255 as alpha amount
function rgb_funcs.setOpaque(c) love.graphics.setColor(c.r, c.g, c.b, 255) end

--Set the color used for drawing using 0 as alpha amount
function rgb_funcs.setTransp(c) love.graphics.setColor(c.r, c.g, c.b, 0) end

---------------
--PRESET COLORS
---------------

--Dark Black
local _black = RGB(0,0,0)
function rgb_funcs.black(new)
    return new and RGB(0,0,0) or _black
end

--Clean white
local _white = RGB(255,255,255)
function rgb_funcs.white(new)
    return new and RGB(255,255,255) or _white
end

--Cheerful red
local _red = RGB(240,41,74)
function rgb_funcs.red(new)
    return new and RGB(240,41,74) or _red
end

--Calm green
local _green = RGB(99,247,92)
function rgb_funcs.green(new)
    return new and RGB(99,247,92) or _green
end

--Smooth blue
local _blue = RGB(25,96,209)
function rgb_funcs.blue(new)
    return new and RGB(25,96,209) or _blue
end

--Jazzy orange
local _orange = RGB(247,154,92)
function rgb_funcs.orange(new)
    return new and RGB(247,154,92) or _orange
end

--Sunny yellow
local _yellow = RGB(240,225,65)
function rgb_funcs.yellow(new)
    return new and RGB(240,225,65) or _yellow
end

--Sexy purple
local _purple = RGB(142,62,240)
function rgb_funcs.purple(new)
    return new and RGB(142,62,240) or _purple
end

--Happy pink
local _pink = RGB(242,85,195)
function rgb_funcs.pink(new)
    return new and RGB(242,85,195) or _pink
end

--Invisible transparent
local _transp = RGB(0,0,0,0)
function rgb_funcs.transp(new)
    return new and RGB(0,0,0,0) or _transp
end

--Return functions
return rgb_funcs
