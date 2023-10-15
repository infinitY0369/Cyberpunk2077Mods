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

return util
