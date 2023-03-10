local nightclub = setmetatable({}, {__index = _G})
local char = util.get_char_slot()

local utils = require("lib.recovery.utils") -- require the utils module
local script = require("lib.recovery.script") -- require the script module

nightclub.value = util.joaat("MP" .. char .. "_PROP_NIGHTCLUB_VALUE") -- stat for nightclub value
nightclub.owned = util.joaat("MP" .. char .. "_NIGHTCLUB_OWNED") -- stat for owned nightclub id
nightclub.offset = 0.05
nightclub.name = "nightclub"

nightclub.globals = { -- nightclub specific globals
    prices = {
        ["La Mesa"] = script:global(262145 + 24838), -- memory.script_global(262145 + 24838)
        ["Mission Row"] = script:global(262145 + 24843), -- memory.script_global(262145 + 24843)
        ["Vespucci Canals"] = script:global(262145 + 24845) -- memory.script_global(262145 + 24845)
    },
    safe = script:global(262145 + 24045), -- memory.script_global(262145 + 24045)
    income = script:global(262145 + 24041), -- memory.script_global(262145 + 24041)
    popularity_decay = script:global(262145 + 24042), -- memory.script_global(262145 + 24042)
    popularity_per_mission = script:global(262145 + 24043), -- memory.script_global(262145 + 24043)
    income_popularity_start = 24022,
    income_popularity_end = 24041,
}

nightclub.afk_options = {
    available = {"La Mesa", "Mission Row", "Vespucci Canals"},
    total_loops = 0,
    total_earnings = 0
}

function nightclub:SELECT_INTERNET_FILTER(script)
    local xptr, yptr = memory.alloc_int(4), memory.alloc_int(4)
    GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(xptr, yptr)
    local x, y = tonumber(memory.read_int(xptr)), tonumber(memory.read_int(yptr))

    local start_x, start_y = 0.78, 0.28

    switch x do
        case 1920:
            start_x = 0.78
            start_y = 0.28
            break
        case 1680:
            start_x = 0.78 - nightclub.offset
            start_y = 0.28
            break
        case 1600:
            if y == 1024 then
                start_x = 0.78 - (nightclub.offset + 0.01)
                start_y = 0.28
            end
    
            if y == 900 then
                start_x = 0.78
                start_y = 0.28
            end
            break
        case 1440:
            start_x = 0.78 - nightclub.offset
            start_y = 0.28
            break
        case 1366:
            start_x = 0.78
            start_y = 0.28
            break
        case 1360:
            start_x = 0.78
            start_y = 0.28
            break
        case 1280:
            if y == 1024 then
                start_x = 0.78 - (nightclub.offset * 3)
                start_y = 0.28
            end
    
            if y == 960 then
                start_x = 0.78 - (nightclub.offset * 2.5)
                start_y = 0.28
            end
    
            if y == 800 then
                start_x = 0.78 - nightclub.offset
                start_y = 0.28
            end
    
            if y == 768 then
                start_x = 0.78 - (nightclub.offset / 2)
                start_y = 0.28
            end
    
            if y == 720 then
                start_x = 0.78
                start_y = 0.28
            end
            break
        case 1176:
            start_x = 0.78
            start_y = 0.28
            break
        case 1152:
            start_x = 0.78 - (nightclub.offset * 2.5)
            start_y = 0.28
            break
        case 1024:
            start_x = 0.78 - (nightclub.offset * 2.5)
            start_y = 0.28
            break
        case 800:
            start_x = 0.78 - (nightclub.offset * 2.5)
            start_y = 0.28
            break
        default:
            start_x = 0.78
            start_y = 0.28
            break
    end

    utils:MOVE_CURSOR(start_x, start_y, script.delays.PURCHASE.SELECT_FILTER_DELAY, true) -- select the internet filter
end

