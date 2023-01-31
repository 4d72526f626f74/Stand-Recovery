local nightclub = setmetatable({}, {__index = _G})
local char = util.get_char_slot()

local utils = require("lib.recovery.utils") -- require the utils module

nightclub.value = util.joaat("MP" .. char .. "_PROP_NIGHTCLUB_VALUE") -- stat for nightclub value
nightclub.owned = util.joaat("MP" .. char .. "_NIGHTCLUB_OWNED") -- stat for owned nightclub id
nightclub.offset = 0.05
nightclub.name = "nightclub"

nightclub.globals = { -- nightclub specific globals
    prices = {
        ["La Mesa"] = memory.script_global(262145 + 24838),
        ["Mission Row"] = memory.script_global(262145 + 24843),
        ["Vespucci Canals"] = memory.script_global(262145 + 24845)
    },
    safe = memory.script_global(262145 + 24045),
    income = memory.script_global(262145 + 24041),
}

nightclub.afk_options = {
    available = {"La Mesa", "Mission Row", "Vespucci Canals"},
}

function nightclub:SELECT_INTERNET_FILTER()
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

    utils:MOVE_CURSOR(start_x, start_y, 100, true) -- select the internet filter
    utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to select the internet filter
end

function nightclub:init(script)
    -- add la mesa nightclub
    nightclub["La Mesa"] = {
        name = "La Mesa",
        purchase = function()
            utils:MOVE_CURSOR(0.69, 0.58, 300, true) -- select the nightclub
            utils:MOVE_CURSOR(0.30, 0.73, 300, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.93, 300, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy butwton
            utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:CLOSE_BROWSER() -- close browser
        end
    }

    -- add mission row nightclub
    nightclub["Mission Row"] = {
        name = "Mission Row",
        purchase = function()
            utils:MOVE_CURSOR(0.64, 0.51, 300, true) -- select the nightclub
            utils:MOVE_CURSOR(0.30, 0.73, 300, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.93, 300, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy butwton
            utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:CLOSE_BROWSER() -- close browser
        end
    }

    -- add vespucci canals nightclub
    nightclub["Vespucci Canals"] = {
        name = "Vespucci Canals",
        purchase = function()
            utils:MOVE_CURSOR(0.479, 0.54, 300, true) -- select the nightclub
            utils:MOVE_CURSOR(0.30, 0.73, 300, true) -- press the first buy button
            utils:MOVE_CURSOR(0.30, 0.93, 300, true) -- press the second buy button
            utils:MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
            utils:SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
            utils:SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
            util.yield(1500) -- wait for transaction to complete
            script:CLOSE_BROWSER() -- close browser
        end
    }

    -- add nightclub recovery option to the menu
    local owned_data = script:GET_OWNED_PROPERTY_DATA("nightclub")

    script:add(
        script.root:list("Nightclub", {}, "Nightclub recovery options", function()
            local ref = menu.ref_by_rel_path(script.root, "Nightclub")
            if owned_data == nil then
                ref:focus() -- prevent access
                script:notify("You do not own a nightclub, purchase a nightclub to access this feature")
            end
        end),
        "nightclub_recovery"
    )
    
    script.nightclub_recovery:divider("1B Recovery")

    script:add(
        script.nightclub_recovery:list("Presets", {}, "Presets for 1B Recovery"),
        "nightclub_presets"
    )

    script:add(
        script.nightclub_recovery:list("Custom", {}, "Customisable options for 1B Recovery"),
        "nightclub_custom"
    )

    script.nightclub_recovery:divider("Nightclub Safe")

    script:add(
        script.nightclub_recovery:action("Teleport To Nightclub", {}, "Teleports to your nightclub", function()
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
        script.nightclub_recovery:action("Trigger Production", {}, "Triggers production at your nightclub", function()
            memory.write_int(nightclub.globals.safe, 300000) -- set the maximum amount of money the safe can hold
            memory.write_int(nightclub.globals.income, 300000) -- set the amount of income to maximum

            script:STAT_SET_INT("CLUB_PAY_TIME_LEFT", 1, true) -- set the time left to 1 second
            script:STAT_SET_INT("CLUB_POPULARITY", 10000, true) -- set the popularity to 10000
        end),
        "nightclub_trigger_production"
    )

    script:add(
        script.nightclub_recovery:toggle_loop("Fill Safe", {}, "Fills your nightclub safe", function()
            menu.trigger_command(script.nightclub_trigger_production) -- trigger production
        end),
        "nightclub_fill_safe"
    )

    script:add(
        script.nightclub_recovery:toggle("AFK Loop", {}, "AFK Money Loop", function(state)
            local fill = script.nightclub_fill_safe
            local afk = menu.ref_by_rel_path(script.nightclub_recovery, "AFK Loop")

            if not script:IS_INSIDE_OF_INTERIOR("nightclub") then
                script:notify("You are not inside of your nightclub")
                afk.value = false
                return
            end

            fill.value = state

            util.create_tick_handler(function()
                if afk.value then
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
                else
                    util.yield(1000)
                    utils:SIMULATE_CONTROL_KEY(51, 1)
                    fill.value = false
                    script.states.nightclub.safe_open = false
                    script.states.nightclub.infront_of_safe = false
                    return false
                end
        
                util.yield(1)
            end)
        end),
        "nightclub_safe_afk_loop"
    )

    -- add options divider
    script.nightclub_presets:divider("Options")

    -- add the nightclub presets
    script:add(
        script.nightclub_presets:list_select("Money", {}, "", script.money_options, 1, function() end),
        "nightclub_presets_money"
    )

    -- add buy nightclub
    script:add(
        script.nightclub_presets:action("Buy Nightclub", {}, "Automatically buys a nightclub for you", function()
            local owned_data = script:GET_OWNED_PROPERTY_DATA("nightclub")
            local club = nightclub.afk_options.available[math.random(#nightclub.afk_options.available)]

            while owned_data.name == club do
                club = nightclub.afk_options.available[math.random(#nightclub.afk_options.available)]
                util.yield()
            end

            local price = memory.read_int(nightclub.globals.prices[club])
            if club == "La Mesa" then price = price + 400000 end
            local value = script:CONVERT_VALUE(script.money_options[script.nightclub_presets_money.value])
            value = (value + price) * 2

            script:STAT_SET_INT("PROP_NIGHTCLUB_VALUE", value, true)

            utils:OPEN_INTERNET(script, 300)
            nightclub:SELECT_INTERNET_FILTER()
            script:PURCHASE_PROPERTY(nightclub, club)
        end),
        "nightclub_presets_buy"
    )

    -- add set value
    script:add(
        script.nightclub_presets:action("Set Value", {}, "Sets the value of your nightclub", function()
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
        script.nightclub_presets:toggle_loop("Loop Set Value", {}, "Does the same as set value but instead of setting it once it sets it repeatedly", function()
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

    -- block phone calls
    script:add(
        script.nightclub_presets:toggle("Block Phone Calls", {}, "Blocks incoming phones calls", function(state)
            local phone_calls = menu.ref_by_command_name("nophonespam")
            phone_calls.value = state
        end),
        "nightclub_presets_block_phone_calls"
    )

    -- add afk loop option
    script:add(
        script.nightclub_presets:toggle_loop("AFK Loop", {}, "Alternates between buying nightclubs you don\'t own", function(state)
            local afk = menu.ref_by_rel_path(script.nightclub_presets, "AFK Loop")
            local owned_data = script:GET_OWNED_PROPERTY_DATA("nightclub")

            util.yield(100) -- small delay before starting

            local club = nightclub.afk_options.available[math.random(#nightclub.afk_options.available)]

            script:STAT_SET_INT("PROP_NIGHTCLUB_VALUE", script.MAX_INT, true) -- set value to max int
            utils:OPEN_INTERNET(script, 200)
            nightclub:SELECT_INTERNET_FILTER()
            script:PURCHASE_PROPERTY(nightclub, club)
            club = nightclub.afk_options.available[math.random(#nightclub.afk_options.available)]
            util.yield(1500)
            script:STAT_SET_INT("PROP_NIGHTCLUB_VALUE", script.MAX_INT, true) -- set value to max int
            utils:OPEN_INTERNET(script, 200)
            nightclub:SELECT_INTERNET_FILTER()
            script:PURCHASE_PROPERTY(nightclub, club)
            util.yield(2000)
        end),
        "nightclub_presets_afk_loop"
    )

    -- add options for custom
    script:add(
        script.nightclub_custom:text_input("Money", {"rsnightclubvalue"}, "The nightclub value", function(value)
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
        script.nightclub_custom:action("Buy Nightclub", {}, "Buys a nightclub", function()
            local owned_data = script:GET_OWNED_PROPERTY_DATA("nightclub")
            local club = nightclub.afk_options.available[math.random(#nightclub.afk_options.available)]

            while owned_data.name == club do
                club = nightclub.afk_options.available[math.random(#nightclub.afk_options.available)]
                util.yield()
            end

            local price = memory.read_int(nightclub.globals.prices[club])
            if club == "La Mesa" then price = price + 400000 end
            local value = tonumber(script.nightclub_custom_money.value)
            value = (value + price) * 2

            script:STAT_SET_INT("PROP_NIGHTCLUB_VALUE", value, true)

            utils:OPEN_INTERNET(script, 300)
            nightclub:SELECT_INTERNET_FILTER()
            script:PURCHASE_PROPERTY(nightclub, club)
        end),
        "nightclub_custom_buy"
    )
end

return nightclub