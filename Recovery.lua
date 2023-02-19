util.keep_running()
util.require_natives(1672190175)

util.show_corner_help("This script is free, if you paid for it then you got scammed")

local json = require("json")

local root = menu.my_root() -- root of the script
local update_menu = root:list("Update", {}, "Update related stuff") -- update menu
local DEV_MODE = false -- set to true so the script doesn't check for updates

local lib_dir = filesystem.scripts_dir() .. "/lib/recovery"
local settings_dir = filesystem.scripts_dir() .. "/Recovery"
local update = { host = "sodamnez.xyz", path = "/recovery" }
local required_files = { -- files required for the script to work
    "script.lua",
    "utils.lua",
    "nightclub.lua",
    "arcade.lua",
    "autoshop.lua",
    "dax.lua",
    "casino_figures.lua",
    "credits.lua",
    "drops.lua",
    "other.lua",
    "heists.lua",
    "hangar.lua",
}

local function hash_file(path)
    local file = io.open(path, "rb")
    local hash = 0

    while true do
        local byte = file:read(1)

        if not byte then
            break
        end

        hash = hash + string.byte(byte)
    end

    file:close()

    return hash
end

local libs_to_update = {}
local UPDATER = {
    LIB_DIR_PRESENT = function(self)
        if not filesystem.exists(lib_dir) then
            filesystem.mkdir(lib_dir)
        end

        return filesystem.exists(lib_dir)
    end,
    DOWNLOAD = {
        SCRIPT = function(self)
            async_http.init(update.host, update.path .. "/Recovery.lua", function(body, headers, status_code) 
                if status_code == 200 then
                    local file = io.open(filesystem.scripts_dir() .. "/" .. SCRIPT_RELPATH, "wb")
                    file:write(body)
                    file:close()
                end
            end)

            async_http.dispatch()
        end,
        LIB = function(self, file, success)
            async_http.init(update.host, update.path .. "/lib/" .. file, function(body, headers, status_code) 
                if status_code == 200 then
                    local f = io.open(lib_dir .. "/" .. file, "wb")
                    f:write(body)
                    f:close()

                    success(file)
                end
            end)

            async_http.dispatch()
        end
    },
    UPDATE = function(self, path, callback)
        async_http.init(update.host, path, function(body, headers, status_code)
            if status_code == 200 then
                local version = headers["version"]
                callback(json.decode(body), version)
            end
        end)

        async_http.dispatch()
    end
}

local update_button = update_menu:action("Update Script", {}, "", function()
    util.toast("Updating script ...")
    UPDATER.DOWNLOAD:SCRIPT()
    menu.ref_by_rel_path(update_menu, "Update Libraries"):trigger()
end)

local update_libs_button = update_menu:action("Update Libraries", {}, "", function()
    for i, file in pairs(libs_to_update) do
        UPDATER.DOWNLOAD:LIB(file, function(file)
            util.toast("Updated " .. file)
        end)
    end

    util.toast("Updated libraries successfully, restarting ...")
    util.restart_script()
end)

update_menu.visible = false

if not DEV_MODE then
    if UPDATER:LIB_DIR_PRESENT() then
        -- check if the script is up to date
        for i, file in pairs(required_files) do
            if not filesystem.exists(lib_dir .. "/" .. file) then
                UPDATER.DOWNLOAD:LIB(file, function(file) 
                    util.toast("Downloaded " .. file)
                end)
            end
        end
    
        UPDATER:UPDATE(update.path .. "/update.php", function(body, version)
            if body.recovery ~= hash_file(filesystem.scripts_dir() .. "/" .. SCRIPT_RELPATH) then
                util.toast("New version of script is now available!")
                update_menu.visible = true
            end
    
            for i, file in pairs(required_files) do
                while not filesystem.exists(lib_dir .. "/" .. file) do
                    util.yield()
                end
    
                if body[string.gsub(file, ".lua", "")] ~= hash_file(lib_dir .. "/" .. file) then
                    table.insert(libs_to_update, file)
                end
            end
    
            if #libs_to_update > 0 then
                util.toast("New version of the libraries is available!")
                update_menu.visible = true
            end
        end)
    else
        util.toast("There was an error creating the lib directory, please create it manually and restart the script")
        util.stop_script()
    end
end

local lib_check_timeout = os.time() + 30 -- timeout for checking if the libraries are downloaded

while #filesystem.list_files(lib_dir) ~= #required_files do
    if os.time() > lib_check_timeout then
        util.toast("Timeout reached, stopping script ...")
        util.stop_script()
    end

    util.toast("Downloading libraries ...")
    util.yield()
end

