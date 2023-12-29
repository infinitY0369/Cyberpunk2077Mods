local _c, config = pcall(require, "modules\\config")
local _r, radio  = pcall(require, "modules\\radio")
local _u, util   = pcall(require, "modules\\util")

registerForEvent("onInit", function()
    if not _c or not _r or not _u then
        return
    end

    local native_settings = GetMod("nativeSettings")
    radio.ext = GetMod("radioExt")

    local is_codeware_found = type(Codeware) == "userdata"
    radio.is_radio_ext_found = radio.ext and type(RadioExt) == "userdata"

    if not is_codeware_found or not native_settings then
        return
    end

    radio.init()

    if native_settings then
        config.path = "/better_vehicle_radio"

        native_settings.addTab(     -- Add a tab
            config.path,            -- path
            "Better Vehicle Radio", -- label
            function()              -- callback
                config.controller_input = false

                if radio.is_receiver_active() then
                    radio.skip(false)
                elseif radio.current_track_hash_lo then
                    local current_station_data = radio.get_station_data_by_hash_lo(radio.current_track_hash_lo)

                    if not current_station_data then
                        return
                    end

                    local is_current_track_available = false
                    local available_track_count = 0

                    for _, track_data in ipairs(current_station_data.tracks) do
                        local track_evt = track_data.trackEventName

                        if config.get(config.track.table, config.track.column.value, config.track.column.key, track_evt, true) then
                            available_track_count = available_track_count + 1

                            if track_data.primaryKey == radio.current_track_hash_lo then
                                is_current_track_available = true
                            end
                        end
                    end

                    if is_current_track_available or available_track_count == 0 then
                        return
                    end

                    radio.set_current_track()
                end
            end
        )

        config.common = {
            path             = "/common",

            table            = "COMMON",
            column           = {key = "key", value = "value"},
            veh_input        = {key = "veh_input", default_value = EInputKey.IK_F1.value},
            port_input       = {key = "port_input", default_value = EInputKey.IK_F1.value},
            info_popup       = {key = "info_popup", default_value = false},
            onscreen_message = {key = "onscreen_message", default_value = false}
        }

        function config.common.generate()
            config.create(config.common.table, {config.common.column.key, config.common.column.value})

            local sub_path = ("%s%s"):format(config.path, config.common.path)
            native_settings.addSubcategory(                  -- Add a subcategory
                sub_path,                                    -- path
                GetLocalizedText("UI-Settings-GenaralInput") -- label
            )

            config.insert(
                config.common.table,
                {config.common.column.key, config.common.value},
                {config.common.veh_input.key, config.common.veh_input.default_value},
                1
            )
            local selected_veh_input_key = config.get(
                config.common.table,
                config.common.column.value,
                config.common.column.key,
                config.common.veh_input.key
            )
            native_settings.addKeyBinding(                                                                                 -- Add a keybind
                sub_path,                                                                                                  -- path
                ("%s (Vehicle)"):format(GetLocalizedText("LocKey#27571")),                                                 -- label
                ("%s%s"):format(GetLocalizedText("UI-Settings-Bind"), GetLocalizedText("UI-Settings-ConfirmationNeeded")), -- desc
                selected_veh_input_key or config.common.veh_input.default_value,                                           -- currentKey
                config.common.veh_input.default_value,                                                                     -- defaultKey
                false,                                                                                                     -- isHold
                function(key)                                                                                              -- callback
                    config.set(
                        config.common.table,
                        config.common.column.value,
                        key,
                        config.common.column.key,
                        config.common.veh_input.key
                    )
                end
            )

            config.insert(
                config.common.table,
                {config.common.column.key, config.common.value},
                {config.common.port_input.key, config.common.port_input.default_value},
                1
            )
            local selected_port_input_key = config.get(
                config.common.table,
                config.common.column.value,
                config.common.column.key,
                config.common.port_input.key
            )
            native_settings.addKeyBinding(                                                                                 -- Add a keybind
                sub_path,                                                                                                  -- path
                ("%s (Radioport)"):format(GetLocalizedText("LocKey#27571")),                                               -- label
                ("%s%s"):format(GetLocalizedText("UI-Settings-Bind"), GetLocalizedText("UI-Settings-ConfirmationNeeded")), -- desc
                selected_port_input_key or config.common.port_input.default_value,                                         -- currentKey
                config.common.port_input.default_value,                                                                    -- defaultKey
                false,                                                                                                     -- isHold
                function(key)                                                                                              -- callback
                    config.set(
                        config.common.table,
                        config.common.column.value,
                        key,
                        config.common.column.key,
                        config.common.port_input.key
                    )
                end
            )

            config.insert(
                config.common.table,
                {config.common.column.key, config.common.value},
                {config.common.info_popup.key, util.to_bit(config.common.info_popup.default_value)},
                1
            )
            local info_popup_state = config.get(
                config.common.table,
                config.common.column.value,
                config.common.column.key,
                config.common.info_popup.key,
                true
            )
            native_settings.addSwitch(                                                                       -- Add a switch
                sub_path,                                                                                    -- path
                "Display Notification on Radioport",                                                         -- label
                "Displays default song change notification on the Radioport, similar to the vehicle radio.", -- desc
                info_popup_state or config.common.info_popup.default_value,                                  -- currentValue
                config.common.info_popup.default_value,                                                      -- defaultValue
                function(state)                                                                              -- callback
                    config.set(
                        config.common.table,
                        config.common.column.value,
                        util.to_bit(state),
                        config.common.column.key,
                        config.common.info_popup.key
                    )
                end
            )

            config.insert(
                config.common.table,
                {config.common.column.key, config.common.value},
                {config.common.onscreen_message.key, util.to_bit(config.common.onscreen_message.default_value)},
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
                "Display Alternate Notification",                                       -- label
                "Display the song change notification on the left side of the screen.", -- desc
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
        end

        config.track = {
            path                       = {},

            table                      = "TRACK",
            column                     = {key = "sound_event", value = "value"},

            station_filter_option_list = {GetLocalizedText("UI-Menus-WorldMap-Filter-All")},
            filter_idx                 = 1,
            current_station_state      = {}
        }

        function config.track.generate(init)
            for idx = 1, radio.get_stations_count() do
                local station_index = radio.get_station_index_by_ui_index(idx - 1)
                local metadata = radio.metadata[station_index + 1]

                local is_filter_all = config.track.filter_idx == 1
                local is_filter_station = idx == config.track.filter_idx - 1

                config.track.path.station = ("%s/%s"):format(config.path, metadata.stationEventName)

                local station_localized_text = GetLocalizedText(metadata.secondaryKey)

                if init then
                    table.insert(config.track.station_filter_option_list, station_localized_text)
                    config.create(config.track.table, {config.track.column.key, config.track.column.value})
                end

                if is_filter_all or config.track.current_station_state[idx] then
                    native_settings.removeSubcategory(config.track.path.station)
                    config.track.current_station_state[idx] = false
                end

                if is_filter_all or is_filter_station then
                    if not config.track.current_station_state[idx] then
                        native_settings.addSubcategory( -- Add a subcategory
                            config.track.path.station,  -- path
                            station_localized_text      -- label
                        )

                        config.track.current_station_state[idx] = true
                    end
                else
                    native_settings.removeSubcategory(config.track.path.station)
                    config.track.current_station_state[idx] = false
                end

                for _, track_data in ipairs(metadata.tracks) do
                    if is_filter_all or is_filter_station then
                        if init then
                            config.insert(config.track.table,
                                          {config.track.column.key, config.track.column.value},
                                          {track_data.trackEventName, 1},
                                          1)
                        end

                        local desc = track_data.isStreamingFriendly == 0 and "This song is copyrighted." or ""

                        native_settings.addSwitch(                       -- Add a switch
                            config.track.path.station,                   -- path
                            GetLocalizedText(track_data.secondaryKey),   -- label
                            desc,                                        -- desc
                            config.get(config.track.table, config.track.column.value, config.track.column.key,
                                       track_data.trackEventName, true), -- currentValue
                            true,                                        -- defaultValue
                            function(state)                              -- callback
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
    end

    local function process_radio_ext(is_user_input)
        local is_radio_ext_active, active_station_data, radio_ext = radio.is_radio_ext_active(radio.ext)

        if not is_radio_ext_active or not active_station_data or not radio_ext then
            return false
        end

        if is_user_input then
            local song_count = #radio_ext.songs

            if song_count <= 1 then
                return true
            end

            local current_track_index = -1

            for idx, song_data in ipairs(radio_ext.songs) do
                if song_data.path == radio.current_track_hash_lo then
                    current_track_index = idx

                    break
                end
            end

            radio_ext:currentSongDone()

            radio_ext.currentSong = radio_ext.songs[RandDifferent(current_track_index - 1, song_count) + 1]
            radio_ext.tick = 0

            radio_ext:startNewSong()

            local station_text = active_station_data.station
            local track_text = radio.normalize_radio_ext_track_text(active_station_data.track, radio_ext.path)

            radio.show_screen_notification(station_text, track_text)
        end

        radio.set_current_track(radio_ext.currentSong.path)

        return true
    end

    function radio.skip(is_user_input)
        if radio.is_radio_ext_found then
            if process_radio_ext(is_user_input) then
                return
            end
        end

        local pre_track_name = radio.get_current_track_name()

        if pre_track_name.hash_lo == 0 or pre_track_name.value == radio.none_track_name then
            return
        end

        local current_station_name = radio.get_current_station_name()

        local pre_track_evt = radio.get_track_evt_by_hash_lo(pre_track_name.hash_lo, current_station_name)

        if not pre_track_evt then
            return
        end

        local is_track_available = config.get(config.track.table, config.track.column.value, config.track.column.key, pre_track_evt, true)

        if not is_user_input and is_track_available then
            radio.set_current_track(pre_track_name.hash_lo)

            return
        end

        local available_tracks           = {}
        local unavailable_tracks         = {}

        local is_enable_streamer_mode    = radio.is_enable_streamer_mode()
        local is_in_metro                = radio.is_in_metro()
        local is_enable_quest_fact       = Game.GetQuestsSystem():GetFact("sq017_enable_kerry_usc_radio_songs") == 1

        local is_current_track_available = false
        local current_track_evt

        for track_data in radio.get_station_tracks(current_station_name) do
            local is_streaming_friendly = true

            -- I don't know if this is a bug or a feature, but it seems that copyrighted songs cannot be played on the NCART.
            if is_enable_streamer_mode or is_in_metro then
                if track_data.isStreamingFriendly == 0 then
                    is_streaming_friendly = false
                end
            end

            local track_hash_lo = track_data.primaryKey
            local track_evt = track_data.trackEventName

            if is_streaming_friendly and (is_enable_quest_fact or not util.find_value_in_table(radio.quest_fact_tracks, track_hash_lo)) then
                if track_hash_lo ~= radio.current_track_hash_lo then
                    if config.get(config.track.table, config.track.column.value, config.track.column.key, track_evt, true) then
                        table.insert(available_tracks, {track_hash_lo, track_evt})
                    else
                        table.insert(unavailable_tracks, {track_hash_lo, track_evt})
                    end
                else
                    if config.get(config.track.table, config.track.column.value, config.track.column.key, track_evt, true) then
                        is_current_track_available = true
                    end

                    current_track_evt = track_evt
                end
            end
        end

        local available_track_count = #available_tracks
        local final_tracks = {}

        if available_track_count >= 2 then
            final_tracks = available_tracks
        elseif available_track_count == 1 then
            local is_same_track = available_tracks[1][1] == radio.current_track_hash_lo

            if is_same_track then
                if is_user_input then
                    radio.set_current_track(pre_track_name.hash_lo)

                    return
                end

                table.insert(final_tracks, {radio.current_track_hash_lo, current_track_evt})
            else
                final_tracks = available_tracks
            end
        elseif available_track_count == 0 then
            if is_user_input == is_current_track_available then
                radio.set_current_track(pre_track_name.hash_lo)

                return
            end

            if is_user_input and not is_current_track_available then
                final_tracks = unavailable_tracks
            elseif not is_user_input and is_current_track_available then
                table.insert(final_tracks, {radio.current_track_hash_lo, current_track_evt})
            end
        end

        local range_max = #final_tracks + 1

        if range_max <= 1 then
            return
        end

        local next_radio_track_data = final_tracks[RandRange(1, range_max)]

        if not next_radio_track_data then
            return
        end

        local current_station_evt = radio.get_station_evt_by_name(current_station_name)

        if not current_station_evt then
            return
        end

        Game.GetAudioSystem():RequestSongOnRadioStation(current_station_evt, next_radio_track_data[2])

        radio.set_current_track(next_radio_track_data[1])

        local post_track_name = radio.get_current_track_name()

        if post_track_name.hash_lo ~= next_radio_track_data[1] then
            radio.is_requested = true

            return
        end
    end

    config.key_input_event = NewProxy(
        {
            OnKeyInput = {
                args = {"whandle:KeyInputEvent"},
                ---@param evt KeyInputEvent
                callback = function(evt)
                    local key = evt:GetKey()
                    local action = evt:GetAction()

                    if config.controller_input then
                        if config.listening_keybind_widget and action == EInputAction.IACT_Release then
                            config.listening_keybind_widget:OnKeyBindingEvent(inkKeyBindingEvent.new({keyName = key.value}))
                            config.listening_keybind_widget = nil
                        end
                    end

                    if action ~= EInputAction.IACT_Press then
                        return
                    end

                    local input_key

                    if GetPlayer().mountedVehicle and not radio.is_in_metro() then
                        input_key = config.get(config.common.table, config.common.column.value, config.common.column.key, config.common.veh_input.key)
                    else
                        input_key = config.get(config.common.table, config.common.column.value, config.common.column.key, config.common.port_input.key)
                    end

                    if key.value ~= input_key then
                        return
                    end

                    if not radio.is_receiver_active() or util.is_in_menu() then
                        return
                    end

                    radio.skip(true)
                end
            }
        }
    )

    Game.GetCallbackSystem():RegisterCallback("Input/Key", config.key_input_event:Target(), config.key_input_event:Function("OnKeyInput"), true)

    ---@param evt VehicleRadioSongChanged
    ObserveBefore("VehicleSummonWidgetGameController", "OnVehicleRadioSongChanged", function(self, evt)
        if not radio.check_pre_track(evt.radioSongName, true) and not radio.is_radio_ext_active(radio.ext) then
            return
        end

        radio.skip(false)
    end)

    ObserveBefore("VehicleSummonWidgetGameController", "TryShowVehicleRadioNotification", function(self)
        local is_radio_ext_active, active_station_data, radio_ext = radio.is_radio_ext_active(radio.ext)

        if not is_radio_ext_active then
            local is_show_popup = config.get(config.common.table, config.common.column.value, config.common.column.key, config.common.info_popup.key, true)

            if is_show_popup and radio.is_pocket_receiver_active() and not GetPlayer().mountedVehicle then
                self.rootWidget:SetVisible(true)
                inkWidgetRef.SetVisible(self.subText, true)
                inkWidgetRef.SetVisible(self.radioStationName, true)
                local station = GetLocalizedTextByKey(radio.get_current_station_name())
                local song = GetLocalizedTextByKey(radio.get_current_track_name())
                inkTextRef.SetText(self.radioStationName, station)
                inkTextRef.SetText(self.subText, song)
                self:PlayAnimation("OnSongChanged", inkAnimOptions.new(), "OnTimeOut")
            end
        end

        local is_show_onscreen = config.get(config.common.table, config.common.column.value, config.common.column.key, config.common.onscreen_message.key, true)

        if not is_show_onscreen then
            return
        end

        if is_radio_ext_active then
            if not active_station_data or not radio_ext then
                return
            end

            local station_text = active_station_data.station
            local track_text = radio.normalize_radio_ext_track_text(active_station_data.track, radio_ext.path)

            radio.show_screen_notification(station_text, track_text)

            return
        end

        radio.show_screen_notification()
    end)

    ObserveBefore("PlayerPuppet", "OnGameAttached", function(self)
        radio.set_current_track()
    end)

    ObserveBefore("PlayerPuppet", "OnDetach", function(self)
        radio.set_current_track()
    end)

    ObserveBefore("inkSettingsSelectorControllerKeyBinding", "ListenForInput", function(self)
        config.listening_keybind_widget = self
    end)

    ---@param idx Int32
    ObserveBefore("SettingsMainGameController", "PopulateCategorySettingsOptions", function(self, idx)
        if self.data[idx + 1].groupPath.value == config.path then
            config.controller_input = true
        end
    end)

    ---@param progress Float
    ObserveBefore("inkFastTravelLoadingScreenLogicController", "SetLoadProgress", function(self, progress)
        if util.is_fast_travel_loading then
            return
        end

        util.is_fast_travel_loading = true
    end)

    ---@param visible Bool
    ObserveBefore("inkFastTravelLoadingScreenLogicController", "SetSpinnerVisiblility", function(self, visible)
        if not visible then
            return
        end

        util.is_fast_travel_loading = true
    end)

    ---@param value Bool
    ObserveBefore("FastTravelSystem", "OnLoadingScreenFinished", function(self, value)
        if not value then
            return
        end

        util.is_fast_travel_loading = false
    end)

    ---@param state Bool
    ObserveBefore("RadioLogicController", "OnRadioStateChanged", function(self, state)
        if not state or not radio.current_track_hash_lo then
            return
        end

        radio.veh_radio_state_change = true
    end)
end)

registerForEvent("onUpdate", function(delta)
    if util.is_in_menu() then
        return
    end

    local is_in_metro = radio.is_in_metro()
    local is_vehicle_receiver_active = radio.is_vehicle_receiver_active(true)

    if (is_vehicle_receiver_active and not is_in_metro) or radio.is_radio_ext_active(radio.ext) then
        if not radio.current_track_hash_lo then
            radio.skip(false)
            radio.is_requested = false
        elseif is_vehicle_receiver_active and radio.veh_radio_state_change then
            radio.skip(false)
            radio.veh_radio_state_change = false
        end

        return
    end

    if GetPlayer().mountedVehicle and not is_in_metro then
        return
    end

    local pre_track_name = radio.get_current_track_name()

    if not radio.check_pre_track(pre_track_name, true) then
        return
    end

    Game.GetUISystem():QueueEvent(vehicleRadioSongChanged.new({radioSongName = pre_track_name}))
end)

registerForEvent("onShutdown", function()
    Game.GetCallbackSystem():UnregisterCallback("Input/Key", config.key_input_event:Target(), config.key_input_event:Function("OnKeyInput"))
end)
