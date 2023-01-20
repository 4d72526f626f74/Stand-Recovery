local version = "1.1.1"
local root = menu.my_root()

local update_button = root:action("Update Script", {}, "Update the script to the latest version", function()
    async_http.init("raw.githubusercontent.com", "4d72526f626f74/Stand-Recovery/main/Recovery.lua", function(body, headers, status_code)
        if status_code == 200 then
            local file = io.open(filesystem.scripts_dir() .. SCRIPT_RELPATH, "wb")
            file:write(body)
            file:close()

            util.restart_script()
        end
    end)
    async_http.dispatch()
end)

update_button.visible = false

async_http.init("raw.githubusercontent.com", "4d72526f626f74/Stand-Recovery/main/Version", function(body, headers, status_code)
    if status_code == 200 then
        body = body:gsub("%s+", "")
        if body ~= version then
            update_button.visible = true
            util.toast("New version available")
        end
    end
end)
async_http.dispatch()

util.keep_running()
util.require_natives(1672190175)

util.toast("WARNING: All features are considered risky and may result in a ban. Use at your own risk.")

-- dbase = facility
-- businesshub = bunker

local items = {
    settings = {
        root = nil
    },
    presets = {
        root = nil,
        nightclub = {
            root = nil,
            choice = nil,
            afk = nil,
            first_nightclub = nil,
            second_nightclub = nil,
        },
        arcade = {
            root = nil,
            choice = nil
        },
        autoshop = {
            root = nil,
            choice = nil
        },
        agency = {
            root = nil,
            choice = nil
        },
        hanger = {
            root = nil,
            choice = nil
        },
        facility = {
            root = nil,
            choice = nil
        }
    },
    custom = {
        root = nil,
        nightclub = {
            root = nil
        },
        arcade = {
            root = nil
        },
        autoshop = {
            root = nil
        },
        agency = {
            root = nil
        },
        hanger = {
            root = nil
        },
        facility = {
            root = nil
        },
    },
    dax_mission = {
        root = nil,
    },
    casino_figures = {
        root = nil
    }
}

local settings = {
    ownership_check = true,
    verbose = false
}

local stats = {
    nightclub = util.joaat("mp" .. util.get_char_slot() .. "_prop_nightclub_value"),
    arcade = util.joaat("mp" .. util.get_char_slot() .. "_prop_arcade_value"),
    autoshop = util.joaat("mp" .. util.get_char_slot() .. "_prop_auto_shop_value"),
    agency = util.joaat("mp" .. util.get_char_slot() .. "_prop_fixer_hq_value"),
    hanger = util.joaat("mp" .. util.get_char_slot() .. "_prop_hangar_value"),
    office = util.joaat("mp" .. util.get_char_slot() .. "_prop_office_value"),
    bunker = util.joaat("mp" .. util.get_char_slot() .. "_prop_businesshub_value"), -- might not be correct
    facility = util.joaat("mp" .. util.get_char_slot() .. "_prop_defuncbase_value"),
    nightclub_owned = util.joaat("mp" .. util.get_char_slot() .. "_nightclub_owned"),
    arcade_owned = util.joaat("mp" .. util.get_char_slot() .. "_arcade_owned"),
    autoshop_owned = util.joaat("mp" .. util.get_char_slot() .. "_auto_shop_owned"),
    agency_owned = util.joaat("mp" .. util.get_char_slot() .. "_fixer_hq_owned"),
    hanger_owned = util.joaat("mp" .. util.get_char_slot() .. "_hangar_owned"),
    office_owned = util.joaat("mp" .. util.get_char_slot() .. "_office_owned"),
    bunker_owned = util.joaat("mp" .. util.get_char_slot() .. "_businesshub_owned"), -- might not be correct
    facility_owned = util.joaat("mp" .. util.get_char_slot() .. "_dbase_owned")
}