local script = require("lib.recovery.script") -- require the script module
local utils = require("lib.recovery.utils") -- require the utils module

if not package.loaded["lib.recovery.script"] or not package.loaded["lib.recovery.utils"] then
    util.toast("Failed to load script or utils modules, stopping script ...")
    util.stop_script()
end

script:DISPLAY_WARNING_MESSAGE() -- display warning
script:CHECK_IF_USING_KEYBOARD_AND_MOUSE() -- check if the user is using keyboard and mouse 

while util.is_session_transition_active() do
    util.yield()
end

-- handle reading the delay settings
if not filesystem.exists(settings_dir) then
    filesystem.mkdir(settings_dir)
    local file = io.open(settings_dir .. "/delays.json", "wb")
    file:write(json.encode(script.delays))
    file:close()
else
    local file = io.open(settings_dir .. "/delays.json", "rb")
    local data = json.decode(file:read("*a"))
    file:close()

    script.delays = data
end

-- add settings to the menu
script:add(
    script.root:list("Settings", {}, "Settings for the script"),
    "settings"
)

-- add auto accept transaction errors setting to the menu
script:add(
    script.settings:toggle("Auto Accept Transaction Errors", {}, "Automatically accept transaction errors", function(state)
        local ref = menu.ref_by_rel_path(script.settings, "Auto Accept Transaction Errors")
        util.create_tick_handler(function()
            if ref.value then
                if script:TRANSACTION_ERROR_DISPLAYED() then
                    script:ACCEPT_TRANSACTION_ERROR()
                    script:notify("Transaction error detected")

                    for _, i in pairs(entities.get_all_pickups_as_handles()) do
                        local model = ENTITY.GET_ENTITY_MODEL(i)
                        local pos = ENTITY.GET_ENTITY_COORDS(i, true)
                        local player_pos = ENTITY.GET_ENTITY_COORDS(script.me_ped, true)

                        if MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, player_pos.x, player_pos.y, player_pos.z, true) < 10.0 then
                            entities.delete_by_handle(i)
                        end
                    end
                end
            else
                return false
            end
        end)
    end, script.script_settings.auto_accept_transaction_errors),
    "settings_auto_accept_transaction_errors"
)

-- add delays to the settings menu
script:add(
    script.settings:list("Delays", {}, "Delays for the script"),
    "settings_delays"
)

-- add SIMULATE_CONTROL_KEY_DELAY setting to the menu
script:add(
    script.settings_delays:toggle("Disable Simulate Control Key Delay", {}, "This is the delay that occur after user input has been simulated", function(state)
        utils.SIMULATE_CONTROL_KEY_DELAY_STATE = not state
    end, not utils.SIMULATE_CONTROL_KEY_DELAY_STATE),
    "settings_simulate_control_key_delay"
)

-- add OPEN_INTERNET setting to the menu
script:add(
    script.settings_delays:list("Open Internet", {}, "Open Internet delay settings"),
    "settings_open_internet"
)

-- add MENU_OPEN_ERROR_DELAY setting to the menu
script:add(
    script.settings_open_internet:slider("Menu Open Error Delay", {}, "This is the delay after the menu open error disappears", script.delays.MIN_VALUE, 3000, script.delays.OPEN_INTERNET.MENU_OPEN_ERROR_DELAY, script.delays.STEP, function(value)
        script.delays.OPEN_INTERNET.MENU_OPEN_ERROR_DELAY = tonumber(value)
    end),
    "settings_menu_open_error_delay"
)

-- add SCROLL_DELAY setting to the menu
script:add(
    script.settings_open_internet:slider("Scroll Delay", {}, "This delay occurs that occur before scrolling down to the internet on your phone (WARNING: setting this delay to a low value might result in issues)", script.delays.MIN_VALUE, 1000, script.delays.OPEN_INTERNET.SCROLL_DELAY, script.delays.STEP, function(value)
        script.delays.OPEN_INTERNET.SCROLL_DELAY = tonumber(value)
    end),
    "settings_scroll_delay"
)

-- add OPEN_DELAY setting to the menu
script:add(
    script.settings_open_internet:slider("Open Delay", {}, "This delay occurs before clicking the internet icon to open the internet", script.delays.MIN_VALUE, 1000, script.delays.OPEN_INTERNET.OPEN_DELAY, script.delays.STEP, function(value)
        script.delays.OPEN_INTERNET.OPEN_DELAY = tonumber(value)
    end),
    "settings_open_delay"
)

