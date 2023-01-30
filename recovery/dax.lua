local dax = setmetatable({}, {__index = _G})

local utils = require("lib.recovery.utils") -- require the utils module

function dax:init(script)
    -- add dax to the menu
    script:add(
        script.root:list("Dax Missions", {}, "", function()
            script:notify("Check 'enable cash boost' option and start one of the new dax missions (if you haven't completed the first mission the 'Start Mission' will automatically start the first mission for you, the R on the map at sandy shores), once the mission has started you need to kill yourself immediately to fail the mission and you will recieve $1,000,000, take too long to kill yourself during the mission and you won\'t get any money", util.show_corner_help)
        end),
        "dax"
    )
    
    -- add divider for help
    script.dax:divider("Help")

    -- add button for showing the help
    script:add(
        script.dax:action("How To Use", {}, "Shows a help message", function()
            script:notify("Check 'enable cash boost' option and start one of the new dax missions (if you haven't completed the first mission the 'Start Mission' will automatically start the first mission for you, the R on the map at sandy shores), once the mission has started you need to kill yourself immediately to fail the mission and you will recieve $1,000,000, take too long to kill yourself during the mission and you won\'t get any money", util.show_corner_help)
        end),
        "dax_help"
    )

    -- add divider for compatible missions then add the compatible missions
    script.dax:divider("Compatible Missions")
    script.dax:readonly("First Dose - Welcome to the Troupe")
    script.dax:readonly("First Dose - Designated Driver")
    script.dax:readonly("First Dose - Fatal Incursion")
    script.dax:readonly("First Dose - Uncontrolled Substance")
    script.dax:readonly("First Dose - Make War not Love")
    script.dax:readonly("First Dose - Off the Rails")

    -- add options divider
    script.dax:divider("Options")

    script.dax:action("Make 1M - First Dose 1", {}, "Automatically completes requirements to make $1M from First Dose 1 mission", function()
        -- wait until player has fully loaded before trying to do anything
        while script:GET_TRANSITION_STATE() ~= 66 do
            util.yield()
        end

        ENTITY.SET_ENTITY_COORDS(script.me_ped, 1394.4620361328, 3598.4528808594, 34.990489959717)
        util.yield(200)
        utils:SIMULATE_CONTROL_KEY(51, 1)
        util.yield(1500)
        utils:SIMULATE_CONTROL_KEY(188, 1, 2)
        utils:SIMULATE_CONTROL_KEY(201, 1)
        utils:SIMULATE_CONTROL_KEY(188, 1, 2)
        utils:SIMULATE_CONTROL_KEY(201, 1)
        utils:SIMULATE_CONTROL_KEY(201, 1, 2)
        util.yield(6000)
        memory.write_float(script.globals.modifiers.cash, 5000.0)
        menu.trigger_commands("suicide")
        util.yield(3000)
        menu.trigger_commands("suicide")
        util.yield(3000)
        menu.trigger_commands("suicide")
        util.yield(4500)
        utils:SIMULATE_CONTROL_KEY(201, 10)
    end)

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