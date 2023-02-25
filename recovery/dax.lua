local dax = setmetatable({}, {__index = _G})

local utils = require("lib.recovery.utils") -- require the utils module

dax.missions = {
    "Welcome to the Troupe",
    "Designated Driver",
    "Fatal Incursion",
    "Uncontrolled Substance",
    "Make War Not Love",
    "Off the Rails"
}

function dax:init(script)
    -- add dax to the menu
    script:add(
        script.root:list("Dax Missions", {}, "", function()
            script:notify("Select a mission then press 'Start Mission' button, when you get into the mission make sure that you fail it (script should automatically start the mission and cause it to fail), you can also manually do this by going to the mission blip (~HUD_COLOUR_YELLOW~~BLIP_DEVIN~~s~) on the map and starting it with 'Enable Cash Boost' enabled (make sure it's enabled before failing the mission)", util.show_corner_help)
        end),
        "dax"
    )
    
    -- add divider for help
    script.dax:divider("Help")

    -- add button for showing the help
    script:add(
        script.dax:action("How To Use", {}, "Shows a help message", function()
            script:notify("Select a mission then press 'Start Mission' button, when you get into the mission make sure that you fail it (script should automatically start the mission and cause it to fail), you can also manually do this by going to the mission blip (~HUD_COLOUR_YELLOW~~BLIP_DEVIN~~s~) on the map and starting it with 'Enable Cash Boost' enabled (make sure it's enabled before failing the mission)", util.show_corner_help)
        end),
        "dax_help"
    )

    -- add divider for compatible missions then add the compatible missions
    script.dax:divider("Compatible Missions")
    script.dax:readonly("First Dose - Welcome to the Troupe")
    script.dax:readonly("First Dose - Designated Driver")
    script.dax:readonly("First Dose - Fatal Incursion")
    script.dax:readonly("First Dose - Uncontrolled Substance")
    script.dax:readonly("First Dose - Make War Not Love")
    script.dax:readonly("First Dose - Off the Rails")

    -- add missison teleports divider
    script.dax:divider("Missions")

    -- add mission selector
    script.dax:list_select("Mission", {}, "Select a mission to start", dax.missions, 1, function() end)

    -- add start mission button
    script.dax:action("Start Mission", {}, "Start the selected mission to make an ez $1,000,000", function()
        local index = menu.ref_by_rel_path(script.dax, "Mission").value
        local mission = dax.missions[index]

        local function START_MISSION()
            utils:MENU_OPEN_ERROR()
            utils:SIMULATE_CONTROL_KEY(51, 1)
            util.yield(1500)
            utils:SIMULATE_CONTROL_KEY(188, 1, 2, 500)
            utils:SIMULATE_CONTROL_KEY(201, 1, 0, 500)
            utils:SIMULATE_CONTROL_KEY(188, 1, 2, 500)
            utils:SIMULATE_CONTROL_KEY(201, 1, 0, 500)
            utils:SIMULATE_CONTROL_KEY(201, 1, 2, 500)
            util.yield(6000)
            memory.write_float(script.globals.modifiers.cash, 5000.0)
            menu.trigger_commands("suicide")
            util.yield(3000)
            menu.trigger_commands("suicide")
            util.yield(3000)
            menu.trigger_commands("suicide")
            util.yield(6000)
            menu.trigger_commands("suicide")
            util.yield(4500)
            utils:SIMULATE_CONTROL_KEY(201, 10)
        end

        while script:GET_TRANSITION_STATE() ~= 66 do
            util.yield()
        end

        if mission == "Welcome to the Troupe" then
            local ron_pos = v3.new(1394.4620361328, 3598.4528808594, 34.990489959717)
            local blip = script:GET_CLOSEST_BLIP_TO_COORDS(739, ron_pos)

            if blip ~= 0 then
                if HUD.DOES_BLIP_EXIST(blip) then
                    local pos = HUD.GET_BLIP_COORDS(blip)
                    local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, ron_pos.x, ron_pos.y, ron_pos.z)

                    if dist < 10 then
                        ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                        START_MISSION()
                    else
                        script:notify("First Dose 1 - Welcome to the Troupe mission is already completed or not unlocked!")
                    end
                end
            else
                script:notify("First Dose 1 - Welcome to the Troupe mission is already completed or not unlocked!")
            end
        end

        if mission == "Designated Driver" then
            local dax_pos = v3.new(614.97247314453, -387.58212280273, 24.799682617188)
            local blip = script:GET_CLOSEST_BLIP_TO_COORDS(355, dax_pos)

            if blip ~= 0 then
                if HUD.DOES_BLIP_EXIST(blip) then
                    local pos = HUD.GET_BLIP_COORDS(blip)
                    local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, dax_pos.x, dax_pos.y, dax_pos.z)

                    if dist < 10 then
                        ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                        START_MISSION()
                    else
                        script:notify("First Dose 2 - Designated Driver is already completed or not unlocked!")
                    end
                end
            else
                script:notify("First Dose 2 - Designated Driver mission is already completed or not unlocked!")
            end
        end

        if mission == "Fatal Incursion" then
            local dax_pos = v3.new(614.97247314453, -387.58212280273, 24.799682617188)
            local blip = script:GET_CLOSEST_BLIP_TO_COORDS(355, dax_pos)

            if blip ~= 0 then
                if HUD.DOES_BLIP_EXIST(blip) then
                    local pos = HUD.GET_BLIP_COORDS(blip)
                    local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, dax_pos.x, dax_pos.y, dax_pos.z)

                    if dist < 10 then
                        ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                        START_MISSION()
                    else
                        script:notify("First Dose 3 - Fatal Incursion is already completed or not unlocked!")
                    end
                end
            else
                script:notify("First Dose 3 - Fatal Incursion mission is already completed or not unlocked!")
            end
        end

        if mission == "Uncontrolled Love" then
            local dax_pos = v3.new(614.97247314453, -387.58212280273, 24.799682617188)
            local blip = script:GET_CLOSEST_BLIP_TO_COORDS(355, dax_pos)

            if blip ~= 0 then
                if HUD.DOES_BLIP_EXIST(blip) then
                    local pos = HUD.GET_BLIP_COORDS(blip)
                    local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, dax_pos.x, dax_pos.y, dax_pos.z)

                    if dist < 10 then
                        ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                        START_MISSION()
                    else
                        script:notify("First Dose 4 - Uncontrolled Love is already completed or not unlocked!")
                    end
                end
            else
                script:notify("First Dose 4 - Uncontrolled Love mission is already completed or not unlocked!")
            end
        end

        if mission == "Make War Not Love" then
            local dax_pos = v3.new(614.97247314453, -387.58212280273, 24.799682617188)
            local blip = script:GET_CLOSEST_BLIP_TO_COORDS(355, dax_pos)

            if blip ~= 0 then
                if HUD.DOES_BLIP_EXIST(blip) then
                    local pos = HUD.GET_BLIP_COORDS(blip)
                    local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, dax_pos.x, dax_pos.y, dax_pos.z)

                    if dist < 10 then
                        ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                        START_MISSION()
                    else
                        script:notify("First Dose 5 - Make War Not Love is already completed or not unlocked!")
                    end
                end
            else
                script:notify("First Dose 5 - Make War Not Love mission is already completed or not unlocked!")
            end
        end

        if mission == "Off The Rails" then
            local dax_pos = v3.new(614.97247314453, -387.58212280273, 24.799682617188)
            local blip = script:GET_CLOSEST_BLIP_TO_COORDS(355, dax_pos)

            if blip ~= 0 then
                if HUD.DOES_BLIP_EXIST(blip) then
                    local pos = HUD.GET_BLIP_COORDS(blip)
                    local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, dax_pos.x, dax_pos.y, dax_pos.z)

                    if dist < 10 then
                        ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
                        START_MISSION()
                    else
                        script:notify("First Dose 6 - Off The Rails is already completed or not unlocked!")
                    end
                end
            else
                script:notify("First Dose 6 - Off The Rails mission is already completed or not unlocked!")
            end
        end
    end)

    -- add options divider
    script.dax:divider("Options")

    script.dax:toggle_loop("Enable Cash Boost", {}, "Modifies cash multiplier", function()
        memory.write_float(script.globals.modifiers.cash, 5000.0)
    end,
    function()
        memory.write_float(script.globals.modifiers.cash, 1.0)
    end)

    script.dax:toggle_loop("Enable RP Boost", {}, "Modifies RP multiplier", function()
        memory.write_float(script.globals.modifiers.rp, 2000.0)
    end,
    function()
        memory.write_float(script.globals.modifiers.rp, 1.0)
    end)
end

return dax