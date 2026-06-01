# Hyprland Configuration

My personal Hyprland configuration for a dual-monitor desktop setup
(programming, gaming, general use). Written in Lua against the Hyprland 0.55+
Lua config API, managed by [uwsm](https://github.com/Vladimir-csp/uwsm).

## Structure

```
~/.config/hypr/
├── hyprland.lua        # entry point, requires every module
├── appearance.lua      # general, decorations, animations, misc
├── autostart.lua       # uwsm finalize, autostart programs and commands
├── display.lua         # monitor outputs, modes, positions, VRR
├── environment.lua     # placeholder (env vars now live in ~/.config/uwsm/env)
├── inputs.lua          # keyboard, touchpad, mouse
├── keybinds.lua        # every keybinding, with hl.bind options + descriptions
├── meta/
│  └── hl.lua           # Used for LSP info about hl.*
├── plugins.lua         # plugin config (split_monitor_workspaces)
├── rules.lua           # window rules (steam, terminal, utilities)
├── utils.lua           # tiny notification helper
├── hypridle.conf       # idle daemon (lock, dim, dpms, suspend)
├── hyprlock.conf       # lock screen UI
├── mocha.conf          # Catppuccin Mocha color palette
├── scripts/
│   ├── gen-docs.lua          # build markdown tables from the config
│   ├── update-readme.sh      # apply gen-docs.lua output to this file
│   └── sleep.sh              # standalone swayidle wrapper (legacy)
└── wallpapers/
```

The tables in this README under **Keybindings**, **Monitors**, and **Window Rules**
are regenerated from the Lua config by `scripts/update-readme.sh` and a pre-commit
hook. Edit the Lua, not the tables.

## Keybindings

<!-- BEGIN:autodoc-keybinds -->
### Session

| Mods | Key | Description |
| --- | --- | --- |
| `SUPER` | `Delete` | Lock screen |
| `SUPER + SHIFT` | `Q` | Open logout menu |

### Applications

| Mods | Key | Description |
| --- | --- | --- |
| `SUPER` | `Return` | Launch terminal (wezterm) |
| `SUPER` | `E` | Launch file manager (thunar) |
| `SUPER` | `R` | Open application launcher (rofi drun) |
| `SUPER` | `S` | Open window switcher (rofi) |
| `SUPER` | `V` | Open clipboard history (cliphist + rofi) |
| `SUPER` | `period` | Open emoji picker (rofi) |

### Screenshots

| Mods | Key | Description |
| --- | --- | --- |
| `SUPER + SHIFT` | `S` | Screenshot region to clipboard (grim + slurp + wl-copy) |
| _none_ | `Print` | Screenshot full screen to clipboard (grim + wl-copy) |
| `SUPER + CONTROL` | `Print` | Screenshot full screen to file (grim) |
| `SUPER + SHIFT` | `Print` | Screenshot region to file (grim + slurp) |

### Window Management

| Mods | Key | Description |
| --- | --- | --- |
| `SUPER` | `Q` | Close focused window |
| `SUPER + SHIFT` | `V` | Toggle floating mode for focused window |
| `SUPER` | `F` | Toggle fullscreen for focused window |
| `SUPER` | `C` | Center the focused floating window |
| `SUPER` | `Tab` | Cycle to next window |
| `SUPER` | `B` | Toggle waybar visibility |

### Pyprland Scratchpads

| Mods | Key | Description |
| --- | --- | --- |
| `SUPER` | `grave` | Toggle terminal scratchpad (pypr) |
| `SUPER + SHIFT` | `E` | Toggle file manager scratchpad (pypr) |
| `SUPER + SHIFT` | `A` | Toggle volume mixer scratchpad (pypr) |

### Pyprland Utilities

| Mods | Key | Description |
| --- | --- | --- |
| `SUPER` | `Z` | Toggle screen zoom (pypr) |
| `SUPER` | `O` | Toggle expose / window overview (pypr) |

### Focus

| Mods | Key | Description |
| --- | --- | --- |
| `SUPER` | `H` | Focus window to the left |
| `SUPER` | `J` | Focus window below |
| `SUPER` | `K` | Focus window above |
| `SUPER` | `L` | Focus window to the right |

### Move Window

| Mods | Key | Description |
| --- | --- | --- |
| `SUPER + SHIFT` | `H` | Move focused window left |
| `SUPER + SHIFT` | `J` | Move focused window down |
| `SUPER + SHIFT` | `K` | Move focused window up |
| `SUPER + SHIFT` | `L` | Move focused window right |

### Resize Window

| Mods | Key | Description |
| --- | --- | --- |
| `SUPER + CONTROL` | `H` | Shrink focused window horizontally |
| `SUPER + CONTROL` | `L` | Grow focused window horizontally |
| `SUPER + CONTROL` | `K` | Shrink focused window vertically |
| `SUPER + CONTROL` | `J` | Grow focused window vertically |

### Mouse

| Mods | Key | Description |
| --- | --- | --- |
| `SUPER` | `mouse:272` | Move window by dragging (Super + LMB) |
| `SUPER` | `mouse:273` | Resize window by dragging (Super + RMB) |

### Media

| Mods | Key | Description |
| --- | --- | --- |
| _none_ | `XF86AudioRaiseVolume` | Volume up |
| _none_ | `XF86AudioLowerVolume` | Volume down |
| _none_ | `XF86AudioMute` | Toggle mute (output) |
| _none_ | `XF86AudioMicMute` | Toggle mute (microphone) |
| _none_ | `XF86AudioPlay` | Play / pause |
| _none_ | `XF86AudioPause` | Play / pause |
| _none_ | `XF86AudioNext` | Next track |
| _none_ | `XF86AudioPrev` | Previous track |

### Brightness

| Mods | Key | Description |
| --- | --- | --- |
| _none_ | `XF86MonBrightnessUp` | Brightness up (laptop backlight; see TODO for DDC) |
| _none_ | `XF86MonBrightnessDown` | Brightness down (laptop backlight; see TODO for DDC) |

### Workspaces

| Mods | Key | Description |
| --- | --- | --- |
| `SUPER` | `1` | Switch to workspace 1 |
| `SUPER + SHIFT` | `1` | Move focused window to workspace 1 |
| `SUPER` | `2` | Switch to workspace 2 |
| `SUPER + SHIFT` | `2` | Move focused window to workspace 2 |
| `SUPER` | `3` | Switch to workspace 3 |
| `SUPER + SHIFT` | `3` | Move focused window to workspace 3 |
| `SUPER` | `4` | Switch to workspace 4 |
| `SUPER + SHIFT` | `4` | Move focused window to workspace 4 |
| `SUPER` | `5` | Switch to workspace 5 |
| `SUPER + SHIFT` | `5` | Move focused window to workspace 5 |
<!-- END:autodoc-keybinds -->

## Monitors

<!-- BEGIN:autodoc-monitors -->
| Output | Mode | Position | Scale | VRR |
| --- | --- | --- | --- | --- |
| `DP-1` | `3840x2160@144` | `0x0` | 1 | fullscreen |
| `DP-2` | `3840x2160@144` | `3840x0` | 1 | fullscreen |
<!-- END:autodoc-monitors -->

## Window Rules

<!-- BEGIN:autodoc-rules -->
| Name | Match | Applies |
| --- | --- | --- |
| `steam-popups` | `class=steam, title=^$` | `min_size=1 1, stay_focused=true` |
| `steam-games` | `class=steam_app_.*, fullscreen=true, no_blur=true` | `` |
| `terminal-opacity` | `class=org.wezfurlong.wezterm` | `opacity=0.95` |
| `file-dialogs` | `title=Open.*&#124;Save.*&#124;Select.*` | `float=true` |
| `utilities` | `class=file-roller&#124;ark&#124;pavucontrol` | `float=true` |
<!-- END:autodoc-rules -->

## Idle Behavior

Configured in [`hypridle.conf`](hypridle.conf):

| Timeout | Action |
| --- | --- |
| 5:00 | Dim external monitors via `ddcutil` |
| 9:40 | Notification: "Locking in 20s" |
| 10:00 | Lock session (`loginctl lock-session`) |
| 10:30 | Turn off displays (DPMS off) |
| 30:00 | Suspend (`systemctl suspend`) |

## Dependencies

### Required

- [hyprland](https://hyprland.org/): Wayland compositor (0.55+ for Lua config)
- [uwsm](https://github.com/Vladimir-csp/uwsm): session manager
- [waybar](https://github.com/Alexays/Waybar): status bar
- [hyprlock](https://github.com/hyprwm/hyprlock): lock screen
- [hypridle](https://github.com/hyprwm/hypridle): idle daemon
- [stylua](https://github.com/JohnnyMorganz/StyLua) and
  [luacheck](https://github.com/lunarmodules/luacheck): formatting and lint
- [pre-commit](https://pre-commit.com/): runs the above hooks on commit

### Recommended

- [wezterm](https://wezfurlong.org/wezterm/): terminal
- [rofi](https://github.com/davatorium/rofi): app launcher, window switcher, emoji
- [thunar](https://docs.xfce.org/xfce/thunar/start): file manager
- [grim](https://sr.ht/~emersion/grim/) +
  [slurp](https://github.com/emersion/slurp) +
  [wl-clipboard](https://github.com/bugaevc/wl-clipboard): screenshots
- [cliphist](https://github.com/sentriz/cliphist): clipboard history
- [wpctl](https://pipewire.pages.freedesktop.org/wireplumber/) +
  [playerctl](https://github.com/altdesktop/playerctl): audio and media keys
- [wlogout](https://github.com/ArtsyMacaw/wlogout): logout menu
- [swaybg](https://github.com/swaywm/swaybg): wallpaper
- [vesktop](https://github.com/Vencord/Vesktop): Discord with proper Wayland
  screen-share and audio capture

## Plugins

### pyprland

Python plugin system providing advanced scratchpads, magnifier, and expose view.

```bash
yay -S pyprland
```

### split-monitor-workspaces

Per-monitor workspaces, AwesomeWM-style.

```bash
hyprpm add https://github.com/Duckonaut/split-monitor-workspaces
hyprpm enable split-monitor-workspaces
hyprpm reload
```

## Gaming

Steam games launched fullscreen are handled by a window rule (see the
**Window Rules** table above) that disables blur. VRR is enabled per-monitor
in `display.lua` (fullscreen-only mode), and `general:allow_tearing = true`
is set globally so any window that opts in via `immediate = true` will tear
instead of stalling on VSync. See
[Hyprland tearing docs](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/)
for the trade-offs.

## Development

This repo has a [pre-commit](https://pre-commit.com/) setup that runs file-hygiene
checks, formats Lua with [StyLua](https://github.com/JohnnyMorganz/StyLua),
lints with [luacheck](https://github.com/lunarmodules/luacheck), formats and
lints shell scripts (`shfmt`, `shellcheck`), scans for secrets with
[gitleaks](https://github.com/gitleaks/gitleaks), catches typos with
[typos](https://github.com/crate-ci/typos), and keeps the autodoc tables in
this README in sync with the Lua config.

```bash
# one-time setup (per clone)
pre-commit install

# run all hooks against every tracked file
pre-commit run --all-files

# bump hook pins to latest
pre-commit autoupdate

# regenerate the README autodoc tables manually
scripts/update-readme.sh
```

Tool configs live at the repo root:
[`.pre-commit-config.yaml`](.pre-commit-config.yaml),
[`.stylua.toml`](.stylua.toml),
[`.luacheckrc`](.luacheckrc),
[`.typos.toml`](.typos.toml),
[`.editorconfig`](.editorconfig).

## License

[GPL-3.0 license](LICENSE)
