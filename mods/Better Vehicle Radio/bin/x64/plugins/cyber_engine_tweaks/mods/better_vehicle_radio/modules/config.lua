local _u, util = pcall(require, "modules\\util")

if not _u then
    return
end

local config = {}

---@param table_name string
---@param column_names table
function config.create(table_name, column_names)
    ---@diagnostic disable-next-line: no-unknown, undefined-global
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
    ---@diagnostic disable-next-line: no-unknown, undefined-global
    db:exec(("INSERT INTO %s SELECT %s WHERE NOT EXISTS (SELECT 1 FROM %s WHERE %s = %s)")
        :format(
            table_name,
            util.format_table_values(column_values),
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
---@param boolean? boolean
---@return any
function config.get(table_name, column_name, condition_column, condition_value, boolean)
    ---@diagnostic disable-next-line: no-unknown, undefined-global
    for row in db:rows(("SELECT %s FROM %s WHERE %s = %s"):format(column_name, table_name, condition_column, util.string_with_quotes(condition_value))) do
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
    ---@diagnostic disable-next-line: no-unknown, undefined-global
    db:exec(("UPDATE %s SET %s = %s WHERE %s = %s")
        :format(
            table_name,
            column_name,
            util.string_with_quotes(new_value),
            condition_column,
            util.string_with_quotes(condition_value)
        )
    )
end

return config
