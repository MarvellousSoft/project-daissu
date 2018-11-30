--MODULE FOR COLOR AND STUFF--

local Class = require "common.extra_libs.hump.class"

local hsl = {}

--Color object
HSL = Class{
    init = function(self, h, s, l, a)
        self.h     = h or 255 --Hue
        self.s     = s or 255 --Saturation
        self.l     = l or 255 --Lightness
        self.a     = a or 255 --Alpha

        self.tp = "HSL"
    end
}

------------------
--USEFUL FUNCTIONS
------------------

--Converts HSL to RGB. (input and output range: 0 - 255)
function hsl.convert(h, s, l, a)
    if s<=0 then return l,l,l,a end

    h, s, l = h/256*6, s/255, l/255

    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0

    if h < 1     then
        r,g,b = c,x,0
    elseif h < 2 then
        r,g,b = x,c,0
    elseif h < 3 then
        r,g,b = 0,c,x
    elseif h < 4 then
        r,g,b = 0,x,c
    elseif h < 5 then
        r,g,b = x,0,c
    else
        r,g,b = c,0,x
    end

    return (r+m)*255,(g+m)*255,(b+m)*255,a
end

--Converts HSL in (degrees, percent, percent) to standard (0-255) value
function hsl.stdv(h,s,l,a)

    local sh = h*255/360
    local ss = s*255/100
    local sl = l*255/100
    local a = a or 255

    return sh, ss, sl, a
end

--Return hue, saturation and lightness levels of given color c
function hsl.hsl(c) return c.h, c.s, c.l end

--Return hue, saturation, lightness and alpha levels of given color c
function hsl.hsla(c) return c.h, c.s, c.l, c.a end

--Return alpha level of given color c
function hsl.a(c) return c.a end

--Copy colors from a color c2 to a color c1
function hsl.copy(c1, c2)  c1.h, c1.s, c1.l, c1.a = c2.h, c2.s, c2.l, c2.a end

--Set the color used for drawing
function hsl.set(c) love.graphics.setColor(hsl.convert(c.h, c.s, c.l, c.a)) end

--Set the color used for drawing using given alpha
function hsl.setWithAlpha(c,alpha) love.graphics.setColor(hsl.convert(c.h, c.s, c.l, alpha)) end

--Set the color used for drawing using 255 as alpha amount
function hsl.setOpaque(c) love.graphics.setColor(hsl.convert(c.h, c.s, c.l, 255)) end

--Set the color used for drawing using 0 as alpha amount
function hsl.setTransp(c) love.graphics.setColor(hsl.convert(c.h, c.s, c.l, 0)) end

---------------
--PRESET COLORS
---------------

--Dark Black
local _black = HSL(hsl.stdv(0,0,0))
function hsl.black(new)
    return new and HSL(hsl.stdv(0,0,0)) or _black
end

--Clean white
local _white = HSL(hsl.stdv(0,0,100))
function hsl.white(new)
    return new and HSL(hsl.stdv(0,0,100)) or _white
end

--Cheerful red
local _red = HSL(hsl.stdv(351,95.4,57.1))
function hsl.red(new)
    return new and HSL(hsl.stdv(351,95.4,57.1)) or _red
end

--Calm green
local _green = HSL(hsl.stdv(117,90.6,66.5))
function hsl.green(new)
    return new and HSL(hsl.stdv(117,90.6,66.5)) or _green
end

--Smooth blue
local _blue = HSL(hsl.stdv(217,78.6,45.9))
function hsl.blue(new)
    return new and HSL(hsl.stdv(217,78.6,45.9)) or _blue
end

--Jazzy orange
local _orange = HSL(hsl.stdv(24,90.6,66.5))
function hsl.orange(new)
    return new and HSL(hsl.stdv(24,90.6,66.5)) or _orange
end

--Sunny yellow
local _yellow = HSL(hsl.stdv(55,85.4,59.8))
function hsl.yellow(new)
    return new and HSL(hsl.stdv(55,85.4,59.8)) or _yellow
end

--Sexy purple
local _purple = HSL(hsl.stdv(267,85.6,59.2))
function hsl.purple(new)
    return new and HSL(hsl.stdv(267,85.6,59.2)) or _purple
end

--Happy pink
local _pink = HSL(hsl.stdv(318,85.8,64.1))
function hsl.pink(new)
    return new and HSL(hsl.stdv(318,85.8,64.1)) or _pink
end

--Invisible transparent
local _transp = HSL(0,0,0,0)
function hsl.transp(new)
    return new and HSL(0,0,0,0) or _transp
end

--Return functions
return hsl
