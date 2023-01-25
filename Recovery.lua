util.keep_running()
util.require_natives(1672190175)

-- warning message
util.toast("WARNING: All features are considered risky and may result in a ban. Use at your own risk.")

local root = menu.my_root()
local helper = setmetatable({}, {})
helper.__index = helper

-- settings
helper.script_settings = {
    script_ver = "1.3.0", -- script version
    ownership_check = true -- ownership check for properties
}

-- predefined values
helper.MAX_INT = (2 << 30) - 1 -- max int value

-- command states
helper.states = {
    nightclub = { enabled = true, reason = "" },
    arcade = { enabled = true, reason = "Hash lookup failure" },
    autoshop = { enabled = true, reason = "" },
    hangar = { enabled = true, reason = "" },
    agency = { enabled = true, reason = "" },
}

-- meta table for afk loop
helper.afk = setmetatable(
    {
        ragdoll_timer = 1,
        nightclub = {
            locations = {}, 
            offset = 0.05
        },
        arcade = {
            locations = {},
            offset = 0.05
        },
        autoshop = {
            locations = {},
            offset = 0.05
        },
        hangar = {
            locations = {},
            offset = 0.05
        },
        facility = {
            locations = {},
            offset = 0.05
        },
    }, 
    {}
)

helper.property_ids = {
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
        ["Davis"] = 3,
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
    hangars = {
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

helper.prices = {
    nightclub = {
        ["La Mesa"] = memory.script_global(262145 + 24838),
        ["Mission Row"] = memory.script_global(262145 + 24843),
        ["Vespucci Canals"] = memory.script_global(262145 + 24845)
    },
    arcade = {
        ["La Mesa"] = memory.script_global(262145 + 28441),
        ["Davis"] = memory.script_global(262145 + 28439),
        ["Eight Bit"] = memory.script_global(262145 + 28444)
    },
    autoshop = {
        ["La Mesa"] = memory.script_global(262145 + 31246),
        ["Mission Row"] = memory.script_global(262145 + 31248),
        ["Burton"] = memory.script_global(262145 + 31249)
    }
}

local options = {
    "50,000,000", "100,000,000", "150,000,000", "200,000,000",
    "250,000,000", "300,000,000", "350,000,000", "400,000,000",
    "450,000,000", "500,000,000", "550,000,000", "600,000,000",
    "650,000,000", "700,000,000", "750,000,000", "800,000,000", 
    "850,000,000", "900,000,000", "950,000,000","1,000,000,000"
}

-- selections for presets
helper.afk.nightclub_opts = {
    first = {"La Mesa", "Mission Row", "Vespucci Canals"},
    second = {"Vespucci Canals", "Mission Row", "La Mesa"},
    owned = nil
}

helper.afk.arcade_opts = {
    first = {"La Mesa", "Davis", "Eight Bit"},
    second = {"Eight Bit", "Davis", "La Mesa"},
    owned = nil
}

helper.afk.autoshop_opts = {
    first = {"La Mesa", "Mission Row", "Burton"},
    second = {"Burton", "Mission Row", "La Mesa"},
    owned = nil
}

helper.afk.hangar_opts = {
    first = {"Fort Zancudo A2", "Fort Zancudo 3497", "Fort Zancudo 3499"},
    second = {"Fort Zancudo 3499", "Fort Zancudo 3497", "Fort Zancudo A2"},
    owned = nil
}

helper.afk.facility_opts = {
    first = {"Land Act Reservoir", "Ron Alternates Wind Farm", "Fort Zancudo"},
    second = {"Fort Zancudo", "Ron Alternates Wind Farm", "Land Act Reservoir"},
    owned = nil
}

helper.afk.agency_opts = {
    first = {"Hawick", "Rockford Hills", "Little Seoul"},
    second = {"Little Seoul", "Rockford Hills", "Hawick"},
    owned = nil
}

-- matrix of something
local matrix = { 
    0x53355D1B, 0x571F0621, 0x60167782, 0x3A3EEA5F, 0xFFFFFFFFE296BDED, 0x56F56335, 0x1C6D62CD, 0x19CCAB7, 0x3823872F, 0xFFFFFFFFD68C226B, 0x7F8C5A21, 0xFFFFFFFF84120CCA, 0xBC0B7DC, 0xFFFFFFFFC446355E, 0xFFFFFFFF8F52CAF3, 
    0x7BE9F8D0, 0xFFFFFFFFC7340920,     0x5F4E1327, 0xFFFFFFFF8FB0CDF7, 0x12FFD71E, 0xFFFFFFFFFF78C935, 0xFFFFFFFFA5168573, 0x2A231EFF, 0x5CBA6A9,  0x7F91D94,  0xFFFFFFFFB6D66ADE, 0xFFFFFFFFAB2ADB9C, 0x36DC130D, 0xFFFFFFFFDBABBDEA, 
    0xFFFFFFFF9F2BD3BC,     0x82B695A,  0x5B2441DC, 0x1DF0EAA7, 0x540D0DA3, 0x7B5DAA59, 0x67263571, 0x3C1399CB, 0x939AECD,  0xE6A9D489, 0x9F8C042F, 0xEEB0EBC3, 0x17C98A34, 0x21874091, 0x52821246, 0xA891C2CF, 0x357BB6CA, 0x430E19A0, 
    0x161C6B49, 0xED775E65, 0x906DCE83, 0x99113E6C, 0xA978075A, 0xCE2F0DE9, 0xE1F86C8A, 0xA6990930, 0x5CDDB293, 0xE3D6B03B, 0xB00DD26,  0xD782AB22, 0xDA2CDED7, 0x6AA94377, 0x3D9F1943, 0x9B4D2771, 0xD3A13530, 0xAAEA9DA8, 0xB5AF64C9, 
    0x6F91E97,  0xB0355B5E, 0xA906E6F0, 0x570D2952, 0xD9E882BD, 0xC319F754, 0x7B3DA23A, 0x11B7C9A3, 0x7114FE74, 0x9D4B218E, 0x39CFEAFB, 0x9116B40C, 0xE169A639, 0x68130ED2, 0x9C32D310, 0xC94EF2CF, 0xBC98707,  0x6DC5925C, 0x6135EB3B, 
    0x6AE6DD31, 0x66092CE4, 0xAC7A1451, 0x9CCFDD62, 0xDDBC2D8A, 0xA336E8F9, 0xC3116DA0, 0x40E45388, 0x708C1011, 0x59A6074B, 0x21900315, 0x191B08,   0x7EF82257, 0xBE429FDE, 0xD1AF78EC, 0xFD322A1F, 0x534B1155, 0x35F4AC56, 0x48A16735, 
    0x9B7CB190, 0x364FA48,  0xDE01603,  0xB6126B0E, 0x917E8033, 0xAF9B8748, 0xD19E7052, 0xCE3EFB3F, 0xABC56A14, 0xDA27185C, 0xCF426A5B, 0x888C4B05, 0x2C08FD5B, 0x83C4038E, 0xFD208C4,  0x92BD0EC1, 0x5103031A, 0x8249C810, 0x5767E2A4, 
    0x7DD4F62F, 0x18267837, 0x76A7DC07, 0xCAD8B1EA, 0x1C4B2CF0, 0x3571AFDC, 0x98F70D69, 0xF4FF2B17, 0x3E13E49A, 0x4BA9D440, 0x1B0F6D8F, 0x9A21BAEE, 0xF3D5D45D, 0xE47AF21C, 0xDB0C5D95, 0x663A9266, 0x18222BA4, 0xE73894D3, 0x587BF0DA, 
    0x828BA693, 0xB2EE05C1, 0x16C3BD48, 0x211F5D4A, 0x982896EB, 0x54AF34A9, 0xDD9742A8, 0x55B7D5F6, 0x93FA0E92, 0xBA7A5F13, 0x2D961346, 0xAD7C3195, 0x6165F3F7, 0x2348717E, 0xCC8F82E8, 0x44566D4C, 0x29644434, 0x820E844E, 0xD07B58B2, 
    0xE14D8C85, 0x3D33DF9F, 0xD32C6B69, 0x32143384, 0x864BC1FE, 0xA5BBE4B7, 0x130CA0B5, 0xF86DF78B, 0xEC8E37D9, 0x89D68F0F, 0xB296392B, 0x4BF8E74C, 0x3CC4EC10, 0xDEA9455A, 0x6FB46737, 0xE0F8F74E, 0xA76A7239, 0x67349F50, 0xDD76AE2D, 
    0xF583C852, 0x69098F02, 0x654EF37B, 0xB7162C7B, 0x1177E438, 0xD5C4D8C3, 0x91ABD300, 0x3755849,  0x5B96EF1A, 0xCBD760BB, 0xCB83A62,  0x3C73737B, 0x37F10D14, 0x46725219, 0x2AB94FBA, 0xCEEF1B2,  0xA62938D8, 0xA0F25A63, 0x3BCD1E26, 
    0x3C8A0140, 0xA4383662, 0xE88680E3, 0x80D40812, 0xC4C7D191, 0x429F38B1, 0xAC5E30D1, 0xAFD2E4E6, 0xC62018DA, 0xDACD634D, 0x7439B354, 0x14A82322, 0x3B376384, 0x53C97B98, 0xD13E64BF, 0xF0D2098D, 0x3115F941, 0xFDDFCF1A, 0x2FDE22E7, 
    0x12FEE31B, 0xEAA91E75, 0x84958F96, 0x7DBACD08, 0x4F7C9786, 0xB305B870, 0x990E5692, 0x5B00192D, 0xD3F12BE9, 0x25C6C293, 0x2E680DF,  0xE83A540D, 0xE255FF84, 0x52D36C6D, 0x93A17A7,  0x898DA393, 0xD2CAE26A, 0xA74C5D73, 0x6A7CFDA7, 
    0xE9DFBC2E, 0x7DEE4243, 0x81F823B2, 0xF073DD70, 0xC55900B6, 0xC643A2C,  0xC1F772EC, 0xC026F688, 0xBDAAC698, 0x240349FF, 0x297B317F, 0x49F93731, 0x388F26E2, 0x628AF645, 0xE8E270FC, 0xF405A9A9, 0xC9ABA8F9, 0x5C5EC714, 0xC8243A75 
}

-- function to convert selected option to a usable value
function helper:CONVERT_VALUE(value)
    value = string.gsub(value, ",", "")
    return tonumber(value, 10)
end

-- add property function (replaces individual functions)
function helper.afk:ADD_PROPERTY(property, name, purchase)
    local location = {
        name = name,
        purchase = purchase
    }

    table.insert(helper.afk[property].locations, location)
end

-- purchase property function (replaces individual functions)
function helper.afk:PURCHASE_PROPERTY(property, name)
    local properties = helper.afk[property]
    local locations = properties.locations

    for key, value in pairs(locations) do
        if value.name == name then
            return value.purchase()
        end
    end
end

-- locate something somewhere
function helper:MATRIX_LOOKUP(prop, ptype)
    local slot = util.get_char_slot()

    if prop == "nightclub" then
        if ptype == 0 then
            if slot == 0 then
                return matrix[11]
            end

            if slot == 1 then
                return matrix[27]
            end
        end

        if ptype == 1 then
            if slot == 0 then
                return matrix[1]
            end

            if slot == 1 then
                return matrix[17]
            end
        end
    end

    if prop == "arcade" then
        if ptype == 0 then
            if slot == 0 then
                return matrix[13]
            end

            if slot == 1 then
                return matrix[29]
            end
        end

        if ptype == 1 then
            if slot == 0 then
                return matrix[8]
            end

            if slot == 1 then
                return matrix[24]
            end
        end
    end

    if prop == "autoshop" then
        if ptype == 0 then
            if slot == 0 then
                return matrix[6]
            end

            if slot == 1 then
                return matrix[22]
            end
        end

        if ptype == 1 then
            if slot == 0 then
                return matrix[4]
            end

            if slot == 1 then
                return matrix[20]
            end
        end
    end

    if prop == "hangar" then
        if ptype == 0 then
            if slot == 0 then
                return matrix[16]
            end

            if slot == 1 then
                return matrix[32]
            end
        end

        if ptype == 1 then
            if slot == 0 then
                return matrix[3]
            end

            if slot == 1 then
                return matrix[19]
            end
        end
    end

    if prop == "agency" then
        if ptype == 0 then
            if slot == 0 then
                return matrix[9]
            end

            if slot == 1 then
                return matrix[25]
            end
        end

        if ptype == 1 then
            if slot == 0 then
                return matrix[2]
            end

            if slot == 1 then
                return matrix[18]
            end
        end
    end
end

-- something
helper.FHP = function(v1, v2, v3)
	for v4, v5 in pairs(v3) do
		local v6 = (v4 >> (1 + 0 + (349 - (147 + 199)))) & ((10 + 24) - 19)
		local v7 = v4 & (21 - (17 - 11))
		if ((v2 >> ((1471 - 938) - ((254 - 67) + (993 - (39 + 610))))) == v5) then
			return ((1821 - (463 + 1342)) * v6) + v7
		end
	end
	return nil
end

-- determine if a property is owned
function helper.afk:IS_PROPERTY_OWNED(property)
    if not helper.script_settings.ownership_check then
        return true -- return true if ownership check is disabled to bypass the check
    end

    local hash = helper:MATRIX_LOOKUP(property, 1) 
    local ptr = memory.alloc(4)

    if STATS.STAT_GET_INT(hash, ptr, -1) then
        return memory.read_int(ptr) ~= 0
    else
        return false
    end
end

-- get the property id of the property that is owned
function helper:GET_OWNED_PROPERTY_NAME(property)
    local owned = helper.afk:IS_PROPERTY_OWNED(property)
    if owned then
        local hash = helper:MATRIX_LOOKUP(property, 1)
        local ptr = memory.alloc(4)

        if STATS.STAT_GET_INT(hash, ptr, -1) then
            local id = memory.read_int(ptr)
            for key, value in pairs(helper.property_ids[property .. "s"]) do
                if value == id then
                    return key
                end
            end
        else
            return nil
        end
    else
        return nil
    end
end

-- get property price
function helper:GET_PROPERTY_PRICE(property, name)
    local prices = helper.prices[property]
    local price = prices[name]

    return memory.read_int(price)
end

-- determine if player can make a purchase of x amount
function helper:CAN_MAKE_PURCHASE(amount)
    local wallet = players.get_wallet(players.user()) -- players wallet
    local bank = players.get_bank(players.user()) -- players bank

    if wallet ~= nil and bank ~= nil then
        return (wallet + bank) >= amount -- return true if player can make the purchase
    end

    return false -- return false if wallet or bank is nil
end

-- add reference to helper
function helper:add(ref, name)
    self[name] = ref
end

-- get memory address for globals
function helper:TUNABLE(start, offset)
    start = start or 262145
    return memory.script_global(start + offset)
end

-- read stats
function helper:STAT_GET_INT(stat)
    local char_slot = util.get_char_slot() -- get character slot
    local ptr = memory.alloc(4) -- allocate memory for stat

    if type(stat) == "string" then
        
        stat = util.joaat("MP" .. char_slot .. "_" .. stat) -- get the hash of the stat

        if STATS.STAT_GET_INT(stat, ptr, -1) then
            return memory.read_int(ptr) -- return the stat value
        else
            return nil -- return nil if reading the stat failed
        end
    else
        if STATS.STAT_GET_INT(stat, ptr, -1) then
            return memory.read_int(ptr) -- return the stat value
        else
            return nil -- return nil if reading the stat failed
        end
    end
end

-- write stats
function helper:STAT_SET_INT(stat, value, save)
    save = save or true -- set default value for save argument

    if type(stat) == "string" then
        local char_slot = util.get_char_slot() -- get character slot
        stat = util.joaat("MP" .. char_slot .. "_" .. stat) -- get the hash of the stat

        return STATS.STAT_SET_INT(stat, value, save) -- set the stat value
    else
        return STATS.STAT_SET_INT(stat, value, save) -- set the stat value
    end
end

-- simulate user input
function SIMULATE_CONTROL_KEY(key, times, control=0, delay=300)
    for i = 1, times do
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(control, key, 1)
        util.yield(delay)
    end

    util.yield(100)
end

-- move cursor
function MOVE_CURSOR(x, y, delay=300, autoclick=false)
    PAD.SET_CURSOR_POSITION(x, y)
    util.yield(delay)

    if autoclick then
        SIMULATE_CONTROL_KEY(201, 1)
    end
end

-- close internet
function helper.afk:CLOSE_BROWSER()
    PED.SET_PED_TO_RAGDOLL(players.user_ped(), helper.afk.ragdoll_timer, helper.afk.ragdoll_timer, 2, 0, 0, 0) -- ragdoll to close browser
end

-- notify wrapper for util.toast and show_corner_help
function helper:NOTIFY(text, func)
    func = func or util.toast
    func(text)
end

-- quick notification for stand being open when purchasing a property
function helper:STAND_OPEN_ERROR()
    while menu.is_open() do
        helper:NOTIFY("Close Stand Mod Menu to continue")
        util.yield()
    end
end

-- not implemented notification
function helper:NOT_IMPLEMENTED()
    helper:NOTIFY("Not implemented yet")
end

-- add the location for nightclub 1/3 (La Mesa)
helper.afk:ADD_PROPERTY("nightclub", "La Mesa", function()
    MOVE_CURSOR(0.69, 0.58, 300, true) -- select the nightclub
    MOVE_CURSOR(0.30, 0.73, 300, true) -- press the first buy button
    MOVE_CURSOR(0.30, 0.93, 300, true) -- press the second buy button
    MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy butwton
    SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
    SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
    util.yield(1500) -- wait for transaction to complete
    helper.afk:CLOSE_BROWSER() -- close browser
end)

-- add the location for nightclub 2/3 (Mission Row)
helper.afk:ADD_PROPERTY("nightclub", "Mission Row", function()
    MOVE_CURSOR(0.64, 0.51, 300, true) -- select the nightclub
    MOVE_CURSOR(0.30, 0.73, 300, true) -- press the first buy button
    MOVE_CURSOR(0.30, 0.93, 300, true) -- press the second buy button
    MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
    SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
    SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
    util.yield(1500) -- wait for transaction to complete
    helper.afk:CLOSE_BROWSER() -- close browser
end)

-- add the location for nightclub 3/3 (Vespucci Canals)
helper.afk:ADD_PROPERTY("nightclub", "Vespucci Canals", function()
    MOVE_CURSOR(0.479, 0.54, 300, true) -- select the nightclub
    MOVE_CURSOR(0.30, 0.73, 300, true) -- press the first buy button
    MOVE_CURSOR(0.30, 0.93, 300, true) -- press the second buy button
    MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
    SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
    SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
    util.yield(1500) -- wait for transaction to complete
    helper.afk:CLOSE_BROWSER() -- close browser
end)

-- add the location for arcade 1/3 (La Mesa)
helper.afk:ADD_PROPERTY("arcade", "La Mesa", function()
    MOVE_CURSOR(0.687, 0.48, 300, true) -- select the arcade
    MOVE_CURSOR(0.30, 0.78, 300, true) -- press the first buy button
    MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
    MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
    SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
    SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
    util.yield(1500) -- wait for transaction to complete
    helper.afk:CLOSE_BROWSER() -- close browser
end)

-- add the location for arcade 2/3 (Davis)
helper.afk:ADD_PROPERTY("arcade", "Davis", function()
    MOVE_CURSOR(0.593, 0.67, 300, true) -- select the arcade
    MOVE_CURSOR(0.30, 0.81, 300, true) -- press the first buy button
    MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
    MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
    SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
    SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
    util.yield(1500) -- wait for transaction to complete
    helper.afk:CLOSE_BROWSER() -- close browser
end)

-- add the location for arcade 3/3 (Eight Bit)
helper.afk:ADD_PROPERTY("arcade", "Eight Bit", function()
    MOVE_CURSOR(0.54, 0.27, 300, true) -- select the arcade
    MOVE_CURSOR(0.30, 0.81, 300, true) -- press the first buy button
    MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
    MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
    SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
    SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
    util.yield(1500) -- wait for transaction to complete
    helper.afk:CLOSE_BROWSER() -- close browser
end)

-- add the location for autoshop 1/3 (La Mesa)
helper.afk:ADD_PROPERTY("autoshop", "La Mesa", function()
    MOVE_CURSOR(0.687, 0.455, 300, true) -- select the autoshop
    MOVE_CURSOR(0.30, 0.75, 300, true) -- press the first buy button
    MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
    MOVE_CURSOR(0.78, 0.94, 300, true) -- press the third buy button
    SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
    SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
    util.yield(1500) -- wait for transaction to complete
    helper.afk:CLOSE_BROWSER() -- close browser
end)

-- add the location for autoshop 2/3 (Mission Row)
helper.afk:ADD_PROPERTY("autoshop", "Mission Row", function()
    MOVE_CURSOR(0.66, 0.49, 300, true) -- select the autoshop
    MOVE_CURSOR(0.30, 0.75, 300, true) -- press the first buy button
    MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
    MOVE_CURSOR(0.78, 0.94, 300, true) -- press the third buy button
    SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
    SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
    util.yield(1500) -- wait for transaction to complete
    helper.afk:CLOSE_BROWSER() -- close browser
end)

-- add the location for autoshop 3/3 (Butron)
helper.afk:ADD_PROPERTY("autoshop", "Burton", function()
    MOVE_CURSOR(0.585, 0.32, 300, true) -- select the autoshop
    MOVE_CURSOR(0.30, 0.75, 300, true) -- press the first buy button
    MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
    MOVE_CURSOR(0.78, 0.94, 300, true) -- press the third buy button
    SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
    SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
    util.yield(1500) -- wait for transaction to complete
    helper.afk:CLOSE_BROWSER() -- close browser
end)

-- function to open internet for afk loop
function helper.afk:OPEN_INTERNET(filter)
    helper:STAND_OPEN_ERROR()

    local xptr, yptr = memory.alloc(4), memory.alloc(4)
    GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(xptr, yptr)
    local x, y = tonumber(memory.read_int(xptr)), tonumber(memory.read_int(yptr))

    SIMULATE_CONTROL_KEY(27, 1) -- open phone
    SIMULATE_CONTROL_KEY(173, 2) -- scroll down
    SIMULATE_CONTROL_KEY(176, 1) -- select internet
    MOVE_CURSOR(0.25, 0.70, 300, true) -- mazebank hyperlink
    MOVE_CURSOR(0.5, 0.83, 300, true) -- enter mazebank button
    
    switch x do
        case 1920:
            if filter == "nightclub" then MOVE_CURSOR(0.78, 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86, 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94, 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70, 0.28) end -- facility filter
            break
        case 1680:
            if filter == "nightclub" then MOVE_CURSOR(0.78 - helper.afk.nightclub.offset, 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86 - helper.afk.arcade.offset, 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94 - helper.afk.autoshop.offset, 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70 - helper.afk.facility.offset, 0.28) end -- facility filter
            break
        case 1600:
            if y == 1024 then
                if filter == "nightclub" then MOVE_CURSOR(0.78 - (helper.afk.nightclub.offset + 0.01), 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86 - (helper.afk.arcade.offset + 0.01), 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94 - (helper.afk.autoshop.offset + 0.01), 0.28) end -- autoshop filter
                if filter == "facility" then MOVE_CURSOR(0.70 - (helper.afk.facility.offset + 0.01), 0.28) end -- facility filter
            end

            if y == 900 then
                if filter == "nightclub" then MOVE_CURSOR(0.78, 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86, 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94, 0.28) end -- autoshop filter
                if filter == "facility" then MOVE_CURSOR(0.70, 0.28) end -- facility filter
            end
            break
        case 1440:
            if filter == "nightclub" then MOVE_CURSOR(0.78 - helper.afk.nightclub.offset, 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86 - helper.afk.arcade.offset, 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94 - helper.afk.autoshop.offset, 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70 - helper.afk.facility.offset, 0.28) end -- facility filter
            break
        case 1366:
            if filter == "nightclub" then MOVE_CURSOR(0.78, 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86, 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94, 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70, 0.28) end -- facility filter
            break
        case 1360:
            if filter == "nightclub" then MOVE_CURSOR(0.78, 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86, 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94, 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70, 0.28) end -- facility filter
            break
        case 1280: 
            if y == 1024 then
                if filter == "nightclub" then MOVE_CURSOR(0.78 - (helper.afk.nightclub.offset * 3), 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86 - (helper.afk.arcade.offset * 3), 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94 - (helper.afk.autoshop.offset * 3), 0.28) end -- autoshop filter
                if filter == "facility" then MOVE_CURSOR(0.70 - (helper.afk.facility.offset * 3), 0.28) end -- facility filter
            end

            if y == 960 then
                if filter == "nightclub" then MOVE_CURSOR(0.78 - (helper.afk.nightclub.offset * 2.5), 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86 - (helper.afk.arcade.offset * 2.5), 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94 - (helper.afk.autoshop.offset * 2.5), 0.28) end -- autoshop filter
                if filter == "facility" then helper:OVE_CURSOR(0.70 - (helper.afk.facility.offset * 2.5), 0.28) end -- facility filter
            end

            if y == 800 then
                if filter == "nightclub" then MOVE_CURSOR(0.78 - helper.afk.nightclub.offset, 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86 - helper.afk.arcade.offset, 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94 - helper.afk.autoshop.offset, 0.28) end -- autoshop filter
                if filter == "facility" then MOVE_CURSOR(0.70 - helper.afk.facility.offset, 0.28) end -- facility filter
            end

            if y == 768 then
                if filter == "nightclub" then MOVE_CURSOR(0.78 - (helper.afk.nightclub.offset / 2), 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86 - (helper.afk.arcade.offset / 2), 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94 - (helper.afk.autoshop.offset / 2), 0.28) end -- autoshop filter    
                if filter == "facility" then MOVE_CURSOR(0.70 - (helper.afk.facility.offset / 2), 0.28) end -- facility filter
            end

            if y == 720 then
                if filter == "nightclub" then MOVE_CURSOR(0.78, 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86, 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94, 0.28) end -- autoshop filter 
                if filter == "facility" then MOVE_CURSOR(0.70, 0.28) end -- facility filter
            end
            break
        case 1176:
            if filter == "nightclub" then MOVE_CURSOR(0.78, 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86, 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94, 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70, 0.28) end -- facility filter
            break
        case 1152:
            if filter == "nightclub" then MOVE_CURSOR(0.78 - (helper.afk.nightclub.offset * 2.5), 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86 - (helper.afk.arcade.offset * 2.5), 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94 - (helper.afk.autoshop.offset * 2.5), 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70 - (helper.afk.facility.offset * 2.5), 0.28) end -- facility filter
            break
        case 1024:
            if filter == "nightclub" then MOVE_CURSOR(0.78 - (helper.afk.nightclub.offset * 2.5), 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86 - (helper.afk.arcade.offset * 2.5), 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94 - (helper.afk.autoshop.offset * 2.5), 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70 - (helper.afk.facility.offset * 2.5), 0.28) end -- facility filter
            break
        case 800:
            if filter == "nightclub" then MOVE_CURSOR(0.78 - (helper.afk.nightclub.offset * 2.5), 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86 - (helper.afk.arcade.offset * 2.5), 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94 - (helper.afk.autoshop.offset * 2.5), 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70 - (helper.afk.facility.offset * 2.5), 0.28) end -- facility filter
            break
        default: 
            util.toast("Unsupported resolution: " .. x .. "x" .. y)
    end

    SIMULATE_CONTROL_KEY(201, 1) -- select filter
end

-- create the update button
helper:add(
    root:action("Update", {}, "Update script to the latest version", function()
        async_http.init("sodamnez.xyz", "lua/recovery/Recovery.lua", function(body, headers, status_code)
            if status_code == 200 then
                local file = io.open(filesystem.scripts_dir() .. SCRIPT_RELPATH, 'wb')
                file:write(body)
                file:close()

                util.toast("Updated successfully, restarting script...")
                util.restart_script()
            else
                util.toast("Update failed (" .. status_code .. ")")
            end
        end)

        async_http.dispatch()
    end),
    "update"
)

-- hide update button until update check is finished
helper.update.visible = false

-- json related functions
helper.json = {}

function helper.json:stringify(obj)
    local function stringify(obj)
        local str = ""

        if type(obj) == "table" then
            str = str .. "{"
            for k, v in pairs(obj) do
                str = str .. stringify(k) .. ":" .. stringify(v) .. ","
            end
            str = str .. "}"
        elseif type(obj) == "string" then
            str = str .. "\"" .. obj .. "\""
        else
            str = str .. tostring(obj)
        end

        return str
    end

    return stringify(obj)
end

function helper.json:parse(str)
    local obj = {}

    str = str:gsub("{", "")
    str = str:gsub("}", "")
    str = str:gsub("\"", "")
    str = str:gsub(" ", "")

    local split = str:split(",")

    for i = 1, #split do
        local split2 = split[i]:split(":")
        obj[split2[1]] = split2[2]
    end

    return obj
end

-- checking for updates function
function helper:check_for_updates(update_callback)
    async_http.init("sodamnez.xyz", "lua/recovery/update.php?version=" .. helper.script_settings.script_ver, function(body, headers, status_code)
        if status_code == 200 then
            local update = body
            local version = headers["Version"]
            
            if update == "1" then
                update_callback(version)
            end
        end
    end)

    async_http.dispatch()
end

-- check for updates
helper:check_for_updates(function(version)
    util.toast("New update available! ")

    helper.update.visible = true
end)

-- add settings list to menu
helper:add(
    root:list("Settings", {"rssettings"}, ""),
    "settings"
)

-- add tools list to menu
helper:add(
    root:list("Tools", {"rstools"}, ""),
    "tools"
)

-- create divider for recovery
root:divider("Recovery")

-- add presets list to menu
helper:add(
    root:list("Presets", {"rspresets"}, "", function()
        helper:NOTIFY("Without unlocking arcades and autoshops the afk money loop option will not work as intended!", util.show_corner_help)
    end),
    "presets"
)

-- add custom list to menu
helper:add(
    root:list("Custom", {"rscustom"}, ""),
    "custom"
)

-- add dax missions to the menu
helper:add(
    root:list("Dax Missions", {"rsdax"}, ""),
    "dax"
)

-- add casino figures to the menu
helper:add(
    root:list("Casino Figures", {"rscasino"}, ""),
    "casino"
)

-- add heists to the menu
helper:add(
    root:list("Heists", {"rsheists"}, ""),
    "heists"
)

-- add disable ownership check setting
helper:add(
    helper.settings:toggle("Ownership Check", {"rsdisableownershipcheck"}, "Enable/disable ownership check for properties", function(state)
        helper.script_settings.ownership_check = state
    end, helper.script_settings.ownership_check),
    "settings_ownership_check"
)

-- add unlock arcades to tools
helper:add(
    helper.tools:action("Unlock Arcades On MazeBank", {}, "Unlocks arcades", function()
        local current_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped(), true)
        local lester_blip = HUD.GET_NEXT_BLIP_INFO_ID(77)
        local casino_blip = HUD.GET_NEXT_BLIP_INFO_ID(804)

        if HUD.DOES_BLIP_EXIST(lester_blip) == 0 or HUD.DOES_BLIP_EXIST(casino_blip) == 0 then
            helper:NOTIFY("Blip not found")
            return
        end

        local lester_coords = HUD.GET_BLIP_COORDS(lester_blip)
        local casino_coords = HUD.GET_BLIP_COORDS(casino_blip)

        ENTITY.SET_ENTITY_COORDS(players.user_ped(), casino_coords.x, casino_coords.y, casino_coords.z, true, true, true, true)
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 51, 1)
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), lester_coords.x, lester_coords.y, lester_coords.z, true, true, true, true)
        util.yield(500)
        menu.trigger_commands("skipcutscene")
        util.yield(100)
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), current_pos.x, current_pos.y, current_pos.z, true, true, true, true)
    end),
    "tools_unlock_arcades"
)

