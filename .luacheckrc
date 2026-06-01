std = "lua54"
cache = true
codes = true

globals = {
	"hl",
}

read_globals = {
	"vim",
}

max_line_length = 120

ignore = {
	"212", -- unused argument
	"213", -- unused loop variable
}

exclude_files = {
	".git/",
	"meta/", -- LSP-only type stubs, never executed.
}
