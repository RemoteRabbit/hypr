---@class Environment
---@field setup fun() No-op kept so hyprland.lua's require chain stays uniform.
local M = {}

-- Under uwsm, environment variables for the graphical session live in
-- ~/.config/uwsm/env          (loaded for any uwsm-managed compositor)
-- ~/.config/uwsm/env-hyprland (loaded only when the compositor is Hyprland)
--
-- Variables there are exported into systemd --user's environment BEFORE the
-- compositor and any user services start, so xdg-desktop-portal-hyprland,
-- pipewire, and friends see them at their own startup. Setting them here via
-- `hl.env` was too late for those consumers.
--
-- Add new graphical-session env vars to ~/.config/uwsm/env-hyprland.
function M.setup() end

return M
