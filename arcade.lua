local arcade = setmetatable({}, {__index = _G})
local char = util.get_char_slot()

local utils = require("lib.recovery.utils")

arcade.value = util.joaat("MP" .. char .. "_PROP_ARCADE_VALUE") -- stat for arcade value
arcade.owned = util.joaat("MP" .. char .. "_ARCADE_OWNED") -- stat for owned arcade id
arcade.offset = 0.05
arcade.name = "arcade"

arcade.globals = { -- arcade specific globals
    prices = {
        ["La Mesa"] = memory.script_global(262145 + 28441),
        ["Davis"] = memory.script_global(262145 + 28439),
        ["Eight Bit"] = memory.script_global(262145 + 28444)
    },
    safe = memory.script_global(262145 + 29250),
    income = memory.script_global(262145 + 29252),
}

arcade.afk_options = {
    available = {"La Mesa", "Eight Bit", "Davis"},    
    total_loops = 0,
    total_earnings = 0
}

function arcade:SELECT_INTERNET_FILTER(script)
    local xptr, yptr = memory.alloc_int(4), memory.alloc_int(4)
    GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(xptr, yptr)
    local x, y = tonumber(memory.read_int(xptr)), tonumber(memory.read_int(yptr))

    local start_x, start_y = 0.86, 0.28

    switch x do
        case 1920:
            start_x = 0.86
            start_y = 0.28
            break
        case 1680:
            start_x = 0.86 - arcade.offset
            start_y = 0.28
            break
        case 1600:
            if y == 1024 then
                start_x = 0.86 - (arcade.offset + 0.01)
                start_y = 0.28
            end
    
            if y == 900 then
                start_x = 0.86
                start_y = 0.28
            end
            break
        case 1440:
            start_x = 0.86 - arcade.offset
            start_y = 0.28
            break
        case 1366:
            start_x = 0.86
            start_y = 0.28
            break
        case 1360:
            start_x = 0.86
            start_y = 0.28
            break
        case 1280:
            if y == 1024 then
                start_x = 0.86 - (arcade.offset * 3)
                start_y = 0.28
            end
    
            if y == 960 then
                start_x = 0.86 - (arcade.offset * 2.5)
                start_y = 0.28
            end
    
            if y == 800 then
                start_x = 0.86 - arcade.offset
                start_y = 0.28
            end
    
            if y == 768 then
                start_x = 0.86 - (arcade.offset / 2)
                start_y = 0.28
            end
    
            if y == 720 then
                start_x = 0.86
                start_y = 0.28
            end
            break
        case 1176:
            start_x = 0.86
            start_y = 0.28
            break
        case 1152:
            start_x = 0.86 - (arcade.offset * 2.5)
            start_y = 0.28
            break
        case 1024:
            start_x = 0.86 - (arcade.offset * 2.5)
            start_y = 0.28
            break
        case 800:
            start_x = 0.86 - (arcade.offset * 2.5)
            start_y = 0.28
            break
        default:
            start_x = 0.86
            start_y = 0.28
            break
    end

    utils:MOVE_CURSOR(start_x, start_y, script.delays.PURCHASE.SELECT_FILTER_DELAY, true) -- select the internet filter
    utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to select the internet filter
end

