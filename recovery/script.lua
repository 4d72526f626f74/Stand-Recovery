local script = setmetatable({}, {__index = _G})

-- require modules
local utils = require("lib.recovery.utils") -- require the utils module

-- add script root
script.root = menu.my_root()
script.sroot = menu.shadow_root()
script.proot = nil -- will be set later

-- resolution
script.resolution = nil

-- script settings
script.script_settings = {
    auto_accept_transaction_errors = true, -- automatically accept transaction errors,
    increase_afk_loop_speed = false, -- increase the speed of the afk loop
}

-- script delays
script.delays = {
    STEP = 50, -- step value for slider
    MIN_VALUE = 0, -- minimum value for slider
    OPEN_INTERNET = { -- delays related to opening the internet
        MENU_OPEN_ERROR_DELAY = 1000, -- delay after the menu is closed before opening the internet
        SCROLL_DELAY = 700, -- delay before opening the phone
        OPEN_DELAY = 700, -- delay before scrolling down to the internet
        SELECT_DELAY = 700, -- delay before opening the internet
    },
    PURCHASE = { -- delays related to purchasing a property
        BUY_FROM_DELAY = 300, -- delay before pressing 'buy from: $1,500,000 button',
        BUY_BUTTON_DELAY = 300, -- delay before pressing 'buy' button,
        FINAL_BUY_BUTTON_DELAY = 300, -- delay before pressing 'buy' button on the final confirmation screen,
        TRADE_IN_SELECTION_DELAY = 1, -- delay before selecting a trade in property
        RETURN_TO_MAP_DELAY = 300, -- delay before pressing 'return to map' button
        SELECT_FILTER_DELAY = 300, -- delay before selecting a filter
    },
    PURCHASE_PRESS_ENTER_COUNT = 2, -- the number of times that enter should be pressed when purchasing a property
}

script.states = {
    nightclub = {
        safe_open = false,
        infront_of_safe = false
    },
    arcade = {
        safe_open = false,
        infront_of_safe = false
    },
    overrides = {
        purchase_block = false
    }
}

-- predefined variables
script.me = players.user() -- you
script.me_ped = players.user_ped() -- your ped
script.MAX_INT = (2 << 30) - 1 -- max integer value
script.char = util.get_char_slot() -- character slot

-- warning hashes
script.MH_BEFORE_PURCHASE = 377291349 -- hash for the final purchase confirmation screen

