local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local os = os

local home = os.getenv("HOME")
local titlebar_path = home .. "/.config/awesome/titlebar/"
local chrome_path = home .. "/.config/awesome/chrome/"
local themes_path = gears.filesystem.get_themes_dir()

-- inherit default theme
local theme = dofile(themes_path .. "default/theme.lua")

theme.font          = "Inconsolata 12"

theme.bg_normal     = "#000000"
theme.bg_focus      = "#006699"
theme.bg_urgent     = "#6666cc"
theme.bg_minimize   = "#000000"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#FFFFFF"
theme.fg_focus      = "#FFFFFF"
theme.fg_urgent     = "#FFFFFF"
theme.fg_minimize   = "#808080"

theme.useless_gap   = dpi(4)
theme.border_width  = dpi(2)
theme.border_normal = "#404040"
theme.border_focus  = "#404040"
theme.border_marked = "#404040"

theme.titlebar_bg_normal = "#000000"
theme.titlebar_bg_focus = "#000000"
theme.titlebar_fg_normal = "#808080"

theme.tooltip_bg = theme.bg_normal
theme.tooltip_fg = theme.fg_normal

theme.menu_submenu_icon = chrome_path .. "submenu.svg"
theme.menu_height = dpi(32)
theme.menu_width  = dpi(256)

theme.titlebar_close_button_normal = titlebar_path.."normal.svg"
theme.titlebar_close_button_focus  = titlebar_path.."close_focus.svg"
theme.titlebar_close_button_focus_hover = titlebar_path.."close_hover.svg" 
theme.titlebar_close_button_focus_press = titlebar_path.."close_press.svg" 

theme.titlebar_maximized_button_normal_inactive = titlebar_path.."normal.svg"
theme.titlebar_maximized_button_focus_inactive  = titlebar_path.."maximize_focus.svg"
theme.titlebar_maximized_button_focus_inactive_hover = titlebar_path.."maximize_hover_inactive.svg"
theme.titlebar_maximized_button_focus_inactive_press  = titlebar_path.."maximize_press_inactive.svg"

theme.titlebar_maximized_button_normal_active = titlebar_path.."normal.svg"
theme.titlebar_maximized_button_focus_active  = titlebar_path.."maximize_focus.svg"
theme.titlebar_maximized_button_focus_active_hover = titlebar_path.."maximize_hover_active.svg"
theme.titlebar_maximized_button_focus_active_press  = titlebar_path.."maximize_press_active.svg"

theme.titlebar_minimize_button_normal = titlebar_path.."normal.svg"
theme.titlebar_minimize_button_focus  = titlebar_path.."minimize_focus.svg"
theme.titlebar_minimize_button_focus_hover  = titlebar_path.."minimize_hover.svg"
theme.titlebar_minimize_button_focus_press  = titlebar_path.."minimize_press.svg"

theme.awesome_icon = chrome_path.."application-exit-symbolic.svg"
theme.wallpaper = chrome_path.."wall.png"
theme.icon_theme = "Papirus-Dark"

theme.quark_bar_bg = "#404040"
theme.quark_bar_great = "#00ccff"
theme.quark_bar_good = "#0099cc"
theme.quark_bar_okay = "#006699"
theme.quark_bar_poor = "#6666cc"
theme.quark_bar_critical = "#9999ff"

theme.quark_exit_icon = chrome_path .. "application-exit-symbolic.svg"
theme.quark_lock_icon = chrome_path .. "system-lock-screen-symbolic.svg"
theme.quark_logout_icon = chrome_path .. "system-log-out-symbolic.svg"
theme.quark_suspend_icon = chrome_path .. "system-suspend-symbolic.svg"
theme.quark_reboot_icon = chrome_path .. "system-reboot-symbolic.svg"
theme.quark_shutdown_icon = chrome_path .. "system-shutdown-symbolic.svg"

theme.quark_volume_overamp_icon = chrome_path .. "audio-volume-overamplified-symbolic.svg"
theme.quark_volume_high_icon = chrome_path .. "audio-volume-high-symbolic.svg"
theme.quark_volume_medium_icon = chrome_path .. "audio-volume-medium-symbolic.svg"
theme.quark_volume_low_icon = chrome_path .. "audio-volume-low-symbolic.svg"
theme.quark_volume_muted_icon = chrome_path .. "audio-volume-muted-symbolic.svg"

return theme
