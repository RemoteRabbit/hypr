#!/usr/bin/env lua
-- Generate markdown documentation sections from the Hyprland Lua config.
--
-- Usage:
--   lua scripts/gen-docs.lua keybinds   # print the keybinds table
--   lua scripts/gen-docs.lua monitors   # print the monitors table
--   lua scripts/gen-docs.lua rules      # print the window-rules table
--   lua scripts/gen-docs.lua all        # print every section with markers
--
-- The script stubs out the Hyprland `hl` global so the real config modules
-- can be `require`d without a running compositor. Stubbed calls either do
-- nothing or record their arguments into capture buckets we then format.

local SCRIPT_DIR = arg[0]:match("(.+)/[^/]+$") or "."
package.path = SCRIPT_DIR .. "/../?.lua;" .. package.path

-- ---------------------------------------------------------------------------
-- Mock `hl`
-- ---------------------------------------------------------------------------

local captured = { monitors = {}, rules = {} }

local function noop() end

-- An opaque, infinitely-callable, infinitely-indexable sentinel for
-- dispatcher chains like `hl.dsp.window.move({ ... })`.
local opaque
opaque = setmetatable({}, {
	__call = function()
		return opaque
	end,
	__index = function()
		return opaque
	end,
})

_G.hl = {
	bind = noop,
	config = noop,
	env = noop,
	on = noop,
	exec_cmd = noop,
	curve = noop,
	animation = noop,
	notification = { create = noop },
	monitor = function(spec)
		table.insert(captured.monitors, spec)
	end,
	window_rule = function(...)
		for _, r in ipairs({ ... }) do
			table.insert(captured.rules, r)
		end
	end,
	dsp = setmetatable({}, {
		__index = function(_, k)
			if k == "window" then
				return setmetatable({}, {
					__index = function()
						return function()
							return opaque
						end
					end,
				})
			end
			return function()
				return opaque
			end
		end,
	}),
	plugin = setmetatable({}, {
		__index = function()
			return setmetatable({}, {
				__index = function()
					return noop
				end,
			})
		end,
	}),
}

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

---Escape a value for safe inclusion inside a single markdown table cell.
---
---Pipes inside table cells must be HTML-encoded so they don't terminate the
---markdown column. We use the entity (rather than `\|`) because that survives
---being passed through awk's `-v` flag in `update-readme.sh`, and it renders
---as a literal `|` in any markdown viewer.
---@param s any Value coerced to string before escaping.
---@return string escaped Cell-safe representation of `s`.
local function md_escape(s)
	return (tostring(s):gsub("|", "&#124;"))
end

---Return the keys of a table sorted alphabetically as strings.
---Used to produce stable column orderings in generated docs (without it, the
---`match=`/`applies=` columns would shuffle on every regeneration and churn
---the diff).
---@param t table<any, any>
---@return string[] keys Sorted string-coerced keys.
local function sorted_keys(t)
	local keys = {}
	for k in pairs(t) do
		keys[#keys + 1] = tostring(k)
	end
	table.sort(keys)
	return keys
end

-- ---------------------------------------------------------------------------
-- Generators
-- ---------------------------------------------------------------------------

---Render the keybindings table grouped by `bind[5]` (its `in_group` label).
---Group order follows first-seen order in `keybinds.binds` so the README
---reflects the visual ordering in `keybinds.lua`.
---@return string markdown Multi-section markdown with `### <Group>` headings.
local function gen_keybinds()
	local keybinds = require("keybinds")

	-- Partition by `bind[5]` (group), preserving first-seen group order.
	local groups = {}
	local group_order = {}
	for _, b in ipairs(keybinds.binds) do
		local group = b[5] or "Other"
		if not groups[group] then
			groups[group] = {}
			group_order[#group_order + 1] = group
		end
		groups[group][#groups[group] + 1] = b
	end

	local lines = {}
	for i, group in ipairs(group_order) do
		if i > 1 then
			lines[#lines + 1] = ""
		end
		lines[#lines + 1] = "### " .. group
		lines[#lines + 1] = ""
		lines[#lines + 1] = "| Mods | Key | Description |"
		lines[#lines + 1] = "| --- | --- | --- |"
		for _, b in ipairs(groups[group]) do
			local mods, key, _, opts = b[1], b[2], b[3], b[4]
			local desc = (opts and opts.description) or ""
			local mods_disp = mods == "" and "_none_"
				or string.format("`%s`", mods)
			lines[#lines + 1] = string.format(
				"| %s | `%s` | %s |",
				mods_disp,
				md_escape(key),
				md_escape(desc)
			)
		end
	end
	return table.concat(lines, "\n")
end

---Render the monitors table by invoking `display.monitors()` against the
---mocked `hl` so every `hl.monitor(spec)` call is captured into
---`captured.monitors` and turned into a row.
---@return string markdown Single markdown table of declared outputs.
local function gen_monitors()
	require("display").monitors()
	local lines = {
		"| Output | Mode | Position | Scale | VRR |",
		"| --- | --- | --- | --- | --- |",
	}
	for _, m in ipairs(captured.monitors) do
		local vrr = m.vrr
		local vrr_disp
		if vrr == nil then
			vrr_disp = "off"
		elseif vrr == 0 then
			vrr_disp = "off"
		elseif vrr == 1 then
			vrr_disp = "always"
		elseif vrr == 2 then
			vrr_disp = "fullscreen"
		else
			vrr_disp = tostring(vrr)
		end
		table.insert(
			lines,
			string.format(
				"| `%s` | `%s` | `%s` | %s | %s |",
				m.output,
				m.mode,
				m.position,
				tostring(m.scale),
				vrr_disp
			)
		)
	end
	return table.concat(lines, "\n")
end

---Render the window-rules table by invoking each `rules.*` group against
---the mocked `hl` and flattening every `hl.window_rule(...)` arg into a row.
---@return string markdown Single markdown table of declared window rules.
local function gen_rules()
	local rules = require("rules")
	rules.steam()
	rules.terminal()
	rules.utilities()
	local lines = {
		"| Name | Match | Applies |",
		"| --- | --- | --- |",
	}
	for _, r in ipairs(captured.rules) do
		local name = r.name or "_(unnamed)_"
		local match_parts = {}
		for _, k in ipairs(sorted_keys(r.match or {})) do
			match_parts[#match_parts + 1] = k .. "=" .. tostring(r.match[k])
		end
		local applies_parts = {}
		for _, k in ipairs(sorted_keys(r)) do
			if k ~= "name" and k ~= "match" then
				applies_parts[#applies_parts + 1] = k .. "=" .. tostring(r[k])
			end
		end
		table.insert(
			lines,
			string.format(
				"| `%s` | `%s` | `%s` |",
				md_escape(name),
				md_escape(table.concat(match_parts, ", ")),
				md_escape(table.concat(applies_parts, ", "))
			)
		)
	end
	return table.concat(lines, "\n")
end

-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

local sections = {
	keybinds = gen_keybinds,
	monitors = gen_monitors,
	rules = gen_rules,
}

local target = arg[1]

if target == "all" then
	for _, name in ipairs({ "keybinds", "monitors", "rules" }) do
		print(string.format("<!-- BEGIN:autodoc-%s -->", name))
		print(sections[name]())
		print(string.format("<!-- END:autodoc-%s -->", name))
		print()
	end
elseif sections[target] then
	print(sections[target]())
else
	io.stderr:write(
		"usage: lua scripts/gen-docs.lua {keybinds|monitors|rules|all}\n"
	)
	os.exit(1)
end
