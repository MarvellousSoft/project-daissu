local Die = require "classes.die.die"

local Archetypes = {}

function Archetypes.getBaseBag(archetype, my_id)
    local bag = {}
    if archetype == 'melee' then
        table.insert(bag, Die({"walk", "run and hit", "long walk"}, my_id))
        table.insert(bag, Die({"walk", "run and hit", "long walk"}, my_id))
        table.insert(bag, Die({"strong punch", "strong punch", "run and hit"}, my_id))
        table.insert(bag, Die({"roundhouse", "hookshot"}, my_id))
    elseif archetype == 'ranged' then
        table.insert(bag, Die({"long walk", "long walk", "long walk", "walk"}, my_id))
        table.insert(bag, Die({"long walk", "long walk", "long walk", "walk"}, my_id))
        table.insert(bag, Die({"shoot","shoot","explosion shot"}, my_id))
        table.insert(bag, Die({"shove", "shove", "walk", "long walk"}, my_id))
    else
        error('Unknown archetype ' .. archetype)
    end
    return bag
end

return Archetypes
