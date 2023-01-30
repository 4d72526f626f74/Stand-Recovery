local utils = {
    script = nil,
    SET_SCRIPT = function(self, script)
        self.script = script
    end,
    SIMULATE_CONTROL_KEY = function(self, key, times, control=0, delay=300)
        for i = 1, times do
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(control, key, 1) -- press the key
            util.yield(delay) -- wait before attempting to press the key again
        end
    
        util.yield(100) 
    end,
    MOVE_CURSOR = function(self, x, y, delay=300, autoclick=false, autoclick_delay=150)
        local fps = self:GET_FPS()
        
        -- change the delay based on the fps to account for fps related issues
        if fps <= 20 then
            delay = delay * 4
            autoclick_delay = autoclick_delay * 4
        end

        if fps <= 40 and fps > 20 then
            delay = delay * 2
            autoclick_delay = autoclick_delay * 2
        end

        if fps <= 60 and fps > 40 then
            delay = delay * 2
            autoclick_delay = autoclick_delay * 2
        end

        if fps <= 80 and fps > 60 then
            delay = delay * 1.5
            autoclick_delay = autoclick_delay * 1.5
        end

        PAD.SET_CURSOR_POSITION(x, y) -- move the cursor
        util.yield(delay) -- wait before attempting to autoclick if enabled

        if autoclick then
            util.yield(autoclick_delay) -- delay before clicking
            self:PRESS_ENTER() -- press enter
        end
    end,
    PRESS_ENTER = function(self, control=0)
        if control == 0 then
            self:SIMULATE_CONTROL_KEY(201, 1, control) -- press enter using PLAYER_CONTROL mode
        end

        if control == 2 then
            self:SIMULATE_CONTROL_KEY(176, 1, control) -- press enter using FRONTEND_CONTROL mode
        end
    end,
    CLOSE_BROWSER = function(self)
        while self.script:IS_SCREEN_OPEN() do
            PED.SET_PED_TO_RAGDOLL(players.user_ped(), 1, 1, 2, 0, 0, 0) -- ragdoll the player
            util.yield(100) -- 100ms delay before next iteration
        end
    end,
    OPEN_INTERNET = function(self, script, hyperlink_delay=300)
        if script.states.block_purchase then
            return -- block this function from running
        end

        self:MENU_OPEN_ERROR() -- display an error message until the menu is closed
        util.yield(1000) -- wait 1 second after menu is closed to increase consistency

        local xptr, yptr = memory.alloc(4), memory.alloc(4) -- allocate memory for resolution
        GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(xptr, yptr) -- get the resolution
        local x, y = tonumber(memory.read_int(xptr)), tonumber(memory.read_int(yptr)) -- read the resolution

        self:SIMULATE_CONTROL_KEY(27, 1, 0, 700) -- open phone
        self:SIMULATE_CONTROL_KEY(173, 1, 0, 700) -- scroll down to internet
        self:SIMULATE_CONTROL_KEY(176, 1, 0, 700) -- press enter to open internet
        self:MOVE_CURSOR(0.25, 0.70, hyperlink_delay, true) -- move to mazebank hyperlink
        self:MOVE_CURSOR(0.5, 0.83, hyperlink_delay, true) -- press enter on maze bank button
    end,
    MENU_OPEN_ERROR = function(self)
        while menu.is_open() do
            util.toast("Please close Stand menu to continue")
            util.yield()
        end
    end,
    GET_FPS = function(self)
        local frame_time = MISC.GET_FRAME_TIME()
        return math.floor(1 / frame_time)
    end
}

return utils