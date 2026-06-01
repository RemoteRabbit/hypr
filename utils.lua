---@class Utils
---@field print fun(message: string, opts?: NotifyOpts) Show a Hyprland notification.
local M = {}

---Options accepted by `M.print` for shaping the on-screen notification.
---@class NotifyOpts
---@field timeout? integer Duration in milliseconds before the notification fades. Defaults to 4000.
---@field color?   string  CSS-like `rrggbb` (no leading `#`). Defaults to `"ff1ea3"`.
---@field icon?    integer Hyprland icon id. -1=none, 0=warn, 1=info, 2=hint, 3=ok, 4=input, 5=?. Defaults to 1 (info).

---Display a transient Hyprland notification. Intended for quick debugging
---("breadcrumb prints") from inside Lua config modules; not for end-user UI.
---@param message string Content for the notification.
---@param opts?   NotifyOpts
---@return nil
function M.print(message, opts)
	opts = opts or {}
	hl.notification.create({
		text = message,
		timeout = opts.timeout or 4000,
		color = "rgb(" .. (opts.color or "ff1ea3") .. ")",
		icon = opts.icon or 1,
	})
end

return M
