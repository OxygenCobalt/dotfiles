-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

local quark = require("quark")

local os = os
local io = io
local config_path = os.getenv("HOME") .. "/.config/awesome/"
local chrome_path = os.getenv("HOME") .. "/.config/awesome/chrome/"

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "A startup error occured.",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "An error occured.",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

beautiful.init(config_path .. "theme.lua")

-- Some XDG autostart files in this configuration will fail on startup,
-- as they rely on an X server to function. This makes sure that these are ran.
awful.spawn.with_shell(
   'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
   'xrdb -merge <<< "awesome.started:true";' ..
   'dex --environment Awesome --autostart --search-paths /etc/xdg/autostart;' ..
   'dex --environment Awesome --autostart --search-paths ~/.config/autostart;' ..
   'xset b off'
)

terminal = "kitty"
editor = os.getenv("EDITOR") or "micro"
editor_cmd = terminal .. " -e " .. editor
filemgr_cmd = terminal .. " -e nnn"

modkey = "Mod4"

-- Floating only, tiling WMs aren't my thing
awful.layout.layouts = {
    awful.layout.suit.floating
}
-- }}}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
local myexitmenu = quark.exit {
    on_lock = function() awful.spawn("light-locker-command -l") end,
    on_logout = function() awesome.quit() end,
    on_suspend = function() awful.spawn("systemctl suspend") end,
    on_reboot = function() awful.spawn("reboot") end,
    on_shutdown = function() awful.spawn("shutdown now") end
}

local mycpu = quark.cpu { open = "lxtask" }
local mymem = quark.mem { open = "lxtask" }

-- Determine the network device to use. This is always the first active non-loopback device we find.
local mynet = nil
local p = io.popen("ip link")

for line in p:lines() do
    local device = not string.match(line, "LOOPBACK") and string.match(line, "state UP") and string.match(line, "(%w+): <") or nil

    if type(device) ~= "nil" then
        mynet = quark.net { 
            device = device,
            unit = {
                name = "kb",
                denom = 1024
            },
            up_max = 32,
            down_max = 512
        }
        
        break
    end
end

local mypwr = nil

-- Sanity check: Do we even have a battery?
-- If we do, then make a pwr widget, otherwise keep it nil.
-- The way we detect this is stupid and dumb and probably fails with
-- some edge case, but there is nothing else we can do since acpi
-- returns 0 regardless of whether it can find a battery or not.
local has_battery = false
local p = io.popen('bash -c "acpi -b | head -n 1"') -- Clip to the first input since thats all we use

for l in p:lines() do
    if string.match(l, "Battery") then
        has_battery = true
        break
    end
end

if has_battery then
    mypwr = quark.pwr {
        get = {
            cmd = 'bash -c "acpi -b | head -n 1"',
            parse = function(stdout)
                local stripped = string.sub(stdout, string.find(stdout, ":.+") + 2)
                local i = 1
                local acpi = {}

                for w in string.gmatch(stripped, "[%a%d:]+") do
                    if i == 1 then
                        acpi["status"] = w
                    elseif i == 2 then
                        acpi["perc"] = tonumber(w)
                    elseif i == 3 and string.match(w, "%d+:%d+:%d+") then
                        acpi["time"] = w
                    end

                    i = i + 1
                end

                return acpi
            end
        }
    }
end

local mypulse = quark.pulse {
    get = {
        cmd = "pamixer --get-volume --get-mute",
        parse = function(stdout)        
            local i = 1
            local pulse = {}

            for w in string.gmatch(stdout, "%g+") do
                if i == 1 then
                    pulse["muted"] = w == "true"
                elseif i == 2 then
                    pulse["vol"] = tonumber(w)
                else
                    break
                end

                i = i + 1
            end

            return pulse
        end
    },
    up_cmd = "pamixer -i 5",
    down_cmd = "pamixer -d 5",
    toggle_cmd = "pamixer --toggle-mute",
    open = "pavucontrol"
}

local mytextclock = wibox.widget.textclock("%H:%M")