local property_ids = {
    nightclubs = {
        ["La Mesa"] = 1,
        ["Mission Row"] = 2,
        ["Strawberry"] = 3,
        ["West Vinewood"] = 4,
        ["Cypress Flats"] = 5,
        ["LSIA"] = 6,
        ["Elysian Island"] = 7,
        ["Downtown Vinewood"] = 8,
        ["Del Perro"] = 9,
        ["Vespucci Canals"] = 10
    },
    arcades = {
        ["Warehouse - Davis"] = 3,
        ["Eight Bit"] = 4,
        ["Insert Coin - Rockford Hills"] = 5,
        ["La Mesa"] = 6
    },
    autoshops = {
        ["La Mesa"] = 1,
        ["Strawberry"] = 2,
        ["Burton"] = 3,
        ["Rancho"] = 4,
        ["Mission Row"] = 5
    },
    agencies = {
        ["Hawick"] = 1,
        ["Rockford Hills"] = 2,
        ["Little Seoul"] = 3,
        ["Vespucci Canals"] = 4
    },
    hangers = {
        ["LSIA 1"] = 1,
        ["LSIA A17"] = 2,
        ["Fort Zancudo Hangar A2"] = 3,
        ["Fort Zancudo Hangar 3497"] = 4,
        ["Fort Zancudo Hangar 3499"] = 5
    },
    bunkers = {
        
    },
    facilities = {
        ["Grand Senora Desert"] = 1,
        ["Route 68"] = 2,
        ["Sandy Shores"] = 3,
        ["Mount Gordo"] = 4,
        ["Paleto Bay"] = 5,
        ["Fort Zancudo"] = 6,
        ["Ron Alternates Wind Farm"] = 8,
        ["Land Act Reservoir"] = 9
    }
}

local function simulate_control_key(key, times, control=0)
    for i = 1, times do
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(control, key, 1)
        util.yield(300)
    end

    util.yield(100)
end

local function move_cursor(x, y)
    PAD.SET_CURSOR_POSITION(x, y)
    util.yield(200)
end

local function purchase_property()
    simulate_control_key(201, 1)
    move_cursor(0.30, 0.73) -- buy button
    simulate_control_key(201, 1)
    move_cursor(0.30, 0.93) -- buy button
    simulate_control_key(201, 1)
    move_cursor(0.78, 0.91) -- buy button
    simulate_control_key(201, 1)
    simulate_control_key(176, 1)
    simulate_control_key(201, 1, 2)
end

local function purchase_mazebank_property(property_curloc_func)
    local purchase = function()
        simulate_control_key(201, 1)
        move_cursor(0.30, 0.73) -- buy button
        simulate_control_key(201, 1)
        move_cursor(0.30, 0.93) -- buy button
        simulate_control_key(201, 1)
        move_cursor(0.78, 0.91) -- buy button
        simulate_control_key(201, 1)
        simulate_control_key(176, 1)
        simulate_control_key(201, 1, 2)
    end

    simulate_control_key(27, 1) -- bring up the phone
    simulate_control_key(172, 3) -- go to the internet
    simulate_control_key(176, 1) -- open internet
    move_cursor(0.25, 0.7) -- mazebank foreclosure
    simulate_control_key(201, 1) -- press enter
    move_cursor(0.5, 0.83) -- enter button
    simulate_control_key(201, 1) -- press enter
    move_cursor(0.78, 0.28) -- nightclub filter
    simulate_control_key(201, 1) -- press enter
    property_curloc_func() -- move cursor to property
    purchase() -- purchase property
    move_cursor(0.81, 0.10) -- close browser
    util.yield(1500) -- wait for transaction to complete
    simulate_control_key(201, 1) -- press enter
end

local nightclub_curloc = {
    [1] = function() -- la mesa
        move_cursor(0.69, 0.58)
    end,
    [2] = function() -- mission row
        move_cursor(0.644, 0.51)
    end,
    [3] = function() -- Strawberry
        move_cursor(0.59, 0.56)
    end,
    [4] = function()-- west vinewood
        move_cursor(0.61, 0.28) 
    end,
    [5] = function()-- cypress flats
        move_cursor(0.70, 0.74) 
    end,
    [6] = function()-- LSIA
        move_cursor(0.53, 0.80) 
    end,
    [7] = function() -- Elysian Island
        move_cursor(0.63, 0.94) 
    end,
    [8] = function() -- downtown vinewood
        move_cursor(0.647, 0.28)
    end,
    [9] = function() -- del perro
        move_cursor(0.46, 0.457)
    end,
    [10] = function() -- vespucci canals
        move_cursor(0.479, 0.54)
    end
}

