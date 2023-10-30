local spectator = {}

local function update(delta)
    local pos = GetPlayer():GetWorldPosition()
    local vec4 = Game.GetCameraSystem():GetActiveCameraRight()

    local rad = math.atan2(vec4.y, vec4.x)

    local x = pos.x + (spectator.x * math.cos(rad) - spectator.y * math.sin(rad)) * delta * 20 * spectator.speed
    local y = pos.y + (spectator.x * math.sin(rad) + spectator.y * math.cos(rad)) * delta * 20 * spectator.speed
    local z = pos.z + (spectator.z * delta * 20 * spectator.speed)

    pos.x = x
    pos.y = y
    pos.z = z

    local position = pos
    local orientation = EulerAngles.new(0, 0, Game.GetPlayer():GetWorldYaw() + spectator.yaw)

    Game.GetTeleportationFacility():Teleport(Game.GetPlayerObject(), position, orientation)
end

local function is_in_menu()
    return Game.GetBlackboardSystem():Get(GetAllBlackboardDefs().UI_System):GetBool(GetAllBlackboardDefs().UI_System.IsInMenu)
end

registerForEvent("onInit", function()
    local key_input_event = NewProxy(
        {
            OnKeyInput = {
                args = { "whandle:KeyInputEvent" },
                callback = function(evt)
                    local key = evt:GetKey()
                    local action = evt:GetAction()

                    if action == EInputAction.IACT_Press then
                        print(key.value)
                    end
                end
            }
        }
    )

    Game.GetCallbackSystem():RegisterCallback("Input/Key", key_input_event:Target(), key_input_event:Function("OnKeyInput"), true)

    ---@param self PlayerPuppet
    ---@param action ListenerAction
    ---@param consumer ListenerActionConsumer
    ObserveBefore("PlayerPuppet", "OnAction", function(self, action, consumer)
        local action_name = ListenerAction.GetName(action)

        if action_name.value == "MoveX" then
            spectator.x = ListenerAction.GetValue(action)
        elseif action_name.value == "MoveY" then
            spectator.y = ListenerAction.GetValue(action)
        elseif action_name.value == "Jump" then
            spectator.z = ListenerAction.GetValue(action)
        elseif action_name.value == "Crouch" then
            spectator.z = ListenerAction.GetValue(action) * -1
        elseif action_name.value == "ToggleCrouch" then
            spectator.z = ListenerAction.GetValue(action) * -1
        elseif action_name.value == "Sprint" then
            spectator.speed = ListenerAction.GetValue(action) + 1
        elseif action_name.value == "ToggleSprint" then
            spectator.speed = ListenerAction.GetValue(action) + 1
        end

        if action_name.value == "CameraMouseX" then
            local fpp_mouse_x = Game.GetSettingsSystem():GetVar("/controls/fppcameramouse", "FPP_MouseX"):GetValue()
            spectator.yaw = ListenerAction.GetValue(action) * fpp_mouse_x / -101.5
        end

        if action_name.value == "right_stick_x" then
            local fpp_pad_x = Game.GetSettingsSystem():GetVar("/controls/fppcamerapad", "FPP_PadX"):GetValue()
            spectator.yaw = ListenerAction.GetValue(action) * fpp_pad_x * -0.17
        end
    end)

    ---@param self LocomotionEventsTransition
    ---@param timeDelta Float
    ---@param stateContext StateContext
    ---@param scriptInterface StateGameScriptInterface
    ObserveBefore("LocomotionEventsTransition", "OnUpdate", function(self, timeDelta, stateContext, scriptInterface)
        spectator.is_crouch = scriptInterface.owner:GetPuppetPS():IsCrouch()
    end)
end)

registerForEvent("onUpdate", function(delta)
    if not is_in_menu() then
        update(delta)
    end
end)
