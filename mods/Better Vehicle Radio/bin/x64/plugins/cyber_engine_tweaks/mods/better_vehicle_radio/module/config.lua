local config = {}

---@param str any
---@return any
local function string_with_quotes(str)
    if type(str) == "string" then
        return ("\"%s\""):format(str)
    else
        return str
    end
end

local function format_table_values(column_values)
    for i, v in ipairs(column_values) do
        if type(v) == "string" then
            column_values[i] = string_with_quotes(v)
        end
    end

    return table.concat(column_values, ", ")
end

---@param table_name string
---@param column_names table
function config.create(table_name, column_names)
    db:exec(("CREATE TABLE %s (%s)")
        :format(
            table_name,
            table.concat(column_names, ", ")
        )
    )
end

---@param table_name string
---@param column_names table
---@param column_values table
---@param exist_check_column integer
function config.insert(table_name, column_names, column_values, exist_check_column)
    db:exec(("INSERT INTO %s SELECT %s WHERE NOT EXISTS (SELECT 1 FROM %s WHERE %s = %s)")
        :format(
            table_name,
            format_table_values(column_values),
            table_name,
            column_names[exist_check_column],
            column_values[exist_check_column]
        )
    )
end

---@param table_name string
---@param column_name any
---@param condition_column any
---@param condition_value any
---@param boolean boolean?
---@return any
function config.get(table_name, column_name, condition_column, condition_value, boolean)
    for row in db:rows(("SELECT %s FROM %s WHERE %s = %s"):format(column_name, table_name, condition_column, string_with_quotes(condition_value))) do
        if boolean then
            return row[1] == 1 and true or false
        else
            return row[1]
        end
    end
end

---@param table_name string
---@param column_name any
---@param new_value any
---@param condition_column any
---@param condition_value any
function config.set(table_name, column_name, new_value, condition_column, condition_value)
    db:exec(("UPDATE %s SET %s = %s WHERE %s = %s")
        :format(
            table_name,
            column_name,
            string_with_quotes(new_value),
            condition_column,
            string_with_quotes(condition_value)
        )
    )
end

return config
