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
    OPEN_INTERNET = function(self, script, hyperlink_delay=300, override=false)
        local should_continue = (
            script.nightclub_presets_afk_loop.value 
            or 
            script.arcade_presets_afk_loop.value
            or
            script.autoshop_presets_afk_loop.value
        )

        if override then should_continue = true end
        
        if should_continue then
            --MOBILE.SET_MOBILE_PHONE_SCALE(0.0) -- hide phone because it's funny
            self:MENU_OPEN_ERROR() -- display an error message until the menu is closed
            util.yield(script.delays.OPEN_INTERNET.MENU_OPEN_ERROR_DELAY) -- wait for x amount of time before continuing

            self:SIMULATE_CONTROL_KEY(
                27, 
                1, 
                0, 
                script.delays.OPEN_INTERNET.SCROLL_DELAY
            ) -- open phone
            
            self:SIMULATE_CONTROL_KEY(
                173, 
                1, 
                0, 
                script.delays.OPEN_INTERNET.OPEN_DELAY
            ) -- scroll down to internet
            
            self:SIMULATE_CONTROL_KEY(
                176, 
                1, 
                0, 
                script.delays.OPEN_INTERNET.SELECT_DELAY
            ) -- press enter to open internet
            
            self:MOVE_CURSOR(0.25, 0.70, hyperlink_delay, true) -- move to mazebank hyperlink
            self:MOVE_CURSOR(0.5, 0.83, hyperlink_delay, true) -- press enter on maze bank button
        else
            script:CLOSE_BROWSER()
        end
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