local radio         = {}

local metadata_json = "data/metadata.json"
local file          = io.open(metadata_json, "r")

radio.metadata      = json.decode(file:read("*a")).radioStations
file:close()

radio.station_order = { 4, 0, 10, 1, 9, 8, 6, 2, 3, 7, 5 }
radio.quest_fact_tracks = { "52893", "52892" }

local function find_station_data_by_name(station_name)
    for _, station_data in ipairs(radio.metadata) do
        if station_data.secondaryKey == station_name.value then
            return station_data
        end
    end
end

---@return CName
function radio.get_current_station_name()
    return Game.GetMountedVehicle(Game.GetPlayer()):GetRadioReceiverStationName()
end

---@return string
function radio.get_current_station_evt()
    local current_station_name = radio.get_current_station_name()

    local current_station_data = find_station_data_by_name(current_station_name)

    if current_station_data then
        return current_station_data.stationEventName
    end
end

function radio.get_station_names()
    local station_data = radio.metadata

    local idx = 0
    return function()
        idx = idx + 1

        if idx <= #station_data then
            return station_data[radio.station_order[idx] + 1].secondaryKey
        end
    end
end

function radio.get_current_station_track_evts()
    local current_station_name = radio.get_current_station_name()

    local current_station_data = find_station_data_by_name(current_station_name)

    if not current_station_data then
        return
    end

    local idx = 0
    return function()
        idx = idx + 1

        local tracks = current_station_data.tracks

        if idx <= #tracks then
            return tracks[idx].primaryKey, tracks[idx].trackEventName
        end
    end
end

---@return CName
function radio.get_current_track_name()
    return Game.GetMountedVehicle(Game.GetPlayer()):GetRadioReceiverTrackName()
end

---@return string
function radio.get_current_track_evt()
    local current_station_name = radio.get_current_station_name()
    local current_track_name   = radio.get_current_track_name()

    local current_station_data = find_station_data_by_name(current_station_name)

    for _, track_data in ipairs(current_station_data.tracks) do
        if tonumber(track_data.primaryKey) == current_track_name.hash_lo then
            return track_data.trackEventName
        end
    end
end

return radio
