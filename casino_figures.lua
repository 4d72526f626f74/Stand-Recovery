local figures = setmetatable({}, {__index = _G})

figures.globals = {
    cash = memory.script_global(262145 + 27123)
}

function figures:init(script)
    script:add(
        script.root:list("Casino Figures", {}, "", function()
            script:notify("Stop using this when you start getting transaction errors", util.show_corner_help)
        end),
        "casino_figures"
    )

    script:add(
        script.casino_figures:toggle("Modify Value", {}, "Modify the value of the figure to $200,000", function(state)
            if state then
                memory.write_int(figures.globals.cash, 200000) -- 200k is the max value
            else
                memory.write_int(figures.globals.cash, 1000)
            end
        end),
        "casino_figures_modify_value"
    )

    script:add(
        script.casino_figures:toggle("Enable Drop", {}, "Starts dropping casino figures on you", function(state)
            local ref = menu.ref_by_rel_path(script.casino_figures, "Enable Drop")
            menu.trigger_commands("rp" .. players.get_name(script.me) .. " on")
            memory.write_int(figures.globals.cash, 200000)

            util.create_tick_handler(function()
                if ref.value then
                    if script:TRANSACTION_ERROR_DISPLAYED() then
                        menu.trigger_commands("rp" .. players.get_name(script.me) .. " off")
                        ref.value = false
                        script:notify("Transaction error detected")
                    end
                else
                    menu.trigger_commands("rp" .. players.get_name(script.me) .. " off")
                    return false
                end
            end)
        end),
        "casino_figures_enable_drop"
    )

    script:add(
        script.casino_figures:toggle("Disable RP", {}, "Prevents you from gaining RP when collecting figures", function(state)
            if state then
                memory.write_float(script.globals.modifiers.rp, 0.0)
            else
                memory.write_float(script.globals.modifiers.rp, 1.0)
            end
        end),
        "casino_figures_disable_rp"
    )
end

return figures