local mod = get_mod("TeamKillTracker")

local Text = require("scripts/utilities/ui/text")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local font_size = 24
local size = {400, 200}

local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	teamKillContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "top",
		horizontal_alignment = "center",
		size = size,
		position = {0, 50, 10},
	},
}

local teamKillStyle = {
	line_spacing = 1.2,
	font_size = font_size,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = {255, 255, 255, 255},
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "top",
}

local widget_definitions = {
	teamKillCounter = UIWidget.create_definition(
		{ {
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = teamKillStyle,
		} },
		"teamKillContainer"
	),
}

local HudElementPlayerStats = class("HudElementPlayerStats", "HudElementBase")

HudElementPlayerStats.init = function(self, parent, draw_layer, start_scale)
	HudElementPlayerStats.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})
	self.is_in_hub = mod._is_in_hub()
end

HudElementPlayerStats.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementPlayerStats.super.update(self, dt, t, ui_renderer, render_settings, input_service)
	
	if self.is_in_hub then
		self._widgets_by_name.teamKillCounter.content.text = ""
		return
	end
	
	-- Обновление текста
	local total_kills = 0
	local players_with_kills = {}
	
	-- Собираем игроков с убийствами > 0
	for player_name, kills in pairs(mod.player_kills or {}) do
		if kills > 0 then
			total_kills = total_kills + kills
			table.insert(players_with_kills, {name = player_name, kills = kills})
		end
	end
	
	-- Сортируем по убийствам (больше сверху)
	table.sort(players_with_kills, function(a, b)
		return a.kills > b.kills
	end)
	
	-- Формируем текст
	local display_text = "TEAM KILLS: " .. total_kills
	
	if #players_with_kills > 0 then
		for _, player in ipairs(players_with_kills) do
			display_text = display_text .. "\n" .. player.name .. ": " .. player.kills
		end
	else
		display_text = display_text .. "\nNo kills yet"
	end
	
	self._widgets_by_name.teamKillCounter.content.text = display_text
end

return HudElementPlayerStats