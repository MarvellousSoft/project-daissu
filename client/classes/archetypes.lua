local Die = require "classes.die.die"
local Color = require "classes.color.color"

local Archetypes = {}

function Archetypes.getBaseBag(archetype, my_id)
    local bag = {}
    if archetype == 'melee' then
        table.insert(bag, Die({"walk", "run and hit", "long walk"}, my_id, Color.green()))
        table.insert(bag, Die({"walk", "run and hit", "long walk"}, my_id, Color.green()))
        table.insert(bag, Die({"strong punch", "strong punch", "run and hit"}, my_id, Color.red()))
        table.insert(bag, Die({"roundhouse", "hookshot"}, my_id, Color.yellow()))
    elseif archetype == 'ranged' then
        table.insert(bag, Die({"long walk", "long walk", "long walk", "walk"}, my_id, Color.green()))
        table.insert(bag, Die({"long walk", "long walk", "long walk", "walk"}, my_id, Color.green()))
        table.insert(bag, Die({"shoot","shoot","explosion shot"}, my_id, Color.red()))
        table.insert(bag, Die({"shove", "shove", "walk", "long walk"}, my_id, Color.yellow()))
    else
        error('Unknown archetype ' .. archetype)
    end
    return bag
end

return Archetypes