-- ids for each property
script.property_ids = {
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
    facilities = { -- might get removed later, not sure if gonna add facilities or not
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

script.globals = { -- script globals
    transaction_error = {
        banner = memory.script_global(4536673), -- https://www.unknowncheats.me/forum/grand-theft-auto-v/500059-globals-locals-discussion-read-page-1-a.html
        notification = memory.script_global(4536674), -- https://www.unknowncheats.me/forum/grand-theft-auto-v/500059-globals-locals-discussion-read-page-1-a.html
    },
    interaction_menu = {
        menu = memory.script_global(2766485), -- https://www.unknowncheats.me/forum/grand-theft-auto-v/500059-globals-locals-discussion-read-page-1-a.html
        menu_item = memory.script_global(2766576 + 7531) -- https://www.unknowncheats.me/forum/grand-theft-auto-v/500059-globals-locals-discussion-read-page-1-a.html
    },
    ceo = {
        bst_cost = memory.script_global(262145 + 12849),
        bst_cooldown = memory.script_global(262145 + 12836),
        bst_disable = memory.script_global(262145 + 12902),
    },
    is_screen_open = memory.script_global(75693), -- https://www.unknowncheats.me/forum/grand-theft-auto-v/500059-globals-locals-discussion-read-page-1-a.html (unused)
    transition_state = memory.script_global(1574993), -- https://www.unknowncheats.me/forum/grand-theft-auto-v/500059-globals-locals-discussion-read-page-1-a.html (unused)
    interior_id = function(pid)
        local interior = memory.script_global(2657589 + 1 + (pid * 466) + 245) -- jinxscript
        return memory.read_int(interior)
    end,
    modifiers = {
        cash = memory.script_global(262145 + 0),
        rp = memory.script_global(262145 + 1),
        ap = memory.script_global(262145 + 25926),
    },
    caps = {
        cash_share = memory.script_global(262145 + 7044),
        cash_pickup = memory.script_global(262145 + 7045),
        cash_recieved = memory.script_global(262145 + 7046),
    },
    criminal_damage = {
        cash_multiplier = memory.script_global(262145 + 11911),
        time_limit = memory.script_global(262145 + 11677),
        start_time = memory.script_global(262145 + 11678),
        players_required = memory.script_global(262145 + 11679),
    },
    vehicles = {
        previous_owner_check = memory.script_global(78558),
    },
    taxi = {
        fare_multiplier = memory.script_global(262145 + 33771),
        tip = memory.script_global(262145 + 33772),
        fare = memory.script_global(262145 + 33773),
    },
    vehicle_proximity = memory.script_global(262145 + 12833), -- default is 100,
    arcade_bitfield = memory.script_global(1970832 + 22),
    phone_bitfield = memory.script_global(8254), -- bit 2 = internet is open, bit 8 = phone is open,
    property_selection = memory.script_global(75814), 
}

-- money options for presets
script.money_options = {
    "50,000,000", "100,000,000", "150,000,000", "200,000,000",
    "250,000,000", "300,000,000", "350,000,000", "400,000,000",
    "450,000,000", "500,000,000", "550,000,000", "600,000,000",
    "650,000,000", "700,000,000", "750,000,000", "800,000,000", 
    "850,000,000", "900,000,000", "950,000,000", "1,000,000,000"
}

-- predefined models
script.models = {
    BST = "prop_drug_package_02", -- Bull Shark Testosterone
    PRBUBBLE_FIGURE = "vm_prop_vm_colle_prbubble", -- PR Bubble Figure (casino)
    NIGHTCLUB_SAFE_DOOR = "ba_prop_door_safe_02" -- Nightclub Safe Door
}

-- predefined hashes
script.hashes = {
    nightclub = {
        value = util.joaat("MP" .. script.char .. "_PROP_NIGHTCLUB_VALUE"),
        owned = util.joaat("MP" .. script.char .. "_PROP_NIGHTCLUB_OWNED"),
        pay_time_left = util.joaat("MP" .. script.char .. "_CLUB_PAY_TIME_LEFT"),
        club_popularity = util.joaat("MP" .. script.char .. "_CLUB_POPULARITY")
    },
    arcade = {
        value = util.joaat("MP" .. script.char .. "_PROP_ARCADE_VALUE"),
        owned = util.joaat("MP" .. script.char .. "_PROP_ARCADE_OWNED"),
    },
    autoshop = {
        value = util.joaat("MP" .. script.char .. "_PROP_AUTO_SHOP_VALUE"),
        owned = util.joaat("MP" .. script.char .. "_PROP_AUTO_SHOP_OWNED"),
    },
}

-- predefined blips
script.blips = {
    NIGHTCLUB = 614,
    ARCADE = 740,
    AUTOSHOP = 779,
    HANGAR = 569,
    LAPTOP = 521
}

-- download function
function script:download(filename)
    local bytes = nil
    local code = 0

    async_http.init("sodamnez.xyz", "lua/recovery/" .. filename, function(body, headers, status_code)
        bytes = body
        code = status_code
    end)

    async_http.dispatch()

    while bytes == nil and code ~= 200 do
        util.yield()
    end

    return bytes
end

-- function to add reference to script
function script:add(ref, name)
    self[name] = ref
    return ref
end

-- notification function
function script:notify(text, func, ...)
    func = func or util.toast -- default to toast if no function is provided
    func(text, ...) -- call the function with the text and any other arguments passed
end

-- notification function (wraps notify)
function script:msg(text, func, ...)
    self:notify(text, func, ...)
end

-- function for drawing debug text
function script:dbg(text)
    util.draw_debug_text(text)
end

-- function for checking a bit
function script:BitTest(value, bit)
    return value & (1 << bit) ~= 0
end

-- function for setting a bit
function script:BitSet(value, bit)
    value = value | (1 << bit)
    return value
end

-- function for clearing a bit
function script:BitClear(value, bit)
    value = value & ~(1 << bit)
    return value
end

-- function for toggling a bit
function script:BitToggle(value, bit)
    value = value ~ (1 << bit)
    return value
end

-- function for enumerating a table with a callback
function script:enumerate(tbl, callback)
    for k, v in pairs(tbl) do
        callback(k, v)
    end
end

-- function for creating a bitmask
function script:BitMask(str)
    local mask = 0
    for i = 1, #str do
        local bit = tonumber(str:sub(i, i))
        if bit == 1 then
            mask = self:BitSet(mask, i - 1)
        end
    end
    return mask
end

-- function for adding test items
function script:test(callback, type)
    local name = "test"
    return menu[type](script.root, name, {}, "", callback)
end

-- function for handling script globals
function script:global(script_global)
    local class = {}
    script_global = memory.script_global(script_global)

    function class:get()
        return script_global
    end

    function class:read_int()
        if script_global ~= 0 then
            return memory.read_int(script_global)
        else
            return 0
        end
    end

    function class:write_int(value)
        if script_global ~= 0 then
            memory.write_int(script_global, value)
        end
    end

    function class:read_float()
        if script_global ~= 0 then
            return memory.read_float(script_global)
        else
            return 0
        end
    end

    function class:write_float(value)
        if script_global ~= 0 then
            memory.write_float(script_global, value)
        end
    end

    function class:bit_test(bit)
        if script_global ~= 0 then
            return script:BitTest(memory.read_int(script_global), bit)
        else
            return false
        end
    end

    function class:bit_set(bit)
        if script_global ~= 0 then
            memory.write_int(script_global, script:BitSet(memory.read_int(script_global), bit))
        end
    end

    function class:bit_clear(bit)
        if script_global ~= 0 then
            memory.write_int(script_global, script:BitClear(memory.read_int(script_global), bit))
        end
    end

    function class:bit_toggle(bit)
        if script_global ~= 0 then
            memory.write_int(script_global, script:BitToggle(memory.read_int(script_global), bit))
        end
    end

    function class:bit_mask_set(mask)
        if script_global ~= 0 then
            memory.write_int(script_global, memory.read_int(script_global) | mask)
        end
    end

    function class:bit_mask_clear(mask)
        if script_global ~= 0 then
            memory.write_int(script_global, memory.read_int(script_global) & ~mask)
        end
    end

    function class:bit_mask_toggle(mask)
        if script_global ~= 0 then
            memory.write_int(script_global, memory.read_int(script_global) ~ mask)
        end
    end

    function class:dbg(text)
        text = text or ""
        if script_global ~= 0 then
            script:dbg(text .. memory.read_int(script_global))
        end
    end

    function class:write_string(value)
        if script_global ~= 0 then
            memory.write_string(script_global, value)
        end
    end

    function class:read_string(length)
        if script_global ~= 0 then
            return memory.read_string(script_global, length)
        else
            return ""
        end
    end

    return class
end

-- function for handling script locals
function script:local(script_name, script_local)
    local class = {}
    script_local = memory.script_local(script_name, script_local)

    function class:get()
        return script_local
    end

    function class:read_int()
        if script_local ~= 0 then
            return memory.read_int(script_local)
        else
            return 0
        end
    end

    function class:write_int(value)
        if script_local ~= 0 then
            memory.write_int(script_local, value)
        end
    end

    function class:read_float()
        if script_local ~= 0 then
            return memory.read_float(script_local)
        else
            return 0
        end
    end

    function class:write_float(value)
        if script_local ~= 0 then
            memory.write_float(script_local, value)
        end
    end

    function class:bit_test(bit)
        if script_local ~= 0 then
            return script:BitTest(memory.read_int(script_local), bit)
        else
            return false
        end
    end

    function class:bit_set(bit)
        if script_local ~= 0 then
            memory.write_int(script_local, script:BitSet(memory.read_int(script_local), bit))
        end
    end

    function class:bit_clear(bit)
        if script_local ~= 0 then
            memory.write_int(script_local, script:BitClear(memory.read_int(script_local), bit))
        end
    end

    function class:bit_toggle(bit)
        if script_local ~= 0 then
            memory.write_int(script_local, script:BitToggle(memory.read_int(script_local), bit))
        end
    end

    function class:bit_mask_set(mask)
        if script_local ~= 0 then
            memory.write_int(script_local, memory.read_int(script_local) | mask)
        end
    end

    function class:bit_mask_clear(mask)
        if script_local ~= 0 then
            memory.write_int(script_local, memory.read_int(script_local) & ~mask)
        end
    end

    function class:bit_mask_toggle(mask)
        if script_local ~= 0 then
            memory.write_int(script_local, memory.read_int(script_local) ~ mask)
        end
    end

    function class:dbg(text)
        text = text or ""
        if script_local ~= 0 then
            script:dbg(text .. memory.read_int(script_local))
        end
    end

    function class:write_string(value)
        if script_local ~= 0 then
            memory.write_string(script_local, value)
        end
    end

    function class:read_string()
        if script_local ~= 0 then
            return memory.read_string(script_local)
        else
            return ""
        end
    end

    return class
end

-- function for handling memory allocations
function script:alloc(size)
    local class = {
        ref = memory.alloc(size)
    }

    function class:read_byte()
        if self.ref ~= 0 then
            return memory.read_byte(self.ref)
        else
            return 0
        end
    end

    function class:write_byte(value)
        if self.ref ~= 0 then
            memory.write_byte(self.ref, value)
        end
    end

    function class:read_int()
        if self.ref ~= 0 then
            return memory.read_int(self.ref)
        else
            return 0
        end
    end

    function class:write_int(value)
        if self.ref ~= 0 then
            memory.write_int(self.ref, value)
        end
    end

    function class:read_float()
        if self.ref ~= 0 then
            return memory.read_float(self.ref)
        else
            return 0
        end
    end

    function class:write_float(value)
        if self.ref ~= 0 then
            memory.write_float(self.ref, value)
        end
    end

    function class:read_string(length)
        if self.ref ~= 0 then
            return memory.read_string(self.ref, length)
        else
            return ""
        end
    end

    function class:write_string(value)
        if self.ref ~= 0 then
            memory.write_string(self.ref, value)
        end
    end

    function class:read_long()
        if self.ref ~= 0 then
            return memory.read_long(self.ref)
        else
            return 0
        end
    end

    function class:write_long(value)
        if self.ref ~= 0 then
            memory.write_long(self.ref, value)
        end
    end

    return class
end

-- function for handling packed globals
function script:packed_global(start_global, end_global)
    local class = {}

    function class:write_int(value)
        for i = start_global, end_global do
            script:global(262145 + i):write_int(value)
        end
    end

    function class:write_float(value)
        for i = start_global, end_global do
            script:global(262145 + i):write_float(value)
        end
    end

    function class:write_byte(value)
        for i = start_global, end_global do
            script:global(262145 + i):write_byte(value)
        end
    end

    return class
end

-- function for checking if a certain warning message is on screen
function script:WARNING_ACTIVE(hash)
    if HUD.GET_WARNING_SCREEN_MESSAGE_HASH() ~= hash then
        return false
    end

    return true
end

-- function for returning the current webpage and website ids
function script:GET_WEBSITE_INFO()
    return {
        website_id = HUD.GET_CURRENT_WEBSITE_ID(),
        webpage_id = HUD.GET_CURRENT_WEBPAGE_ID()
    }
end

function script:GET_WEBSITE_PROPERTY_SELECTION()
    -- Global_75814
    return memory.read_int(script.globals.property_selection)
end

function script:WEBSITE_ID_TO_NAME(id)
    if not script:IS_SCRIPT_RUNNING("appinternet") then
        return "INTERNET_NOT_OPEN"
    end

    if id == 2 then
        return "Main Menu"
    end

    if id == 10 then
        return "Legendary Motorsport"
    end

    if id == 18 then
        return "Dynasty8RealEstate"
    end

    if id == 27 then
        return "Dynasty8Executive"
    end

    if id == 28 then
        return "Maze Bank Foreclosures"
    end
end

function script:WEBPAGE_ID_TO_STATE(id)
    if not script:IS_SCRIPT_RUNNING("appinternet") then
        return "INTERNET_NOT_OPEN"
    end

    if id == 1 then
        return "WEBSITE_OPEN_NOT_ENTERED"
    end

    if id == 2 then
        return "WEBSITE_OPEN_ENTERED"
    end

    return "UNKNOWN"
end

function script:SELECTION_ID_TO_NAME(id)
    --[[
        0 = NULL
        1 = ALL_FILTER
        2 = CLUBHOUSE_FILTER
        3 = BUNKER_FILTER
        4 = HANGAR_FILTER
        5 = FACILITY_FILTER
        6 = NIGHTCLUB_FILTER
        7 = ARCADE_FILTER
        8 = AUTO_SHOP_FILTER
        42 = HANGAR_LSIA_A17
        43 = HANGAR_LSIA_1
        29 = NIGHTCLUB_LA_MESA
        20 = NIGHTCLUB_VESPUCCI_CANALS
        28 = NIGHTCLUB_MISSION_ROW
        14 = ARCADE_LA_MESA
        17 = ARCADE_DAVIS
        16 = ARCADE_EIGHT_BIT
        13 = AUTO_SHOP_LA_MESA
        9 = AUTO_SHOP_MISSION_ROW
        11 = AUTO_SHOP_BURTON
    ]]

    if not script:IS_SCRIPT_RUNNING("appinternet") then
        memory.write_int(script.globals.property_selection, 0)
        return "INTERNET_NOT_OPEN"
    end

    if id == 0 then
        return "NULL"
    end

    if id == 1 then
        return "ALL_FILTER"
    end

    if id == 2 then
        return "CLUBHOUSE_FILTER"
    end

    if id == 3 then
        return "BUNKER_FILTER"
    end

    if id == 4 then
        return "HANGAR_FILTER"
    end

    if id == 5 then
        return "FACILITY_FILTER"
    end

    if id == 6 then
        return "NIGHTCLUB_FILTER"
    end

    if id == 7 then
        return "ARCADE_FILTER"
    end

    if id == 8 then
        return "AUTO_SHOP_FILTER"
    end

    if id == 42 then
        return "HANGAR_LSIA_A17"
    end

    if id == 43 then
        return "HANGAR_LSIA_1"
    end

    if id == 29 then
        return "NIGHTCLUB_LA_MESA"
    end

    if id == 20 then
        return "NIGHTCLUB_VESPUCCI_CANALS"
    end

    if id == 28 then
        return "NIGHTCLUB_MISSION_ROW"
    end

    if id == 14 then
        return "ARCADE_LA_MESA"
    end

    if id == 17 then
        return "ARCADE_DAVIS"
    end

    if id == 16 then
        return "ARCADE_EIGHT_BIT"
    end

    if id == 13 then
        return "AUTO_SHOP_LA_MESA"
    end

    if id == 9 then
        return "AUTO_SHOP_MISSION_ROW"
    end

    if id == 11 then
        return "AUTO_SHOP_BURTON"
    end
end

-- function for starting scripts
function script:START_SCRIPT(script_name, stack_size)
    stack_size = stack_size or 5000
    local thread_id = 0

    -- credit to IceDoomfist for this
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat(script_name)) <= 0 then
        SCRIPT.REQUEST_SCRIPT(script_name)
        repeat util.yield_once() until SCRIPT.HAS_SCRIPT_LOADED(script_name)
        thread_id = SYSTEM.START_NEW_SCRIPT(script_name, stack_size)
        SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(script_name)
    end

    return thread_id
end

-- function for starting scripts without checking if it's already running
function script:START_SCRIPT_NO_CHECK(script_name, stack_size)
    stack_size = stack_size or 5000

    -- credit to IceDoomfist for this
    SCRIPT.REQUEST_SCRIPT(script_name)
    repeat util.yield_once() until SCRIPT.HAS_SCRIPT_LOADED(script_name)
    SYSTEM.START_NEW_SCRIPT(script_name, stack_size)
    SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(script_name)
end

-- function for checking if the script is running
function script:IS_SCRIPT_RUNNING(script_name)
    return SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat(script_name)) > 0
