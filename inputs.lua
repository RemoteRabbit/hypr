---@class Inputs
---@field setup fun() Apply keyboard, touchpad, and mouse configuration.
local M = {}

function M.setup()
	hl.config({
		input = {
			kb_layout = "us",
			kb_variant = "",
			kb_model = "",
			kb_options = "",
			kb_rules = "",
			follow_mouse = 1,
			touchpad = {
				natural_scroll = false,
			},
			sensitivity = 0,
		},
	})
end

return M
