-- NOT A FUNCTIONAL SCRIPT AT THE MOMENT. DO NOT USE.

-- KNOCKOUT for skeet.

-- local base64 = require("neverlose/base64")
-- local clipboard = require ("neverlose/clipboard")
-- local pui = require("neverlose/pui") 
local ffi = require("ffi")

ffi.cdef[[
    typedef void* HWND;
    HWND FindWindowA(const char* lpClassName, const char* lpWindowName);
    int FlashWindow(HWND hWnd, int bInvert);
]]

local definitions = {

	-- globals
	lua_build = "dev build (v0.6)",
    localplayer = entity.get_local_player,
    screen_size = client.screen_size,
    -- username = common.get_username,
    white = "\aFFFFFFFF",
    hitboxes = {[0] = 'GENERIC','HEAD', 'CHEST', 'STOMACH','LEFT ARM', 'RIGHT ARM','LEFT LEG', 'RIGHT LEG','NECK', 'GENERIC', 'GEAR'},
	clantag = "KNOCKOUT",
    clantag_index = 0,

	-- killsays
	killsays = {
		"No fucking lua will ever save your ass from that pathetic playstyle.",
		"Fuck your cheat, fuck your lua. You're either using KNOCKOUT.lua or you're not. Choice is always yours.",
		"You LOST because you're simply incompetent. Should've used KNOCKOUT.lua.",
		"Out cold. Knockout delivered. Just use knockout already bro. It's literally FREE.",
		"You just met the knockout punch.",
		"Lights out. Better luck next time.",
		"Resolved. Knocked out.",
		"KO'd like a champ.",
		"Knocked out of the fucking game.",
		"Sleep tight. You've been knocked out.",
		"Game over. KNOCKOUT.lua victory?",
		"Consider yourself knocked the fuck out.",
		"Avoid the loss. Use KNOCKOUT.lua at github.com/devnrk/KNOCKOUT",
	},

	default_primary_theme = color(31, 109, 255),
	default_secondary_theme = color(255, 110, 110),

	-- some random vars
    jitter_side = 1,
    target,
    i_shot,
    aimbot_shot_to_enemy = true,
    alreadypulledtaser = 0,

	-- for player dormancy state
    player_dormancies = {
		CHEAT_CONFIDENCE = "Dormant - Cheat 100% confidence",
		SOUNDS = "Dormant - Sounds",
		DATA_EXPIRED = "Dormant - Data expired"
    },

	-- for player state
    player_states = {
		STAND = "Standing",
		WALK = "Walking",
		RUN = "Running",
		CROUCH = "Ducking",
		AIR_CROUCH = "Air Ducking",
		AIR = "In Air",
    },
    enemy_states = {
		STAND,
		WALK,
		RUN,
		CROUCH,
		AIR_CROUCH,
		AIR
    },

	-- for auto tp
	tp_once = true,
	our_trace_z_offset = 0,
	check_for_tp_after_air_duration = 0.2, -- how long after we jump or are in air that the teleport logic should run.
	
	-- for hitmarker
	new_lines_from_random_directions = {},
	new_random_directions = {},
	render_impact = false,
	extending = true,
	aim_points = nil,
	num_of_lines = 15,
	start_line_offset = 2,
	start_line_length = 0,
	end_line_length = 0,
	shot_hitbox = nil,

	-- for indicators
	all_indicators = {
		"[DEV]  KNOCKOUT",
		"DT",
		"HS",
	},

	-- for ui and configs
	current_configs = {},

	-- for fps mtigations

	get_model_materials = materialsystem.get_model_materials,

	-- localplayer_materials = materials.get_materials("neverlose/self"),
	-- team8s_materials = materials.get_materials("neverlose/teammates"),
	-- team8s_weapon_materials = materials.get_materials("neverlose/teammates/weapon"),

	-- for non desync custom anti aim
	sway_add_desync = 0,
	sway_add_factor = 5,
	old_angles = {},
	jitter_idx = 1,
	distortion_minmax = {-40, 40},
	distortion_cur_angle = 0,
	swing_right = false,
	spin_factor = 0,

	-- To keep track ofdefensive spin yaw
	spin_angle = 0,

	-- for anti bruteforce
	bruteforce_counter = 0,
	anti_bruteforce_shots = {},
	entity_that_shot = nil,
	vec_from_enemy_to_me = nil,
	magnitude_from_enemy_to_me = nil,
	bullet_start_pos = nil,
	bullet_end_pos = nil,
	log_angle_once = nil,
	who_we_met_first = nil,
	set_who_we_met_first = true,
}

local function override_materials_test()
	
	local localplayer = entity.get_local_player()
	local my_team_num = entity.get_prop(localplayer, "m_iTeamNum")
	local localplayer_materials = definitions.get_model_materials(localplayer)

	print("localplayer_materials", localplayer_materials)

	-- for team8s materials
	local players = entity.get_players()
	for _, player in ipairs(players) do
		local team_num = entity.get_prop(player, "m_iTeamNum")
		if team_num == my_team_num and player ~= localplayer then
			-- we know these are team8s and not the localplayer or enemy
			local team8 = player
			local team8s_materials = definitions.get_model_materials(team8)
			print("team8s_materials", team8s_materials)
		end
	end
	-- team8s_weapon_materials = materials.get_materials("neverlose/teammates/weapon"),
end

override_materials_test()