-- add unlock autoshops
helper:add(
    helper.tools:action("Unlock Autoshops On MazeBank", {}, "Unlock Autoshops", function()
        local pos = v3.new(778.99708076172, -1867.5257568359, 28.296264648438)
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), pos.x, pos.y, pos.z, true, true, true, true)
    end),
    "tools_unlock_autoshops"
)

-- add a divider to presets
helper.presets:divider("MazeBank Foreclusure Properties")

-- add presets to presets list (mazebank foreclusure properties)
helper:add(helper.presets:list("Nightclub", {"rsprenightclub"}, "Nightclub recovery options"), "presets_nightclub")
helper:add(helper.presets:list("Arcade", {"reprearcade"}, "Arcade recovery options"), "presets_arcade")
helper:add(helper.presets:list("Autoshop", {"repreautoshop"}, "Autoshop recovery options"), "presets_autoshop")
helper:add(helper.presets:list("Hangar", {"reprehangar"}, "Hangar recovery options"), "presets_hangar")

-- add a divider for Dynasty8 properties
helper.presets:divider("Dynasty8Executive Properties", "dynasty8")

-- add presets to presets list (dynasty8 properties)
helper:add(helper.presets:list("Agency", {"repreagency"}, "Agency recovery options", "dynasty8"), "presets_agency")

