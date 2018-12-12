local en = {}
local pt = {}

-- [[Actions]]

-- Walk
en['actions/walk/name'] = "Walk"
pt['actions/walk/name'] = "Andar"

en['actions/walk/desc'] = "Walk 1 space in any direction."
pt['actions/walk/desc'] = "Ande 1 passo em qualquer direção."

en['actions/walk/flavor'] = "Slow and steady."
pt['actions/walk/flavor'] = "Devagar e sempre."

-- Long Walk
en['actions/long walk/name'] = "Long Walk"
pt['actions/long walk/name'] = "Correr"

en['actions/long walk/desc'] = "Walk 2 tiles in any direction."
pt['actions/long walk/desc'] = "Ande 2 passos em qualquer direção."

en['actions/long walk/flavor'] = "Two steps at a time is better."
pt['actions/long walk/flavor'] = "Dois passos é melhor que um."

-- Shove
en['actions/shove/name'] = "Shove"
pt['actions/shove/name'] = "Empurrar"

en['actions/shove/desc'] = "Push an adjacent enemy up to 2 tiles away, dealing 1 damage."
pt['actions/shove/desc'] = "Empurre um inimigo adjacente para até 2 espaços de distância, causando 1 de dano."

en['actions/shove/flavor'] = "todo"
pt['actions/shove/flavor'] = "todo"

-- Explosion Shot
en['actions/explosion shot/name'] = "Explosion Shot"
pt['actions/explosion shot/name'] = "Tiro Explosivo"

en['actions/explosion shot/desc'] = "Shoot in straight line, exploding on the first thing it hits. It deals 2 damage on its center, and 1 damage in the tiles around it."
pt['actions/explosion shot/desc'] = "Um tiro em linha reta que explode ao atingir o primeiro obstaculo. Causa 2 de dano no centro da explosão, e 1 de dano nos espaços em volta."

en['actions/explosion shot/flavor'] = "todo"
pt['actions/explosion shot/flavor'] = "todo"

-- Hookshot
en['actions/hookshot/name'] = "Hookshot"
pt['actions/hookshot/name'] = "Gancho"

en['actions/hookshot/desc'] = "Shoot a hook in straight line. If it hits an obstacle, pulls you to it. If it hits an enemy, pulls it towards you, dealing 1 damage to it."
pt['actions/hookshot/desc'] = "Atire um gancho em linha reta. Se atingir um obstáculo, você é puxado em direção a ele. Se atingir um inimigo, este é puxado até o seu lado, e sofre 1 de dano."

en['actions/hookshot/flavor'] = "Get over here!"
pt['actions/hookshot/flavor'] = "Get over here!"

-- Roundhouse
en['actions/roundhouse/name'] = "Roundhouse Kick"
pt['actions/roundhouse/name'] = "Giratória"

en['actions/roundhouse/desc'] = "Deal 1 damage to every tile around you (including diagonals)."
pt['actions/roundhouse/desc'] = "Cause 1 de dano em todos os espaços em volta de você (incluindo diagonais)."

en['actions/roundhouse/flavor'] = "todo"
pt['actions/roundhouse/flavor'] = "todo"

-- Run and Hit
en['actions/run and hit/name'] = "Run and Hit"
pt['actions/run and hit/name'] = "Andar e Bater"

en['actions/run and hit/desc'] = "Walk 1 tile in any direction. Deal 3 damage to the next tile in that direction."
pt['actions/run and hit/desc'] = "Ande 1 espaço em qualquer direção. Cause 3 dano no próximo espaço naquela direção."

en['actions/run and hit/flavor'] = "todo"
pt['actions/run and hit/flavor'] = "todo"

-- Shoot Forward
en['actions/shoot/name'] = "Shoot"
pt['actions/shoot/name'] = "Atirar"

en['actions/shoot/desc'] = "Shoot in straight line, dealing 1 damage to everything until the first obstacle."
pt['actions/shoot/desc'] = "Atire em linha reta, causando 1 de dano em todos os espaços até o primeiro obstáculo."

en['actions/shoot/flavor'] = "todo"
pt['actions/shoot/flavor'] = "todo"

-- Strong punch
en['actions/strong punch/name'] = "Strong Punch"
pt['actions/strong punch/name'] = "Socão"

en['actions/strong punch/desc'] = "Deal 2 damage to an adjacent tile."
pt['actions/strong punch/desc'] = "Cause 2 de dano em um espaço adjacente."

en['actions/strong punch/flavor'] = "todo"
pt['actions/strong punch/flavor'] = "todo"

return {
    en = en,
    pt = pt
}