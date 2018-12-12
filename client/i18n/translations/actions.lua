local en = {}
local pt = {}

-- [[Actions]]

-- Walk
en['walk/name'] = "Walk"
pt['walk/name'] = "Andar"

en['walk/desc'] = "Walk 1 space in any direction."
pt['walk/desc'] = "Ande 1 passo em qualquer direção."

en['walk/flavor'] = "Slow and steady."
pt['walk/flavor'] = "Devagar e sempre."

-- Long Walk
en['long walk/name'] = "Long Walk"
pt['long walk/name'] = "Correr"

en['long walk/desc'] = "Walk 2 tiles in any direction."
pt['long walk/desc'] = "Ande 2 passos em qualquer direção."

en['long walk/flavor'] = "Two steps at a time is better."
pt['long walk/flavor'] = "Dois passos é melhor que um."

-- Shove
en['shove/name'] = "Shove"
pt['shove/name'] = "Empurrar"

en['shove/desc'] = "Push an adjacent enemy up to 2 tiles away, dealing 1 damage."
pt['shove/desc'] = "Empurre um inimigo adjacente para até 2 espaços de distância, causando 1 de dano."

en['shove/flavor'] = "todo"
pt['shove/flavor'] = "todo"

-- Explosion Shot
en['explosion shot/name'] = "Explosion Shot"
pt['explosion shot/name'] = "Tiro Explosivo"

en['explosion shot/desc'] = "Shoot in straight line, exploding on the first thing it hits. It deals 2 damage on its center, and 1 damage in the tiles around it."
pt['explosion shot/desc'] = "Um tiro em linha reta que explode ao atingir o primeiro obstaculo. Causa 2 de dano no centro da explosão, e 1 de dano nos espaços em volta."

en['explosion shot/flavor'] = "todo"
pt['explosion shot/flavor'] = "todo"

-- Hookshot
en['hookshot/name'] = "Hookshot"
pt['hookshot/name'] = "Gancho"

en['hookshot/desc'] = "Shoot a hook in straight line. If it hits an obstacle, pulls you to it. If it hits an enemy, pulls it towards you, dealing 1 damage to it."
pt['hookshot/desc'] = "Atire um gancho em linha reta. Se atingir um obstáculo, você é puxado em direção a ele. Se atingir um inimigo, este é puxado até o seu lado, e sofre 1 de dano."

en['hookshot/flavor'] = "Get over here!"
pt['hookshot/flavor'] = "Get over here!"

-- Roundhouse
en['roundhouse/name'] = "Roundhouse Kick"
pt['roundhouse/name'] = "Giratória"

en['roundhouse/desc'] = "Deal 1 damage to every tile around you (including diagonals)."
pt['roundhouse/desc'] = "Cause 1 de dano em todos os espaços em volta de você (incluindo diagonais)."

en['roundhouse/flavor'] = "todo"
pt['roundhouse/flavor'] = "todo"

-- Run and Hit
en['run and hit/name'] = "Run and Hit"
pt['run and hit/name'] = "Andar e Bater"

en['run and hit/desc'] = "Walk 1 tile in any direction. Deal 3 damage to the next tile in that direction."
pt['run and hit/desc'] = "Ande 1 espaço em qualquer direção. Cause 3 dano no próximo espaço naquela direção."

en['run and hit/flavor'] = "todo"
pt['run and hit/flavor'] = "todo"

-- Shoot Forward
en['shoot/name'] = "Shoot"
pt['shoot/name'] = "Atirar"

en['shoot/desc'] = "Shoot in straight line, dealing 1 damage to everything until the first obstacle."
pt['shoot/desc'] = "Atire em linha reta, causando 1 de dano em todos os espaços até o primeiro obstáculo."

en['shoot/flavor'] = "todo"
pt['shoot/flavor'] = "todo"

-- Strong punch
en['strong punch/name'] = "Strong Punch"
pt['strong punch/name'] = "Socão"

en['strong punch/desc'] = "Deal 2 damage to an adjacent tile."
pt['strong punch/desc'] = "Cause 2 de dano em um espaço adjacente."

en['strong punch/flavor'] = "todo"
pt['strong punch/flavor'] = "todo"

return {
    en = en,
    pt = pt
}