-- disable according to states
helper.presets_nightclub.visible = helper.states.nightclub.enabled
helper.presets_arcade.visible = helper.states.arcade.enabled
helper.presets_autoshop.visible = helper.states.autoshop.enabled
helper.presets_hangar.visible = helper.states.hangar.enabled
helper.presets_agency.visible = helper.states.agency.enabled

if not helper.states.nightclub.enabled then helper:NOTIFY("Nightclub preset temporarily disabled\n\nReason: " .. helper.states.nightclub.reason, util.show_corner_help) end
if not helper.states.arcade.enabled then helper:NOTIFY("Arcade preset temporarily disabled\n\nReason: " .. helper.states.arcade.reason , util.show_corner_help) end
if not helper.states.autoshop.enabled then helper:NOTIFY("Autoshop preset temporarily disabled\n\nReason: " .. helper.states.autoshop.reason, util.show_corner_help) end
if not helper.states.hangar.enabled then helper:NOTIFY("Hangar preset temporarily disabled\n\nReason: " .. helper.states.hangar.reason, util.show_corner_help) end
if not helper.states.agency.enabled then helper:NOTIFY("Agency preset temporarily disabled\n\nReason: " .. helper.states.agency.reason, util.show_corner_help) end

-- add money options for nightclub
helper.presets_nightclub:divider("Settings", "nightclub")
helper:add(helper.presets_nightclub:list_select("Money", {}, "The nightclub value", options, 1, function() end), "presets_nightclub_money")

