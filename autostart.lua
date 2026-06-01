---@class Autostart
---@field finalize fun() Signal compositor readiness to the uwsm/systemd user manager.
---@field programs fun() Launch one-shot GUI helpers as systemd-tracked scopes.
---@field commands fun() Run shell commands at session start.
local M = {}

-- Apps that should live as systemd transient scopes under graphical-session.target.
-- Wrapped with `uwsm app --` so each gets its own cgroup and journald tag.
--
-- NOTE: waybar, hypridle, nm-applet, and blueman-applet now run as systemd
-- user units (see ~/.config/systemd/user/) and are pulled in automatically
-- when graphical-session.target activates. They no longer belong here.
---@type string[]
local programs = {
	-- Currently empty: every persistent helper has a systemd unit.
	-- Add transient, fire-and-forget GUI apps here if needed.
}

---@type string[]
local commands = {
	"ssh-add $HOME/.ssh/proton",
	"hyprpm reload -n",
	"swaybg -i $HOME/Pictures/Beer-Bucket-Wallpaper.jpg -m fill",
}

---Send WAYLAND_DISPLAY/DISPLAY to the systemd user manager and notify it
---that the compositor unit has finished starting. This is what causes
---`graphical-session.target` to activate, which in turn starts
---`waybar.service`, `hypridle.service`, and any other PartOf= units.
---Safe to call when not under uwsm: it just exports the vars and no-ops
---on the readiness signal.
---@return nil
function M.finalize()
	hl.on("hyprland.start", function()
		hl.exec_cmd(
			"uwsm finalize WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE"
		)
	end)
end

---Launch each entry in `programs` as a uwsm-managed transient scope on
---compositor start. Use this for persistent GUI helpers that don't already
---have a dedicated systemd user unit.
---@return nil
function M.programs()
	for _, program in ipairs(programs) do
		hl.on("hyprland.start", function()
			hl.exec_cmd("uwsm app -- " .. program)
		end)
	end
end

---Run each entry in `commands` once on compositor start. Use this for
---one-shot shell commands and pipelines (ssh-add, plugin reloads, wallpaper
---setters) that should NOT be supervised as long-lived units.
---@return nil
function M.commands()
	for _, command in ipairs(commands) do
		hl.on("hyprland.start", function()
			hl.exec_cmd(command)
		end)
	end
end

return M