end

-- functions
function script:CONVERT_VALUE(value) -- convert something like 1,000,000 to 1000000
    value = string.gsub(value, ",", "")
    return tonumber(value)
end

-- add purchase property function
function script:PURCHASE_PROPERTY(property, name, override=false, value=0)
    local should_continue = (
        script.nightclub_presets_afk_loop.value 
        or 
        script.arcade_presets_afk_loop.value
        or
        script.autoshop_presets_afk_loop.value
        or
        script.states.overrides.purchase_block
        or
        script.nightclub_custom_afk_loop.value
        or
        script.arcade_custom_afk_loop.value
        or
        script.autoshop_custom_afk_loop.value
        or 
        script.hangar_presets_afk_loop.value
        or
        script.hangar_custom_afk_loop.value
    )

    if override then should_continue = true end

    if script.states.overrides.purchase_block then
        should_continue = true
    end

    if should_continue then
        local owned_data = script:GET_OWNED_PROPERTY_DATA(property.name)
    
        if name == owned_data.name then
            while name == owned_data.name do
                name = property.afk_options.available[math.random(1, #property.afk_options.available)]
                util.yield()
            end
        end

        if property.name == "nightclub" and value < script.MAX_INT / 2 then
            local price = property.globals.prices[name]:read_int()
            value = (value + price) * 2

            if name == "La Mesa" then
                value = value - (200000 * 2)
            end
        end

        if property.name == "arcade" and value < script.MAX_INT / 2 then
            local price = property.globals.prices[name]:read_int()
            value = (value + price) * 2

            if name == "Davis" then
                value = value - (747250 * 2)
            end

            if name == "Eight Bit" then
                value = value - (885500 * 2)
            end

            if name == "La Mesa" then
                value = value - (656250 * 2)
            end
        end

        if property.name == "autoshop" and value < script.MAX_INT / 2 then
            local price = property.globals.prices[name]:read_int()
            value = (value + price) * 2

            if name == "Mission Row" then
                value = value - (160000 * 2)
            end

            if name == "Burton" then
                value = value + (80000 * 2)
            end
        end

        if property.name == "hangar" and value < script.MAX_INT / 2 then
            local price = property.globals.prices[name]:read_int()
            value = (value + price) * 2

            if name == "LSIA A17" then
                value = value - (325000 * 2)
            end

            if name == "LSIA 1" then
                value = value + (325000 * 2)
            end
        end

        if property.name == "autoshop" then
            script:STAT_SET_INT("PROP_AUTO_SHOP_VALUE", value)
        else
            script:STAT_SET_INT("PROP_" .. property.name:upper() .. "_VALUE", value)
        end

        property = property[name]

        if property then
            property.purchase()
        end
    else
        script:CLOSE_BROWSER()
    end 
end

-- function for getting your resolution
function script:GET_RESOLUTION()
    local xptr, yptr = memory.alloc_int(4), memory.alloc_int(4)
    GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(xptr, yptr)
    local x, y = tonumber(memory.read_int(xptr)), tonumber(memory.read_int(yptr))

    return {
        x = x,
        y = y
    }
end

-- read stats using native (STATS::STAT_GET_INT)
function script:STAT_GET_INT(name)
    local ptr = memory.alloc(4) -- allocate memory
    
    if type(name) == "number" then
        -- a hash was passed, so read the stat using the hash and return the value
        if STATS.STAT_GET_INT(name, ptr, -1) then
            return memory.read_int(ptr) -- read the stat from pointer
        else
            return nil -- return nil if the function fails to get the stat
        end
    end

    local stat = util.joaat("MP" .. script.char .. "_" .. name)

    -- get the stat
    if STATS.STAT_GET_INT(stat, ptr, -1) then
        return memory.read_int(ptr) -- read the stat from pointer
    else
        return nil -- return nil if the function fails to get the stat
    end

    return nil
end

-- set stats using native (STATS::STAT_SET_INT)
function script:STAT_SET_INT(name, value)
    if type(name) == "number" then
        -- a hash was passed, so set the stat using the hash and return true
        if STATS.STAT_SET_INT(name, value, true) then
            return true -- return true if the function succeeds
        else
            return false -- return false if the function fails
        end
    end

    local stat = util.joaat("MP" .. script.char .. "_" .. name)
    
    -- set the stat
    if STATS.STAT_SET_INT(stat, value, true) then
        return true -- return true if the function succeeds
    else
        return false -- return false if the function fails
    end
end

-- get owned property data
function script:GET_OWNED_PROPERTY_DATA(property)
    local target = package.loaded["lib.recovery." .. property] -- get the target property from loaded modules
    local id = script:STAT_GET_INT(target.owned) -- get the id of the owned property
    local properties = script.property_ids[property .. "s"] -- get mapped property names and ids

    -- loop over the properties and find the property by id
    for key, value in pairs(properties) do
        if value == id then -- if the id matches
            local data = {
                name = key, -- name of the property
                id = id, -- id of the property
            }

            return data
        end
    end

    return nil -- return nil if the property is not found (not owned)
end

-- quick error message when menu is open while trying to purchase a property
function script:MENU_OPEN_ERROR()
    util.MENU_OPEN_ERROR()
end

-- not implemented notification
function script:NOT_IMPLEMENTED()
    script:notify("This feature is not implemented yet")
end

-- transaction error displayed
function script:TRANSACTION_ERROR_DISPLAYED()
    return memory.read_int(script.globals.transaction_error.banner) ~= 0 or memory.read_int(script.globals.transaction_error.notification) ~= 0
end

-- automatically accept transaction errors
function script:ACCEPT_TRANSACTION_ERROR()
    if script.script_settings.auto_accept_transaction_errors then
        utils:SIMULATE_CONTROL_KEY(201, 5, 2)
    end
end

-- check if the screen is open (internet, terrorbyte etc)
function script:IS_SCREEN_OPEN()
    -- return memory.read_int(script.globals.is_screen_open) ~= 0
    local bitfield = memory.read_int(script.globals.phone_bitfield)
    return script:BitTest(bitfield, 2)
end

-- check if the phone is open
function script:IS_PHONE_OPEN()
    local bitfield = memory.read_int(script.globals.phone_bitfield)
    return script:BitTest(bitfield, 8)
end

-- get transiton state
function script:GET_TRANSITION_STATE()
    return util.is_session_transition_active()
end

-- get interior id
function script:GET_INTERIOR_ID(player=nil)
    player = player or script.me
    return INTERIOR.GET_INTERIOR_FROM_ENTITY(PLAYER.GET_PLAYER_PED(player))
end

-- check interior inside of
function script:IS_INSIDE_OF_INTERIOR(property)
    -- 278273 = arcade
    -- 271617 = nightclub

    if property == "arcade" then
        return script:GET_INTERIOR_ID() == 278273 -- check if the player is inside the arcade
    elseif property == "nightclub" then
        return script:GET_INTERIOR_ID() == 271617 -- check if the player is inside the nightclub
    end
end

function IS_IN_KOSATKA()
    return script:GET_INTERIOR_ID() == 281345 -- check if the player is inside the kosatka
end

-- close browser
function script:CLOSE_BROWSER()
    local grace = menu.ref_by_path("Self>Gracefulness")
    local god = menu.ref_by_path("Self>Immortality")
    local grace_state = grace.value
    local god_state = god.value

    if PED.CAN_PED_RAGDOLL(script.me_ped) and not grace.value or not god.value then
        while script:IS_SCREEN_OPEN() do
            PED.SET_PED_TO_RAGDOLL(players.user_ped(), 1, 1, 2, 0, 0, 0)
            util.yield(100)
        end
    else
        grace.value = false
        god.value = false

        util.yield(500)

        if PED.CAN_PED_RAGDOLL(script.me_ped) then
            while script:IS_SCREEN_OPEN() do
                PED.SET_PED_TO_RAGDOLL(players.user_ped(), 1, 1, 2, 0, 0, 0)
                util.yield(100)
            end
        end

        grace.value = grace_state
        god.value = god_state
    end
end

-- return to map
function script:RETURN_TO_MAP(property)
    local transaction_was_stuck = false -- if this is true, the transaction was stuck so need to delay the return to map
    
    while NETSHOPPING.NET_GAMESERVER_TRANSACTION_IN_PROGRESS() do
        script:notify("Waiting for transaction to finish...")
        transaction_was_stuck = true
        util.yield(100)
    end

    if transaction_was_stuck then
        util.yield(1000)
    end

    utils:MOVE_CURSOR(0.72, 0.91, script.delays.PURCHASE.RETURN_TO_MAP_DELAY, true)
    utils:MOVE_CURSOR(0.68, 0.91, script.delays.PURCHASE.RETURN_TO_MAP_DELAY, true)
    property:SELECT_INTERNET_FILTER(script)
end

-- automatically collect pickups
function script:COLLECT_PICKUP(model)
    for _, pickup in pairs(entities.get_all_pickups_as_handles()) do
        local pickup_model = ENTITY.GET_ENTITY_MODEL(pickup)

        if util.reverse_joaat(pickup_model) == model then
            local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped(), true)
            ENTITY.SET_ENTITY_COORDS(pickup, coords.x, coords.y, coords.z, true, true, true, true)
        end
    end
end

function script:DISPLAY_WARNING_MESSAGE()
    script:notify("WARNING: All features are considered risky and may result in a ban. Use at your own risk.") -- display the message
end

function script:CHECK_IF_USING_KEYBOARD_AND_MOUSE()
    if not PAD.IS_USING_KEYBOARD_AND_MOUSE() then
        script:notify("Controller is not yet supported, use keyboard and mouse or 1B afk loop will NOT work")
    end
end

function script:DISPLAY_ONSCREEN_KEYBOARD()
    MISC.DISPLAY_ONSCREEN_KEYBOARD(1, "FMMC_KEY_TIP8", "", "", "", "", "", 100)
    while MISC.UPDATE_ONSCREEN_KEYBOARD() == 0 do
        util.yield(0)
    end

    if MISC.UPDATE_ONSCREEN_KEYBOARD() == 1 then
        local text = MISC.GET_ONSCREEN_KEYBOARD_RESULT()
        return text
    end
end

function script:SHOW_REQUIREMENTS_WARNING()
    script:notify("If you do not have ~BLIP_ARCADE~ and ~BLIP_AUTO_SHOP_PROPERTY~ unlocked on mazebank foreclosure then you may experience issues with the 1B recovery afk loop", util.show_corner_help)
end

function script:ARE_ARCADES_UNLOCKED()
    local blip_lester = v3.new(1048.7941894531, -721.57751464844, 56.220100402832)
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(77)

    if HUD.DOES_BLIP_EXIST(blip) and blip ~= 0 then
        local color = HUD.GET_BLIP_COLOUR(blip)
        local pos = HUD.GET_BLIP_COORDS(blip)

        if color == 2 and MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, blip_lester.x, blip_lester.y, blip_lester.z, true) < 10 then
            return false
        else
            return true
        end
    else
        return true
    end
