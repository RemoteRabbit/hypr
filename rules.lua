---@class Rules
---@field steam fun() Window rules for Steam popups and games.
---@field terminal fun() Window rules for the terminal (opacity, etc).
---@field utilities fun() Window rules for file dialogs and utility apps.
local M = {}

-- ╭───────╮
-- │ Steam │
-- ╰───────╯
function M.steam()
	hl.window_rule({
		name = "steam-popups",
		match = {
			class = "steam",
			title = "^$",
		},
		stay_focused = true,
		min_size = "1 1",
	}, {
		name = "steam-games",
		match = {
			class = "steam_app_.*",
			fullscreen = true,
			-- Tearing disabled in favor of VRR (see display.lua `vrr = 2`).
			-- VRR gives the same latency benefit inside the 48-144 Hz range
			-- without the visible tear line. Re-enable `immediate = true`
			-- per-window if a specific competitive game needs sub-VSync latency.
			no_blur = true,
		},
	})
end

-- ╭──────────╮
-- │ Terminal │
-- ╰──────────╯
function M.terminal()
	hl.window_rule({
		name = "terminal-opacity",
		match = {
			class = "org.wezfurlong.wezterm",
		},
		opacity = 0.95,
	})
end

-- ╭───────────╮
-- │ Utilities │
-- ╰───────────╯
function M.utilities()
	hl.window_rule({
		name = "file-dialogs",
		match = {
			title = "Open.*|Save.*|Select.*",
		},
		float = true,
	}, {
		-- TODO: Split these up into their own rules
		name = "utilities",
		match = {
			class = "file-roller|ark|pavucontrol",
		},
		float = true,
	})
end

return M
