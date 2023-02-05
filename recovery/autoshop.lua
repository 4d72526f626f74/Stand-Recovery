local autoshop = setmetatable({}, {__index = _G})
local char = util.get_char_slot()

local utils = require("lib.recovery.utils")

autoshop.value = util.joaat("MP" .. char .. "_PROP_AUTO_SHOP_VALUE") -- stat for autoshop value
autoshop.owned = util.joaat("MP" .. char .. "_AUTO_SHOP_OWNED") -- stat for owned autoshop id
autoshop.offset = 0.05
autoshop.name = "autoshop"

autoshop.globals = { -- autoshop specific globals
    prices = {
        ["La Mesa"] = memory.script_global(262145 + 31246),
        ["Mission Row"] = memory.script_global(262145 + 31248),
        ["Burton"] = memory.script_global(262145 + 31249)
    }
}

autoshop.afk_options = {
    available = {"La Mesa", "Mission Row", "Burton"},
}

function autoshop:SELECT_INTERNET_FILTER(script)
    local xptr, yptr = memory.alloc_int(4), memory.alloc_int(4)
    GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(xptr, yptr)
    local x, y = tonumber(memory.read_int(xptr)), tonumber(memory.read_int(yptr))

    local start_x, start_y = 0.94, 0.28

    switch x do
        case 1920:
            start_x = 0.94
            start_y = 0.28
            break
        case 1680:
            start_x = 0.94 - autoshop.offset
            start_y = 0.28
            break
        case 1600:
            if y == 1024 then
                start_x = 0.94 - (autoshop.offset + 0.01)
                start_y = 0.28
            end
    
            if y == 900 then
                start_x = 0.94
                start_y = 0.28
            end
            break
        case 1440:
            start_x = 0.94 - autoshop.offset
            start_y = 0.28
            break
        case 1366:
            start_x = 0.94
            start_y = 0.28
            break
        case 1360:
            start_x = 0.94
            start_y = 0.28
            break
        case 1280:
            if y == 1024 then
                start_x = 0.94 - (autoshop.offset * 3)
                start_y = 0.28
            end
    
            if y == 960 then
                start_x = 0.94 - (autoshop.offset * 2.5)
                start_y = 0.28
            end
    
            if y == 800 then
                start_x = 0.94 - autoshop.offset
                start_y = 0.28
            end
    
            if y == 768 then
                start_x = 0.94 - (autoshop.offset / 2)
                start_y = 0.28
            end
    
            if y == 720 then
                start_x = 0.94
                start_y = 0.28
            end
            break
        case 1176:
            start_x = 0.94
            start_y = 0.28
            break
        case 1152:
            start_x = 0.94 - (autoshop.offset * 2.5)
            start_y = 0.28
            break
        case 1024:
            start_x = 0.94 - (autoshop.offset * 2.5)
            start_y = 0.28
            break
        case 800:
            start_x = 0.94 - (autoshop.offset * 2.5)
            start_y = 0.28
            break
        default:
            start_x = 0.94
            start_y = 0.28
            break
    end

    utils:MOVE_CURSOR(start_x, start_y, script.delays.PURCHASE.SELECT_FILTER_DELAY, true) -- select the internet filter
    utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to select the internet filter
end

