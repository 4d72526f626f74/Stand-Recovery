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
}

function arcade:SELECT_INTERNET_FILTER()
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

    utils:MOVE_CURSOR(start_x, start_y, 100, true) -- select the internet filter
    utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to select the internet filter
end

function arcade:init(script)
    arcade["La Mesa"] = {
        name = "La Mesa",
        purchase = function()
            utils:MOVE_CURSOR(0.687, 0.48, 300, true) -- select the arcade
            utils:MOVE_CURSOR(0.30, 0.78, 300, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
            utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:CLOSE_BROWSER() -- close browser
        end
    }
    
    arcade["Eight Bit"] = {
        name = "Eight Bit",
        purchase = function()
            utils:MOVE_CURSOR(0.54, 0.27, 300, true) -- select the arcade
            utils:MOVE_CURSOR(0.30, 0.81, 300, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
            utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:CLOSE_BROWSER() -- close browser
        end
    }
    
    arcade["Davis"] = {
        name = "Davis",
        purchase = function()
            utils:MOVE_CURSOR(0.593, 0.67, 300, true) -- select the arcade
            utils:MOVE_CURSOR(0.30, 0.81, 300, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
            utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:CLOSE_BROWSER() -- close browser
        end
    }
    

    -- add arcade to the menu
    local owned_data = script:GET_OWNED_PROPERTY_DATA("arcade")

    script:add(
        script.root:list("Arcade", {}, "Arcade recovery options", function()
            local ref = menu.ref_by_rel_path(script.root, "Arcade")
            if owned_data == nil then
                ref:focus() -- prevent access
                script:notify("You do not own a arcade, purchase a arcade to access this feature")
            end
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
        script.arcade_recovery:toggle("AFK Loop", {}, "AFK Money Loop", function(state)
            local fill = script.arcade_fill_safe
            local afk = menu.ref_by_rel_path(script.arcade_recovery, "AFK Loop")

            if not script:IS_INSIDE_OF_INTERIOR("arcade") then
                script:notify("You are not inside of your arcade")
                afk.value = false
                return
            end

            fill.value = state

            util.create_tick_handler(function()
                if afk.value then
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
                else
                    util.yield(1000)
                    utils:SIMULATE_CONTROL_KEY(51, 1)
                    fill.value = false
                    script.states.arcade.safe_open = false
                    script.states.arcade.infront_of_safe = false
                    return false
                end
        
                util.yield(1)
            end)
        end),
        "arcade_safe_afk_loop"
    )

    -- add options divider
    script.arcade_presets:divider("Options")

    -- add the arcade presets
    script:add(
        script.arcade_presets:list_select("Money", {}, "", script.money_options, 1, function() end),
        "arcade_presets_money"
    )

    -- add buy arcade
    script:add(
        script.arcade_presets:action("Buy Arcade", {}, "Automatically buys a arcade for you", function()
            local owned_data = script:GET_OWNED_PROPERTY_DATA("arcade")
            local choice = arcade.afk_options.available[math.random(#arcade.afk_options.available)]

            while owned_data.name == choice do
                choice = arcade.afk_options.available[math.random(#arcade.afk_options.available)]
                util.yield()
            end

            local price = memory.read_int(arcade.globals.prices[choice])
            local value = script:CONVERT_VALUE(script.money_options[script.arcade_presets_money.value])
            value = (value + price) * 2

            script:STAT_SET_INT("PROP_ARCADE_VALUE", value, true)

            utils:OPEN_INTERNET(script, 300)
            arcade:SELECT_INTERNET_FILTER()
            script:PURCHASE_PROPERTY(arcade, choice)
        end),
        "arcade_presets_buy"
    )

    -- add set value
    script:add(
        script.arcade_presets:action("Set Value", {}, "Sets the value of your arcade", function()
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
        script.arcade_presets:toggle_loop("AFK Loop", {}, "Alternates between buying arcades you don\'t own", function(state)
            local afk = menu.ref_by_rel_path(script.arcade_presets, "AFK Loop")
            local owned_data = script:GET_OWNED_PROPERTY_DATA("arcade")
            local choice = arcade.afk_options.available[math.random(#arcade.afk_options.available)]

            script:STAT_SET_INT("PROP_ARCADE_VALUE", script.MAX_INT, true) -- set value to max int
            utils:OPEN_INTERNET(script, 200)
            arcade:SELECT_INTERNET_FILTER()
            script:PURCHASE_PROPERTY(arcade, choice)
            choice = arcade.afk_options.available[math.random(#arcade.afk_options.available)]
            util.yield(1500)
            script:STAT_SET_INT("PROP_ARCADE_VALUE", script.MAX_INT, true) -- set value to max int
            utils:OPEN_INTERNET(script, 200)
            arcade:SELECT_INTERNET_FILTER()
            script:PURCHASE_PROPERTY(arcade, choice)
            util.yield(1500)
        end),
        "arcade_presets_afk_loop"
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
        script.arcade_custom:action("Buy Arcade", {}, "Buys a arcade", function()
            local owned_data = script:GET_OWNED_PROPERTY_DATA("arcade")
            local club = arcade.afk_options.available[math.random(#arcade.afk_options.available)]

            while owned_data.name == club do
                club = arcade.afk_options.available[math.random(#arcade.afk_options.available)]
                util.yield()
            end

            local price = memory.read_int(arcade.globals.prices[club])
            if club == "La Mesa" then price = price + 400000 end
            local value = tonumber(script.arcade_custom_money.value)
            value = (value + price) * 2

            script:STAT_SET_INT("PROP_ARCADE_VALUE", value, true)

            utils:OPEN_INTERNET(script, 300)
            arcade:SELECT_INTERNET_FILTER()
            script:PURCHASE_PROPERTY(arcade, club)
        end),
        "arcade_custom_buy"
    )
end

return arcade