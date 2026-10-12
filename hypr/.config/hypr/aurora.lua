-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- AURORA LOOK (Catppuccin Frappé)                         --
-- Inspired by github.com/flickowoa/dotfiles (aurora),    --
-- ported to the Hyprland Lua config.                     --
-- Loaded at the end of hyprland.lua via require("aurora")--
-- To go back to the defaults, comment out that line.     --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Catppuccin Frappé palette
local mauve    = "rgba(ca9ee6ff)"
local blue     = "rgba(8caaeeff)"
local teal     = "rgba(81c8beff)"
local surface1 = "rgba(51576dff)"

hl.config({
    general = {
        gaps_in     = 8,
        gaps_out    = 15,
        border_size = 3,

        col = {
            -- The signature aurora border: mauve -> blue -> teal
            active_border   = { colors = { mauve, blue, teal }, angle = 10 },
            inactive_border = surface1,
        },
    },

    decoration = {
        rounding = 15,

        shadow = {
            enabled      = true,
            range        = 60,
            render_power = 4,
            color        = 0x55000000,
        },

        blur = {
            enabled  = true,
            size     = 6,
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

-- Aurora's springy "overshot" curve: windows slide in and settle with a bounce
hl.curve("overshot", { type = "bezier", points = { {0.13, 0.99}, {0.29, 1.1} } })

hl.animation({ leaf = "windows",       enabled = true, speed = 4,  bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4,  bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 4,  bezier = "overshot", style = "slide" })
hl.animation({ leaf = "border",        enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 6,  bezier = "overshot", style = "slidevert" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 6,  bezier = "overshot", style = "slidevert" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 6,  bezier = "overshot", style = "slidevert" })

-- Blur behind the bar, launcher and notifications
hl.layer_rule({ name = "blur-waybar", match = { namespace = "^waybar$" }, blur = true })
hl.layer_rule({ name = "blur-wofi",   match = { namespace = "^wofi$" },   blur = true })
hl.layer_rule({ name = "blur-mako",   match = { namespace = "^notifications$" }, blur = true })

-- Lock screen
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
