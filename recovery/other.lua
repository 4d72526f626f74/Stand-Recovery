local other_methods = setmetatable({}, {__index = _G})

other_methods.property_changer = {
    property_ids = {
        ["Invalid"] = 0,
        ["Eclipse Towers 31"] = 1,
        ["Eclipse Towers 9"] = 2,
        ["Eclipse Towers 40"] = 3,
        ["Eclipse Towers 5"] = 4,
        ["3 Alta St, Apt 10"] = 5,
        ["3 Alta St, Apt 57"] = 6,
        ["Del Perro Heights, Apt 20"] = 7,
        ["Power St, Apt 3"] = 8,
        ["Spanish Ave, Apt 1"] = 9,
        ["Las Lagunas Blv, 4"] = 10,
        ["Milton Rd, Apt 13"] = 11,
        ["The Royale, Apt 19"] = 12,
        ["S Mo Milton Drive"] = 13,
        ["Bay City Ave, Apt 45"] = 14,
        ["0325 S Rockford Dr"] = 15,
        ["Dream Tower, Apt 15"] = 16,
        ["Las Lagunas Blv, 9"] = 17,
        ["San Vitas St, Apt 2"] = 18,
        ["0112 S Rockford Dr, 13"] = 19,
        ["Vespucci Blvd, Apt 1"] = 20,
        ["Cougar Ave, Apt 19"] = 21,
        ["Prosperity St, 21"] = 22,
        ["Blvd Del Perro, 18"] = 23,
        ["Murrieta Heights"] = 24,
        ["Unit 14 Popular St"] = 25,
        ["Unit 2 Popular St"] = 26,
        ["331 Supply St"] = 27,
        ["Unit 1 Olympic Fwy"] = 28,
        ["Roy Lowenstein Blvd"] = 29,
        ["Little Bighorn Ave"] = 30,
        ["Unit 124 Popular St"] = 31,
        ["Roy Lowenstein Blvd"] = 32,
        ["0432 Davis Ave"] = 33,
        ["Del Perro Heights, 7"] = 34,
        ["Weazel Plaza, 101"] = 35,
        ["Weazel Plaza, 70"] = 36,
        ["Weazel Plaza, 26"] = 37,
        ["Integrity Way, 30"] = 38,
        ["Integrity Way, 35"] = 39,
        ["Richards Majestic, 4"] = 40,
        ["Richards Majestic, 51"] = 41,
        ["Tinsel Towers, Apt 45"] = 42,
        ["Tinsel Towers, Apt 29"] = 43,
        ["Paleto Blvd"] = 44,
        ["Strawberry Ave"] = 45,
        ["Grapeseed Ave"] = 46,
        ["Senora Way"] = 47,
        ["Great Ocean Highway"] = 48,
        ["197 Route 68"] = 49,
        ["870 Route 68"] = 50,
        ["1200 Route 68"] = 51,
        ["8754 Route 68"] = 52,
        ["1905 Davis Ave"] = 53,
        ["South Shambles St"] = 54,
        ["4531 Dry Dock St"] = 55,
        ["Exceptionalists Way"] = 56,
        ["Greenwich Parkway"] = 57,
        ["Innocence Blvd"] = 58,
        ["Blvd Del Perro"] = 59,
        ["Mirror Park Blvd"] = 60,
        ["Eclipse Towers 3"] = 61,
        ["Del Perro Heights 4"] = 62,
        ["Richards Majestics, 2"] = 63,
        ["Tinsel Towers, Apt 42"] = 64,
        ["Integrity Way, 28"] = 65,
        ["4 Hangman Ave"] = 66,
        ["12 Sustancia Rd"] = 67,
        ["4584 Procopio Dr"] = 68,
        ["4401 Procopio Dr"] = 69,
        ["0232 Paleto Blvd"] = 70,
        ["140 Zancudo Ave"] = 71,
        ["1893 Grapeseed Ave"] = 72,
        ["3655 Wild Oats Dr"] = 73,
        ["2044 North Conker Ave"] = 74,
        ["2868 Hillcrest Ave"] = 75,
        ["2862 Hillcrest Ave"] = 76,
        ["3677 Whispymound Dr"] = 77,
        ["2117 Milton Rd"] = 78,
        ["2866 Hillcrest Ave"] = 79,
        ["2874 Hillcrest Ave"] = 80,
        ["2113 Mad Wayne T Dr"] = 81,
        ["2045 North Conker Ave"] = 82,
        ["Eclipse Penthouse, Suite 1"] = 83,
        ["Eclipse Penthouse, Suite 2"] = 84,
        ["Eclipse Penthouse, Suite 3"] = 85,
        ["Invalid (1)"] = 86,
        ["Lombank West"] = 87,
        ["Maze Bank West"] = 88,
        ["Arcadius"] = 89,
        ["Maze Bank Tower"] = 90,
        ["Rancho Clubhouse"] = 91,
        ["Del Perro Beach Clubhouse"] = 92,
        ["Philbox Hill Clubhouse"] = 93,
        ["Great Chaparral Clubhouse"] = 94,
        ["Paleto Bay Clubhouse"] = 95,
        ["Sandy Shores Clubhouse"] = 96,
        ["La Mesa Clubhouse"] = 97,
        ["Vinewood Clubhouse"] = 98,
        ["Hawick Clubhouse"] = 99,
        ["Grapeseed Clubhouse"] = 100,
        ["Paleto Bay Clubhouse (0)"] = 101,
        ["Vespucci Beach Clubhouse"] = 102,
        ["Office Garage 1 (Lombank)"] = 103,
        ["Office Garage 2 (Lombank)"] = 104,
        ["Office Garage 3 (Lombank)"] = 105,
        ["Office Garage 1 (Maze Bank West)"] = 106,
        ["Office Garage 2 (Maze Bank West)"] = 107,
        ["Office Garage 3 (Maze Bank West)"] = 108,
        ["Office Garage 1 (Arcadius)"] = 109,
        ["Office Garage 2 (Arcadius)"] = 110,
        ["Office Garage 3 (Arcadius)"] = 111,
        ["Office Garage 1 (Maze Bank Tower)"] = 112,
        ["Office Garage 2 (Maze Bank Tower)"] = 113,
        ["Office Garage 3 (Maze Bank Tower)"] = 114,
        ["Vehicle Warehouse"] = 115,
    }
}

