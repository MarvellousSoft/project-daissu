--[[
    Validates types according to a schema. Example:
    local schema = {
        a = 'boolean',
        b = 'string',
        c = {'array', {oi = 'number'}}
    }
    validateType(schema, {a = false, b = 'hi', c = {}}) -- True
    validateType(schema, {a = true, c = {{oi = 1}, {oi = 2}}}) -- False, missing b

    To be more precise, an array is a table with only number keys (they are not checked to be continuos), all obeying the same schema.

    schema = {'string', 'number'}

    validateType(schema, {'hi', 12}) -- True
    validateType(schema, {'hi', 12, 12}) -- False, extra table position [3]

    There's no way to specify optional fields, or anything to complex.
]]

local function validateType(schema, data)
    if type(schema) == 'table' then
        if type(data) ~= 'table' then return false end

        if schema[1] == 'array' then -- array type
            for k, v in pairs(data) do
                if type(k) ~= 'number' or not validateType(schema[2], v) then
                    return false
                end
            end
        else
            for k, v in pairs(data) do
                if schema[k] == nil or not validateType(schema[k], v) then
                    return false
                end
            end
            for k, v in pairs(schema) do
                if v ~= 'nil' and data[k] == nil then
                    return false
                end
            end
        end
        return true
    else
        return type(data) == schema
    end
end

return validateType