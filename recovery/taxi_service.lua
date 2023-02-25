local taxi = setmetatable({}, {__index = _G})
local utils = require("lib.recovery.utils")

function taxi:init(script)
    -- add taxi service to the menu
    script:add(
        script.root:list("Taxi Service", {}, "Taxi Service", function()
            script:notify("This works best with multiplier set to 0, tip base amount set to ~g~$5000~w~ and fare base amount set to ~g~$0~w~", util.show_corner_help)
        end),
        "taxi_service"
    )

    -- add taxi service to the menu
    script.taxi_service:divider("Taxi Service")

    -- add fare multiplier to the menu
    script.taxi_service:slider("Fare Multiplier", {}, "Multiplier for fares (do not set this value too high or you won\'t get any money)", 0, 100, 1, 1, function(value)
        memory.write_int(script.globals.taxi.fare_multiplier, value)
    end)

    -- add tip base amount to the menu
    script.taxi_service:text_input("Tip Base Amount", {"rststipbase"}, "Base amount for tips (do not set this value too high or you won\'t get any money)", function(value)
        memory.write_int(script.globals.taxi.tip, tonumber(value))
    end, tostring(memory.read_int(script.globals.taxi.tip)))

    -- add fare base amount to the menu
    script.taxi_service:text_input("Fare Base Amount", {"rstsfarebase"}, "Base amount for fares (do not set this value too high or you won\'t get any money)", function(value)
        memory.write_int(script.globals.taxi.fare, tonumber(value))
    end, tostring(memory.read_int(script.globals.taxi.fare)))    

    -- add afk loop to the menu
    script:add(
        script.taxi_service:toggle_loop("AFK Loop", {}, "", function()
            local blip = HUD.GET_FIRST_BLIP_INFO_ID(280)
            local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped(), true)
            local start = os.time() + 2
            local wait_time = os.time() + 60
            local afk = menu.ref_by_rel_path(script.taxi_service, "AFK Loop")
        
            if blip ~= 0 then
                local color = HUD.GET_BLIP_COLOUR(blip)
                if color == 57 then
                    local entity = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
                    local ent_pos = ENTITY.GET_ENTITY_COORDS(entity, true)
                    if entity ~= 0 then
                        local veh = PED.GET_VEHICLE_PED_IS_IN(script.me_ped, false)
                        if veh ~= 0 then
                            ENTITY.SET_ENTITY_INVINCIBLE(entity, true)
                            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(entity, true)
                            PED.SET_PED_CAN_RAGDOLL(entity, false)
                            PED.SET_PED_COORDS_KEEP_VEHICLE(script.me_ped, ent_pos.x - 3, ent_pos.y - 3, ent_pos.z)
                            ENTITY.FREEZE_ENTITY_POSITION(veh, true)

                            while not PED.IS_PED_IN_ANY_VEHICLE(entity) do
                                if not afk.value then util.stop_thread() end
                                utils:SIMULATE_CONTROL_KEY(86, 1)
        
                                if os.time() >= start then
                                    PED.SET_PED_INTO_VEHICLE(entity, veh, 1)
                                    break
                                end
                                util.yield_once()
                            end
        
                            util.yield(1000)
                            menu.trigger_commands("tpobj")
                        end
                    end
                end
            end
        
            while os.time() < wait_time do
                if not afk.value then util.stop_thread() end
                util.draw_debug_text("Waiting " .. wait_time - os.time() .. " seconds")
                util.yield_once()
            end
        
            wait_time = os.time() + 60
        end),
        "taxi_service_afk_loop"
    )
end

return taxi