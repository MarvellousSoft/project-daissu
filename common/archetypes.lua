local Die = require "common.die.die"

local Archetypes = {}

function Archetypes.getBaseBag(archetype)
    local bag = {}
    if archetype == 'melee' then
        for i = 1, 4 do
            table.insert(bag, Die({"walk", "run and hit", "long walk"}, 'movement', i))
        end
        for i = 1, 2 do
            table.insert(bag, Die({"strong punch", "strong punch", "run and hit"}, 'attack', 5 + (i - 1) * 2))
            table.insert(bag, Die({"roundhouse", "hookshot"}, 'utility', 6 + (i - 1) * 2))
        end
    elseif archetype == 'ranged' then
        for i = 1, 4 do
            table.insert(bag, Die({"long walk", "long walk", "long walk", "walk"}, 'movement', i))
        end
        for i = 1, 2 do
            table.insert(bag, Die({"shoot","shoot","explosion shot"}, 'attack', 5 + (i - 1) * 2))
            table.insert(bag, Die({"shove", "shove", "walk", "long walk"}, 'utility', 6 + (i - 1) * 2))
        end
    else
        error('Unknown archetype ' .. archetype)
    end
    return bag
end

return Archetypes
