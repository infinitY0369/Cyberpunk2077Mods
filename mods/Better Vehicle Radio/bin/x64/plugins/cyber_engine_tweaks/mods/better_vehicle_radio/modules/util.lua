local util = {}

---@param loop_count integer
---@return string
function util.set_space(loop_count)
    local str = ""

    if loop_count then
        for _ = 1, loop_count do
            str = ("%s "):format(str)
        end
    end

    return str
end

---@param num number
---@return boolean?
function util.to_bool(num)
    if num == 1 then
        return true
    elseif num == 0 then
        return false
    end
end

---@param bool boolean
---@return integer
function util.to_bit(bool)
    return bool and 1 or 0
end

---@param tbl table
---@param value string
---@return boolean
function util.find_value_in_table(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end

    return false
end

---@param orig table
---@param copies table?
---@return table
function util.deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[util.deepcopy(orig_key, copies)] = util.deepcopy(orig_value, copies)
            end
            setmetatable(copy, util.deepcopy(getmetatable(orig), copies))
        end
    else
        copy = orig
    end
    return copy
end

return util