function autoshop:FIRST_CHOICE_OPTIONS(script, return_results)
    -- create options for first autoshop (get all autoshops that don't own)
    local autoshop_options = {}
    local owned_data = script:GET_OWNED_PROPERTY_DATA("autoshop")

    for key, value in pairs(autoshop.afk_options.available) do
        table.insert(autoshop_options, value)
    end

    for index, option in ipairs(autoshop_options) do
        if owned_data.name == option then
            table.remove(autoshop_options, index)
        end
    end

    if return_results then
        return autoshop_options
    end

    -- get the reference and set the options
    local ref = script.autoshop_presets_afk_first
    menu.set_list_action_options(ref, autoshop_options)
end

function autoshop:SECOND_CHOICE_OPTIONS(script, return_results)
    -- modify the options for the second autoshop
    local autoshop1_options = {}
    local owned_data = script:GET_OWNED_PROPERTY_DATA("autoshop")

    for key, value in pairs(autoshop.afk_options.available) do
        table.insert(autoshop1_options, value)
    end

    if return_results then
        return autoshop1_options
    end

    -- get the reference and set the options
    local ref = script.autoshop_presets_afk_second
    menu.set_list_action_options(ref, autoshop1_options)
end

function autoshop:init(script)
    local press_counter = 2 -- the number of times enter will be pressed

    autoshop["La Mesa"] = {
        name = "La Mesa",
        purchase = function()
            utils:MOVE_CURSOR(0.687, 0.455, script.delays.PURCHASE.BUY_FROM_DELAY, true) -- select the autoshop
            utils:MOVE_CURSOR(0.30, 0.75, script.delays.PURCHASE.BUY_BUTTON_DELAY, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.92, script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.94, script.delays.PURCHASE.TRADE_IN_SELECTION_DELAY, true) -- press the third buy button
            utils:SIMULATE_CONTROL_KEY(176, press_counter) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, press_counter, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:RETURN_TO_MAP(autoshop) -- return to the map
        end
    }
    
    autoshop["Mission Row"] = {
        name = "Mission Row",
        purchase = function()
            utils:MOVE_CURSOR(0.66, 0.49, script.delays.PURCHASE.BUY_FROM_DELAY, true) -- select the autoshop
            utils:MOVE_CURSOR(0.30, 0.75, script.delays.PURCHASE.BUY_BUTTON_DELAY, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.92, script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.94, script.delays.PURCHASE.TRADE_IN_SELECTION_DELAY, true) -- press the third buy button
            utils:SIMULATE_CONTROL_KEY(176, press_counter) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, press_counter, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:RETURN_TO_MAP(autoshop) -- return to the map
        end
    }
    
    autoshop["Burton"] = {
        name = "Burton",
        purchase = function()
            utils:MOVE_CURSOR(0.585, 0.32, script.delays.PURCHASE.BUY_FROM_DELAY, true) -- select the autoshop
            utils:MOVE_CURSOR(0.30, 0.75, script.delays.PURCHASE.BUY_BUTTON_DELAY, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.92, script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.94, script.delays.PURCHASE.TRADE_IN_SELECTION_DELAY, true) -- press the third buy button
            utils:SIMULATE_CONTROL_KEY(176, press_counter) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, press_counter, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:RETURN_TO_MAP(autoshop) -- return to the map
        end
    }

    -- add autoshop recovery option to the menu
    script:add(
        script.root:list("Autoshop", {}, "autoshop recovery options", function()
            local ref = menu.ref_by_rel_path(script.root, "Autoshop")
            local owned_data = script:GET_OWNED_PROPERTY_DATA("autoshop")
            
            if owned_data == nil then
                ref:focus() -- prevent access
                script:notify("You do not own a autoshop, purchase a autoshop to access this feature")
            end

            script:SHOW_REQUIREMENTS_WARNING() -- show the requirements warning
        end),
        "autoshop_recovery"
    )
    
    script.autoshop_recovery:divider("1B Recovery")

    script:add(
        script.autoshop_recovery:list("Presets", {}, "Presets for 1B Recovery"),
        "autoshop_presets"
    )

    script:add(
        script.autoshop_recovery:list("Custom", {}, "Customisable options for 1B Recovery"),
        "autoshop_custom"
    )

    script.autoshop_recovery:divider("Other")

    script:add(
        script.autoshop_recovery:action("Teleport To Autoshop", {}, "Teleports to your autoshop", function()
            local autoshop_blip = HUD.GET_FIRST_BLIP_INFO_ID(script.blips.AUTOSHOP) -- get the autoshop blip

            if HUD.DOES_BLIP_EXIST(autoshop_blip) then -- check if the blip exists on the map
                local pos = HUD.GET_BLIP_INFO_ID_COORD(autoshop_blip) -- get the coordinates of the blip
                ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z) -- teleport to the coordinates
            else
                script:notify("Autoshop blip not found")
            end
        end),
        "autoshop_teleport"
    )

    -- add options divider
    script.autoshop_presets:divider("Options")

    -- add the autoshop presets
    script:add(
        script.autoshop_presets:list_select("Money", {}, "Setting this does not change the amount you get from the afk loop", script.money_options, 1, function() end),
        "autoshop_presets_money"
    )

    -- add buy autoshop
    script:add(
        script.autoshop_presets:action("Buy Autoshop", {}, "Automatically buys a autoshop for you", function()
            local owned_data = script:GET_OWNED_PROPERTY_DATA("autoshop")
            local choice = autoshop.afk_options.available[math.random(#autoshop.afk_options.available)]

            while owned_data.name == choice do
                choice = autoshop.afk_options.available[math.random(#autoshop.afk_options.available)]
                util.yield()
            end

            local price = memory.read_int(autoshop.globals.prices[choice])
            if choice == "Mission Row" then price = price - 160000 end
            if choice == "Burton" then price = price + 80000 end
            local value = script:CONVERT_VALUE(script.money_options[script.autoshop_presets_money.value])
            value = (value + price) * 2

            script:STAT_SET_INT("PROP_AUTO_SHOP_VALUE", value, true)

            utils:OPEN_INTERNET(script, 300, true)
            autoshop:SELECT_INTERNET_FILTER(script)
            script:PURCHASE_PROPERTY(autoshop, choice, true)
        end),
        "autoshop_presets_buy"
    )

    -- add set value
    script:add(
        script.autoshop_presets:action("Set Value", {}, "Sets the value of your autoshop (this is for manual purchases)", function()
            local money = script:CONVERT_VALUE(script.money_options[script.autoshop_presets_money.value])
            local current_value = script:STAT_GET_INT("PROP_AUTO_SHOP_VALUE")
            
            if current_value > 0 then
                script:STAT_SET_INT("PROP_AUTO_SHOP_VALUE", (money + current_value + 400000) * 2, true)
            else
                script:STAT_SET_INT("PROP_AUTO_SHOP_VALUE", (money + 15000000) * 2, true)
            end
        end),
        "autoshop_presets_set_value"
    )

    -- add loop set value
    script:add(
        script.autoshop_presets:toggle_loop("Loop Set Value", {}, "Does the same as set value but instead of setting it once it sets it repeatedly", function()
            local afk = menu.ref_by_rel_path(script.autoshop_presets, "AFK Loop")
            local loop_set = menu.ref_by_rel_path(script.autoshop_presets, "Loop Set Value")

            if not afk.value then
                menu.trigger_command(script.autoshop_presets_set_value) -- call set value button
                util.yield(500) -- wait before setting it again
            else
                loop_set.value = false
            end
        end),
        "autoshop_presets_loop_set_value"
    )

    -- add divider for afk loop
    script.autoshop_presets:divider("AFK Money Loop")

    -- block phone calls
    script:add(
        script.autoshop_presets:toggle("Block Phone Calls", {}, "Blocks incoming phones calls", function(state)
            local phone_calls = menu.ref_by_command_name("nophonespam")
            phone_calls.value = state
        end),
        "autoshop_presets_block_phone_calls"
    )

    -- add afk loop option
    script:add(
        script.autoshop_presets:toggle_loop("AFK Loop", {}, "Alternates between buying autoshops you don\'t own, the value is set to the max (" .. tostring(math.floor(script.MAX_INT / 2)) .. ")", function(state)
            local afk = menu.ref_by_rel_path(script.autoshop_presets, "AFK Loop")
            local owned_data = script:GET_OWNED_PROPERTY_DATA("autoshop")
            local choice = autoshop.afk_options.available[math.random(#autoshop.afk_options.available)]

            script:STAT_SET_INT("PROP_AUTO_SHOP_VALUE", script.MAX_INT, true) -- set value to max int
            if not script:IS_SCREEN_OPEN() then
                utils:OPEN_INTERNET(script, 200)
                autoshop:SELECT_INTERNET_FILTER(script)
            end
            script:PURCHASE_PROPERTY(autoshop, choice)
            choice = autoshop.afk_options.available[math.random(#autoshop.afk_options.available)]
            script:STAT_SET_INT("PROP_AUTO_SHOP_VALUE", script.MAX_INT, true) -- set value to max int
            script:PURCHASE_PROPERTY(autoshop, choice)
            util.yield(100)
        end),
        "autoshop_presets_afk_loop"
    )

    -- add options for custom
    script:add(
        script.autoshop_custom:text_input("Money", {"rsautoshopvalue"}, "The autoshop value", function(value)
            value = tonumber(value) -- ensure that the value is a number
            
            if value ~= nil then -- prevents an error when stopping the script
                if value >= 0 then
                    script:STAT_SET_INT("PROP_AUTO_SHOP_VALUE", value, true)
                else
                    script:notify("Invalid value, must be greater than 0")
                end
            end
        end),
        "autoshop_custom_money"
    )

    -- add buy autoshop option to custom (works the same as the presets)
    script:add(
        script.autoshop_custom:action("Buy Autoshop", {}, "Buys a autoshop", function()
            local owned_data = script:GET_OWNED_PROPERTY_DATA("autoshop")
            local choice = autoshop.afk_options.available[math.random(#autoshop.afk_options.available)]

            while owned_data.name == choice do
                choice = autoshop.afk_options.available[math.random(#autoshop.afk_options.available)]
                util.yield()
            end

            local price = memory.read_int(autoshop.globals.prices[choice])
            if choice == "Mission Row" then price = price - 160000 end
            if choice == "Burton" then price = price + 80000 end
            local value = tonumber(script.autoshop_custom_money.value)

            value = (value + price) * 2

            script:STAT_SET_INT("PROP_AUTO_SHOP_VALUE", value, true)

            utils:OPEN_INTERNET(script, 300, true)
            autoshop:SELECT_INTERNET_FILTER(script)
            script:PURCHASE_PROPERTY(autoshop, choice, true)
        end),
        "autoshop_custom_buy"
    )
end

return autoshop