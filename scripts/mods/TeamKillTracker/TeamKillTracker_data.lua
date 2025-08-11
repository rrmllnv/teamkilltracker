local mod = get_mod("TeamKillTracker")

return {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
	options = {
		widgets = {
            {
                setting_id = "hide_team_kills",
                type = "checkbox",
                default_value = false,
            },
            {
                setting_id = "hide_user_kills",
                type = "checkbox",
                default_value = false,
            },
        },
	},
}