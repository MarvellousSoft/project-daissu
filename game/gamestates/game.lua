--MODULE FOR THE GAMESTATE: GAME--

local state = {}

--LOCAL VARIABLES--

local switch --If gamestate should change to another one

--LOCAL FUNCTIONS--

--STATE FUNCTIONS--

function state:enter()

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

	Color.set(Color.white())
	love.graphics.rectangle("fill", 10, 10, 100, 100)

    Draw.allTables()

end

function state:keypressed(key)

	if key == "r" then
		switch = "MENU"
	else
    	Util.defaultKeyPressed(key)
	end

end

--Return state functions
return state
