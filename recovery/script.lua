local script = setmetatable({}, {__index = _G})

-- require modules
local nightclub = require("lib.recovery.nightclub") -- require the nightclub module
local arcade = require("lib.recovery.arcade") -- require the arcade module
local autoshop = require("lib.recovery.autoshop") -- require the autoshop module
local utils = require("lib.recovery.utils") -- require the utils module

-- add script root
script.root = menu.my_root()

-- script settings
script.script_settings = {
    version = "1.5.0", -- script version
    ownership_check = true, -- ownership check for properties
    auto_accept_transaction_errors = true, -- automatically accept transaction errors
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
    block_purchase = false,
    bypass_blocked_state = false
}

-- predefined variables
script.me = players.user() -- you
script.me_ped = players.user_ped() -- your ped
script.MAX_INT = (2 << 30) - 1 -- max integer value
script.char = util.get_char_slot() -- character slot
script.update_backwards_compat = false -- update backwards compatibility

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
    prices = { -- gloals for prices of different properties
        
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
    },
    transaction_error = {
        banner = memory.script_global(4536673),
        notification = memory.script_global(4536674),
    },
    interaction_menu = {
        menu = memory.script_global(2766485),
        menu_item = memory.script_global(2766576 + 7531)
    },
    ceo = {
        bst_cost = memory.script_global(262145 + 12849),
        bst_cooldown = memory.script_global(262145 + 12836),
        bst_disable = memory.script_global(262145 + 12902),
    },
    is_screen_open = memory.script_global(75693),
    transition_state = memory.script_global(1574993),
    interior_id = function(pid)
        local interior = memory.script_global(2657589 + 1 + (pid * 466) + 245)
        return memory.read_int(interior)
    end,
    modifiers = {
        cash = memory.script_global(262145 + 0),
        rp = memory.script_global(262145 + 1),
    }
}

script.locals = { -- script locals
    -- no locals yet
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
    AUTOSHOP = 779
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
end

-- notification function
function script:notify(text, func, ...)
    func = func or util.toast -- default to toast if no function is provided
    func(text, ...) -- call the function with the text and any other arguments passed
end

-- functions
function script:CONVERT_VALUE(value) -- convert something like 1,000,000 to 1000000
    value = string.gsub(value, ",", "")
    return tonumber(value)
end

-- add purchase property function
function script:PURCHASE_PROPERTY(property, name)
    if not script.states.bypass_blocked_state then
        if property.name == "nightclub" then
            local ref = script.nightclub_presets_afk_loop
            if not ref.value then
                script:notify("Blocked purchase of " .. name .. " nightclub")
                if script:IS_SCREEN_OPEN() then
                    utils:CLOSE_BROWSER()
                end
                return
            end
        end
    
        if property.name == "arcade" then
            local ref = script.arcade_presets_afk_loop
            if not ref.value then
                script:notify("Blocked purchase of " .. name .. " arcade")
                if script:IS_SCREEN_OPEN() then
                    utils:CLOSE_BROWSER()
                end
                return
            end
        end
    
        if property.name == "autoshop" then
            local ref = script.autoshop_presets_afk_loop
            if not ref.value then
                script:notify("Blocked purchase of " .. name .. " autoshop")
                if script:IS_SCREEN_OPEN() then
                    utils:CLOSE_BROWSER()
                end
                return
            end
        end
    end

    local property = property[name]
    if property then
        property.purchase()
    end 
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
        --
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
                id = id -- id of the property
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

-- simulate user input
function SIMULATE_CONTROL_KEY(key, times, control=0, delay=300)
    for i = 1, times do
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(control, key, 1) -- press the key
        util.yield(delay) -- wait before attempting to press the key again
    end

    util.yield(100) 
end

-- move cursor
function MOVE_CURSOR(x, y, delay=300, autoclick=false)
    PAD.SET_CURSOR_POSITION(x, y) -- move the cursor
    util.yield(delay)

    if autoclick then
        SIMULATE_CONTROL_KEY(201, 1) -- press enter to select the option automatically
    end
end

-- function to quickly close the internet browser
function CLOSE_BROWSER()
    PED.SET_PED_TO_RAGDOLL(players.user_ped(), 1, 1, 2, 0, 0, 0) -- ragdoll the player
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
    return memory.read_int(script.globals.is_screen_open) ~= 0
end

-- get transiton state
function script:GET_TRANSITION_STATE()
    return memory.read_int(script.globals.transition_state)
end

-- get interior id
function script:GET_INTERIOR_ID(player=nil)
    player = player or script.me
    return script.globals.interior_id(player)
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

-- purchase bst
function script:BUY_BST(value=1000)
    local delay = 1

    if value < 1000 then value = 1000 end

    memory.write_int(script.globals.interaction_menu.menu, 30) -- render VIP/CEO abilties in interaction menu
    memory.write_int(script.globals.ceo.bst_cost, value)
    memory.write_int(script.globals.ceo.bst_cooldown, 0)
    memory.write_int(script.globals.ceo.bst_disable, 0)

    utils:SIMULATE_CONTROL_KEY(244, 1, 0, delay) -- open interaction menu
    utils:SIMULATE_CONTROL_KEY(173, 1, 0, delay) -- scroll down to bst
    
    if memory.read_int(script.globals.interaction_menu.menu_item) == 1 then -- make sure correct item is selected
        utils:SIMULATE_CONTROL_KEY(176, 1, 0, delay) -- press enter on bst
        util.yield(100)
        script:COLLECT_PICKUP(script.models.BST) -- collect bst
        memory.write_int(script.globals.ceo.bst_cost, 1000)
    else
        script:notify("Next time don\'t press any buttons dumbass")
    end
end

function script:DISPLAY_WARNING_MESSAGE()
    script:notify("WARNING: All features are considered risky and may result in a ban. Use at your own risk.") -- display the message
end

return script