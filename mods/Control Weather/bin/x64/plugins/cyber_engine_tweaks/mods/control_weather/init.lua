---@param ... any
local function log(...)
    local args = { ... }
    for i, v in ipairs(args) do
        args[i] = tostring(v)
    end
    print(("[control_weather] %s"):format((table.concat(args, " "))))
end

registerForEvent("onInit", function()
    if not Codeware then
        log("Codeware is not installed.")
        return
    end

    local native_settings = GetMod("nativeSettings")

    if native_settings then
        local settings = {
            path = "/control_weather",
            blend_time = 10.0
        }

        local weather_system = Game.GetWeatherSystem()

        native_settings.addTab( -- Add a tab
            settings.path,      -- path
            "Control Weather",  -- label
            function()          -- callback
                if settings.weather_name then
                    weather_system:SetWeather(settings.weather_name, settings.blend_time, 5)
                end
            end
        )

        settings.weather_list = {
            "Sunny",
            "Rain",
            "Fog",
            "Pollution",
            "ToxicRain",
            "Sandstorm",
            "Light_Clouds",
            "Cloudy",
            "Heavy_Clouds",
            "q302_deep_blue",
            "q302_light_rain",
            "q302_squat_morning",
            "q306_epilogue_cloudy_morning",
            "q306_rainy_night",
            "sa_courier_clouds"
        }

        local weather_name_list = {
            "24h_weather_sunny",
            "24h_weather_rain",
            "24h_weather_fog",
            "24h_weather_pollution",
            "24h_weather_toxic_rain",
            "24h_weather_sandstorm",
            "24h_weather_light_clouds",
            "24h_weather_cloudy",
            "24h_weather_heavy_clouds",
            "q302_deep_blue",
            "q302_light_rain",
            "q302_squat_morning",
            "q306_epilogue_cloudy_morning",
            "q306_rainy_night",
            "sa_courier_clouds"
        }


        native_settings.addRangeFloat(
            settings.path,       -- path
            "Blend Time",        -- label
            "",                  -- desc
            0.0,                 -- min
            100.0,               -- max
            0.25,                -- step
            "%.2f",              -- format
            settings.blend_time, -- currentValue
            settings.blend_time, -- defaultValue
            function(value)      -- callback
                settings.blend_time = value
            end
        )

        native_settings.addSelectorString( -- Add a list of strings
            settings.path,                 -- path
            "Weather",                     -- label
            "",                            -- desc
            settings.weather_list,         -- elements
            1,                             -- currentValue
            1,                             -- defaultValue
            function(value)                -- callback
                settings.weather_name = weather_name_list[value]
            end
        )

        native_settings.addButton(
            settings.path,     -- path
            "",                -- label
            "",                -- desc
            "Restore Weather", -- buttonText
            45,               -- textSize
            function()         -- callback
                weather_system:ResetWeather(false, settings.blend_time)
                settings.weather_name = nil
            end
        )

        native_settings.addButton(
            settings.path,           -- path
            "",                      -- label
            "",                      -- desc
            "Force Restore Weather", -- buttonText
            45,                     -- textSize
            function()               -- callback
                weather_system:ResetWeather(true, settings.blend_time)
                settings.weather_name = nil
            end
        )
    else
        log("Native Settings UI is not installed.")
        return
    end
end)

registerForEvent("onShutdown", function()
    Game.GetWeatherSystem():ResetWeather(true, 0.0)
end)
