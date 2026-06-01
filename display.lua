---@class Display
---@field monitors fun() Declare monitor outputs, modes, and positions.
local M = {}

function M.monitors()
	-- vrr = 2 means "VRR active only while a fullscreen window is focused".
	-- Avoids flicker on idle desktop animations while still giving games the
	-- adaptive sync benefit. Use vrr = 1 to force it always-on.
	hl.monitor({
		output = "DP-1",
		mode = "3840x2160@144",
		position = "0x0",
		scale = 1,
		vrr = 2,
	})

	hl.monitor({
		output = "DP-2",
		mode = "3840x2160@144",
		position = "3840x0",
		scale = 1,
		vrr = 2,
	})
end

return M
