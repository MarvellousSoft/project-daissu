local Color = require "classes.color.color"
local Die = require "classes.die.die"
local DieView = require "classes.die.die_view"

--MODULE FOR THE GAMESTATE: GAME--
local Class = require "extra_libs.hump.class"
local Vector = require "extra_libs.hump.vector"
local Util = require "util"
local Draw = require "draw"
local Drawable = require "classes.primitives.drawable"
local Map = require "classes.map.map"
local MapView = require "classes.map.map_view"
local Controller = require "classes.map.controller"

local state = {}

--LOCAL VARIABLES--

local switch --If gamestate should change to another one

--LOCAL FUNCTIONS--

local die

local map
local controller

--STATE FUNCTIONS--

function state:enter()
    local map_obj = Map(10, 10)
    map = MapView(map_obj, Vector(500, 100), 50)
    controller = Controller(map_obj, 5, 3)
	Die{"turn","blurn","churn","hurn","surn"}:setId("my_die")
	DieView(Util.findId("my_die"), 100, 100, Color.orange()):addElement("L1", "die_view")

    DieView(Die{"turn","turn","churn","hurn","surn"}, 200, 100, Color.red()):addElement("L1", "die_view")
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

    map:draw()

    Draw.allTables()

end

function state:keypressed(key, scancode, isrepeat)
    if key == "r" then
        Util.findId("my_die"):roll()
    end
    if key == 'up' or key == 'down' or key == 'left' or key == 'right' then
        controller:applyAction(key)
    end
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