local options = {
    "50,000,000", "100,000,000", "150,000,000", "200,000,000",
    "250,000,000", "300,000,000", "350,000,000", "400,000,000",
    "450,000,000", "500,000,000", "550,000,000", "600,000,000",
    "650,000,000", "700,000,000", "750,000,000", "800,000,000", 
    "850,000,000", "900,000,000", "950,000,000","1,000,000,000",
}

local function convert_value(value)
    switch value do
        case "50,000,000": return 50000000 break
        case "100,000,000": return 100000000 break
        case "150,000,000": return 150000000 break
        case "200,000,000": return 200000000 break
        case "250,000,000": return 250000000 break
        case "300,000,000": return 300000000 break
        case "350,000,000": return 350000000 break
        case "400,000,000": return 400000000 break
        case "450,000,000": return 450000000 break
        case "500,000,000": return 500000000 break
        case "550,000,000": return 550000000 break
        case "600,000,000": return 600000000 break
        case "650,000,000": return 650000000 break
        case "700,000,000": return 700000000 break
        case "750,000,000": return 750000000 break
        case "800,000,000": return 800000000 break
        case "850,000,000": return 850000000 break
        case "900,000,000": return 900000000 break
        case "950,000,000": return 950000000 break
        case "1,000,000,000": return 1000000000 break
        case "Maximum": return (2 << 30) - 1 break
        default: return (2 << 30) - 1 break
    end
end

local function is_owned(stat)
    local pOwned = memory.alloc_int()
    if STATS.STAT_GET_INT(stat, pOwned, -1) then
        local prop_id = memory.read_int(pOwned)
        if settings.verbose then util.toast("Stat Value: " .. prop_id) end
        return prop_id > 0
    else
        if settings.verbose then util.toast("Reading stat failed") end
    end

    return false
end

local function tunable(value)
    return memory.script_global(262145 + value)
end

local function simulate_control_key(key, times)
    for i = 1, times do
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, key, 1)
        util.yield(300)
    end

    util.yield(100)
end

local function move_cursor(x, y)
    PAD.SET_CURSOR_POSITION(x, y)
    util.yield(200)
end

local function get_owned_property(property, as_id)
    local ptr = memory.alloc(4)

    switch property do
        case "Nightclub":
            if STATS.STAT_GET_INT(stats.nightclub_owned, ptr, -1) then
                local prop_id = memory.read_int(ptr)
                if prop_id > 0 then
                    if not as_id then
                        return property_ids.nightclubs[prop_id]
                    else
                        return prop_id
                    end
                end
            end
            break
        end
end

local function get_property_names(property)
    switch property do
        case "Nightclub":
            local names = {}
            for name, id in pairs(property_ids.nightclubs) do
                table.insert(names, name)
            end
            return names
            break
        case "Arcade": return {} break
        case "Autoshop": return {} break
        case "Agency": return {} break
        case "Hanger": return {} break
        case "Facility": return {} break
        default: return {} break
    end
end

local show_usage = {
    nightclub = os.time(),
    arcade = os.time(),
    autoshop = os.time(),
    agency = os.time(),
    hanger = os.time(),
    facility = os.time(),
}

local usage_timer = 20

items.settings.root = root:list("Settings", {}, "Settings for the script")
items.presets.root = root:list("Presets", {}, "Preset values for convenience (not all presets will be the exact value")
items.custom.root = root:list("Custom", {}, "Customisable values for fine-tuning to your own liking")

items.settings.root:toggle("Disable Ownership Check", {}, "Disable ownership check for properties (useful if reading the stat is failing)", function(state) settings.ownership_check = state end)
items.settings.root:toggle("Verbose", {}, "Show verbose output", function(state) settings.verbose = state end)
items.presets.root:divider("MazeBank Properties", "MazeBank Properties")
items.presets.nightclub.root = items.presets.root:list("Nightclub", {}, "Preset values for nightclub")
items.presets.arcade.root = items.presets.root:list("Arcade", {}, "Preset values for arcade")
items.presets.autoshop.root = items.presets.root:list("Autoshop", {}, "Preset values for autoshop")
items.presets.hanger.root = items.presets.root:list("Hanger", {}, "Preset values for hanger")
items.presets.facility.root = items.presets.root:list("Facility", {}, "Preset values for facility")
items.presets.root:divider("Dynasty8Executive Properties", "Dynasty8Executive Properties")
items.presets.agency.root = items.presets.root:list("Agency", {}, "Preset values for agency")

