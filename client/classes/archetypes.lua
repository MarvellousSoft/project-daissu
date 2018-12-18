local Die = require "classes.die.die"
local Color = require "classes.color.color"

local Archetypes = {}

function Archetypes.getBaseBag(archetype)
    local bag = {}
    if archetype == 'melee' then
        for i = 1, 4 do
            table.insert(bag, Die({"walk", "run and hit", "long walk"}, 'movement'))
        end
        for i = 1, 2 do
            table.insert(bag, Die({"strong punch", "strong punch", "run and hit"}, 'attack'))
            table.insert(bag, Die({"roundhouse", "hookshot"}, 'utility'))
        end
    elseif archetype == 'ranged' then
        for i = 1, 4 do
            table.insert(bag, Die({"long walk", "long walk", "long walk", "walk"}, 'movement'))
        end
        for i = 1, 2 do
            table.insert(bag, Die({"shoot","shoot","explosion shot"}, 'attack'))
            table.insert(bag, Die({"shove", "shove", "walk", "long walk"}, 'utility'))
        end
    else
        error('Unknown archetype ' .. archetype)
    end
    return bag
end

return Archetypes