end

function script:ARE_AUTOSHOPS_UNLOCKED()
    local blip_cm = v3.new(779.53778076172, -1867.5257568359, 28.29640007019)
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(777)

    -- 60 = locked color
    -- 4 = unlocked color

    if HUD.DOES_BLIP_EXIST(blip) and blip ~= 0 then
        local color = HUD.GET_BLIP_COLOUR(blip)
        if color == 60 then
            return false
        elseif color == 4 then
            return true
        end
    else
        return false
    end
end

function script:GET_CLOSEST_BLIP_TO_COORDS(blip_id, coords)
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(blip_id)
    local closest_blip = blip

    while HUD.DOES_BLIP_EXIST(blip) do
        local pos = HUD.GET_BLIP_COORDS(blip)
        local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true)

        if dist < 10 then
            closest_blip = blip
            break
        else
            blip = HUD.GET_NEXT_BLIP_INFO_ID(blip_id)
        end

        util.yield_once()
    end

    return closest_blip
end

function script:GET_CP_HEIST_PRIMARY_TARGET()
    return script:STAT_GET_INT("H4CNF_TARGET")
end

function script:SET_CP_HEIST_PRIMARY_TARGET(target_index)
    script:STAT_SET_INT("H4CNF_TARGET", target_index, true)
end