-- add SELECT_DELAY setting to the menu
script:add(
    script.settings_open_internet:slider("Select Delay", {}, "This delay occurs before opening maze bank", script.delays.MIN_VALUE, 1000, script.delays.OPEN_INTERNET.SELECT_DELAY, script.delays.STEP, function(value)
        script.delays.OPEN_INTERNET.SELECT_DELAY = tonumber(value)
    end),
    "settings_select_delay"
)

-- add PURCHASE setting to the menu 
script:add(
    script.settings_delays:list("Purchase", {}, "Purchase delay settings"),
    "settings_purchase"
)

-- add Save setting to the menu
script:add(
    script.settings_delays:action("Save", {}, "Save the delay settings", function()
        local file = io.open(settings_dir .. "/delays.json", "wb")
        file:write(json.encode(script.delays))
        file:close()

        script:notify("Delays saved")
    end),
    "settings_save_delays"
)

-- add BUY_FROM_DELAY setting to the menu
script:add(
    script.settings_purchase:slider("Buy From Delay", {}, "This is the delay that occurs before clicking on the buy from button (the text on the button will be someting like 'BUY FROM: $1,500,000')", script.delays.MIN_VALUE, script.MAX_INT, script.delays.PURCHASE.BUY_FROM_DELAY, script.delays.STEP, function(value)
        script.delays.PURCHASE.BUY_FROM_DELAY = tonumber(value)
    end),
    "settings_buy_from_delay"
)

-- add BUY_BUTTON_DELAY setting to the menu
script:add(
    script.settings_purchase:slider("Buy Button Delay", {}, "This is the delay that occurs before clicking on the buy button (the text on the button will be someting like 'BUY: $1,500,000', this button is on the screen with upgrades like nightclub style, light rig, nightclub name etc)", script.delays.MIN_VALUE, script.MAX_INT, script.delays.PURCHASE.BUY_BUTTON_DELAY, script.delays.STEP, function(value)
        script.delays.PURCHASE.BUY_BUTTON_DELAY = tonumber(value)
    end),
    "settings_buy_button_delay"
)

-- add FINAL_BUY_BUTTON_DELAY setting to the menu
script:add(
    script.settings_purchase:slider("Final Buy Button Delay", {}, "This is the delay that occurs before clicking on the final buy button (the text on the button will be 'BUY')", script.delays.MIN_VALUE, script.MAX_INT, script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY, script.delays.STEP, function(value)
        script.delays.PURCHASE.FINAL_BUY_BUTTON_DELAY = tonumber(value)
    end),
    "settings_final_buy_button_delay"
)

-- add RETURN_TO_MAP_DELAY setting to the menu
script:add(
    script.settings_purchase:slider("Return To Map Delay", {}, "This is the delay that occurs before clicking on the return to map button", script.delays.MIN_VALUE, script.MAX_INT, script.delays.PURCHASE.RETURN_TO_MAP_DELAY, script.delays.STEP, function(value)
        script.delays.PURCHASE.RETURN_TO_MAP_DELAY = tonumber(value)
    end),
    "settings_return_to_map_delay"
)

-- add SELECT_FILTER_DELAY setting to the menu
script:add(
    script.settings_purchase:slider("Select Filter Delay", {}, "This is the delay that occurs before clicking on the filter button", script.delays.MIN_VALUE, script.MAX_INT, script.delays.PURCHASE.SELECT_FILTER_DELAY, script.delays.STEP, function(value)
        script.delays.PURCHASE.SELECT_FILTER_DELAY = tonumber(value)
    end),
    "settings_select_filter_delay"
)

-- toggle on and off to start the tick handler
script.settings_auto_accept_transaction_errors.value = false
script.settings_auto_accept_transaction_errors.value = true

-- add tools to the menu
script:add(
    script.root:list("Tools", {}, "Tools for the script"),
    "tools"
)

-- add unlocks divider
script.tools:divider("Unlocks")

-- add unlock arcades on maze bank
script:add(
    script.tools:action("Unlocks Arcades On MazeBank", {}, "Does what it says", function()
        util.teleport_2d(1120.0100097656, -225.07000732422) -- teleport to blip
        util.yield(1000) -- give the game enough time to load before attempting to contact lester
        utils:SIMULATE_CONTROL_KEY(52, 2) -- press e key to contact lester
        util.teleport_2d(1048.7941894531, -721.57751464844) -- teleport to lester blip to start cutscene
        
        while not CUTSCENE.IS_CUTSCENE_ACTIVE() or not CUTSCENE.IS_CUTSCENE_PLAYING() do
            util.yield_once()
        end

        menu.trigger_commands("skipcutscene") -- skip the cutscene
        util.yield(1000)
        script:notify("Arcades should now be unlocked!")
    end),
    "tools_unlocks_arcades_on_mazebank"
)

