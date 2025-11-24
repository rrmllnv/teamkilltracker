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
mod.player_damage = {}
mod.killed_units = {}

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

-- Форматирование числа с разделителем тысяч (запятая)
mod.format_number = function(number)
	local num = math.floor(number)
	if num < 1000 then
		return tostring(num)
	end
	
	local formatted = tostring(num)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

local function recreate_hud()
    mod.player_kills = {}
    mod.player_damage = {}
    mod.killed_units = {}
    mod.hide_team_kills = mod:get("hide_team_kills")
    mod.hide_user_kills = mod:get("hide_user_kills")
    mod.hud_counter_mode = mod:get("hud_counter_mode") or 1
end

mod.on_all_mods_loaded = function()
	recreate_hud()
end

mod.on_setting_changed = function()
    mod.hide_team_kills = mod:get("hide_team_kills")
    mod.hide_user_kills = mod:get("hide_user_kills")
    mod.hud_counter_mode = mod:get("hud_counter_mode") or 1
end

function mod.on_game_state_changed(status, state_name)
	if state_name == 'GameplayStateRun' or state_name == "StateGameplay" and status == "enter" then
		recreate_hud()
	end
end

mod.add_to_killcounter = function(account_id)
    if not account_id then
		return
	end
	
    if not mod.player_kills[account_id] then
        mod.player_kills[account_id] = 0
	end
	
    mod.player_kills[account_id] = mod.player_kills[account_id] + 1
end

mod.add_to_damage = function(account_id, amount)
    if not account_id or not amount then
        return
    end
    if not mod.player_damage[account_id] then
        mod.player_damage[account_id] = 0
    end
    mod.player_damage[account_id] = mod.player_damage[account_id] + math.max(0, amount)
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

-- Проверяем, локальная ли сессия (для корректного подсчёта overkill)
local function is_local_session()
    local game_mode_name = Managers.state.game_mode and Managers.state.game_mode:game_mode_name()
    return game_mode_name == "shooting_range" or game_mode_name == "hub"
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
            local account_id = player:account_id() or player:name() or "Player"
            local unit_health_extension = ScriptUnit.has_extension(attacked_unit, "health_system")
            
            -- Логика подсчёта урона из Power_DI
            local health_damage = 0
            
            if attack_result == "died" then
                -- При смерти: вычисляем здоровье, которое осталось у цели перед ударом
                local attacked_unit_damage_taken = unit_health_extension and unit_health_extension:damage_taken()
                local defender_max_health = unit_health_extension and unit_health_extension:max_health()
                local is_local = is_local_session()
                
                if defender_max_health and not is_local then
                    health_damage = defender_max_health - (attacked_unit_damage_taken or 0)
                elseif defender_max_health and is_local then
                    health_damage = defender_max_health - (attacked_unit_damage_taken or 0) + (damage or 0)
                else
                    health_damage = damage or 1
                end
                
                -- Килл: считаем один раз на юнит
                if not mod.killed_units[attacked_unit] then
                    mod.killed_units[attacked_unit] = true
                    mod.add_to_killcounter(account_id)
                end
                
            elseif attack_result == "damaged" then
                -- При обычном уроне просто берём значение damage
                health_damage = damage or 0
            end
            
            if health_damage > 0 then
                mod.add_to_damage(account_id, health_damage)
            end
        end
    end
end)