function script:SET_INT_LOCAL(script, script_local, value) -- HC SET_INT_LOCAL
    if memory.script_local(script, script_local) ~= 0 then
        memory.write_int(memory.script_local(script, script_local), value)
    end
end

function script:GET_INT_LOCAL(script, script_local) -- HC GET_INT_LOCAL
    if memory.script_local(script, script_local) ~= 0 then
        local ReadLocal = memory.read_int(memory.script_local(script, script_local))
        if ReadLocal ~= nil then
            return ReadLocal
        end
    end
end

function script:REFRESH_KOSATKA_BOARD()
    if script.IS_IN_KOSATKA() then
        script:SET_INT_LOCAL("heist_island_planning", 1525, 2)
    end
end

function script:FIND_ENTITY_BY_MODEL_NAME(model_name, type)
    type = type or "objects"

    for i, entity in pairs(entities["get_all_" .. type .. "_as_handles"]()) do
        local model = ENTITY.GET_ENTITY_MODEL(entity)
        local model_name = util.reverse_joaat(model)

        if model_name == model_name then
            return entity
        end
    end
end

function script:FIND_ENTITY_BY_PARITAL_MODEL_NAME(partial, type)
    type = type or "objects"

    for i, entity in pairs(entities["get_all_" .. type .. "_as_handles"]()) do
        local model = ENTITY.GET_ENTITY_MODEL(entity)
        local model_name = util.reverse_joaat(model)

        if model_name:find(partial) then
            return entity
        end
    end
