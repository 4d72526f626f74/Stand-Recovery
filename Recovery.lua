util.keep_running()
util.require_natives(1672190175)

local json = require("json")

local root = menu.my_root() -- root of the script
local lib_dir = filesystem.scripts_dir() .. "/lib/recovery"
local update = { host = "sodamnez.xyz", path = "/recovery" }
local required_files = { -- files required for the script to work
    "script.lua",
    "utils.lua",
    "nightclub.lua",
    "arcade.lua",
    "autoshop.lua",
    "dax.lua",
    "casino_figures.lua",
    "credits.lua"
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

local update_button = root:action("Update", {}, "", function()
    UPDATER.DOWNLOAD:SCRIPT()
    util.toast("Script updated, restarting ...")
    util.restart_script()
end)

local update_libs_button = root:action("Update Libs", {}, "", function()
    for i, file in pairs(libs_to_update) do
        UPDATER.DOWNLOAD:LIB(file, function(file)
            util.toast("Updated " .. file)
        end)
    end

    util.toast("Libs updated, restarting ...")
    util.restart_script()
end)

update_button.visible = false
update_libs_button.visible = false

if UPDATER:LIB_DIR_PRESENT() then
    -- check if the script is up to date
    for i, file in pairs(required_files) do
        if not filesystem.exists(lib_dir .. "/" .. file) then
            UPDATER.DOWNLOAD:LIB(file, function(file) end)
        end
    end

    UPDATER:UPDATE(update.path .. "/update.php", function(body, version)
        if body.recovery ~= hash_file(filesystem.scripts_dir() .. "/" .. SCRIPT_RELPATH) then
            util.toast("New version of the script is available!")
            update_button.visible = true
            menu.set_menu_name(update_button, "Update To v" .. version)
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
            util.toast("New version of the libs is available!")
            update_libs_button.visible = true
        end
    end)
else
    util.toast("There was an error creating the lib directory, please create it manually and restart the script")
    util.stop_script()
end

while #filesystem.list_files(lib_dir) ~= #required_files do
    util.yield()
end

local script = require("lib.recovery.script") -- require the script module
local utils = require("lib.recovery.utils") -- require the utils module

script:DISPLAY_WARNING_MESSAGE() -- display warning 

while script:GET_TRANSITION_STATE() ~= 66 do
    util.yield()
end

-- add settings to the menu
script:add(
    script.root:list("Settings", {}, "Settings for the script"),
    "settings"
)

-- add ownership check setting to the menu
script:add(
    script.settings:toggle("Ownership Check", {}, "Enable/Disable ownership checking for properties (disabing this can cause problems)", function(state)
        script.script_settings.ownership_check = state
    end, script.script_settings.ownership_check),
    "settings_ownership_check"
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
        ENTITY.SET_ENTITY_COORDS(script.me_ped, 1120.0100097656, -225.07000732422, 69.084953308105, true, true, true, true) -- teleports you to a blip on the map
        utils:SIMULATE_CONTROL_KEY(52, 2) -- press e key to contact lester
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), 1048.7941894531, -721.57751464844, 57.227325439453, true, true, true, true)
        util.yield(1500) -- give the cutsene time to start before attempting to skip it
        menu.trigger_commands("skipcutscene")
    end),
    "tools_unlocks_arcades_on_mazebank"
)

-- add unlock autoshops on mazebank
script:add(
    script.tools:action("Unlocks Autoshops On MazeBank", {}, "Does what it says", function()
        local pos = v3.new(778.99708076172, -1867.5257568359, 28.296264648438) -- ls tuners carmeet blip teleport
        ENTITY.SET_ENTITY_COORDS(players.user_ped(), pos.x, pos.y, pos.z, true, true, true, true) -- teleport to ls tuners carmeet
        util.yield(4000) -- give the cutsene time to start before attempting to skip it
        menu.trigger_commands("skipcutscene") -- skip the cutscene
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

-- add amount to remove
script:add(
    script.tools:text_input("Money Remover", {"rsremovemoney"}, "Removes money from your account", function() end, "0"),
    "tools_money_remover"
)

-- add button to remove money
script:add(
    script.tools:action("Remove Money", {"rsremovemoney"}, "Removes money from your account", function()
        local amount = tonumber(script.tools_money_remover.value)
    
        if amount == nil then
            script:NOTIFY("Invalid money amount")
            return
        end
    
        if amount < 0 then
            script:NOTIFY("Money amount must be greater than 0")
            return
        end
    
        script:BUY_BST(amount)
        util.yield(200)
        PED.SET_PED_TO_RAGDOLL(script.me_ped, 1, 1, 0, 0, 0, 0) -- ensures player picks up bst
        util.yield(100)
        menu.trigger_commands("bst off")
    end),
    "tools_remove_money_button"
)

-- add remove maximum money
script.tools:action("Remove Max Money", {"rsremovemaxmoney"}, "Removes max money from your account", function()
    script:BUY_BST(script.MAX_INT)
    util.yield(200)
    PED.SET_PED_TO_RAGDOLL(script.me_ped, 1, 1, 0, 0, 0, 0) -- ensures player picks up bst
    util.yield(100)
    menu.trigger_commands("bst off")
end)

-- add recovery divider
script.root:divider("Recovery")

local nightclub = require("lib.recovery.nightclub") -- require the nightclub module
local arcade = require("lib.recovery.arcade") -- require the arcade module
local autoshop = require("lib.recovery.autoshop") -- require the autoshop module
local dax = require("lib.recovery.dax") -- require the dax module
local casino_figures = require("lib.recovery.casino_figures") -- require the casino figures module
local credits = require("lib.recovery.credits") -- require the credits module

nightclub:init(script) -- initalise nightclub menu
arcade:init(script) -- initalise arcade menu
autoshop:init(script) -- initalise autoshop menu
dax:init(script) -- initalise dax menu
casino_figures:init(script) -- initalise casino figures menu
credits:init(script) -- initalise credits menu

utils:SET_SCRIPT(script) -- set the script for the utils module