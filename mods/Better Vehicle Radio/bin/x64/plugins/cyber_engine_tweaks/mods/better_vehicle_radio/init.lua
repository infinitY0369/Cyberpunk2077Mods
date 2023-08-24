local _, Cron   = pcall(require, "modules\\Cron")
local _, util   = pcall(require, "modules\\util")
local _, config = pcall(require, "modules\\config")
local _, radio  = pcall(require, "modules\\radio")

---@param ... any
local function log(...)
    local args = { ... }
    for i, v in ipairs(args) do
        args[i] = tostring(v)
    end
    print(("[better_vehicle_radio] %s"):format((table.concat(args, " "))))
end

registerForEvent("onInit", function()
    ----------------------------------------------------------------------------------------------------
    -- Native Settings UI
    ----------------------------------------------------------------------------------------------------

    local native_settings = GetMod("nativeSettings")

    if native_settings then
        config.path = "/better_vehicle_radio"

        native_settings.addTab(     -- Add a tab
            config.path,            -- path
            "Better Vehicle Radio", -- label
            function()              -- callback
                config.controller_input = false
            end
        )

        config.common = {
            path                     = "/common",

            table                    = "COMMON",
            column                   = { key = "key", value = "value" },
            input                    = { key = "input", default_value = "IK_C" },
            default_station          = { key = "default_station", default_value = 1 },
            onscreen_message         = { key = "onscreen_message", default_value = true },
            fix_vanilla_radio_notice = { key = "fix_vanilla_radio_notice", default_value = true },

            station_option_list      = { GetLocalizedText("UI-Sorting-Default"), GetLocalizedText("Gameplay-Devices-Radio-NoneStation") }
        }

        function config.common.generate()
            config.create(config.common.table, { config.common.column.key, config.common.column.value })

            local sub_path = ("%s%s"):format(config.path, config.common.path)
            native_settings.addSubcategory(                  -- Add a subcategory
                sub_path,                                    -- path
                GetLocalizedText("UI-Settings-GenaralInput") -- label
            )

            config.insert(
                config.common.table,
                { config.common.column.key, config.common.value },
                { config.common.input.key, config.common.input.default_value },
                1
            )
            local selected_key = config.get(
                config.common.table,
                config.common.column.value,
                config.common.column.key,
                config.common.input.key
            )
            native_settings.addKeyBinding(                                                                                 -- Add a keybind
                sub_path,                                                                                                  -- path
                GetLocalizedText("LocKey#27571"),                                                                          -- label
                ("%s%s"):format(GetLocalizedText("UI-Settings-Bind"), GetLocalizedText("UI-Settings-ConfirmationNeeded")), -- desc
                selected_key or config.common.input.default_value,                                                         -- currentKey
                config.common.input.default_value,                                                                         -- defaultKey
                false,                                                                                                     -- isHold
                function(key)                                                                                              -- callback
                    config.set(
                        config.common.table,
                        config.common.column.value,
                        key,
                        config.common.column.key,
                        config.common.input.key
                    )
                end
            )

            for station_name in radio.get_station_names() do
                table.insert(config.common.station_option_list, GetLocalizedText(station_name))
            end

            config.insert(
                config.common.table,
                { config.common.column.key, config.common.value },
                { config.common.default_station.key, config.common.default_station.default_value },
                1
            )
            local selected_station_idx = config.get(
                config.common.table,
                config.common.column.value,
                config.common.column.key,
                config.common.default_station.key
            )
            native_settings.addSelectorString(                                       -- Add a list of strings
                sub_path,                                                            -- path
                GetLocalizedText("Gameplay-Devices-DisplayNames-Radio"),             -- label
                "",                                                                  -- desc
                config.common.station_option_list,                                   -- elements
                selected_station_idx or config.common.default_station.default_value, -- currentValue
                config.common.default_station.default_value,                         -- defaultValue
                function(value)                                                      -- callback
                    config.set(
                        config.common.table,
                        config.common.column.value,
                        value,
                        config.common.column.key,
                        config.common.default_station.key
                    )
                end
            )

            config.insert(
                config.common.table,
                { config.common.column.key, config.common.value },
                { config.common.onscreen_message.key, util.to_bit(config.common.onscreen_message.default_value) },
                1
            )
            local onscreen_message_state = config.get(
                config.common.table,
                config.common.column.value,
                config.common.column.key,
                config.common.onscreen_message.key,
                true
            )
            native_settings.addSwitch(                                                  -- Add a switch
                sub_path,                                                               -- path
                "Onscreen Message",                                                     -- label
                "",                                                                     -- desc
                onscreen_message_state or config.common.onscreen_message.default_value, -- currentValue
                config.common.onscreen_message.default_value,                           -- defaultValue
                function(state)                                                         -- callback
                    config.set(
                        config.common.table,
                        config.common.column.value,
                        util.to_bit(state),
                        config.common.column.key,
                        config.common.onscreen_message.key
                    )
                end
            )

            config.insert(
                config.common.table,
                { config.common.column.key, config.common.value },
                { config.common.fix_vanilla_radio_notice.key, util.to_bit(config.common.fix_vanilla_radio_notice.default_value) },
                1
            )
            local fix_vanilla_radio_notice_state = config.get(
                config.common.table,
                config.common.column.value,
                config.common.column.key,
                config.common.fix_vanilla_radio_notice.key,
                true
            )
            native_settings.addSwitch(                                                                  -- Add a switch
                sub_path,                                                                               -- path
                "Fix Vanilla Radio Notice",                                                             -- label
                "",                                                                                     -- desc
                fix_vanilla_radio_notice_state or config.common.fix_vanilla_radio_notice.default_value, -- currentValue
                config.common.fix_vanilla_radio_notice.default_value,                                   -- defaultValue
                function(state)                                                                         -- callback
                    config.set(
                        config.common.table,
                        config.common.column.value,
                        util.to_bit(state),
                        config.common.column.key,
                        config.common.fix_vanilla_radio_notice.key
                    )
                end
            )
        end

        config.track = {
            path                       = {},

            table                      = "TRACK",
            column                     = { key = "sound_event", value = "value" },

            station_filter_option_list = { GetLocalizedText("UI-Menus-WorldMap-Filter-All") },
            filter_idx                 = 1,
            current_station_state      = {}
        }

        function config.track.generate(init)
            for _, station_idx in ipairs(radio.station_order) do
                local tbl_idx = station_idx + 1

                local station_data = radio.metadata[tbl_idx]

                local is_filter_all = config.track.filter_idx == 1
                local is_filter_station_idx = station_idx == radio.station_order[config.track.filter_idx - 1]

                config.track.path.station = ("%s/%s"):format(config.path, station_data.stationEventName)

                local station_localized_text = GetLocalizedText(station_data.secondaryKey)

                if init then
                    table.insert(config.track.station_filter_option_list, station_localized_text)
                    config.create(config.track.table, { config.track.column.key, config.track.column.value })
                end

                if is_filter_all or config.track.current_station_state[tbl_idx] then
                    native_settings.removeSubcategory(config.track.path.station)
                    config.track.current_station_state[tbl_idx] = false
                end

                if is_filter_all or is_filter_station_idx then
                    if not config.track.current_station_state[tbl_idx] then
                        native_settings.addSubcategory( -- Add a subcategory
                            config.track.path.station,  -- path
                            station_localized_text      -- label
                        )

                        config.track.current_station_state[tbl_idx] = true
                    end
                else
                    native_settings.removeSubcategory(config.track.path.station)
                    config.track.current_station_state[tbl_idx] = false
                end

                for _, track_data in ipairs(station_data.tracks) do
                    if is_filter_all or is_filter_station_idx then
                        if init then
                            config.insert(
                                config.track.table,
                                { config.track.column.key, config.track.column.value },
                                { track_data.trackEventName, 1 },
                                1
                            )
                        end

                        native_settings.addSwitch(                                                                                               -- Add a switch
                            config.track.path.station,                                                                                           -- path
                            GetLocalizedText(track_data.secondaryKey),                                                                           -- label
                            "",                                                                                                                  -- desc
                            config.get(config.track.table, config.track.column.value, config.track.column.key, track_data.trackEventName, true), -- currentValue
                            true,                                                                                                                -- defaultValue
                            function(state)                                                                                                      -- callback
                                config.set(config.track.table, config.track.column.value, util.to_bit(state), config.track.column.key, track_data.trackEventName)
                            end
                        )
                    end
                end
            end
        end

        config.common.generate()
        config.track.generate(true)
        native_settings.addSelectorString( -- Add a list of strings
            config.path,                   -- path
            ("%s%s %s"):format(
                GetLocalizedText("LocKey#22270"),
                GetLocalizedText("Common-Characters-Semicolon"),
                GetLocalizedText("Gameplay-Devices-DisplayNames-Radio")
            ),                                       -- label
            "",                                      -- desc
            config.track.station_filter_option_list, -- elements
            1,                                       -- currentValue
            1,                                       -- defaultValue
            function(value)                          -- callback
                config.track.filter_idx = value
                config.track.generate(false)
            end
        )
    else
        log("Native Settings UI is not installed.")
        return
    end

    if not Codeware then
        log("Codeware is not installed.")
        return
    end

    ----------------------------------------------------------------------------------------------------
    -- RadioExt
    ----------------------------------------------------------------------------------------------------

    local radioExt = GetMod("radioExt")

    ----------------------------------------------------------------------------------------------------
    -- util
    ----------------------------------------------------------------------------------------------------

    if not Game.GetSystemRequestsHandler():IsPreGame() then
        local mounted_vehicle = Game.GetMountedVehicle(Game.GetPlayer())

        if mounted_vehicle then
            radio.isMounting = true

            if mounted_vehicle:IsRadioReceiverActive() then
                radio.current_track_evt = radio.get_current_track_evt()
            end

            if not IsDefined(VehicleSummonWidgetGameController.playerVehicle) then
                VehicleSummonWidgetGameController.playerVehicle = mounted_vehicle
            end
        else
            radio.isMounting = false
        end
    end

    function radio.set_default_station(vehicle_base_object)
        local selected_station_idx = config.get(
            config.common.table,
            config.common.column.value,
            config.common.column.key,
            config.common.default_station.key
        ) or config.common.default_station.default_value

        if selected_station_idx == 1 then
            return
        elseif selected_station_idx == 2 then
            vehicle_base_object:ToggleRadioReceiver(false)
        else
            vehicle_base_object:SetRadioReceiverStation(radio.station_order[selected_station_idx - 2])
        end
    end

    local function set_onscreen_message(msg, no_evt)
        if config.get(config.common.table, config.common.column.value, config.common.column.key, config.common.onscreen_message.key, true) then
            local simple_screen_message     = SimpleScreenMessage.new()
            simple_screen_message.isShown   = true
            simple_screen_message.duration  = 5.0
            simple_screen_message.message   = msg
            simple_screen_message.isInstant = true
            Game.GetBlackboardSystem()
                    :Get(Game.GetAllBlackboardDefs().UI_Notifications)
                    :SetVariant(Game.GetAllBlackboardDefs().UI_Notifications.OnscreenMessage, ToVariant(simple_screen_message), true)
        end

        if not no_evt and config.get(config.common.table, config.common.column.value, config.common.column.key, config.common.fix_vanilla_radio_notice.key, true) then
            ScriptGameInstance.GetUISystem():QueueEvent(UIVehicleRadioEvent.new())
        end
    end

    local function display_radio_notice(station_name, track_name, no_evt)
        local loc_station_name = station_name or GetLocalizedTextByKey(radio.get_current_station_name())
        local loc_track_name   = track_name or GetLocalizedTextByKey(radio.get_current_track_name())

        set_onscreen_message(("%s\n\n%s%s"):format(loc_station_name, util.set_space(8), loc_track_name), no_evt)
    end

    function radio.skip(force)
        if radioExt and RadioExt then
            local station_name = Game.GetMountedVehicle(Game.GetPlayer()):GetBlackboard():GetName(GetAllBlackboardDefs().Vehicle.VehRadioStationName)
            local ext_radio = radioExt.radioManager.managerV:getRadioByName(station_name.value)

            if ext_radio then
                ext_radio:currentSongDone()
                ext_radio.currentSong = ext_radio.songs[Game.RandRange(1, #ext_radio.songs + 1)]
                ext_radio:startNewSong()

                radioExt.observersV.customNotif = {
                    name = ext_radio.name,
                    path = ext_radio.currentSong.path
                }

                local ext_station_name          = ext_radio.name
                local ext_track_name            = ext_radio.currentSong.path:gsub(("%s\\"):format(ext_radio.path), ""):gsub("%..*", "")

                radio.current_track_evt         = ext_radio.currentSong.path

                display_radio_notice(ext_station_name, ext_track_name)

                return true
            end
        end

        local current_track_evt = radio.get_current_track_evt()
        if not force and config.get(config.track.table, config.track.column.value, config.track.column.key, current_track_evt, true) then
            radio.current_track_evt = current_track_evt
            return false
        end

        local available_tracks   = {}
        local unavailable_tracks = {}

        for primary_key, track_evt in radio.get_current_station_track_evts() do
            if radio.sq017_enable_kerry_usc_radio_songs or not util.find_value_in_table(radio.quest_fact_tracks, primary_key) then
                if config.get(config.track.table, config.track.column.value, config.track.column.key, track_evt, true) then
                    table.insert(available_tracks, track_evt)
                else
                    table.insert(unavailable_tracks, track_evt)
                end
            end
        end

        if not force and #available_tracks == 0 then
            return false
        end

        local next_radio_track
        local final_track_list = {}
        if #available_tracks >= 2 then -- If two or more are valid
            for _, track_evt in ipairs(available_tracks) do
                if track_evt ~= radio.current_track_evt then
                    table.insert(final_track_list, track_evt)
                end
            end
        elseif #available_tracks == 1 then           -- If only one is valid
            final_track_list = available_tracks
        elseif force and #available_tracks == 0 then -- If all are invalid
            for _, track_evt in ipairs(unavailable_tracks) do
                if track_evt ~= radio.current_track_evt then
                    table.insert(final_track_list, track_evt)
                end
            end
        end

        local range_max = #final_track_list + 1

        if range_max <= 1 then
            log("The thread tried to divide an integer value by an integer divisor of zero.")

            return true
        end

        next_radio_track = final_track_list[Game.RandRange(1, range_max)]

        Cron.NextTick(function()
                          Game.GetAudioSystem():RequestSongOnRadioStation(radio.get_current_station_evt(), next_radio_track)
                      end,
                      nil)

        radio.current_track_evt = next_radio_track

        return #available_tracks == 1 and false or true
    end

    config.key_input_event = NewProxy(
        {
            KeyInputEvent = {
                args = { "whandle:KeyInputEvent" },
                callback = function(evt)
                    local key = evt:GetKey()
                    local action = evt:GetAction()

                    if config.controller_input then
                        if config.listening_keybind_widget and action == EInputAction.IACT_Release then
                            config.listening_keybind_widget:OnKeyBindingEvent(inkKeyBindingEvent.new({ keyName = key.value }))
                            config.listening_keybind_widget = nil
                        end
                    end

                    if action == EInputAction.IACT_Press then
                        if key.value == config.get(config.common.table, config.common.column.value, config.common.column.key, config.common.input.key) then
                            radio.skip(true)
                        end
                    end
                end
            }
        }
    )

    Game.GetCallbackSystem():RegisterCallback("Input/Key", config.key_input_event:Target(), config.key_input_event:Function("KeyInputEvent"), true)

    ----------------------------------------------------------------------------------------------------
    -- VehicleComponent
    ----------------------------------------------------------------------------------------------------

    ---@param self VehicleComponent
    ---@param evt VehicleRadioSongChanged
    ObserveBefore("VehicleComponent", "OnVehicleRadioSongChanged", function(self, evt)
        if radio.isMounting and self.mounted and evt.radioSongName.hash_lo ~= 0 and radio.get_current_track_name() then
            if radio.skip() then
                return
            end

            display_radio_notice()
        end
    end)

    ---@param self VehicleComponent
    ---@param evt VehicleRadioStationChanged
    ObserveAfter("VehicleComponent", "OnVehicleRadioStationChanged", function(self, evt)
        if radio.isMounting and evt.isActive and self.mounted and evt.radioSongName.hash_lo ~= 0 then
            if radio.skip() then
                return
            end

            if not self.radioState then
                return
            end

            Cron.NextTick(function()
                              display_radio_notice()
                          end,
                          nil)
        end
    end)

    ---@param self VehicleRadioPopupGameController
    ObserveAfter("VehicleRadioPopupGameController", "Activate", function(self)
        local ext_station_name = self.selectedItem:GetStationData().record:DisplayName()
        local ext_radio = radioExt.radioManager.managerV:getRadioByName(ext_station_name)
        if ext_radio then
            radioExt.observersV.customNotif = {
                name = ext_radio.name,
                path = ext_radio.currentSong.path
            }

            display_radio_notice(ext_radio.name, ext_radio.currentSong.path:gsub(("%s\\"):format(ext_radio.path), ""):gsub("%..*", ""))
        end
    end)

    ---@param self VehicleComponent
    ---@param evt VehicleRadioEvent
    ObserveBefore("VehicleComponent", "OnVehicleRadioEvent", function(self, evt)
        if evt.toggle and not evt.setStation then
            Cron.After(0.2,
                       function()
                           local station_name = Game.GetMountedVehicle(Game.GetPlayer()):GetBlackboard():GetName(GetAllBlackboardDefs().Vehicle.VehRadioStationName)
                           local ext_radio = radioExt.radioManager.managerV:getRadioByName(station_name.value)
                           if ext_radio then
                               display_radio_notice(ext_radio.name, ext_radio.currentSong.path:gsub(("%s\\"):format(ext_radio.path), ""):gsub("%..*", ""), true)
                           end
                       end,
                       nil)
        end
    end)

    ---@param self VehicleComponent
    ---@param evt MountingEvent
    ObserveBefore("VehicleComponent", "OnMountingEvent", function(self, evt)
        if not self.mounted and not evt.request.mountData.isInstant and self:GetVehicle():IsRadioReceiverActive() then
            radio.isMounting = true

            if radio.skip() then
                return
            end

            display_radio_notice()
        end
    end)

    ---@param self VehicleComponent
    ---@param evt UnmountingEvent
    ObserveBefore("VehicleComponent", "OnUnmountingEvent", function(self, evt)
        if not evt.request.mountData then
            radio.isMounting = false
        end
    end)

    ---@param self VehicleComponent
    ---@param evt VehicleFinishedMountingEvent
    ObserveBefore("VehicleComponent", "OnVehicleFinishedMountingEvent", function(self, evt)
        if not radio.isMounting and evt.isMounting then
            radio.isMounting = true
        end
    end)

    ---@param self VehicleComponent
    ---@param evt VehicleRadioStationInitialized
    ObserveBefore("VehicleComponent", "OnVehicleRadioStationInitialized", function(self, evt)
        radio.set_default_station(self:GetVehicle())
    end)

    ----------------------------------------------------------------------------------------------------
    -- VehicleSummonWidgetGameController
    ----------------------------------------------------------------------------------------------------

    ---@param self VehicleSummonWidgetGameController
    ---@param playerPuppet GameObject
    ObserveBefore("VehicleSummonWidgetGameController", "OnPlayerAttach", function(self, playerPuppet)
        if not IsDefined(self.playerVehicle) then
            self.playerVehicle = Game.GetMountedVehicle(playerPuppet)
        end
    end)

    ---@param self VehicleSummonWidgetGameController
    ---@param value Uint32
    ObserveBefore("VehicleSummonWidgetGameController", "OnVehicleSummonStateChanged", function(self, value)
        if value == EnumInt(vehicleSummonState.Arrived) then
            radio.set_default_station(self.vehicle)
        end
    end)

    ----------------------------------------------------------------------------------------------------
    -- PlayerPuppet
    ----------------------------------------------------------------------------------------------------

    ---@param self PlayerPuppet
    ObserveBefore("PlayerPuppet", "OnGameAttached", function(self)
        radio.isMounting = false
        radio.sq017_enable_kerry_usc_radio_songs = util.to_bool(ScriptGameInstance.GetQuestsSystem():GetFact("sq017_enable_kerry_usc_radio_songs"))
    end)

    ----------------------------------------------------------------------------------------------------
    -- SettingsSelectorControllerKeyBinding
    ----------------------------------------------------------------------------------------------------

    ---@param self SettingsSelectorControllerKeyBinding
    ObserveBefore("SettingsSelectorControllerKeyBinding", "ListenForInput", function(self)
        config.listening_keybind_widget = self
    end)

    ----------------------------------------------------------------------------------------------------
    -- SettingsMainGameController
    ----------------------------------------------------------------------------------------------------

    ---@param self SettingsMainGameController
    ---@param idx Int32
    ObserveBefore("SettingsMainGameController", "PopulateCategorySettingsOptions", function(self, idx)
        if self.data[idx + 1].groupPath.value == config.path then
            config.controller_input = true
        end
    end)
end)

---@param delta number
registerForEvent("onUpdate", function(delta)
    Cron.Update(delta)
end)
