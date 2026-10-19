-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- HYPRWIZRD LOOK (Catppuccin Frappé)                      --
-- From github.com/hyprwizrd/hyprwizrd-dotfiles,          --
-- ported to the Hyprland Lua config.                     --
-- Loaded at the end of hyprland.lua via require(...)     --
-- Previous look: aurora.lua (swap the require back).     --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Catppuccin Frappé palette
local mauve    = "rgba(ca9ee6ee)"
local blue     = "rgba(8caaeeee)"
local surface0 = "rgba(414559ee)"

hl.config({
    general = {
        gaps_in     = 3,
        gaps_out    = 6,
        border_size = 2,

        col = {
            active_border   = { colors = { blue, mauve }, angle = 45 },
            inactive_border = surface0,
        },
    },

    decoration = {
        rounding       = 4,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 8,
            passes   = 3,
            vibrancy = 0.1696,
        },
    },

    misc = {
        -- Use our wallpaper instead of the built-in anime/logo backgrounds
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

-- Floating popups opened from the bar
hl.window_rule({
    name   = "btop-centered",
    match  = { title = "^btop$" },
    float  = true,
    size   = "70% 70%",
    center = true,
})

hl.window_rule({
    name   = "nmtui-centered",
    match  = { title = "^nmtui$" },
    float  = true,
    size   = "50% 50%",
    center = true,
})

hl.window_rule({
    name   = "pavucontrol-centered",
    match  = { class = "^org\\.pulseaudio\\.pavucontrol$" },
    float  = true,
    size   = "800 600",
    center = true,
})

-- Keys
hl.bind("SUPER + L",           hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + Escape",      hl.dsp.exec_cmd("~/.config/rofi/powermenu/type-2/powermenu.sh"))
hl.bind("SUPER + Print",       hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("SUPER + SHIFT + P",   hl.dsp.exec_cmd("hyprpicker -a"))

-- Music visualizer (cava, Catppuccin gradient) as a floating window
hl.window_rule({
    name   = "cava-floating",
    match  = { title = "^cava$" },
    float  = true,
    size   = "60% 40%",
    center = true,
})
-- (--window-width/height are in cells, about 9.3 x 20 px each: the Mac's shared Ghostty config asks for a
-- 226x64 window, which would otherwise override the size rules here)
hl.bind("SUPER + A", hl.dsp.exec_cmd("ghostty --title=cava --window-width=121 --window-height=20 -e cava"))

-- Night tint on/off by hand (hyprsunset starts at login with the times in hyprsunset.conf)
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("sh -c 'pkill -x hyprsunset || hyprsunset'"))

-- Wallpaper picker (rofi thumbnail grid over ~/Pictures/Wallpapers)
hl.bind("SUPER + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-picker.sh"))

-- Clipboard history (cliphist, stored by the wl-paste lines in hyprland.lua) and window switcher,
-- both in the same rofi style as the SUPER+R launcher.
hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("sh -c 'cliphist list | rofi -dmenu -p Clipboard -theme ~/.config/rofi/launchers/type-1/style-3.rasi | cliphist decode | wl-copy'"))
hl.bind("SUPER + Tab",       hl.dsp.exec_cmd("rofi -show window -theme ~/.config/rofi/launchers/type-1/style-3.rasi"))

-- Music player (cliamp, Catppuccin theme in ~/.config/cliamp) as a floating window.
-- Media keys reach it over MPRIS via playerctl.
hl.window_rule({
    name   = "cliamp-floating",
    match  = { title = "^cliamp$" },
    float  = true,
    size   = "55% 60%",
    center = true,
})
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("ghostty --title=cliamp --window-width=111 --window-height=30 -e cliamp"))

-- Image viewer (Gwenview, the default for images) as a floating window.
hl.window_rule({
    name   = "gwenview-floating",
    match  = { class = "^org\\.kde\\.gwenview$" },
    float  = true,
    size   = "1152 756",
    center = true,
})
