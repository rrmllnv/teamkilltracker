local mod = get_mod("TeamKillTracker")

return {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
	options = {
		widgets = {
			{
				setting_id = "hud_counter_mode",
				type = "dropdown",
				default_value = 1,
				options = {
					{text = "hud_counter_mode_kills_damage", value = 1},
					{text = "hud_counter_mode_kills", value = 2},
					{text = "hud_counter_mode_damage", value = 3},
					{text = "hud_counter_mode_last_damage", value = 4},
					{text = "hud_counter_mode_kills_last_damage", value = 5},
					{text = "hud_counter_mode_kills_total_last_damage", value = 6},
				},
			},
			{
				setting_id = "display_mode",
				type = "dropdown",
				default_value = 1,
				options = {
					{text = "display_mode_default", value = 1},
					{text = "display_mode_only_me", value = 2},
					{text = "display_mode_team_only", value = 3},
				},
			},
			{
				setting_id = "kills_color",
				type = "dropdown",
				default_value = "white",
				options = {
					{text = "color_white", value = "white"},
					{text = "color_red", value = "red"},
					{text = "color_green", value = "green"},
					{text = "color_blue", value = "blue"},
					{text = "color_yellow", value = "yellow"},
					{text = "color_orange", value = "orange"},
					{text = "color_purple", value = "purple"},
					{text = "color_cyan", value = "cyan"},
				},
			},
			{
				setting_id = "damage_color",
				type = "dropdown",
				default_value = "orange",
				options = {
					{text = "color_white", value = "white"},
					{text = "color_red", value = "red"},
					{text = "color_green", value = "green"},
					{text = "color_blue", value = "blue"},
					{text = "color_yellow", value = "yellow"},
					{text = "color_orange", value = "orange"},
					{text = "color_purple", value = "purple"},
					{text = "color_cyan", value = "cyan"},
				},
			},
			{
				setting_id = "last_damage_color",
				type = "dropdown",
				default_value = "orange",
				options = {
					{text = "color_white", value = "white"},
					{text = "color_red", value = "red"},
					{text = "color_green", value = "green"},
					{text = "color_blue", value = "blue"},
					{text = "color_yellow", value = "yellow"},
					{text = "color_orange", value = "orange"},
					{text = "color_purple", value = "purple"},
					{text = "color_cyan", value = "cyan"},
				},
			},
        },
	},
}