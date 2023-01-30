local autoshop = setmetatable({}, {__index = _G})
local char = util.get_char_slot()

local utils = require("lib.recovery.utils")

autoshop.value = util.joaat("MP" .. char .. "_PROP_AUTO_SHOP_VALUE") -- stat for autoshop value
autoshop.owned = util.joaat("MP" .. char .. "_AUTO_SHOP_OWNED") -- stat for owned autoshop id
autoshop.offset = 0.5
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

autoshop["La Mesa"] = {
    name = "La Mesa",
    purchase = function()
        utils:MOVE_CURSOR(0.687, 0.455, 300, true) -- select the autoshop
        utils:MOVE_CURSOR(0.30, 0.75, 300, true) -- press the first buy button
        utils:MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
        utils:MOVE_CURSOR(0.78, 0.94, 300, true) -- press the third buy button
        utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
        utils:SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
        util.yield(1500) -- wait for transaction to complete
        utils:CLOSE_BROWSER() -- close browser
    end
}

autoshop["Mission Row"] = {
    name = "Mission Row",
    purchase = function()
        utils:MOVE_CURSOR(0.66, 0.49, 300, true) -- select the autoshop
        utils:MOVE_CURSOR(0.30, 0.75, 300, true) -- press the first buy button
        utils:MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
        utils:MOVE_CURSOR(0.78, 0.94, 300, true) -- press the third buy button
        utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
        utils:SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
        util.yield(1500) -- wait for transaction to complete
        utils:CLOSE_BROWSER() -- close browser
    end
}

autoshop["Burton"] = {
    name = "Burton",
    purchase = function()
        utils:MOVE_CURSOR(0.585, 0.32, 300, true) -- select the autoshop
        utils:MOVE_CURSOR(0.30, 0.75, 300, true) -- press the first buy button
        utils:MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
        utils:MOVE_CURSOR(0.78, 0.94, 300, true) -- press the third buy button
        utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
        utils:SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
        util.yield(1500) -- wait for transaction to complete
        utils:CLOSE_BROWSER() -- close browser
    end
}

function autoshop:SELECT_INTERNET_FILTER()
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

    utils:MOVE_CURSOR(start_x, start_y, 100, true) -- select the internet filter
    utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to select the internet filter
end

function autoshop:init(script)
    -- add autoshop recovery option to the menu
    local owned_data = script:GET_OWNED_PROPERTY_DATA("autoshop")

    script:add(
        script.root:list("Autoshop", {}, "autoshop recovery options", function()
            local ref = menu.ref_by_rel_path(script.root, "Autoshop")
            if owned_data == nil then
                ref:focus() -- prevent access
                script:notify("You do not own a autoshop, purchase a autoshop to access this feature")
            end
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
        script.autoshop_presets:list_select("Money", {}, "", script.money_options, 1, function() end),
        "autoshop_presets_money"
    )

    -- add buy autoshop
    script:add(
        script.autoshop_presets:action("Buy Autoshop", {}, "Automatically buys a autoshop for you", function()
            script.states.bypass_blocked_state = true
            local owned_data = script:GET_OWNED_PROPERTY_DATA("autoshop")
            local choice = autoshop.afk_options.available[math.random(#autoshop.afk_options.available)]
            script.states.block_purchase = false

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

            utils:OPEN_INTERNET(script, 300)
            autoshop:SELECT_INTERNET_FILTER()
            script:PURCHASE_PROPERTY(autoshop, choice)
            script.states.bypass_blocked_state = false
        end),
        "autoshop_presets_buy"
    )

    -- add set value
    script:add(
        script.autoshop_presets:action("Set Value", {}, "Sets the value of your autoshop", function()
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
            menu.trigger_command(script.autoshop_presets_set_value)
        end),
        "autoshop_presets_loop_set_value"
    )

    -- add divider for afk loop
    script.autoshop_presets:divider("AFK Money Loop")

    -- create options for first autoshop (get all autoshops that don't own)
    local autoshop_options = {}
    local owned_data = script:GET_OWNED_PROPERTY_DATA("autoshop")

    for key, value in pairs(autoshop.afk_options.available) do
        if value ~= owned_data.name then
            table.insert(autoshop_options, value)
        end
    end

    -- add first autoshop option
    script:add(
        script.autoshop_presets:list_select("First Autoshop", {}, "", autoshop_options, 1, function()
            -- change the second autoshop option to a different autoshop
            local ref = menu.ref_by_rel_path(script.autoshop_presets, "First Autoshop")
            local ref1 = menu.ref_by_rel_path(script.autoshop_presets, "Second Autoshop")

            while ref.value == ref1.value do
                ref1.value = math.random(1, 2)
                util.yield()
            end
        end),
        "autoshop_presets_afk_first"
    )

    -- modify the options for the second autoshop
    local autoshop1_options = {}

    for key, value in pairs(autoshop.afk_options.available) do
        if value == owned_data.name or value ~= autoshop.afk_options.available[script.autoshop_presets_afk_first.value] then
            table.insert(autoshop1_options, value)
        end
    end

    -- add second autoshop option
    script:add(
        script.autoshop_presets:list_select("Second Autoshop", {}, "", autoshop1_options, 1, function()
            -- change this autoshop option to a different autoshop
            local ref = menu.ref_by_rel_path(script.autoshop_presets, "First Autoshop")
            local ref1 = menu.ref_by_rel_path(script.autoshop_presets, "Second Autoshop")

            while ref.value == ref1.value do
                ref1.value = math.random(1, 2)
                util.yield()
            end
        end),
        "autoshop_presets_afk_second"
    )

    -- add afk loop option
    script:add(
        script.autoshop_presets:toggle("AFK Loop", {}, "Automatically alternates between buying the 2 selected autoshops", function(state)
            local first = script.autoshop_presets_afk_first
            local second = script.autoshop_presets_afk_second
            local afk = menu.ref_by_rel_path(script.autoshop_presets, "AFK Loop")
            script.states.block_purchase = false
            
            util.create_tick_handler(function()
                util.yield(100) -- small delay before starting

                if afk.value then
                    if not script.states.block_purchase then
                        script:STAT_SET_INT("PROP_AUTO_SHOP_VALUE", script.MAX_INT, true) -- set value to max int
                        utils:OPEN_INTERNET(script, 200)
                        autoshop:SELECT_INTERNET_FILTER()
                        script:PURCHASE_PROPERTY(autoshop, autoshop_options[first.value])
                        util.yield(1000)
                        script:STAT_SET_INT("PROP_AUTO_SHOP_VALUE", script.MAX_INT, true) -- set value to max int
                        utils:OPEN_INTERNET(script, 200)
                        autoshop:SELECT_INTERNET_FILTER()
                        script:PURCHASE_PROPERTY(autoshop, autoshop1_options[second.value])
                        util.yield(1000)
                    end
                else
                    script.states.block_purchase = true
                    return false
                end

                util.yield(500) -- delay before next tick
            end)
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
            script.states.bypass_blocked_state = true
            local owned_data = script:GET_OWNED_PROPERTY_DATA("autoshop")
            local choice = autoshop.afk_options.available[math.random(#autoshop.afk_options.available)]
            script.states.block_purchase = false

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

            utils:OPEN_INTERNET(script, 300)
            autoshop:SELECT_INTERNET_FILTER()
            script:PURCHASE_PROPERTY(autoshop, choice)
            script.states.bypass_blocked_state = false
        end),
        "autoshop_custom_buy"
    )
end

return autoshop