-- ╭──────────╮
-- │ Displays │
-- ╰──────────╯
require("display").monitors()

-- ╭───────────╮
-- │ Autostart │
-- ╰───────────╯
-- finalize() must run first: it tells the systemd user manager the compositor
-- is ready, which activates graphical-session.target and pulls in waybar,
-- hypridle, and any other PartOf= units.
require("autostart").finalize()
require("autostart").programs()
require("autostart").commands()

-- ╭──────────╮
-- │ Keybinds │
-- ╰──────────╯
require("keybinds").setup()

-- ╭─────────╮
-- │ Plugins │
-- ╰─────────╯
require("plugins").split_monitors()

-- ╭────────────╮
-- │ Appearance │
-- ╰────────────╯
require("appearance").setup()
require("appearance").animations()
require("appearance").decorations()
require("appearance").misc()

-- ╭─────────────╮
-- │ Environment │
-- ╰─────────────╯
require("environment").setup()

-- ╭───────╮
-- │ Rules │
-- ╰───────╯
require("rules").steam()
require("rules").terminal()
require("rules").utilities()

-- ╭────────╮
-- │ Inputs │
-- ╰────────╯
require("inputs").setup()
