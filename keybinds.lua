---@class Keybinds
---@field binds Bind[] Declarative list of keybindings registered on `setup`.
---@field setup fun() Apply Hyprland configuration and register every bind.
local M = {}

---@alias Mods string Modifier string accepted by `hl.bind`, e.g. "SUPER + SHIFT".
---@alias Direction "l"|"r"|"u"|"d" Cardinal direction used by focus/move dispatchers.
---@alias Dispatcher any Opaque dispatcher value returned by `hl.dsp.*` helpers.

---@class BindOpts
---@field description? string Human-readable description shown by `hyprctl binds`.
---@field mouse?       boolean Treat this bind as a mouse binding (bindm).
---@field locked?      boolean Fire even when the session is locked (e.g. media keys).
---@field repeating?   boolean Repeat while the key is held (e.g. volume up).

---A single keybinding entry.
---
---Positional fields:
---  [1] Mods       modifier prefix (e.g. `mod`, `shift`, `ctrl`)
---  [2] string     key name (e.g. `"Q"`, `"Return"`, `"mouse:272"`)
---  [3] Dispatcher dispatcher to invoke
---  [4] BindOpts   options table (always includes `description`)
---  [5] string     group name for documentation / autodoc grouping
---@class Bind
---@field [1] Mods
---@field [2] string
---@field [3] Dispatcher
---@field [4] BindOpts
---@field [5] string

local mod = "SUPER"
local shift = "SUPER + SHIFT"
local ctrl = "SUPER + CONTROL"
-- local alt = "SUPER + ALT"

local terminal = "wezterm"
local fileManager = "thunar"
local menu = "rofi -show drun"
local winSwitch = "rofi -show window"
local emoji = "rofi -show emoji"
local clip = "cliphist list | rofi -dmenu | cliphist decode | wl-copy"

---Run a one-shot shell command. Use for utilities that exit immediately
---(grim, wpctl, killall, etc.) or for shell pipelines that `uwsm app` can't
---handle.
---@param command string
---@return Dispatcher
local exec = function(command)
	return hl.dsp.exec_cmd(command)
end

---Launch a long-lived GUI app under a systemd transient scope via uwsm.
---Gives the app its own cgroup, restart-aware lifecycle, and journald logs.
---Do NOT use for shell pipelines or one-shot utilities (use `exec` for those).
---@param command string
---@return Dispatcher
local app = function(command)
	return hl.dsp.exec_cmd("uwsm app -- " .. command)
end

---@param direction Direction
---@return Dispatcher
local focus = function(direction)
	return hl.dsp.focus({ direction = direction })
end

---@param direction Direction
---@return Dispatcher
local move = function(direction)
	return hl.dsp.window.move({ direction = direction })
end

---@param x integer
---@param y integer
---@return Dispatcher
local size = function(x, y)
	return hl.dsp.window.resize({ x = x, y = y })
end

---@param funcName string
---@param ... any
---@return Dispatcher
local win = function(funcName, ...)
	return hl.dsp.window[funcName](...)
end

---Valid keys allowed in `BindOpts`. Anything else is a typo and we fail loudly
---at config-load time so silent no-op binds don't ship to production.
local VALID_OPTS = {
	description = true,
	mouse = true,
	locked = true,
	repeating = true,
}

---Validate a modifier string. Allows empty string (no mods), or any combo of
---`SUPER`, `SHIFT`, `CONTROL`, `ALT`, `CTRL`, `MOD2`-`MOD5` joined with ` + `.
---Catches things like `"SUPER+SHIFT"` (missing spaces) or stray lowercase
---which Hyprland would silently treat as "no mods" or refuse to register.
---@param mods string
local function validate_mods(mods)
	if mods == "" then
		return
	end
	for token in mods:gmatch("[^%+%s]+") do
		assert(
			token:match("^[A-Z][A-Z0-9_]*$"),
			"keybinds: invalid modifier token "
				.. tostring(token)
				.. " in mods string '"
				.. mods
				.. "' (expected ALLCAPS joined with ' + ')"
		)
	end
	assert(
		mods:match("^[A-Z0-9_]+ ?$") or mods:find(" %+ "),
		"keybinds: mods string '"
			.. mods
			.. "' must separate tokens with ' + ' (e.g. 'SUPER + SHIFT')"
	)
end

-- Current group, set by `in_group()` and captured by `bind()` for autodoc.
local _current_group = "Other"

---Set the group label applied to subsequent `bind()` calls. Used by the
---autodoc generator to partition the README keybindings table into
---per-section sub-tables.
---@param name string
local function in_group(name)
	_current_group = name
end

