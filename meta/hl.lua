---@meta
---
--- Type stubs for the `hl` global injected by Hyprland's Lua plugin runtime.
---
--- This file is NEVER loaded at runtime. It exists solely so that
--- lua-language-server can resolve calls like `hl.config({ ... })`,
--- `hl.bind(...)`, `hl.dsp.window.move(...)` without emitting
--- `redundant-parameter` warnings against the otherwise-untyped global.
---
--- The signatures here mirror what the config actually calls, not the full
--- Hyprland Lua API. Expand them as new helpers are used in the config.

---@class HlDispatcher
local HlDispatcher = {}

---@class HlWindowDispatchers
---Each field returns an `HlDispatcher` callable suitable for `hl.bind`.
---@field move      fun(opts: table): HlDispatcher
---@field resize    fun(opts: table): HlDispatcher
---@field close     fun(): HlDispatcher
---@field float     fun(): HlDispatcher
---@field fullscreen fun(arg?: table): HlDispatcher
---@field center    fun(): HlDispatcher
---@field cycle_next fun(): HlDispatcher
---@field drag      fun(): HlDispatcher
---@field [string]  fun(...): HlDispatcher

---@class HlDsp
---@field exec_cmd fun(cmd: string): HlDispatcher
---@field focus    fun(opts: { direction: string }): HlDispatcher
---@field window   HlWindowDispatchers

---@class HlSplitMonitorWorkspaces
---@field workspace                 fun(i: integer)
---@field move_to_workspace_silent  fun(i: integer)

---@class HlPlugin
---@field split_monitor_workspaces HlSplitMonitorWorkspaces
---@field [string] any

---@class HlNotification
---@field create fun(spec: { text: string, timeout?: integer, color?: string, icon?: integer })

---@class Hl
---Apply one or more configuration sub-trees (general, decoration, input, ...).
---@field config       fun(cfg: table)
---Register a keybind. `key` is the full chord like `"SUPER + Q"`; `opts`
---carries description, mouse/locked/repeating flags, etc.
---@field bind         fun(key: string, dispatch: HlDispatcher, opts?: table)
---Subscribe to a compositor event (e.g. `"hyprland.start"`).
---@field on           fun(event: string, cb: fun())
---Run a shell command via the compositor (fire-and-forget).
---@field exec_cmd     fun(cmd: string)
---Export an env var into the compositor's environment. Prefer
---`~/.config/uwsm/env-hyprland` under uwsm; kept for completeness.
---@field env          fun(name: string, value: string)
---Declare a named bezier curve usable by `hl.animation`.
---@field curve        fun(name: string, spec: table)
---Register one or more animation entries (variadic).
---@field animation    fun(...: table)
---Declare a monitor output.
---@field monitor      fun(spec: table)
---Declare one or more window rules (variadic).
---@field window_rule  fun(...: table)
---Notification subsystem (used by `utils.print`).
---@field notification HlNotification
---Dispatcher factory namespace (`hl.dsp.window.move({...})` etc.).
---@field dsp          HlDsp
---Plugin namespace (`hl.plugin.split_monitor_workspaces.workspace(i)` etc.).
---@field plugin       HlPlugin

---@type Hl
hl = hl