-- add money options for arcade
helper.presets_arcade:divider("Settings", "arcade")
helper:add(helper.presets_arcade:list_select("Money", {}, "The arcade value", options, 1, function() end), "presets_arcade_money")

-- add money options for autoshop
helper.presets_autoshop:divider("Settings", "autoshop")
helper:add(helper.presets_autoshop:list_select("Money", {}, "The autoshop value", options, 1, function() end), "presets_autoshop_money")

-- add money options for hangar
helper.presets_hangar:divider("Settings", "hangar")
helper:add(helper.presets_hangar:list_select("Money", {}, "The hangar value", options, 1, function() end), "presets_hangar_money")

-- add money options for agency
helper.presets_agency:divider("Settings", "agency")
helper:add(helper.presets_agency:list_select("Money", {}, "The agency value", options, 1, function() end), "presets_agency_money")

-- purchase nightclub
helper.presets_nightclub:action("Buy Nightclub", {}, "Automatically purchases a random nightclub", function()
    local nightclubs = helper.afk.nightclub_opts.first
    local nightclub = nightclubs[math.random(#nightclubs)]
    local owned = helper:GET_OWNED_PROPERTY_NAME("nightclub")
    local value = helper:CONVERT_VALUE(options[helper.presets_nightclub_money.value])
    local hash = helper:MATRIX_LOOKUP("nightclub", 0)

    while owned == nightclub do
        nightclub = nightclubs[math.random(#nightclubs)]
        util.yield()
    end

    if hash == nil then
        helper:NOTIFY("Hash lookup failed")
        return
    end

    local price = helper:GET_PROPERTY_PRICE("nightclub", nightclub)

    value = (value + price) * 2
    if nightclub == "La Mesa" then value = value - 400000 end

    if not helper:CAN_MAKE_PURCHASE(price) then
        helper:NOTIFY("You need $" .. price .. " to purchase this nightclub")
        return
    end

    if not helper:STAT_SET_INT(hash, value, true) then
        helper:NOTIFY("Failed to set nightclub value")
        return
    end

    helper:STAND_OPEN_ERROR()
    helper.afk:OPEN_INTERNET("nightclub")
    helper.afk:PURCHASE_PROPERTY("nightclub", nightclub)
end)

-- add set value to nightclub preset
helper.presets_nightclub:action("Set Value", {}, "Sets the value of the nightclub", function()
    local value = helper:CONVERT_VALUE(options[helper.presets_nightclub_money.value])
    local hash = helper:MATRIX_LOOKUP("nightclub", 0)

    if hash == nil then
        helper:NOTIFY("Hash lookup failed")
        return
    end

    if not helper:STAT_SET_INT(hash, value, true) then
        helper:NOTIFY("Failed to set nightclub value")
        return
    end

    helper:NOTIFY("Set nightclub value to $" .. value)
end)

-- afk loop divider
helper.presets_nightclub:divider("AFK Money Loop", "afk")

-- add first nightclub selection to nightclub preset
helper:add(helper.presets_nightclub:list_select("First Nightclub", {}, "The first nightclub to purchase", helper.afk.nightclub_opts.first, 1, function() end), "presets_nightclub_first")

-- add second nightclub selection to nightclub preset
helper:add(helper.presets_nightclub:list_select("Second Nightclub", {}, "The second nightclub to purchase", helper.afk.nightclub_opts.second, 1, function() end), "presets_nightclub_second")

-- add afk loop button
helper:add(
    helper.presets_nightclub:toggle_loop("AFK Loop", {}, "AFK money loop", function()
        local hash = helper:MATRIX_LOOKUP("nightclub", 0)
        local ref = menu.ref_by_rel_path(helper.presets_nightclub, "AFK Loop")
        local nightclub_first = helper.afk.nightclub_opts.first[helper.presets_nightclub_first.value]
        local nightclub_second = helper.afk.nightclub_opts.second[helper.presets_nightclub_second.value]
        local owned = helper:GET_OWNED_PROPERTY_NAME("nightclub")

        if ref.value == false then return false end
        
        if hash == nil then
            helper:NOTIFY("Hash lookup failed")
            return false
        end

        if ref.value then
            if nightclub_first == owned then
                helper:NOTIFY("You already own " .. nightclub_first .. ", please choose another nightclub")
                ref.value = false
                return false
            end

            if nightclub_first == nightclub_second then
                helper:NOTIFY("First and second nightclub cannot be the same, please choose another nightclub")
                ref.value = false
                return false
            end

            helper:STAT_SET_INT(hash, helper.MAX_INT, true)
            helper.afk:OPEN_INTERNET("nightclub")
            helper.afk:PURCHASE_PROPERTY("nightclub", nightclub_first)
            util.yield(1000)
            helper:STAT_SET_INT(hash, helper.MAX_INT, true)
            helper.afk:OPEN_INTERNET("nightclub")
            helper.afk:PURCHASE_PROPERTY("nightclub", nightclub_second)
            util.yield(1000)
        else
            return false
        end
    end),
    "presets_nightclub_afkloop"
)

-- purchase arcade
helper.presets_arcade:action("Buy Arcade", {}, "Automatically purchases a random arcade", function()
    local arcades = helper.afk.arcade_opts.first
    local arcade = arcades[math.random(#arcades)]
    local owned = helper:GET_OWNED_PROPERTY_NAME("arcade")
    local value = helper:CONVERT_VALUE(options[helper.presets_arcade_money.value])
    local hash = helper:MATRIX_LOOKUP("arcade", 0)

    while owned == arcade do
        arcade = arcades[math.random(#arcades)]
        util.yield()
    end

    if hash == nil then
        helper:NOTIFY("Hash lookup failed")
        return
    end

    local price = helper:GET_PROPERTY_PRICE("arcade", arcade)
    value = (value + price) * 2

    if not helper:CAN_MAKE_PURCHASE(price) then
        helper:NOTIFY("You need $" .. price .. " to purchase this arcade")
        return
    end

    if not helper:STAT_SET_INT(hash, value, true) then
        helper:NOTIFY("Failed to set arcade value")
        return
    end

    helper.afk:OPEN_INTERNET(false, "arcade")
    helper.afk:PURCHASE_PROPERTY("arcade", arcade)
end)

-- add set value to arcade preset
helper:add(
    helper.presets_arcade:action("Set Value", {}, "Sets the value of the arcade", function()
        local value = helper:CONVERT_VALUE(options[helper.presets_arcade_money.value])
        local hash = helper:MATRIX_LOOKUP("arcade", 0)

        if hash == nil then
            helper:NOTIFY("Hash lookup failed")
            return
        end

        if not helper:STAT_SET_INT(hash, value, true) then
            helper:NOTIFY("Failed to set arcade value")
            return
        end

        helper:NOTIFY("Set arcade value to $" .. value)
    end),
    "presets_arcade_setvalue"
)

-- afk loop divider
helper.presets_arcade:divider("AFK Money Loop", "afk")

-- add first arcade selection to arcade preset
helper:add(helper.presets_arcade:list_select("First Arcade", {}, "The first arcade to purchase", helper.afk.arcade_opts.first, 1, function() end), "presets_arcade_first")

-- add second arcade selection to arcade preset
helper:add(helper.presets_arcade:list_select("Second Arcade", {}, "The second arcade to purchase", helper.afk.arcade_opts.second, 1, function() end), "presets_arcade_second")

-- add afk loop button
helper:add(
    helper.presets_arcade:toggle_loop("AFK Loop", {}, "AFK money loop", function()
        local hash = helper:MATRIX_LOOKUP("arcade", 0)

        local ref = menu.ref_by_rel_path(helper.presets_arcade, "AFK Loop")
        local arcade_first = helper.afk.arcade_opts.first[helper.presets_arcade_first.value]
        local arcade_second = helper.afk.arcade_opts.second[helper.presets_arcade_second.value]
        local owned = helper:GET_OWNED_PROPERTY_NAME("arcade")

        if ref.value == false then return false end

        if hash == nil then
            helper:NOTIFY("Hash lookup failed")
            return false
        end

        if ref.value then
            if arcade_first == owned then
                helper:NOTIFY("You already own " .. arcade_first .. ", please choose another arcade")
                ref.value = false
                return false
            end

            if arcade_first == arcade_second then
                helper:NOTIFY("First and second arcade cannot be the same, please choose another arcade")
                ref.value = false
                return false
            end

            helper:STAT_SET_INT(hash, helper.MAX_INT, true)
            helper.afk:OPEN_INTERNET("arcade")
            helper.afk:PURCHASE_PROPERTY("arcade", arcade_first)
            util.yield(1000)
            helper:STAT_SET_INT(hash, helper.MAX_INT, true)
            helper.afk:OPEN_INTERNET("arcade")
            helper.afk:PURCHASE_PROPERTY("arcade", arcade_second)
            util.yield(1000)
        else
            return false
        end
    end),
    "presets_arcade_afkloop"
)

-- purchase autoshop
helper.presets_autoshop:action("Buy Auto Shop", {}, "Automatically purchases a random auto shop", function()
    local autoshops = helper.afk.autoshop_opts.first
    local autoshop = autoshops[math.random(#autoshops)]
    local owned = helper:GET_OWNED_PROPERTY_NAME("autoshop")
    local value = helper:CONVERT_VALUE(options[helper.presets_autoshop_money.value])
    local hash = helper:MATRIX_LOOKUP("autoshop", 0)

    while owned == autoshop do
        autoshop = autoshops[math.random(#autoshops)]
        util.yield()
    end

    if hash == nil then
        helper:NOTIFY("Hash lookup failed")
        return
    end

    local price = helper:GET_PROPERTY_PRICE("autoshop", autoshop)
    value = (value + price) * 2

    switch autoshop do
        case "Mission Row":
            value = value - (160000 * 2)
            break
        case "Burton":
            value = value + (80000 * 2)
            break
    end

    if not helper:CAN_MAKE_PURCHASE(price) then
        helper:NOTIFY("You need $" .. price .. " to purchase this auto shop")
        return
    end

    if not helper:STAT_SET_INT(hash, value, true) then
        helper:NOTIFY("Failed to set auto shop value")
        return
    end

    helper.afk:OPEN_INTERNET(false, "autoshop")
    helper.afk:PURCHASE_PROPERTY("autoshop", autoshop)
end)

-- add set value to autoshop preset
helper:add(
    helper.presets_autoshop:action("Set Value", {}, "Sets the value of the auto shop", function()
        local value = helper:CONVERT_VALUE(options[helper.presets_autoshop_money.value])
        local hash = helper:MATRIX_LOOKUP("autoshop", 0)

        if hash == nil then
            helper:NOTIFY("Hash lookup failed")
            return
        end

        if not helper:STAT_SET_INT(hash, value, true) then
            helper:NOTIFY("Failed to set auto shop value")
            return
        end

        helper:NOTIFY("Set auto shop value to $" .. value)
    end),
    "presets_autoshop_setvalue"
)

-- afk loop divider
helper.presets_autoshop:divider("AFK Money Loop", "afk")

-- add first autoshop selection to autoshop preset
helper:add(helper.presets_autoshop:list_select("First Auto Shop", {}, "The first auto shop to purchase", helper.afk.autoshop_opts.first, 1, function() end), "presets_autoshop_first")

-- add second autoshop selection to autoshop preset
helper:add(helper.presets_autoshop:list_select("Second Auto Shop", {}, "The second auto shop to purchase", helper.afk.autoshop_opts.second, 1, function() end), "presets_autoshop_second")

-- add afk loop button
helper:add(
    helper.presets_autoshop:toggle_loop("AFK Loop", {}, "AFK money loop", function()
        local hash = helper:MATRIX_LOOKUP("autoshop", 0)

        local ref = menu.ref_by_rel_path(helper.presets_autoshop, "AFK Loop")
        local autoshop_first = helper.afk.autoshop_opts.first[helper.presets_autoshop_first.value]
        local autoshop_second = helper.afk.autoshop_opts.second[helper.presets_autoshop_second.value]
        local owned = helper:GET_OWNED_PROPERTY_NAME("autoshop")

        if ref.value == false then return false end

        if hash == nil then
            helper:NOTIFY("Hash lookup failed")
            return false
        end

        if ref.value then
            if autoshop_first == owned then
                helper:NOTIFY("You already own " .. autoshop_first .. ", please choose another auto shop")
                ref.value = false
                return false
            end

            if autoshop_first == autoshop_second then
                helper:NOTIFY("First and second auto shop cannot be the same, please choose another auto shop")
                ref.value = false
                return false
            end

            helper:STAT_SET_INT(hash, helper.MAX_INT, true)
            helper.afk:OPEN_INTERNET("autoshop")
            helper.afk:PURCHASE_PROPERTY("autoshop", autoshop_first)
            util.yield(1000)
            helper:STAT_SET_INT(hash, helper.MAX_INT, true)
            helper.afk:OPEN_INTERNET("autoshop")
            helper.afk:PURCHASE_PROPERTY("autoshop", autoshop_second)
            util.yield(1000)
        else
            return false
        end
    end),
    "presets_autoshop_afkloop"
)

-- purchase hangar
helper.presets_hangar:action("Buy Hangar", {}, "Automatically purchases a random hangar", function()
    -- TODO: implement hangar purchase
    helper:NOT_IMPLEMENTED()
end)

-- add set value to hangar preset
helper:add(
    helper.presets_hangar:action("Set Value", {}, "Sets the value of the hangar", function()
        -- TODO: implement hangar set value
        helper:NOT_IMPLEMENTED()
    end),
    "presets_hangar_setvalue"
)

-- afk loop divider
helper.presets_hangar:divider("AFK Money Loop", "afk")

-- add first hangar selection to hangar preset
helper:add(helper.presets_hangar:list_select("First Hangar", {}, "The first hangar to purchase", helper.afk.hangar_opts.first, 1, function() end), "presets_hangar_first")

-- add second hangar selection to hangar preset
helper:add(helper.presets_hangar:list_select("Second Hangar", {}, "The second hangar to purchase", helper.afk.hangar_opts.second, 1, function() end), "presets_hangar_second")

-- add afk loop button
helper:add(
    helper.presets_hangar:toggle_loop("AFK Loop", {}, "AFK money loop", function()
        helper:NOT_IMPLEMENTED()
        local ref = menu.ref_by_rel_path(helper.presets_hangar, "AFK Loop")
        ref.value = false
    end),
    "presets_hangar_afkloop"
)

-- purchase agency
helper.presets_agency:action("Buy Agency", {}, "Automatically purchases a random agency", function()
    helper:NOT_IMPLEMENTED()
end)

-- add set value to agency preset
helper:add(
    helper.presets_agency:action("Set Value", {}, "Sets the value of the agency", function()
        helper:NOT_IMPLEMENTED()
    end),
    "presets_agency_setvalue"
)

-- afk loop divider
helper.presets_agency:divider("AFK Money Loop", "afk")

-- add first agency selection to agency preset
helper:add(helper.presets_agency:list_select("First Agency", {}, "The first agency to purchase", helper.afk.agency_opts.first, 1, function() end), "presets_agency_first")

-- add second agency selection to agency preset
helper:add(helper.presets_agency:list_select("Second Agency", {}, "The second agency to purchase", helper.afk.agency_opts.second, 1, function() end), "presets_agency_second")

-- add afk loop button
helper:add(
    helper.presets_agency:toggle_loop("AFK Loop", {}, "AFK money loop", function()
        helper:NOT_IMPLEMENTED()
        local ref = menu.ref_by_rel_path(helper.presets_agency, "AFK Loop")
        ref.value = false
    end),
    "presets_agency_afkloop"
)

-- finish adding rest of presets once locations are added

-- add mazebank foreclosure divider
helper.custom:divider("Mazebank Foreclosure Properties", "mazebank")

-- add mazebank foreclosure properties
helper:add(helper.custom:list("Nightclub", {}, "Nightclub recovery options"), "custom_nightclub")
helper:add(helper.custom:list("Arcade", {}, "Arcade recovery options"), "custom_arcade")
helper:add(helper.custom:list("Autoshhop", {}, "Auto Shop recovery options"), "custom_autoshop")
helper:add(helper.custom:list("Hangar", {}, "Hangar recovery options"), "custom_hangar")

-- add dynasty8 divider
helper.custom:divider("Dynasty8Executive Properties", "dynasty8")

-- add dynasty8 properties
helper:add(helper.custom:list("Agency", {}, "Agency recovery options"), "custom_agency")

-- add money option for nightclub
helper.custom_nightclub:divider("Money", "money")
helper:add(helper.custom_nightclub:text_input("Money", {"rsnightclubvalue"}, "The nightclub value", function(value)
    local owned = helper.afk:IS_PROPERTY_OWNED("nightclub")
    local hash = helper:MATRIX_LOOKUP("nightclub", 0)

    if not owned then
        helper:NOTIFY("You do not own a nightclub")
        return
    end

    value = tonumber(value)

    if not helper:STAT_SET_INT(hash, value, true) then
        helper:NOTIFY("Failed to set nightclub value")
        return
    end
end), "custom_nightclub_money")

-- add money option for arcade
helper.custom_arcade:divider("Money", "money")
helper:add(helper.custom_arcade:text_input("Money", {"rsarcadevalue"}, "The arcade value", function(value)
    local owned = helper.afk:IS_PROPERTY_OWNED("arcade")
    local hash = helper:MATRIX_LOOKUP("arcade", 0)

    if not owned then
        helper:NOTIFY("You do not own an arcade")
        return
    end

    value = tonumber(value)

    if not helper:STAT_SET_INT(hash, value, true) then
        helper:NOTIFY("Failed to set arcade value")
        return
    end
end), "custom_arcade_money")

-- add money option for autoshop
helper.custom_autoshop:divider("Money", "money")
helper:add(helper.custom_autoshop:text_input("Money", {"rsautoshopvalue"}, "The auto shop value", function(value)
    local owned = helper.afk:IS_PROPERTY_OWNED("autoshop")
    local hash = helper:MATRIX_LOOKUP("autoshop", 0)

    if not owned then
        helper:NOTIFY("You do not own an auto shop")
        return
    end

    value = tonumber(value)

    if not helper:STAT_SET_INT(hash, value, true) then
        helper:NOTIFY("Failed to set auto shop value")
        return
    end
end), "custom_autoshop_money")

-- add money option for hangar
helper.custom_hangar:divider("Money", "money")
helper:add(helper.custom_hangar:text_input("Money", {"rshangarvalue"}, "The hangar value", function(value)
    local owned = helper.afk:IS_PROPERTY_OWNED("hangar")
    local hash = helper:MATRIX_LOOKUP("hangar", 0)

    if not owned then
        helper:NOTIFY("You do not own a hangar")
        return
    end

    value = tonumber(value)

    if not helper:STAT_SET_INT(hash, value, true) then
        helper:NOTIFY("Failed to set hangar value")
        return
    end
end), "custom_hangar_money")

-- add money option for agency
helper.custom_agency:divider("Money", "money")
helper:add(helper.custom_agency:text_input("Money", {"rsagencyvalue"}, "The agency value", function(value)
    local owned = helper.afk:IS_PROPERTY_OWNED("agency")
    local hash = helper:MATRIX_LOOKUP("agency", 0)

    if not owned then
        helper:NOTIFY("You do not own an agency")
        return
    end

    value = tonumber(value)

    if not helper:STAT_SET_INT(hash, value, true) then
        helper:NOTIFY("Failed to set agency value")
        return
    end
end), "custom_agency_money")

-- purchase nightclub button
helper.custom_nightclub:action("Buy Nightclub", {}, "Automatically purchases a random nightclub", function()
    local nightclubs = helper.afk.nightclub_opts.first
    local nightclub = nightclubs[math.random(#nightclubs)]
    local owned = helper:GET_OWNED_PROPERTY_NAME("nightclub")
    local value = helper.custom_nightclub_money.value
    local hash = helper:MATRIX_LOOKUP("nightclub", 0)

    while owned == nightclub do
        nightclub = nightclubs[math.random(#nightclubs)]
        util.yield()
    end

    if hash == nil then
        helper:NOTIFY("Hash lookup failed")
        return
    end

    local price = helper:GET_PROPERTY_PRICE("nightclub", nightclub)

    value = (value + price) * 2
    if nightclub == "La Mesa" then value = value - 400000 end

    if not helper:CAN_MAKE_PURCHASE(price) then
        helper:NOTIFY("You need $" .. price .. " to purchase this nightclub")
        return
    end

    if not helper:STAT_SET_INT(hash, value, true) then
        helper:NOTIFY("Failed to set nightclub value")
        return
    end

    helper:STAND_OPEN_ERROR()
    helper.afk:OPEN_INTERNET("nightclub")
    helper.afk:PURCHASE_PROPERTY("nightclub", nightclub)
end)

-- purchase arcade button
helper.custom_arcade:action("Buy Arcade", {}, "Automatically purchases a random arcade", function()
    local arcades = helper.afk.arcade_opts.first
    local arcade = arcades[math.random(#arcades)]
    local owned = helper:GET_OWNED_PROPERTY_NAME("arcade")
    local value = helper.custom_arcade_money.value
    local hash = helper:MATRIX_LOOKUP("arcade", 0)

    while owned == arcade do
        arcade = arcades[math.random(#arcades)]
        util.yield()
    end

    if hash == nil then
        helper:NOTIFY("Hash lookup failed")
        return
    end

    local price = helper:GET_PROPERTY_PRICE("arcade", arcade)

    value = (value + price) * 2
    if arcade == "La Mesa" then value = value - 400000 end

    if not helper:CAN_MAKE_PURCHASE(price) then
        helper:NOTIFY("You need $" .. price .. " to purchase this arcade")
        return
    end

    if not helper:STAT_SET_INT(hash, value, true) then
        helper:NOTIFY("Failed to set arcade value")
        return
    end

    helper:STAND_OPEN_ERROR()
    helper.afk:OPEN_INTERNET("arcade")
    helper.afk:PURCHASE_PROPERTY("arcade", arcade)
end)

-- purchase autoshop button
helper.custom_autoshop:action("Buy Auto Shop", {}, "Automatically purchases a random auto shop", function()
    local autoshops = helper.afk.autoshop_opts.first
    local autoshop = autoshops[math.random(#autoshops)]
    local owned = helper:GET_OWNED_PROPERTY_NAME("autoshop")
    local value = helper.custom_autoshop_money.value
    local hash = helper:MATRIX_LOOKUP("autoshop", 0)

    while owned == autoshop do
        autoshop = autoshops[math.random(#autoshops)]
        util.yield()
    end

    if hash == nil then
        helper:NOTIFY("Hash lookup failed")
        return
    end

    local price = helper:GET_PROPERTY_PRICE("autoshop", autoshop)

    value = (value + price) * 2
    if autoshop == "La Mesa" then value = value - 400000 end

    if not helper:CAN_MAKE_PURCHASE(price) then
        helper:NOTIFY("You need $" .. price .. " to purchase this auto shop")
        return
    end

    if not helper:STAT_SET_INT(hash, value, true) then
        helper:NOTIFY("Failed to set auto shop value")
        return
    end

    helper:STAND_OPEN_ERROR()
    helper.afk:OPEN_INTERNET("autoshop")
    helper.afk:PURCHASE_PROPERTY("autoshop", autoshop)
end)

-- purchase hangar button
helper.custom_hangar:action("Buy Hangar", {}, "Automatically purchases a random hangar", function()
    -- TODO: implement hangar purchase
    helper:NOT_IMPLEMENTED()
end)

-- purchase agency button
helper.custom_agency:action("Buy Agency", {}, "Automatically purchases a random agency", function()
    -- TODO: implement agency purchase
    helper:NOT_IMPLEMENTED()
end)

-- add help divider to dax missions
helper.dax:divider("Help", "help")

-- add help button
helper.dax:action("How To Use", {}, "Shows a help message", function()
    helper:NOTIFY("Check 'enable cash boost' option and start one of the new dax missions (if you haven't completed the first mission the 'Start Mission' will automatically start the first mission for you, the R on the map at sandy shores), once the mission has started you need to kill yourself immediately to fail the mission and you will recieve $1,000,000, take too long to kill yourself during the mission and you won\'t get any money", util.show_corner_help)
end)

-- add compatible missions divider
helper.dax:divider("Compatible Missions", "missions")

-- add readonly items to compatible missions
helper.dax:readonly("First Dose 1 - Welcome to the Troupe")
helper.dax:readonly("First Dose 2 - Designated Driver")

-- add options divider
helper.dax:divider("Options", "options")

-- add make 1M button
helper.dax:action("Make $1M - First Dose 1", {}, "Automatically completes requirements to make $1M from First Dose 1 mission", function()
    local cash = helper:TUNABLE(262145, 0)
    local ped = players.user_ped()
    ENTITY.SET_ENTITY_COORDS(ped, 1394.4620361328, 3598.4528808594, 34.990489959717)
    util.yield(200)
    SIMULATE_CONTROL_KEY(51, 1)
    util.yield(1500)
    SIMULATE_CONTROL_KEY(188, 1, 2)
    SIMULATE_CONTROL_KEY(201, 1)
    SIMULATE_CONTROL_KEY(188, 1, 2)
    SIMULATE_CONTROL_KEY(201, 1)
    SIMULATE_CONTROL_KEY(201, 1, 2)
    util.yield(6000)
    memory.write_float(cash, 5000.0)
    menu.trigger_commands("suicide")
    util.yield(3000)
    menu.trigger_commands("suicide")
    util.yield(3000)
    menu.trigger_commands("suicide")
    util.yield(4500)
    SIMULATE_CONTROL_KEY(201, 10)
end)

-- add cash boost buttotn
helper:add(
    helper.dax:toggle_loop("Enable Cash Boost", {}, "Modifies cash multiplier", function()
        local cash = helper:TUNABLE(262145, 0)
        memory.write_float(cash, 5000.0)
    end,
    function()
        local cash = helper:TUNABLE(262145, 0)
        memory.write_float(cash, 1.0)
    end),
    "dax_cash_boost"
)

-- add rp boost
helper:add(
    helper.dax:toggle_loop("Enable RP Boost", {}, "Modifies rp multiplier", function()
        local rp = helper:TUNABLE(262145, 1)
        memory.write_float(rp, 2000.0)
    end,
    function()
        local rp = helper:TUNABLE(262145, 1)
        memory.write_float(rp, 1.0)
    end),
    "dax_rp_boost"
)

-- add enable toggle for casino figures
helper:add(
    helper.casino:toggle_loop("Enable", {}, "Drops figures that give you $200,000", function()
        local cash = helper:TUNABLE(262145, 27123)
        memory.write_int(cash, 200000)
        menu.trigger_commands("rp" .. playrs.get_name(players.user()) .. " on")
    end,
    function()
        local cash = helper:TUNABLE(262145, 27123)
        memory.write_int(cash, 1000)
        menu.trigger_commands("rp" .. playrs.get_name(players.user()) .. " off")
    end),
    "casino_figures_toggle"
)

-- add disable rp toggle for casino figures
helper.casino:toggle("Disable RP", {}, "Prevents you from gaining RP", function(state)
    local rp = helper:TUNABLE(262145, 1)

    if state then
        memory.write_float(rp, 0.0)
    else
        memory.write_float(rp, 1.0)
    end
end)

-- add globals divider
helper.heists:divider("Globals", "globals")

-- disable payouts for heists
helper.heists:toggle("Disable Payout", {}, "Prevents you from gaining money from heists (this also affects missions)", function(state)
    local cash = helper:TUNABLE(262145, 0)

    util.create_tick_handler(function()
        local state = menu.ref_by_rel_path(helper.heists, "Disable Payout").value
        if state then
            memory.write_float(cash, 0.0)
        else
            memory.write_float(cash, 1.0)
            return false
        end
    end)
end)