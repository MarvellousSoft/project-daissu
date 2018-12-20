local ActionsModel = {}

local helpers = {
    walk = (require "common.actions.walk_model")(1),
    shoot = require "common.actions.shoot_model",
    roundhouse = require "common.actions.roundhouse_model",
    ['explosion shot'] = require "common.actions.explosion_shot_model",
    ['strong punch'] = require "common.actions.strong_punch_model",
    ['run and hit'] = require "common.actions.run_and_hit_model",
    shove = require "common.actions.shove_model",
    ['long walk'] = (require "common.actions.walk_model")(2),
    hookshot = require "common.actions.hookshot_model",
}

function ActionsModel.applyAction(action_name, ...)
    if not helpers[action_name] then
        error("Unknown action " .. action_name)
    else
        return helpers[action_name].applyAction(...)
    end
end

-- possibly improve this
function ActionsModel.needsInput(action_name)
    return action_name ~= 'roundhouse'
end

return ActionsModel
