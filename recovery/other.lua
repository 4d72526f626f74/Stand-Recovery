local other_methods = setmetatable({}, {__index = _G})

function other_methods:init(script)
    local loops = 0 -- number of loops for criminal damage money method
    local start = os.time() -- timer

    -- add other methods to the menu
    script:add(
        script.root:list("Other", {}, "Other methods",
        function()
            util.show_corner_help("If you plan on using the Criminal Damage Money method, make sure you are the host of the session and that the player you want to give money to is in a CEO with you as their associate (this method does not work for you)")
        end),
        "other"
    )

    -- add criminal damage money loop to the menu
    script:add(
        script.other:toggle_loop("Criminal Damage Loop", {}, "Give other players money through criminal damage freeroam event, you need to be the host and be an associate of the organisation of the player you wish to give money to", function()
            while players.get_script_host() ~= script.me do
                script:notify("Forcing script host")
                menu.trigger_commands("scripthost")
                util.yield(1000)
            end

            memory.write_float(script.globals.criminal_damage.cash_multiplier, 2.5) -- cash multiplier
            memory.write_int(script.globals.criminal_damage.time_limit, 2000) -- time limit
            memory.write_int(script.globals.criminal_damage.start_time, 2000) -- start timer
            memory.write_int(script.globals.criminal_damage.players_required, 0) -- players required (bypasses default 3 player requirement when there are 2 players in the session)

            local base = menu.ref_by_command_name("runscript")
            local ref = menu.ref_by_rel_path(base, "Freemode Activities")
            local criminal_damage = menu.ref_by_rel_path(ref, "Criminal Damage")
            local session = menu.ref_by_rel_path(menu.ref_by_path("Online>Session"), "Session Scripts")
            local criminal_damage1 = menu.ref_by_rel_path(session, "Criminal Damage")
            local stop = menu.ref_by_rel_path(criminal_damage1, "Stop Script")
            local score = menu.ref_by_rel_path(criminal_damage1, "Score")

            criminal_damage:trigger() -- start criminal damage
            util.yield(2250) -- wait for the script to start
            score:trigger(600000)
            util.yield(2000) -- wait for the score to update
            stop:trigger() -- stop the script
            util.yield(2000) -- wait for the script to stop
            stop:trigger() -- stop the script again

            loops = loops + 1
            if loops % 2 == 0 and loops > 0 then
                start = os.time() + 90
                while os.time() < start and menu.ref_by_rel_path(script.other, "Criminal Damage Loop").value do
                    if not menu.ref_by_rel_path(script.other, "Criminal Damage Loop").value then break end
                    script:notify("Waiting " .. start - os.time() .. " seconds")
                    util.yield(5000)
                end
            end
        end,
        function()
            loops = 0
        end),
        "other_criminal_damage_money"
    )
end

return other_methods