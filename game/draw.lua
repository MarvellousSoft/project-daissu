--MODULE FOR DRAWING STUFF--

local draw = {}

----------------------
--BASIC DRAW FUNCTIONS
----------------------

--Draws every drawable object from all tables
function draw.allTables()

    DrawTable(DRAW_TABLE.BG)

    CAM:attach() --Start tracking camera

    DrawTable(DRAW_TABLE.L1) --(die slots, die arenas)

    DrawTable(DRAW_TABLE.L2) --(dice)

    DrawTable(DRAW_TABLE.L2upper) --Above L2 (selected die)

    CAM:detach() --Stop tracking camera

    DrawTable(DRAW_TABLE.GUI)

end

--Draw all the elements in a table
function DrawTable(t)

    for o in pairs(t) do
        if not o.invisible then
          o:draw() --Call the object respective draw function
        end
    end

end

--Return functions
return draw