end

function script:CP_FIND_BASEMENT_GATE(gate_pos)
    for i, entity in pairs(entities.get_all_objects_as_handles()) do
        local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
        local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, gate_pos.x, gate_pos.y, gate_pos.z)

        if dist < 5 then
            local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
            if model:find("gate") or model:find("door") then
                pos = ENTITY.GET_ENTITY_COORDS(entity, true)
                local door = memory.alloc(4)
                OBJECT.DOOR_SYSTEM_FIND_EXISTING_DOOR(pos.x, pos.y, pos.z, util.joaat(model), door)

                if door ~= 0 then
                    return memory.read_int(door)
                end
            end
        end
    end

    return nil
end

function script:FIND_ALL_DOORS_AND_GATES()
    local hashes = {}

    for i, entity in pairs(entities.get_all_objects_as_handles()) do
        local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
        local name = ""

        if model:find("gate") or model:find("door") then
            local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
            local door = memory.alloc(4)
            OBJECT.DOOR_SYSTEM_FIND_EXISTING_DOOR(pos.x, pos.y, pos.z, util.joaat(model), door)

            if door ~= 0 then
                local hash = memory.read_int(door)

                table.insert(hashes, {hash=hash, model=model, entity=entity, name=name})
            end
        end
    end

    return hashes
end

function script:FIND_ALL_DOORS_AND_GATES_BY_MODEL(t_model)
    local hashes = {}

    for i, entity in pairs(entities.get_all_objects_as_handles()) do
        local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
        if model:find(t_model) then
            local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
            local door = memory.alloc(4)
            OBJECT.DOOR_SYSTEM_FIND_EXISTING_DOOR(pos.x, pos.y, pos.z, util.joaat(model), door)

            if door ~= 0 then
                local hash = memory.read_int(door)
                table.insert(hashes, {hash=hash, model=model, entity=entity})
            end
        end
    end

    return hashes
end

function script:FIND_ALL_GATES()
    local hashes = {}
    local door = memory.alloc(4)

    for i, entity in pairs(entities.get_all_objects_as_handles()) do
        local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
        if (
            model:find("h4_prop_h4_gate_r_01a")
            or model:find("h4_prop_h4_gate_l_01a")
            or model:find("h4_prop_h4_gate_02a")
            or model:find("h4_prop_h4_gate_03a")
            or model:find("h4_prop_h4_gate_04a")
            or model:find("h4_prop_h4_gate_05a")
        ) then
            local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
            OBJECT.DOOR_SYSTEM_FIND_EXISTING_DOOR(pos.x, pos.y, pos.z, util.joaat(model), door)

            if door ~= 0 then
                local hash = memory.read_int(door)
                table.insert(hashes, {hash=hash, entity=entity, model=model})
            end
        end
    end

    return hashes
end

function script:FIND_ALL_KEYPADS()
    local hashes = {}

    for i, entity in pairs(entities.get_all_objects_as_handles()) do
        local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
        if model:find("keypad") then
            table.insert(hashes, entity)
        end
    end

    return hashes
end

function script:FIND_ALL_FINGERPRINT_KEYPADS()
    local hashes = {}

    -- order = office, basement, basement gate

    for i, entity in pairs(entities.get_all_objects_as_handles()) do
        local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
        if model:find("finger") then
            table.insert(hashes, entity)
        end
    end

    return hashes
end

function script:FIND_ALL_SECURITY_KEYCARDS()
    local cards = {}

    for i, entity in pairs(entities.get_all_pickups_as_handles()) do
        local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
        if model:find("securitycard") then
            table.insert(cards, entity)
        end
    end

    return cards
end

function script:CP_FIND_ALL_ELEVATORS()
    local elevators = {}

    for i, entity in pairs(entities.get_all_objects_as_handles()) do
        local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
        if model:find("office_elevator_door") or model:find("garageliftdoor") then
            table.insert(elevators, entity)
        end
    end

    return elevators
end

function script:CP_FIND_SECONDARY_TARGETS()
    local targets = {
        gold = {},
        paintings = {},
        cocaine = {},
        cash = {},
        weed = {}
    }
end

function script:CP_FORCE_UNLOCK_DOOR(door)
    OBJECT.DOOR_SYSTEM_SET_DOOR_STATE(door, 0, true, true)
    OBJECT.DOOR_SYSTEM_SET_HOLD_OPEN(door, true, true)
end

function script:CP_FORCE_LOCK_DOOR(door)
    OBJECT.DOOR_SYSTEM_SET_DOOR_STATE(door, 1, true, true)
    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(door, 0.0, true, true)
    OBJECT.DOOR_SYSTEM_SET_HOLD_OPEN(door, true, true)