function arcade:init(script)
    local press_counter = 2 -- the number of times enter will be pressed
    arcade["La Mesa"] = {
        name = "La Mesa",
        purchase = function()
            utils:MOVE_CURSOR(0.687, 0.48, script.delays.PURCHASE.BUY_FROM_DELAY, true) -- select the arcade
            utils:MOVE_CURSOR(0.30, 0.78, script.delays.PURCHASE.BUY_BUTTON_DELAY, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.92, script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, script.delays.PURCHASE.TRADE_IN_SELECTION_DELAY, true) -- press the third buy button
            utils:SIMULATE_CONTROL_KEY(176, press_counter) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, press_counter, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:RETURN_TO_MAP(arcade) -- return to the map
        end
    }
    
    arcade["Eight Bit"] = {
        name = "Eight Bit",
        purchase = function()
            utils:MOVE_CURSOR(0.54, 0.27, script.delays.PURCHASE.BUY_FROM_DELAY, true) -- select the arcade
            utils:MOVE_CURSOR(0.30, 0.81, script.delays.PURCHASE.BUY_BUTTON_DELAY, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.92, script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, script.delays.PURCHASE.TRADE_IN_SELECTION_DELAY, true) -- press the third buy button
            utils:SIMULATE_CONTROL_KEY(176, press_counter) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, press_counter, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:RETURN_TO_MAP(arcade) -- return to the map
        end
    }
    
    arcade["Davis"] = {
        name = "Davis",
        purchase = function()
            utils:MOVE_CURSOR(0.593, 0.67, script.delays.PURCHASE.BUY_FROM_DELAY, true) -- select the arcade
            utils:MOVE_CURSOR(0.30, 0.81, script.delays.PURCHASE.BUY_BUTTON_DELAY, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.92, script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, script.delays.PURCHASE.TRADE, true) -- press the third buy button
            utils:SIMULATE_CONTROL_KEY(176, press_counter) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, press_counter, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:RETURN_TO_MAP(arcade) -- return to the map
        end
    }
    

    -- add arcade to the menu
    script:add(
        script.root:list("Arcade", {}, "Arcade recovery options", function()
            local ref = menu.ref_by_rel_path(script.root, "Arcade")
            local owned_data = script:GET_OWNED_PROPERTY_DATA("arcade")
            
            if owned_data == nil then
                ref:focus() -- prevent access
                script:notify("You do not own a arcade, purchase a arcade to access this feature")
            end

            script:SHOW_REQUIREMENTS_WARNING() -- show the requirements warning
        end),
        "arcade_recovery"
    )

    script.arcade_recovery:divider("1B Recovery")

    script:add(
        script.arcade_recovery:list("Presets", {}, "Presets for 1B Recovery"),
        "arcade_presets"
    )

    script:add(
        script.arcade_recovery:list("Custom", {}, "Customisable options for 1B Recovery"),
        "arcade_custom"
    )

    script.arcade_recovery:divider("Arcade Safe")

    script:add(
        script.arcade_recovery:action("Teleport To Arcade", {}, "Teleports to your arcade", function()
            local arcade_blip = HUD.GET_FIRST_BLIP_INFO_ID(script.blips.ARCADE) -- get the arcade blip

            if HUD.DOES_BLIP_EXIST(arcade_blip) then -- check if the blip exists on the map
                local pos = HUD.GET_BLIP_INFO_ID_COORD(arcade_blip) -- get the coordinates of the blip
                ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z) -- teleport to the coordinates
            else
                script:notify("Arcade blip not found")
            end
        end),
        "arcade_teleport"
    )

    script:add(
        script.arcade_recovery:action("Trigger Production", {}, "Triggers production at your arcade", function()
            memory.write_int(arcade.globals.safe, 200000) -- set the maximum amount of money the safe can hold
            memory.write_int(arcade.globals.income, 200000) -- set the amount of income to maximum

            script:STAT_SET_INT("ARCADE_PAY_TIME_LEFT", 1, true) -- set the time left to 1 second
            script:STAT_SET_INT("ARCADE_POPULARITY", 10000, true) -- set the popularity to 10000
        end),
        "arcade_trigger_production"
    )

    script:add(
        script.arcade_recovery:toggle_loop("Fill Safe", {}, "Fills your arcade safe", function()
            menu.trigger_command(script.arcade_trigger_production) -- trigger production
        end),
        "arcade_fill_safe"
    )

    script:add(
        script.arcade_recovery:toggle_loop("AFK Loop", {}, "AFK Money Loop", function()
            local fill = script.arcade_fill_safe
            local afk = menu.ref_by_rel_path(script.arcade_recovery, "AFK Loop")

            if not script:IS_INSIDE_OF_INTERIOR("arcade") then
                script:notify("You are not inside of your arcade")
                afk.value = false
                return
            end

            if not script:TRANSACTION_ERROR_DISPLAYED() then
                if not script.states.arcade.safe_open then
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, 2728.4833984375, -374.21838378906, -47.392971038818)
                    utils:SIMULATE_CONTROL_KEY(51, 1)
                    script.states.arcade.safe_open = true
                    util.yield(8000)
                    ENTITY.SET_ENTITY_COORDS(script.me_ped, 2728.5122070312, -374.37905883789, -47.392944335938)
                else
                    if not script.states.arcade.infront_of_safe then
                        ENTITY.SET_ENTITY_COORDS(script.me_ped, 2728.5122070312, -374.37905883789, -47.392944335938)
                        script.states.arcade.infront_of_safe = true
                        util.yield(3000)
                    else
                        ENTITY.SET_ENTITY_COORDS(script.me_ped, 2726.9116210938, -374.23046875, -47.38952255249)
                        util.yield(1000)
                        ENTITY.SET_ENTITY_COORDS(script.me_ped, 2728.5122070312, -374.37905883789, -47.392944335938)
                    end
                end
            end

            fill.value = true
        end,
        function()
            local fill = script.arcade_fill_safe
            fill.value = false

            util.yield(1000)
            utils:SIMULATE_CONTROL_KEY(51, 1)
            script.states.arcade.safe_open = false
            script.states.arcade.infront_of_safe = false
        end),
        "arcade_safe_afk_loop"
    )

    -- add options divider
    script.arcade_presets:divider("Options")

    -- add the arcade presets
    script:add(
        script.arcade_presets:list_select("Money", {}, "Setting this does not change the amount you get from the afk loop", script.money_options, 1, function() end),
        "arcade_presets_money"
    )

    -- add buy arcade
    script:add(
        script.arcade_presets:action("Buy Arcade", {}, "Automatically buys an arcade for you", function()
            local owned_data = script:GET_OWNED_PROPERTY_DATA("arcade")
            local choice = arcade.afk_options.available[math.random(#arcade.afk_options.available)]
            local value = script:CONVERT_VALUE(script.money_options[script.arcade_presets_money.value])

            while owned_data.name == choice do
                choice = arcade.afk_options.available[math.random(#arcade.afk_options.available)]
                util.yield()
            end

            utils:OPEN_INTERNET(script, 200, true)
            arcade:SELECT_INTERNET_FILTER(script)
            script:PURCHASE_PROPERTY(arcade, choice, true, value)
        end),
        "arcade_presets_buy"
    )

    -- add set value
    script:add(
        script.arcade_presets:action("Set Value", {}, "Sets the value of your arcade (this is for manual purchases)", function()
            local money = script:CONVERT_VALUE(script.money_options[script.arcade_presets_money.value])
            local current_value = script:STAT_GET_INT("PROP_ARCADE_VALUE")
            
            if current_value > 0 then
                script:STAT_SET_INT("PROP_ARCADE_VALUE", (money + current_value + 400000) * 2, true)
            else
                script:STAT_SET_INT("PROP_ARCADE_VALUE", (money + 15000000) * 2, true)
            end
        end),
        "arcade_presets_set_value"
    )

    -- add loop set value
    script:add(
        script.arcade_presets:toggle_loop("Loop Set Value", {}, "Does the same as set value but instead of setting it once it sets it repeatedly", function()
            local afk = menu.ref_by_rel_path(script.arcade_presets, "AFK Loop")
            local loop_set = menu.ref_by_rel_path(script.arcade_presets, "Loop Set Value")

            if not afk.value then
                menu.trigger_command(script.arcade_presets_set_value) -- call set value button
                util.yield(500) -- wait before setting it again
            else
                loop_set.value = false
            end
        end),
        "arcade_presets_loop_set_value"
    )

    -- add divider for afk loop
    script.arcade_presets:divider("AFK Money Loop")

    -- add override value to the menu
    script:add(
        script.arcade_presets:toggle("Override Value", {}, "Overrides the afk loop value from 1.07B to the choice selected in money under options", function()
        
        end),
        "arcade_presets_override_value"
    )

    -- block phone calls
    script:add(
        script.arcade_presets:toggle("Block Phone Calls", {}, "Blocks incoming phones calls", function(state)
            local phone_calls = menu.ref_by_command_name("nophonespam")
            phone_calls.value = state
        end),
        "arcade_presets_block_phone_calls"
    )

    -- add afk loop option
    script:add(
        script.arcade_presets:toggle_loop("AFK Loop", {}, "Alternates between buying arcades you don\'t own, the value is set to the max (" .. tostring(math.floor(script.MAX_INT / 2)) .. ")", function(state)
            local afk = menu.ref_by_rel_path(script.arcade_presets, "AFK Loop")
            local owned_data = script:GET_OWNED_PROPERTY_DATA("arcade")
            local choice = arcade.afk_options.available[math.random(#arcade.afk_options.available)]
            local override = menu.ref_by_rel_path(script.arcade_presets, "Override Value")
            local loop_delay = menu.ref_by_rel_path(script.arcade_presets, "Loop Delay")
            local loops = menu.ref_by_rel_path(script.arcade_presets, "Loops")
            local money_value = (script:CONVERT_VALUE(script.money_options[script.arcade_presets_money.value]))

            if not afk.value then util.stop_thread() end

            if not override.value then
                money_value = script.MAX_INT
            end

            if loops.value > 0 then
                if arcade.afk_options.total_loops >= loops.value then
                    afk.value = false
                    util.stop_thread()
                end
            end

            if not script:IS_SCREEN_OPEN() then
                utils:OPEN_INTERNET(script, 200)
                arcade:SELECT_INTERNET_FILTER(script)
            end
            
            script:PURCHASE_PROPERTY(arcade, choice, false, money_value)
            arcade.afk_options.total_loops = arcade.afk_options.total_loops + 1
            arcade.afk_options.total_earnings = arcade.afk_options.total_earnings + money_value
            util.yield(loop_delay.value)
        end,
        function()
            arcade.afk_options.total_loops = 0
            arcade.afk_options.total_earnings = 0
        end),
        "arcade_presets_afk_loop"
    )

    -- add divider for loop options
    script.arcade_presets:divider("Loop Options")

    -- add loop delay option
    script:add(
        script.arcade_presets:slider("Loop Delay", {"rsarcadedelay"}, "The delay between each loop", 0, script.MAX_INT, 100, 100, function() end),
        "arcade_presets_loop_delay"
    )

    -- add loop count option
    script:add(
        script.arcade_presets:slider("Loops", {"rsarcadecount"}, "The amount of loops to do before stopping", -1, script.MAX_INT, 0, 1, function() end),
        "arcade_presets_loop_count"
    )

    -- add options for custom
    script:add(
        script.arcade_custom:text_input("Money", {"rsarcadevalue"}, "The arcade value", function(value)
            value = tonumber(value) -- ensure that the value is a number
            
            if value ~= nil then -- prevents an error when stopping the script
                if value >= 0 then
                    script:STAT_SET_INT("PROP_ARCADE_VALUE", value, true)
                else
                    script:notify("Invalid value, must be greater than 0")
                end
            end
        end),
        "arcade_custom_money"
    )

    -- add buy arcade option to custom (works the same as the presets)
    script:add(
        script.arcade_custom:action("Buy Arcade", {}, "Automatically buys an arcade for you", function()
            local owned_data = script:GET_OWNED_PROPERTY_DATA("arcade")
            local club = arcade.afk_options.available[math.random(#arcade.afk_options.available)]
            local value = tonumber(script.arcade_custom_money.value)

            while owned_data.name == club do
                club = arcade.afk_options.available[math.random(#arcade.afk_options.available)]
                util.yield()
            end

            utils:OPEN_INTERNET(script, 200, true)
            arcade:SELECT_INTERNET_FILTER(script)
            script:PURCHASE_PROPERTY(arcade, club, true, value)
        end),
        "arcade_custom_buy"
    )

    -- add divider for afk loop
    script.arcade_custom:divider("AFK Money Loop")

    -- add block phone calls option
    script:add(
        script.arcade_custom:toggle("Block Phone Calls", {}, "Blocks incoming phones calls", function(state)
            local phone_calls = menu.ref_by_command_name("nophonespam")
            phone_calls.value = state
        end),
        "arcade_custom_block_phone_calls"
    )

    -- add afk loop option
    script:add(
        script.arcade_custom:toggle_loop("AFK Loop", {}, "Alternates between buying arcades you don\'t own, the value is set to the max (" .. tostring(math.floor(script.MAX_INT / 2)) .. ")", function(state)
            local afk = menu.ref_by_rel_path(script.arcade_custom, "AFK Loop")
            local choice = arcade.afk_options.available[math.random(#arcade.afk_options.available)]
            local loop_delay = menu.ref_by_rel_path(script.arcade_custom, "Loop Delay")
            local loops = menu.ref_by_rel_path(script.arcade_custom, "Loops")
            local money_value = tonumber(script.arcade_custom_money.value)

            if not afk.value then util.stop_thread() end

            if loops.value > 0 then
                if arcade.afk_options.total_loops >= loops.value then
                    afk.value = false
                    util.stop_thread()
                end
            end

            if not script:IS_SCREEN_OPEN() then
                utils:OPEN_INTERNET(script, 200)
                arcade:SELECT_INTERNET_FILTER(script)
            end
            
            script:PURCHASE_PROPERTY(arcade, choice, false, money_value)
            arcade.afk_options.total_loops = arcade.afk_options.total_loops + 1
            arcade.afk_options.total_earnings = arcade.afk_options.total_earnings + money_value
            util.yield(loop_delay.value)
        end,
        function()
            arcade.afk_options.total_loops = 0
            arcade.afk_options.total_earnings = 0
        end),
        "arcade_custom_afk_loop"
    )

    -- add divider for loop options
    script.arcade_custom:divider("Loop Options")

    -- add loop delay option
    script:add(
        script.arcade_custom:slider("Loop Delay", {"rsarcadedelay"}, "The delay between each loop", 0, script.MAX_INT, 100, 100, function() end),
        "arcade_custom_loop_delay"
    )

    -- add loop count option
    script:add(
        script.arcade_custom:slider("Loops", {"rsarcadecount"}, "The amount of loops to do before stopping", -1, script.MAX_INT, 0, 1, function() end),
        "arcade_custom_loop_count"
    )
end

return arcade