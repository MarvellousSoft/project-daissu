local Class = require "extra_libs.hump.class"

local MapTile = Class {}

function MapTile:__init(obj)
    self.obj = obj
end

return MapTile
