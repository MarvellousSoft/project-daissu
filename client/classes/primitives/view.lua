local Class = require "common.extra_libs.hump.class"

local View = Class {}

function View:init(model)
    self:setModel(model)
end

-- For now, each model can only have one view
function View:setModel(model)
    if self.model ~= nil then
        self.model.view = nil
    end
    self.model = model
    if model ~= nil then
        assert(model.view == nil)
        model.view = self
    end
end

function View:getModel()
    return self.model
end

return View