items.presets.nightclub.root:divider("Nightclub", "Nightclub")
items.presets.nightclub.choice = items.presets.nightclub.root:list_select("Money", {}, "The nightclub trade-in price", options, 1, function(index) end)
items.presets.nightclub.root:toggle_loop("Enable", {}, "Enable the preset value for your nightclub", function()
    local ref =  menu.ref_by_rel_path(items.presets.nightclub.root, "Enable")
    local value = convert_value(options[items.presets.nightclub.choice.value])

    if settings.ownership_check then
        if not is_owned(stats.nightclub_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own a nightclub")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.nightclub, ((value * 2) + 4500000), true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set nightclub trade-in price")
    end

    if show_usage.nightclub - os.time() <= 0 then
        show_usage.nightclub = os.time() + usage_timer
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new nightclub to get the money")
    end
end)

local nc_owned = get_owned_property("Nightclub", true)
local nc_options = {
    first = {"La Mesa", "Mission Row", "West Vinewood", "Cypress Flats", "LSIA", "Elysian Island", "Downtown Vinewood", "Del Perro", "Vespucci Canals"},
    second = {"Vespucci Canals", "Del Perro", "Downtown Vinewood", "Elysian Island", "LSIA", "Cypress Flats", "West Vinewood", "Mission Row", "La Mesa"}
}

table.remove(nc_options.first, nc_owned)

items.presets.nightclub.root:divider("AFK Money Loop", "AFK Money Loop")
items.presets.nightclub.first_nightclub = items.presets.nightclub.root:list_select("First Nightclub", {}, "First nightclub to purchase", nc_options.first, "1", function(index) end)
items.presets.nightclub.second_nightclub = items.presets.nightclub.root:list_select("Second Nightclub", {}, "Second nightclub to purchase", nc_options.second, "1", function(index) end)
items.presets.nightclub.root:toggle_loop("Modify Value $1.07B", {}, "Modify the value to $1.07B", function()
    STATS.STAT_SET_INT(stats.nightclub, (2 << 30) - 1, true)
end)

items.presets.nightclub.root:toggle_loop("AFK Loop", {}, "AFK money loop", function()
    while menu.is_open() do
        util.toast("[Recovery]: Please close Stand menu.")
        util.yield()
    end

    local enable =  menu.ref_by_rel_path(items.presets.nightclub.root, "Enable")
    enable.value = false

    local afk_loop =  menu.ref_by_rel_path(items.presets.nightclub.root, "AFK Loop")
    local value = convert_value(options[items.presets.nightclub.choice.value])
    local first_nc_name = nc_options.first[tonumber(items.presets.nightclub.first_nightclub.value)]
    local second_nc_name = nc_options.second[tonumber(items.presets.nightclub.second_nightclub.value)]
    local first_nc = property_ids.nightclubs[first_nc_name]
    local second_nc = property_ids.nightclubs[second_nc_name]

    purchase_mazebank_property(nightclub_curloc[first_nc])
    util.yield(1000)
    purchase_mazebank_property(nightclub_curloc[second_nc])
    util.yield(1000)
end)

items.presets.arcade.choice = items.presets.arcade.root:list_select("Money", {}, "The arcade trade-in price", options, 1, function() end)
items.presets.arcade.root:toggle_loop("Enable", {}, "Enable the preset value for your arcade", function()
    local ref =  menu.ref_by_rel_path(items.presets.arcade.root, "Enable")
    local value = convert_value(options[items.presets.arcade.choice.value]) 

    if settings.ownership_check then
        if not is_owned(stats.arcade_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own an arcade")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.arcade, ((value - 255000) * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.arcade.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set arcade trade-in price")
    end

    if show_usage.arcade - os.time() <= 0 then
        show_usage.arcade = os.time() + usage_timer
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new arcade to get the money")
    end
end)

items.presets.autoshop.choice = items.presets.autoshop.root:list_select("Money", {}, "The autoshop trade-in price", options, 1, function() end)
items.presets.autoshop.root:toggle_loop("Enable", {}, "Enable the preset value for your autoshop", function()
    local ref = menu.ref_by_rel_path(items.presets.autoshop.root, "Enable")
    local value = convert_value(options[items.presets.autoshop.choice.value])
    
    if settings.ownership_check then
        if not is_owned(stats.autoshop_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own an autoshop")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.autoshop, (value * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.autoshop.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set autoshop trade-in price")
    end

    if show_usage.autoshop - os.time() <= 0 then
        show_usage.autoshop = os.time() + usage_timer
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new autoshop to get the money")
    end
end)

