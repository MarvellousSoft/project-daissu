local Color = require "classes.color.color"
local Die = require "classes.die.die"
local DieView = require "classes.die.die_view"

--MODULE FOR THE GAMESTATE: GAME--
local Class = require "extra_libs.hump.class"
local Util = require "util"
local Draw = require "draw"
local Drawable = require "classes.primitives.drawable"

local state = {}

--LOCAL VARIABLES--

local switch --If gamestate should change to another one

--LOCAL FUNCTIONS--

local die

--STATE FUNCTIONS--

function state:enter()
	die = Die{"turn","blurn","churn","hurn","surn"}
	local dv = DieView(die, 100, 100, Color.orange())
	dv:addElement("L1", "die_view")
end

function state:leave()

    Util.destroyAll("force")

end


function state:update(dt)

    if switch == "menu" then
        --Gamestate.switch(GS.MENU)
    end

    Util.destroyAll()

end

function state:draw()

    Draw.allTables()

end

function state:mousemoved(...)
	local dies = Util.findSubtype("die_view")
	if dies then
		for die_view in pairs(dies) do
			die_view:mousemoved(...)
		end
	end
end

function state:mousepressed(...)
	local dies = Util.findSubtype("die_view")
	if dies then
		for die_view in pairs(dies) do
			die_view:mousepressed(...)
		end
	end
end

function state:mousereleased(...)
	local dies = Util.findSubtype("die_view")
	if dies then
		for die_view in pairs(dies) do
			die_view:mousereleased(...)
		end
	end
end

--Return state functions
return state
