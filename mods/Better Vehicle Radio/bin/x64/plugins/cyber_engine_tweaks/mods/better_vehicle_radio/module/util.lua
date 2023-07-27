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

---@param tbl table
---@param value string
---@return boolean
function util.has_value_in_table(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end

    return false
end

---@param tbl table
function util.sort_table_by_value_order(tbl)
    local keys = {}
    for key, value in pairs(tbl) do
        if type(value) == "number" then
            table.insert(keys, key)
        end
    end

    table.sort(keys, function(a, b) return tbl[a] < tbl[b] end)

    local i = 0
    return function()
        i = i + 1

        if i <= #keys then
            local key = keys[i]
            return i, key, tbl[key]
        end
    end
end

---@param tbl table
---@param idx table
function util.sort_table_by_index(tbl, idx)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys, function(a, b) return tbl[a].index < tbl[b].index end)

    local i = 0
    return function()
        i = i + 1

        if i <= #keys then
            local key = keys[idx[i] + 1]
            return i, key, tbl[key]
        end
    end
end

return util
