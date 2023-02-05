local drops = setmetatable({}, {__index = _G})
local char = util.get_char_slot()

function drops:init(script)
    -- add drops to the menu
    script:add(
        script.root:list("Drops", {}, "Money drop"),
        "drops"
    )

    -- add money drop divider to the menu
    script.drops:divider("Money Drop")

    -- add enable to the menu
    script:add(
        script.drops:toggle_loop("Enable Drop", {}, "Enable money drop", function() 
            local amount = script.drops_drop_amount.value
            local delay = script.drops_loop_delay.value

            if not script:TRANSACTION_ERROR_DISPLAYED() then
                memory.write_int(script.globals.caps.cash_pickup, amount)
                memory.write_int(script.globals.caps.cash_recieved, script.MAX_INT)
                local pos = ENTITY.GET_ENTITY_COORDS(script.me_ped, true, true, true)
                OBJECT.CREATE_MONEY_PICKUPS(pos.x, pos.y, pos.z, amount, 1, 0, 0)

                for i, pickup in pairs(entities.get_all_pickups_as_handles()) do
                    local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(pickup))
                    local pos = ENTITY.GET_ENTITY_COORDS(script.me_ped, true, true, true)
                    if model == "prop_cash_pile_01" then
                        ENTITY.SET_ENTITY_COORDS(pickup, pos.x, pos.y, pos.z, true, true, true, true)
                    end
                end
            else
                menu.ref_by_rel_path(script.drops, "Enable Drop").value = false
            end

            util.yield(delay)
        end),
        "drops_enable"
    )

    -- add drop delay slider to the menu
    script:add(
        script.drops:slider("Loop Delay", {}, "Loop delay in seconds", 0, script.MAX_INT, 500, 100, function() end),
        "drops_loop_delay"
    )

    -- add drop amount slider to the menu
    script:add(
        script.drops:slider("Money", {}, "Amount of money to drop", 100, 10000, 10000, 100, function() end),
        "drops_drop_amount"
    )

    -- ped cash divider to the menu
    script.drops:divider("Ped Cash")

    -- add ped cash enable to the menu
    script:add(
        script.drops:toggle_loop("Enable", {}, "Changes amount of money that peds drop", function() 
            local amount = script.drops_ped_cash_amount.value
            
            if not script:TRANSACTION_ERROR_DISPLAYED() then
                memory.write_int(script.globals.caps.cash_pickup, amount)
                memory.write_int(script.globals.caps.cash_recieved, script.MAX_INT)

                for i, ped in pairs(entities.get_all_peds_as_handles()) do
                    if not PED.IS_PED_A_PLAYER(ped) then
                        PED.SET_PED_MONEY(ped, script.drops_ped_cash_amount.value)
                    end
                end
            else
                menu.ref_by_rel_path(script.drops, "Enable").value = false
                menu.ref_by_rel_path(script.drops, "Collect").value = false
            end
        end),
        "drops_ped_cash_enable"
    )

    -- add collect ped cash to the menu
    script:add(
        script.drops:toggle_loop("Collect", {}, "Collects all the money that peds have dropped", function() 
            if not script:TRANSACTION_ERROR_DISPLAYED() then
                for i, pickup in pairs(entities.get_all_pickups_as_handles()) do
                    local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(pickup))
                    local pos = ENTITY.GET_ENTITY_COORDS(script.me_ped, true, true, true)
                    if model == "prop_cash_pile_01" then
                        ENTITY.SET_ENTITY_COORDS(pickup, pos.x, pos.y, pos.z, true, true, true, true)
                    end
                end
            end
        end),
        "drops_ped_cash_collect"
    )

    -- add ped cash slider to the menu
    script:add(
        script.drops:slider("Money", {}, "Amount of money the ped will drop when dead", 100, 10000, 10000, 100, function() end),
        "drops_ped_cash_amount"
    )
end

return drops