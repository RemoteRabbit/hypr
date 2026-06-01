---@class Appearance
---@field setup fun() Apply general layout/border config.
---@field animations fun() Register curves and animation entries.
---@field decorations fun() Configure rounding, blur, shadow, glow.
---@field misc fun() Misc tweaks (disable logo, force default wallpaper).
local M = {}

function M.animations()
	hl.config({ animations = {
		enabled = true,
	} })

	-- ╭────────────╮
	-- │ 	Curves  │
	-- ╰────────────╯

	hl.curve(
		"easeOutQuint",
		{ type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } }
	)
	hl.curve(
		"easeInOutCubic",
		{ type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } }
	)
	hl.curve("linear", {
		type = "bezier",
		points = { { 0, 0 }, { 1, 1 } },
	})
	hl.curve(
		"almostLinear",
		{ type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } }
	)
	hl.curve("quick", {
		type = "bezier",
		points = { { 0.15, 0 }, { 0.1, 1 } },
	})

	-- ╭───────────────╮
	-- │ 	Animation  │
	-- ╰───────────────╯

	-- "default" bezier and "easy" spring below refer to Hyprland's
	-- built-in named curves, not anything declared above.
	hl.animation(
		{ leaf = "global", enabled = true, speed = 10, bezier = "default" },
		{
			leaf = "border",
			enabled = true,
			speed = 5.39,
			bezier = "easeOutQuint",
		},
		{ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" },
		{
			leaf = "windowsIn",
			enabled = true,
			speed = 4.1,
			spring = "easy",
			style = "popin 87%",
		},
		{
			leaf = "windowsOut",
			enabled = true,
			speed = 1.49,
			bezier = "linear",
			style = "popin 87%",
		},
		{
			leaf = "fadeIn",
			enabled = true,
			speed = 1.73,
			bezier = "almostLinear",
		},
		{
			leaf = "fadeOut",
			enabled = true,
			speed = 1.46,
			bezier = "almostLinear",
		},
		{ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" },
		{
			leaf = "layers",
			enabled = true,
			speed = 3.81,
			bezier = "easeOutQuint",
		},
		{
			leaf = "layersIn",
			enabled = true,
			speed = 4,
			bezier = "easeOutQuint",
			style = "fade",
		},
		{
			leaf = "layersOut",
			enabled = true,
			speed = 1.5,
			bezier = "linear",
			style = "fade",
		},
		{
			leaf = "fadeLayersIn",
			enabled = true,
			speed = 1.79,
			bezier = "almostLinear",
		},
		{
			leaf = "fadeLayersOut",
			enabled = true,
			speed = 1.39,
			bezier = "almostLinear",
		},
		{
			leaf = "workspaces",
			enabled = true,
			speed = 1.94,
			bezier = "almostLinear",
			style = "fade",
		},
		{
			leaf = "workspacesIn",
			enabled = true,
			speed = 1.21,
			bezier = "almostLinear",
			style = "fade",
		},
		{
			leaf = "workspacesOut",
			enabled = true,
			speed = 1.94,
			bezier = "almostLinear",
			style = "fade",
		},
		{ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" }
	)
end

function M.decorations()
	hl.config({
		decoration = {
			rounding = 10,
			inactive_opacity = 1,
			blur = {
				enabled = true,
				size = 8,
				passes = 2,
				vibrancy = 0.1696,
			},
			shadow = {
				enabled = true,
				range = 15,
				render_power = 3,
				color = 0xee1a1a1a,
			},
			glow = {
				enabled = true,
			},
		},
	})
end

function M.misc()
	hl.config({
		misc = {
			disable_hyprland_logo = true,
			force_default_wallpaper = 1,
			-- Suppress the "Hyprland was started without start-hyprland" notification.
			-- Under uwsm, the wayland-wm@Hyprland.service already provides
			-- restart-on-failure supervision, making start-hyprland's watchdog
			-- redundant. See https://github.com/hyprwm/Hyprland/discussions/12661.
			disable_watchdog_warning = true,
		},
	})
end

function M.setup()
	hl.config({
		dwindle = {
			preserve_split = true,
		},
		general = {
			gaps_in = 10,
			gaps_out = 30,
			border_size = 5,
			-- Allow screen tearing globally. Per-window opt-in is controlled
			-- by `immediate = true` in window rules (see rules.lua Steam-games).
			-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
			allow_tearing = true,

			col = {
				active_border = {
					colors = {
						"rgba(33ccffee)",
						"rgba(00ff99ee)",
					},
				},
				inactive_border = {
					colors = {
						"rgba(595959aa)",
					},
				},
			},
			layout = "dwindle",
		},
	})
end

return M
