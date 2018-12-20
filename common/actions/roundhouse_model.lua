local Roundhouse = {}

function Roundhouse.applyAction(map, player)
    local pi, pj = player.tile:getPosition()
    for di = -1, 1, 1 do
        for dj = -1, 1, 1 do
            if di ~= 0 or dj ~= 0 then
                tile = map:get(pi + di, pj + dj)
                if tile then
                    tile:applyDamage(1)
                end
            end
        end
    end
end

return Roundhouse
