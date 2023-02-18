local heists = setmetatable({}, {__index = _G})

heists.globals = {
    cayo_perico = {
        panther_statue_value = memory.script_global(262145 + 29987),
        madrazo_files_value = memory.script_global(262145 + 29986),
        pink_diamond_value = memory.script_global(262145 + 29985),
        bearer_bonds_value = memory.script_global(262145 + 29984),
        ruby_necklace_value = memory.script_global(262145 + 29983),
        tequila_value = memory.script_global(262145 + 29982),
        pavel_cut = memory.script_global(262145 + 29991),
        pavel_cut1 = memory.script_global(262145 + 29727),
        fencing_cut = memory.script_global(262145 + 29992),
    }
}

heists.cayo_perico = {
    targets = {
        [-1] = "None",
        [0] = "Tequila",
        [1] = "Ruby Necklace",
        [2] = "Bearer Bonds",
        [3] = "Pink Diamonds",
        [4] = "Madrazo Files",
        [5] = "Sapphire Panther"
    },
    PANTHER_DEFAULT = 1900000,
    MADRAZO_DEFAULT = 1100000,
    PINK_DIAMOND_DEFAULT = 1300000,
    BEARER_BONDS_DEFAULT = 1100000,
    RUBY_NECKLACE_DEFAULT = 1000000,
    TEQUILA_DEFAULT = 900000,
    gates = {
        SECONDARY_TARGET_BASEMENT_DOOR = v3.new(5002.2915039062, -5746.7397460938, 14.941325187683),
        BASEMENT_ENTRY_DOOR_1 = v3.new(5006.6015625, -5734.466796875, 15.936750411987),
        BASEMENT_ENTRY_DOOR_2 = v3.new(4992.8266601562, -5756.6586914062, 15.988387107849),
        MAIN_GATE = v3.new(4987.5874023438, -5718.634765625, 20.781032562256),
        MAIN_GATE_1 = v3.new(4984.1337890625, -5709.2485351562, 20.781032562256),
        MAIN_GATE_2 = v3.new(4981.0122070312, -5712.7470703125, 20.781032562256),
        MAIN_GATE_3 = v3.new(4990.6811523438, -5715.1059570312, 20.781032562256),
        ARCH_GATE_RIGHT = v3.new(4993.048828125, -5758.0986328125, 20.270370483398),
        ARCH_GATE_RIGHT_1 = v3.new(4998.6025390625, -5733.0712890625, 20.270597457886),
        ARCH_GATE_LEFT = v3.new(4994.3681640625, -5755.9975585938, 20.270370483398),
        ARCH_GATE_LEFT_1 = v3.new(5000.2680664062, -5731.2290039062, 20.270597457886),
        PRIMARY_TARGET_GATE = v3.new(5007.6196289062, -5753.6083984375, 15.572952270508),
        BASEMENT_FINGERPRINT_ENTRY_GATE = v3.new(4998.0825195312, -5743.1323242188, 14.941325187683)
    },
    refs = {},
}

