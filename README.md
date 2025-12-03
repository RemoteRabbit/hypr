# Hyprland Configuration

My personal Hyprland configuration for a dual-monitor desktop setup (programming, gaming, general use).

## Structure

```
~/.config/hypr/
├── hyprland.conf          # Main config (sources all others)
├── conf/
│   ├── monitors.conf      # Monitor setup (DP-1, DP-2)
│   ├── env.conf           # Environment variables
│   ├── autostart.conf     # Startup applications
│   ├── input.conf         # Keyboard/mouse settings
│   ├── appearance.conf    # Gaps, borders, animations
│   ├── keybinds.conf      # All keybindings
│   ├── rules.conf         # Window/layer rules
│   └── plugins.conf       # Plugin configuration
├── pyprland.toml          # Pyprland config
├── hyprlock.conf          # Lock screen config
├── hypridle.conf          # Idle/suspend config
├── hyprpaper.conf         # Wallpaper config
├── mocha.conf             # Catppuccin Mocha colors
└── wallpapers/            # Wallpaper images
```

## Keybindings

### Session
| Key | Action |
|-----|--------|
| `Super + Delete` | Lock screen |
| `Super + Shift + Q` | Logout menu (wlogout) |
| `Super + M` | Exit Hyprland |

### Applications
| Key | Action |
|-----|--------|
| `Super + Return` | Terminal (wezterm) |
| `Super + E` | File manager (dolphin) |
| `Super + R` | App launcher (rofi) |
| `Super + S` | Window switcher |
| `Super + V` | Clipboard history |
| `Super + .` | Emoji picker |

### Windows
| Key | Action |
|-----|--------|
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + Shift + F` | Fake fullscreen |
| `Super + Shift + V` | Toggle floating |
| `Super + C` | Center floating window |
| `Super + G` | Toggle window group |
| `Super + Tab` | Cycle windows |
| `Super + B` | Toggle waybar |

### Focus/Move/Resize (Vim-style)
| Key | Action |
|-----|--------|
| `Super + H/J/K/L` | Move focus |
| `Super + Shift + H/J/K/L` | Move window |
| `Super + Ctrl + H/J/K/L` | Resize window |
| `Super + Alt + H/L` | Move workspace to monitor |

### Workspaces
| Key | Action |
|-----|--------|
| `Super + 1-0` | Switch to workspace 1-10 |
| `Super + Shift + 1-0` | Move window to workspace |
| `Super + Scroll` | Cycle workspaces |

### Pyprland Scratchpads
| Key | Action |
|-----|--------|
| `Super + \`` | Terminal scratchpad |
| `Super + Shift + E` | File manager scratchpad |
| `Super + Shift + A` | Volume control scratchpad |
| `Super + Shift + \`` | Move window to built-in scratchpad |

### Pyprland Utilities
| Key | Action |
|-----|--------|
| `Super + Z` | Toggle magnifier (2x zoom) |
| `Super + O` | Expose all windows (Mission Control) |

### Media
| Key | Action |
|-----|--------|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioPlay` | Play/pause |
| `XF86AudioNext/Prev` | Next/previous track |

### Screenshots
| Key | Action |
|-----|--------|
| `Super + Shift + S` | Screenshot region |

## Dependencies

### Required
- [hyprland](https://hyprland.org/) - Wayland compositor
- [waybar](https://github.com/Alexays/Waybar) - Status bar
- [hyprpaper](https://github.com/hyprwm/hyprpaper) - Wallpaper
- [hyprlock](https://github.com/hyprwm/hyprlock) - Lock screen
- [hypridle](https://github.com/hyprwm/hypridle) - Idle daemon

### Recommended
- [wezterm](https://wezfurlong.org/wezterm/) - Terminal
- [rofi](https://github.com/davatorium/rofi) - App launcher
- [dolphin](https://apps.kde.org/dolphin/) - File manager
- [grim](https://sr.ht/~emersion/grim/) + [slurp](https://github.com/emersion/slurp) - Screenshots
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) - Clipboard
- [cliphist](https://github.com/sentriz/cliphist) - Clipboard history
- [playerctl](https://github.com/altdesktop/playerctl) - Media control
- [wlogout](https://github.com/ArtsyMacaw/wlogout) - Logout menu
- [blueman](https://github.com/blueman-project/blueman) - Bluetooth
- [network-manager-applet](https://gitlab.gnome.org/GNOME/network-manager-applet) - Network

## Idle Behavior

Configured in `hypridle.conf`:

| Timeout | Action |
|---------|--------|
| 4:50 | Notification: "Locking session soon!" |
| 5:00 | Dim external monitors |
| 10:00 | Lock screen |
| 10:30 | Turn off displays |
| 30:00 | Suspend |

## Plugins

### pyprland
Python plugin system providing advanced scratchpads, magnifier, and expose view.

```bash
yay -S pyprland
```

**Features enabled:**
- **scratchpads** — Named scratchpads with animations (term, files, volume)
- **magnify** — 2x screen zoom for accessibility/presentations
- **expose** — macOS Mission Control-style window overview

### split-monitor-workspaces
Per-monitor workspaces like AwesomeWM. **Currently broken** on Hyprland 0.52.0—waiting for plugin update.

```bash
hyprpm add https://github.com/Duckonaut/split-monitor-workspaces
hyprpm enable split-monitor-workspaces
hyprpm reload
```

## Gaming

Steam games automatically:
- Launch fullscreen
- Disable VSync (`immediate` mode) for lower latency
- Disable blur for performance

VRR/G-Sync is enabled via environment variables.

## License

[GPL-3.0 license](LICENSE)
