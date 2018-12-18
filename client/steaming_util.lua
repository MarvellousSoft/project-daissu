--MODULE WITH LOGICAL, MATHEMATICAL AND USEFUL STUFF--

local util = {}

---------------------
--UTILITIES FUNCTIONS
---------------------

--Receives a table of timer handles T and a timer TIMER. Cancels every handle from the timer
function util.clearTimerTable(T, TIMER)

    if not T then return end --If table is empty
    --Clear T table
    for _,o in pairs (T) do
        TIMER.cancel(o)
    end

end

--------------
--FIND OBJECTS
--------------

--Find an object based on an id
function util.findId(id)
    return ID_TABLE[id]
end

--Find a set of objects based on a subtype
function util.findSubtype(subtp)
    return SUBTP_TABLE[subtp]
end

----------------------
--MANIPULATE OBJECTS--
----------------------

--Set an atribute 'att' in all elements in a given 'T' table to 'value'
function util.setAtributeTable(T, att, value)
  for o in pairs(T) do
    o[att] = value
  end
end

--Set an atribute 'att' from an element with a given 'id' to 'value'
function util.setAtributeId(id, att, value)
  for o in pairs(ID_TABLE) do
    if o.id == id then
      o[att] = value
      return
    end
  end
end

--Set an atribute 'att' in all element with a given subtype 'st' to 'value'
function util.setAtributeSubtype(st, att, value)
  for o in pairs(SUBTP_TABLE[st]) do
    o[att] = value
  end
end

--------------------
--UPDATE FUNCTIONS
--------------------

--Update all objects in a table
function util.updateTable(dt, T)

    if not T then return end
    for o in pairs(T) do
        if o.update then
            o:update(dt)
        end
    end

end

--Update all objects with a subtype sb
function util.updateSubtype(dt, sb)
    util.updateTable(dt, SUBTP_TABLE[sb])
end

--Update an object with an id
function util.updateId(dt, id)
    local o

    o = util.findId(id)

    if not o then return end

    o:update(dt)

end

--Update all timers
function util.updateTimers(dt)

    MAIN_TIMER:update(dt)

end

--Update all objects in the draw tables
function util.updateDrawTable(dt)

	for _,T in pairs(DRAW_TABLE) do
		util.updateTable(dt, T)
	end

end

---------------------
--DESTROY FUNCTIONS--
---------------------

--[[Iterate through a table and destroys any element with the death flag on
    -If mode is "force", it will destroy all objects despite the "death" flag, except the ones with the "exception" flag on
    -If mode is "true_force", destroy all objects no matter the death flag or exception
]]
function util.destroyTable(T, mode)

    if not T then return end
    for o in pairs(T) do
        if o.death or mode == "force" then o:destroy() end
    end

end


--[[Destroys a single element if his death flag is on or mode is "force"
    -If mode is "force", it will destroy all objects despite the "death" flag, except the ones with the "exception" flag on
    -If mode is "true_force", destroy all objects no matter the death flag or exception
]]
function util.destroyId(id, mode)
    local o

    o = ID_TABLE[id]
    if o and
        (
          (o.death) or
          (mode == "force" and not o.exception) or
          (mode == "true_force")
        ) then
         o:destroy()
    end

end

--[[Iterate through all elements with a subtype sb and destroy anything with the death flag on
    -If mode is "force", it will destroy all objects despite the "death" flag, except the ones with the "exception" flag on
    -If mode is "true_force", destroy all objects no matter the death flag or exception
]]
function util.destroySubtype(sb, mode)

    util.destroyTable(SUBTP_TABLE[sb])

end

--[[Destroy all objects in the game that have the death flag set to true
    -If mode is "force", it will destroy all objects despite the "death" flag, except the ones with the "exception" flag on
    -If mode is "true_force", destroy all objects no matter the death flag or exception
]]
function util.destroyAll(mode)

    for T in pairs(SUBTP_TABLE) do
        util.destroySubtype(T, mode)
    end

    for o in pairs(ID_TABLE) do
        util.destroyId(o, mode)
    end

    for _,T in pairs(DRAW_TABLE) do
        util.destroyTable(T, mode)
    end

end

--Return functions
return util