function other_methods:init(script)
    local loops = 0 -- number of loops for criminal damage money method
    local start = os.time() -- timer

    -- add other methods to the menu
    script:add(
        script.root:list("Other", {}, "Other methods",
        function()
            util.show_corner_help("If you plan on using the Criminal Damage Money method, make sure you are the host of the session and that the player you want to give money to is in a CEO with you as their associate (this method does not work for you)")
        end),
        "other"
    )

    -- add a money divider
    script.other:divider("Money")

    -- add criminal damage money loop to the menu
    script:add(
        script.other:toggle_loop("Criminal Damage Loop", {}, "Give other players money through criminal damage freeroam event, you need to be the host and be an associate of the organisation of the player you wish to give money to", function()
            while players.get_script_host() ~= script.me do
                script:notify("Forcing script host")
                menu.trigger_commands("scripthost")
                util.yield(1000)
            end

            memory.write_float(script.globals.criminal_damage.cash_multiplier, 2.5) -- cash multiplier
            memory.write_int(script.globals.criminal_damage.time_limit, 2000) -- time limit
            memory.write_int(script.globals.criminal_damage.start_time, 2000) -- start timer
            memory.write_int(script.globals.criminal_damage.players_required, 0) -- players required (bypasses default 3 player requirement when there are 2 players in the session)

            local base = menu.ref_by_command_name("runscript")
            local ref = menu.ref_by_rel_path(base, "Freemode Activities")
            local criminal_damage = menu.ref_by_rel_path(ref, "Criminal Damage")
            local session = menu.ref_by_rel_path(menu.ref_by_path("Online>Session"), "Session Scripts")
            local criminal_damage1 = menu.ref_by_rel_path(session, "Criminal Damage")
            local stop = menu.ref_by_rel_path(criminal_damage1, "Stop Script")
            local score = menu.ref_by_rel_path(criminal_damage1, "Score")

            criminal_damage:trigger() -- start criminal damage
            util.yield(2250) -- wait for the script to start
            score:trigger(600000)
            util.yield(2000) -- wait for the score to update
            stop:trigger() -- stop the script
            util.yield(2000) -- wait for the script to stop
            stop:trigger() -- stop the script again

            loops = loops + 1
            if loops % 2 == 0 and loops > 0 then
                start = os.time() + 90
                while os.time() < start and menu.ref_by_rel_path(script.other, "Criminal Damage Loop").value do
                    if not menu.ref_by_rel_path(script.other, "Criminal Damage Loop").value then break end
                    script:notify("Waiting " .. start - os.time() .. " seconds")
                    util.yield(5000)
                end
            end
        end,
        function()
            loops = 0
        end),
        "other_criminal_damage_money"
    )

    -- add fake money
    script:add(
        script.other:toggle_loop("Fake Money", {}, "Give yourself fake money", function()
            local bank = players.get_bank(script.me)

            HUD.CHANGE_FAKE_MP_CASH(0, (2 << 30) - 1)
            --util.yield(500)
        end),
        "other_fake_money"
    )

    -- add a divider for property changer
    script.other:divider("Property Changer")

    local properties = {}
    for k, v in pairs(other_methods.property_changer.property_ids) do
        table.insert(properties, k)
    end

    -- add owned properties to the menu
    script:add(
        script.other:list("Owned Properties", {}, "Properties you own"),
        "other_owned_properties"
    )

    -- add slot 0 to properties menu
    local slot_0_id = script:STAT_GET_INT("PROPERTY_HOUSE")
    local slot_1_id = script:STAT_GET_INT("MULTI_PROPERTY_1")
    local slot_2_id = script:STAT_GET_INT("MULTI_PROPERTY_2")
    local slot_3_id = script:STAT_GET_INT("MULTI_PROPERTY_3")
    local slot_4_id = script:STAT_GET_INT("MULTI_PROPERTY_4")
    local slot_5_id = script:STAT_GET_INT("MULTI_PROPERTY_5")
    local slot_6_id = script:STAT_GET_INT("MULTI_PROPERTY_6")
    local slot_7_id = script:STAT_GET_INT("MULTI_PROPERTY_7")
    local slot_8_id = script:STAT_GET_INT("MULTI_PROPERTY_8")
    local slot_9_id = script:STAT_GET_INT("MULTI_PROPERTY_9")
    
    if slot_0_id ~= 0 then
        for k, v in pairs(other_methods.property_changer.property_ids) do
            if v == slot_0_id then
                script.other_owned_properties:readonly("Slot 0", k)
            end
        end
    end

    -- add slot 1 to properties menu
    if slot_1_id ~= 0 then
        for k, v in pairs(other_methods.property_changer.property_ids) do
            if v == slot_1_id then
                script.other_owned_properties:readonly("Slot 1", k)
            end
        end
    end

    -- add slot 2 to properties menu
    if slot_2_id ~= 0 then
        for k, v in pairs(other_methods.property_changer.property_ids) do
            if v == slot_2_id then
                script.other_owned_properties:readonly("Slot 2", k)
            end
        end
    end

    -- add slot 3 to properties menu
    if slot_3_id ~= 0 then
        for k, v in pairs(other_methods.property_changer.property_ids) do
            if v == slot_3_id then
                script.other_owned_properties:readonly("Slot 3", k)
            end
        end
    end

    -- add slot 4 to properties menu
    if slot_4_id ~= 0 then
        for k, v in pairs(other_methods.property_changer.property_ids) do
            if v == slot_4_id then
                script.other_owned_properties:readonly("Slot 4", k)
            end
        end
    end

    -- add slot 5 to properties menu
    if slot_5_id ~= 0 then
        for k, v in pairs(other_methods.property_changer.property_ids) do
            if v == slot_5_id then
                script.other_owned_properties:readonly("Slot 5", k)
            end
        end
    end

    -- add slot 6 to properties menu
    if slot_6_id ~= 0 then
        for k, v in pairs(other_methods.property_changer.property_ids) do
            if v == slot_6_id then
                script.other_owned_properties:readonly("Slot 6", k)
            end
        end
    end

    -- add slot 7 to properties menu
    if slot_7_id ~= 0 then
        for k, v in pairs(other_methods.property_changer.property_ids) do
            if v == slot_7_id then
                script.other_owned_properties:readonly("Slot 7", k)
            end
        end
    end

    -- add slot 8 to properties menu
    if slot_8_id ~= 0 then
        for k, v in pairs(other_methods.property_changer.property_ids) do
            if v == slot_8_id then
                script.other_owned_properties:readonly("Slot 8", k)
            end
        end
    end

    -- add property changer
    script:add(
        script.other:list_select("Property", {}, "Property to change to", properties, 1, function(index) end),
        "other_property_changer"
    )

    script.other:action("Change Property", {}, "Changes the property in slot 0", function()
        local p_index = script.other_property_changer.value
        local p_name = properties[p_index]
        local p_id = other_methods.property_changer.property_ids[p_name]

        script:STAT_SET_INT("PROPERTY_HOUSE", p_id)
        script:STAT_SET_INT("PROPERTY_HOUSE_NEW", p_id)
    end)

    -- add vehicles
    script.other:divider("Vehicles")

    -- add vehicle gifting
    script:add(
        script.other:action("Improved Gift Spawned Vehicle", {}, "Gifts you the vehicle you have spawned, this is an improved version of the built-in one", function()
            if PED.IS_PED_IN_ANY_VEHICLE(script.me_ped) then
                local veh = PED.GET_VEHICLE_PED_IS_IN(script.me_ped, false)
                local start = os.time() + 15
        
                if veh ~= 0 then
                    local owner_check = script.globals.vehicles.previous_owner_check
                    local player_hash = NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(script.me)
                    local spawned_model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(veh))
                    local pos = ENTITY.GET_ENTITY_COORDS(script.me_ped, true)
        
                    if player_hash ~= 0 then
                        local bitset = DECORATOR.DECOR_GET_INT(veh, "MPBitset")
                        bitset = script:BitClear(bitset, 3) -- vehicle spawned bit
                        bitset = script:BitSet(bitset, 24) -- personal vehicle bit
                        VEHICLE.SET_VEHICLE_IS_STOLEN(veh, false)
                        
                        memory.write_int(owner_check, 0)
                        DECORATOR.DECOR_SET_INT(veh, "MPBitset", bitset)
                        DECORATOR.DECOR_SET_INT(veh, "Previous_Owner", 0)
                        DECORATOR.DECOR_SET_INT(veh, "PV_Slot", 0)
                        DECORATOR.DECOR_SET_INT(veh, "Player_Vehicle", player_hash)
                        DECORATOR.DECOR_SET_INT(veh, "Veh_Modded_By_Player", player_hash)
        
                        local interior = INTERIOR.GET_INTERIOR_FROM_ENTITY(script.me_ped)
                        while interior == 0 do
                            interior = INTERIOR.GET_INTERIOR_FROM_ENTITY(script.me_ped)
                            if os.time() >= start then
                                memory.write_int(owner_check, 1)
                                util.stop_thread()
                            end
                            util.yield_once()
                        end
        
                        memory.write_int(owner_check, 1)
        
                        while interior ~= 0 do
                            interior = INTERIOR.GET_INTERIOR_FROM_ENTITY(script.me_ped)
                            util.yield_once()
                        end
        
                        for i, veh in pairs(entities.get_all_vehicles_as_handles()) do
                            local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(veh))
                            if model:find(spawned_model) then
                                local veh_pos = ENTITY.GET_ENTITY_COORDS(veh, true)
                                if MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, veh_pos.x, veh_pos.y, veh_pos.z, true) < 10.0 then
                                    entities.delete_by_handle(veh)
                                end
                            end
                        end
                    end
                end
            else
                script:notify("You must be in a vehicle")
            end
        end),
        "other_vehicle_gifting"
    )

    script.other:action("Claim All Personal Vehicles", {}, "Claims all destroyed/impounded personal vehicles", function()
        for slot = 0, 415 do
            local veh = memory.script_global(1586468 + 1 + (slot * 142) + 103)
            local bitfield = memory.read_int(veh)

            memory.write_int(veh, bitfield & ((bitfield & (1 << 1)) ~= 0 and ~0x26 or ~0x40))
        end
    end)

    script.other:action("Claim Personal Vehicle", {}, "Claims the current active personal vehicle", function()
        local pv_slot = memory.script_global(2359296 + 1 + (0 * 5568) + 681 + 2)
        local veh = memory.script_global(1586468 + 1 + (memory.read_int(pv_slot) * 142) + 103)
        local bitfield = memory.read_int(veh)

        memory.write_int(veh, bitfield & ((bitfield & (1 << 1)) ~= 0 and ~0x26 or ~0x40))
    end)

    script.other:action("Add Insurance", {}, "Insures your personal vehicle", function()
        local player_veh = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        if player_veh ~= 0 then
            local pv_slot = script:global(2359296 + 1 + (0 * 5568) + 681 + 2)
            local veh = script:global(1586468 + 1 + (pv_slot:read_int() * 142) + 103)
            local bitfield = veh:read_int()

            if script:BitTest(bitfield, 2) then
                script:msg("Vehicle is already insured!")
            else
                veh:write_int(script:BitSet(bitfield, 2))
                script:msg("Vehicle is now insured, to make sure it stays insured goto LS Customs and change any upgrade on your vehicle")
            end
        end
    end)

    script.other:toggle_loop("Auto Claim All Personal Vehicles", {}, "Automatically claims all destroyed/impounded personal vehicles", function()
        menu.ref_by_rel_path(script.other, "Claim All Personal Vehicles"):trigger()
        util.yield_once()
    end)

    script.other:toggle_loop("Auto Claim Personal Vehicle", {}, "Automatically claims the current active personal vehicle", function()
        menu.ref_by_rel_path(script.other, "Claim Personal Vehicle"):trigger()
        util.yield_once()
    end)

    script.other:toggle_loop("Auto Add Insurance", {}, "Automatically insures your personal vehicle", function()
        menu.ref_by_rel_path(script.other, "Add Insurance"):trigger()
        util.yield_once()
    end)
end

return other_methods