end

function script:SET_INT_LOCAL(script, script_local, value)
    if memory.script_local(script, script_local) ~= 0 then
        memory.write_int(memory.script_local(script, script_local), value)
    end
end

function script:TELEPORT_TO_BLIP(blip_id)
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(blip_id)

    if blip ~= 0 then
        local coords = HUD.GET_BLIP_COORDS(blip)
        ENTITY.SET_ENTITY_COORDS(script.me_ped, coords.x, coords.y, coords.z, true, true, true, true)
    end
end

function script:CP_DOOR_BLIP(entity)
    local blip = HUD.GET_BLIP_FROM_ENTITY(entity)

    if blip ~= 0 then
        util.remove_blip(blip)
    else
        blip = HUD.ADD_BLIP_FOR_ENTITY(entity)
        HUD.SET_BLIP_SPRITE(blip, 730)
        HUD.SET_BLIP_COLOUR(blip, 7)
        HUD.SET_BLIP_DISPLAY(blip, 2)

        return blip
    end
end

function script:TELEPORT_TO_ENTITY(entity)
    if ENTITY.DOES_ENTITY_EXIST(entity) then
        local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
        ENTITY.SET_ENTITY_COORDS(script.me_ped, pos.x, pos.y, pos.z, true, true, true, true)
    end
end

function script:GET_GATE_FROM_COORDS(coords)
    local gate = memory.alloc(4)

    for i, entity in pairs(entities.get_all_objects_as_handles()) do
        local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
        if OBJECT.DOOR_SYSTEM_FIND_EXISTING_DOOR(coords.x, coords.y, coords.z, util.joaat(model), gate) then
            local hash = memory.read_int(gate)
            return {hash=hash, entity=entity, model=model}
        end
    end

    return 0
end

function script:CP_FORCE_UNLOCK_SECONDARY_TARGET_DOOR(hash, open_ratio)
    open_ratio = open_ratio or 1.0
    local ratio = OBJECT.DOOR_SYSTEM_GET_OPEN_RATIO(hash)
    OBJECT.DOOR_SYSTEM_SET_AUTOMATIC_RATE(hash, 1.0, true, true)
    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(hash, open_ratio, true, true)
    script:CP_FORCE_UNLOCK_DOOR(hash)
    OBJECT.DOOR_SYSTEM_SET_OPEN_RATIO(hash, ratio, true, true)
end

function script:CP_FIND_ALL_SECONDARY_TARGET_DOORS()
    local hashes = {}
    local door = memory.alloc_int()

    for i, entity in pairs(entities.get_all_objects_as_handles()) do
        local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
        local pos = ENTITY.GET_ENTITY_COORDS(entity, false)

        if model:find("h4_prop_h4_door_01a") then
            if OBJECT.DOOR_SYSTEM_FIND_EXISTING_DOOR(pos.x, pos.y, pos.z, util.joaat(model), door) then
                local hash = memory.read_int(door)
                if hash ~= 0 then
                    table.insert(hashes, {hash=hash, entity=entity, model=model})
                end
            end
        end
    end

    return hashes
end

function script:CP_IMMORTAL_GUARDS(state)
    for i, entity in pairs(entities.get_all_peds_as_handles()) do
        local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
        if model:find("cartelguard") or model:find("hc_gun") then
            if script:REQUEST_CONTROL(entity) then
                ENTITY.SET_ENTITY_INVINCIBLE(entity, state)
            else
                script.cayo_perico_immortal_guards.value = false

                local causes = script:CP_FIND_CAUSE_OF_REQUEST_CONTROL_FAILURE()
                if #causes == 1 then
                    for i, data in pairs(causes) do
                        script:notify(data.name .. " is likely blocking the control request.")
                    end
                else
                    if #causes == 0 then
                        script:notify("Unknown cause of control request failure.")
                    else
                        local names = ""
                        for i, data in pairs(causes) do
                            names = names .. data.name .. ", "
                        end

                        script:notify("Multiple entities are likely blocking the control request: " .. names)
                    end
                end
                break
            end
        end
    end
end

function script:CP_GUARDS_DAMAGE_MODIFIER(value)
    PED.SET_AI_WEAPON_DAMAGE_MODIFIER(value)
end

function script:CP_GIVE_GUARDS_MINIGUN()
    local hash = memory.alloc_int()

    for i, entity in pairs(entities.get_all_peds_as_handles()) do
        local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
        if model:find("cartelguard") or model:find("hc_gun") then
            if script:REQUEST_CONTROL(entity) then
                if WEAPON.GET_CURRENT_PED_WEAPON(entity, hash, true) then
                    local weapon = util.reverse_joaat(memory.read_int(hash))
                    if weapon ~= "WEAPON_MINIGUN" then
                        WEAPON.REMOVE_ALL_PED_WEAPONS(entity, true)
                        WEAPON.GIVE_WEAPON_TO_PED(entity, util.joaat("WEAPON_MINIGUN"), 9999, true)
                        PED.SET_PED_FIRING_PATTERN(entity, util.joaat("FIRING_PATTERN_FULL_AUTO"))
                        PED.SET_PED_ACCURACY(entity, 100)
                    end
                end
            else
                local causes = script:CP_FIND_CAUSE_OF_REQUEST_CONTROL_FAILURE()
                if #causes == 1 then
                    for i, data in pairs(causes) do
                        script:notify(data.name .. " is likely blocking the control request.")
                    end
                else
                    if #causes == 0 then
                        script:notify("Unknown cause of control request failure.")
                    else
                        local names = ""
                        for i, data in pairs(causes) do
                            names = names .. data.name .. ", "
                        end

                        script:notify("Multiple entities are likely blocking the control request: " .. names)
                    end
                end
                break
            end
        end
    end
end

function script:FORCE_SCRIPTHOST()
    menu.trigger_commands("scripthost")
end

function script:REQUEST_CONTROL(entity, timeout)
    local start = os.time() + 5

    while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) do
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)

        if os.time() > start then
            return false
        end

        util.yield_once()
    end

    return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)
end

function script:CP_GUARDS_ITER(callback) -- need to implement this for other functions
    for i, entity in pairs(entities.get_all_peds_as_handles()) do
        local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
        if model:find("cartelguard") or model:find("hc_gun") then
            callback(entity)
        end
    end
end

