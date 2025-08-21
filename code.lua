 local ref = {
    aimbot = ui.reference('RAGE', 'Aimbot', 'Enabled'),
    doubletap = {
        main = { ui.reference('RAGE', 'Aimbot', 'Double tap') },
        fakelag_limit = ui.reference('RAGE', 'Aimbot', 'Double tap fake lag limit')
    }
}

local local_player, callback_reg, dt_charged = nil, false, false

 
local function toticks(seconds)
    return math.floor(seconds / globals.curtime() + 0.5)
end

local function check_charge()
    if not local_player or not entity.is_alive(local_player) then return end

    local m_nTickBase = entity.get_prop(local_player, 'm_nTickBase')
    local client_latency = client.latency()
    local server_tickrate = 128   
    local latency_ticks = math.max(1, math.floor(client_latency / globals.tickinterval() + 0.5))
 
    local shift = math.floor(m_nTickBase - globals.tickcount() - 3 - toticks(client_latency) * 0.5 + 0.5 * (client_latency * 10))

 
    local fakelag_limit = ui.get(ref.doubletap.fakelag_limit) or 1
    local wanted = -14 + (fakelag_limit - 1) + 3   

  
    dt_charged = shift <= wanted + 1  

    
    if shift > wanted + 3 then
        dt_charged = false
    end
end

local function rage_teleport(cmd)
    if not dt_charged then return end   

    local lp = entity.get_local_player()
    if not lp or not entity.is_alive(lp) then return end

 
    local teleport_tick = globals.curtime() + 3   

     
    cmd.tick_count = teleport_tick

   
end
 
 
 

client.set_event_callback('setup_command', function()
    local_player = entity.get_local_player()
    if not local_player or not entity.is_alive(local_player) then return end

   
    if not ui.get(ref.doubletap.main[2]) or not ui.get(ref.doubletap.main[1]) then
        ui.set(ref.aimbot, true)
        if callback_reg then
            client.unset_event_callback('run_command', check_charge)
            callback_reg = false
        end
        return
    end


     
 
      if not ui.get(ref.doubletap.main[2]) or not ui.get(ref.doubletap.main[1]) then
        ui.set(ref.aimbot, true)
        if callback_reg then
            client.unset_event_callback('run_command', rage_teleport)
            callback_reg = false
        end
        return
    end

    if not callback_reg then
        client.set_event_callback('run_command', check_charge)
        callback_reg = true
    end

    
    if not dt_charged then
        ui.set(ref.aimbot, false)
    else
        ui.set(ref.aimbot, true)
    end
end)

client.set_event_callback('shutdown', function()
    ui.set(ref.aimbot, true)
end)

 
local aimbot_ref = ui.reference("RAGE", "Aimbot", "Enabled")
local doubletap_ref = ui.reference("RAGE", "Aimbot", "Double tap")
local fakeduck_ref = ui.reference("RAGE", "Other", "Duck peek assist")

 
local was_dt_disabled_by_fakeduck = false

 
local function force_aimbot_on_fakeduck(cmd)
    local local_player = entity.get_local_player()

    if not local_player or not entity.is_alive(local_player) then
        return
    end

 
    local is_fakeduck_enabled = ui.get(fakeduck_ref)

    
    local is_ducking = bit.band(cmd.buttons, 1) ~= 0   

 
    local is_fakeducking = is_fakeduck_enabled and is_ducking

    if is_fakeducking then
    
        if ui.get(doubletap_ref) and not was_dt_disabled_by_fakeduck then
            ui.set(doubletap_ref, false)
            was_dt_disabled_by_fakeduck = true
        end

      
        ui.set(aimbot_ref, true)

    else
     

        if was_dt_disabled_by_fakeduck then
            ui.set(doubletap_ref, true)
            was_dt_disabled_by_fakeduck = false
        end

   
    end
end

 
client.set_event_callback("setup_command", force_aimbot_on_fakeduck)



 
local dt_ref = ui.reference("Rage", "Aimbot", "Double tap")

 
local Bind_for_fd = ui.new_hotkey("Rage", "Other", "Bind_for_fd")       
local Test = ui.new_hotkey("Rage", "Other", "Not working ")  

-- я тупой в бинд системе не разобрался по этому юзайте первый hotkey(Bind_for_fd)
 --I'm not good at the bind system, so use the first hotkey (Bind_for_fd)
local dt_toggled = false
local was_toggle_down = false

  
client.set_event_callback("setup_command", function()
    local hold_down = ui.get(Bind_for_fd)         
    local toggle_down = ui.get(Test)     
    local toggle_pressed = toggle_down and not was_toggle_down   

     
    local dt_active = false

   
    if hold_down then
        dt_active = false
    else
    
        dt_active = true
    end
 
    if toggle_pressed then
        dt_toggled = not dt_toggled
    end
 
    ui.set(dt_ref, dt_active)
 
    was_toggle_down = toggle_down
end)
