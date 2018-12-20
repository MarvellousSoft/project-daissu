local StrongPunch = {}

function StrongPunch.applyAction(map, player, i, j)
    map:get(i, j):applyDamage(2)
end

return StrongPunch
