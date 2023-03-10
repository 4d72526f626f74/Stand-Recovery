util.keep_running()
util.require_natives(1676318796)

util.show_corner_help("This ~r~SCRIPT~w~ is ~r~FREE~w~, if you paid for it then you got ~r~SCAMMED~w~")

local json = require("json")

local root = menu.my_root() -- root of the script
local update_menu = root:list("Update", {"rsupdatemenu"}, "") -- update menu
update_menu.visible = false -- hide the update menu

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
    "taxi_service.lua",
    "acid_lab.lua",
    "collectables.lua",
}

local function check_for_updates(on_complete)
    function hash_file(path)
        local file = io.open(path, "rb")
        local hash = 0

        if not file then
            return hash
        end
    
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

    function hash_raw(raw)
        local hash = 0

        for i = 1, #raw do
            hash = hash + string.byte(raw, i)
        end

        return hash
    end

    function download_missing()
        for i, file in pairs(required_files) do
            async_http.init("sodamnez.xyz", "/recovery/lib/" .. file, function(body, headers, status_code)
                if status_code == 200 then
                    local file <close> = assert(io.open(lib_dir .. "/" .. file, "wb"))
                    file:write(body)
                    file:close()
                end
            end)

            async_http.dispatch()
        end

        repeat
            util.draw_debug_text("Download progress: " .. math.floor(#filesystem.list_files(lib_dir) / #required_files * 100) .. "%")
            util.yield_once()
        until #filesystem.list_files(lib_dir) == #required_files

        util.toast("Success, restarting script...")
        util.restart_script()
    end
    
    async_http.init("sodamnez.xyz", "/recovery/update.php", function(body, headers, status_code)
        if status_code == 200 then
            remote_hashes = json.decode(body)
        end
    end)
    
    async_http.dispatch()
    
    repeat
        util.yield_once()
    until remote_hashes

    update_menu:action("Update Script", {"rsupdate"}, "Update the script", function()
        local downloads = 0

        for i, file in pairs(required_files) do
            local name = file:gsub(".lua", "")
            local remote_hash = remote_hashes[name]

            async_http.init("sodamnez.xyz", "/recovery/lib/" .. file, function(body, headers, status_code)
                if status_code == 200 then
                    local local_hash = hash_raw(body)
                    local path = lib_dir .. "/" .. file

                    if local_hash == remote_hash then
                        local file <close> = assert(io.open(path, "wb"))
                        file:write(body)
                        file:close()

                        downloads = downloads + 1
                    end
                end
            end)

            async_http.dispatch()
        end

        local main = remote_hashes.recovery
        local local_hash = hash_file(filesystem.scripts_dir() .. "/Recovery.lua")

        if local_hash ~= main then
            async_http.init("sodamnez.xyz", "/recovery/Recovery.lua", function(body, headers, status_code)
                if status_code == 200 then
                    local file <close> = assert(io.open(filesystem.scripts_dir() .. "/Recovery.lua", "wb"))
                    file:write(body)
                    file:close()

                    downloads = downloads + 1
                end
            end)

            async_http.dispatch()
        end

        repeat
            util.draw_debug_text("Update progress: " .. math.floor(downloads / #required_files * 100) .. "%")
            util.yield_once()
        until downloads == #required_files

        util.toast("Update was successful, restarting script...")
        util.restart_script()
    end)

    local update = {
        available = false,
        skip = false
    }

    if filesystem.exists(lib_dir) then
        if #filesystem.list_files(lib_dir) < #required_files then
            update.skip = true
        end

        if not update.skip then
            for i, file in pairs(required_files) do
                local name = file:gsub(".lua", "")
                local remote_hash = remote_hashes[name]
                local local_hash = hash_file(lib_dir .. "/" .. file)
        
                if local_hash ~= remote_hash then
                    update.available = true
                end
            end
        
            local main = remote_hashes.recovery
            local local_hash = hash_file(filesystem.scripts_dir() .. "/Recovery.lua")
        
            if local_hash ~= main then
                update.available = true
            end
        else
            download_missing()
        end
    else
        update.available = false
        filesystem.mkdir(lib_dir)

        download_missing()
    end

    if update.available and not update.skip then
        update_menu.visible = true
        util.toast("New update available!")
    end
end

local script = require("lib.recovery.script") -- require the script module
local utils = require("lib.recovery.utils") -- require the utils module
script.shadow_root = menu.shadow_root() -- get the shadow root

if not package.loaded["lib.recovery.script"] or not package.loaded["lib.recovery.utils"] then
    util.toast("Failed to load script or utils modules, stopping script ...")
    util.stop_script()
end

if not script.developer_mode then
    check_for_updates()
else
    util.toast("Developer mode is enabled, skipping update check")
end

script:DISPLAY_WARNING_MESSAGE() -- display warning
script:CHECK_IF_USING_KEYBOARD_AND_MOUSE() -- check if the user is using keyboard and mouse 

while util.is_session_transition_active() do
    util.yield()
end

script.proot = menu.player_root(script.me)
script.resolution = script:GET_RESOLUTION() -- get screen resolution

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
    script.root:list("Settings", {"rssettings"}, "Settings for the script"),
    "settings"
)

-- add auto accept transaction errors setting to the menu
script:add(
    script.settings:toggle("Auto Accept Transaction Errors", {"rsaccepterror"}, "Automatically accept transaction errors", function(state)
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

-- add enable 1B Recovery setting to the menu
script:add(
    script.settings:toggle("Enable 1B Recovery", {"rsenable1brecovery"}, "Enables 1B Recovery", function(state)
        if not script.developer_mode then
            if state and SCRIPT_CAN_CONTINUE then
                script:msg("This feature is currently detected, it is recommended not to use it in a blatant way as it could get you banned (smaller amounts could get you banned too). Use at your own risk.")
            end

            script.nightclub_presets.visible = state
            script.nightclub_custom.visible = state
            script.arcade_presets.visible = state
            script.arcade_custom.visible = state
            script.autoshop_presets.visible = state
            script.autoshop_custom.visible = state
            script.hangar_presets.visible = state
            script.hangar_custom.visible = state

            if state then
                local d1 = script.shadow_root:divider("1B Recovery")
                local d2 = script.shadow_root:divider("1B Recovery")
                local d3 = script.shadow_root:divider("1B Recovery")
                local d4 = script.shadow_root:divider("1B Recovery")
                local ref = nil

                ref = menu.ref_by_rel_path(script.nightclub_recovery, "Presets")
                if ref:isValid() then menu.attach_before(ref, d1) end
                ref = menu.ref_by_rel_path(script.arcade_recovery, "Presets")
                if ref:isValid() then menu.attach_before(ref, d2) end
                ref = menu.ref_by_rel_path(script.autoshop_recovery, "Presets")
                if ref:isValid() then menu.attach_before(ref, d3) end
                ref = menu.ref_by_rel_path(script.hangar_recovery, "Presets")
                if ref:isValid() then menu.attach_before(ref, d4) end
            else
                local ref = nil
                ref = script.nightclub_recovery:getChildren()[1]
                if ref.menu_name == "1B Recovery" then ref:delete() end
                ref = script.arcade_recovery:getChildren()[1]
                if ref.menu_name == "1B Recovery" then ref:delete() end
                ref = script.autoshop_recovery:getChildren()[1]
                if ref.menu_name == "1B Recovery" then ref:delete() end
                ref = script.hangar_recovery:getChildren()[1]
                if ref.menu_name == "1B Recovery" then ref:delete() end
            end
        end
    end, false),
    "settings_enable_1b_recovery"
)

-- add delays to the settings menu
script:add(
    script.settings:list("Delays", {"rsdelays"}, "Delays for the script"),
    "settings_delays"
)

-- add SIMULATE_CONTROL_KEY_DELAY setting to the menu
script:add(
    script.settings_delays:toggle("Disable Simulate Control Key Delay", {"rsdisablecontrolkeydelay"}, "This is the delay that occur after user input has been simulated", function(state)
        utils.SIMULATE_CONTROL_KEY_DELAY_STATE = not state
    end, not utils.SIMULATE_CONTROL_KEY_DELAY_STATE),
    "settings_simulate_control_key_delay"
)

-- add PURCHASE setting to the menu 
script:add(
    script.settings_delays:list("Purchase", {"rspurchasedelays"}, "Purchase delay settings"),
    "settings_purchase"
)

-- add Save setting to the menu
script:add(
    script.settings_delays:action("Save", {"rssavedelays"}, "Save the delay settings", function()
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
    script.root:list("Tools", {"rstools"}, "Tools for the script"),
    "tools"
)

-- add unlocks divider
script.tools:divider("Unlocks")

-- add unlock arcades on maze bank
script:add(
    script.tools:action("Unlock Arcades On MazeBank", {"rsarcadeunlock"}, "Does what it says", function()
        local bitfield = memory.read_int(script.globals.arcade_bitfield)
        local mask = 0x14E -- 000101001110 (334)
        local timeout = os.time() + 5

        memory.write_int(script.globals.arcade_bitfield, bitfield | mask)
        while not CUTSCENE.IS_CUTSCENE_ACTIVE() or not CUTSCENE.IS_CUTSCENE_PLAYING() do
            if os.time() > timeout then
                util.stop_thread()
            end
            util.yield_once()
        end
        menu.trigger_commands("skipcutscene")

        script:notify("Arcades are now unlocked!")
    end),
    "tools_unlocks_arcades_on_mazebank"
)

-- add unlock autoshops on mazebank
script:add(
    script.tools:action("Unlock Autoshops On MazeBank", {"rsautoshopunlock"}, "Does what it says", function()
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
    script.tools:action("Deposit Wallet", {"rsdepositall"}, "Deposits all the money from your wallet into bank", function()
        local wallet = players.get_wallet(script.me)
        if NETSHOPPING.NET_GAMESERVER_TRANSFER_WALLET_TO_BANK(script.char, wallet) then
            script:notify("Deposited $" .. wallet .. " into bank")
        end
    end),
    "tools_deposit_money"
)

if script.developer_mode then
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

    script.tools:toggle_loop("Show Interior ID", {}, "", function()
        local interior = INTERIOR.GET_INTERIOR_FROM_ENTITY(script.me_ped)
        local hash = memory.alloc_int()
        local coords = v3.new()
        INTERIOR.GET_INTERIOR_LOCATION_AND_NAMEHASH(interior, coords, hash)
        util.draw_debug_text("Interior ID: " .. interior)
        util.draw_debug_text("Interior Hash: " .. memory.read_int(hash))
    end)
    
    script.tools:toggle_loop("Vehicle Decors", {}, "", function()
        local veh = PED.GET_VEHICLE_PED_IS_IN(script.me_ped, false)
        if veh ~= 0 then
            local not_allow = DECORATOR.DECOR_GET_INT(veh, "Not_Allow_As_Saved_Veh")
            local player_vehicle = DECORATOR.DECOR_GET_INT(veh, "Player_Vehicle")
            local previous_owner = DECORATOR.DECOR_GET_INT(veh, "Previous_Owner")
            local pv_slot = DECORATOR.DECOR_GET_INT(veh, "PV_Slot")
            local veh_modded_by_player = DECORATOR.DECOR_GET_INT(veh, "Veh_Modded_By_Player")
            local company_suv = DECORATOR.DECOR_GET_INT(veh, "Company_SUV")
            local player_sub = DECORATOR.DECOR_GET_INT(veh, "Player_Submarine")
            local moon_pool = DECORATOR.DECOR_GET_INT(veh, "Player_Moon_Pool")
            local avenger = DECORATOR.DECOR_GET_INT(veh, "Player_Avenger")
            local mpbitset = DECORATOR.DECOR_GET_INT(veh, "MPBitset")
    
            util.draw_debug_text("Not_Allow_As_Saved_Veh: " .. not_allow)
            util.draw_debug_text("Player_Vehicle: " .. player_vehicle)
            util.draw_debug_text("Previous_Owner: " .. previous_owner)
            util.draw_debug_text("PV_Slot: " .. pv_slot)
            util.draw_debug_text("Veh_Modded_By_Player: " .. veh_modded_by_player)
            util.draw_debug_text("Company_SUV: " .. company_suv)
            util.draw_debug_text("Player_Submarine: " .. player_sub)
            util.draw_debug_text("Player_Moon_Pool: " .. moon_pool)
            util.draw_debug_text("Player_Avenger: " .. avenger)
            
            for i = 0, 26 do
                util.draw_debug_text("MPBitset(" .. i .. "): " .. script:BitTest(mpbitset, i))
            end
        end
    end)

    script.tools:text_input("Bitmask", {"devbitmask"}, "", function(value)
        local bitmask = script:BitMask(value)
        if bitmask ~= 0 then
            util.copy_to_clipboard(string.format("0x%x", script:BitMask(value)))
        end
    end, "")

    script.tools:toggle_loop("Warning Hash", {}, "", function()
        local hash = HUD.GET_WARNING_SCREEN_MESSAGE_HASH()
        util.draw_debug_text("Warning Hash: " .. hash)
    end)
end

local nightclub = require("lib.recovery.nightclub") -- require the nightclub module
local arcade = require("lib.recovery.arcade") -- require the arcade module
local autoshop = require("lib.recovery.autoshop") -- require the autoshop module
local hangar = require("lib.recovery.hangar") -- require the hangar module
local dax = require("lib.recovery.dax") -- require the dax module
local casino_figures = require("lib.recovery.casino_figures") -- require the casino figures module
local drops = require("lib.recovery.drops") -- require the drops module
local other_methods = require("lib.recovery.other") -- require the other module
local heists = require("lib.recovery.heists") -- require the heists module
local taxi_service = require("lib.recovery.taxi_service") -- require the taxi service module
local acid_lab = require("lib.recovery.acid_lab") -- require the acid lab module
local credits = require("lib.recovery.credits") -- require the credits module
local collectables = require("lib.recovery.collectables") -- require the collectables module


if package.loaded["lib.recovery.credits"] then
    credits:init(script) -- initalise credits menu
else
    script:notify("Credits module failed to load")
end

-- add recovery divider
script.root:divider("Recovery")

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

if package.loaded["lib.recovery.taxi_service"] then
    taxi_service:init(script) -- initalise taxi service menu
else
    script:notify("Taxi service module failed to load")
end

if package.loaded["lib.recovery.acid_lab"] then
    acid_lab:init(script) -- initalise acid lab menu
else
    script:notify("Acid lab module failed to load")
end


-- add other divider
script.root:divider("Other")

if package.loaded["lib.recovery.collectables"] then
    collectables:init(script) -- initalise collectables menu
else
    script:notify("Collectables module failed to load")
end

if not script.developer_mode then
    script.nightclub_presets.visible = false
    script.nightclub_custom.visible = false
    script.arcade_presets.visible = false
    script.arcade_custom.visible = false
    script.autoshop_presets.visible = false
    script.autoshop_custom.visible = false
    script.hangar_presets.visible = false
    script.hangar_custom.visible = false

    local ref = nil
    ref = script.nightclub_recovery:getChildren()[1]
    if ref.menu_name == "1B Recovery" then ref:delete() end
    ref = script.arcade_recovery:getChildren()[1]
    if ref.menu_name == "1B Recovery" then ref:delete() end
    ref = script.autoshop_recovery:getChildren()[1]
    if ref.menu_name == "1B Recovery" then ref:delete() end
    ref = script.hangar_recovery:getChildren()[1]
    if ref.menu_name == "1B Recovery" then ref:delete() end
end

--[[
    -- Global_262145.f_28408 mk2 request cooldown
    -- (BitTest(Global_1586468[Local_124.f_181.f_69 /*142*/].f_103, 2)) mors mutual insurance
    -- Global_78558 = Previous_Owner check
    -- Global_2793044.f_4648 = Pegasus
    -- Global_1894573[bParam0 /*608*/].f_10.f_33;
    -- Global_32315 = ? (some sort of state maybe)
    -- Global_2793044.f_5150 = ?
    -- Global_1894573[iVar0 /*608*/] ?
    -- Global_1981293.f_10 = kosatka (bit 5)
    -- Global_1836102 = VSLI Unlock App (Fleeca Heist)
]]

--[[
    Global_262145.f_30939 = lester heist blip toggle
    Global_1970832.f_22
    bit 1 = lester
    bit 2 = ?
    bit 3 = arcade 
    bit 4 = ?
    bit 5 = ?
    bit 6 = contacted

    Global_262145.f_19128 /* Tunable: -475525840 */) something related to vehicles, line 175305 (freemode.c)
    Global_262145.f_21092 /* Tunable: -1119737689 */) something related to vehicles, line 175327 (freemode.c)e
    -- Global_4542297 -- bitfield for phone app
    -- Global_1574918 temporarily corrupts your game (character swapping)
    -- Global_8254 phone
    -- Global_2359296[func_876() /*5568*/].f_681.f_2 >= 415 func_876() = 0
    -- Global_1586468[func_1155() /*142*/].f_66 func_1155() = Global_2359296[func_876() /*5568*/].f_681.f_2
    -- Global_1586468[func_1155() /*142*/].f_103 func_1155() = Global_2359296[func_876() /*5568*/].f_681.f_2
    -- Global_2672505.f_61 = personal vehicle blip
    BitTest(Global_1577915, PLAYER::PLAYER_ID()) unknown
    Global_2793044.f_927 = request moc
    Global_2793044.f_935 = request avenger
    Global_2793044.f_940 = request acid lab
    Global_2793044.f_939 = request terrorbyte
    Global_2793044.f_925 = set when requesting personal vehicle but doesn't work when set through script
    Global_75806 = when changed before opening internet, it will open the internet to a page other than the homepage
    Global_75814 = property id
    Global_75810 = same as Local_593 and Local_592
    Global_75811 = website id
    Global_2793046.f_336 = Kosatka handle
]]