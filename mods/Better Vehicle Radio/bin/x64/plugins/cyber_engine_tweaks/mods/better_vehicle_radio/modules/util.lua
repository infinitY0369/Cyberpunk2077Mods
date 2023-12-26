local util = {}

util.is_loading = false

---@param space_count integer
---@return string
function util.set_space(space_count)
    local str = ""

    for _ = 1, space_count do
        str = ("%s "):format(str)
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

---@generic T
---@param str T
---@return T
function util.string_with_quotes(str)
    if type(str) ~= "string" then
        return str
    end

    return ("\"%s\""):format(str)
end

---@param column_values table
---@return string
function util.format_table_values(column_values)
    for i, v in ipairs(column_values) do
        if type(v) == "string" then
            column_values[i] = util.string_with_quotes(v)
        end
    end

    return table.concat(column_values, ", ")
end

---@param file_name string
---@return any
function util.get_file_data(file_name)
    local file, err = io.open(file_name, "r")

    if not file or err then
        return
    end

    local file_data = file:read("*a")
    file:close()

    return file_data
end

---@param message String
function util.show_screen_message(message)
    local simple_screen_message = SimpleScreenMessage.new({
        isShown = true,
        message = message
    })

    local ui_notifications_def  = GetAllBlackboardDefs().UI_Notifications
    Game.GetBlackboardSystem():Get(ui_notifications_def):SetVariant(ui_notifications_def.OnscreenMessage, ToVariant(simple_screen_message), true)
end

---@return boolean
function util.is_in_menu()
    local all_script_definitions = GetAllBlackboardDefs()
    local blackboard_system = Game.GetBlackboardSystem()

    local ui_system_def = all_script_definitions.UI_System
    local is_in_menu = blackboard_system:Get(ui_system_def):GetBool(ui_system_def.IsInMenu)

    if is_in_menu then
        return true
    end

    local photo_mode_def = all_script_definitions.PhotoMode
    local is_active = blackboard_system:Get(photo_mode_def):GetBool(photo_mode_def.IsActive)

    if is_active then
        return true
    end

    if util.is_loading then
        return true
    end

    return false
end

return util