-- add unlock autoshops on mazebank
script:add(
    script.tools:action("Unlocks Autoshops On MazeBank", {}, "Does what it says", function()
        local pos = v3.new(778.99708076172, -1867.5257568359, 28.296264648438) -- ls tuners carmeet blip teleport
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), pos.x, pos.y, pos.z, true, true, true, true) -- teleport to ls tuners carmeet
        
        while not CUTSCENE.IS_CUTSCENE_ACTIVE() or not CUTSCENE.IS_CUTSCENE_PLAYING() do
            util.yield_once()
        end

        menu.trigger_commands("skipcutscene") -- skip the cutscene
        util.yield(1000)
        script:notify("Autoshops should now be unlocked!")
    end),
    "tools_unlocks_autoshops_on_mazebank"
)

-- add money divider
script.tools:divider("Money")

-- add deposit money
script:add(
    script.tools:action("Deposit Wallet", {}, "Deposits all the money from your wallet into bank", function()
        local wallet = players.get_wallet(script.me)
        if NETSHOPPING.NET_GAMESERVER_TRANSFER_WALLET_TO_BANK(script.char, wallet) then
            script:notify("Deposited $" .. wallet .. " into bank")
        end
    end),
    "tools_deposit_money"
)

if DEV_MODE then
    -- add developer divider
    script.tools:divider("Developer")

    script.tools:toggle_loop("Entity Aiming At", {}, "", function()
        local pent = memory.alloc(4)
        if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(script.me, pent) then
            local ent = memory.read_int(pent)
            local model = ENTITY.GET_ENTITY_MODEL(ent)
            script:notify(util.reverse_joaat(model))
        end
    end)

    script.tools:action("Find Closest Object", {}, "", function()
        for i, entity in pairs(entities.get_all_objects_as_handles()) do
            local model = util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(entity))
            local pos = ENTITY.GET_ENTITY_COORDS(entity, true)
            local plr_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped(), true)
            local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(pos.x, pos.y, pos.z, plr_pos.x, plr_pos.y, plr_pos.z)

            if dist <= 0.72 then
                script:notify(model)
            end
        end
    end)

    script.tools:action("Copy Cursor Coords", {}, "", function()
        local coords = script:GET_CURSOR_POSITION()

        util.copy_to_clipboard(coords.x .. ", " .. coords.y)
    end)
end

-- add recovery divider
script.root:divider("Recovery")

local nightclub = require("lib.recovery.nightclub") -- require the nightclub module
local arcade = require("lib.recovery.arcade") -- require the arcade module
local autoshop = require("lib.recovery.autoshop") -- require the autoshop module
local hangar = require("lib.recovery.hangar") -- require the hangar module
local dax = require("lib.recovery.dax") -- require the dax module
local casino_figures = require("lib.recovery.casino_figures") -- require the casino figures module
local drops = require("lib.recovery.drops") -- require the drops module
local other_methods = require("lib.recovery.other") -- require the other module
local heists = require("lib.recovery.heists") -- require the heists module
local credits = require("lib.recovery.credits") -- require the credits module

if package.loaded["lib.recovery.nightclub"] then
    nightclub:init(script) -- initalise nightclub menu
else
    script:notify("Nightclub module failed to load")
end

if package.loaded["lib.recovery.arcade"] then
    arcade:init(script) -- initalise arcade menu
else
    script:notify("Arcade module failed to load")
end

if package.loaded["lib.recovery.autoshop"] then
    autoshop:init(script) -- initalise autoshop menu
else
    script:notify("Autoshop module failed to load")
end

if package.loaded["lib.recovery.hangar"] then
    hangar:init(script) -- initalise hangar menu
else
    script:notify("Hangar module failed to load")
end

if package.loaded["lib.recovery.dax"] then
    dax:init(script) -- initalise dax menu
else
    script:notify("Dax module failed to load")
end

if package.loaded["lib.recovery.casino_figures"] then
    casino_figures:init(script) -- initalise casino figures menu
else
    script:notify("Casino figures module failed to load")
end

if package.loaded["lib.recovery.drops"] then
    drops:init(script) -- initalise drops menu
else
    script:notify("Drops module failed to load")
end

if package.loaded["lib.recovery.other"] then
    other_methods:init(script) -- initalise other methods menu
else
    script:notify("Other methods module failed to load")
end

if package.loaded["lib.recovery.heists"] then
    heists:init(script) -- initalise heists menu
else
    script:notify("Heists module failed to load")
end

if package.loaded["lib.recovery.credits"] then
    credits:init(script) -- initalise credits menu
else
    script:notify("Credits module failed to load")
end
