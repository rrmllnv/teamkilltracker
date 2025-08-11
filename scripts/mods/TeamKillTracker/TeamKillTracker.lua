local mod = get_mod("TeamKillTracker")

local Breed = mod:original_require("scripts/utilities/breed")

local hud_elements = {
	{
		filename = "TeamKillTracker/scripts/mods/TeamKillTracker/HudElementPlayerStats",
		class_name = "HudElementPlayerStats",
		visibility_groups = {
			"alive",
		},
	},
}

mod.player_kills = {}

for _, hud_element in ipairs(hud_elements) do
	mod:add_require_path(hud_element.filename)
end

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
	for _, hud_element in ipairs(hud_elements) do
		if not table.find_by_key(elements, "class_name", hud_element.class_name) then
			table.insert(elements, {
				class_name = hud_element.class_name,
				filename = hud_element.filename,
				use_hud_scale = true,
				visibility_groups = hud_element.visibility_groups or {
					"alive",
				},
			})
		end
	end

	return func(self, elements, visibility_groups, params)
end)

mod._is_in_hub = function()
	local game_mode_name = Managers.state.game_mode:game_mode_name()
	return game_mode_name == "hub"
end

local function recreate_hud()
    mod.player_kills = {}
    mod.hide_team_kills = mod:get("hide_team_kills")
    mod.hide_user_kills = mod:get("hide_user_kills")
end

mod.on_all_mods_loaded = function()
	recreate_hud()
end

mod.on_setting_changed = function()
    mod.hide_team_kills = mod:get("hide_team_kills")
    mod.hide_user_kills = mod:get("hide_user_kills")
end

function mod.on_game_state_changed(status, state_name)
	if state_name == 'GameplayStateRun' or state_name == "StateGameplay" and status == "enter" then
		recreate_hud()
	end
end

mod.add_to_killcounter = function(player_name)
	if not player_name then
		return
	end
	
	if not mod.player_kills[player_name] then
		mod.player_kills[player_name] = 0
	end
	
	mod.player_kills[player_name] = mod.player_kills[player_name] + 1
end

-- Получаем игрока по юниту (проверяем всех игроков)
mod.player_from_unit = function(self, unit)
	if unit then
		local player_manager = Managers.player
		local players = player_manager:players()
		for _, player in pairs(players) do
			if player and player.player_unit == unit then
				return player
			end
		end
	end
	return nil
end

mod:hook_safe(CLASS.AttackReportManager, "add_attack_result",
function(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage,
	attack_result, attack_type, damage_efficiency, ...)

	local player = mod:player_from_unit(attacking_unit)
	if player then
		local unit_data_extension = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
		local breed_or_nil = unit_data_extension and unit_data_extension:breed()
		local target_is_minion = breed_or_nil and Breed.is_minion(breed_or_nil)		
		if target_is_minion then
			if attack_result == "died" then
				local player_name = player:name() or "Player"
				mod.add_to_killcounter(player_name)
			end
		end
	end
end)