function nightclub:init(script)
    local press_counter = 2 -- the number of times enter will be pressed
    -- add la mesa nightclub
    nightclub["La Mesa"] = {
        name = "La Mesa",
        purchase = function()
            utils:MOVE_CURSOR(0.69, 0.58, script.delays.PURCHASE.BUY_FROM_DELAY, true) -- select the nightclub
            utils:MOVE_CURSOR(0.30, 0.73, script.delays.PURCHASE.BUY_BUTTON_DELAY, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.93, script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, script.delays.PURCHASE.TRADE_IN_SELECTION_DELAY, true) -- press the third buy butwton
            utils:SIMULATE_CONTROL_KEY(176, press_counter) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, press_counter, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:RETURN_TO_MAP(nightclub) -- return to the map
        end
    }

    -- add mission row nightclub
    nightclub["Mission Row"] = {
        name = "Mission Row",
        purchase = function()
            utils:MOVE_CURSOR(0.64, 0.51, script.delays.PURCHASE.BUY_FROM_DELAY, true) -- select the nightclub
            utils:MOVE_CURSOR(0.30, 0.73, script.delays.PURCHASE.BUY_BUTTON_DELAY, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.93, script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, script.delays.PURCHASE.TRADE_IN_SELECTION_DELAY, true) -- press the third buy butwton
            utils:SIMULATE_CONTROL_KEY(176, press_counter) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, press_counter, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:RETURN_TO_MAP(nightclub) -- return to the map
        end
    }

    -- add vespucci canals nightclub
    nightclub["Vespucci Canals"] = {
        name = "Vespucci Canals",
        purchase = function()
            utils:MOVE_CURSOR(0.479, 0.54, script.delays.PURCHASE.BUY_FROM_DELAY, true) -- select the nightclub
            utils:MOVE_CURSOR(0.30, 0.73, script.delays.PURCHASE.BUY_BUTTON_DELAY, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.93, script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, script.delays.PURCHASE.TRADE_IN_SELECTION_DELAY, true) -- press the third buy button
            utils:SIMULATE_CONTROL_KEY(176, press_counter) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, press_counter, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:RETURN_TO_MAP(nightclub) -- return to the map
        end
    }

    -- add nightclub recovery option to the menu
    script:add(
        script.root:list("Nightclub", {"rsnightclub"}, "Nightclub recovery options", function()
            local ref = menu.ref_by_rel_path(script.root, "Nightclub")
            local owned_data = script:GET_OWNED_PROPERTY_DATA("nightclub")
            
            if owned_data == nil then
                ref:focus() -- prevent access
                script:notify("You do not own a nightclub, purchase a nightclub to access this feature")
                return
            end

            script:SHOW_REQUIREMENTS_WARNING() -- show the requirements warning
        end),
        "nightclub_recovery"
    )
    
    script.nightclub_recovery:divider("1B Recovery")

    script:add(
        script.nightclub_recovery:list("Presets", {"rsncpresets"}, "Presets for 1B Recovery"),
        "nightclub_presets"
    )

    script:add(
        script.nightclub_recovery:list("Custom", {"rsnccustom"}, "Customisable options for 1B Recovery"),
        "nightclub_custom"
    )

    script.nightclub_recovery:divider("Nightclub Safe")

    script:add(
        script.nightclub_recovery:action("Teleport To Nightclub", {"rstpnightclub"}, "Teleports to your nightclub", function()
            local nightclub_blip = HUD.GET_FIRST_BLIP_INFO_ID(script.blips.NIGHTCLUB) -- get the nightclub blip

            if HUD.DOES_BLIP_EXIST(nightclub_blip) then -- check if the blip exists on the map
                local pos = HUD.GET_BLIP_INFO_ID_COORD(nightclub_blip) -- get the coordinates of the blip
                ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z) -- teleport to the coordinates
            else
                script:notify("Nightclub blip not found")
            end
        end),
        "nightclub_teleport"
    )

    script:add(
        script.nightclub_recovery:action("Trigger Production", {"rsncsafe_triggerprod"}, "Triggers production at your nightclub", function()
            nightclub.globals.safe:write_int(300000) -- set the maximum amount of money the safe can hold
            nightclub.globals.income:write_int(300000) -- set the amount of income to maximum
            script:packed_global(nightclub.globals.income_popularity_start, nightclub.globals.income_popularity_end):write_int(300000)

            script:STAT_SET_INT("CLUB_PAY_TIME_LEFT", 1, true) -- set the time left to 1 second
            script:STAT_SET_INT("CLUB_POPULARITY", 10000, true) -- set the popularity to 10000
        end),
        "nightclub_trigger_production"
    )

    script:add(
        script.nightclub_recovery:action("Open Nightclub Screen", {"rsnc_manager"}, "Opens the nightclub management screen", function()
            script:START_SCRIPT("appbusinesshub")
        end),
        "nightclub_open_screen"
    )

    script:add(
        script.nightclub_recovery:toggle_loop("Fuck Popularity", {"rsfuckpopularity"}, "Stops popularity affecting your safe income", function()
            script:packed_global(nightclub.globals.income_popularity_start, nightclub.globals.income_popularity_end):write_int(300000)
        end,
        function()
            script:global(262145 + 24022):write_int(1500)
            script:global(262145 + 24023):write_int(1600)
            script:global(262145 + 24024):write_int(1800)
            script:global(262145 + 24025):write_int(2000)
            script:global(262145 + 24026):write_int(2200)
            script:global(262145 + 24027):write_int(2500)
            script:global(262145 + 24028):write_int(8000)
            script:global(262145 + 24029):write_int(8500)
            script:global(262145 + 24030):write_int(9000)
            script:global(262145 + 24031):write_int(9500)
            script:global(262145 + 24032):write_int(10000)
            script:global(262145 + 24033):write_int(20000)
            script:global(262145 + 24034):write_int(21000)
            script:global(262145 + 24035):write_int(22000)
            script:global(262145 + 24036):write_int(23000)
            script:global(262145 + 24037):write_int(24000)
            script:global(262145 + 24038):write_int(25000)
            script:global(262145 + 24039):write_int(45000)
            script:global(262145 + 24040):write_int(50000)
            script:global(262145 + 24041):write_int(50000)
        end),
        "nightclub_fuck_popularity"
    )

    script:add(
        script.nightclub_recovery:toggle_loop("Anti Popularity Decay", {"rsncantidecay"}, "Prevents your nightclub from losing popularity", function()
            nightclub.globals.popularity_decay:write_float(script.MAX_INT) -- reverse the popularity decay so popularity increases
        end,
        function()
            nightclub.globals.popularity_decay:write_float(-0.1) -- set the popularity decay to default
        end),
        "nightclub_disable_popularity_decay"
    )

    script:add(
        script.nightclub_recovery:toggle_loop("Fill Safe", {"rsncfillsafe"}, "Fills your nightclub safe", function()
            menu.trigger_command(script.nightclub_trigger_production) -- trigger production
        end),
        "nightclub_fill_safe"
    )

    script:add(
        script.nightclub_recovery:toggle_loop("AFK Loop", {"rsncsafeloop"}, "AFK Money Loop", function()
            local fill = script.nightclub_fill_safe
            local afk = menu.ref_by_rel_path(script.nightclub_recovery, "AFK Loop")

            if not script:IS_INSIDE_OF_INTERIOR("nightclub") then
                script:notify("You are not inside of your nightclub")
                afk.value = false
                return
            end

            fill.value = true

            if not script:TRANSACTION_ERROR_DISPLAYED() then
                if not script.states.nightclub.safe_open then
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, -1615.5490722656, -3015.6804199219, -75.205093383789)
                    utils:SIMULATE_CONTROL_KEY(51, 1)
                    script.states.nightclub.safe_open = true
                    util.yield(8000)
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, -1615.6691894531, -3015.728515625, -75.205001831055)
                else
                    if not script.states.nightclub.infront_of_safe then
                        ENTITY.SET_ENTITY_COORDS(script.me_ped, -1615.6691894531, -3015.728515625, -75.205001831055)
                        script.states.nightclub.infront_of_safe = true
                        util.yield(3000)
                    else
                        ENTITY.SET_ENTITY_COORDS(script.me_ped, -1618.3752441406, -3011.5810546875, -75.205078125)
                        util.yield(1000)
                        ENTITY.SET_ENTITY_COORDS(script.me_ped, -1615.6691894531, -3015.728515625, -75.205001831055)
                    end
                end
            end
        end,
        function()
            local fill = script.nightclub_fill_safe
            fill.value = false
            
            util.yield(1000)
            utils:SIMULATE_CONTROL_KEY(51, 1)
            script.states.nightclub.safe_open = false
            script.states.nightclub.infront_of_safe = false
        end),
        "nightclub_safe_afk_loop"
    )

    -- add options divider
    script.nightclub_presets:divider("Options")

    -- add the nightclub presets
    script:add(
        script.nightclub_presets:list_select("Money", {"rsncpmoney"}, "Setting this does not change the amount you get from the afk loop", script.money_options, 1, function() end),
        "nightclub_presets_money"
    )

    -- add buy nightclub
    script:add(
        script.nightclub_presets:action("Buy Nightclub", {"rspbuync"}, "Automatically buys a nightclub for you", function()
            local owned_data = script:GET_OWNED_PROPERTY_DATA("nightclub")
            local club = nightclub.afk_options.available[math.random(#nightclub.afk_options.available)]
            local value = script:CONVERT_VALUE(script.money_options[script.nightclub_presets_money.value])

            while owned_data.name == club do
                club = nightclub.afk_options.available[math.random(#nightclub.afk_options.available)]
                util.yield()
            end

            utils:OPEN_INTERNET(script, 300, true)
            nightclub:SELECT_INTERNET_FILTER(script)
            script:PURCHASE_PROPERTY(nightclub, club, true, value)
        end),
        "nightclub_presets_buy"
    )

    -- add set value
    script:add(
        script.nightclub_presets:action("Set Value", {"rspncsetval"}, "Sets the value of your nightclub (this is for manual purchases)", function()
            local money = script:CONVERT_VALUE(script.money_options[script.nightclub_presets_money.value])
            local current_value = script:STAT_GET_INT("PROP_NIGHTCLUB_VALUE")
            
            if current_value > 0 then
                script:STAT_SET_INT("PROP_NIGHTCLUB_VALUE", (money + current_value + 400000) * 2, true)
            else
                script:STAT_SET_INT("PROP_NIGHTCLUB_VALUE", (money + 15000000) * 2, true)
            end
        end),
        "nightclub_presets_set_value"
    )

    -- add loop set value
    script:add(
        script.nightclub_presets:toggle_loop("Loop Set Value", {"rsncpsetvalloop"}, "Does the same as set value but instead of setting it once it sets it repeatedly", function()
            local afk = menu.ref_by_rel_path(script.nightclub_presets, "AFK Loop")
            local loop_set = menu.ref_by_rel_path(script.nightclub_presets, "Loop Set Value")

            if not afk.value then
                menu.trigger_command(script.nightclub_presets_set_value) -- call set value button
                util.yield(500) -- wait before setting it again
            else
                loop_set.value = false
            end
        end),
        "nightclub_presets_loop_set_value"
    )

    -- add divider for afk loop
    script.nightclub_presets:divider("AFK Money Loop")

    script:add(
        script.nightclub_presets:toggle("Override Value", {"rsncpoverride"}, "Overrides the afk loop value from 1.07B to the choice selected in money under options", function()
        
        end),
        "nightclub_presets_override_value"
    )

    -- block phone calls
    script:add(
        script.nightclub_presets:toggle("Block Phone Calls", {"rsncp_blockcalls"}, "Blocks incoming phones calls", function(state)
            local phone_calls = menu.ref_by_command_name("nophonespam")
            phone_calls.value = state
        end),
        "nightclub_presets_block_phone_calls"
    )

    -- add afk loop option
    script:add(
        script.nightclub_presets:toggle_loop("AFK Loop", {"rsncploop"}, "Alternates between buying nightclubs you don\'t own, the value is set to the max (" .. tostring(math.floor(script.MAX_INT / 2)) .. ")", function(state)
            local afk = menu.ref_by_rel_path(script.nightclub_presets, "AFK Loop")
            local owned_data = script:GET_OWNED_PROPERTY_DATA("nightclub")
            local club = nightclub.afk_options.available[math.random(#nightclub.afk_options.available)]
            local override = menu.ref_by_rel_path(script.nightclub_presets, "Override Value")
            local loop_delay = menu.ref_by_rel_path(script.nightclub_presets, "Loop Delay")
            local loops = menu.ref_by_rel_path(script.nightclub_presets, "Loops")
            local money_value = (script:CONVERT_VALUE(script.money_options[script.nightclub_presets_money.value]))

            if not afk.value then util.stop_thread() end

            if not override.value then
                money_value = script.MAX_INT
            end

            if loops.value > 0 then
                if nightclub.afk_options.total_loops >= loops.value then
                    afk.value = false
                    util.stop_thread()
                end
            end

            if not script:IS_SCREEN_OPEN() then 
                utils:OPEN_INTERNET(script, 200)
                nightclub:SELECT_INTERNET_FILTER(script) 
            end

            script:PURCHASE_PROPERTY(nightclub, club, false, money_value)
            nightclub.afk_options.total_loops = nightclub.afk_options.total_loops + 1
            nightclub.afk_options.total_earnings = nightclub.afk_options.total_earnings + money_value
            util.yield(loop_delay.value)
        end,
        function()
            nightclub.afk_options.total_loops = 0
            nightclub.afk_options.total_earnings = 0
        end),
        "nightclub_presets_afk_loop"
    )

    -- add divider for loop options
    script.nightclub_presets:divider("Loop Options")

    -- add loop delay option
    script:add(
        script.nightclub_presets:slider("Loop Delay", {"rsncploopdelay"}, "The delay between each loop", 0, script.MAX_INT, 100, 100, function() end),
        "nightclub_presets_loop_delay"
    )

    -- add loop count option
    script:add(
        script.nightclub_presets:slider("Loops", {"rsncploops"}, "The amount of loops to do before stopping", 0, script.MAX_INT, 0, 1, function() end),
        "nightclub_presets_loop_count"
    )

    -- add options for custom
    script:add(
        script.nightclub_custom:text_input("Money", {"rsnccmoney"}, "The nightclub value", function(value)
            value = tonumber(value) -- ensure that the value is a number
            
            if value ~= nil then -- prevents an error when stopping the script
                if value >= 0 then
                    script:STAT_SET_INT("PROP_NIGHTCLUB_VALUE", value, true)
                else
                    script:notify("Invalid value, must be greater than 0")
                end
            end
        end),
        "nightclub_custom_money"
    )

    -- add buy nightclub option to custom (works the same as the presets)
    script:add(
        script.nightclub_custom:action("Buy Nightclub", {"rscbuync"}, "Automatically buys a nightclub for you", function()
            local owned_data = script:GET_OWNED_PROPERTY_DATA("nightclub")
            local club = nightclub.afk_options.available[math.random(#nightclub.afk_options.available)]
            local value = tonumber(script.nightclub_custom_money.value)

            while owned_data.name == club do
                club = nightclub.afk_options.available[math.random(#nightclub.afk_options.available)]
                util.yield()
            end

            utils:OPEN_INTERNET(script, 200, true)
            nightclub:SELECT_INTERNET_FILTER(script)
            script:PURCHASE_PROPERTY(nightclub, club, true, value)
        end),
        "nightclub_custom_buy"
    )

    -- add divider for afk loop
    script.nightclub_custom:divider("AFK Money Loop")

    -- add block phone calls option
    script:add(
        script.nightclub_custom:toggle("Block Phone Calls", {"rsblockcalls"}, "Blocks incoming phones calls", function(state)
            local phone_calls = menu.ref_by_command_name("nophonespam")
            phone_calls.value = state
        end),
        "nightclub_custom_block_phone_calls"
    )

    -- add afk loop option
    script:add(
        script.nightclub_custom:toggle_loop("AFK Loop", {"rsnccloop"}, "Alternates between buying nightclubs you don\'t own, the value is set to the max (" .. tostring(math.floor(script.MAX_INT / 2)) .. ")", function(state)
            local afk = menu.ref_by_rel_path(script.nightclub_custom, "AFK Loop")
            local club = nightclub.afk_options.available[math.random(#nightclub.afk_options.available)]
            local loop_delay = menu.ref_by_rel_path(script.nightclub_custom, "Loop Delay")
            local loops = menu.ref_by_rel_path(script.nightclub_custom, "Loops")
            local money_value = tonumber(script.nightclub_custom_money.value)

            if not afk.value then util.stop_thread() end

            if loops.value > 0 then
                if nightclub.afk_options.total_loops >= loops.value then
                    afk.value = false
                    util.stop_thread()
                end
            end

            if not script:IS_SCREEN_OPEN() then
                utils:OPEN_INTERNET(script, 200)
                nightclub:SELECT_INTERNET_FILTER(script)
            end

            script:PURCHASE_PROPERTY(nightclub, club, false, money_value)
            nightclub.afk_options.total_loops = nightclub.afk_options.total_loops + 1
            nightclub.afk_options.total_earnings = nightclub.afk_options.total_earnings + money_value
            util.yield(loop_delay.value)
        end,
        function()
            nightclub.afk_options.total_loops = 0
            nightclub.afk_options.total_earnings = 0
        end),
        "nightclub_custom_afk_loop"
    )

    -- add divider for loop options
    script.nightclub_custom:divider("Loop Options")

    -- add loop delay option
    script:add(
        script.nightclub_custom:slider("Loop Delay", {"rscncloopdelay"}, "The delay between each loop", 0, script.MAX_INT, 100, 100, function() end),
        "nightclub_custom_loop_delay"
    )

    -- add loop count option
    script:add(
        script.nightclub_custom:slider("Loops", {"rscncloops"}, "The amount of loops to do before stopping", 0, script.MAX_INT, 0, 1, function() end),
        "nightclub_custom_loop_count"
    )
end

return nightclub