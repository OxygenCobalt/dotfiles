local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local util = require("quark.util")
local math = math

local function new(args)
	local ret = wibox.widget {
        {
            image = beautiful.quark_exit_icon,
            widget = wibox.widget.imagebox
        },
        top = dpi(4),
        bottom = dpi(4),
        widget = wibox.container.margin
    }

    local menu = awful.menu {
    	items = {
    		{ "lock", args.on_lock, beautiful.quark_lock_icon },
    		{ "logout", args.on_logout, beautiful.quark_logout_icon },
    		{ "suspend", args.on_suspend, beautiful.quark_suspend_icon },
    		{ "reboot", args.on_reboot, beautiful.quark_reboot_icon },
			{ "shutdown", args.on_shutdown, beautiful.quark_shutdown_icon },
    	}
    }

    ret:connect_signal(
        "button::press",
        function(_, _, _, button)
            if button == 1 then
            	menu:toggle()
            end
        end
    )

	return {
        widget = ret,
        menu = menu
    }
end

return new