function heists:init(script)
    -- add heists to the menu
    script:add(
        script.root:list("Heists", {}, "Heist related options"),
        "heists"
    )

    -- add heists divider
    script.heists:divider("Heists")

    -- add cayo perico to the menu
    script:add(
        script.heists:list("Cayo Perico Heist", {}, "Cayo Perico heist options"),
        "cayo_perico"
    )

    -- add casino heist to the menu
    --[[script:add(
        script.heists:list("Diamond Casino Heist", {}, "Diamond Casino heist options"),
        "casino_heist"
    )]]

    -- add other divider to the menu
    script.heists:divider("Other")

    -- add multipliers to the menu
    script:add(
        script.heists:list("Multipliers", {}, "Multiplers"),
        "mults"
    )

    -- add tunables to the menu
    script:add(
        script.heists:list("Tunables", {}, "Tunables"),
        "tunables"
    )

    -- add sliders divider to the menu
    script.mults:divider("Sliders")

    -- add cash mult to the menu
    script:add(
        script.mults:click_slider_float("Cash Multiplier", {}, "", 0.0, 1000000.0, 100.0, 50.0, function(value)
            value = tonumber(value / 100)
            memory.write_float(script.globals.modifiers.cash, value)
        end),
        "mult_cash_multiplier"
    )

    -- add rp mult to the menu
    script:add(
        script.mults:click_slider_float("RP Multiplier", {}, "", 0.0, 1000000.0, 100.0, 50.0, function(value)
            value = tonumber(value / 100)
            memory.write_float(script.globals.modifiers.rp, value)
        end),
        "mult_rp_multiplier"
    )

    -- add arena points mult to the menu
    script:add(
        script.mults:click_slider_float("Arena Points Multiplier", {}, "", 0.0, 1000000.0, 100.0, 50.0, function(value)
            value = tonumber(value / 100)
            memory.write_float(script.globals.modifiers.ap, value)
        end),
        "mult_arena_points_multiplier"
    )

    -- add custom divider to the menu
    script.mults:divider("Custom")

    -- add step changer
    script:add(
        script.mults:text_input("Step Changer", {"rsstepchanger"}, "Changes the step size for the sliders (default value is 0.5)", function(value)
            value = tonumber(value)
            if value ~= nil then
                value = value * 100
                menu.set_step_size(script.mult_cash_multiplier, value)
                menu.set_step_size(script.mult_rp_multiplier, value)
                menu.set_step_size(script.mult_arena_points_multiplier, value)
            else
                menu.set_step_size(script.mult_cash_multiplier, 50.0)
                menu.set_step_size(script.mult_rp_multiplier, 50.0)
                menu.set_step_size(script.mult_arena_points_multiplier, 50.0)
            end
        end),
        "mult_step_changer"
    )

    -- add disable cayo perico payout to the menu
    script:add(
        script.tunables:toggle("Disable Payout", {}, "", function(state)
            if state then
                memory.write_float(script.globals.modifiers.cash, 0.0)
            else
                memory.write_float(script.globals.modifiers.cash, 1.5) -- 1.0 is default, 1.5 means you get more money ez
            end
        end),
        "tunables_disable_payout"
    )

    -- add options to the menu
    script.cayo_perico:divider("Options")

    -- add primary target list
    script:add(
        script.cayo_perico:list("Primary Target", heists.cayo_perico.targets, "The primary target of the heist", function()
            local target_ref = menu.ref_by_rel_path(script.cayo_perico_primary_target, "Target")
            local target = heists.cayo_perico.targets[script:GET_CP_HEIST_PRIMARY_TARGET()] or "None"

            if target_ref:isValid() then
                target_ref.value = target
            end
        end),
        "cayo_perico_primary_target"
    )

    -- add the current primary target to the menu
    script.cayo_perico_primary_target:readonly("Target", heists.cayo_perico.targets[script:GET_CP_HEIST_PRIMARY_TARGET()] or "None")

    -- add sapphire panther to the menu
    script:add(
        script.cayo_perico_primary_target:action("Sapphire Panther", {}, "Set the primary target", function()
            script:SET_CP_HEIST_PRIMARY_TARGET(5)
            script:notify("Primary target set to Sapphire Panther")
        end),
        "cayo_perico_primary_target_sapphire_panther"
    )

    -- add madrazo files to the menu
    script:add(
        script.cayo_perico_primary_target:action("Madrazo Files", {}, "Set the primary target", function()
            script:SET_CP_HEIST_PRIMARY_TARGET(4)
            script:notify("Primary target set to Madrazo Files")
        end),
        "cayo_perico_primary_target_madrazo_files"
    )

    -- add pink diamonds to the menu
    script:add(
        script.cayo_perico_primary_target:action("Pink Diamonds", {}, "Set the primary target", function()
            script:SET_CP_HEIST_PRIMARY_TARGET(3)
            script:notify("Primary target set to Pink Diamonds")
        end),
        "cayo_perico_primary_target_pink_diamonds"
    )

    -- add bearer bonds to the menu
    script:add(
        script.cayo_perico_primary_target:action("Bearer Bonds", {}, "Set the primary target", function()
            script:SET_CP_HEIST_PRIMARY_TARGET(2)
            script:notify("Primary target set to Bearer Bonds")
        end),
        "cayo_perico_primary_target_bearer_bonds"
    )

    -- add ruby necklace to the menu
    script:add(
        script.cayo_perico_primary_target:action("Ruby Necklace", {}, "Set the primary target", function()
            script:SET_CP_HEIST_PRIMARY_TARGET(1)
            script:notify("Primary target set to Ruby Necklace")
        end),
        "cayo_perico_primary_target_ruby_necklace"
    )

    -- add tequila to the menu
    script:add(
        script.cayo_perico_primary_target:action("Tequila", {}, "Set the primary target", function()
            script:SET_CP_HEIST_PRIMARY_TARGET(0)
            script:notify("Primary target set to Tequila")
        end),
        "cayo_perico_primary_target_tequila"
    )

    -- add none to the menu
    script:add(
        script.cayo_perico_primary_target:action("Reset Target", {}, "Set the primary target", function()
            script:SET_CP_HEIST_PRIMARY_TARGET(-1)
            script:notify("Primary target has been reset")
        end),
        "cayo_perico_primary_target_reset"
    )

    -- add primary target values divider
    script.cayo_perico_primary_target:divider("Primary Target Values")

    -- add sapphire panther value slider
    script:add(
        script.cayo_perico_primary_target:slider("Sapphire Panther", {}, "Set value of sapphire panther", 0, script.MAX_INT, memory.read_int(heists.globals.cayo_perico.panther_statue_value), 100000, function(value)
            memory.write_int(heists.globals.cayo_perico.panther_statue_value, value)
        end),
        "cayo_perico_sapphire_value"
    )

    -- add madrazo files value slider
    script:add(
        script.cayo_perico_primary_target:slider("Madrazo Files", {}, "Set value of madrazo files", 0, script.MAX_INT, memory.read_int(heists.globals.cayo_perico.madrazo_files_value), 100000, function(value)
            memory.write_int(heists.globals.cayo_perico.madrazo_files_value, value)
        end),
        "cayo_perico_madrazo_value"
    )

    -- add pink diamonds value slider
    script:add(
        script.cayo_perico_primary_target:slider("Pink Diamonds", {}, "Set value of pink diamonds", 0, script.MAX_INT, memory.read_int(heists.globals.cayo_perico.pink_diamond_value), 100000, function(value)
            memory.write_int(heists.globals.cayo_perico.pink_diamond_value, value)
        end),
        "cayo_perico_pink_value"
    )

    -- add bearer bonds value slider
    script:add(
        script.cayo_perico_primary_target:slider("Bearer Bonds", {}, "Set value of bearer bonds", 0, script.MAX_INT, memory.read_int(heists.globals.cayo_perico.bearer_bonds_value), 100000, function(value)
            memory.write_int(heists.globals.cayo_perico.bearer_bonds_value, value)
        end),
        "cayo_perico_bearer_value"
    )

    -- add 1 necklace value slider
    script:add(
        script.cayo_perico_primary_target:slider("Ruby Necklace", {}, "Set value of ruby necklace", 0, script.MAX_INT, memory.read_int(heists.globals.cayo_perico.ruby_necklace_value), 100000, function(value)
            memory.write_int(heists.globals.cayo_perico.ruby_necklace_value, value)
        end),
        "cayo_perico_ruby_value"
    )

    -- add tequila value slider
    script:add(
        script.cayo_perico_primary_target:slider("Tequila", {}, "Set value of tequila", 0, script.MAX_INT, memory.read_int(heists.globals.cayo_perico.tequila_value), 100000, function(value)
            memory.write_int(heists.globals.cayo_perico.tequila_value, value)
        end),
        "cayo_perico_tequila_value"
    )

    -- add presets to the menu
    script:add(
        script.cayo_perico:list("Presets", {}, "Presets"),
        "cayo_perico_presets"
    )

    -- add teleports to the menu
    script:add(
        script.cayo_perico:list("Teleports", {}, "Teleports"),
        "cayo_perico_teleports"
    )

    -- add compound teleports to the menu
    script:add(
        script.cayo_perico_teleports:list("Compound", {}, "Compound"),
        "cayo_perico_compound_teleports"
    )

    -- add island teleports to the menu
    script:add(
        script.cayo_perico_teleports:list("Island", {}, "Island"),
        "cayo_perico_island_teleports"
    )

    script:add(
        script.cayo_perico_teleports:list("Exits", {}, "Exits"),
        "cayo_perico_exit_teleports"
    )

    -- add helpful tools to the menu
    script:add(
        script.cayo_perico:list("Useful Tools", {}, "Features that assist you with completing the heist", function()
            
        end),
        "cayo_perico_useful_tools"
    )

    -- add trolling tools to the menu
    script:add(
        script.cayo_perico:list("Trolling Tools", {}, "Features that assist you with trolling your friends or random players during this heist"),
        "cayo_perico_trolling_tools"
    )

    -- add teleport to keypad (the one in rubio's office)
    script:add(
        script.cayo_perico_compound_teleports:action("Teleport To Keypad (Office)", {}, "Teleports you to the keypad in the basement", function()
            local keypads = script:FIND_ALL_FINGERPRINT_KEYPADS()
            
            local entity = keypads[1]
            local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
            ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
        end),
        "cayo_perico_teleport_keypad"
    )

    -- add teleport to keypad (basement elevator)
    script:add(
        script.cayo_perico_compound_teleports:action("Teleport To Keypad (Basement)", {}, "Teleports you to the keypad in the basement", function()
            local keypads = script:FIND_ALL_FINGERPRINT_KEYPADS()
            
            local entity = keypads[2]
            local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
            ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
        end),
        "cayo_perico_teleport_keypad_basement"
    )

    -- add teleport to keypad (basement gate)
    script:add(
        script.cayo_perico_compound_teleports:action("Teleport To Keypad (Basement Gate 1)", {}, "Teleports you to the keypad in the basement", function()
            local keypads = script:FIND_ALL_FINGERPRINT_KEYPADS()
            
            local entity = keypads[3]
            local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
            ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
        end),
        "cayo_perico_teleport_keypad_gate"
    )

    -- add teleport to keypad (basement gate 2)
    script:add(
        script.cayo_perico_compound_teleports:action("Teleport To Keypad (Basement Gate 2)", {}, "Teleports you to the keypad in the basement", function()
            local keypads = script:FIND_ALL_FINGERPRINT_KEYPADS()
            
            local entity = keypads[4]
            local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
            ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
        end),
        "cayo_perico_teleport_keypad_gate_2"
    )

    -- teleport you to kosatka
    script:add(
        script.cayo_perico_exit_teleports:action("Teleport To Kosatka", {}, "Teleports you to your kosatka", function()
            local blip = HUD.GET_FIRST_BLIP_INFO_ID(760)

            if blip ~= 0 then
                local coords = HUD.GET_BLIP_COORDS(blip)
                ENTITY.SET_ENTITY_COORDS(script.me_ped, coords.x, coords.y, coords.z, true, true, true, true)
            end
        end),
        "cayo_perico_teleport_submarine"
    )

    -- add teleport to main gate
    script:add(
        script.cayo_perico_compound_teleports:action("Teleport To Main Gate", {}, "Teleports you to the main gate", function()
            script:TELEPORT_TO_BLIP(770)
        end),
        "cayo_perico_teleport_main_gate"
    )

    -- add teleport to drainage pipe 1st checkpoint
    script:add(
        script.cayo_perico_island_teleports:action("Drainage Pipe 1st Checkpoint", {}, "Teleports you to the 1st drainage pipe checkpoints", function()
            script:TELEPORT(5044.001, -5815.6426, -11.808871) -- coords are from heist control
        end),
        "cayo_perico_teleport_drainage_pipe_1"
    )

    -- add teleport to drainage pipe 2nd checkpoint
    script:add(
        script.cayo_perico_island_teleports:action("Drainage Pipe 2nd Checkpoint", {}, "Teleports you to the 2nd drainage pipe checkpoints", function()
            script:TELEPORT(5053.773, -5773.2266, -5.40778) -- coords are from heist control
        end),
        "cayo_perico_teleport_drainage_pipe_2"
    )

    -- add other divider
    script.cayo_perico:divider("Other")

    -- refresh kosatka board
    script:add(
        script.cayo_perico:action("Refresh Kosatka Planning Board", {}, "Does what it says ...", function()
            script:REFRESH_KOSATKA_BOARD()
        end),
        "cayo_perico_refresh_board"
    )

    -- add actions divider
    script.cayo_perico_useful_tools:divider("Actions")

    -- add remove drainage
    script:add(
        script.cayo_perico_useful_tools:action("Remove Drainage Pipe", {}, "Removes the drainage pipe (bypasses cutting)", function()
            for i, entity in pairs(entities.get_all_objects_as_handles()) do
                local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
                if ENTITY.DOES_ENTITY_EXIST(entity) then
                    if model:find("prop_chem_grill") then
                        entities.delete_by_handle(entity)
                    end
                end
            end
        end),
        "cayo_perico_remove_drainage"
    )

    -- add delete all cameras
    script:add(
        script.cayo_perico_useful_tools:action("Delete All Cameras", {}, "Deletes all cameras in the heist", function()
            for i, entity in pairs(entities.get_all_objects_as_handles()) do
                local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
                if model:find("cctv_cam") then
                    if ENTITY.DOES_ENTITY_EXIST(entity) then
                        entities.delete_by_handle(entity)
                    end
                end
            end
        end),
        "cayo_perico_delete_all_cameras"
    )

    -- delete elevator doors
    script:add(
        script.cayo_perico_useful_tools:action("Delete All Elevator Doors", {}, "Deletes all elevator doors in the heist", function()
            local elevators = script:CP_FIND_ALL_ELEVATORS()

            for i, e in pairs(elevators) do
                if e ~= 0 and ENTITY.DOES_ENTITY_EXIST(e) then
                    entities.delete_by_handle(e)
                end
            end
        end),
        "cayo_perico_delete_elevator_doors"
    )

    -- add kill all guards
    script:add(
        script.cayo_perico_useful_tools:action("Kill All Guards", {}, "Kills all guards in the heist", function()
            for i, entity in pairs(entities.get_all_peds_as_handles()) do
                local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
                if model:find("cartelguards") or model:find("hc_gunman") then
                    if script:REQUEST_CONTROL(entity) then
                        local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
                        local health = ENTITY.GET_ENTITY_HEALTH(entity)
                        health = health - (health - 1)
                        ENTITY.SET_ENTITY_HEALTH(entity, health)
                        PED.SET_PED_CAN_RAGDOLL(entity, true)
                        PED.SET_PED_TO_RAGDOLL(entity, 1000, 1000, 0, true, true, false)
                        ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(entity, 1, 0.0, pos.y - 2, pos.z + 2, true, true, false, true)
                    end
                end
            end
        end),
        "cayo_perico_kill_all_guards"
    )

    -- add make guards useless
    script:add(
        script.cayo_perico_useful_tools:action("Make Guards Useless", {}, "Makes all guards in the heist useless", function()
            for i, entity in pairs(entities.get_all_peds_as_handles()) do
                local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
                if model:find("cartelguards") or model:find("hc_gunman") then
                    if script:REQUEST_CONTROL(entity) then
                        local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
                        local health = ENTITY.GET_ENTITY_HEALTH(entity)

                        PED.SET_PED_CAN_RAGDOLL(entity, true)
                        PED.SET_PED_TO_RAGDOLL(entity, 1, 1, 0, true, true, false)
                        ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(entity, 1, 0.0, pos.y - 2, 0.0, true, true, false, true)
                        PED.SET_ENABLE_BOUND_ANKLES(entity, true)
                        ENTITY.SET_ENTITY_HEALTH(entity, health)
                    end
                end
            end
        end),
        "cayo_perico_make_guards_useless"
    )

    -- collect primary target
    script:add(
        script.cayo_perico_useful_tools:action("Collect Primary Target", {}, "Collects the primary target for you", function()
            local target = heists.cayo_perico.targets[script:GET_CP_HEIST_PRIMARY_TARGET()]
            local start = os.time() + 30
            local pos = ENTITY.GET_ENTITY_COORDS(script.me_ped, true)
            local ref = menu.ref_by_rel_path(script.cayo_perico_useful_tools, "Unlock All Gates (experimental)")
            local state = ref.value
            ref.value = false

            script:SET_INT_LOCAL("fm_mission_controller_2020", 27984, 5) -- CutterStage (from HC)
            script:SET_INT_LOCAL("fm_mission_controller_2020", 27985, 3) -- BitCheck (from HC)

            if target:find("Bearer Bonds") or target:find("Madrazo Files") then
                local vault = script:FIND_ENTITY_BY_PARITAL_MODEL_NAME("h4_safe_h4_01a")

                if vault ~= 0 then
                    if ENTITY.DOES_ENTITY_EXIST(vault) then
                        util.yield_once()
                        if script:REQUEST_CONTROL(vault) then
                            entities.delete_by_handle(vault)
                        else
                            util.stop_thread()
                        end
                    end
                end
            else
                local glass = script:FIND_ENTITY_BY_PARITAL_MODEL_NAME("h4_prop_h4_glass_disp_01a")

                if glass ~= 0 then
                    if ENTITY.DOES_ENTITY_EXIST(glass) then
                        util.yield_once()
                        if script:REQUEST_CONTROL(glass) then
                            entities.delete_by_handle(glass)
                        else
                            util.stop_thread()
                        end
                    end
                end
            end

            ref.value = state
            --[[menu.ref_by_rel_path(script.cayo_perico_useful_tools, "Delete All Cameras"):trigger()
            menu.ref_by_rel_path(script.cayo_perico_useful_tools, "Kill All Guards"):trigger()
            util.yield(500)
            menu.ref_by_rel_path(script.cayo_perico_useful_tools, "Kill All Guards"):trigger()]]
        end),
        "cayo_perico_collect_primary_target"
    )

    -- add teleport secondary targets to me
    script:add(
        script.cayo_perico_useful_tools:action("Bring Targets To Me", {}, "Teleports all secondary targets to you", function()
            for i, entity in pairs(entities.get_all_objects_as_handles()) do
                local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
                if NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(entity) then
                    if model:find("gold") or model:find("coke") or model:find("painting") or model:find("weed") then
                        if ENTITY.DOES_ENTITY_EXIST(entity) then
                            if script:REQUEST_CONTROL(entity) then
                                local pos = ENTITY.GET_ENTITY_COORDS(script.me_ped, true)
                                ENTITY.SET_ENTITY_COORDS(entity, pos.x, pos.y, pos.z, true, true, true, true)
                            end
                        end
                    end
                end
            end
        end),
        "cayo_perico_teleport_targets_to_me"
    )

    -- add force gates open
    script:add(
        script.cayo_perico_useful_tools:action("Force Gates Open", {}, "Unlocks all gates but prevents them from closing", function()
            local hashes = script:FIND_ALL_GATES()

            for k, gate in pairs(hashes) do
                script:CP_FORCE_UNLOCK_DOOR(gate.hash)
                OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(gate.hash, 1.5, true, true)
                OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(gate.hash, true, true, true)
            end

            script:notify("Unlocked " .. #hashes .. " gates")
        end),
        "cayo_perico_force_gates_open"
    )

    -- add force gates closed
    script:add(
        script.cayo_perico_useful_tools:action("Force Gates Closed", {}, "Locks all gates", function()
            local hashes = script:FIND_ALL_GATES()

            for k, gate in pairs(hashes) do
                OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(gate.hash, false, true, true)
                script:CP_FORCE_LOCK_DOOR(gate.hash)
                OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(gate.hash, 0.0, true, true)
            end

            script:notify("Locked " .. #hashes .. " gates")
        end),
        "cayo_perico_force_gates_closed"
    )

    -- add force unlock secondary target doors
    script:add(
        script.cayo_perico_useful_tools:action("Force Unlock Secondary Target Doors", {}, "Unlocks closest secondary target door", function()
            local hashes = script:CP_FIND_ALL_SECONDARY_TARGET_DOORS()
            local pos = ENTITY.GET_ENTITY_COORDS(script.me_ped, true)

            for i, data in pairs(hashes) do
                local ent_pos = ENTITY.GET_ENTITY_COORDS(data.entity, true)
                local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, ent_pos.x, ent_pos.y, ent_pos.z, true)

                if dist < 1 then
                    script:CP_FORCE_UNLOCK_SECONDARY_TARGET_DOOR(data.hash, 0.2)
                end
            end
        end),
        "cayo_perico_force_unlock_secondary_target_doors"
    )

    -- add instant finish (only works if there you are solo)
    script:add(
        script.cayo_perico_useful_tools:action("Instant Finish", {}, "Instantly finishes the mission", function()
            script:FORCE_SCRIPTHOST()
            script.cayo_perico_collect_primary_target:trigger() -- collect primary target
            util.yield(100)

            script:SET_INT_LOCAL("fm_mission_controller_2020", 42279 + 1, 51338752) -- from heist control
            script:SET_INT_LOCAL("fm_mission_controller_2020", 42279 + 1375 + 1, 50) -- from heist control
        end),
        "cayo_perico_instant_finish"
    )

    -- add toggles divider
    script.cayo_perico_useful_tools:divider("Toggles")

    -- collect keycards
    script:add(
        script.cayo_perico_useful_tools:toggle_loop("Auto Collect Mission Pickups", {}, "Collects mission pickups for you, such as keycards, gatekeys, vault cash (enable before entering the compound otherwise vault cash will not be collected)", function()
            for i, entity in pairs(entities.get_all_pickups_as_handles()) do
                local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
                
                if model:find("securitycard") or model:find("keys_jail") or model:find("cash") then
                    if script:REQUEST_CONTROL(entity) then
                        local pos = ENTITY.GET_ENTITY_COORDS(script.me_ped, true)
                        ENTITY.SET_ENTITY_COORDS(entity, pos.x, pos.y, pos.z, true, true, true, true)
                    end
                end
            end
        end),
        "cayo_perico_collect_keycards"
    )

    -- add disable collisions
    script:add(
        script.cayo_perico_useful_tools:toggle("Disable Collisions", {}, "Disables collisions for certain objects such as doors, gates and elevators (elevators in the office)", function(state)
            for i, entity in pairs(entities.get_all_objects_as_handles()) do
                local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))

                if model:find("elevator") or model:find("gate") or model:find("door") or model:find("chain_lock") then
                    ENTITY.SET_ENTITY_COLLISION(entity, not state, false)
                end
            end
        end),
        "cayo_perico_disable_collisions"
    )

    -- add poor guard accuracy
    script:add(
        script.cayo_perico_useful_tools:toggle("Poor Guard Accuracy", {}, "Makes guards have poor accuracy", function(state)
            local guards = {}
            for i, entity in pairs(entities.get_all_peds_as_handles()) do
                local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))

                if model:find("cartelguards") or model:find("hc_gunman") then
                    if state then
                        PED.SET_PED_ACCURACY(entity, 0)
                    else
                        PED.SET_PED_ACCURACY(entity, 100)
                    end
                end
            end
        end),
        "cayo_perico_poor_guard_accuracy"
    )

    -- add unlock all gates
    script:add(
        script.cayo_perico_useful_tools:toggle_loop("Unlock All Gates (experimental)", {}, "Unlocks doors when you are close to them", function()
            local hashes = script:FIND_ALL_GATES()
            local pos = ENTITY.GET_ENTITY_COORDS(script.me_ped, true)

            for k, v in ipairs(hashes) do
                if v.hash ~= 0 then
                    local ent_pos = ENTITY.GET_ENTITY_COORDS(v.entity, true)
                    local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, ent_pos.x, ent_pos.y, ent_pos.z, true)

                    if dist <= 0.72 then
                        script:CP_FORCE_UNLOCK_DOOR(v.hash)
                    end
                end
            end

            util.yield_once()
        end),
        "cayo_perico_unlock_all_doors"
    )

    -- add lock all gates
    script:add(
        script.cayo_perico_useful_tools:toggle_loop("Lock All Gates (experimental)", {}, "Locks all doors", function()
            local hashes = script:FIND_ALL_GATES()
            local pos = ENTITY.GET_ENTITY_COORDS(script.me_ped, true)

            for k, v in ipairs(hashes) do
                if v.hash ~= 0 then
                    script:CP_FORCE_LOCK_DOOR(v.hash)
                end
            end

            util.yield_once()
        end),
        "cayo_perico_lock_all_doors"
    )

    -- add a manager divider
    script.cayo_perico_useful_tools:divider("Manager")

    -- add gate manager to the menu
    script:add(
        script.cayo_perico_useful_tools:list("Gate Manager", {}, "Allows you to manage gates", function()
            script:notify("If you cannot find a gate in the list try moving closer to the gate", util.show_corner_help)
        end),
        "cayo_perico_gate_manager"
    )

    -- add compound to the menu
    script:add(
        script.cayo_perico_gate_manager:list("Compound", {}, "Allows you to manage gates in the compound", function()
            local compound = menu.ref_by_rel_path(script.cayo_perico_gate_manager, "Compound")
            local secondary_target_basement_door = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.SECONDARY_TARGET_BASEMENT_DOOR)
            local basement_entry_door_1 = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.BASEMENT_ENTRY_DOOR_1)
            local basement_entry_door_2 = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.BASEMENT_ENTRY_DOOR_2)
            local main_gate = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.MAIN_GATE)
            local main_gate_1 = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.MAIN_GATE_1)
            local main_gate_2 = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.MAIN_GATE_2)
            local main_gate_3 = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.MAIN_GATE_3)
            local arch_gate = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.ARCH_GATE_RIGHT)
            local arch_gate_1 = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.ARCH_GATE_LEFT)
            local arch_gate_2 = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.ARCH_GATE_RIGHT_1)
            local arch_gate_3 = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.ARCH_GATE_LEFT_1)
            local primary_target_gate = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.PRIMARY_TARGET_GATE)
            local basement_fingerprint_entry_gate = script:GET_GATE_FROM_COORDS(heists.cayo_perico.gates.BASEMENT_FINGERPRINT_ENTRY_GATE)

            if secondary_target_basement_door ~= 0 then
                local s_target = compound:list("Secondary Target Basement Door", {}, "Allows you to manage the secondary target basement door")

                s_target:divider("Info")
                s_target:readonly("Entity ID", tostring(secondary_target_basement_door.entity))
                s_target:readonly("Gate Hash", tostring(secondary_target_basement_door.hash))

                s_target:divider("Actions")
                s_target:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.SECONDARY_TARGET_BASEMENT_DOOR
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                s_target:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(secondary_target_basement_door.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(secondary_target_basement_door.hash)
                end)

                s_target:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(secondary_target_basement_door.hash)
                end)

                s_target:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(secondary_target_basement_door.hash, true)
                end)

                s_target:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(secondary_target_basement_door.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(secondary_target_basement_door.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(secondary_target_basement_door.hash, true)
                end)

                s_target:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(secondary_target_basement_door.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(secondary_target_basement_door.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(secondary_target_basement_door.hash)
                end)
            end

            if basement_entry_door_1 ~= 0 then
                local basement = compound:list("Basement Entry Door 1", {}, "Allows you to manage the basement entry door 1")

                basement:divider("Info")
                basement:readonly("Entity ID", tostring(basement_entry_door_1.entity))
                basement:readonly("Gate Hash", tostring(basement_entry_door_1.hash))

                basement:divider("Actions")
                basement:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.BASEMENT_ENTRY_DOOR_1
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                basement:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(basement_entry_door_1.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(basement_entry_door_1.hash)
                end)

                basement:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(basement_entry_door_1.hash)
                end)

                basement:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(basement_entry_door_1.hash, true)
                end)

                basement:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(basement_entry_door_1.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(basement_entry_door_1.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(basement_entry_door_1.hash, true)
                end)

                basement:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(basement_entry_door_1.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(basement_entry_door_1.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(basement_entry_door_1.hash)
                end)
            end

            if basement_entry_door_2 ~= 0 then
                local basement = compound:list("Basement Entry Door 2", {}, "Allows you to manage the basement entry door 2")

                basement:divider("Info")
                basement:readonly("Entity ID", tostring(basement_entry_door_2.entity))
                basement:readonly("Gate Hash", tostring(basement_entry_door_2.hash))

                basement:divider("Actions")
                basement:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.BASEMENT_ENTRY_DOOR_2
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                basement:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(basement_entry_door_2.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(basement_entry_door_2.hash)
                end)

                basement:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(basement_entry_door_2.hash)
                end)

                basement:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(basement_entry_door_2.hash, true)
                end)

                basement:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(basement_entry_door_2.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(basement_entry_door_2.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(basement_entry_door_2.hash, true)
                end)

                basement:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(basement_entry_door_2.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(basement_entry_door_2.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(basement_entry_door_2.hash)
                end)
            end

            if main_gate ~= 0 then
                local main = compound:list("Main Gate Left (Inner Gate)", {}, "Allows you to manage the main gate")

                main:divider("Info")
                main:readonly("Entity ID", tostring(main_gate.entity))
                main:readonly("Gate Hash", tostring(main_gate.hash))

                main:divider("Actions")
                main:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.MAIN_GATE
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                main:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(main_gate.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(main_gate.hash)
                end)

                main:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(main_gate.hash)
                end)

                main:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(main_gate.hash, true)
                end)

                main:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(main_gate.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(main_gate.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(main_gate.hash, true)
                end)

                main:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(main_gate.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(main_gate.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(main_gate.hash)
                end)
            end

            if main_gate_3 ~= 0 then
                local main = compound:list("Main Gate Right (Inner Gate)", {}, "Allows you to manage the main gate 3")

                main:divider("Info")
                main:readonly("Entity ID", tostring(main_gate_3.entity))
                main:readonly("Gate Hash", tostring(main_gate_3.hash))

                main:divider("Actions")
                main:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.MAIN_GATE_3
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                main:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(main_gate_3.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(main_gate_3.hash)
                end)

                main:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(main_gate_3.hash)
                end)

                main:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(main_gate_3.hash, true)
                end)

                main:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(main_gate_3.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(main_gate_3.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(main_gate_3.hash, true)
                end)

                main:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(main_gate_3.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(main_gate_3.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(main_gate_3.hash)
                end)
            end

            if main_gate_1 ~= 0 then
                local main = compound:list("Main Gate Right (Outer Gate)", {}, "Allows you to manage the main gate 1")

                main:divider("Info")
                main:readonly("Entity ID", tostring(main_gate_1.entity))
                main:readonly("Gate Hash", tostring(main_gate_1.hash))

                main:divider("Actions")
                main:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.MAIN_GATE_1
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                main:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(main_gate_1.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(main_gate_1.hash)
                end)

                main:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(main_gate_1.hash)
                end)

                main:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(main_gate_1.hash, true)
                end)

                main:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(main_gate_1.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(main_gate_1.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(main_gate_1.hash, true)
                end)

                main:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(main_gate_1.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(main_gate_1.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(main_gate_1.hash)
                end)
            end

            if main_gate_2 ~= 0 then
                local main = compound:list("Main Gate Left (Outer Gate)", {}, "Allows you to manage the main gate 2")

                main:divider("Info")
                main:readonly("Entity ID", tostring(main_gate_2.entity))
                main:readonly("Gate Hash", tostring(main_gate_2.hash))

                main:divider("Actions")
                main:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.MAIN_GATE_2
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                main:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(main_gate_2.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(main_gate_2.hash)
                end)

                main:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(main_gate_2.hash)
                end)

                main:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(main_gate_2.hash, true)
                end)

                main:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(main_gate_2.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(main_gate_2.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(main_gate_2.hash, true)
                end)

                main:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(main_gate_2.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(main_gate_2.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(main_gate_2.hash)
                end)
            end

            if primary_target_gate ~= 0 then
                local primary = compound:list("Primary Target Gate", {}, "Allows you to manage the primary target gate")

                primary:divider("Info")
                primary:readonly("Entity ID", tostring(primary_target_gate.entity))
                primary:readonly("Gate Hash", tostring(primary_target_gate.hash))

                primary:divider("Actions")
                primary:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.PRIMARY_TARGET_GATE
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                primary:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(primary_target_gate.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(primary_target_gate.hash)
                end)

                primary:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(primary_target_gate.hash)
                end)

                primary:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(primary_target_gate.hash, true)
                end)

                primary:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(primary_target_gate.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(primary_target_gate.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(primary_target_gate.hash, true)
                end)

                primary:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(primary_target_gate.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(primary_target_gate.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(primary_target_gate.hash)
                end)
            end

            if basement_fingerprint_entry_gate ~= 0 then
                local basement = compound:list("Basement Fingerprint Entry Gate", {}, "Allows you to manage the basement fingerprint entry gate")

                basement:divider("Info")
                basement:readonly("Entity ID", tostring(basement_fingerprint_entry_gate.entity))
                basement:readonly("Gate Hash", tostring(basement_fingerprint_entry_gate.hash))

                basement:divider("Actions")
                basement:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.BASEMENT_FINGERPRINT_ENTRY_GATE
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                basement:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(basement_fingerprint_entry_gate.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(basement_fingerprint_entry_gate.hash)
                end)

                basement:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(basement_fingerprint_entry_gate.hash)
                end)

                basement:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(basement_fingerprint_entry_gate.hash, true)
                end)

                basement:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(basement_fingerprint_entry_gate.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(basement_fingerprint_entry_gate.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(basement_fingerprint_entry_gate.hash, true)
                end)

                basement:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(basement_fingerprint_entry_gate.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(basement_fingerprint_entry_gate.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(basement_fingerprint_entry_gate.hash)
                end)
            end

            if arch_gate ~= 0 then
                local arch = compound:list("Arch Gate Left (Left Side)", {}, "Allows you to manage the arch gate")

                arch:divider("Info")
                arch:readonly("Entity ID", tostring(arch_gate.entity))
                arch:readonly("Gate Hash", tostring(arch_gate.hash))

                arch:divider("Actions")
                arch:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.ARCH_GATE_RIGHT
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                arch:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(arch_gate.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(arch_gate.hash)
                end)

                arch:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(arch_gate.hash)
                end)

                arch:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(arch_gate.hash, true)
                end)

                arch:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(arch_gate.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(arch_gate.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(arch_gate.hash, true)
                end)

                arch:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(arch_gate.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(arch_gate.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(arch_gate.hash)
                end)
            end

            if arch_gate_1 ~= 0 then
                local arch_1 = compound:list("Arch Gate Right (Left Side)", {}, "Allows you to manage the arch gate 1")

                arch_1:divider("Info")
                arch_1:readonly("Entity ID", tostring(arch_gate_1.entity))
                arch_1:readonly("Gate Hash", tostring(arch_gate_1.hash))

                arch_1:divider("Actions")
                arch_1:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.ARCH_GATE_LEFT
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                arch_1:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(arch_gate_1.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(arch_gate_1.hash)
                end)

                arch_1:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(arch_gate_1.hash)
                end)

                arch_1:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(arch_gate_1.hash, true)
                end)

                arch_1:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(arch_gate_1.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(arch_gate_1.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(arch_gate_1.hash, true)
                end)

                arch_1:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(arch_gate_1.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(arch_gate_1.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(arch_gate_1.hash)
                end)
            end

            if arch_gate_2 ~= 0 then
                local arch_2 = compound:list("Arch Gate Left (Right Side)", {}, "Allows you to manage the arch gate 2")

                arch_2:divider("Info")
                arch_2:readonly("Entity ID", tostring(arch_gate_2.entity))
                arch_2:readonly("Gate Hash", tostring(arch_gate_2.hash))

                arch_2:divider("Actions")
                arch_2:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.ARCH_GATE_RIGHT_1
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                arch_2:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(arch_gate_2.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(arch_gate_2.hash)
                end)

                arch_2:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(arch_gate_2.hash)
                end)

                arch_2:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(arch_gate_2.hash, true)
                end)

                arch_2:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(arch_gate_2.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(arch_gate_2.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(arch_gate_2.hash, true)
                end)

                arch_2:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(arch_gate_2.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(arch_gate_2.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(arch_gate_2.hash)
                end)
            end

            if arch_gate_3 ~= 0 then
                local arch_3 = compound:list("Arch Gate Right (Right Side)", {}, "Allows you to manage the arch gate 3")

                arch_3:divider("Info")
                arch_3:readonly("Entity ID", tostring(arch_gate_3.entity))
                arch_3:readonly("Gate Hash", tostring(arch_gate_3.hash))

                arch_3:divider("Actions")
                arch_3:action("Teleport", {}, "Teleport you to the gate", function()
                    local pos = heists.cayo_perico.gates.ARCH_GATE_LEFT_1
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                end)
                
                arch_3:toggle_loop("Unlock", {}, "Unlock the gate", function()
                    script:CP_FORCE_UNLOCK_DOOR(arch_gate_3.hash)
                end,
                function()
                    script:CP_FORCE_LOCK_DOOR(arch_gate_3.hash)
                end)

                arch_3:toggle_loop("Lock", {}, "Lock the gate", function()
                    script:CP_FORCE_LOCK_DOOR(arch_gate_3.hash)
                end)

                arch_3:toggle_loop("Remove Spring", {}, "Removes the spring from the gate preventing it from moving", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(arch_gate_3.hash, true)
                end)

                arch_3:action("Force Open", {}, "Forces the gate open, use this if unlock doesn\'t work", function()
                    script:CP_FORCE_UNLOCK_DOOR(arch_gate_3.hash)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(arch_gate_3.hash, 1.0, false, true)
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(arch_gate_3.hash, true)
                end)

                arch_3:action("Force Lock", {}, "Forces the gate closed, use this if lock doesn\'t work", function()
                    OBJECT.DOOR_SYSTEM_SET_SPRING_REMOVED(arch_gate_3.hash, false)
                    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(arch_gate_3.hash, 0.0, false, true)
                    script:CP_FORCE_LOCK_DOOR(arch_gate_3.hash)
                end)
            end

            script:notify("Found " .. tostring(#compound:getChildren()) .. "/" .. "13 gates")
        end,
        function()
            local compound = menu.ref_by_rel_path(script.cayo_perico_gate_manager, "Compound")
            local children = compound:getChildren()

            for i, child in pairs(children) do
                child:delete()
            end
        end),
        "cayo_perico_gate_manager_compound"
    )

    -- add blip manager
    script:add(
        script.cayo_perico_useful_tools:list("Blip Manager", {}, "Allows you to manage blips"),
        "cayo_perico_blip_manager"
    )

    -- add drainage pipe
    script:add(
        script.cayo_perico_blip_manager:list("Drainage Pipe", {}, "Allows you to manage the drainage pipe", function()
            local drainage = menu.ref_by_rel_path(script.cayo_perico_blip_manager, "Drainage Pipe")
            for i, child in pairs(drainage:getChildren()) do
                child:delete()
            end

            local blips = script:CP_FIND_BLIPS_BY_ID(768)

            drainage:divider("Info")
            
            for i, blip in pairs(blips) do

            end
        end),
        "cayo_perico_drainage_pipe_blip"
    )

    -- add actions divider
    script.cayo_perico_trolling_tools:divider("Actions")

    -- uninstall primary target from existence
    script:add(
        script.cayo_perico_trolling_tools:action("Uninstall Primary Target", {}, "Uninstalls the primary target from existence", function()
            local glass = script:FIND_ENTITY_BY_PARITAL_MODEL_NAME("glass_disp")
            local vault = script:FIND_ENTITY_BY_PARITAL_MODEL_NAME("h4_safe")

            if glass ~= 0 and ENTITY.DOES_ENTITY_EXIST(glass) then
                if script:REQUEST_CONTROL(glass) then
                    entities.delete_by_handle(glass)
                end
            end

            if vault ~= 0 and ENTITY.DOES_ENTITY_EXIST(vault) then
                if script:REQUEST_CONTROL(vault) then
                    entities.delete_by_handle(vault)
                end
            end

            local blip = HUD.GET_FIRST_BLIP_INFO_ID(765)

            repeat
                blip = HUD.GET_NEXT_BLIP_INFO_ID(765)
                util.yield_once()
            until blip ~= 0
            
            if blip ~= 0 then
                local pos = ENTITY.GET_ENTITY_COORDS(script.me_ped, true)
                local entity = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)

                if entity ~= 0 and ENTITY.DOES_ENTITY_EXIST(entity) then
                    if script:REQUEST_CONTROL(entity) then
                        entities.delete_by_handle(entity)
                        script:notify("Uninstalled primary target")
                    end
                else
                    script:notify("Already uninstalled")
                end
            else
                script:notify("Already uninstalled")
            end
        end),
        "cayo_perico_uninstall_primary_target"
    )

    -- uninstall gate key from existence
    script:add(
        script.cayo_perico_trolling_tools:action("Uninstall Gate Key", {}, "Uninstalls the gate key from existence", function()
            local key = script:FIND_ENTITY_BY_PARITAL_MODEL_NAME("key", "pickups")

            if key ~= 0 and ENTITY.DOES_ENTITY_EXIST(key) then
                entities.delete_by_handle(key)
                script:notify("Uninstalled gate key")
            else
                script:notify("Already uninstalled")
            end
        end),
        "cayo_perico_uninstall_gate_key"
    )

    -- uninstall keycards from existence
    script:add(
        script.cayo_perico_trolling_tools:action("Uninstall Keycards", {}, "Uninstalls the keycards from existence", function()
            local cards = script:FIND_ALL_SECURITY_KEYCARDS()

            for i, card in pairs(cards) do
                if card ~= 0 and ENTITY.DOES_ENTITY_EXIST(card) then
                    if script:REQUEST_CONTROL(card) then
                        entities.delete_by_handle(card)
                        script:notify("Uninstalled " .. i .. "/" .. #cards .. " keycards")
                    end
                end
            end
        end),
        "cayo_perico_uninstall_keycars"
    )

    -- uninstall vault cash
    script:add(
        script.cayo_perico_trolling_tools:action("Uninstall Vault Cash", {}, "Uninstalls the vault cash from existence", function()
            local cash = script:FIND_ENTITY_BY_PARITAL_MODEL_NAME("cash", "pickups")

            if cash ~= 0 and ENTITY.DOES_ENTITY_EXIST(cash) then
                if script:REQUEST_CONTROL(cash) then
                    entities.delete_by_handle(cash)
                    script:notify("Uninstalled vault cash")
                end
            else
                script:notify("Already uninstalled")
            end
        end),
        "cayo_perico_uninstall_vault_cash"
    )

    -- add give guards minigun
    script:add(
        script.cayo_perico_trolling_tools:action("Give Guards Minigun", {}, "Gives the guards miniguns", function()
            script:CP_GIVE_GUARDS_MINIGUN()
            util.yield_once()
        end),
        "cayo_perico_give_guards_minigun"
    )

    -- add Toggles divider
    script.cayo_perico_trolling_tools:divider("Toggles")

    -- add immortal guards
    script:add(
        script.cayo_perico_trolling_tools:toggle_loop("Immortal Guards", {}, "Makes the guards immortal", function()
            script:CP_IMMORTAL_GUARDS(true)
        end,
        function()
            script:CP_IMMORTAL_GUARDS(false)
        end),
        "cayo_perico_immortal_guards"
    )

    -- add guards insta kill
    script:add(
        script.cayo_perico_trolling_tools:toggle("Guards Insta Kill", {}, "Makes the guards insta kill", function(state)
            if state then
                script:CP_GUARDS_DAMAGE_MODIFIER(script.MAX_INT)
            else
                script:CP_GUARDS_DAMAGE_MODIFIER(1.0)
            end
        end),
        "cayo_perico_guards_insta_kill"
    )

    -- add guards explosive ammo
    script:add(
        script.cayo_perico_trolling_tools:toggle_loop("Guards Explosive Ammo", {}, "Gives the guards explosive ammo", function()
            local vector = v3.new()
            
            script:CP_GUARDS_ITER(function(entity)
                if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(entity, vector) then
                    ENTITY.SET_ENTITY_PROOFS(entity, false, false, true, false, false, false, true, false)
                    FIRE.ADD_OWNED_EXPLOSION(entity, vector.x, vector.y, vector.z, 18, 1.0, true, false, 0.0)
                    ENTITY.SET_ENTITY_PROOFS(entity, false, false, false, false, false, false, true, false)
                end
            end)
        end),
        "cayo_perico_guards_explosive_ammo"
    )

    -- add 1 player preset to the menu
    script:add(
        script.cayo_perico_presets:list("1 Player", {}, "Presets for playing the heist with only 1 player"),
        "cayo_perico_presets_1_player"
    )

    -- add 2 player preset to the menu
    script:add(
        script.cayo_perico_presets:list("2 Players", {}, "Presets for playing the heist with 2 players"),
        "cayo_perico_presets_2_players"
    )

    -- add 3 player preset to the menu
    script:add(
        script.cayo_perico_presets:list("3 Players", {}, "Presets for playing the heist with 3 players"),
        "cayo_perico_presets_3_players"
    )

    -- add 4 player preset to the menu
    script:add(
        script.cayo_perico_presets:list("4 Players", {}, "Presets for playing the heist with 4 players"),
        "cayo_perico_presets_4_players"
    )

    -- add 1 player sapphire panther preset to the menu
    script:add(
        script.cayo_perico_presets_1_player:toggle("Sapphire Panther", {}, "Sapphire Panther preset for 1 player (2.5m)", function(state)
            if state then
                script:CP_SETUP_PRESET(5) -- 5 = sappphire panther

                while menu.ref_by_rel_path(script.cayo_perico_presets_1_player, "Sapphire Panther").value do
                    memory.write_int(heists.globals.cayo_perico.panther_statue_value, script:CP_CALCULATE_PLAYER_TAKE(1))
                    script:CP_SET_PLAYER_CUT(1, 100) -- set player cut to 100%
                    util.yield_once()
                end
            else
                memory.write_int(heists.globals.cayo_perico.panther_statue_value, heists.cayo_perico.PANTHER_DEFAULT) -- set back to default
            end
        end),
        "cayo_perico_presets_1_player_sapphire_panther"
    )

    -- add 1 player madrazo files preset to the menu
    script:add(
        script.cayo_perico_presets_1_player:toggle("Madrazo Files", {}, "Madrazo Files preset for 1 player (2.5m)", function(state)
            if state then
                script:CP_SETUP_PRESET(4) -- 4 = madrazo files

                while menu.ref_by_rel_path(script.cayo_perico_presets_1_player, "Madrazo Files").value do
                    memory.write_int(heists.globals.cayo_perico.madrazo_files_value, script:CP_CALCULATE_PLAYER_TAKE(1))
                    script:CP_SET_PLAYER_CUT(1, 100) -- set player cut to 100%
                    util.yield_once()
                end
            else
                memory.write_int(heists.globals.cayo_perico.madrazo_files_value, heists.cayo_perico.MADRAZO_DEFAULT) -- set back to default
            end
        end),
        "cayo_perico_presets_1_player_madrazo_files"
    )

    -- add 1 player pink diamond preset to the menu
    script:add(
        script.cayo_perico_presets_1_player:toggle("Pink Diamond", {}, "Pink Diamond preset for 1 player (2.5m)", function(state)
            if state then
                script:CP_SETUP_PRESET(3) -- 3 = pink diamond

                while menu.ref_by_rel_path(script.cayo_perico_presets_1_player, "Pink Diamond").value do
                    memory.write_int(heists.globals.cayo_perico.pink_diamond_value, script:CP_CALCULATE_PLAYER_TAKE(1))
                    script:CP_SET_PLAYER_CUT(1, 100) -- set player cut to 100%
                    util.yield_once()
                end
            else
                memory.write_int(heists.globals.cayo_perico.pink_diamond_value, heists.cayo_perico.PINK_DIAMOND_DEFAULT) -- set back to default
            end
        end),
        "cayo_perico_presets_1_player_pink_diamond"
    )

    -- add 1 player bearer bonds preset to the menu
    script:add(
        script.cayo_perico_presets_1_player:toggle("Bearer Bonds", {}, "Bearer Bonds preset for 1 player (2.5m)", function(state)
            if state then
                script:CP_SETUP_PRESET(2) -- 2 = bearer bonds

                while menu.ref_by_rel_path(script.cayo_perico_presets_1_player, "Bearer Bonds").value do
                    memory.write_int(heists.globals.cayo_perico.bearer_bonds_value, script:CP_CALCULATE_PLAYER_TAKE(1))
                    script:CP_SET_PLAYER_CUT(1, 100) -- set player cut to 100%
                    util.yield_once()
                end
            else
                memory.write_int(heists.globals.cayo_perico.bearer_bonds_value, heists.cayo_perico.BEARER_BONDS_DEFAULT) -- set back to default
            end
        end),
        "cayo_perico_presets_1_player_bearer_bonds"
    )

    -- add 1 player ruby necklace preset to the menu
    script:add(
        script.cayo_perico_presets_1_player:toggle("Ruby Necklace", {}, "Ruby Necklace preset for 1 player (2.5m)", function(state)
            if state then
                script:CP_SETUP_PRESET(1) -- 1 = ruby necklace

                while menu.ref_by_rel_path(script.cayo_perico_presets_1_player, "Ruby Necklace").value do
                    memory.write_int(heists.globals.cayo_perico.ruby_necklace_value, script:CP_CALCULATE_PLAYER_TAKE(1))
                    script:CP_SET_PLAYER_CUT(1, 100) -- set player cut to 100%
                    util.yield_once()
                end
            else
                memory.write_int(heists.globals.cayo_perico.ruby_necklace_value, heists.cayo_perico.RUBY_NECKLACE_DEFAULT) -- set back to default
            end
        end),
        "cayo_perico_presets_1_player_ruby_necklace"
    )

    -- add 1 player tequila preset to the menu
    script:add(
        script.cayo_perico_presets_1_player:toggle("Tequila", {}, "Tequila preset for 1 player (2.5m)", function(state)
            if state then
                script:CP_SETUP_PRESET(0) -- 0 = tequila

                while menu.ref_by_rel_path(script.cayo_perico_presets_1_player, "Tequila").value do
                    memory.write_int(heists.globals.cayo_perico.tequila_value, script:CP_CALCULATE_PLAYER_TAKE(1))
                    script:CP_SET_PLAYER_CUT(1, 100) -- set player cut to 100%
                    util.yield_once()
                end
            else
                memory.write_int(heists.globals.cayo_perico.tequila_value, heists.cayo_perico.TEQUILA_DEFAULT) -- set back to default
            end
        end),
        "cayo_perico_presets_1_player_tequila"
    )

    -- add 2 player sapphire panther preset to the menu
    script:add(
        script.cayo_perico_presets_2_players:toggle("Sapphire Panther", {}, "Sapphire Panther preset for 2 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(5) -- 5 = sappphire panther

                while menu.ref_by_rel_path(script.cayo_perico_presets_2_players, "Sapphire Panther").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PANTHER_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PANTHER_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85) -- set back to default
                script:CP_SET_PLAYER_CUT(2, 15) -- set back to default
            end
        end),
        "cayo_perico_presets_2_player_sapphire_panther"
    )

    -- add 2 player madrazo files preset to the menu
    script:add(
        script.cayo_perico_presets_2_players:toggle("Madrazo Files", {}, "Madrazo Files preset for 2 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(4) -- 4 = madrazo files

                while menu.ref_by_rel_path(script.cayo_perico_presets_2_players, "Madrazo Files").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.MADRAZO_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.MADRAZO_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85) -- set back to default
                script:CP_SET_PLAYER_CUT(2, 15) -- set back to default
            end
        end),
        "cayo_perico_presets_2_player_madrazo_files"
    )

    -- add 2 player pink diamond preset to the menu
    script:add(
        script.cayo_perico_presets_2_players:toggle("Pink Diamond", {}, "Pink Diamond preset for 2 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(3) -- 3 = pink diamond

                while menu.ref_by_rel_path(script.cayo_perico_presets_2_players, "Pink Diamond").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PINK_DIAMOND_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PINK_DIAMOND_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85) -- set back to default
                script:CP_SET_PLAYER_CUT(2, 15) -- set back to default
            end
        end),
        "cayo_perico_presets_2_player_pink_diamond"
    )

    -- add 2 player bearer bonds preset to the menu
    script:add(
        script.cayo_perico_presets_2_players:toggle("Bearer Bonds", {}, "Bearer Bonds preset for 2 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(2) -- 2 = bearer bonds

                while menu.ref_by_rel_path(script.cayo_perico_presets_2_players, "Bearer Bonds").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.BEARER_BONDS_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.BEARER_BONDS_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85) -- set back to default
                script:CP_SET_PLAYER_CUT(2, 15) -- set back to default
            end
        end),
        "cayo_perico_presets_2_player_bearer_bonds"
    )

    -- add 2 player ruby necklace preset to the menu
    script:add(
        script.cayo_perico_presets_2_players:toggle("Ruby Necklace", {}, "Ruby Necklace preset for 2 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(1) -- 1 = ruby necklace

                while menu.ref_by_rel_path(script.cayo_perico_presets_2_players, "Ruby Necklace").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.RUBY_NECKLACE_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.RUBY_NECKLACE_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85) -- set back to default
                script:CP_SET_PLAYER_CUT(2, 15) -- set back to default
            end
        end),
        "cayo_perico_presets_2_player_ruby_necklace"
    )

    -- add 2 player tequila preset to the menu
    script:add(
        script.cayo_perico_presets_2_players:toggle("Tequila", {}, "Tequila preset for 2 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(0) -- 0 = tequila

                while menu.ref_by_rel_path(script.cayo_perico_presets_2_players, "Tequila").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.TEQUILA_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.TEQUILA_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85) -- set back to default
                script:CP_SET_PLAYER_CUT(2, 15) -- set back to default
            end
        end),
        "cayo_perico_presets_2_player_tequila"
    )

    -- add 3 player sapphire panther preset to the menu
    script:add(
        script.cayo_perico_presets_3_players:toggle("Sapphire Panther", {}, "Sapphire Panther preset for 3 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(5) -- 5 = sapphire panther

                while menu.ref_by_rel_path(script.cayo_perico_presets_3_players, "Sapphire Panther").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PANTHER_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PANTHER_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(3, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PANTHER_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85)
                script:CP_SET_PLAYER_CUT(2, 15)
                script:CP_SET_PLAYER_CUT(3, 15)
            end
        end),
        "cayo_perico_presets_3_player_sapphire_panther"
    )

    -- add 3 player madrazo files preset to the menu
    script:add(
        script.cayo_perico_presets_3_players:toggle("Madrazo Files", {}, "Madrazo Files preset for 3 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(4) -- 4 = madrazo files

                while menu.ref_by_rel_path(script.cayo_perico_presets_3_players, "Madrazo Files").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.MADRAZO_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.MADRAZO_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(3, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.MADRAZO_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85)
                script:CP_SET_PLAYER_CUT(2, 15)
                script:CP_SET_PLAYER_CUT(3, 15)
            end
        end),
        "cayo_perico_presets_3_player_madrazo_files"
    )

    -- add 3 player pink diamond preset to the menu
    script:add(
        script.cayo_perico_presets_3_players:toggle("Pink Diamond", {}, "Pink Diamond preset for 3 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(3) -- 3 = pink diamond

                while menu.ref_by_rel_path(script.cayo_perico_presets_3_players, "Pink Diamond").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PINK_DIAMOND_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PINK_DIAMOND_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(3, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PINK_DIAMOND_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85)
                script:CP_SET_PLAYER_CUT(2, 15)
                script:CP_SET_PLAYER_CUT(3, 15)
            end
        end),
        "cayo_perico_presets_3_player_pink_diamond"
    )

    -- add 3 player bearer bonds preset to the menu
    script:add(
        script.cayo_perico_presets_3_players:toggle("Bearer Bonds", {}, "Bearer Bonds preset for 3 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(2) -- 2 = bearer bonds

                while menu.ref_by_rel_path(script.cayo_perico_presets_3_players, "Bearer Bonds").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.BEARER_BONDS_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.BEARER_BONDS_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(3, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.BEARER_BONDS_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85)
                script:CP_SET_PLAYER_CUT(2, 15)
                script:CP_SET_PLAYER_CUT(3, 15)
            end
        end),
        "cayo_perico_presets_3_player_bearer_bonds"
    )

    -- add 3 player ruby necklace preset to the menu
    script:add(
        script.cayo_perico_presets_3_players:toggle("Ruby Necklace", {}, "Ruby Necklace preset for 3 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(1) -- 1 = ruby necklace

                while menu.ref_by_rel_path(script.cayo_perico_presets_3_players, "Ruby Necklace").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.RUBY_NECKLACE_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.RUBY_NECKLACE_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(3, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.RUBY_NECKLACE_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85)
                script:CP_SET_PLAYER_CUT(2, 15)
                script:CP_SET_PLAYER_CUT(3, 15)
            end
        end),
        "cayo_perico_presets_3_player_ruby_necklace"
    )

    -- add 3 player tequila preset to the menu
    script:add(
        script.cayo_perico_presets_3_players:toggle("Tequila", {}, "Tequila preset for 3 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(0) -- 0 = tequila

                while menu.ref_by_rel_path(script.cayo_perico_presets_3_players, "Tequila").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.TEQUILA_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.TEQUILA_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(3, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.TEQUILA_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85)
                script:CP_SET_PLAYER_CUT(2, 15)
                script:CP_SET_PLAYER_CUT(3, 15)
            end
        end),
        "cayo_perico_presets_3_player_tequila"
    )

    -- add 4 player sapphire panther preset to the menu
    script:add(
        script.cayo_perico_presets_4_players:toggle("Sapphire Panther", {}, "Sapphire Panther preset for 4 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(5) -- 5 = sapphire panther

                while menu.ref_by_rel_path(script.cayo_perico_presets_4_players, "Sapphire Panther").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PANTHER_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PANTHER_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(3, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PANTHER_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(4, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PANTHER_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85)
                script:CP_SET_PLAYER_CUT(2, 15)
                script:CP_SET_PLAYER_CUT(3, 15)
                script:CP_SET_PLAYER_CUT(4, 15)
            end
        end),
        "cayo_perico_presets_4_player_sapphire_panther"
    )

    -- add 4 player madrazo files preset to the menu
    script:add(
        script.cayo_perico_presets_4_players:toggle("Madrazo Files", {}, "Madrazo Files preset for 4 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(4) -- 4 = madrazo files

                while menu.ref_by_rel_path(script.cayo_perico_presets_4_players, "Madrazo Files").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.MADRAZO_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.MADRAZO_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(3, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.MADRAZO_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(4, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.MADRAZO_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85)
                script:CP_SET_PLAYER_CUT(2, 15)
                script:CP_SET_PLAYER_CUT(3, 15)
                script:CP_SET_PLAYER_CUT(4, 15)
            end
        end),
        "cayo_perico_presets_4_player_madrazo_files"
    )

    -- add 4 player pink diamond preset to the menu
    script:add(
        script.cayo_perico_presets_4_players:toggle("Pink Diamond", {}, "Pink Diamond preset for 4 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(3) -- 3 = pink diamond

                while menu.ref_by_rel_path(script.cayo_perico_presets_4_players, "Pink Diamond").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PINK_DIAMOND_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PINK_DIAMOND_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(3, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PINK_DIAMOND_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(4, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.PINK_DIAMOND_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85)
                script:CP_SET_PLAYER_CUT(2, 15)
                script:CP_SET_PLAYER_CUT(3, 15)
                script:CP_SET_PLAYER_CUT(4, 15)
            end
        end),
        "cayo_perico_presets_4_player_pink_diamond"
    )

    -- add 4 player bearer bonds preset to the menu
    script:add(
        script.cayo_perico_presets_4_players:toggle("Bearer Bonds", {}, "Bearer Bonds preset for 4 players (2.5m per player)", function()
            if state then
                script:CP_SETUP_PRESET(2) -- 2 = Bearer Bonds

                while menu.ref_by_rel_path(script.cayo_perico_presets_4_players, "Bearer Bonds").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.BEARER_BONDS_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.BEARER_BONDS_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(3, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.BEARER_BONDS_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(4, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.BEARER_BONDS_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85)
                script:CP_SET_PLAYER_CUT(2, 15)
                script:CP_SET_PLAYER_CUT(3, 15)
                script:CP_SET_PLAYER_CUT(4, 15)
            end
        end),
        "cayo_perico_presets_4_player_bearer_bonds"
    )

    -- add 4 player ruby necklace preset to the menu
    script:add(
        script.cayo_perico_presets_4_players:toggle("Ruby Necklace", {}, "Ruby Necklace preset for 4 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(1) -- 1 = ruby necklace

                while menu.ref_by_rel_path(script.cayo_perico_presets_4_players, "Ruby Necklace").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.RUBY_NECKLACE_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.RUBY_NECKLACE_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(3, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.RUBY_NECKLACE_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(4, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.RUBY_NECKLACE_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85)
                script:CP_SET_PLAYER_CUT(2, 15)
                script:CP_SET_PLAYER_CUT(3, 15)
                script:CP_SET_PLAYER_CUT(4, 15)
            end
        end),
        "cayo_perico_presets_4_player_ruby_necklace"
    )

    -- add 4 player tequila preset to the menu
    script:add(
        script.cayo_perico_presets_4_players:toggle("Tequila", {}, "Tequila preset for 4 players (2.5m per player)", function(state)
            if state then
                script:CP_SETUP_PRESET(0) -- 0 = tequila

                while menu.ref_by_rel_path(script.cayo_perico_presets_4_players, "Tequila").value do
                    script:CP_SET_PLAYER_CUT(1, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.TEQUILA_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(2, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.TEQUILA_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(3, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.TEQUILA_DEFAULT, 2550000))
                    script:CP_SET_PLAYER_CUT(4, script:CP_CALCULATE_CUT_FOR_AMOUNT(heists.cayo_perico.TEQUILA_DEFAULT, 2550000))
                    util.yield_once()
                end
            else
                script:CP_SET_PLAYER_CUT(1, 85)
                script:CP_SET_PLAYER_CUT(2, 15)
                script:CP_SET_PLAYER_CUT(3, 15)
                script:CP_SET_PLAYER_CUT(4, 15)
            end
        end),
        "cayo_perico_presets_4_player_tequila"
    )
end

return heists