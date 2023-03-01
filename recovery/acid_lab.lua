local lab = setmetatable({}, {__index = _G})

local script = require("lib.recovery.script")

lab.teleports = {
    inside = v3(486.8305, -2625.264, -50),
    source_supplies = v3(480.76102, -2625.1067, -49.664055),
    sell_acid = v3(480.7342, -2624.7778, -49.664055)
}

lab.globals = {
    support_bike_cooldown = script:global(262145 + 21865), -- script:global(262145 + 21865) -- unused due to support bike having no cooldown yet
    acid_lab_cooldown = script:global(262145 + 21866),
    supplies_cost_per_segment = script:global(262145 + 21869), -- default is 1200
    supplies_cost_per_segment_base = script:global(262145 + 21870), -- default is 1200
    boost_amount = script:global(262145 + 21871),
    boost_expiry = script:global(262145 + 21872),
    product_rename_price = script:global(262145 + 21873),
    rename_price = script:global(262145 + 21874),
    utility_fee = script:global(262145 + 21867), -- not sure what this does yet
    equipment_upgrade_utility_fee = script:global(262145 + 21868), -- not sure what this does yet
    product_capacity = script:global(262145 + 18949),
    product_value = script:global(262145 + 17425), -- 1485 is the default value,
    production_time = script:global(262145 + 17396), -- default is 135000
    utility_cost = script:global(262145 + 18950),
    resupply_crate_value = script:global(262145 + 32700), -- default is 25
    damage_scale = script:global(262145 + 32693),
    resupply_timer = script:global(1648637 + 7), -- Global_1648637[iParam0]) >= Global_262145.f_18954,
    supplies_delay = script:global(262145 + 18954), -- default is 600,
    request_acid_lab = script:global(2793046 + 938), -- from heist control
}