---Construct a `Bind` with named, ordered parameters.
---The description is merged into the options table so that `hyprctl binds`
---shows it (see https://wiki.hypr.land/Configuring/Basics/Binds/#description).
---Validates `mods` and rejects unknown option keys. The current group
---(set via `in_group`) is captured as the 5th element for autodoc.
---@param mods Mods
---@param key string
---@param dispatch Dispatcher
---@param desc string
---@param opts? BindOpts
---@return Bind
local function bind(mods, key, dispatch, desc, opts)
	validate_mods(mods)
	assert(
		type(key) == "string" and key ~= "",
		"keybinds: key must be a non-empty string"
	)
	assert(dispatch ~= nil, "keybinds: dispatch for '" .. key .. "' is nil")
	local merged = { description = desc }
	if opts then
		for k, v in pairs(opts) do
			assert(
				VALID_OPTS[k],
				"keybinds: unknown BindOpts key '"
					.. tostring(k)
					.. "' on bind '"
					.. key
					.. "'"
			)
			merged[k] = v
		end
	end
	return { mods, key, dispatch, merged, _current_group }
end

-- The split-monitor-workspaces plugin replaces Hyprland's global workspace
-- numbering with per-monitor workspaces, so `workspace 1` on DP-1 is a
-- different surface than `workspace 1` on DP-2. See plugins.lua.
local smw = hl.plugin.split_monitor_workspaces

---Build a dispatcher that switches the focused monitor to its `i`-th
---per-monitor workspace.
---@param i integer 1-based workspace index on the focused monitor.
---@return fun() dispatcher Zero-arg closure suitable for `hl.bind`.
local ws = function(i)
	return function()
		smw.workspace(i)
	end
end

---Build a dispatcher that moves the focused window to the `i`-th per-monitor
---workspace on its current monitor without following the move.
---@param i integer 1-based workspace index on the focused monitor.
---@return fun() dispatcher Zero-arg closure suitable for `hl.bind`.
local wsMv = function(i)
	return function()
		smw.move_to_workspace_silent(i)
	end
end

---Declarative list of keybindings registered by `M.setup`. Built up via
---grouped `add(...)` calls below so the autodoc generator can partition them
---by section in the README.
---@type Bind[]
M.binds = {}

---Append a new bind to `M.binds`. Thin wrapper over `bind(...)` so the
---per-group sections below read as tight one-liners.
---@param mods Mods
---@param key string
---@param dispatch Dispatcher
---@param desc string
---@param opts? BindOpts
---@return nil
local function add(mods, key, dispatch, desc, opts)
	M.binds[#M.binds + 1] = bind(mods, key, dispatch, desc, opts)
end

in_group("Session")
add(mod, "Delete", exec("hyprlock"), "Lock screen")
add(shift, "Q", app("wlogout"), "Open logout menu")

in_group("Applications")
add(mod, "Return", app(terminal), "Launch terminal (wezterm)")
add(mod, "E", app(fileManager), "Launch file manager (thunar)")
add(mod, "R", app(menu), "Open application launcher (rofi drun)")
add(mod, "S", app(winSwitch), "Open window switcher (rofi)")
-- cliphist is a shell pipeline; can't go through `uwsm app --`.
add(mod, "V", exec(clip), "Open clipboard history (cliphist + rofi)")
add(mod, "period", app(emoji), "Open emoji picker (rofi)")

in_group("Screenshots")
-- TODO: revisit against the docs / community recs; consider hyprshot,
-- grimblast, satty for annotation, and a dedicated $HOME/Pictures/Screenshots
-- target path with timestamped filenames.
add(
	shift,
	"S",
	exec('grim -g "$(slurp)" - | wl-copy'),
	"Screenshot region to clipboard (grim + slurp + wl-copy)"
)
add(
	"",
	"Print",
	exec("grim - | wl-copy"),
	"Screenshot full screen to clipboard (grim + wl-copy)"
)
add(
	ctrl,
	"Print",
	exec('grim "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"'),
	"Screenshot full screen to file (grim)"
)
add(
	shift,
	"Print",
	exec(
		'grim -g "$(slurp)" "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"'
	),
	"Screenshot region to file (grim + slurp)"
)

in_group("Window Management")
add(mod, "Q", win("close"), "Close focused window")
add(shift, "V", win("float"), "Toggle floating mode for focused window")
add(mod, "F", win("fullscreen", { 0 }), "Toggle fullscreen for focused window")
add(mod, "C", win("center"), "Center the focused floating window")
add(mod, "Tab", win("cycle_next"), "Cycle to next window")
add(mod, "B", exec("killall -SIGUSR1 waybar"), "Toggle waybar visibility")

in_group("Pyprland Scratchpads")
add(mod, "grave", exec("pypr toggle term"), "Toggle terminal scratchpad (pypr)")
add(
	shift,
	"E",
	exec("pypr toggle files"),
	"Toggle file manager scratchpad (pypr)"
)
add(
	shift,
	"A",
	exec("pypr toggle volume"),
	"Toggle volume mixer scratchpad (pypr)"
)

in_group("Pyprland Utilities")
add(mod, "Z", exec("pypr zoom"), "Toggle screen zoom (pypr)")
add(mod, "O", exec("pypr expose"), "Toggle expose / window overview (pypr)")

in_group("Focus")
add(mod, "H", focus("l"), "Focus window to the left")
add(mod, "J", focus("d"), "Focus window below")
add(mod, "K", focus("u"), "Focus window above")
add(mod, "L", focus("r"), "Focus window to the right")

in_group("Move Window")
add(shift, "H", move("l"), "Move focused window left")
add(shift, "J", move("d"), "Move focused window down")
add(shift, "K", move("u"), "Move focused window up")
add(shift, "L", move("r"), "Move focused window right")

in_group("Resize Window")
add(ctrl, "H", size(-10, 0), "Shrink focused window horizontally")
add(ctrl, "L", size(10, 0), "Grow focused window horizontally")
add(ctrl, "K", size(0, -10), "Shrink focused window vertically")
add(ctrl, "J", size(0, 10), "Grow focused window vertically")

in_group("Mouse")
-- bindm: hold + drag. See https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua
add(
	mod,
	"mouse:272",
	win("drag"),
	"Move window by dragging (Super + LMB)",
	{ mouse = true }
)
add(
	mod,
	"mouse:273",
	win("resize"),
	"Resize window by dragging (Super + RMB)",
	{ mouse = true }
)

in_group("Media")
-- locked: fire while screen is locked; repeating: hold to repeat.
-- TODO: review against docs for preferred backends. Currently using
-- wpctl (pipewire) for audio and playerctl for media; pamixer is an
-- alternative if you ever drop pipewire.
add(
	"",
	"XF86AudioRaiseVolume",
	exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	"Volume up",
	{ locked = true, repeating = true }
)
add(
	"",
	"XF86AudioLowerVolume",
	exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	"Volume down",
	{ locked = true, repeating = true }
)
add(
	"",
	"XF86AudioMute",
	exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	"Toggle mute (output)",
	{ locked = true }
)
add(
	"",
	"XF86AudioMicMute",
	exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	"Toggle mute (microphone)",
	{ locked = true }
)
add(
	"",
	"XF86AudioPlay",
	exec("playerctl play-pause"),
	"Play / pause",
	{ locked = true }
)
add(
	"",
	"XF86AudioPause",
	exec("playerctl play-pause"),
	"Play / pause",
	{ locked = true }
)
add(
	"",
	"XF86AudioNext",
	exec("playerctl next"),
	"Next track",
	{ locked = true }
)
add(
	"",
	"XF86AudioPrev",
	exec("playerctl previous"),
	"Previous track",
	{ locked = true }
)

in_group("Brightness")
-- TODO: this is a desktop with DP monitors (no internal backlight).
-- brightnessctl only handles laptop backlights / keyboard LEDs.
-- For DDC/CI monitor control you already use ddcutil in hypridle.conf;
-- consider a wrapper script that calls
--   ddcutil --display=1 setvcp 10 + 5 && ddcutil --display=2 setvcp 10 + 5
-- and bind it here. Left as brightnessctl placeholders for now.
add(
	"",
	"XF86MonBrightnessUp",
	exec("brightnessctl -e4 -n2 set 5%+"),
	"Brightness up (laptop backlight; see TODO for DDC)",
	{ locked = true, repeating = true }
)
add(
	"",
	"XF86MonBrightnessDown",
	exec("brightnessctl -e4 -n2 set 5%-"),
	"Brightness down (laptop backlight; see TODO for DDC)",
	{ locked = true, repeating = true }
)

in_group("Workspaces")
for i = 1, 5 do
	add(mod, tostring(i), ws(i), "Switch to workspace " .. i)
	add(shift, tostring(i), wsMv(i), "Move focused window to workspace " .. i)
end

---Apply Hyprland bind configuration and register every entry in `M.binds`.
---
---For each bind, the key string is constructed as `"<mods> + <key>"` (or just
---`"<key>"` when mods is empty) and dispatched via `hl.bind`. The 4th
---positional element (always present) is forwarded as the options table and
---carries at minimum a `description` for `hyprctl binds`. The 5th element is
---only used by `scripts/gen-docs.lua` for README autodoc grouping.
---@return nil
function M.setup()
	hl.config({ binds = { drag_threshold = 10 } })
	for _, b in ipairs(M.binds) do
		local key = (b[1] == "" and "" or b[1] .. " + ") .. b[2]
		hl.bind(key, b[3], b[4])
	end
end

return M
