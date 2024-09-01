


local get_antiaim = ui.find("Aimbot", "Anti Aim", "Angles", "Enabled")

local sway_add_desync = 0
local sway_add_factor = 5
local old_angles = {}
local jitter_idx = 1
local distortion_minmax = {-40, 40}
local distortion_cur_angle = 0
local swing_right = false
local spin_factor = 0

local function run_non_desync_aa(in_air, cmd)

    if cmd.in_attack == 1 then 
        get_antiaim:override()
        return 
    end

    get_antiaim:override(false)
    
    local cur_target = entity.get_threat()

    if cur_target ~= nil then
    
        -- getting at target yaw
        local enemy_pos = cur_target:get_origin()
        local direction = enemy_pos - entity.get_local_player:get_origin()
        local target_yaw = math.deg(math.atan2(direction.y, direction.x))
        target_yaw = target_yaw + 180

        -- setting pitch
        cmd.view_angles.x = 89
        
        -- jitter
        local jitter_angles = {-math.random(-60, 40), math.random(-40, 60)}
        
        if #old_angles == 0 then
            old_angles[1] = jitter_angles[1]
            old_angles[2] = jitter_angles[2]
        else
            --print_dev(jitter_angles[1], " ", old_angles[1], " ", jitter_angles[2], " ", old_angles[2])
            if old_angles[1] == jitter_angles[1] or old_angles[2] == jitter_angles[2] then return end
        end
            
        jitter_idx = jitter_idx + 1
        
        if jitter_idx > # jitter_angles then jitter_idx = 1 end
        
        local cur_angle = jitter_angles[jitter_idx]
        
        cmd.view_angles.y = target_yaw + cur_angle
            
        -- run some smart anti aim logic
        -- check for priority target
        -- coming soon!
        local priority = cur_target == entity.get_threat()
    else
        cmd.view_angles.y = cmd.view_angles.y + 180
    end
end


events.createmove:set(function(cmd)
    local prop = entity.get_local_player()["m_fFlags"]
    local in_air = (prop == 256 or prop == 262)
    run_non_desync_aa(in_air, cmd)
end)