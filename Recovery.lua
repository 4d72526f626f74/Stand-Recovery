local version = "1.0"
local root = menu.my_root()
local natives_list = {}
local natives = { wanted_found = false, required_native = false }

util.toast("ez")

local update_button = root:action("Update Script", {}, "Update the script to the latest version", function()
    async_http.init("raw.githubusercontent.com", "4d72526f626f74/Stand-Recovery/main/Recovery.lua", function(body, headers, status_code)
        if status_code == 200 then
            local file = io.open(filesystem.scripts_dir() .. SCRIPT_RELPATH, "wb")
            file:write(body)
            file:close()

            util.toast("Updated to v" .. version .. ".")
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

for i, path in ipairs(filesystem.list_files(filesystem.scripts_dir() .. "\\lib")) do
    if filesystem.is_regular_file(path) then
        local split = path:split("\\")
        local name = string.match(split[#split], "(.*)%.lua")

        if name == "natives-1672190175" then
            natives.wanted_found = true
        end

        if string.find(name, "natives") then
            if not string.find(name, "uno") then
                table.insert(natives_list, name)
            end
        end
    end
end

util.keep_running()
if natives.wanted_found then
    util.require_natives(1672190175)
    natives.required_native = true
end

if not natives.required_native and not natives.wanted_found then
    util.require_natives(natives_list[#natives_list])
    util.show_corner_help("Required native not found. Using " .. natives_list[#natives_list] .. " instead.")
end

util.toast("WARNING: All features are considered risky and may result in a ban. Use at your own risk.")

-- dbase = facility
-- businesshub = bunker

local items = {
    presets = {
        root = nil,
        nightclub = {
            root = nil,
            choice = nil
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
        }
    }
}

local stats = {
    nightclub = util.joaat("mp" .. util.get_char_slot() .. "_prop_nightclub_value"),
    arcade = util.joaat("mp" .. util.get_char_slot() .. "_prop_arcade_value"),
    autoshop = util.joaat("mp" .. util.get_char_slot() .. "_prop_auto_shop_value"),
    agency = util.joaat("mp" .. util.get_char_slot() .. "_prop_fixer_hq_value"),
    hanger = util.joaat("mp" .. util.get_char_slot() .. "_prop_hangar_value"),
    office = util.joaat("mp" .. util.get_char_slot() .. "_prop_office_value"),
    bunker = util.joaat("mp" .. util.get_char_slot() .. "_prop_businesshub_value"),
    facility = util.joaat("mp" .. util.get_char_slot() .. "_prop_defuncbase_value"),
    nightclub_owned = util.joaat("mp" .. util.get_char_slot() .. "_nightclub_owned"),
    arcade_owned = util.joaat("mp" .. util.get_char_slot() .. "_arcade_owned"),
    autoshop_owned = util.joaat("mp" .. util.get_char_slot() .. "_auto_shop_owned"),
    agency_owned = util.joaat("mp" .. util.get_char_slot() .. "_fixer_hq_owned"),
    hanger_owned = util.joaat("mp" .. util.get_char_slot() .. "_hangar_owned"),
    office_owned = util.joaat("mp" .. util.get_char_slot() .. "_office_owned"),
    bunker_owned = util.joaat("mp" .. util.get_char_slot() .. "_businesshub_owned"),
    facility_owned = util.joaat("mp" .. util.get_char_slot() .. "_dbase_owned")
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
        default: return (2 << 30) - 1 break
    end
end

local function is_owned(stat)
    local pOwned = memory.alloc_int()
    if STATS.STAT_GET_INT(stat, pOwned, -1) then
        return memory.read_int(pOwned) > 0
    end

    return false
end

local show_usage = {
    nightclub = os.time(),
    arcade = os.time(),
    autoshop = os.time(),
    agency = os.time(),
    hanger = os.time(),
    facility = os.time()
}

items.presets.root = root:list("Presets", {}, "Preset values for convenience (not all presets will be the exact value")
items.custom.root = root:list("Custom", {}, "Customisable values for fine-tuning to your own liking")

items.presets.nightclub.root = items.presets.root:list("Nightclub", {}, "Preset values for nightclub")
items.presets.arcade.root = items.presets.root:list("Arcade", {}, "Preset values for arcade")
items.presets.autoshop.root = items.presets.root:list("Autoshop", {}, "Preset values for autoshop")
items.presets.agency.root = items.presets.root:list("Agency", {}, "Preset values for agency")
items.presets.hanger.root = items.presets.root:list("Hanger", {}, "Preset values for hanger")
items.presets.facility.root = items.presets.root:list("Facility", {}, "Preset values for facility")

items.presets.nightclub.choice = items.presets.nightclub.root:list_select("Money", {}, "The nightclub trade-in price", options, 1, function(index) end)
items.presets.nightclub.root:toggle_loop("Enable", {}, "Enable the preset value for your nightclub", function()
    local ref =  menu.ref_by_rel_path(items.presets.nightclub.root, "Enable")
    local value = convert_value(options[items.presets.nightclub.choice.value])

    if not is_owned(stats.nightclub_owned) then
        ref.value = false
        util.toast("[Recovery]: You do not own a nightclub")
        return
    end

    if not STATS.STAT_SET_INT(stats.nightclub, ((value * 2) + 4500000), true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set nightclub trade-in price")
    end

    if show_usage.nightclub - os.time() <= 0 then
        show_usage.nightclub = os.time() + 15
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new nightclub to get the money")
    end
end)

items.presets.arcade.choice = items.presets.arcade.root:list_select("Money", {}, "The arcade trade-in price", options, 1, function() end)
items.presets.arcade.root:toggle_loop("Enable", {}, "Enable the preset value for your arcade", function()
    local ref =  menu.ref_by_rel_path(items.presets.arcade.root, "Enable")
    local value = convert_value(options[items.presets.arcade.choice.value]) 

    if not is_owned(stats.arcade_owned) then
        ref.value = false
        util.toast("[Recovery]: You do not own an arcade")
        return
    end

    if not STATS.STAT_SET_INT(stats.arcade, ((value - 255000) * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.arcade.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set arcade trade-in price")
    end

    if show_usage.arcade - os.time() <= 0 then
        show_usage.arcade = os.time() + 15
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new arcade to get the money")
    end
end)

items.presets.autoshop.choice = items.presets.autoshop.root:list_select("Money", {}, "The autoshop trade-in price", options, 1, function() end)
items.presets.autoshop.root:toggle_loop("Enable", {}, "Enable the preset value for your autoshop", function()
    local ref = menu.ref_by_rel_path(items.presets.autoshop.root, "Enable")
    local value = convert_value(options[items.presets.autoshop.choice.value])
    
    if not is_owned(stats.autoshop_owned) then
        ref.value = false
        util.toast("[Recovery]: You do not own an autoshop")
        return
    end

    if not STATS.STAT_SET_INT(stats.autoshop, (value * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.autoshop.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set autoshop trade-in price")
    end

    if show_usage.autoshop - os.time() <= 0 then
        show_usage.autoshop = os.time() + 15
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new autoshop to get the money")
    end
end)

items.presets.agency.choice = items.presets.agency.root:list_select("Money", {}, "The agency trade-in price", options, 1, function() end)
items.presets.agency.root:toggle_loop("Enable", {}, "Enable the preset value for your agency", function()
    local ref = menu.ref_by_rel_path(items.presets.agency.root, "Enable")
    local value = convert_value(options[items.presets.agency.choice.value])
    
    if not is_owned(stats.agency_owned) then
        ref.value = false
        util.toast("[Recovery]: You do not own an agency")
        return
    end

    if not STATS.STAT_SET_INT(stats.agency, ((value - 897500) * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.agency.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set agency trade-in price")
    end

    if show_usage.agency - os.time() <= 0 then
        show_usage.agency = os.time() + 15
        util.show_corner_help("Goto dynasty8executive website and purchase a new agency to get the money")
    end
end)

items.presets.hanger.choice = items.presets.hanger.root:list_select("Money", {}, "The hanger trade-in price", options, 1, function() end)
items.presets.hanger.root:toggle_loop("Enable", {}, "Enable the preset value for your hanger", function()
    local ref = menu.ref_by_rel_path(items.presets.hanger.root, "Enable")
    local value = convert_value(options[items.presets.hanger.choice.value])

    if not is_owned(stats.hanger_owned) then
        ref.value = false
        util.toast("[Recovery]: You do not own a hanger")
        return
    end

    if not STATS.STAT_SET_INT(stats.hanger, ((value - 645000) * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.hanger.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set hanger trade-in price")
    end

    if show_usage.hanger - os.time() <= 0 then
        show_usage.hanger = os.time() + 15
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new hanger to get the money")
    end
end)

items.presets.facility.choice = items.presets.facility.root:list_select("Money", {}, "The facility trade-in price", options, 1, function() end)
items.presets.facility.root:toggle_loop("Enable", {}, "Enable the preset value for your facility", function()
    local ref = menu.ref_by_rel_path(items.presets.facility.root, "Enable")
    local value = convert_value(options[items.presets.facility.choice.value])

    if not is_owned(stats.facility_owned) then
        ref.value = false
        util.toast("[Recovery]: You do not own a facility")
        return
    end

    if not STATS.STAT_SET_INT(stats.facility, (value * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.facility.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set facility trade-in price")
    end

    if show_usage.facility - os.time() <= 0 then
        show_usage.facility = os.time() + 15
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new facility to get the money")
    end
end)

items.custom.nightclub.root = items.custom.root:list("Nightclub", {}, "Customisable values for nightclub")
items.custom.arcade.root = items.custom.root:list("Arcade", {}, "Customisable values for arcade")
items.custom.autoshop.root = items.custom.root:list("Autoshop", {}, "Customisable values for autoshop")
items.custom.agency.root = items.custom.root:list("Agency", {}, "Customisable values for agency")
items.custom.hanger.root = items.custom.root:list("Hanger", {}, "Customisable values for hanger")
items.custom.facility.root = items.custom.root:list("Facility", {}, "Customisable values for facility")

items.custom.nightclub.root:text_input("Money", {"nightclubvalue"}, "The nightclub trade-in price", function(value) 
    if not is_owned(stats.nightclub_owned) then
        util.toast("[Recovery]: You do not own a nightclub")
        return
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
    
    if not is_owned(stats.nightclub_owned) then
        ref.value = false
        util.toast("[Recovery]: You do not own a nightclub")
        return
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
    if not is_owned(stats.arcade_owned) then
        util.toast("[Recovery]: You do not own an arcade")
        return
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
    
    if not is_owned(stats.arcade_owned) then
        ref.value = false
        util.toast("[Recovery]: You do not own an arcade")
        return
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
    if not is_owned(stats.autoshop_owned) then
        util.toast("[Recovery]: You do not own an autoshop")
        return
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
    
    if not is_owned(stats.autoshop_owned) then
        ref.value = false
        util.toast("[Recovery]: You do not own an autoshop")
        return
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

items.custom.agency.root:text_input("Money", {"agencyvalue"}, "The agency trade-in price", function(value) 
    if not is_owned(stats.agency_owned) then
        util.toast("[Recovery]: You do not own an agency")
        return
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
    
    if not is_owned(stats.agency_owned) then
        ref.value = false
        util.toast("[Recovery]: You do not own an agency")
        return
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

items.custom.hanger.root:text_input("Money", {"hangervalue"}, "The hanger trade-in price", function(value) 
    if not is_owned(stats.hanger_owned) then
        util.toast("[Recovery]: You do not own a hanger")
        return
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
    
    if not is_owned(stats.hanger_owned) then
        ref.value = false
        util.toast("[Recovery]: You do not own a hanger")
        return
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
    if not is_owned(stats.facility_owned) then
        util.toast("[Recovery]: You do not own a facility")
        return
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
    
    if not is_owned(stats.facility_owned) then
        ref.value = false
        util.toast("[Recovery]: You do not own a facility")
        return
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
