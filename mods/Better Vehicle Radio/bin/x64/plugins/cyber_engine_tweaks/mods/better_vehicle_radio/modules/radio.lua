local _u, util = pcall(require, "modules\\util")

if not _u then
    return
end

local radio = {}

radio.is_requested = false
radio.none_track_name = "Gameplay-Devices-Radio-NoneTrack"
radio.police_station_name = "Gameplay-Devices-Radio-PoliceStation"
radio.quest_fact_tracks = { "52893", "52892" }

---@return nil
function radio.init()
    local metadata_path = "data\\metadata.json"
    local raw_json_metadata = util.get_file_data(metadata_path)

    radio.metadata = json.decode(raw_json_metadata).radioStations ---@type table

    if not Game.GetSystemRequestsHandler():IsPreGame() and radio.is_receiver_active() then
        local current_track_name = radio.get_current_track_name()

        if not radio.check_pre_track(current_track_name) then
            return
        end

        radio.set_current_track(current_track_name.hash_lo)
    end
end

---@param hash_lo? integer
function radio.set_current_track(hash_lo)
    if radio.current_track_hash_lo ~= hash_lo then
        radio.current_track_hash_lo = hash_lo
    end

    radio.is_requested = false
end

---@param station_name CName|string
---@return table?
local function find_station_data_by_name(station_name)
    if type(station_name) ~= "string" then
        station_name = station_name.value
    end

    ---@diagnostic disable-next-line: no-unknown
    for _, station_data in ipairs(radio.metadata) do
        if station_data.secondaryKey == station_name then
            return station_data
        end
    end
end

---@return boolean
function radio.is_receiver_active()
    return radio.is_vehicle_receiver_active(true) or radio.is_pocket_receiver_active()
end

---@param ignore_police_station? boolean
---@return boolean
function radio.is_vehicle_receiver_active(ignore_police_station)
    local player = GetPlayer()

    if not player then
        return false
    end

    local player_vehicle = player:GetMountedVehicle()

    if not player_vehicle then
        return false
    end

    if not player_vehicle:IsRadioReceiverActive() then
        return false
    end

    if ignore_police_station and player_vehicle:GetRadioReceiverStationName().value == radio.police_station_name then
        return false
    end

    return true
end

---@return boolean
function radio.is_pocket_receiver_active()
    local player = GetPlayer()

    if not player then
        return false
    end

    return player:GetPocketRadio():IsActive()
end

---@return boolean
function radio.is_in_metro()
    local player = GetPlayer()

    if not player then
        return false
    end

    return player:GetPocketRadio().isInMetro
end

---@return boolean
function radio.is_enable_streamer_mode()
    ---@diagnostic disable-next-line: undefined-field
    return Game.GetSettingsSystem():GetVar("/audio/misc", "StreamerMode"):GetValue()
end

---@return Int32
function radio.get_stations_count()
    return RadioStationDataProvider.GetStationsCount()
end

---@param index Int32
---@return number?
function radio.get_station_index_by_ui_index(index)
    return tonumber(EnumInt(RadioStationDataProvider.GetRadioStationByUIIndex(index)))
end

---@return CName
function radio.get_current_station_name()
    local player = GetPlayer()
    local mounted_vehicle = player:GetMountedVehicle()

    if mounted_vehicle then
        return mounted_vehicle:GetRadioReceiverStationName()
    end

    return player:GetPocketRadio():GetStationName()
end

---@param station_name CName|string
---@return string?
function radio.get_station_evt_by_name(station_name)
    local station_data = find_station_data_by_name(station_name)

    if station_data then
        return station_data.stationEventName
    end
end

---@return nil|fun():string?
function radio.get_station_names()
    local station_data = radio.metadata

    if not station_data then
        return
    end

    local idx = 0
    return function()
        idx = idx + 1

        if idx <= #station_data then
            return station_data[radio.get_station_index_by_ui_index(idx - 1) + 1].secondaryKey
        end
    end
end

---@param station_name CName|string
---@return nil|fun():table?
function radio.get_station_tracks(station_name)
    local station_data = find_station_data_by_name(station_name)

    if not station_data then
        return
    end

    local idx = 0
    return function()
        idx = idx + 1

        local tracks = station_data.tracks ---@type table
        local track_count = #tracks

        if idx <= track_count then
            return tracks[idx]
        end
    end
end

---@param hash_lo number
---@return table?
function radio.get_station_data_by_hash_lo(hash_lo)
    for station_name in radio.get_station_names() do
        local station_data = find_station_data_by_name(station_name)

        if not station_data then
            return
        end

        ---@diagnostic disable-next-line: no-unknown
        for _, track_data in ipairs(station_data.tracks) do
            if track_data.primaryKey == hash_lo then
                return station_data
            end
        end
    end
end

---@return CName
function radio.get_current_track_name()
    local player = GetPlayer()
    local mounted_vehicle = player:GetMountedVehicle()

    if mounted_vehicle then
        return mounted_vehicle:GetRadioReceiverTrackName()
    end

    return player:GetPocketRadio():GetTrackName()
end

---@param hash_lo number
---@param station_name CName|string
---@return string?
function radio.get_track_evt_by_hash_lo(hash_lo, station_name)
    for track_data in radio.get_station_tracks(station_name) do
        if track_data.primaryKey == hash_lo then
            return track_data.trackEventName
        end
    end
end

---@param pre_track_name CName
---@param is_full_check? boolean
---@return boolean
function radio.check_pre_track(pre_track_name, is_full_check)
    if pre_track_name.hash_lo == 0 or pre_track_name.value == radio.none_track_name then
        return false
    end

    if not is_full_check then
        return true
    end

    if pre_track_name.hash_lo == radio.current_track_hash_lo then
        if not radio.is_requested then
            return false
        end
    elseif radio.is_requested then
        return false
    end

    return true
end

---@param loc_station_text? String
---@param loc_track_text? String
function radio.show_screen_notification(loc_station_text, loc_track_text)
    local is_police_station = false

    if not loc_station_text then
        local station_name = radio.get_current_station_name()
        is_police_station = station_name.value == radio.police_station_name
        loc_station_text = GetLocalizedTextByKey(station_name)
    end

    if not loc_track_text then
        local track_name = radio.get_current_track_name()

        if not is_police_station and not radio.check_pre_track(track_name) then
            return
        end

        loc_track_text = not is_police_station and GetLocalizedTextByKey(track_name) or ""
    end

    util.show_screen_message(("%s\n\n%s%s"):format(loc_station_text, util.set_space(8), loc_track_text))
end

---@param radio_ext table
---@return boolean, table?, table?
function radio.is_radio_ext_active(radio_ext)
    if not radio_ext or not radio.is_radio_ext_found then
        return false
    end

    if not radio_ext.radioManager or not radio_ext.radioManager.managerV then
        return false
    end

    ---@type table
    local active_station_data = radio_ext.radioManager.managerV:getActiveStationData()

    if not active_station_data then
        return false
    end

    ---@type table
    local ext_radio = radio_ext.radioManager.managerV:getRadioByName(active_station_data.station)

    if not ext_radio then
        return false
    end

    return true, active_station_data, ext_radio
end

---@param track_text string
---@param path string
---@return string
function radio.normalize_radio_ext_track_text(track_text, path)
    local normalized_track_text = track_text:gsub(("%s\\"):format(path), ""):gsub("%..*", "")

    return normalized_track_text
end

return radio