items.presets.hanger.choice = items.presets.hanger.root:list_select("Money", {}, "The hanger trade-in price", options, 1, function() end)
items.presets.hanger.root:toggle_loop("Enable", {}, "Enable the preset value for your hanger", function()
    local ref = menu.ref_by_rel_path(items.presets.hanger.root, "Enable")
    local value = convert_value(options[items.presets.hanger.choice.value])

    if settings.ownership_check then
        if not is_owned(stats.hanger_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own a hanger")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.hanger, ((value - 645000) * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.hanger.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set hanger trade-in price")
    end

    if show_usage.hanger - os.time() <= 0 then
        show_usage.hanger = os.time() + usage_timer
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new hanger to get the money")
    end
end)

items.presets.facility.choice = items.presets.facility.root:list_select("Money", {}, "The facility trade-in price", options, 1, function() end)
items.presets.facility.root:toggle_loop("Enable", {}, "Enable the preset value for your facility", function()
    local ref = menu.ref_by_rel_path(items.presets.facility.root, "Enable")
    local value = convert_value(options[items.presets.facility.choice.value])

    if settings.ownership_check then
        if not is_owned(stats.facility_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own a facility")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.facility, (value * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.facility.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set facility trade-in price")
    end

    if show_usage.facility - os.time() <= 0 then
        show_usage.facility = os.time() + usage_timer
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new facility to get the money")
    end
end)

items.presets.agency.choice = items.presets.agency.root:list_select("Money", {}, "The agency trade-in price", options, 1, function() end)
items.presets.agency.root:toggle_loop("Enable", {}, "Enable the preset value for your agency", function()
    local ref = menu.ref_by_rel_path(items.presets.agency.root, "Enable")
    local value = convert_value(options[items.presets.agency.choice.value])
    
    if settings.ownership_check then
        if not is_owned(stats.agency_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own an agency")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.agency, ((value - 897500) * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.agency.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set agency trade-in price")
    end

    if show_usage.agency - os.time() <= 0 then
        show_usage.agency = os.time() + usage_timer
        util.show_corner_help("Goto dynasty8executive website and purchase a new agency to get the money")
    end
end)

items.custom.root:divider("MazeBank Properties", "MazeBank Properties")
items.custom.nightclub.root = items.custom.root:list("Nightclub", {}, "Customisable values for nightclub")
items.custom.arcade.root = items.custom.root:list("Arcade", {}, "Customisable values for arcade")
items.custom.autoshop.root = items.custom.root:list("Autoshop", {}, "Customisable values for autoshop")
items.custom.hanger.root = items.custom.root:list("Hanger", {}, "Customisable values for hanger")
items.custom.facility.root = items.custom.root:list("Facility", {}, "Customisable values for facility")
items.custom.root:divider("Dynasty8Executive Properties", "Dynasty8Executive Properties")
items.custom.agency.root = items.custom.root:list("Agency", {}, "Customisable values for agency")