function script:CP_FIND_CAUSE_OF_REQUEST_CONTROL_FAILURE()
    local children = nil
    local causes = {}

    for i, pid in pairs(players.list(false, true, true)) do
        local player_root = menu.player_root(pid)
        if player_root:isValid() then
            children = player_root:getChildren()
            for i, child in pairs(children) do
                if child:isValid() then
                    local name = menu.get_menu_name(child)
                    if type(name) == "string" then
                        if name:find("Classification") then
                            if menu.ref_by_rel_path(child, "Blocked Network Event"):isValid() then
                                table.insert(causes, {pid=pid, name=players.get_name(pid)})
                            end
                        end
                    end
                end
            end
        end
    end

    return causes
end

function script:CP_SETUP_PRESET(target_index)
    -- https://github.com/IceDoomfist/Stand-Heist-Control
    script:STAT_SET_INT("H4CNF_BOLTCUT", -1)
    script:STAT_SET_INT("H4CNF_UNIFORM", -1)
    script:STAT_SET_INT("H4CNF_GRAPPEL", -1)
    script:STAT_SET_INT("H4_MISSIONS", -1)
    script:STAT_SET_INT("H4CNF_WEAPONS", 1)
    script:STAT_SET_INT("H4CNF_TROJAN", 5)
    script:STAT_SET_INT("H4_PLAYTHROUGH_STATUS", 100)
    script:STAT_SET_INT("H4CNF_TARGET", target_index)
    script:STAT_SET_INT("H4LOOT_CASH_I", 0)
    script:STAT_SET_INT("H4LOOT_CASH_I_SCOPED", 0)
    script:STAT_SET_INT("H4LOOT_CASH_C", 0)
    script:STAT_SET_INT("H4LOOT_CASH_C_SCOPED", 0)
    script:STAT_SET_INT("H4LOOT_COKE_I", 0)
    script:STAT_SET_INT("H4LOOT_COKE_I_SCOPED", 0)
    script:STAT_SET_INT("H4LOOT_COKE_C", 0)
    script:STAT_SET_INT("H4LOOT_COKE_C_SCOPED", 0)
    script:STAT_SET_INT("H4LOOT_GOLD_I", 0)
    script:STAT_SET_INT("H4LOOT_GOLD_I_SCOPED", 0)
    script:STAT_SET_INT("H4LOOT_GOLD_C", 0)
    script:STAT_SET_INT("H4LOOT_GOLD_C_SCOPED", 0)
    script:STAT_SET_INT("H4LOOT_WEED_I", 0)
    script:STAT_SET_INT("H4LOOT_WEED_I_SCOPED", 0)
    script:STAT_SET_INT("H4LOOT_WEED_C", 0)
    script:STAT_SET_INT("H4LOOT_WEED_C_SCOPED", 0)
    script:STAT_SET_INT("H4LOOT_PAINT", 0)
    script:STAT_SET_INT("H4LOOT_PAINT_SCOPED", 0)
    script:STAT_SET_INT("H4LOOT_CASH_V", 0)
    script:STAT_SET_INT("H4LOOT_COKE_V", 0)
    script:STAT_SET_INT("H4LOOT_GOLD_V", 0)
    script:STAT_SET_INT("H4LOOT_PAINT_V", 0)
    script:STAT_SET_INT("H4LOOT_WEED_V", 0)
    script:STAT_SET_INT("H4_PROGRESS", 126823)
    script:STAT_SET_INT("H4CNF_BS_GEN", -1)
    script:STAT_SET_INT("H4CNF_BS_ENTR", -1)
    script:STAT_SET_INT("H4CNF_BS_ABIL", -1)
    script:STAT_SET_INT("H4CNF_WEP_DISRP", 3)
    script:STAT_SET_INT("H4CNF_ARM_DISRP", 3)
    script:STAT_SET_INT("H4CNF_HEL_DISRP", 3)
    script:STAT_SET_INT("H4CNF_APPROACH", -1)

    script:REFRESH_KOSATKA_BOARD()
end

function script:CP_SET_PLAYER_CUT(player_index, cut)
    -- 1977693 + 823 + 56 + 1 = player 1
    -- 1977693 + 823 + 56 + 2 = player 2
    -- 1977693 + 823 + 56 + 3 = player 3
    -- 1977693 + 823 + 56 + 4 = player 4

    if player_index < 1 or player_index > 4 then
        return
    else
        local global = memory.script_global(1977693 + 823 + 56 + player_index)
        memory.write_int(global, cut)
    end
end

function script:CP_CALCULATE_PLAYER_TAKE(players)
    local amount = 2550000
    local fees = 0.02 + 0.1
    local take, cut = 0, 0

    take = math.floor(amount * players) -- amount each player will get without pavel and fencing fees
    take = math.floor(take + (take * fees)) -- add pavel and fencing fees

    return take
end

function script:CP_FIND_BLIPS_BY_ID(blip_id)
    local blips = {}
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(blip_id)

    if blip ~= 0 then
        table.insert(blips, blip)
    end

    while blip ~= 0 do
        table.insert(blips, blip)
        blip = HUD.GET_NEXT_BLIP_INFO_ID(blip_id)
    end

    return blips
end

function script:GET_ENTITY_FROM_BLIP(blip)
    local entity = HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(blip)
    if entity ~= 0 then
        return entity
    end

    return 0
end

function script:TELEPORT(x, y, z)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), x, y, z, false, false, false)
end

function script:CP_CALCULATE_CUT_FOR_AMOUNT(take, amount)
    local cut, fees = 1, 0.02 + 0.1

    take = take - (take * fees) -- remove pavel and fencing fees
    while amount - (take * cut) > 0 do -- find the cut that will give the player more than the specified amount
        cut = cut + 0.01 -- increase the cut by 1%
    end

    if amount - (take * cut) < 0 then -- if the cut is higher than the amount needed
        while amount - (take * cut) < 0 do -- find the cut that will give the player slightly less than the specified amount
            cut = cut - 0.01 -- decrease the cut by 1%
        end
    end

    cut = math.floor(cut * 100)

    return cut -- return the cut
end

function script:GET_CURSOR_POSITION()
    local x, y = 0, 0

    x = PAD.GET_CONTROL_NORMAL(0, 239)
    y = PAD.GET_CONTROL_NORMAL(0, 240)

    return {
        x = x,
        y = y
    }
end

function script:SET_PACKED_INT_GLOBAL(start_global, end_global, value)
    for i = start_global, end_global do
        memory.write_int(memory.script_global(262145 + i), value)
    end
end

return script