function lab:init(script)
    -- add lab to the menu
    script:add(
        script.root:list("Acid Lab", {"acidlab"}, "Acid Lab Manager"),
        "acid_lab"
    )

    -- add a divider for acid lab manager
    script.acid_lab:divider("Acid Lab Manager")

    -- add boost amount to the menu
    script:add(
        script.acid_lab:text_input("Acid Production Boost", {"rsacidprodboost"}, "The amount to boost acid production by after completing acid production boost within your acid lab", function(value)
            lab.globals.boost_amount:write_int(tonumber(value))
        end, tostring(lab.globals.boost_amount:read_int())),
        "acid_lab_boost_amount"
    )

    -- add boost expiration delay to the menu
    script:add(
        script.acid_lab:text_input("Boost Expiration Delay", {"rsacidprodboostexpdelay"}, "The period of time that acid production is boosted for in seconds (1 day default)", function(value)
            lab.globals.boost_expiry:write_int(tonumber(value))
        end, tostring(lab.globals.boost_expiry:read_int())),
        "acid_lab_boost_expiration_delay"
    )

    -- add product capacity to the menu
    script:add(
        script.acid_lab:text_input("Product Capacity", {"rsacidprodcapacity"}, "The amount of acid your acid lab is able to hold before it\'s full and production is halted", function(value)
            value = tonumber(value)
            if value < 0 then
                value = 160
            end

            lab.globals.product_capacity:write_int(tonumber(value))
        end, tostring(lab.globals.product_capacity:read_int())),
        "acid_lab_product_capacity"
    )

    -- add product value to the menu
    script:add(
        script.acid_lab:text_input("Product Value", {"rsacidprodvalue"}, "The value of 1 acid unit", function(value)
            lab.globals.product_value:write_int(tonumber(value))
        end, tostring(lab.globals.product_value:read_int())),
        "acid_lab_product_value"
    )

    -- add disable acid lab request cooldown to the menu
    script:add(
        script.acid_lab:toggle("Disable Acid Lab Request Cooldown", {}, "Disables the cooldown for acid lab request", function(state)
            lab.globals.acid_lab_cooldown:write_int(state and 0 or 300000)
        end),
        "disable_acid_lab_request_cooldown"
    )

    -- add free supplies to the menu
    script:add(
        script.acid_lab:toggle("Free Supplies", {"freesupplies"}, "Makes supplies free", function(state)
            local segment_cost = lab.globals.supplies_cost_per_segment
            local segment_base = lab.globals.supplies_cost_per_segment_base

            segment_cost:write_int(state and 0 or 12000)
            segment_base:write_int(state and 0 or 12000)
        end),
        "acid_lab_free_supplies"
    )

    -- add trigger production to the menu
    script:add(
        script.acid_lab:toggle("Trigger Production", {"rsacidtriggerprod"}, "Triggers production of acid, to force this into taking effect sooner enter your acid lad then restart production (pause and resume)", function(state)
            local prod_time = lab.globals.production_time
            prod_time:write_int(state and 10 or 135000)
        end),
        "acid_lab_trigger_production"
    )

    -- add product value multiplier to the menu
    script:add(
        script.acid_lab:slider("Product Value Multiplier", {}, "Product value multiplier", 1, 9000, 1, 1, function(value)
            local product_value = lab.globals.product_value
            product_value:write_int(1485 * value)
        end),
        "acid_lab_product_value_multiplier"
    )

    -- add resupply crate value to the menu
    script:add(
        script.acid_lab:slider("Resupply Crate Value", {}, "Resupply crate value", 1, 100, lab.globals.resupply_crate_value:read_int(), 1, function(value)
            local crate_value = lab.globals.resupply_crate_value
            crate_value:write_int(value)
        end),            
        "acid_lab_resupply_crate_value"
    )

    -- add request acid lab to the menu
    script:add(
        script.acid_lab:action("Request Acid Lab", {"rsacidrequest"}, "Delivers your acid lab nearby", function(state)
            local request = lab.globals.request_acid_lab
            request:write_int(1)
        end),
        "acid_lab_request"
    )

    -- add resupply acid lab
    script:add(
        script.acid_lab:action("Resupply Acid Lab", {"rsacidresupply"}, "Resupplies your acid lab instantly", function(state)
            local resupply = lab.globals.resupply_timer
            resupply:write_int(-1)
        end),
        "acid_lab_resupply"
    )

    -- add instantly deliver acid lab supplies
    script:add(
        script.acid_lab:action("Instant Delivery", {"rsacidinstantdelivery"}, "Instantly delivers supplies that were purchased manually", function(state)
            local resupply_delay = lab.globals.supplies_delay

            resupply_delay:write_int(1)
            util.yield(1000)
            resupply_delay:write_int(600)
        end),
        "acid_lab_instantly_delivery"
    )

    -- add instant finish sell mission
    script:add(
        script.acid_lab:action("Instant Finish", {"rsacidinstantfinishsell"}, "Instantly completes sell missions (currently only completes mission with 10 deliveries)", function(state)
            -- credit to IcedoomFist for these locals and link to UC post https://www.unknowncheats.me/forum/3641612-post76.html
            script:local("fm_content_acid_lab_sell", 5192 + 1357 + 2):write_int(9)
            script:local("fm_content_acid_lab_sell", 5192 + 1357 + 2):write_int(10)
            script:local("fm_content_acid_lab_sell", 5192 + 1293):write_int(2)
            
            --script:SET_INT_LOCAL("fm_content_acid_lab_sell", 5192 + 1357 + 2, 9)
            --script:SET_INT_LOCAL("fm_content_acid_lab_sell", 5192 + 1357 + 2, 10)
            --script:SET_INT_LOCAL("fm_content_acid_lab_sell", 5192 + 1293, 2)
        end),
        "acid_lab_instant_finish_sell_mission"
    )

    -- add teleports divider to the menu
    script.acid_lab:divider("Teleports")

    -- add teleport inside acid lab to the menu
    script:add(
        script.acid_lab:action("Teleport Inside Acid Lab", {}, "Teleports you inside of your acid lab", function()
            local inside = lab.teleports.inside
            script:TELEPORT(inside.x, inside.y, inside.z)
        end),
        "acid_lab_teleport_inside"
    )

    -- add teleport to acid lab sourcing to the menu
    script:add(
        script.acid_lab:action("Teleport To Acid Lab Sourcing", {}, "Teleports you to your acid lab sourcing", function()
            local sourcing = lab.teleports.source_supplies
            script:TELEPORT(sourcing.x, sourcing.y, sourcing.z)
        end),
        "acid_lab_teleport_sourcing"
    )

    -- add teleport to sell acid to the menu
    script:add(
        script.acid_lab:action("Teleport To Sell Acid", {}, "Teleports you to your sell acid location", function()
            local sell = lab.teleports.sell_acid
            script:TELEPORT(sell.x, sell.y, sell.z)
        end),
        "acid_lab_teleport_sell"
    )
end

return lab