local window_menu = nil
local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                {raise = true}
            )
        end
    end),
    awful.button({ }, 3, function(c)
        -- Custom menu function that implements the good parts of XFCE's menu
		local minimize_lbl = "minimize"
		local maximize_lbl = "maximize"
        local ontop_lbl = "keep on top"
			
		if c.minimized then
			minimize_lbl = "unminimize"
		end

		if c.maximized then
			maximize_lbl = "unmaximize"
		end

        if c.ontop then
            ontop_lbl = "remove from top"
        end

        -- Ensure that two menus cannot exist at the same time
        if type(window_menu) == "nil" then 
            window_menu = awful.menu({ items = { 
                { minimize_lbl, function() c.minimized = not c.minimized end },
                { maximize_lbl, function() c.maximized = not c.maximized end },
                { ontop_lbl, function() c.ontop = not c.ontop end },
                { "close", function() c:kill() end },
            }})
        else
            window_menu:hide()
            window_menu = awful.menu({ items = { 
                { minimize_lbl, function() c.minimized = not c.minimized end },
                { maximize_lbl, function() c.maximized = not c.maximized end },
                { ontop_lbl, function() c.ontop = not c.ontop end },
                { "close", function() c:kill() end },
            }})
        end

        window_menu:show()
    end),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
    end)
)

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        
        gears.wallpaper.fit(wallpaper, s)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    -- I don't get use out of tags.
    awful.tag({ "1" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    
    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.currenttags,
        buttons  = tasklist_buttons,
        style    = {
            border_width = 0,
            shape        = gears.shape.octogon,
        },
        layout   = {
            layout  = wibox.layout.flex.horizontal
        },
        widget_template = {
            {
                {
                    {
                        {
                            id     = "icon_role",
                            widget = wibox.widget.imagebox,
                        },
                        top = dpi(4),
                        bottom = dpi(4),
                        widget = wibox.container.margin
                    },
                    {
                        id     = "text_role",
                        widget = wibox.widget.textbox
                    },
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(4),
                },
                left = dpi(8),
                right = dpi(8),
                widget = wibox.container.margin
            },
            id     = "background_role",
            widget = wibox.container.background,
        },
    }
        
    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        wibox.widget.base.empty_widget(),  
        {
            {
                widget = s.mytasklist
            },
            widget = wibox.container.margin
        },
        {
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(8),
                mycpu,
                mymem,
                mynet,
                mypulse.widget,
                mypwr,
                wibox.widget.systray(),
                mytextclock
            },
            left = dpi(8),
            right = dpi(8),
            widget = wibox.container.margin
        }
    }
end)
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description = "show help", group = "awesome"}),

    awful.key({ modkey,           }, "Left",
        function () awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}),

    awful.key({ modkey,           }, "Right",
        function () awful.client.focus.byidx( 1) end,
        {description = "focus next by index", group = "client"}),

    awful.key({ modkey,           }, "q", function () myexitmenu:show() end,
              {description = "show exit prompt", group = "awesome"}),

    awful.key({ modkey, "Shift"   }, "Left", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),

    awful.key({ modkey, "Shift"   }, "Right", function () awful.client.swap.byidx( 1)    end,
              {description = "swap with previous client by index", group = "client"}),

    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),

    awful.key({ modkey,           }, "/", function () awful.spawn(filemgr_cmd) end,
              {description = "open file manager", group = "launcher"}),
              
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),

    awful.key({ modkey }, "r", function() menubar.show() end,
              {description = "show run menu", group = "launcher"}),

   -- Volume Keys
   awful.key({}, "XF86AudioRaiseVolume", function ()
            mypulse.up()
        end),

    awful.key({}, "XF86AudioLowerVolume", 
        function()
            mypulse.down()
        end),

   awful.key({}, "XF86AudioMute", function ()
            mypulse.toggle()
        end),

   -- Media Keys
   awful.key({}, "XF86AudioPlay", function()
            awful.util.spawn("playerctl play-pause", false)
        end),

   awful.key({}, "XF86AudioNext", function()
            awful.util.spawn("playerctl next", false)
        end),

   awful.key({}, "XF86AudioPrev", function()
            awful.util.spawn("playerctl previous", false) 
        end)
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),

    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),

    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"})
)

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),

    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    -- Screw tooltips, all my homies hate tooltips
    awful.titlebar.enable_tooltip = false

    awful.titlebar(c, { size = beautiful.titlebar_height }) : setup {
        { -- Left
        	{
        		{
        			widget = awful.titlebar.widget.iconwidget(c)
        		},
        		margins = dpi(4),
        		widget = wibox.container.margin
        	},
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.minimizebutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