items.custom.nightclub.root:text_input("Money", {"nightclubvalue"}, "The nightclub trade-in price", function(value) 
    if settings.ownership_check then
        if not is_owned(stats.nightclub_owned) then
            util.toast("[Recovery]: You do not own a nightclub")
            return
        end
    end

    value = tonumber(value)

    if not STATS.STAT_SET_INT(stats.nightclub, (value * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set nightclub trade-in price")
    end

    util.show_corner_help("Goto maze bank foreclosure website and purchase a new nightclub to get the money")
end, "0")

items.custom.nightclub.root:toggle_loop("Enable", {}, "", function()
    local ref = menu.ref_by_rel_path(items.custom.nightclub.root, "Enable")
    local value = tonumber(menu.ref_by_rel_path(items.custom.nightclub.root, "Money").value)
    
    if settings.ownership_check then
        if not is_owned(stats.nightclub_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own a nightclub")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.nightclub, (value * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set nightclub trade-in price")
    end

    if show_usage.nightclub - os.time() <= 0 then
        show_usage.nightclub = os.time() + 15
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new nightclub to get the money")
    end
end)

items.custom.arcade.root:text_input("Money", {"arcadevalue"}, "The arcade trade-in price", function(value) 
    if settings.ownership_check then
        if not is_owned(stats.arcade_owned) then
            util.toast("[Recovery]: You do not own an arcade")
            return
        end
    end

    value = tonumber(value)

    if not STATS.STAT_SET_INT(stats.arcade, ((value - 255000) * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set arcade trade-in price")
    end

    util.show_corner_help("Goto maze bank foreclosure website and purchase a new arcade to get the money")
end, "0")

items.custom.arcade.root:toggle_loop("Enable", {}, "", function()
    local ref = menu.ref_by_rel_path(items.custom.arcade.root, "Enable")
    local value = tonumber(menu.ref_by_rel_path(items.custom.arcade.root, "Money").value)
    
    if settings.ownership_check then
        if not is_owned(stats.arcade_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own an arcade")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.arcade, ((value - 255000) * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set arcade trade-in price")
    end

    if show_usage.arcade - os.time() <= 0 then
        show_usage.arcade = os.time() + 15
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new arcade to get the money")
    end
end)

items.custom.autoshop.root:text_input("Money", {"autoshopvalue"}, "The autoshop trade-in price", function(value) 
    if settings.ownership_check then
        if not is_owned(stats.autoshop_owned) then
            util.toast("[Recovery]: You do not own an autoshop")
            return
        end
    end

    value = tonumber(value)

    if not STATS.STAT_SET_INT(stats.autoshop, (value * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set autoshop trade-in price")
    end

    util.show_corner_help("Goto mazebank foreclosure website and purchase a new autoshop to get the money")
end, "0")

items.custom.autoshop.root:toggle_loop("Enable", {}, "", function()
    local ref = menu.ref_by_rel_path(items.custom.autoshop.root, "Enable")
    local value = tonumber(menu.ref_by_rel_path(items.custom.autoshop.root, "Money").value)
    
    if settings.ownership_check then
        if not is_owned(stats.autoshop_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own an autoshop")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.autoshop, (value * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set autoshop trade-in price")
    end

    if show_usage.autoshop - os.time() <= 0 then
        show_usage.autoshop = os.time() + 15
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new autoshop to get the money")
    end
end)

items.custom.hanger.root:text_input("Money", {"hangervalue"}, "The hanger trade-in price", function(value) 
    if settings.ownership_check then
        if not is_owned(stats.hanger_owned) then
            util.toast("[Recovery]: You do not own a hanger")
            return
        end
    end

    value = tonumber(value)

    if not STATS.STAT_SET_INT(stats.hanger, ((value - 255000) * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set hanger trade-in price")
    end

    util.show_corner_help("Goto mazebank foreclosure website and purchase a new hanger to get the money")
end, "0")

items.custom.hanger.root:toggle_loop("Enable", {}, "", function()
    local ref = menu.ref_by_rel_path(items.custom.hanger.root, "Enable")
    local value = tonumber(menu.ref_by_rel_path(items.custom.hanger.root, "Money").value)
    
    if settings.ownership_check then
        if not is_owned(stats.hanger_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own a hanger")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.hanger, ((value - 255000) * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set hanger trade-in price")
    end

    if show_usage.hanger - os.time() <= 0 then
        show_usage.hanger = os.time() + 15
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new hanger to get the money")
    end
end)

items.custom.facility.root:text_input("Money", {"facilityvalue"}, "The facility trade-in price", function(value) 
    if settings.ownership_check then
        if not is_owned(stats.facility_owned) then
            util.toast("[Recovery]: You do not own a facility")
            return
        end
    end

    value = tonumber(value)

    if not STATS.STAT_SET_INT(stats.facility, (value * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set facility trade-in price")
    end

    util.show_corner_help("Goto mazebank foreclosure website and purchase a new facility to get the money")
end, "0")

items.custom.facility.root:toggle_loop("Enable", {}, "", function()
    local ref = menu.ref_by_rel_path(items.custom.facility.root, "Enable")
    local value = tonumber(menu.ref_by_rel_path(items.custom.facility.root, "Money").value)
    
    if settings.ownership_check then
        if not is_owned(stats.facility_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own a facility")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.facility, (value * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set facility trade-in price")
    end

    if show_usage.facility - os.time() <= 0 then
        show_usage.facility = os.time() + 15
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new facility to get the money")
    end
end)

items.custom.agency.root:text_input("Money", {"agencyvalue"}, "The agency trade-in price", function(value) 
    if settings.ownership_check then
        if not is_owned(stats.agency_owned) then
            util.toast("[Recovery]: You do not own an agency")
            return
        end
    end

    value = tonumber(value)

    if not STATS.STAT_SET_INT(stats.agency, ((value - 645000) * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set agency trade-in price")
    end

    util.show_corner_help("Goto mazebank foreclosure website and purchase a new agency to get the money")
end, "0")

items.custom.agency.root:toggle_loop("Enable", {}, "", function()
    local ref = menu.ref_by_rel_path(items.custom.agency.root, "Enable")
    local value = tonumber(menu.ref_by_rel_path(items.custom.agency.root, "Money").value)
    
    if settings.ownership_check then
        if not is_owned(stats.agency_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own an agency")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.agency, ((value - 645000) * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set agency trade-in price")
    end

    if show_usage.agency - os.time() <= 0 then
        show_usage.agency = os.time() + 15
        util.show_corner_help("Goto dynasty8executive website and purchase a new agency to get the money")
    end
end)

items.dax_mission.root = root:list("Dax Mission", {"daxmission"}, "Make easy money from the dax mission required to unlock the freakshop", function() util.show_corner_help("Check 'enable cash boost' option and start one of the new dax missions (if you haven't completed the first mission the 'Start Mission' will automatically start the first mission for you, the R on the map at sandy shores), once the mission has started you need to kill yourself immediately to fail the mission and you will recieve $1,000,000, take too long to kill yourself during the mission and you won\'t get any money") end)
items.dax_mission.root:divider("Help", "How to use this menu")
items.dax_mission.root:action("How To Use", {}, "", function()
    util.show_corner_help("Check 'enable cash boost' option and start one of the new dax missions (if you haven't completed the first mission the 'Start Mission' will automatically start the first mission for you, the R on the map at sandy shores), once the mission has started you need to kill yourself immediately to fail the mission and you will recieve $1,000,000, take too long to kill yourself during the mission and you won\'t get any money")
end)

items.dax_mission.root:divider("Options", "Recovery options using Dax Mission")
items.dax_mission.root:action("Start Mission", {}, "This will teleport you to the mission trigger and start it (if you've not completed the job already)", function()
    local ped = PLAYER.PLAYER_PED_ID()
    ENTITY.SET_ENTITY_COORDS(ped, 1394.4620361328, 3598.4528808594, 34.990489959717)
    util.yield(200)
    PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 51, 1)
end)

items.dax_mission.root:toggle_loop("Enable Cash Boost", {}, "", function()
    local cash = tunable(0)
    local ref = menu.ref_by_rel_path(items.dax_mission.root, "Enable RP Boost")
    
    if not ref.value then
        memory.write_float(cash, 5000.0) -- setting this value higher causes you to get no money (1m is the limit)
    end
end)

items.dax_mission.root:toggle_loop("Enable RP Boost", {}, "", function()
    local cash = tunable(0)
    local rp = tunable(1)
    local ref = menu.ref_by_rel_path(items.dax_mission.root, "Enable Cash Boost")
    
    memory.write_float(rp, 2000.0)
    if ref.value then
        memory.write_float(cash, 500.0)
    end
end)

items.casino_figures.root = root:list("Casino Figures", {"casinofigures"}, "Changes the amount of money you recieve from 1 figure to $200,000")
items.casino_figures.root:toggle_loop("Enable", {}, "Drops figures that give you $200,000", function()
    local cash = tunable(27123)

    memory.write_int(cash, 200000)
    menu.trigger_commands("rp" .. players.get_name(players.user()) .. " on")
end, function()
    local cash = tunable(27123)

    memory.write_int(cash, 1000)
    menu.trigger_commands("rp" .. players.get_name(players.user()) .. " off")
end)

items.casino_figures.root:toggle("Disable RP", {}, "Disables RP from casino figures", function(state)
    local rp = tunable(1)

    if state then
        memory.write_float(rp, 0)
    else
        memory.write_float(rp, 1.0)
    end
end)