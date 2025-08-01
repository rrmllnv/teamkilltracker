local mod = get_mod("TeamKillTracker")

return {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
	options = {
		widgets = {
			{
				setting_id = "display_options",
				type = "group",
				sub_widgets = {
					{
						setting_id = "max_players",
						type = "numeric",
						default_value = 4,
						range = {1, 4},
					},
				},
			}
		},
	},
}