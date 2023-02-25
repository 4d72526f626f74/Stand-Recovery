local hangar = setmetatable({}, {__index = _G})
local char = util.get_char_slot()

local utils = require("lib.recovery.utils") -- require the utils module

hangar.value = util.joaat("MP" .. char .. "_PROP_HANGAR_VALUE") -- stat for hangar value
hangar.owned = util.joaat("MP" .. char .. "_HANGAR_OWNED") -- stat for owned hangar id
hangar.offset = 0.05
hangar.name = "hangar"

hangar.globals = { -- hangar specific globals
    prices = {
        ["LSIA A17"] = memory.script_global(262145 + 22603),
        ["LSIA 1"] = memory.script_global(262145 + 22604)
    }
}

hangar.afk_options = {
    available = {"LSIA A17", "LSIA 1"},
    total_loops = 0,
    total_earnings = 0
}

function hangar:SELECT_INTERNET_FILTER(script)
    local xptr, yptr = memory.alloc_int(4), memory.alloc_int(4)
    GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(xptr, yptr)
    local x, y = tonumber(memory.read_int(xptr)), tonumber(memory.read_int(yptr))

    local start_x, start_y = 0.9447917342186, 0.23703703284264

    switch x do
        case 1920:
            start_x, start_y = 0.9447917342186, 0.23703703284264
            break
        case 1680:
            start_x = 0.9447917342186 - hangar.offset
            start_y = 0.23703703284264
            break
        case 1600:
            if y == 1024 then
                start_x = 0.9447917342186 - (hangar.offset + 0.01)
                start_y = 0.23703703284264
            end
    
            if y == 900 then
                start_x = 0.9447917342186
                start_y = 0.23703703284264
            end
            break
        case 1440:
            start_x = 0.9447917342186 - hangar.offset
            start_y = 0.23703703284264
            break
        case 1366:
            start_x = 0.9447917342186
            start_y = 0.23703703284264
            break
        case 1360:
            start_x = 0.9447917342186
            start_y = 0.23703703284264
            break
        case 1280:
            if y == 1024 then
                start_x = 0.9447917342186 - (hangar.offset * 3)
                start_y = 0.23703703284264
            end
    
            if y == 960 then
                start_x = 0.9447917342186 - (hangar.offset * 2.5)
                start_y = 0.23703703284264
            end
    
            if y == 800 then
                start_x = 0.9447917342186 - hangar.offset
                start_y = 0.23703703284264
            end
    
            if y == 768 then
                start_x = 0.9447917342186 - (hangar.offset / 2)
                start_y = 0.23703703284264
            end
    
            if y == 720 then
                start_x = 0.9447917342186
                start_y = 0.23703703284264
            end
            break
        case 1176:
            start_x = 0.9447917342186
            start_y = 0.23703703284264
            break
        case 1152:
            start_x = 0.9447917342186 - (hangar.offset * 2.5)
            start_y = 0.23703703284264
            break
        case 1024:
            start_x = 0.9447917342186 - (hangar.offset * 2.5)
            start_y = 0.23703703284264
            break
        case 800:
            start_x = 0.9447917342186 - (hangar.offset * 2.5)
            start_y = 0.23703703284264
            break
        default:
            start_x = 0.9447917342186
            start_y = 0.23703703284264
            break
    end

    utils:MOVE_CURSOR(start_x, start_y, script.delays.PURCHASE.SELECT_FILTER_DELAY, true) -- select the internet filter
    utils:SIMULATE_CONTROL_KEY(242, 1) -- scroll down to zoom out on map
end

