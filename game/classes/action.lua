--UTILITY FUNCTIONS FOR ACTION

local icons = {
    turn = love.graphics.newImage("assets/images/icons/wide-arrow-dunk.png"),
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
