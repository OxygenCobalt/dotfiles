local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gfs = require("gears.filesystem")

local os = os
local titlebar_path = os.getenv("HOME") .. "/.config/awesome/titlebar/"
local chrome_path = os.getenv("HOME") .. "/.config/awesome/chrome/"
local themes_path = gfs.get_themes_dir()

-- inherit default theme
local theme = dofile(themes_path.."default/theme.lua")

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

theme.bar_bg = "#404040"
theme.bar_great = "#00ccff"
theme.bar_good = "#0099cc"
theme.bar_okay = "#006699"
theme.bar_poor = "#6666cc"
theme.bar_critical = "#9999ff"

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

theme.menu_submenu_icon = chrome_path.."more.png"
theme.menu_height = dpi(32)
theme.menu_width  = dpi(256)

theme.titlebar_close_button_normal = titlebar_path.."normal.png"
theme.titlebar_close_button_focus  = titlebar_path.."close_focus.png"
theme.titlebar_close_button_focus_hover = titlebar_path.."close_hover.png" 
theme.titlebar_close_button_focus_press = titlebar_path.."close_press.png" 

theme.titlebar_maximized_button_normal_inactive = titlebar_path.."normal.png"
theme.titlebar_maximized_button_focus_inactive  = titlebar_path.."maximize_focus.png"
theme.titlebar_maximized_button_focus_inactive_hover = titlebar_path.."maximize_hover_inactive.png"
theme.titlebar_maximized_button_focus_inactive_press  = titlebar_path.."maximize_press_inactive.png"

theme.titlebar_maximized_button_normal_active = titlebar_path.."normal.png"
theme.titlebar_maximized_button_focus_active  = titlebar_path.."maximize_focus.png"
theme.titlebar_maximized_button_focus_active_hover = titlebar_path.."maximize_hover_active.png"
theme.titlebar_maximized_button_focus_active_press  = titlebar_path.."maximize_press_active.png"

theme.titlebar_minimize_button_normal = titlebar_path.."normal.png"
theme.titlebar_minimize_button_focus  = titlebar_path.."minimize_focus.png"
theme.titlebar_minimize_button_focus_hover  = titlebar_path.."minimize_hover.png"
theme.titlebar_minimize_button_focus_press  = titlebar_path.."minimize_press.png"

theme.awesome_icon = chrome_path.."launcher.png"
theme.wallpaper = chrome_path.."wall.png"
theme.icon_theme = "Papirus-Dark"

return theme
