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
        inactive_opacity = 0.95,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
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
hl.bind("SUPER + A", hl.dsp.exec_cmd("ghostty --title=cava -e cava"))

-- Wallpaper picker (rofi thumbnail grid over ~/Pictures/Wallpapers)
hl.bind("SUPER + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper-picker.sh"))

-- Music player (cliamp, Catppuccin theme in ~/.config/cliamp) as a floating window.
-- Media keys reach it over MPRIS via playerctl.
hl.window_rule({
    name   = "cliamp-floating",
    match  = { title = "^cliamp$" },
    float  = true,
    size   = "55% 60%",
    center = true,
})
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("ghostty --title=cliamp -e cliamp"))
