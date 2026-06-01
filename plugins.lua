---@class Plugins
---@field split_monitors fun() Configure the split-monitor-workspaces plugin.
local M = {}

function M.split_monitors()
	hl.config({
		plugin = {
			split_monitor_workspaces = {
				count = 5,
				enable_notifications = 0,
			},
		},
	})
end

return M