function hangar:init(script)
    local press_counter = 2 -- the number of times enter will be pressed
    -- add LSIA A17 hangar
    hangar["LSIA A17"] = {
        name = "LSIA A17",
        purchase = function()
            utils:MOVE_CURSOR(0.47708335518837, 0.77037036418915, script.delays.PURCHASE.BUY_FROM_DELAY, true) -- select the hangar
            utils:MOVE_CURSOR(0.30, 0.73, script.delays.PURCHASE.BUY_BUTTON_DELAY, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.93, script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, script.delays.PURCHASE.TRADE_IN_SELECTION_DELAY, true) -- press the third buy butwton
            utils:SIMULATE_CONTROL_KEY(176, press_counter) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, press_counter, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:RETURN_TO_MAP(hangar) -- return to the map
        end
    }

    -- add LSIA 1 hangar
    hangar ["LSIA 1"] = {
        name = "LSIA 1",
        purchase = function()
            utils:MOVE_CURSOR(0.49010419845581, 0.7907407283783, script.delays.PURCHASE.BUY_FROM_DELAY, true) -- select the hangar
            utils:MOVE_CURSOR(0.30, 0.73, script.delays.PURCHASE.BUY_BUTTON_DELAY, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.93, script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, script.delays.PURCHASE.TRADE_IN_SELECTION_DELAY, true) -- press the third buy butwton
            utils:SIMULATE_CONTROL_KEY(176, press_counter) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, press_counter, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:RETURN_TO_MAP(hangar) -- return to the map
        end
    }

    -- add hangar recovery option to the menu
    script:add(
        script.root:list("Hangar", {}, "Hangar recovery options", function()
            local ref = menu.ref_by_rel_path(script.root, "Hangar")
            local owned_data = script:GET_OWNED_PROPERTY_DATA("hangar")
            
            if owned_data == nil then
                ref:focus() -- prevent access
                script:notify("You do not own a hangar, purchase a hangar to access this feature")
                return
            end

            script:SHOW_REQUIREMENTS_WARNING() -- show the requirements warning
        end),
        "hangar_recovery"
    )
    
    script.hangar_recovery:divider("1B Recovery")

    script:add(
        script.hangar_recovery:list("Presets", {}, "Presets for 1B Recovery"),
        "hangar_presets"
    )

    script:add(
        script.hangar_recovery:list("Custom", {}, "Customisable options for 1B Recovery"),
        "hangar_custom"
    )

    script.hangar_recovery:divider("Other")
    
    -- add options divider
    script.hangar_presets:divider("Options")

    -- add the hangar presets
    script:add(
        script.hangar_presets:list_select("Money", {}, "Setting this does not change the amount you get from the afk loop", script.money_options, 1, function() end),
        "hangar_presets_money"
    )

    -- add buy hangar
    script:add(
        script.hangar_presets:action("Buy Hangar", {}, "Automatically buys a hangar for you", function()
            local owned_data = script:GET_OWNED_PROPERTY_DATA("hangar")
            local choice = hangar.afk_options.available[math.random(#hangar.afk_options.available)]
            local value = script:CONVERT_VALUE(script.money_options[script.hangar_presets_money.value])

            while owned_data.name == choice do
                choice = hangar.afk_options.available[math.random(#hangar.afk_options.available)]
                util.yield()
            end

            utils:OPEN_INTERNET(script, 300, true)
            hangar:SELECT_INTERNET_FILTER(script)
            script:PURCHASE_PROPERTY(hangar, choice, true, value)
        end),
        "hangar_presets_buy"
    )

    -- add set value
    script:add(
        script.hangar_presets:action("Set Value", {}, "Sets the value of your hangar (this is for manual purchases)", function()
            local money = script:CONVERT_VALUE(script.money_options[script.hangar_presets_money.value])
            local current_value = script:STAT_GET_INT("PROP_HANGAR_VALUE")
            
            if current_value > 0 then
                script:STAT_SET_INT("PROP_HANGAR_VALUE", (money + current_value + 400000) * 2, true)
            else
                script:STAT_SET_INT("PROP_HANGAR_VALUE", (money + 15000000) * 2, true)
            end
        end),
        "hangar_presets_set_value"
    )

    -- add loop set value
    script:add(
        script.hangar_presets:toggle_loop("Loop Set Value", {}, "Does the same as set value but instead of setting it once it sets it repeatedly", function()
            local afk = menu.ref_by_rel_path(script.hangar_presets, "AFK Loop")
            local loop_set = menu.ref_by_rel_path(script.hangar_presets, "Loop Set Value")

            if not afk.value then
                menu.trigger_command(script.hangar_presets_set_value) -- call set value button
                util.yield(500) -- wait before setting it again
            else
                loop_set.value = false
            end
        end),
        "hangar_presets_loop_set_value"
    )

    -- add divider for afk loop
    script.hangar_presets:divider("AFK Money Loop")

    script:add(
        script.hangar_presets:toggle("Override Value", {}, "Overrides the afk loop value from 1.07B to the choice selected in money under options", function()
        
        end),
        "hangar_presets_override_value"
    )

    -- block phone calls
    script:add(
        script.hangar_presets:toggle("Block Phone Calls", {}, "Blocks incoming phones calls", function(state)
            local phone_calls = menu.ref_by_command_name("nophonespam")
            phone_calls.value = state
        end),
        "hangar_presets_block_phone_calls"
    )

    -- add afk loop option
    script:add(
        script.hangar_presets:toggle_loop("AFK Loop", {}, "Alternates between buying hangars you don\'t own, the value is set to the max (" .. tostring(math.floor(script.MAX_INT / 2)) .. ")", function(state)
            local afk = menu.ref_by_rel_path(script.hangar_presets, "AFK Loop")
            local owned_data = script:GET_OWNED_PROPERTY_DATA("hangar")
            local choice = hangar.afk_options.available[math.random(#hangar.afk_options.available)]
            local override = menu.ref_by_rel_path(script.hangar_presets, "Override Value")
            local loop_delay = menu.ref_by_rel_path(script.hangar_presets, "Loop Delay")
            local loops = menu.ref_by_rel_path(script.hangar_presets, "Loops")
            local money_value = (script:CONVERT_VALUE(script.money_options[script.hangar_presets_money.value]))

            if not afk.value then util.stop_thread() end

            if not override.value then
                money_value = script.MAX_INT
            end

            if loops.value > 0 then
                if hangar.afk_options.total_loops >= loops.value then
                    afk.value = false
                    util.stop_thread()
                end
            end
            
            if not script:IS_SCREEN_OPEN() then 
                utils:OPEN_INTERNET(script, 200)
                hangar:SELECT_INTERNET_FILTER(script) 
            end

            script:PURCHASE_PROPERTY(hangar, choice, false, money_value)
            hangar.afk_options.total_loops = hangar.afk_options.total_loops + 1
            hangar.afk_options.total_earnings = hangar.afk_options.total_earnings + money_value
            util.yield(loop_delay.value)
        end,
        function()
            hangar.afk_options.total_loops = 0
            hangar.afk_options.total_earnings = 0
        end),
        "hangar_presets_afk_loop"
    )

    -- add divider for loop options
    script.hangar_presets:divider("Loop Options")

    -- add loop delay option
    script:add(
        script.hangar_presets:slider("Loop Delay", {"rshangardelay"}, "The delay between each loop", 0, script.MAX_INT, 100, 100, function() end),
        "hangar_presets_loop_delay"
    )

    -- add loop count option
    script:add(
        script.hangar_presets:slider("Loops", {"rshangarcount"}, "The amount of loops to do before stopping", 0, script.MAX_INT, 0, 1, function() end),
        "hangar_presets_loop_count"
    )

    -- add options for custom
    script:add(
        script.hangar_custom:text_input("Money", {"rshangarvalue"}, "The hangar value", function(value)
            value = tonumber(value) -- ensure that the value is a number
            
            if value ~= nil then -- prevents an error when stopping the script
                if value >= 0 then
                    script:STAT_SET_INT("PROP_HANGAR_VALUE", value, true)
                else
                    script:notify("Invalid value, must be greater than 0")
                end
            end
        end),
        "hangar_custom_money"
    )

    -- add buy hangar option to custom (works the same as the presets)
    script:add(
        script.hangar_custom:action("Buy Hangar", {}, "Automatically buys a hangar for you", function()
            local owned_data = script:GET_OWNED_PROPERTY_DATA("hangar")
            local choice = hangar.afk_options.available[math.random(#hangar.afk_options.available)]
            local value = tonumber(script.hangar_custom_money.value)

            while owned_data.name == choice do
                choice = hangar.afk_options.available[math.random(#hangar.afk_options.available)]
                util.yield()
            end

            utils:OPEN_INTERNET(script, 200, true)
            hangar:SELECT_INTERNET_FILTER(script)
            script:PURCHASE_PROPERTY(hangar, choice, true, value)
        end),
        "hangar_custom_buy"
    )

    -- add divider for afk loop
    script.hangar_custom:divider("AFK Money Loop")

    -- add block phone calls option
    script:add(
        script.hangar_custom:toggle("Block Phone Calls", {}, "Blocks incoming phones calls", function(state)
            local phone_calls = menu.ref_by_command_name("nophonespam")
            phone_calls.value = state
        end),
        "hangar_custom_block_phone_calls"
    )

    -- add afk loop option
    script:add(
        script.hangar_custom:toggle_loop("AFK Loop", {}, "Alternates between buying hangars you don\'t own, the value is set to the max (" .. tostring(math.floor(script.MAX_INT / 2)) .. ")", function(state)
            local afk = menu.ref_by_rel_path(script.hangar_custom, "AFK Loop")
            local choice = hangar.afk_options.available[math.random(#hangar.afk_options.available)]
            local loop_delay = menu.ref_by_rel_path(script.hangar_custom, "Loop Delay")
            local loops = menu.ref_by_rel_path(script.hangar_custom, "Loops")
            local money_value = tonumber(script.hangar_custom_money.value)

            if not afk.value then util.stop_thread() end

            if loops.value > 0 then
                if hangar.afk_options.total_loops >= loops.value then
                    afk.value = false
                    util.stop_thread()
                end
            end

            if not script:IS_SCREEN_OPEN() then
                utils:OPEN_INTERNET(script, 200)
                hangar:SELECT_INTERNET_FILTER(script)
            end

            script:PURCHASE_PROPERTY(hangar, choice, false, money_value)
            hangar.afk_options.total_loops = hangar.afk_options.total_loops + 1
            hangar.afk_options.total_earnings = hangar.afk_options.total_earnings + money_value
            util.yield(loop_delay.value)
        end,
        function()
            hangar.afk_options.total_loops = 0
            hangar.afk_options.total_earnings = 0
        end),
        "hangar_custom_afk_loop"
    )

    -- add divider for loop options
    script.hangar_custom:divider("Loop Options")

    -- add loop delay option
    script:add(
        script.hangar_custom:slider("Loop Delay", {"rshangardelay"}, "The delay between each loop", 0, script.MAX_INT, 100, 100, function() end),
        "hangar_custom_loop_delay"
    )

    -- add loop count option
    script:add(
        script.hangar_custom:slider("Loops", {"rshangarcount"}, "The amount of loops to do before stopping", 0, script.MAX_INT, 0, 1, function() end),
        "hangar_custom_loop_count"
    )

    -- add airfreight to the menu
    script:add(
        script.hangar_recovery:list("Airfreight", {}, "Airfreight Manager"),
        "hangar_airfreight"
    )

    -- add set airfreight cargo sell value
    script:add(
        script.hangar_airfreight:text_input("Set Cargo Sell Value", {"rshangarairfreightsellvalue"}, "The value of the cargo you sell", function(value)
            local start_global = script.globals.hangar.airfreight.sell_start
            local end_global = script.globals.hangar.airfreight.sell_end
            value = tonumber(value)

            if value < 30000 then
                value = 0
            end

            if value >= 10000000 then
                value = 10000000
            end

            script:SET_PACKED_INT_GLOBAL(start_global, end_global, value + 30000)
        end, 30000),
        "hangar_airfreight_set_value"
    )

    -- add instant finish airfreight
    script:add(
        script.hangar_airfreight:action("Instant Finish", {}, "Instantly finishes airfreight", function()
            script:SET_INT_LOCAL("gb_smuggler", 1928 + 1035, script:GET_INT_LOCAL("gb_smuggler", 1928 + 1078)) -- credit to IceDoomfist for this
        end),
        "hangar_airfreight_instant_finish"
    )

    -- add teleport to hangar
    script:add(
        script.hangar_recovery:action("Teleport To Hangar", {}, "Teleports you to your hangar", function()
            script:TELEPORT_TO_BLIP(script.blips.HANGAR)
        end),
        "hangar_recovery_teleport"
    )
    
    -- add teleport to laptop
    script:add(
        script.hangar_recovery:action("Teleport To Laptop", {}, "Teleports you to your laptop within your hangar", function()
            script:TELEPORT_TO_BLIP(script.blips.LAPTOP)
        end),
        "hangar_recovery_teleport_laptop"
    )
end

return hangar