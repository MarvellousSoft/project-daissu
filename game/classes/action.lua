--UTILITY FUNCTIONS FOR ACTION

local icons = {
    clock  = love.graphics.newImage("assets/images/icons/clock.png"),
    counter = love.graphics.newImage("assets/images/icons/counter.png"),
    walk = love.graphics.newImage("assets/images/icons/walk.png"),
    shoot = love.graphics.newImage("assets/images/icons/shoot.png"),
    no_icon = love.graphics.newImage("assets/images/icons/no-icon.png")
}

local funcs = {}

--Returns icon for given action
function funcs.actionImage(action_name)
    if icons[action_name] then
        return icons[action_name]
    else
        return icons["no_icon"]
    end
end

return funcs
