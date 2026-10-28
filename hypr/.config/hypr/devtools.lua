-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- DEVELOPER EXTRAS                                       --
-- Window rules, layer blur and keys for the dev workflow. --
-- Loaded (inside pcall) at the end of hyprland.lua, so a  --
-- mistake here can't stop the rest of the config loading. --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local mainMod = "SUPER"

---------------------------
---- LAYER BLUR (glass) ----
---------------------------
-- ignore_alpha keeps the transparent gaps around waybar's pills from being blurred.
hl.layer_rule({ name = "blur-waybar",        match = { namespace = "^waybar$" },         blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ name = "blur-rofi",          match = { namespace = "^rofi$" },           blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ name = "blur-notifications", match = { namespace = "^notifications$" },  blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ name = "blur-swayosd",       match = { namespace = "^swayosd$" },        blur = true, ignore_alpha = 0.3 })

-------------------------
---- SMART GAPS ---------
-------------------------
-- A lone window fills the screen: no gaps, border or rounding.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})
hl.window_rule({
    name  = "no-gaps-f1",
    match = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})

------------------------------
---- FLOATING UTILITIES ------
------------------------------
hl.window_rule({
    name   = "polkit-floating",
    match  = { class = "^(hyprpolkitagent|org\\.kde\\.polkit-kde-authentication-agent-1)$" },
    float  = true,
    center = true,
})

hl.window_rule({
    name   = "bitwarden-floating",
    match  = { class = "^Bitwarden$" },
    float  = true,
    size   = "900 650",
    center = true,
})

hl.window_rule({
    name   = "blueman-floating",
    match  = { class = "^\\.?blueman-manager" },
    float  = true,
    size   = "600 500",
    center = true,
})

-- Floating terminals opened from the bar and keys below
hl.window_rule({
    name   = "lazydocker-centered",
    match  = { title = "^lazydocker$" },
    float  = true,
    size   = "75% 75%",
    center = true,
})

hl.window_rule({
    name   = "maintain-centered",
    match  = { title = "^maintain$" },
    float  = true,
    size   = "60% 70%",
    center = true,
})

hl.window_rule({
    name   = "update-centered",
    match  = { title = "^update$" },
    float  = true,
    size   = "60% 60%",
    center = true,
})

-- Brave picture-in-picture: always on top, on every workspace, bottom-right corner
hl.window_rule({
    name  = "brave-pip",
    match = { title = "^(Picture in picture|Picture-in-Picture)$" },
    float = true,
    pin   = true,
    size  = "480 270",
    move  = "monitor_w-window_w-20 monitor_h-window_h-20",
})

-----------------------------
---- WORKSPACE HOMES --------
-----------------------------
-- "silent" opens the window there without pulling you away from what you're doing.
-- float = false keeps pop-ups (like the PiP window above) out of it.
hl.window_rule({
    name  = "browser-on-2",
    match = { class = "^brave-browser$", float = false },
    workspace = "2 silent",
})
hl.window_rule({
    name  = "obsidian-on-3",
    match = { class = "^obsidian$" },
    workspace = "3 silent",
})

---------------------------------
---- DROP-DOWN TERMINAL ---------
---------------------------------
-- SUPER+grave: scripts/dropdown.sh starts it once, then shows/hides special:dropdown.
hl.window_rule({
    name      = "dropdown-terminal",
    match     = { class = "^dev\\.seif\\.dropdown$" },
    workspace = "special:dropdown",
    float     = true,
    size      = "80% 50%",
    move      = "10% 6",
})
hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd("~/.config/hypr/scripts/dropdown.sh"))

---------------------
---- DEV KEYS -------
---------------------
-- Project switcher: rofi over ~/Developer, opens a ghostty in a tmux session for the pick
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("~/.config/hypr/scripts/project-switcher.sh"))

-- Run the weekly maintenance script in a floating terminal
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.exec_cmd("~/.config/hypr/scripts/maintain-popup.sh"))

-- Annotate a screenshot with satty (arrows, text, blur), then copy it
hl.bind("CTRL + SHIFT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot-annotate.sh"))

-- dwindle <-> scrolling layout
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("~/.config/hypr/scripts/layout-toggle.sh"))
